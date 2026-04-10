import 'package:isar/isar.dart';

part 'part_price.g.dart';

/// Crowdsourced part price entry.
/// Silently collected from MaintenanceRecord breakdowns.
/// Z-Score analysis runs when N >= 30.
/// NOT exposed in Phase 1 UI.
@collection
class PartPrice {
  Id id = Isar.autoIncrement;

  /// Part name or OEM part number
  @Index()
  late String partName;

  /// Price paid (SAR) for this part
  late double priceSar;

  /// Provider/shop where part was purchased or installed
  String? providerName;

  /// City/region (for regional price variance)
  String? region;

  /// Odometer when part was installed
  int? installedAtKm;

  /// Date when price was recorded
  late DateTime recordedAt;

  /// Whether this has been uploaded to CDN for aggregation
  bool isSynced;

  /// Source: manual (user entered) or telemetry (silent log)
  @enumerated
  late PriceSource source;

  PartPrice({
    this.id = Isar.autoIncrement,
    required this.partName,
    required this.priceSar,
    this.providerName,
    this.region,
    this.installedAtKm,
    required this.recordedAt,
    this.isSynced = false,
    required this.source,
  });
}

/// Source of the price data
enum PriceSource {
  manual,
  telemetry,
}
