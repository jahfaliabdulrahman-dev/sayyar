import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:maintlogic/presentation/providers/settings_provider.dart';
import 'package:maintlogic/presentation/providers/vehicle_provider.dart';
import 'package:maintlogic/presentation/utils/input_sanitizers.dart';

/// ============================================================
/// Odometer Update Dialog
/// ============================================================
///
/// A simple modal dialog that prompts the user to enter a new
/// odometer reading. On confirm, calls updateOdometer on the
/// VehicleNotifier provider.
///
/// Design:
///   - Number-only keyboard for clean numeric input.
///   - Pre-filled with current odometer for quick adjustment.
/// ============================================================
class OdometerUpdateDialog extends ConsumerStatefulWidget {
  const OdometerUpdateDialog({super.key});

  @override
  ConsumerState<OdometerUpdateDialog> createState() =>
      _OdometerUpdateDialogState();
}

class _OdometerUpdateDialogState extends ConsumerState<OdometerUpdateDialog> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentOdometer();
  }

  Future<void> _loadCurrentOdometer() async {
    final vehicleState = await ref.read(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;
    if (vehicle != null && mounted) {
      _controller.text = vehicle.currentOdometerKm.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final settings = ref.read(settingsProvider);
    final t = settings.t;

    final sanitized = InputSanitizers.sanitizeDigits(_controller.text.trim());
    final input = int.tryParse(sanitized);
    if (input == null || input < 0) {
      _showError(t('invalid_number'));
      return;
    }
    if (input > InputSanitizers.odometerMax) {
      _showError(t('odometer_max'));
      return;
    }

    setState(() => _isSubmitting = true);

    await ref.read(vehicleProvider.notifier).updateOdometer(input);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(settingsProvider);
    final t = settings.t;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.speed, color: colorScheme.primary),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              t('update'),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [
          InputSanitizers.digitsOnly,
          LengthLimitingTextInputFormatter(6), // Max 6 digits = 999,999
        ],
        decoration: InputDecoration(
          labelText: t('kilometers'),
          hintText: 'e.g. 15000',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.directions_car),
          suffixText: t('km'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(t('cancel')),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _onConfirm,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(t('save')),
        ),
      ],
    );
  }
}
