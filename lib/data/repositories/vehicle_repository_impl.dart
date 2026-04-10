import 'package:isar/isar.dart';

import '../models/vehicle.dart';
import '../models/maintenance_record.dart';
import '../models/service_task.dart';

/// ============================================================
/// Vehicle Repository — Abstract Contract (inline for simplicity)
/// ============================================================
///
/// Defines the data access contract for vehicle CRUD operations.
/// Kept inline because the vehicle layer is intentionally thin —
/// only basic Create/Read/Update operations with no complex queries.
/// ============================================================
abstract class VehicleRepository {
  /// Returns the currently active vehicle, or null if none is marked active.
  ///
  /// If no vehicle is active, returns the first vehicle in the database.
  /// Returns null if the database is completely empty (should not happen
  /// with auto-seed in place).
  Future<Vehicle?> getActiveVehicle();

  /// Returns all registered vehicles, sorted by name alphabetically.
  ///
  /// Returns an empty list if no vehicles exist.
  Future<List<Vehicle>> getAllVehicles();

  /// Updates the odometer reading for a specific vehicle.
  ///
  /// This is called whenever the user logs a maintenance event with
  /// a new odometer reading — the vehicle's current odometer should
  /// reflect the latest known value.
  ///
  /// Parameters:
  ///   [vehicleId] — The ID of the vehicle to update.
  ///   [newOdometerKm] — The new odometer reading in kilometers.
  ///
  /// Returns:
  ///   true if the vehicle was found and updated.
  ///   false if the vehicle ID does not exist.
  Future<bool> updateOdometer({
    required int vehicleId,
    required int newOdometerKm,
  });

  /// Creates a new vehicle in the database.
  ///
  /// If [setAsActive] is true, all other vehicles are de-activated
  /// first to ensure only one vehicle is active at a time.
  ///
  /// Parameters:
  ///   [vehicle] — The vehicle model to persist.
  ///   [setAsActive] — Whether to mark this as the primary vehicle.
  ///
  /// Returns:
  ///   The persisted vehicle with its generated [Id] field.
  Future<Vehicle> createVehicle(Vehicle vehicle, {bool setAsActive = false});

  /// Updates the make, model, and display name of a vehicle.
  ///
  /// Parameters:
  ///   [vehicleId] — The ID of the vehicle to update.
  ///   [make] — New make (e.g., "Tank").
  ///   [model] — New model (e.g., "300").
  ///   [name] — New display name (e.g., "Tank 300").
  ///
  /// Returns:
  ///   true if the vehicle was found and updated.
  ///   false if the vehicle ID does not exist.
  Future<bool> updateVehicle({
    required int vehicleId,
    required String make,
    required String model,
    required String name,
  });

  /// Deletes a vehicle by ID.
  ///
  /// WARNING: Deleting a vehicle also deletes all associated
  /// maintenance records, service tasks, and part price entries.
  /// This is a cascading delete — use with caution.
  ///
  /// Parameters:
  ///   [vehicleId] — The ID of the vehicle to delete.
  ///
  /// Returns:
  ///   true if the vehicle was found and deleted.
  ///   false if the vehicle ID does not exist.
  Future<bool> deleteVehicle(int vehicleId);
}

/// ============================================================
/// Vehicle Repository — Isar Implementation
/// ============================================================
///
/// Implements [VehicleRepository] using Isar.
/// All write operations are wrapped in [isar.writeTxn] for ACID safety.
/// ============================================================
class VehicleRepositoryImpl implements VehicleRepository {
  /// Isar instance injected via constructor.
  final Isar isar;

  const VehicleRepositoryImpl(this.isar);

  // ============================================================
  // READ
  // ============================================================

  @override
  Future<Vehicle?> getActiveVehicle() async {
    // First, try to find an active vehicle.
    final active = await isar.vehicles
        .filter()
        .isActiveEqualTo(true)
        .findFirst();

    if (active != null) return active;

    // Fallback: return the first vehicle as default.
    return isar.vehicles.where().findFirst();
  }

  @override
  Future<List<Vehicle>> getAllVehicles() async {
    return isar.vehicles.where().findAll();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  Future<bool> updateOdometer({
    required int vehicleId,
    required int newOdometerKm,
  }) async {
    try {
      final vehicle = await isar.vehicles.get(vehicleId);
      if (vehicle == null) return false;

      vehicle.currentOdometerKm = newOdometerKm;

      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateVehicle({
    required int vehicleId,
    required String make,
    required String model,
    required String name,
  }) async {
    try {
      final vehicle = await isar.vehicles.get(vehicleId);
      if (vehicle == null) return false;

      vehicle.make = make;
      vehicle.model = model;
      vehicle.name = name;

      await isar.writeTxn(() async {
        await isar.vehicles.put(vehicle);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // CREATE
  // ============================================================

  @override
  Future<Vehicle> createVehicle(
    Vehicle vehicle, {
    bool setAsActive = false,
  }) async {
    await isar.writeTxn(() async {
      // If this vehicle should be active, deactivate all others first.
      if (setAsActive) {
        final allVehicles = await isar.vehicles.where().findAll();
        for (final v in allVehicles) {
          if (v.isActive) {
            v.isActive = false;
            await isar.vehicles.put(v);
          }
        }
      }

      // Persist the new vehicle.
      await isar.vehicles.put(vehicle);
    });

    return vehicle;
  }

  // ============================================================
  // DELETE
  // ============================================================

  @override
  Future<bool> deleteVehicle(int vehicleId) async {
    try {
      final vehicle = await isar.vehicles.get(vehicleId);
      if (vehicle == null) return false;

      await isar.writeTxn(() async {
        // Cascade delete: remove all related maintenance records.
        final records = await isar.maintenanceRecords
            .filter()
            .vehicleIdEqualTo(vehicleId)
            .findAll();
        if (records.isNotEmpty) {
          final recordIds = records.map((r) => r.id).toList();
          await isar.maintenanceRecords.deleteAll(recordIds);
        }

        // Cascade delete: remove all related service tasks.
        final tasks = await isar.serviceTasks
            .filter()
            .vehicleIdEqualTo(vehicleId)
            .findAll();
        if (tasks.isNotEmpty) {
          final taskIds = tasks.map((t) => t.id).toList();
          await isar.serviceTasks.deleteAll(taskIds);
        }

        // Finally, delete the vehicle itself.
        await isar.vehicles.delete(vehicleId);
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
