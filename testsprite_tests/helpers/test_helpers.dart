// Test helpers for CarSah — In-Memory Isar setup
// Eliminates the need for real devices in unit/widget tests.
//
// Usage:
//   final isar = await openTestIsar();
//   // ... run tests ...
//   await isar.close(deleteFromDisk: true);

import 'dart:io';
import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:maintlogic/data/models/vehicle.dart';
import 'package:maintlogic/data/models/maintenance_record.dart';
import 'package:maintlogic/data/models/service_task.dart';
import 'package:maintlogic/data/models/part_price.dart';
import 'package:maintlogic/data/models/invoice_image.dart';
import 'package:maintlogic/data/datasources/local/isar_provider.dart';

/// Opens an Isar database in a temp directory for testing.
///
/// Each call gets a unique name to avoid collisions between parallel tests.
Future<Isar> openTestIsar() async {
  final name = 'test_${DateTime.now().microsecondsSinceEpoch}';

  // Use system temp directory for test isolation
  final dir = await Directory.systemTemp.createTemp('isar_test_');

  return Isar.open(
    [
      VehicleSchema,
      MaintenanceRecordSchema,
      ServiceTaskSchema,
      PartPriceSchema,
      InvoiceImageSchema,
    ],
    directory: dir.path,
    name: name,
  );
}

/// Creates a ProviderScope override list with an in-memory Isar.
Future<List<Override>> createTestOverrides() async {
  final isar = await openTestIsar();
  return [isarProvider.overrideWithValue(isar)];
}

/// Creates a minimal test Vehicle with sensible defaults.
Vehicle createTestVehicle({
  String name = 'Test Tank 300',
  String make = 'Tank',
  String model = '300',
  int year = 2024,
  int odometer = 15000,
  bool isActive = true,
}) {
  return Vehicle(
    name: name,
    make: make,
    model: model,
    year: year,
    currentOdometerKm: odometer,
    addedAt: DateTime.now(),
    isActive: isActive,
  );
}

/// Creates a minimal test ServiceTask with sensible defaults.
ServiceTask createTestTask({
  int vehicleId = 1,
  String taskKey = 'oil_change',
  String nameEn = 'Oil Change',
  String nameAr = 'تغيير الزيت',
  int? intervalKm = 7500,
  int? intervalMonths = 6,
  int? lastDoneKm,
  DateTime? lastDoneDate,
}) {
  final task = ServiceTask(
    vehicleId: vehicleId,
    taskKey: taskKey,
    displayNameAr: nameAr,
    displayNameEn: nameEn,
    intervalKm: intervalKm,
    intervalMonths: intervalMonths,
  );
  if (lastDoneKm != null) task.lastDoneKm = lastDoneKm;
  if (lastDoneDate != null) task.lastDoneDate = lastDoneDate;
  return task;
}

/// Creates a minimal test MaintenanceRecord with sensible defaults.
MaintenanceRecord createTestRecord({
  int vehicleId = 1,
  String serviceType = 'Oil Change',
  int odometer = 20000,
  double totalCost = 150.0,
  double partsCost = 100.0,
  double laborCost = 50.0,
  DateTime? serviceDate,
  List<String>? taskKeys,
  List<String>? partsReplaced,
}) {
  return MaintenanceRecord(
    vehicleId: vehicleId,
    serviceType: serviceType,
    odometerKm: odometer,
    totalCostSar: totalCost,
    partsCostSar: partsCost,
    laborCostSar: laborCost,
    serviceDate: serviceDate ?? DateTime.now(),
    createdAt: DateTime.now(),
    taskKeys: taskKeys,
    partsReplaced: partsReplaced,
  );
}
