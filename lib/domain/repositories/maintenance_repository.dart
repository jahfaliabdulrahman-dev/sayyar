/// ============================================================
/// Maintenance Repository — Contract
/// ============================================================
///
/// Defines the data access contract for maintenance operations.
/// Implementations handle Isar queries, write transactions, and
/// silent telemetry extraction (PartPrice logging).
///
/// This interface is designed to be injected into repositories
/// and AsyncNotifiers without coupling to any specific database.
/// ============================================================

import '../../data/models/maintenance_record.dart';

/// Abstract contract for maintenance record CRUD operations.
///
/// Every method operates within the context of a specific vehicle.
/// Implementations MUST ensure:
///   - All writes go through isar.writeTxn for ACID safety.
///   - Silent PartPrice extraction on every successful save.
///   - Null-safe returns (empty lists, never null references).
abstract class MaintenanceRepository {
  /// Adds a new maintenance record to the database.
  ///
  /// On success, silently extracts parts cost and part names
  /// from the record and creates corresponding PartPrice entries
  /// for future crowdsourced pricing analysis (N >= 30 threshold).
  ///
  /// Parameters:
  ///   [record] — The maintenance record to persist.
  ///              Must have a valid vehicleId that exists.
  ///
  /// Returns:
  ///   true if the record was saved and telemetry extracted.
  ///   false if the vehicleId does not exist or the record is malformed.
  Future<bool> addRecord(MaintenanceRecord record);

  /// Retrieves all maintenance records for a specific vehicle.
  ///
  /// Results are ordered by serviceDate descending (most recent first).
  ///
  /// Parameters:
  ///   [vehicleId] — The ID of the vehicle to query.
  ///
  /// Returns:
  ///   List of MaintenanceRecord sorted by date (newest first).
  ///   Empty list if no records exist or vehicleId is invalid.
  Future<List<MaintenanceRecord>> getRecordsByVehicle(int vehicleId);

  /// Retrieves maintenance records within a specific date range.
  ///
  /// Both bounds are inclusive. If [startDate] is null, there is
  /// no lower bound. If [endDate] is null, there is no upper bound.
  ///
  /// Parameters:
  ///   [vehicleId]  — The ID of the vehicle to query.
  ///   [startDate]  — Lower bound (inclusive). Null = unbounded.
  ///   [endDate]    — Upper bound (inclusive). Null = unbounded.
  ///
  /// Returns:
  ///   List of MaintenanceRecord within the date window,
  ///   sorted by serviceDate descending.
  Future<List<MaintenanceRecord>> getRecordsByDateRange({
    required int vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Retrieves maintenance records filtered by service type.
  ///
  /// Case-insensitive exact match against the serviceType field.
  ///
  /// Parameters:
  ///   [vehicleId]   — The ID of the vehicle to query.
  ///   [serviceType] — Service type string (e.g. "Oil Change").
  ///
  /// Returns:
  ///   List of matching MaintenanceRecord, sorted by date descending.
  ///   Empty list if no matches found.
  Future<List<MaintenanceRecord>> getRecordsByServiceType({
    required int vehicleId,
    required String serviceType,
  });

  /// Updates an existing maintenance record by ID.
  ///
  /// Replaces the entire record with the provided one.
  /// The record's id field must match an existing entry.
  ///
  /// Parameters:
  ///   [record] — The updated record with a valid existing id.
  ///
  /// Returns:
  ///   true if the record was found and updated.
  ///   false if the record id does not exist.
  Future<bool> updateRecord(MaintenanceRecord record);

  /// Deletes a maintenance record by ID.
  ///
  /// NOTE: Deleting a record does NOT reverse any PartPrice entries
  /// that were created via silent telemetry. Price data is append-only.
  ///
  /// Parameters:
  ///   [recordId] — The ID of the record to delete.
  ///
  /// Returns:
  ///   true if the record was found and deleted.
  ///   false if the record id does not exist.
  Future<bool> deleteRecord(int recordId);

  /// Returns the total count of maintenance records for a vehicle.
  ///
  /// Purpose: Quick metric for the dashboard (e.g. "X services logged").
  ///
  /// Parameters:
  ///   [vehicleId] — The ID of the vehicle to query.
  ///
  /// Returns:
  ///   Integer count. Zero if no records exist.
  Future<int> getRecordCount(int vehicleId);

  /// Returns the total spending on a vehicle across all records.
  ///
  /// Parameters:
  ///   [vehicleId] — The ID of the vehicle to query.
  ///
  /// Returns:
  ///   Sum of totalCostSar across all records. 0.0 if none exist.
  Future<double> getTotalSpending(int vehicleId);
}
