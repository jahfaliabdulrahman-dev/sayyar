/// ============================================================
/// Service Task Repository — Contract
/// ============================================================
///
/// Defines the data access contract for OEM-recommended service
/// tasks and their completion tracking.
///
/// This repository bridges the static OEM intervals (from
/// tank_300_intervals.json) with the user's completed service
/// history to compute due/overdue status.
/// ============================================================

import '../../data/models/service_task.dart';

/// Abstract contract for service task CRUD and due-date queries.
///
/// Implementations MUST:
///   - Seed tasks from OEM JSON on first run for each new vehicle.
///   - Update lastDoneKm and lastDoneDate when a maintenance
///     record matches a service task (by taskKey).
abstract class ServiceTaskRepository {
  /// Seeds the default service tasks for a newly registered vehicle.
  ///
  /// Tasks are loaded from assets/oem/tank_300_intervals.json.
  /// This method is idempotent — calling it multiple times for
  /// the same vehicle has no effect.
  ///
  /// Parameters:
  ///   [vehicleId] — The ID of the vehicle to seed tasks for.
  ///
  /// Returns:
  ///   true if tasks were successfully seeded.
  ///   false if the OEM JSON is missing or malformed.
  Future<bool> seedTasksForVehicle(int vehicleId);

  /// Retrieves all service tasks for a specific vehicle.
  ///
  /// Returns the complete task list regardless of due status.
  /// Order is preserved from the OEM JSON (priority order).
  ///
  /// Parameters:
  ///   [vehicleId] — The ID of the vehicle to query.
  ///
  /// Returns:
  ///   List of ServiceTask. Empty if vehicle has no seeded tasks.
  Future<List<ServiceTask>> getAllTasks(int vehicleId);

  /// Retrieves only the overdue service tasks for a vehicle.
  ///
  /// A task is considered overdue when:
  ///   - KM overdue: currentOdometer - lastDoneKm >= intervalKm
  ///   - Time overdue: now - lastDoneDate >= intervalMonths
  ///   - Never done and interval has passed since vehicle registration
  ///
  /// Parameters:
  ///   [vehicleId]          — The ID of the vehicle to query.
  ///   [currentOdometerKm]  — Vehicle's current odometer reading.
  ///
  /// Returns:
  ///   List of overdue ServiceTask. Empty if all tasks are current.
  Future<List<ServiceTask>> getOverdueTasks({
    required int vehicleId,
    required int currentOdometerKm,
  });

  /// Retrieves only the upcoming service tasks due within a threshold.
  ///
  /// A task is "upcoming" when it is not overdue, but will be due
  /// within the next [thresholdKm] kilometers or [thresholdMonths] months.
  ///
  /// If thresholdKm or thresholdMonths is null, that axis is not checked.
  ///
  /// Parameters:
  ///   [vehicleId]         — The ID of the vehicle to query.
  ///   [currentOdometerKm] — Vehicle's current odometer reading.
  ///   [thresholdKm]       — KM-based upcoming window (e.g. 5000).
  ///   [thresholdMonths]   — Time-based upcoming window (e.g. 3).
  ///
  /// Returns:
  ///   List of upcoming ServiceTask. Empty if none match.
  Future<List<ServiceTask>> getUpcomingTasks({
    required int vehicleId,
    required int currentOdometerKm,
    int? thresholdKm,
    int? thresholdMonths,
  });

  /// Marks a service task as completed by updating its last done values.
  ///
  /// This is typically called after a user logs a maintenance record
  /// that matches the task's taskKey.
  ///
  /// Parameters:
  ///   [vehicleId]     — The vehicle this task belongs to.
  ///   [taskKey]       — The task identifier (e.g. "oil_change").
  ///   [doneAtKm]      — Odometer reading at time of completion.
  ///   [doneAtDate]    — Date of completion (defaults to now if null).
  ///
  /// Returns:
  ///   true if the task was found and updated.
  ///   false if no task matches the vehicleId + taskKey.
  Future<bool> markTaskCompleted({
    required int vehicleId,
    required String taskKey,
    required int doneAtKm,
    DateTime? doneAtDate,
  });

  /// Updates a single service task with arbitrary field changes.
  ///
  /// Use this for bulk updates or corrections (e.g. admin overrides).
  ///
  /// Parameters:
  ///   [vehicleId]     — The vehicle this task belongs to.
  ///   [taskKey]       — The task identifier.
  ///   [taskUpdater]   — Function that receives the current task and
  ///                     returns a modified copy. The returned task
  ///                     will be saved via writeTxn.
  ///
  /// Returns:
  ///   true if the task was found and updated.
  ///   false if not found.
  Future<bool> updateTask({
    required int vehicleId,
    required String taskKey,
    required ServiceTask Function(ServiceTask task) taskUpdater,
  });

  /// Checks whether a specific task exists for a vehicle.
  ///
  /// Purpose: Guard against querying vehicles that have not been
  /// seeded with service tasks yet.
  ///
  /// Parameters:
  ///   [vehicleId] — The vehicle to check.
  ///   [taskKey]   — The task identifier.
  ///
  /// Returns:
  ///   true if the task exists for this vehicle.
  Future<bool> taskExists({
    required int vehicleId,
    required String taskKey,
  });

  /// Creates a new custom service task for a vehicle.
  Future<bool> createTask(ServiceTask task);

  /// Deletes a service task by taskKey.
  ///
  /// Parameters:
  ///   [vehicleId] — The vehicle this task belongs to.
  ///   [taskKey]   — The task identifier to delete.
  ///
  /// Returns:
  ///   true if the task was found and deleted.
  Future<bool> deleteTask({
    required int vehicleId,
    required String taskKey,
  });
}
