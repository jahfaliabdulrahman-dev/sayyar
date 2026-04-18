import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/vehicle.dart';
import '../../models/maintenance_record.dart';
import '../../models/service_task.dart';
import '../../models/part_price.dart';
import '../../models/invoice_image.dart';
import '../../services/ref_counted_invoice_service.dart';

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
        InvoiceImageSchema,
      ],
      directory: directory.path,
      name: kDatabaseName,
    );
  }

  // Auto-seed DISABLED — WelcomePage handles first-run vehicle creation.
  // await _seedDefaultVehicle(isar);

  // GC: Clean up any soft-deleted invoice images from previous sessions
  try {
    final invoiceService = RefCountedInvoiceService(isar);
    final cleaned = await invoiceService.runGarbageCollection();
    if (cleaned > 0) {
      debugPrint('[GC] Startup cleanup: $cleaned entries removed');
    }
  } catch (e) {
    debugPrint('[GC] Startup cleanup failed (non-blocking): $e');
  }

  return isar;
}
