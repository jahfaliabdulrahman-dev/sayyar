import 'dart:math';

/// Lightweight statistical toolkit for crowdsourced price validation.
///
/// Purpose: Detect price outliers when we reach N >= 30 samples.
/// Design is intentionally minimal — no external dependency needed.
///
/// Usage:
///   final stats = ZScoreCalculator.computeMeanStd(prices);
///   final z = ZScoreCalculator.zScore(150.0, stats.mean, stats.std);
///   if (z.abs() > 2.0) { // Flag as outlier }
class ZScoreCalculator {
  /// Compute mean and standard deviation for a list of prices.
  ///
  /// Requires at least 2 data points. Returns null if insufficient data.
  static (double mean, double std)? computeMeanStd(List<double> values) {
    if (values.length < 2) return null;

    final sum = values.fold<double>(0, (acc, v) => acc + v);
    final mean = sum / values.length;

    final variance =
        values.fold<double>(0, (acc, v) => acc + pow(v - mean, 2)) /
        (values.length - 1); // Sample std (n-1)

    return (mean, sqrt(variance));
  }

  /// Calculate Z-Score for a value given the population mean and std.
  ///
  /// Z > 2.0  → likely overpriced (top ~2.5% tail)
  /// Z < -2.0 → likely underpriced (bottom ~2.5% tail)
  /// Z within [-2, 2] → normal price range
  static double zScore(double value, double mean, double std) {
    if (std == 0) return 0;
    return (value - mean) / std;
  }

  /// Check if a price is an outlier based on existing data.
  ///
  /// Returns null if N < 30 (insufficient for statistical significance).
  static bool? isOutlier({
    required double price,
    required List<double> historicalPrices,
    double threshold = 2.0,
  }) {
    if (historicalPrices.length < 30) {
      return null; // Not enough data — cannot classify
    }

    final stats = computeMeanStd(historicalPrices);
    if (stats == null) return null;

    final (mean, std) = stats;
    final z = zScore(price, mean, std);
    return z.abs() > threshold;
  }
}
