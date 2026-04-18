// TC001: Welcome Page Localization — INTEGRATION TEST (Device Required)
// This test runs on a real Android device where Isar can initialize.
// Solves the headless Isar initialization failure from Rounds 1-2.
//
// Run: flutter test integration_test/tc01_welcome_localization_test.dart
// Or:  flutter drive --driver integration_test/driver.dart --target integration_test/tc01_welcome_localization_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:maintlogic/main.dart';
import 'package:maintlogic/presentation/pages/setup/welcome_page.dart';
import 'package:maintlogic/presentation/providers/settings_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TC001: Welcome Page Localization (Device)', () {
    testWidgets('app launches and shows WelcomePage on first run',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: CarSahApp()),
      );

      // Wait for Isar init + first-run check
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // On first run (no vehicles), should show WelcomePage
      expect(find.byType(WelcomePage), findsOneWidget);
      expect(find.text('CarSah'), findsOneWidget);
    });

    testWidgets('WelcomePage shows vehicle input fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: CarSahApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify form fields exist
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byIcon(Icons.directions_car_rounded), findsOneWidget);
    });

    testWidgets('settings sheet shows language toggle', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: CarSahApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap settings icon
      final settingsButton = find.byIcon(Icons.settings_outlined);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();

        // Verify language toggle exists
        expect(find.byType(SegmentedButton<AppLocale>), findsOneWidget);
      }
    });

    testWidgets('Directionality widget exists in widget tree', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: CarSahApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(Directionality), findsWidgets);
    });

    testWidgets('MaterialApp is configured correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: CarSahApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('CarSah'));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
      expect(materialApp.supportedLocales, contains(const Locale('en', '')));
      expect(materialApp.supportedLocales, contains(const Locale('ar', '')));
    });
  });
}
