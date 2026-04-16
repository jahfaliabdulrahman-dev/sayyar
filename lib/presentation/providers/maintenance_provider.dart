import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/isar_provider.dart';
import '../../data/models/maintenance_record.dart';
import '../../data/repositories/maintenance_repository_impl.dart';
import '../../data/repositories/service_task_repository_impl.dart';
import '../../data/services/ref_counted_invoice_service.dart';
import 'service_task_provider.dart';
import 'vehicle_provider.dart';

/// ============================================================
/// Maintenance Provider — AsyncNotifier
/// ============================================================
///
/// Manages the maintenance records for the active vehicle.
/// Handles:
///   - Loading all records on init.
///   - Adding, updating, and deleting records.
///   - Auto-refresh after each mutation to keep UI in sync.
///   - Filtering by service type and date range (future use).
/// ============================================================

/// Immutable snapshot of maintenance records for the UI.
class MaintenanceState {
  final List<MaintenanceRecord> records;
  final int totalRecords;
  final double totalSpending;

  const MaintenanceState({
    this.records = const [],
    this.totalRecords = 0,
    this.totalSpending = 0.0,
  });

  MaintenanceState copyWith({
    List<MaintenanceRecord>? records,
    int? totalRecords,
    double? totalSpending,
  }) {
    return MaintenanceState(
      records: records ?? this.records,
      totalRecords: totalRecords ?? this.totalRecords,
      totalSpending: totalSpending ?? this.totalSpending,
    );
  }
}

/// AsyncNotifier managing maintenance record state.
///
/// Usage in UI:
///   final maintenanceState = ref.watch(maintenanceProviderProvider);
///   maintenanceState.when(
///     data: (state) => ListView.builder(
///       itemCount: state.records.length,
///       itemBuilder: (context, index) => ListTile(
///         title: Text(state.records[index].serviceType),
///       ),
///     ),
///     loading: () => CircularProgressIndicator(),
///     error: (e, st) => Text('Error: $e'),
///   );
class MaintenanceNotifier extends AsyncNotifier<MaintenanceState> {
  MaintenanceRepositoryImpl get _repo => MaintenanceRepositoryImpl(
        ref.watch(isarProvider),
      );

  /// One-time migration: links old records without taskKeys to their tasks.
  ///
  /// Old records store only display names in partsReplaced. This method
  /// finds matching ServiceTask entries and populates the taskKeys field.
  /// Runs silently on each build — safe to call multiple times (idempotent).
  Future<void> _migrateOldRecords(int vehicleId) async {
    final records = await _repo.getRecordsByVehicle(vehicleId);

    // Get tasks via serviceTaskRepo.
    final taskRepo = ServiceTaskRepositoryImpl(ref.watch(isarProvider));
    final tasks = await taskRepo.getAllTasks(vehicleId);

    final toUpdate = <MaintenanceRecord>[];

    for (final record in records) {
      final taskKeys = record.taskKeys;
      if (taskKeys != null && taskKeys.isNotEmpty) continue;

      final parts = record.partsReplaced;
      if (parts == null || parts.isEmpty) continue;

      final matchedKeys = <String>[];
      for (final partName in parts) {
        final match = tasks.where((task) =>
            task.displayNameEn == partName ||
            task.displayNameAr == partName ||
            task.taskKey == partName);
        if (match.isNotEmpty) {
          matchedKeys.add(match.first.taskKey);
        }
      }

      if (matchedKeys.isNotEmpty) {
        record.taskKeys = matchedKeys;
        toUpdate.add(record);
      }
    }

    if (toUpdate.isNotEmpty) {
      final isar = ref.watch(isarProvider);
      await isar.writeTxn(() async {
        for (final r in toUpdate) {
          await isar.maintenanceRecords.put(r);
        }
      });
    }
  }

  @override
  Future<MaintenanceState> build() async {
    // We need the active vehicle's ID to load its records.
    final vehicleState = await ref.watch(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;

    if (vehicle == null) {
      return const MaintenanceState();
    }

    // Silent migration: link old records to taskKeys.
    await _migrateOldRecords(vehicle.id);

    final records = await _repo.getRecordsByVehicle(vehicle.id);
    final totalCount = await _repo.getRecordCount(vehicle.id);
    final totalSpending = await _repo.getTotalSpending(vehicle.id);

    return MaintenanceState(
      records: records,
      totalRecords: totalCount,
      totalSpending: totalSpending,
    );
  }

  /// Adds a new maintenance record to the database.
  ///
  /// After success, the state is automatically refreshed, including
  /// the updated record count and total spending. The silent telemetry
  /// extraction (PartPrice) runs inside the repository layer.
  ///
  /// Parameters:
  ///   [record] — The maintenance record to persist.
  ///
  /// Returns:
  ///   true if the record was saved successfully.
  Future<bool> addRecord(MaintenanceRecord record) async {
    final success = await _repo.addRecord(record);
    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }

  /// Updates an existing maintenance record.
  ///
  /// Parameters:
  ///   [record] — The updated record with a valid existing id.
  ///
  /// Returns:
  ///   true if the record was found and updated.
  Future<bool> updateRecord(MaintenanceRecord record) async {
    // Read old invoice ID BEFORE update for atomic cleanup
    final oldRecord = state.valueOrNull?.records.firstWhere(
      (r) => r.id == record.id,
      orElse: () => record,
    );
    final oldInvoiceImageId = oldRecord?.invoiceImageId;

    final success = await _repo.updateRecord(record);
    if (success) {
      // ATOMIC cleanup: detach old invoice ONLY after record update succeeds
      if (oldInvoiceImageId != null && oldInvoiceImageId != record.invoiceImageId) {
        final invoiceService = RefCountedInvoiceService(_repo.isar);
        await invoiceService.detachOrDelete(oldInvoiceImageId);
        debugPrint('[ATOMIC UPDATE] Old invoice detached: $oldInvoiceImageId');
      }

      // Targeted state update — no full invalidation
      updateRecordInState(record);
    }
    return success;
  }

  /// Update a single record in state without full provider invalidation.
  /// Use after a successful Isar write to keep UI in sync without flicker.
  void updateRecordInState(MaintenanceRecord updated) {
    final current = state.valueOrNull;
    if (current == null) return;

    final index = current.records.indexWhere((r) => r.id == updated.id);
    if (index == -1) return;

    final newRecords = List<MaintenanceRecord>.from(current.records);
    newRecords[index] = updated;

    state = AsyncData(MaintenanceState(
      records: newRecords,
      totalRecords: current.totalRecords,
      totalSpending: current.totalSpending,
    ));
  }

  /// Deletes a maintenance record by ID.
  ///
  /// NOTE: Any PartPrice entries created by telemetry are NOT reversed.
  /// Price data is append-only for statistical integrity.
  ///
  /// Parameters:
  ///   [recordId] — The ID of the record to delete.
  ///
  /// Returns:
  ///   true if the record was found and deleted.
  Future<bool> deleteRecord(int recordId) async {
    final success = await _repo.deleteRecord(recordId);
    if (success) {
      ref.invalidateSelf();
      // Force task page to recalculate drift from rolled-back state.
      ref.invalidate(serviceTaskProvider);
    }
    return success;
  }

  /// Manually refreshes the maintenance state.
  /// Useful after returning from another screen.
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// Riverpod provider for maintenance record state.
final maintenanceProvider =
    AsyncNotifierProvider<MaintenanceNotifier, MaintenanceState>(
  MaintenanceNotifier.new,
);
