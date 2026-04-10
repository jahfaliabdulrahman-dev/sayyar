import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/isar_provider.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../data/models/vehicle.dart';

/// ============================================================
/// Vehicle Provider — AsyncNotifier
/// ============================================================
///
/// Manages the active vehicle state. Handles:
///   - Loading the active vehicle on init.
///   - Updating the odometer reading.
///   - Switching between vehicles.
///
/// No code-gen: uses standard Riverpod AsyncNotifier pattern.
/// ============================================================

/// Immutable snapshot of vehicle-related UI state.
class VehicleState {
  final Vehicle? activeVehicle;
  final List<Vehicle> allVehicles;

  const VehicleState({
    this.activeVehicle,
    this.allVehicles = const [],
  });

  /// Returns a copy with the specified fields replaced.
  VehicleState copyWith({
    Vehicle? activeVehicle,
    List<Vehicle>? allVehicles,
  }) {
    return VehicleState(
      activeVehicle: activeVehicle ?? this.activeVehicle,
      allVehicles: allVehicles ?? this.allVehicles,
    );
  }
}

/// AsyncNotifier that manages vehicle state.
///
/// Usage in UI:
/// final vehicleState = ref.watch(vehicleProviderProvider);
/// vehicleState.when(
///   data: (state) => Text(state.activeVehicle?.name ?? 'No vehicle'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => Text('Error: $e'),
/// );
class VehicleNotifier extends AsyncNotifier<VehicleState> {
  VehicleRepositoryImpl get _repo => VehicleRepositoryImpl(
        ref.watch(isarProvider),
      );

  @override
  Future<VehicleState> build() async {
    final active = await _repo.getActiveVehicle();
    final all = await _repo.getAllVehicles();
    return VehicleState(activeVehicle: active, allVehicles: all);
  }

  /// Updates the odometer for the active vehicle.
  ///
  /// After success, the entire state is refreshed to reflect the
  /// updated odometer in all consumers.
  Future<void> updateOdometer(int newOdometerKm) async {
    final current = await future;
    final vehicle = current.activeVehicle;
    if (vehicle == null) return;

    final success = await _repo.updateOdometer(
      vehicleId: vehicle.id,
      newOdometerKm: newOdometerKm,
    );

    if (success) {
      ref.invalidateSelf();
    }
  }

  /// Updates the make, model, and display name of a vehicle.
  Future<void> updateVehicle({
    required int vehicleId,
    required String make,
    required String model,
    required String name,
  }) async {
    final success = await _repo.updateVehicle(
      vehicleId: vehicleId,
      make: make,
      model: model,
      name: name,
    );

    if (success) {
      ref.invalidateSelf();
    }
  }
}

/// Riverpod provider that exposes VehicleState asynchronously.
final vehicleProvider = AsyncNotifierProvider<VehicleNotifier, VehicleState>(
  VehicleNotifier.new,
);
