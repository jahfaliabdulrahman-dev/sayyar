/// OEM maintenance interval defaults for Tank 300 (2.0L Turbo).
/// Source of truth: assets/oem/tank_300_intervals.json (GitHub Gist CDN).
/// These constants are fallbacks when CDN is offline.

abstract final class OilChange {
  static const maintenanceIntervalKm = 5000;
  static const maintenanceIntervalMonths = 6;
  static const displayNameEn = 'Oil Change';
  static const displayNameAr = 'تغيير الزيت';
}

abstract final class OilFilter {
  static const maintenanceIntervalKm = 5000;
  static const maintenanceIntervalMonths = 6;
  static const displayNameEn = 'Oil Filter';
  static const displayNameAr = 'فلتر الزيت';
}

abstract final class EngineAirFilter {
  static const maintenanceIntervalKm = 10000;
  static const maintenanceIntervalMonths = 12;
  static const displayNameEn = 'Engine Air Filter';
  static const displayNameAr = 'فلتر هواء المحرك';
}

abstract final class CabinAirFilter {
  static const maintenanceIntervalKm = 10000;
  static const maintenanceIntervalMonths = 12;
  static const displayNameEn = 'Cabin Air Filter';
  static const displayNameAr = 'فلتر هواء المقصورة';
}

abstract final class BrakeFluid {
  static const maintenanceIntervalKm = 20000;
  static const maintenanceIntervalMonths = 24;
  static const displayNameEn = 'Brake Fluid';
  static const displayNameAr = 'سائل الفرامل';
}

abstract final class Coolant {
  static const maintenanceIntervalKm = 40000;
  static const maintenanceIntervalMonths = 24;
  static const displayNameEn = 'Coolant';
  static const displayNameAr = 'سائل التبريد';
}

abstract final class SparkPlugs {
  static const maintenanceIntervalKm = 40000;
  static const maintenanceIntervalMonths = 24;
  static const displayNameEn = 'Spark Plugs';
  static const displayNameAr = 'البواجي';
}

abstract final class TransmissionFluid {
  static const maintenanceIntervalKm = 60000;
  static const maintenanceIntervalMonths = 48;
  static const displayNameEn = 'Transmission Fluid';
  static const displayNameAr = 'زيت القير';
}

abstract final class BrakePadsFront {
  static const maintenanceIntervalKm = 30000;
  static const maintenanceIntervalMonths = 24;
  static const displayNameEn = 'Front Brake Pads';
  static const displayNameAr = 'تيل فرامل أمامي';
}

abstract final class BrakePadsRear {
  static const maintenanceIntervalKm = 30000;
  static const maintenanceIntervalMonths = 24;
  static const displayNameEn = 'Rear Brake Pads';
  static const displayNameAr = 'تيل فرامل خلفي';
}

abstract final class TireRotation {
  static const maintenanceIntervalKm = 10000;
  static const maintenanceIntervalMonths = 6;
  static const displayNameEn = 'Tire Rotation';
  static const displayNameAr = 'تبديل الإطارات';
}

abstract final class FuelFilter {
  static const maintenanceIntervalKm = 20000;
  static const maintenanceIntervalMonths = 12;
  static const displayNameEn = 'Fuel Filter';
  static const displayNameAr = 'فلتر الوقود';
}
