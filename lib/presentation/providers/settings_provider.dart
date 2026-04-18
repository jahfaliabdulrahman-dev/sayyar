import 'package:flutter/material.dart';
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
  'Front Brake Pads': {'en': 'Front Brake Pads', 'ar': 'فحمات فرامل أمامي'},
  'brake_pads_front': {'en': 'Front Brake Pads', 'ar': 'فحمات فرامل أمامي'},
  'Rear Brake Pads': {'en': 'Rear Brake Pads', 'ar': 'فحمات فرامل خلفي'},
  'brake_pads_rear': {'en': 'Rear Brake Pads', 'ar': 'فحمات فرامل خلفي'},
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
  'Transfer Case Oil': {'en': 'Transfer Case Oil', 'ar': 'زيت الدبل'},
  'transfer_case_oil': {'en': 'Transfer Case Oil', 'ar': 'زيت الدبل'},
  'Front Differential Fluid': {'en': 'Front Differential Fluid', 'ar': 'زيت الدفرنس الأمامي'},
  'diff_fluid_front': {'en': 'Front Differential Fluid', 'ar': 'زيت الدفرنس الأمامي'},
  'Rear Differential Fluid': {'en': 'Rear Differential Fluid', 'ar': 'زيت الدفرنس الخلفي'},
  'diff_fluid_rear': {'en': 'Rear Differential Fluid', 'ar': 'زيت الدفرنس الخلفي'},
  'Wheel Alignment': {'en': 'Wheel Alignment', 'ar': 'ميزان الأذرع'},
  'wheel_alignment': {'en': 'Wheel Alignment', 'ar': 'ميزان الأذرع'},

  // Dashboard
  'app_title': {'en': 'CarSah', 'ar': 'كار-صح'},
  'beta_badge': {'en': 'BETA', 'ar': 'نسخة تجريبية'},
  'menu_language': {'en': 'English', 'ar': 'اللغة العربية'},
  'menu_theme': {'en': 'Appearance', 'ar': 'المظهر'},
  'menu_feedback': {'en': 'Feedback Hub', 'ar': 'مركز التغذية الراجعة'},
  'add_custom_task': {'en': 'Add Task', 'ar': 'إضافة مهمة'},
  'action_required': {'en': 'Action Required:', 'ar': 'إجراء مطلوب:'},
  'services_overdue': {'en': 'Services Overdue', 'ar': 'مهام متأخرة'},
  'heads_up': {'en': 'Heads up:', 'ar': 'تنبيه:'},
  'services_upcoming': {'en': 'Services upcoming', 'ar': 'مهام قادمة'},
  'all_systems_go': {
    'en': 'All Systems Go. Vehicle in optimal health',
    'ar': 'المركبة في حالة ممتازة'
  },
  'update': {'en': 'Update Odometer', 'ar': 'تحديث العداد'},
  'odometer': {'en': 'Odometer', 'ar': 'العداد'},
  'kilometers': {'en': 'Kilometers', 'ar': 'الكيلومترات'},
  'year': {'en': 'Model Year', 'ar': 'سنة الصنع'},
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
  'create': {'en': 'Create', 'ar': 'إنشاء'},
  'save_all': {'en': 'Save All', 'ar': 'حفظ الكل'},
  'delete_record': {'en': 'Delete Record', 'ar': 'حذف السجل'},
  'delete_task': {'en': 'Delete Task', 'ar': 'حذف المهمة'},
  'edit': {'en': 'Edit', 'ar': 'تعديل'},
  'delete_confirm': {
    'en': 'Are you sure you want to delete this record? This will recalculate your upcoming maintenance tasks.',
    'ar': 'هل أنت متأكد من حذف هذا السجل؟ سيتم إعادة حساب المهام القادمة.'
  },
  'delete_task_title': {'en': 'Delete Task', 'ar': 'حذف المهمة'},
  'delete_task_body': {
    'en': 'Are you sure? This will stop tracking this service.',
    'ar': 'هل أنت متأكد؟ سيتم إيقاف تتبع هذه الخدمة.'
  },
  'edit_task': {'en': 'Edit Task', 'ar': 'تعديل المهمة'},

  // Dialog Fields (Add Custom Task / Add Record)
  'task_name': {'en': 'Task Name', 'ar': 'اسم المهمة'},
  'task_name_ar': {'en': 'Task Name (Arabic)', 'ar': 'اسم المهمة (عربي)'},
  'task_name_en': {'en': 'Task Name (English)', 'ar': 'اسم المهمة (إنجليزي)'},
  'interval_km': {'en': 'Interval (KM)', 'ar': 'الفاصل الزمني (كم)'},
  'interval_months': {'en': 'Interval (Months)', 'ar': 'الفاصل الزمني (أشهر)'},
  'start_current': {
    'en': 'Start from current odometer',
    'ar': 'ابدأ من العداد الحالي'
  },
  'tracking_factory': {
    'en': 'Tracking begins from factory',
    'ar': 'يبدأ التتبع من المصنع'
  },
  'tracking_now': {
    'en': 'Tracking begins now (just serviced)',
    'ar': 'يبدأ التتبع الآن (تمت الصيانة)'
  },
  'optional': {'en': 'optional', 'ar': 'اختياري'},
  'service_type': {'en': 'Service Type', 'ar': 'نوع الصيانة'},
  'service_date': {'en': 'Service Date', 'ar': 'تاريخ الصيانة'},
  'cost': {'en': 'Cost', 'ar': 'التكلفة'},
  'part_cost': {'en': 'Part Cost', 'ar': 'تكلفة القطعة'},
  'notes': {'en': 'Notes', 'ar': 'ملاحظات'},

  // Vehicle Edit
  'edit_vehicle': {'en': 'Edit Vehicle', 'ar': 'تعديل المركبة'},
  'make': {'en': 'Make', 'ar': 'الماركة'},
  'model': {'en': 'Model', 'ar': 'الموديل'},
  'my_car': {'en': 'My Car', 'ar': 'سيارتي'},
  'choose_service': {'en': 'Choose the service', 'ar': 'اختر نوع الصيانة'},
  'select_services': {'en': 'Select Services', 'ar': 'اختر الخدمات'},
  'no_tasks_loaded': {
    'en': 'No service tasks loaded.',
    'ar': 'لا توجد مهام صيانة.'
  },

  // Setup Wizard
  'setup_wizard': {'en': 'Setup Wizard', 'ar': 'معالج الإعداد'},
  'vehicle_info': {'en': 'Vehicle Info', 'ar': 'بيانات المركبة'},
  'current_state': {'en': 'Current Odometer', 'ar': 'العداد الحالي'},
  'past_maintenance': {'en': 'Past Maintenance', 'ar': 'الصيانات السابقة'},
  'mark_as_done': {'en': 'Done previously', 'ar': 'أُنجزت مسبقاً'},
  'done_at_km': {'en': 'Done at (KM)', 'ar': 'تمت عند (كم)'},
  'finish_setup': {'en': 'Finish Setup', 'ar': 'إنهاء الإعداد'},
  'skip_for_now': {'en': 'Skip', 'ar': 'تخطي'},

  // Feedback Hub
  'feedback_hub': {'en': 'Feedback', 'ar': 'التغذية الراجعة'},
  'whatsapp_tooltip': {'en': 'Chat via WhatsApp', 'ar': 'تواصل عبر واتساب'},
  'email_tooltip': {'en': 'Send an email', 'ar': 'أرسل بريداً'},
  'survey_tooltip': {'en': 'Share your opinion', 'ar': 'شاركنا رأيك'},
  'survey_title': {'en': 'Quick Survey', 'ar': 'استبيان سريع'},
  'survey_subtitle': {'en': 'Help us improve (2 min)', 'ar': 'ساعدنا على التحسين (٢ دقيقة)'},
  'email_title': {'en': 'Email Support', 'ar': 'دعم البريد الإلكتروني'},

  // Record Detail
  'record_details': {'en': 'Record Details', 'ar': 'تفاصيل السجل'},
  'edit_record': {'en': 'Edit Record', 'ar': 'تعديل السجل'},
  'delete_confirm_title': {'en': 'Delete Record?', 'ar': 'حذف السجل؟'},
  'delete_confirm_body': {
    'en': 'This action cannot be undone. Are you sure?',
    'ar': 'لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟'
  },
  'total_cost': {'en': 'Total Cost', 'ar': 'إجمالي التكلفة'},
  'services_performed': {'en': 'Services Performed', 'ar': 'الخدمات المنجزة'},
  'labor_cost': {'en': 'Labor', 'ar': 'العمالة'},
  'predicted_cost': {'en': 'Est: ', 'ar': 'متوقع: '},

  // Welcome Page
  'welcome_subtitle': {
    'en': 'Track your vehicle maintenance.\nStart by adding your car details.',
    'ar': 'تابع صيانة سيارتك.\nأبدأ بإدخال بيانات السيارة.'
  },
  'make_hint': {'en': 'e.g. Tank', 'ar': 'مثال: تانك'},
  'model_hint': {'en': 'e.g. 300', 'ar': 'مثال: 300'},
  'year_hint': {'en': 'e.g. 2024', 'ar': 'مثال: 2024'},
  'odometer_hint': {'en': 'e.g. 45000', 'ar': 'مثال: 45000'},
  'welcome_continue': {'en': 'Continue', 'ar': 'متابعة'},

  // Dashboard Setup Banner
  'setup_banner_title': {
    'en': 'Complete your car maintenance history',
    'ar': 'أكمل إعداد سجل صيانة سيارتك'
  },
  'setup_banner_action': {'en': 'Start Wizard', 'ar': 'بدء المعالج'},

  // Setup Wizard — 2-Step
  'step_config': {'en': 'Task Setup', 'ar': 'إعداد المهام'},
  'step_history': {'en': 'History', 'ar': 'السجلات السابقة'},
  'next_step': {'en': 'Next', 'ar': 'التالي'},
  'back': {'en': 'Back', 'ar': 'رجوع'},
  'no_tasks_selected': {
    'en': 'No tasks selected. Go back and choose at least one.',
    'ar': 'لم يتم اختيار أي مهام. عد واختر مهمة واحدة على الأقل.'
  },
  'step1_context': {
    'en': 'These are the recommended periodic tasks for your vehicle. Select the tasks you want to track so we can schedule your upcoming alerts accurately.',
    'ar': 'هذه هي المهام الدورية المقترحة لسيارتك. اختر المهام التي تريد متابعتها حتى نتمكن من جدولة تنبيهاتك القادمة بدقة.'
  },
  'step2_context': {
    'en': 'Enter the last service data for your selected tasks (odometer and cost) to set an accurate starting point.',
    'ar': 'سجل بيانات آخر صيانة قمت بها للمهام المختارة (الممشى والتكلفة) لضبط نقطة البداية بدقة.'
  },

  // Validation Errors
  'field_required': {'en': 'This field is required', 'ar': 'هذا الحقل مطلوب'},
  'invalid_number': {'en': 'Invalid number', 'ar': 'رقم غير صالح'},
  'odometer_max': {
    'en': 'Odometer cannot exceed 999,999 km',
    'ar': 'لا يمكن أن يتجاوز العداد ٩٩٩,٩٩٩ كم'
  },
  'cost_max': {
    'en': 'Cost cannot exceed 99,999.99 SAR',
    'ar': 'لا يمكن أن تتجاوز التكلفة ٩٩,٩٩٩.٩٩ ر.س'
  },
  'year_max': {
    'en': 'Year cannot exceed next year',
    'ar': 'لا يمكن أن تتجاوز السنة السنة القادمة'
  },
  'odometer_empty': {
    'en': 'Enter the odometer reading',
    'ar': 'أدخل قراءة العداد'
  },

  // Invoice
  'invoice_photo': {'en': 'Invoice Photo', 'ar': 'صورة الفاتورة'},
  'camera': {'en': 'Camera', 'ar': 'الكاميرا'},
  'gallery': {'en': 'Gallery', 'ar': 'المعرض'},
  'image_not_found': {'en': 'Image not found', 'ar': 'الصورة غير موجودة'},
  'close': {'en': 'Close', 'ar': 'إغلاق'},
};

/// Immutable settings state.
class SettingsState {
  final AppLocale locale;
  final ThemeMode themeMode;

  const SettingsState({
    this.locale = AppLocale.ar,
    this.themeMode = ThemeMode.light,
  });

  SettingsState copyWith({AppLocale? locale, ThemeMode? themeMode}) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
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

  void toggleTheme() {
    state = state.copyWith(
      themeMode: state.themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }
}

/// Riverpod provider for settings.
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
