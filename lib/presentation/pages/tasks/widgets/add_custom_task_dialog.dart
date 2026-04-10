import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/service_task_provider.dart';

/// ============================================================
/// Add Custom Task Dialog
/// ============================================================
///
/// Allows the user to create a maintenance task not in the OEM
/// schedule (e.g., custom aftermarket parts, personal preferences).
///
/// Fields:
///   - Task Name (required).
///   - Interval KM (optional, but at least one interval required).
///   - Interval Months (optional, but at least one interval required).
///   - "Start from current odometer" toggle (baseline selection).
///
/// Validation:
///   At least one of Interval KM or Interval Months must be provided.
/// ============================================================
class AddCustomTaskDialog extends ConsumerStatefulWidget {
  const AddCustomTaskDialog({super.key});

  @override
  ConsumerState<AddCustomTaskDialog> createState() =>
      _AddCustomTaskDialogState();
}

class _AddCustomTaskDialogState extends ConsumerState<AddCustomTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _kmController = TextEditingController();
  final _monthsController = TextEditingController();
  bool _startFromCurrent = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _kmController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final name = _nameController.text.trim();
    final kmText = _kmController.text.trim();
    final monthsText = _monthsController.text.trim();

    final intervalKm = kmText.isNotEmpty ? int.tryParse(kmText) : null;
    final intervalMonths =
        monthsText.isNotEmpty ? int.tryParse(monthsText) : null;

    final success = await ref.read(serviceTaskProvider.notifier).addCustomTask(
          displayNameEn: name,
          intervalKm: intervalKm,
          intervalMonths: intervalMonths,
          startFromCurrentOdometer: _startFromCurrent,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create task'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // — Task Name —
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  hintText: 'e.g., Cabin Air Filter',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter a task name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // — Interval KM —
              TextFormField(
                controller: _kmController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Interval (KM)',
                  hintText: 'e.g., 15000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed_outlined),
                  suffixText: 'km',
                ),
                validator: (_) {
                  final kmEmpty = _kmController.text.trim().isEmpty;
                  final monthsEmpty = _monthsController.text.trim().isEmpty;
                  if (kmEmpty && monthsEmpty) {
                    return 'Provide at least one interval';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // — Interval Months —
              TextFormField(
                controller: _monthsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Interval (Months)',
                  hintText: 'e.g., 12',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_month_outlined),
                  suffixText: 'months',
                ),
              ),

              const Divider(),
              const SizedBox(height: 8),

              // — Baseline Toggle —
              SwitchListTile(
                title: const Text(
                  'Start from current odometer',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  _startFromCurrent
                      ? 'Tracking begins now (just serviced)'
                      : 'Tracking begins from factory',
                  style: const TextStyle(fontSize: 12),
                ),
                value: _startFromCurrent,
                onChanged: (v) => setState(() => _startFromCurrent = v),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _onSave,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
