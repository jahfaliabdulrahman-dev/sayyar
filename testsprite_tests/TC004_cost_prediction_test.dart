// TC004: Cost prediction — IN-MEMORY ISAR + Z-SCORE
// Upgraded: Round 3 — real Isar persistence + all edge cases
// Category: Cost Prediction | Priority: Medium

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:maintlogic/core/utils/z_score_calculator.dart';
import 'package:maintlogic/core/utils/cost_predictor.dart';
import 'package:maintlogic/data/models/maintenance_record.dart';
import 'helpers/test_helpers.dart';

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestIsar();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('TC004: Cost Prediction (In-Memory Isar)', () {
    // ─── Z-Score Calculator Tests ───────────────────────────

    test('Z-score calculator computes mean and std correctly', () {
      final values = [100.0, 110.0, 105.0, 115.0, 108.0];
      final stats = ZScoreCalculator.computeMeanStd(values);

      expect(stats, isNotNull);
      final (mean, std) = stats!;
      expect(mean, closeTo(107.6, 0.1));
      expect(std, greaterThan(0));
    });

    test('Z-score calculator detects outliers', () {
      final values = [100.0, 110.0, 105.0, 500.0, 108.0];
      final stats = ZScoreCalculator.computeMeanStd(values);

      expect(stats, isNotNull);
      final (mean, std) = stats!;
      final z = ZScoreCalculator.zScore(500.0, mean, std);

      expect(z.abs(), greaterThan(1.5));
    });

    test('Z-score returns null for insufficient data', () {
      final stats = ZScoreCalculator.computeMeanStd([100.0]);
      expect(stats, isNull);
    });

    test('Z-score returns null for empty list', () {
      final stats = ZScoreCalculator.computeMeanStd([]);
      expect(stats, isNull);
    });

    test('isOutlier requires N >= 30', () {
      final smallDataset = List.generate(10, (i) => 100.0 + i);
      final result = ZScoreCalculator.isOutlier(
        price: 200.0,
        historicalPrices: smallDataset,
      );
      expect(result, isNull);
    });

    test('isOutlier works with sufficient data', () {
      final normalPrices = List.generate(40, (_) => 100.0);
      final result = ZScoreCalculator.isOutlier(
        price: 500.0,
        historicalPrices: normalPrices,
      );
      expect(result, isTrue);
    });

    test('isOutlier handles zero-variance data', () {
      final identicalPrices = List.generate(40, (_) => 100.0);
      final result = ZScoreCalculator.isOutlier(
        price: 200.0,
        historicalPrices: identicalPrices,
      );
      expect(result, isTrue);
    });

    test('isOutlier returns false when price matches constant mean', () {
      final identicalPrices = List.generate(40, (_) => 100.0);
      final result = ZScoreCalculator.isOutlier(
        price: 100.0,
        historicalPrices: identicalPrices,
      );
      expect(result, isFalse);
    });

    test('isOutlier boundary: z-score exactly at threshold', () {
      final prices = <double>[];
      prices.addAll(List.generate(29, (_) => -1.0));
      prices.add(29.0);
      final stats = ZScoreCalculator.computeMeanStd(prices)!;
      final (mean, std) = stats;
      final boundaryValue = mean + 2.0 * std;
      final history = List<double>.from(prices);

      final result = ZScoreCalculator.isOutlier(
        price: boundaryValue,
        historicalPrices: history,
        threshold: 2.0,
      );
      expect(result, isTrue);
    });

    // ─── Cost Predictor with Isar-backed Records ───────────

    test('cost predictor returns null with no records', () {
      final result = calculatePredictedCost('oil_change', []);
      expect(result, isNull);
    });

    test('cost predictor returns simple average for N < 3', () async {
      final records = [
        createTestRecord(
          taskKeys: ['oil_change'],
          partsCost: 100.0,
          totalCost: 150.0,
        ),
        createTestRecord(
          taskKeys: ['oil_change'],
          partsCost: 110.0,
          totalCost: 160.0,
        ),
      ];

      // Persist to Isar
      await isar.writeTxn(() async {
        for (final r in records) {
          await isar.maintenanceRecords.put(r);
        }
      });

      // Read back
      final stored = await isar.maintenanceRecords.where().findAll();
      final result = calculatePredictedCost('oil_change', stored);

      expect(result, isNotNull);
      expect(result, closeTo(105.0, 0.1)); // (100 + 110) / 2
    });

    test('cost predictor filters outliers for N >= 3', () async {
      // 10 normal values around 100-110, plus one massive outlier at 10000
      final records = <MaintenanceRecord>[];
      for (int i = 0; i < 10; i++) {
        records.add(createTestRecord(
          taskKeys: ['oil_change'],
          partsCost: 100.0 + (i % 5) * 2.0, // 100, 102, 104, 106, 108
        ));
      }
      records.add(createTestRecord(
        taskKeys: ['oil_change'],
        partsCost: 10000.0, // extreme outlier
      ));

      await isar.writeTxn(() async {
        for (final r in records) {
          await isar.maintenanceRecords.put(r);
        }
      });

      final stored = await isar.maintenanceRecords.where().findAll();
      final result = calculatePredictedCost('oil_change', stored);

      expect(result, isNotNull);
      // With 10 normal values, 10000 is clearly an outlier by Z-score
      expect(result, lessThan(200),
          reason: 'With 10 normal data points, outlier 10000 should be filtered');
    });

    test('cost predictor ignores records without matching taskKey', () async {
      final records = [
        createTestRecord(
          taskKeys: ['tire_rotation'],
          partsCost: 500.0,
        ),
        createTestRecord(
          taskKeys: ['oil_change'],
          partsCost: 100.0,
        ),
      ];

      await isar.writeTxn(() async {
        for (final r in records) {
          await isar.maintenanceRecords.put(r);
        }
      });

      final stored = await isar.maintenanceRecords.where().findAll();
      final result = calculatePredictedCost('oil_change', stored);

      expect(result, equals(100.0));
    });

    test('cost predictor ignores records with zero partsCost', () async {
      final records = [
        createTestRecord(taskKeys: ['oil_change'], partsCost: 0.0),
        createTestRecord(taskKeys: ['oil_change'], partsCost: 100.0),
      ];

      await isar.writeTxn(() async {
        for (final r in records) {
          await isar.maintenanceRecords.put(r);
        }
      });

      final stored = await isar.maintenanceRecords.where().findAll();
      final result = calculatePredictedCost('oil_change', stored);

      expect(result, equals(100.0));
    });
  });
}
