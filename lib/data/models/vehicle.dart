import 'package:isar/isar.dart';

part 'vehicle.g.dart';

@collection
class Vehicle {
  Id id = Isar.autoIncrement;

  late String name;
  late String make;
  late String model;
  late int year;

  String? vin;
  late int currentOdometerKm;
  late DateTime addedAt;
  bool isActive;

  Vehicle({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    required this.currentOdometerKm,
    required this.addedAt,
    this.isActive = false,
  });

  factory Vehicle.defaultTank300() {
    return Vehicle(
      name: 'Tank 300',
      make: 'Tank',
      model: '300',
      year: DateTime.now().year,
      currentOdometerKm: 0,
      addedAt: DateTime.now(),
      isActive: true,
    );
  }
}
