import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/local/isar_provider.dart';
import 'presentation/pages/home/home_root_page.dart';

/// ============================================================
/// Application Entry Point — MaintLogic MVP
/// ============================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final isar = await initIsarDatabase();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const MaintLogicApp(),
    ),
  );
}

/// Root MaterialApp with bilingual support (EN/AR).
class MaintLogicApp extends StatelessWidget {
  const MaintLogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaintLogic',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: ThemeMode.system,

      // Pinned to English to prevent RTL visual corruption.
      // Device system locale is Arabic — without this pin, English
      // text renders right-aligned with broken padding.
      locale: const Locale('en', ''),
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],

      // Localization delegates — required so Arabic RTL does not crash.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const HomeRootPage(),
    );
  }

  static const _brandBlue = Color(0xFF006064);

  static ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brandBlue,
        brightness: Brightness.light,
      ).copyWith(surface: Colors.white),
      scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
      ),
      appBarTheme: const AppBarThemeData(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFFF0F4F8),
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _brandBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brandBlue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarThemeData(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
