import 'dart:collection';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/z_score_calculator.dart';
import '../../data/models/maintenance_record.dart';
import 'maintenance_provider.dart';

/// ============================================================
/// Reporting Provider — AsyncNotifier
/// ============================================================
///
/// Consumes maintenanceProvider records and produces:
///   1. Monthly cost aggregation as List<FlSpot> for charting.
///   2. Outlier detection via Z-Score on monthly totals.
///   3. Human-readable month labels for the X-axis.
///
/// ARCHITECTURE DECISION:
///   Isar does not support SQL-style GROUP BY. All monthly
///   aggregation is performed in-memory inside this provider
///   after fetching the full record list from MaintenanceState.
///
/// Z-SCORE OUTLIER LOGIC:
///   After computing monthly totals, we run ZScoreCalculator
///   on the full list. Any month whose total cost has
///   |Z| > 2.0 is flagged as an outlier and marked visually
///   on the chart with a red dot.
/// ============================================================

/// Monthly cost data point with metadata for outlier display.
class MonthlyCost {
  final DateTime month; // First day of the month (key).
  final double totalCost; // Sum of all records in that month.
  final int recordCount; // Number of records in that month.
  final bool isOutlier; // Z-Score flagged.

  const MonthlyCost({
    required this.month,
    required this.totalCost,
    required this.recordCount,
    this.isOutlier = false,
  });
}

/// Immutable snapshot of reporting state for the UI.
class ReportingState {
  final List<MonthlyCost> monthlyCosts;
  final List<FlSpot> chartSpots; // For fl_chart LineChart.
  final List<String> monthLabels; // X-axis labels (Jan, Feb...).
  final List<int> outlierIndices; // Indices into chartSpots that are outliers.
  final double maxCost; // Y-axis ceiling.
  final int totalMonths; // Number of months with data.

  const ReportingState({
    this.monthlyCosts = const [],
    this.chartSpots = const [],
    this.monthLabels = const [],
    this.outlierIndices = const [],
    this.maxCost = 0,
    this.totalMonths = 0,
  });
}

/// AsyncNotifier that aggregates maintenance records into
/// chart-ready monthly data with outlier detection.
class ReportingNotifier extends AsyncNotifier<ReportingState> {
  @override
  Future<ReportingState> build() async {
    final maintenanceAsync = ref.watch(maintenanceProvider);
    final records = maintenanceAsync.valueOrNull?.records ?? [];

    if (records.isEmpty) {
      return const ReportingState();
    }

    return _aggregateAndAnalyze(records);
  }

  /// Core pipeline: records → monthly aggregation → Z-Score → chart data.
  ///
  /// Steps:
  ///   1. Group records by year-month key (YYYY-MM).
  ///   2. Sum totalCostSar per month.
  ///   3. Sort chronologically.
  ///   4. Run Z-Score on monthly totals to find outliers.
  ///   5. Convert to FlSpot list for fl_chart.
  ///   6. Generate human-readable month labels.
  ReportingState _aggregateAndAnalyze(List<MaintenanceRecord> records) {
    // Step 1-2: Group and sum by month.
    final monthlyMap = SplayTreeMap<String, _MonthAccumulator>();

    for (final record in records) {
      final key =
          '${record.serviceDate.year}-${record.serviceDate.month.toString().padLeft(2, '0')}';
      final accumulator = monthlyMap.putIfAbsent(
        key,
        () => _MonthAccumulator(
          DateTime(record.serviceDate.year, record.serviceDate.month),
        ),
      );
      accumulator.totalCost += record.totalCostSar;
      accumulator.count++;
    }

    if (monthlyMap.isEmpty) {
      return const ReportingState();
    }

    // Step 3: Build sorted monthly list.
    final monthlyCosts = <MonthlyCost>[];
    for (final entry in monthlyMap.entries) {
      monthlyCosts.add(MonthlyCost(
        month: entry.value.month,
        totalCost: entry.value.totalCost,
        recordCount: entry.value.count,
      ));
    }

    // Step 4: Z-Score outlier detection on monthly totals.
    final totals = monthlyCosts.map((m) => m.totalCost).toList();
    final stats = ZScoreCalculator.computeMeanStd(totals);

    final outlierIndices = <int>[];
    final analyzedCosts = <MonthlyCost>[];

    if (stats != null) {
      final (mean, std) = stats;
      for (int i = 0; i < monthlyCosts.length; i++) {
        final z = ZScoreCalculator.zScore(monthlyCosts[i].totalCost, mean, std);
        final isOutlier = std > 0 && z.abs() > 2.0;
        analyzedCosts.add(MonthlyCost(
          month: monthlyCosts[i].month,
          totalCost: monthlyCosts[i].totalCost,
          recordCount: monthlyCosts[i].recordCount,
          isOutlier: isOutlier,
        ));
        if (isOutlier) outlierIndices.add(i);
      }
    } else {
      // Insufficient data for Z-Score — no outliers possible.
      analyzedCosts.addAll(monthlyCosts);
    }

    // Step 5: Convert to FlSpot (x = index, y = cost).
    final chartSpots = <FlSpot>[];
    double maxCost = 0;
    for (int i = 0; i < analyzedCosts.length; i++) {
      chartSpots.add(FlSpot(i.toDouble(), analyzedCosts[i].totalCost));
      if (analyzedCosts[i].totalCost > maxCost) {
        maxCost = analyzedCosts[i].totalCost;
      }
    }

    // Step 6: Generate X-axis labels (Jan, Feb, Mar...).
    final monthLabels = analyzedCosts.map((m) {
      return _monthAbbreviation(m.month.month);
    }).toList();

    return ReportingState(
      monthlyCosts: analyzedCosts,
      chartSpots: chartSpots,
      monthLabels: monthLabels,
      outlierIndices: outlierIndices,
      maxCost: maxCost,
      totalMonths: analyzedCosts.length,
    );
  }

  /// Converts month number (1-12) to 3-letter abbreviation.
  /// No hardcoding of date ranges — purely dynamic from data.
  static String _monthAbbreviation(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    if (month < 1 || month > 12) return '???';
    return months[month - 1];
  }
}

/// Temporary accumulator for in-memory monthly grouping.
class _MonthAccumulator {
  final DateTime month;
  double totalCost = 0;
  int count = 0;

  _MonthAccumulator(this.month);
}

/// Riverpod provider for reporting state.
final reportingProvider =
    AsyncNotifierProvider<ReportingNotifier, ReportingState>(
  ReportingNotifier.new,
);
