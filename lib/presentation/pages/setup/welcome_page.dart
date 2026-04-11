import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/vehicle.dart';
import '../../providers/settings_provider.dart';
import '../../providers/vehicle_provider.dart';
import 'setup_wizard_page.dart';

/// ============================================================
/// Welcome Page — Mandatory First-Run Onboarding
/// ============================================================
///
/// Shown ONLY when isar.vehicles.count() == 0.
/// Cannot be dismissed or skipped — user must create a vehicle first.
///
/// After vehicle creation, auto-navigates to SetupWizard for optional
/// historical maintenance logging.
/// ============================================================
class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _odometerController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final make = _makeController.text.trim();
    final model = _modelController.text.trim();
    final year = int.parse(_yearController.text.trim());
    final odometerKm = int.tryParse(_odometerController.text.trim()) ?? 0;

    final vehicle = Vehicle(
      name: '$make $model',
      make: make,
      model: model,
      year: year,
      currentOdometerKm: odometerKm,
      addedAt: DateTime.now(),
      isActive: true,
    );

    await ref.read(vehicleProvider.notifier).createVehicle(vehicle);

    if (mounted) {
      // Navigate to Setup Wizard (optional — can skip).
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SetupWizardPage(isFirstRun: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(settingsProvider).t;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // — Brand Icon —
                  Icon(
                    Icons.directions_car_rounded,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('app_title'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('welcome_subtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // — Make Field —
                  TextFormField(
                    controller: _makeController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: t('make'),
                      hintText: t('make_hint'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.car_rental_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? t('make') : null,
                  ),
                  const SizedBox(height: 16),

                  // — Model Field —
                  TextFormField(
                    controller: _modelController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: t('model'),
                      hintText: t('model_hint'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.model_training_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? t('model') : null,
                  ),
                  const SizedBox(height: 16),

                  // — Year Field (digits only) —
                  TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: InputDecoration(
                      labelText: t('year'),
                      hintText: t('year_hint'),
                      border: const OutlineInputBorder(),
                      prefixIcon:
                          const Icon(Icons.calendar_today_outlined, size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return t('year');
                      final parsed = int.tryParse(v.trim());
                      if (parsed == null || parsed < 1900 || parsed > 2100) {
                        return 'Invalid year';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // — Odometer Field (digits only) —
                  TextFormField(
                    controller: _odometerController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: t('odometer'),
                      hintText: t('odometer_hint'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.speed_outlined, size: 20),
                      suffixText: t('km'),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return t('odometer');
                      if (int.tryParse(v.trim()) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // — Save & Continue —
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _onSave,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.arrow_forward),
                      label: Text(
                        t('welcome_continue'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
