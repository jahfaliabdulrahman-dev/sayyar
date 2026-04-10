import 'package:isar/isar.dart';

part 'service_task.g.dart';

@collection
class ServiceTask {
  Id id = Isar.autoIncrement;

  @Index()
  late int vehicleId;

  @Index()
  late String taskKey;

  late String displayNameAr;
  late String displayNameEn;

  int? intervalKm;
  int? intervalMonths;

  int? lastDoneKm;
  DateTime? lastDoneDate;

  ServiceTask({
    this.id = Isar.autoIncrement,
    required this.vehicleId,
    required this.taskKey,
    required this.displayNameAr,
    required this.displayNameEn,
    this.intervalKm,
    this.intervalMonths,
    this.lastDoneKm,
    this.lastDoneDate,
  });
}
