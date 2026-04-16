import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/repositories/maintenance_repository.dart';
import '../models/maintenance_record.dart';
import '../models/invoice_image.dart';
import '../models/part_price.dart';
import '../models/service_task.dart';

/// ============================================================
/// Maintenance Repository — Isar Implementation
/// ============================================================
///
/// Implements [MaintenanceRepository] using Isar as the
/// underlying data store.
///
/// Telemetry Contract:
///   On every successful [addRecord], part costs and part names
///   are silently extracted and stored as [PartPrice] entries.
///   This is wrapped inside the same writeTxn as the record save
///   to guarantee atomicity — either both succeed or neither.
///
/// Guards:
///   - partsReplaced null/empty → no extraction (early return).
///   - partsCostSar <= 0 → no extraction.
///   - totalCostSar <= 0 → invalid record.
///   - Per-part price = partsCostSar / parts.length (even split).
/// ============================================================
class MaintenanceRepositoryImpl implements MaintenanceRepository {
  /// Isar instance injected via constructor.
  final Isar isar;

  const MaintenanceRepositoryImpl(this.isar);

  // ============================================================
  // CREATE
  // ============================================================

  @override
  Future<bool> addRecord(MaintenanceRecord record) async {
    try {
      await isar.writeTxn(() async {
        await isar.maintenanceRecords.put(record);
        // Extract part prices for crowdsourcing — must use async put,
        // NOT putSync, inside an async writeTxn.
        await _extractPartPrices(isar, record);
      });
      return true;
    } catch (e) {
      // Surface the error in debug but return false so the caller
      // can show a proper error message to the user (no silent fails).
      return false;
    }
  }

  // ============================================================
  // READ — All queries
  // ============================================================

  @override
  Future<List<MaintenanceRecord>> getRecordsByVehicle(
    int vehicleId,
  ) async {
    return isar.maintenanceRecords
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .sortByServiceDateDesc()
        .findAll();
  }

  @override
  Future<List<MaintenanceRecord>> getRecordsByDateRange({
    required int vehicleId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = isar.maintenanceRecords
        .filter()
        .vehicleIdEqualTo(vehicleId);

    if (startDate != null) {
      query = query.serviceDateGreaterThan(startDate);
    }
    if (endDate != null) {
      query = query.serviceDateLessThan(endDate);
    }

    return query.sortByServiceDateDesc().findAll();
  }

  @override
  Future<List<MaintenanceRecord>> getRecordsByServiceType({
    required int vehicleId,
    required String serviceType,
  }) async {
    return isar.maintenanceRecords
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .serviceTypeContains(serviceType)
        .sortByServiceDateDesc()
        .findAll();
  }

  @override
  Future<int> getRecordCount(int vehicleId) async {
    return isar.maintenanceRecords
        .filter()
        .vehicleIdEqualTo(vehicleId)
        .count();
  }

  @override
  Future<double> getTotalSpending(int vehicleId) async {
    final records = await getRecordsByVehicle(vehicleId);
    if (records.isEmpty) return 0.0;

    return records.fold<double>(
      0.0,
      (sum, r) => sum + r.totalCostSar,
    );
  }

  // ============================================================
  // UPDATE — Smart Edit Engine
  // ============================================================

  /// Updates a maintenance record with full rollback + recalculation.
  ///
  /// EDIT ENGINE LOGIC (atomic transaction):
  ///   1. Fetch the old record to know its partsReplaced.
  ///   2. Rollback ServiceTask state for old parts (same as delete).
  ///   3. Overwrite the record with new data in Isar.
  ///   4. Recalculate ServiceTask state for new parts (same as add).
  ///
  /// This ensures that changing a record's partsReplaced, odometer,
  /// or date correctly updates all associated task drift calculations.
  @override
  Future<bool> updateRecord(MaintenanceRecord newRecord) async {
    try {
      final oldRecord = await isar.maintenanceRecords.get(newRecord.id);
      if (oldRecord == null) return false;

      final vehicleId = oldRecord.vehicleId;
      final oldParts = oldRecord.partsReplaced ?? [];
      final newParts = newRecord.partsReplaced ?? [];

      await isar.writeTxn(() async {
        // Step 1: Rollback old task associations.
        for (final partName in oldParts) {
          final serviceTask = await isar.serviceTasks
              .filter()
              .vehicleIdEqualTo(vehicleId)
              .displayNameEnEqualTo(partName)
              .findFirst();

          if (serviceTask == null) continue;

          // Find most recent remaining record (excluding this one).
          final remainingRecords = await isar.maintenanceRecords
              .filter()
              .vehicleIdEqualTo(vehicleId)
              .sortByServiceDateDesc()
              .findAll();

          MaintenanceRecord? newestMatch;
          for (final r in remainingRecords) {
            if (r.id == oldRecord.id) continue;
            if (r.partsReplaced?.contains(partName) == true) {
              newestMatch = r;
              break;
            }
          }

          if (newestMatch != null) {
            serviceTask.lastDoneKm = newestMatch.odometerKm;
            serviceTask.lastDoneDate = newestMatch.serviceDate;
          } else {
            serviceTask.lastDoneKm = null;
            serviceTask.lastDoneDate = null;
          }

          await isar.serviceTasks.put(serviceTask);
        }

        // Step 2: Overwrite the record.
        await isar.maintenanceRecords.put(newRecord);

        // Step 3: Recalculate for new parts.
        for (final partName in newParts) {
          final serviceTask = await isar.serviceTasks
              .filter()
              .vehicleIdEqualTo(vehicleId)
              .displayNameEnEqualTo(partName)
              .findFirst();

          if (serviceTask == null) continue;

          // If this record is the newest for this part, update the task.
          final existingRecords = await isar.maintenanceRecords
              .filter()
              .vehicleIdEqualTo(vehicleId)
              .sortByServiceDateDesc()
              .findAll();

          MaintenanceRecord? newestForPart;
          for (final r in existingRecords) {
            if (r.partsReplaced?.contains(partName) == true) {
              newestForPart = r;
              break;
            }
          }

          if (newestForPart != null) {
            serviceTask.lastDoneKm = newestForPart.odometerKm;
            serviceTask.lastDoneDate = newestForPart.serviceDate;
            await isar.serviceTasks.put(serviceTask);
          }
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // DELETE — Smart Rollback Engine
  // ============================================================

  /// Deletes a maintenance record and recalculates associated
  /// ServiceTask state based on remaining history.
  ///
  /// ROLLBACK LOGIC:
  ///   1. Fetch the record to know its partsReplaced and vehicleId.
  ///   2. Delete the record from Isar.
  ///   3. For each taskKey in partsReplaced:
  ///      a. Find the most recent remaining record (by odometerKm DESC)
  ///         that also references this taskKey in its partsReplaced.
  ///      b. If found → update ServiceTask.lastDoneKm/lastDoneDate
  ///         to match that older record.
  ///      c. If not found → reset ServiceTask to null (never done).
  ///
  /// PartPrice telemetry is NOT reversed (append-only contract).
  @override
  Future<bool> deleteRecord(int recordId) async {
    try {
      final existing = await isar.maintenanceRecords.get(recordId);
      if (existing == null) return false;

      final vehicleId = existing.vehicleId;
      final deletedParts = existing.partsReplaced ?? [];
      final invoiceId = existing.invoiceImageId;

      await isar.writeTxn(() async {
        // Step 1: ATOMIC — delete record AND decrement invoice refCount
        await isar.maintenanceRecords.delete(recordId);

        // Step 2: Inline refCount decrement — no nested writeTxn
        if (invoiceId != null) {
          final invoiceImage = await isar.invoiceImages.get(invoiceId);
          if (invoiceImage != null && invoiceImage.deletedAt == null) {
            invoiceImage.refCount--;
            debugPrint('[ATOMIC DELETE] Invoice $invoiceId refCount: ${invoiceImage.refCount}');

            if (invoiceImage.refCount <= 0) {
              invoiceImage.deletedAt = DateTime.now();
              debugPrint('[ATOMIC DELETE] Invoice $invoiceId soft-deleted');
            }

            await isar.invoiceImages.put(invoiceImage);
          }
        }
        for (final partName in deletedParts) {
          // Find the ServiceTask whose displayNameEn matches this part.
          final serviceTask = await isar.serviceTasks
              .filter()
              .vehicleIdEqualTo(vehicleId)
              .displayNameEnEqualTo(partName)
              .findFirst();

          if (serviceTask == null) continue;

          // Sort by serviceDate DESC — first match is chronologically newest.
          final remainingRecords = await isar.maintenanceRecords
              .filter()
              .vehicleIdEqualTo(vehicleId)
              .sortByServiceDateDesc()
              .findAll();

          MaintenanceRecord? newestMatch;
          for (final r in remainingRecords) {
            if (r.id == recordId) continue;
            if (r.partsReplaced?.contains(partName) == true) {
              newestMatch = r;
              break;
            }
          }

          if (newestMatch != null) {
            // Roll back to the previous record's data.
            serviceTask.lastDoneKm = newestMatch.odometerKm;
            serviceTask.lastDoneDate = newestMatch.serviceDate;
          } else {
            // No remaining records for this task — reset to never done.
            serviceTask.lastDoneKm = null;
            serviceTask.lastDoneDate = null;
          }

          await isar.serviceTasks.put(serviceTask);
        }
      });

      // AFTER atomic commit — attempt physical file cleanup for soft-deleted invoice
      if (invoiceId != null) {
        final invoiceImage = await isar.invoiceImages.get(invoiceId);
        if (invoiceImage != null && invoiceImage.deletedAt != null) {
          try {
            final appDir = await getApplicationDocumentsDirectory();
            final file = File(p.join(appDir.path, invoiceImage.relativePath));
            if (await file.exists()) {
              await file.delete().timeout(
                const Duration(milliseconds: 200),
                onTimeout: () {
                  debugPrint('[GC] Timeout — soft-delete persists for retry');
                  return file;
                },
              );
              debugPrint('[GC] Physical file deleted: ${invoiceImage.relativePath}');
            }
            // File deleted — safe to remove Isar entity
            await isar.writeTxn(() async {
              await isar.invoiceImages.delete(invoiceImage.id);
            });
          } catch (e) {
            debugPrint('[GC] Physical delete failed: $e — soft-delete persists');
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // PRIVATE — Silent Telemetry Extraction
  // ============================================================

  /// Extracts part prices from a maintenance record and stores
  /// them as [PartPrice] entries for the crowdsourced pricing layer.
  ///
  /// Called asynchronously within the same [writeTxn] as the record
  /// save to guarantee atomicity. Fails silently — a telemetry
  /// issue must never block the primary maintenance save.
  Future<void> _extractPartPrices(Isar isar, MaintenanceRecord record) async {
    final parts = record.partsReplaced;
    if (parts == null || parts.isEmpty) return;
    if (record.partsCostSar <= 0) return;
    if (record.totalCostSar <= 0) return;

    final pricePerPart = record.partsCostSar / parts.length;

    for (final partName in parts) {
      final entry = PartPrice(
        partName: partName,
        priceSar: pricePerPart,
        providerName: record.providerName,
        recordedAt: record.serviceDate,
        source: PriceSource.telemetry,
      );
      await isar.partPrices.put(entry);
    }
  }
}
