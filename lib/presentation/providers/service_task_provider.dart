import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/isar_provider.dart';
import '../../data/models/service_task.dart';
import '../../data/repositories/service_task_repository_impl.dart';
import '../../domain/repositories/service_task_repository.dart' show TaskUpdatePayload;
import 'vehicle_provider.dart';

/// ============================================================
/// Service Task Provider — AsyncNotifier
/// ============================================================
///
/// Manages OEM service tasks for the active vehicle.
/// Handles:
///   - Seeding tasks from OEM JSON on first load.
///   - Fetching all tasks and filtering overdue/upcoming.
///   - Marking tasks as completed when user logs maintenance.
///
/// Thresholds:
///   - Overdue is computed against the active vehicle odometer.
///   - Upcoming uses 5,000 km / 3 months thresholds.
/// ============================================================

/// Immutable snapshot of service task state for the UI.
///
/// 3-TIER ARCHITECTURE:
///   - overdueTasks: past due (currentOdometer >= lastDoneKm + intervalKm).
///   - upcomingTasks: due soon (remaining <= 1000 km OR <= 30 days).
///   - futureTasks: everything else (far away or never completed).
class ServiceTaskState {
  final List<ServiceTask> allTasks;
  final List<ServiceTask> overdueTasks;
  final List<ServiceTask> upcomingTasks;
  final List<ServiceTask> futureTasks;
  final bool isSeeded;

  const ServiceTaskState({
    this.allTasks = const [],
    this.overdueTasks = const [],
    this.upcomingTasks = const [],
    this.futureTasks = const [],
    this.isSeeded = false,
  });

  ServiceTaskState copyWith({
    List<ServiceTask>? allTasks,
    List<ServiceTask>? overdueTasks,
    List<ServiceTask>? upcomingTasks,
    List<ServiceTask>? futureTasks,
    bool? isSeeded,
  }) {
    return ServiceTaskState(
      allTasks: allTasks ?? this.allTasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
      upcomingTasks: upcomingTasks ?? this.upcomingTasks,
      futureTasks: futureTasks ?? this.futureTasks,
      isSeeded: isSeeded ?? this.isSeeded,
    );
  }

  /// Convenience: total number of tasks that need attention.
  int get attentionCount => overdueTasks.length + upcomingTasks.length;

  /// Returns allTasks sorted by urgency:
  ///   1. Overdue tasks first (already identified).
  ///   2. Then by nearest due — smallest (nextDueKm - currentOdometer) first.
  ///   3. Tasks with no lastDoneKm (never completed) go last.
  List<ServiceTask> sortedByUrgency({required int currentOdometerKm}) {
    final overdueKeys = overdueTasks.map((t) => t.taskKey).toSet();
    final sorted = List<ServiceTask>.from(allTasks);

    sorted.sort((a, b) {
      final aOverdue = overdueKeys.contains(a.taskKey);
      final bOverdue = overdueKeys.contains(b.taskKey);

      // Overdue always first.
      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;
      if (aOverdue && bOverdue) return 0;

      // Both non-overdue: sort by remaining KM (smallest first).
      final aNext = a.lastDoneKm != null && a.intervalKm != null
          ? (a.lastDoneKm! + a.intervalKm!) - currentOdometerKm
          : null;
      final bNext = b.lastDoneKm != null && b.intervalKm != null
          ? (b.lastDoneKm! + b.intervalKm!) - currentOdometerKm
          : null;

      if (aNext != null && bNext != null) return aNext.compareTo(bNext);
      if (aNext != null) return -1; // Has data → before no-data.
      if (bNext != null) return 1;
      return 0; // Both no-data → keep original order.
    });

    return sorted;
  }

  /// Computes the next due values for a task based on its last completion.
  ///
  /// DRIFT LOGIC:
  ///   Next Due KM = lastDoneKm + intervalKm
  ///     (Where lastDoneKm comes from the actual odometer at the time
  ///      of the most recent maintenance record of this type — NOT
  ///      from the theoretical OEM schedule.)
  ///
  ///   Next Due Date = lastDoneDate + (intervalMonths * 30 days)
  ///
  /// Returns null fields when the task has never been completed or
  /// has no interval defined.
  ({int? nextDueKm, DateTime? nextDueDate}) getNextDue(ServiceTask task) {
    int? nextDueKm;
    DateTime? nextDueDate;

    if (task.intervalKm != null) {
      if (task.lastDoneKm != null) {
        // Done before: next due = lastDoneKm + intervalKm.
        nextDueKm = task.lastDoneKm! + task.intervalKm!;
      } else {
        // Never done: first due at interval from factory (km 0).
        nextDueKm = task.intervalKm!;
      }
    }

    if (task.lastDoneDate != null && task.intervalMonths != null) {
      nextDueDate = task.lastDoneDate!.add(
        Duration(days: task.intervalMonths! * 30),
      );
    }

    return (nextDueKm: nextDueKm, nextDueDate: nextDueDate);
  }

  /// Classifies all tasks into 3 tiers based on current odometer.
  ///
  /// Tier logic:
  ///   - OVERDUE: remainingKm <= 0 OR remainingDays <= 0.
  ///   - UPCOMING: remainingKm <= 3000 OR remainingDays <= 30.
  ///   - FUTURE: everything else, including never-completed tasks.
  ///
  /// Returns (overdue, upcoming, future) tuple.
  static ({
    List<ServiceTask> overdue,
    List<ServiceTask> upcoming,
    List<ServiceTask> future,
  }) classifyTasks({
    required List<ServiceTask> allTasks,
    required int currentOdometerKm,
  }) {
    final now = DateTime.now();
    final overdue = <ServiceTask>[];
    final upcoming = <ServiceTask>[];
    final future = <ServiceTask>[];

    for (final task in allTasks) {
      int? remainingKm;
      int? remainingDays;

      if (task.intervalKm != null) {
        if (task.lastDoneKm != null) {
          // Done before: next due = lastDoneKm + intervalKm.
          remainingKm = (task.lastDoneKm! + task.intervalKm!) - currentOdometerKm;
        } else {
          // Never done: assume factory origin (km 0).
          // If odometer already past interval → overdue.
          remainingKm = task.intervalKm! - currentOdometerKm;
        }
      }
      if (task.lastDoneDate != null && task.intervalMonths != null) {
        final dueDate = task.lastDoneDate!.add(
          Duration(days: task.intervalMonths! * 30),
        );
        remainingDays = dueDate.difference(now).inDays;
      }

      // No computable axis → future.
      if (remainingKm == null && remainingDays == null) {
        future.add(task);
        continue;
      }

      // Overdue: any axis is past due.
      final isKmOverdue = remainingKm != null && remainingKm <= 0;
      final isTimeOverdue = remainingDays != null && remainingDays <= 0;
      if (isKmOverdue || isTimeOverdue) {
        overdue.add(task);
        continue;
      }

      // Upcoming: within 3000 km or 30 days.
      final isKmUpcoming = remainingKm != null && remainingKm <= 3000;
      final isTimeUpcoming = remainingDays != null && remainingDays <= 30;
      if (isKmUpcoming || isTimeUpcoming) {
        upcoming.add(task);
        continue;
      }

      // Everything else is future.
      future.add(task);
    }

    return (overdue: overdue, upcoming: upcoming, future: future);
  }
}

/// AsyncNotifier managing service task state.
///
/// Seeding happens automatically on first build if tasks don't
/// exist for the active vehicle.
class ServiceTaskNotifier extends AsyncNotifier<ServiceTaskState> {
  ServiceTaskRepositoryImpl get _repo => ServiceTaskRepositoryImpl(
        ref.watch(isarProvider),
      );

  @override
  Future<ServiceTaskState> build() async {
    // We need the active vehicle to seed and query tasks.
    final vehicleState = await ref.watch(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;

    if (vehicle == null) {
      return const ServiceTaskState(isSeeded: false);
    }

    // Seed tasks for this vehicle (idempotent — safe every build).
    await _repo.seedTasksForVehicle(vehicle.id);

    final odometer = vehicle.currentOdometerKm;

    // Fetch all tasks.
    final allTasks = await _repo.getAllTasks(vehicle.id);

    // 3-tier classification: overdue / upcoming (<=1000km,<=30d) / future.
    final classified = ServiceTaskState.classifyTasks(
      allTasks: allTasks,
      currentOdometerKm: odometer,
    );

    return ServiceTaskState(
      allTasks: allTasks,
      overdueTasks: classified.overdue,
      upcomingTasks: classified.upcoming,
      futureTasks: classified.future,
      isSeeded: true,
    );
  }

  /// Marks a specific task as completed.
  ///
  /// Parameters:
  ///   [taskKey] — The task identifier (e.g. "oil_change").
  ///   [doneAtKm] — Odometer reading at completion time.
  ///
  /// After marking complete, the state is refreshed to recalculate
  /// overdue/upcoming lists.
  Future<bool> markTaskCompleted({
    required String taskKey,
    required int doneAtKm,
  }) async {
    final vehicleState = await ref.watch(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;

    if (vehicle == null) return false;

    final success = await _repo.markTaskCompleted(
      vehicleId: vehicle.id,
      taskKey: taskKey,
      doneAtKm: doneAtKm,
    );

    if (success) {
      ref.invalidateSelf();
    }

    return success;
  }

  /// Creates a custom user-defined task not in the OEM schedule.
  ///
  /// BASELINE LOGIC:
  ///   - If startFromCurrentOdometer == true:
  ///       lastDoneKm = currentOdometer, lastDoneDate = now
  ///     (Task is "just done" — next due = current + interval)
  ///   - If false:
  ///       lastDoneKm = null, lastDoneDate = null
  ///     (Task starts from factory — next due = interval, may be overdue)
  ///
  /// Validation: at least one of intervalKm or intervalMonths must be set.
  Future<bool> addCustomTask({
    required String displayNameEn,
    int? intervalKm,
    int? intervalMonths,
    required bool startFromCurrentOdometer,
  }) async {
    final vehicleState = await ref.watch(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;
    if (vehicle == null) return false;

    final taskKey = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final task = ServiceTask(
      vehicleId: vehicle.id,
      taskKey: taskKey,
      displayNameAr: displayNameEn,
      displayNameEn: displayNameEn,
      intervalKm: intervalKm,
      intervalMonths: intervalMonths,
      lastDoneKm: startFromCurrentOdometer
          ? vehicle.currentOdometerKm
          : null,
      lastDoneDate: startFromCurrentOdometer
          ? DateTime.now()
          : null,
    );

    final success = await _repo.createTask(task);
    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }

  /// Deletes a service task by taskKey.
  Future<bool> deleteTask(String taskKey) async {
    final vehicleState = await ref.watch(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;
    if (vehicle == null) return false;

    final success = await _repo.deleteTask(
      vehicleId: vehicle.id,
      taskKey: taskKey,
    );
    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }

  /// Updates a single task's fields (name, intervals).
  Future<bool> updateTask({
    required String taskKey,
    String? displayNameEn,
    String? displayNameAr,
    int? intervalKm,
    int? intervalMonths,
  }) async {
    final vehicleState = await ref.watch(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;
    if (vehicle == null) return false;

    final success = await _repo.updateTask(
      vehicleId: vehicle.id,
      taskKey: taskKey,
      taskUpdater: (task) {
        if (displayNameEn != null) task.displayNameEn = displayNameEn;
        if (displayNameAr != null) task.displayNameAr = displayNameAr;
        if (intervalKm != null) task.intervalKm = intervalKm;
        if (intervalMonths != null) task.intervalMonths = intervalMonths;
        return task;
      },
    );
    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }

  /// Batch-updates task settings (intervals + baselines) for Setup Wizard.
  Future<bool> batchUpdateTaskSettings(Map<String, TaskUpdatePayload> updates) async {
    final vehicleState = await ref.watch(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;
    if (vehicle == null) return false;

    final success = await _repo.batchUpdateTaskSettings(
      vehicleId: vehicle.id,
      updates: updates,
    );
    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }

  /// Manually refreshes the task state (e.g., after user returns
  /// from a maintenance log screen).
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Riverpod provider for service task state.
final serviceTaskProvider =
    AsyncNotifierProvider<ServiceTaskNotifier, ServiceTaskState>(
  ServiceTaskNotifier.new,
);
