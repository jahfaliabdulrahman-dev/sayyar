import 'package:isar/isar.dart';

part 'maintenance_record.g.dart';

@collection
class MaintenanceRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late int vehicleId;

  late String serviceType;
  String? notes;
  late int odometerKm;
  late double totalCostSar;

  double partsCostSar;
  double laborCostSar;
  List<String>? partsReplaced;
  List<String>? taskKeys;
  String? providerName;
  String? invoiceImagePath;

  late DateTime serviceDate;
  late DateTime createdAt;

  bool isSynced;

  MaintenanceRecord({
    this.id = Isar.autoIncrement,
    required this.vehicleId,
    required this.serviceType,
    this.notes,
    required this.odometerKm,
    required this.totalCostSar,
    this.partsCostSar = 0.0,
    this.laborCostSar = 0.0,
    this.partsReplaced,
    this.taskKeys,
    this.providerName,
    this.invoiceImagePath,
    required this.serviceDate,
    required this.createdAt,
    this.isSynced = false,
  });
}
