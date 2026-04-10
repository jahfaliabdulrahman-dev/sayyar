import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

import '../../domain/repositories/service_task_repository.dart';
import '../models/service_task.dart';

/// //===========================================================
/// Service Task Repository — Isar Implementation
/// //===========================================================
///
/// Implements the ServiceTaskRepository contract against Isar.
/// Handles OEM interval seeding, due-date computation, and task
/// completion tracking.
///
/// Key Design Decisions:
///   1. Seed is idempotent — safe to call multiple times. If tasks
///      already exist for a vehicle, the method returns immediately.
///   2. OEM JSON loading is failure-safe: if the asset is missing or
///      malformed, returns false instead of crashing the app.
///   3. Overdue/upcoming computation runs in-memory against the
///      live odometer — no stale cached state in the database.
/// //===========================================================
class ServiceTaskRepositoryImpl implements ServiceTaskRepository {
  /// Isar database instance, injected via constructor.
  final Isar isar;

  const ServiceTaskRepositoryImpl(this.isar);

  // ============================================================
  // SEEDING
  // ============================================================

  @override
  Future<bool> seedTasksForVehicle(int vehicleId) async {
    try {
      // Guard: skip if tasks already exist for this vehicle (idempotent).
      final existingCount = await isar.serviceTasks
          .filter()
          .vehicleIdEqualTo(vehicleId)
          .count();
      if (existingCount > 0) return true;

      // Load OEM intervals from the bundled JSON asset.
      final jsonString = await rootBundle.loadString(
        'assets/oem/tank_300_intervals.json',
      );
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final intervals = jsonData['serviceIntervals'] as List<dynamic>;

      // Transform JSON objects into ServiceTask models.
      final tasks = <ServiceTask>[];
      for (final interval in intervals) {
        final data = interval as Map<String, dynamic>;
        tasks.add(ServiceTask(
          vehicleId: vehicleId,
          taskKey: data['taskKey'] as String,
          displayNameAr: data['displayNameAr'] as String,
          displayNameEn: data['displayNameEn'] as String,
          intervalKm: data['intervalKm'] as int?,
          intervalMonths: data['intervalMonths'] as int?,
          lastDoneKm: null,
          lastDoneDate: null,
        ));
      }

      // Persist all tasks in a single write transaction.
      await isar.writeTxn(() async {
        await isar.serviceTasks.putAll(tasks);
      });

      return true;
    } catch (e) {
      /// Asset not found, malformed JSON, or any other failure.
      /// The app MUST NOT crash — return false so callers know seeding failed.
      return false;
    }
  }

  // ============================================================
  // READ — All queries
  // ============================================================

  @override
  Future<List<ServiceTask>> getAllTasks(int vehicleId) async {
    return isar.serviceTasks
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .sortByTaskKey()
        .findAll();
  }

  @override
  Future<List<ServiceTask>> getOverdueTasks({
    required int vehicleId,
    required int currentOdometerKm,
  }) async {
    final tasks = await getAllTasks(vehicleId);
    final now = DateTime.now();

    return tasks.where((task) {
      // — KM-based overdue check —
      if (task.intervalKm != null) {
        if (task.lastDoneKm == null) {
          // Never done — overdue once vehicle passes the first interval.
          if (currentOdometerKm >= task.intervalKm!) return true;
        } else {
          final kmSinceLast = currentOdometerKm - task.lastDoneKm!;
          if (kmSinceLast >= task.intervalKm!) return true;
        }
      }

      // — Time-based overdue check —
      if (task.intervalMonths != null) {
        if (task.lastDoneDate == null) {
          // Never done — not time-overdue until enough months pass.
          return false;
        } else {
          final dueDate = task.lastDoneDate!.add(
            Duration(days: task.intervalMonths! * 30),
          );
          if (now.isAfter(dueDate)) return true;
        }
      }

      return false;
    }).toList();
  }

  @override
  Future<List<ServiceTask>> getUpcomingTasks({
    required int vehicleId,
    required int currentOdometerKm,
    int? thresholdKm,
    int? thresholdMonths,
  }) async {
    // First, determine which tasks are already overdue so we exclude them.
    final overdue = await getOverdueTasks(
      vehicleId: vehicleId,
      currentOdometerKm: currentOdometerKm,
    );
    final overdueIds = overdue.map((t) => t.id).toSet();

    if (thresholdKm == null && thresholdMonths == null) {
      // No thresholds — return all non-overdue tasks.
      return (await getAllTasks(vehicleId))
          .where((t) => !overdueIds.contains(t.id))
          .toList();
    }

    final allTasks = await getAllTasks(vehicleId);
    final now = DateTime.now();

    return allTasks.where((task) {
      // Skip already overdue tasks.
      if (overdueIds.contains(task.id)) return false;

      // — KM-based upcoming check —
      if (thresholdKm != null && task.intervalKm != null) {
        final kmSinceLast = task.lastDoneKm != null
            ? currentOdometerKm - task.lastDoneKm!
            : currentOdometerKm;
        final kmRemaining = task.intervalKm! - kmSinceLast;
        if (kmRemaining > 0 && kmRemaining <= thresholdKm) return true;
      }

      // — Time-based upcoming check —
      if (thresholdMonths != null && task.intervalMonths != null) {
        if (task.lastDoneDate != null) {
          final dueDate = task.lastDoneDate!.add(
            Duration(days: task.intervalMonths! * 30),
          );
          final daysUntilDue = dueDate.difference(now).inDays;
          if (daysUntilDue > 0 && daysUntilDue <= thresholdMonths * 30) {
            return true;
          }
        }
      }

      return false;
    }).toList();
  }

  @override
  Future<bool> taskExists({
    required int vehicleId,
    required String taskKey,
  }) async {
    final count = await isar.serviceTasks
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .taskKeyEqualTo(taskKey)
        .count();
    return count > 0;
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  Future<bool> markTaskCompleted({
    required int vehicleId,
    required String taskKey,
    required int doneAtKm,
    DateTime? doneAtDate,
  }) async {
    try {
      final task = await isar.serviceTasks
          .filter()
          .vehicleIdEqualTo(vehicleId)
          .taskKeyEqualTo(taskKey)
          .findFirst();

      if (task == null) return false;

      task.lastDoneKm = doneAtKm;
      task.lastDoneDate = doneAtDate ?? DateTime.now();

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateTask({
    required int vehicleId,
    required String taskKey,
    required ServiceTask Function(ServiceTask task) taskUpdater,
  }) async {
    try {
      final task = await isar.serviceTasks
          .filter()
          .vehicleIdEqualTo(vehicleId)
          .taskKeyEqualTo(taskKey)
          .findFirst();

      if (task == null) return false;

      final updatedTask = taskUpdater(task);

      await isar.writeTxn(() async {
        await isar.serviceTasks.put(updatedTask);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // CREATE — Custom Tasks
  // ============================================================

  @override
  Future<bool> createTask(ServiceTask task) async {
    try {
      await isar.writeTxn(() async {
        await isar.serviceTasks.put(task);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // DELETE — Task Removal
  // ============================================================

  @override
  Future<bool> deleteTask({
    required int vehicleId,
    required String taskKey,
  }) async {
    try {
      final task = await isar.serviceTasks
          .filter()
          .vehicleIdEqualTo(vehicleId)
          .taskKeyEqualTo(taskKey)
          .findFirst();

      if (task == null) return false;

      await isar.writeTxn(() async {
        await isar.serviceTasks.delete(task.id);
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
