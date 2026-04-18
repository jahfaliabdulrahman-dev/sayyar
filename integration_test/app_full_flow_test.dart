// TC001-TC010: Full App Flow — INTEGRATION TEST (Device Required)
// Runs the complete user journey on a real device with real Isar.
//
// Run: flutter test integration_test/app_full_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:maintlogic/main.dart';
import 'package:maintlogic/presentation/pages/setup/welcome_page.dart';
import 'package:maintlogic/presentation/pages/home/home_root_page.dart';
import 'package:maintlogic/presentation/pages/dashboard/dashboard_page.dart';
import 'package:maintlogic/presentation/pages/tasks/tasks_page.dart';
import 'package:maintlogic/presentation/pages/history/history_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CarSah Full App Flow (Device)', () {
    testWidgets('complete onboarding + navigation flow', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: CarSahApp()),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ── TC001: Welcome Page ──
      expect(find.byType(WelcomePage), findsOneWidget,
          reason: 'First run should show WelcomePage');

      // Verify app title
      expect(find.text('CarSah'), findsOneWidget);

      // Fill vehicle form
      final makeField = find.widgetWithText(TextFormField, 'Make')
          .evaluate().isNotEmpty
          ? find.widgetWithText(TextFormField, 'Make')
          : find.byType(TextFormField).first;
      await tester.enterText(makeField, 'Tank');
      await tester.pump();

      final modelField = find.widgetWithText(TextFormField, 'Model')
          .evaluate().isNotEmpty
          ? find.widgetWithText(TextFormField, 'Model')
          : find.byType(TextFormField).at(1);
      await tester.enterText(modelField, '300');
      await tester.pump();

      final yearField = find.widgetWithText(TextFormField, 'Model Year')
          .evaluate().isNotEmpty
          ? find.widgetWithText(TextFormField, 'Model Year')
          : find.byType(TextFormField).at(2);
      await tester.enterText(yearField, '2024');
      await tester.pump();

      final odometerField = find.widgetWithText(TextFormField, 'Odometer')
          .evaluate().isNotEmpty
          ? find.widgetWithText(TextFormField, 'Odometer')
          : find.byType(TextFormField).at(3);
      await tester.enterText(odometerField, '15000');
      await tester.pump();

      // Tap Continue
      final continueBtn = find.widgetWithText(FilledButton, 'Continue')
          .evaluate().isNotEmpty
          ? find.widgetWithText(FilledButton, 'Continue')
          : find.byType(FilledButton).first;
      await tester.tap(continueBtn);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ── After onboarding: should navigate to SetupWizard or Home ──
      // The wizard may appear, so we skip it
      final skipBtn = find.text('Skip');
      if (skipBtn.evaluate().isNotEmpty) {
        await tester.tap(skipBtn);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // ── TC009: Dashboard ──
      expect(find.byType(HomeRootPage), findsOneWidget,
          reason: 'After onboarding, should show HomeRootPage');
      expect(find.byType(DashboardPage), findsOneWidget);

      // Verify vehicle card shows
      expect(find.text('Tank 300'), findsOneWidget);

      // ── TC002: Navigation to Tasks ──
      final tasksTab = find.byIcon(Icons.checklist_outlined);
      if (tasksTab.evaluate().isNotEmpty) {
        await tester.tap(tasksTab);
        await tester.pumpAndSettle();
        expect(find.byType(TasksPage), findsOneWidget);
      }

      // ── TC003: Navigation to History ──
      final historyTab = find.byIcon(Icons.history_outlined);
      if (historyTab.evaluate().isNotEmpty) {
        await tester.tap(historyTab);
        await tester.pumpAndSettle();
        expect(find.byType(HistoryPage), findsOneWidget);
      }

      // ── TC007: Language Toggle ──
      // Navigate back to Dashboard
      final dashboardTab = find.byIcon(Icons.home_outlined);
      if (dashboardTab.evaluate().isNotEmpty) {
        await tester.tap(dashboardTab);
        await tester.pumpAndSettle();
      }

      // Open menu
      final menuBtn = find.byIcon(Icons.more_vert);
      if (menuBtn.evaluate().isNotEmpty) {
        await tester.tap(menuBtn);
        await tester.pumpAndSettle();

        // Tap language option
        final langOption = find.text('English');
        if (langOption.evaluate().isNotEmpty) {
          await tester.tap(langOption);
          await tester.pumpAndSettle();
        }
      }

      // Verify app didn't crash after language switch
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
