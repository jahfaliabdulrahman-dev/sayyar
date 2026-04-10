import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================================
/// Settings Provider — Locale Management
/// ============================================================
///
/// Simple locale toggle between EN and AR.
/// Uses a string map for basic translations until i18n is adopted.
/// ============================================================

/// Supported locales.
enum AppLocale { en, ar }

/// Simple string map for UI translations.
/// Replace with proper .arb files when i18n is fully adopted.
const _translations = {
  // Units & Currency
  'currency': {'en': 'SAR', 'ar': 'ر.س'},
  'km': {'en': 'km', 'ar': 'كم'},
  'months': {'en': 'months', 'ar': 'أشهر'},

  // Service Types (database interceptor — both display name and snake_case)
  'Oil Change': {'en': 'Oil Change', 'ar': 'تغيير الزيت'},
  'oil_change': {'en': 'Oil Change', 'ar': 'تغيير الزيت'},
  'Oil Filter': {'en': 'Oil Filter', 'ar': 'فلتر الزيت'},
  'oil_filter': {'en': 'Oil Filter', 'ar': 'فلتر الزيت'},
  'Cabin Air Filter': {'en': 'Cabin Air Filter', 'ar': 'فلتر هواء المقصورة'},
  'cabin_air_filter': {'en': 'Cabin Air Filter', 'ar': 'فلتر هواء المقصورة'},
  'Engine Air Filter': {'en': 'Engine Air Filter', 'ar': 'فلتر هواء المحرك'},
  'air_filter_engine': {'en': 'Engine Air Filter', 'ar': 'فلتر هواء المحرك'},
  'Tire Rotation': {'en': 'Tire Rotation', 'ar': 'تبديل الإطارات'},
  'tire_rotation': {'en': 'Tire Rotation', 'ar': 'تبديل الإطارات'},
  'Front Brake Pads': {'en': 'Front Brake Pads', 'ar': 'تيل فرامل أمامي'},
  'brake_pads_front': {'en': 'Front Brake Pads', 'ar': 'تيل فرامل أمامي'},
  'Rear Brake Pads': {'en': 'Rear Brake Pads', 'ar': 'تيل فرامل خلفي'},
  'brake_pads_rear': {'en': 'Rear Brake Pads', 'ar': 'تيل فرامل خلفي'},
  'Fuel Filter': {'en': 'Fuel Filter', 'ar': 'فلتر الوقود'},
  'fuel_filter': {'en': 'Fuel Filter', 'ar': 'فلتر الوقود'},
  'Brake Fluid': {'en': 'Brake Fluid', 'ar': 'سائل الفرامل'},
  'brake_fluid': {'en': 'Brake Fluid', 'ar': 'سائل الفرامل'},
  'Coolant': {'en': 'Coolant', 'ar': 'سائل التبريد'},
  'coolant': {'en': 'Coolant', 'ar': 'سائل التبريد'},
  'Spark Plugs': {'en': 'Spark Plugs', 'ar': 'البواجي'},
  'spark_plugs': {'en': 'Spark Plugs', 'ar': 'البواجي'},
  'Transmission Fluid': {'en': 'Transmission Fluid', 'ar': 'زيت القير'},
  'transmission_fluid': {'en': 'Transmission Fluid', 'ar': 'زيت القير'},

  // Dashboard
  'app_title': {'en': 'Sayyar', 'ar': 'سيّار'},
  'add_custom_task': {'en': 'Add Task', 'ar': 'إضافة مهمة'},
  'action_required': {'en': 'Action Required:', 'ar': 'إجراء مطلوب:'},
  'services_overdue': {'en': 'Services Overdue', 'ar': 'مهام متأخرة'},
  'heads_up': {'en': 'Heads up:', 'ar': 'تنبيه:'},
  'services_upcoming': {'en': 'Services upcoming', 'ar': 'مهام قادمة'},
  'all_systems_go': {
    'en': 'All Systems Go. Vehicle in optimal health',
    'ar': 'المركبة في حالة ممتازة'
  },
  'update': {'en': 'Update', 'ar': 'تحديث'},
  'odometer': {'en': 'Odometer', 'ar': 'العداد'},
  'year': {'en': 'Year', 'ar': 'السنة'},
  'cost_trend': {'en': 'Cost Trend', 'ar': 'اتجاه التكاليف'},
  'monthly': {'en': 'Monthly', 'ar': 'شهري'},
  'total_spending': {'en': 'Total Spending', 'ar': 'إجمالي الإنفاق'},
  'service_records': {'en': 'service records', 'ar': 'سجلات صيانة'},

  // Tasks
  'service_tasks': {'en': 'Service Tasks', 'ar': 'مهام الصيانة'},
  'every_km': {'en': 'Every', 'ar': 'كل'},
  'remaining': {'en': 'Remaining', 'ar': 'متبقي'},
  'due_now': {'en': 'Due Now', 'ar': 'مستحق الآن'},
  'overdue_by': {'en': 'Overdue by', 'ar': 'متأخر بـ'},
  'next': {'en': 'Next', 'ar': 'القادم'},
  'overdue_services': {'en': 'Overdue Services', 'ar': 'مهام متأخرة'},
  'upcoming_services': {'en': 'Upcoming Services', 'ar': 'مهام قادمة'},
  'future_services': {'en': 'Future Services', 'ar': 'مهام مستقبلية'},
  'short_overdue': {'en': 'Overdue', 'ar': 'متأخر'},
  'short_upcoming': {'en': 'Upcoming', 'ar': 'قادم'},
  'short_future': {'en': 'Future', 'ar': 'مستقبلي'},
  'overdue': {'en': 'OVERDUE', 'ar': 'متأخر'},
  'soon': {'en': 'SOON', 'ar': 'قريب'},
  'ok': {'en': 'OK', 'ar': 'طبيعي'},

  // History
  'maintenance_history': {'en': 'Maintenance History', 'ar': 'سجل الصيانة'},
  'log_service': {'en': 'Log Service', 'ar': 'تسجيل صيانة'},
  'no_records': {'en': 'No maintenance records yet', 'ar': 'لا توجد سجلات صيانة'},
  'tap_to_log': {
    'en': 'Tap the + button to log your first service',
    'ar': 'اضغط على + لتسجيل أول صيانة'
  },

  // Navigation
  'nav_dashboard': {'en': 'Dashboard', 'ar': 'لوحة القيادة'},
  'nav_tasks': {'en': 'Tasks', 'ar': 'المهام'},
  'nav_history': {'en': 'History', 'ar': 'السجل'},

  // Common
  'cancel': {'en': 'Cancel', 'ar': 'إلغاء'},
  'delete': {'en': 'Delete', 'ar': 'حذف'},
  'save': {'en': 'Save', 'ar': 'حفظ'},
  'delete_record': {'en': 'Delete Record', 'ar': 'حذف السجل'},
  'delete_task': {'en': 'Delete Task', 'ar': 'حذف المهمة'},
  'edit': {'en': 'Edit', 'ar': 'تعديل'},
  'delete_confirm': {
    'en': 'Are you sure you want to delete this record? This will recalculate your upcoming maintenance tasks.',
    'ar': 'هل أنت متأكد من حذف هذا السجل؟ سيتم إعادة حساب المهام القادمة.'
  },
  'delete_task_confirm': {
    'en': 'Are you sure? This will stop tracking this service.',
    'ar': 'هل أنت متأكد؟ سيتم إيقاف تتبع هذه الخدمة.'
  },
};

/// Immutable settings state.
class SettingsState {
  final AppLocale locale;

  const SettingsState({this.locale = AppLocale.en});

  SettingsState copyWith({AppLocale? locale}) {
    return SettingsState(locale: locale ?? this.locale);
  }

  /// Translates a key to the current locale.
  String t(String key) {
    final map = _translations[key];
    if (map == null) return key;
    return map[locale.name] ?? map['en'] ?? key;
  }

  /// Whether the current locale is RTL.
  bool get isRtl => locale == AppLocale.ar;
}

/// Notifier for settings state.
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  void toggleLocale() {
    state = state.copyWith(
      locale: state.locale == AppLocale.en ? AppLocale.ar : AppLocale.en,
    );
  }

  void setLocale(AppLocale locale) {
    state = state.copyWith(locale: locale);
  }
}

/// Riverpod provider for settings.
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
