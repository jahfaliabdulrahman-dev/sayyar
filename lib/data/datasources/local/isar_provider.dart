import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/vehicle.dart';
import '../../models/maintenance_record.dart';
import '../../models/service_task.dart';
import '../../models/part_price.dart';

/// ============================================================
/// Isar Database Provider — Phase 1
/// ============================================================
///
/// Purpose:
///   Centralizes Isar database initialization and provides a
///   singleton instance to the application via Standard Riverpod.
///
/// Architecture Decisions:
///   1. Uses Isar.getInstance() to prevent double-opening the database
///      during hot reloads or hot restarts.
///   2. Throws immediately if accessed without prior initialization,
///      enforcing fail-fast behavior over silent degradation.
///   3. Auto-seeds a default Tank 300 vehicle on first launch to
///      eliminate friction for new users.
///   4. All four Isar schemas are registered in a single open() call.
/// ============================================================

/// The unique database identifier. Must remain stable across releases
/// to prevent data loss or orphaned database files on disk.
const kDatabaseName = 'maintlogic_db';

/// Riverpod Provider exposing the initialized Isar database instance.
///
/// Consumers should access this provider via:
///   final isar = ref.watch(isarProvider);
///
/// The provider expects the database to be initialized in main() and
/// injected via ProviderScope(overrides: [...]). If accessed without
/// an override, it throws a [StateError] to surface the misconfiguration.
final isarProvider = Provider<Isar>((ref) {
  // Check if an instance is already open (e.g., during hot reload).
  final existing = Isar.getInstance(kDatabaseName);
  if (existing != null) {
    return existing;
  }

  // If we reach here, the database was never initialized before runApp().
  throw StateError(
    'Isar database not initialized on app startup. '
    'Call initIsarDatabase() before runApp() and pass the result '
    'to ProviderScope(overrides: [isarProvider.overrideWithValue(isar)]).',
  );
});

/// ============================================================
/// Database Initialization
/// ============================================================
///
/// Call this function ONCE during app launch, before runApp().
/// Opens (or creates) the Isar database and applies default seeding.
/// ============================================================

/// Initializes the Isar database and returns the open instance.
///
/// This function is designed to be idempotent — calling it multiple
/// times safely returns the existing instance rather than creating
/// duplicates or throwing errors.
///
/// Returns:
///   A fully initialized [Isar] instance ready for read/write transactions.
Future<Isar> initIsarDatabase() async {
  final directory = await getApplicationDocumentsDirectory();

  Isar isar;

  // Attempt to reuse an existing open instance (safe-guard against double-init).
  final existing = Isar.getInstance(kDatabaseName);
  if (existing != null) {
    isar = existing;
  } else {
    // Cold start: open a new database with all registered collections.
    isar = await Isar.open(
      [
        VehicleSchema,
        MaintenanceRecordSchema,
        ServiceTaskSchema,
        PartPriceSchema,
      ],
      directory: directory.path,
      name: kDatabaseName,
    );
  }

  // Seed default data if this is a fresh installation.
  await _seedDefaultVehicle(isar);

  return isar;
}

/// Creates a default Tank 300 vehicle record if the database is empty.
///
/// This ensures the app is immediately functional after first launch,
/// without forcing the user through an onboarding flow just to log
/// their first maintenance event.
///
/// Parameters:
///   [isar] — The open Isar database instance.
Future<void> _seedDefaultVehicle(Isar isar) async {
  final count = await isar.vehicles.count();
  if (count == 0) {
    final defaultVehicle = Vehicle(
      name: 'Tank 300',
      make: 'Tank',
      model: '300',
      year: DateTime.now().year,
      currentOdometerKm: 0,
      addedAt: DateTime.now(),
      isActive: true,
    );
    await isar.writeTxn(() async {
      await isar.vehicles.put(defaultVehicle);
    });
  }
}
