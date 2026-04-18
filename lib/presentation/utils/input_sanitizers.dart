import 'package:flutter/services.dart';

/// ============================================================
/// Data Sanity Firewall — Shared Input Hardening
/// ============================================================
///
/// Zero-tolerance input validation for CarSah.
/// Assumes hostile user input: paste attacks, astronomical values,
/// malformed decimals, Arabic-Indic numerals.
///
/// Usage:
///   inputFormatters: [InputSanitizers.digitsOnly],
///   validator: (v) => InputSanitizers.validateOdometer(v, t),
///   textDirection: InputSanitizers.detectTextDirection(text),
/// ============================================================
class InputSanitizers {
  InputSanitizers._(); // Prevent instantiation

  // ─── Hard Ceilings ─────────────────────────────────────────

  /// Maximum odometer reading (km). Real-world ceiling.
  static const int odometerMax = 999999;

  /// Maximum cost per entry (SAR). Prevents astronomical entries.
  static const double costMax = 99999.99;

  /// Maximum vehicle manufacture year: current year + 1.
  static int get yearMax => DateTime.now().year + 1;

  /// Minimum vehicle manufacture year.
  static const int yearMin = 1900;

  // ─── Input Formatters ──────────────────────────────────────

  /// Digits-only filter. Blocks spaces, symbols, letters.
  /// Use for odometer and year fields.
  static final digitsOnly = FilteringTextInputFormatter.digitsOnly;

  /// Cost/price formatter: digits + at most one decimal point + max 2 decimals.
  /// Regex: ^\d+\.?\d{0,2}
  /// Blocks: commas, multiple dots, leading dots, more than 2 decimal places.
  static final costFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d+\.?\d{0,2}'),
  );

  // ─── Arabic-Indic Digit Sanitization ──────────────────────

  /// Maps Arabic-Indic numerals (٠-٩) to ASCII (0-9).
  static const _arabicDigits = {
    '\u0660': '0', '\u0661': '1', '\u0662': '2',
    '\u0663': '3', '\u0664': '4', '\u0665': '5',
    '\u0666': '6', '\u0667': '7', '\u0668': '8',
    '\u0669': '9',
  };

  /// Converts Arabic-Indic numerals to ASCII digits.
  /// Also strips commas to prevent parsing crashes.
  static String sanitizeDigits(String input) {
    for (final entry in _arabicDigits.entries) {
      input = input.replaceAll(entry.key, entry.value);
    }
    return input.replaceAll(',', '');
  }

  // ─── Validators ────────────────────────────────────────────

  /// Odometer validator: required, numeric, ≤ 999,999.
  /// [t] is the translation function from SettingsState.
  static String? validateOdometer(String? v, String Function(String) t) {
    if (v == null || v.trim().isEmpty) return t('odometer_empty');
    final sanitized = sanitizeDigits(v.trim());
    final parsed = int.tryParse(sanitized);
    if (parsed == null) return t('invalid_number');
    if (parsed < 0) return t('invalid_number');
    if (parsed > odometerMax) return t('odometer_max');
    return null;
  }

  /// Cost validator: required, numeric, ≤ 99,999.99, max 2 decimals.
  /// [t] is the translation function.
  static String? validateCost(String? v, String Function(String) t) {
    if (v == null || v.trim().isEmpty) return t('field_required');
    final sanitized = sanitizeDigits(v.trim());
    final parsed = double.tryParse(sanitized);
    if (parsed == null) return t('invalid_number');
    if (parsed < 0) return t('invalid_number');
    if (parsed > costMax) return t('cost_max');
    // Reject values with more than 2 decimal places
    final decimalIndex = sanitized.indexOf('.');
    if (decimalIndex != -1 && sanitized.length - decimalIndex - 1 > 2) {
      return t('invalid_number');
    }
    return null;
  }

  /// Optional cost validator: allows empty, but validates if non-empty.
  static String? validateCostOptional(String? v, String Function(String) t) {
    if (v == null || v.trim().isEmpty) return null; // Optional
    return validateCost(v, t);
  }

  /// Year validator: required, numeric, 1900 ≤ year ≤ now+1.
  /// [t] is the translation function.
  static String? validateYear(String? v, String Function(String) t) {
    if (v == null || v.trim().isEmpty) return t('field_required');
    final sanitized = sanitizeDigits(v.trim());
    final parsed = int.tryParse(sanitized);
    if (parsed == null) return t('invalid_number');
    if (parsed < yearMin || parsed > yearMax) return t('year_max');
    return null;
  }

  /// Optional integer validator: allows empty, validates if non-empty.
  /// For interval fields (KM, months).
  static String? validateIntOptional(String? v, String Function(String) t) {
    if (v == null || v.trim().isEmpty) return null;
    final sanitized = sanitizeDigits(v.trim());
    if (int.tryParse(sanitized) == null) return t('invalid_number');
    return null;
  }

  // ─── Text Direction Detection ──────────────────────────────

  /// Detects whether text contains Arabic characters and returns
  /// the appropriate TextDirection.
  ///
  /// Logic: If text contains any character in Unicode Arabic block
  /// (U+0600–U+06FF), force RTL. Otherwise, default to LTR.
  ///
  /// Empty or whitespace-only text returns LTR (safe default).
  static TextDirection detectTextDirection(String text) {
    if (text.trim().isEmpty) return TextDirection.ltr;
    // Fast check: if first Arabic-range char found, it's RTL.
    for (final rune in text.runes) {
      if (rune >= 0x0600 && rune <= 0x06FF) {
        return TextDirection.rtl;
      }
    }
    return TextDirection.ltr;
  }
}
