import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/reporting_provider.dart';

/// ============================================================
/// Cost Trend Chart — Monthly Expense Visualization
/// ============================================================
///
/// Renders a curved LineChart showing monthly maintenance costs.
///
/// Architecture:
///   - Data flows: maintenanceProvider → reportingProvider → this widget.
///   - X-axis: dynamic month labels (Jan, Feb...) from ReportingState.
///   - Outlier months (|Z| > 2.0) get red dot markers.
///   - No hardcoded date ranges — pure data-driven rendering.
///
/// Dependencies: fl_chart
/// ============================================================
class CostTrendChart extends ConsumerWidget {
  const CostTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportingAsync = ref.watch(reportingProvider);

    return reportingAsync.when(
      data: (state) {
        if (state.chartSpots.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildChart(context, state);
      },
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => SizedBox(
        height: 220,
        child: Center(child: Text('Chart error: $e')),
      ),
    );
  }

  /// Empty state when no maintenance records exist yet.
  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No spending data yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            Text(
              'Log maintenance to see trends',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Main chart widget with curved line and outlier markers.
  Widget _buildChart(BuildContext context, ReportingState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final outlierColor = Colors.redAccent;

    // Y-axis: pad 20% above max for visual breathing room.
    final maxY = state.maxCost > 0 ? state.maxCost * 1.2 : 1000.0;

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, right: 16),
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY > 0 ? maxY / 4 : 250,
              getDrawingHorizontalLine: (value) => FlLine(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              // X-axis: dynamic month labels from state.
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= state.monthLabels.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        state.monthLabels[index],
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Y-axis: cost in SAR.
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: maxY > 0 ? maxY / 4 : 250,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox.shrink();
                    return Text(
                      '${value.toInt()}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: state.chartSpots,
                isCurved: true,
                curveSmoothness: 0.3,
                color: primaryColor,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final isOutlier = state.outlierIndices.contains(index);
                    return FlDotCirclePainter(
                      radius: isOutlier ? 6 : 3,
                      color: isOutlier ? outlierColor : primaryColor,
                      strokeWidth: isOutlier ? 2 : 0,
                      strokeColor: isOutlier
                          ? outlierColor.withValues(alpha: 0.4)
                          : Colors.transparent,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: primaryColor.withValues(alpha: 0.08),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.x.toInt();
                    if (index < 0 || index >= state.monthlyCosts.length) {
                      return null;
                    }
                    final cost = state.monthlyCosts[index];
                    final label = cost.isOutlier ? ' \u26a0 OUTLIER' : '';
                    return LineTooltipItem(
                      '${cost.totalCost.toStringAsFixed(0)} SAR\n'
                      '${cost.recordCount} records$label',
                      TextStyle(
                        color: cost.isOutlier ? outlierColor : primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
