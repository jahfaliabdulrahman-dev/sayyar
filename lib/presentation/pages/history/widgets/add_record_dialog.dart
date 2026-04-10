import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/maintenance_record.dart';
import '../../../providers/maintenance_provider.dart';
import '../../../providers/service_task_provider.dart';
import '../../../providers/vehicle_provider.dart';

/// ============================================================
/// Add Batch Record Dialog
/// ============================================================
///
/// Multi-select maintenance logging form. Instead of adding one
/// service at a time, the user selects multiple tasks from a
/// checklist and logs them all at once.
///
/// Layout:
///   1. Shared Odometer field (pre-filled with current reading).
///   2. Shared Notes field (optional, applied to all records).
///   3. Dynamic checklist of service tasks — each task has:
///       - Checkbox to select it.
///       - Cost TextField (shown only when checked).
///
/// On Save:
///   - Loops through all checked tasks.
///   - Creates one MaintenanceRecord per task.
///   - Uses task.displayNameEn as serviceType (human-readable).
///   - Calls addRecord + markTaskCompleted for each.
///   - All operations are wrapped in try/catch with debug logging.
/// ============================================================
class AddBatchRecordDialog extends ConsumerStatefulWidget {
  const AddBatchRecordDialog({super.key});

  @override
  ConsumerState<AddBatchRecordDialog> createState() =>
      _AddBatchRecordDialogState();
}

class _AddBatchRecordDialogState extends ConsumerState<AddBatchRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();

  /// Maps taskKey -> cost controller for each task in the checklist.
  final Map<String, TextEditingController> _costControllers = {};

  /// Set of selected taskKeys (checked items).
  final Set<String> _selectedTasks = {};

  /// Selected service date — defaults to today, can be backdated.
  DateTime _selectedDate = DateTime.now();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _preFillOdometer();
  }

  /// Pre-fills the odometer with current vehicle reading.
  Future<void> _preFillOdometer() async {
    final vehicleState = await ref.read(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;
    if (vehicle != null && mounted) {
      _odometerController.text = vehicle.currentOdometerKm.toString();
    }
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _notesController.dispose();
    for (final c in _costControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Arabic-Indic digit sanitization map.
  static final _arabicDigits = {
    '\u0660': '0', '\u0661': '1', '\u0662': '2',
    '\u0663': '3', '\u0664': '4', '\u0665': '5',
    '\u0666': '6', '\u0667': '7', '\u0668': '8',
    '\u0669': '9',
  };

  /// Converts Arabic-Indic numerals to ASCII digits.
  String _sanitizeDigits(String input) {
    for (final entry in _arabicDigits.entries) {
      input = input.replaceAll(entry.key, entry.value);
    }
    return input;
  }

  /// Validates and saves all selected tasks as individual records.
  ///
  /// FAT-FINGER PROTECTION:
  ///   If the entered odometer exceeds the current vehicle odometer,
  ///   a confirmation dialog is shown before proceeding. The user can:
  ///   - Cancel: returns to form to correct the value.
  ///   - Update & Save: updates vehicle odometer, then saves records.
  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicleState = await ref.read(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;
    if (vehicle == null) {
      _showError('No vehicle loaded');
      return;
    }

    if (_selectedTasks.isEmpty) {
      _showError('Select at least one service');
      return;
    }

    final sanitizedOdometer = _sanitizeDigits(
      _odometerController.text.trim().replaceAll(',', ''),
    );
    final odometer = int.tryParse(sanitizedOdometer) ?? 0;

    // FAT-FINGER CHECK: entered value exceeds current odometer.
    if (odometer > vehicle.currentOdometerKm && mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Odometer Mismatch'),
          content: Text(
            'You entered $odometer km, which is higher than the '
            'current vehicle odometer (${vehicle.currentOdometerKm} km).\n\n'
            'Is this correct?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Update & Save'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) {
        setState(() => _isSubmitting = false);
        return;
      }

      // Update vehicle odometer before saving records.
      await ref.read(vehicleProvider.notifier).updateOdometer(odometer);
    }

    // Proceed with save.
    setState(() => _isSubmitting = true);
    await _performSave(vehicle.id, odometer);
  }

  /// Core save logic: iterates selected tasks and persists records.
  Future<void> _performSave(int vehicleId, int odometer) async {
    final sharedNotes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    final taskState = ref.read(serviceTaskProvider).valueOrNull;
    if (taskState == null) {
      _showError('Tasks not loaded');
      setState(() => _isSubmitting = false);
      return;
    }

    final taskMap = <String, String>{};
    for (final t in taskState.allTasks) {
      taskMap[t.taskKey] = t.displayNameEn;
    }

    int savedCount = 0;
    int failedCount = 0;

    for (final taskKey in _selectedTasks) {
      final costText = _costControllers[taskKey]?.text.trim() ?? '';
      final sanitizedCost = _sanitizeDigits(costText);
      final cost = double.tryParse(sanitizedCost) ?? 0.0;

      final record = MaintenanceRecord(
        vehicleId: vehicleId,
        serviceType: taskMap[taskKey] ?? taskKey,
        notes: sharedNotes,
        odometerKm: odometer,
        totalCostSar: cost,
        partsCostSar: cost,
        laborCostSar: 0.0,
        partsReplaced: [taskMap[taskKey] ?? taskKey],
        serviceDate: _selectedDate,
        createdAt: _selectedDate,
      );

      try {
        final success = await ref
            .read(maintenanceProvider.notifier)
            .addRecord(record);

        if (success) {
          await ref
              .read(serviceTaskProvider.notifier)
              .markTaskCompleted(taskKey: taskKey, doneAtKm: odometer);
          savedCount++;
        } else {
          failedCount++;
        }
      } catch (e, stackTrace) {
        dev.log(
          'CRITICAL SAVE ERROR: taskKey=$taskKey, error=$e\n$stackTrace',
          name: 'AddBatchRecordDialog',
          error: e,
          stackTrace: stackTrace,
        );
        failedCount++;
      }
    }

    if (!mounted) return;

    if (failedCount == 0 && savedCount > 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _isSubmitting = false);
      final message = savedCount > 0
          ? 'Saved $savedCount, $failedCount failed'
          : 'All $failedCount records failed';
      _showError(message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(serviceTaskProvider);

    return AlertDialog(
      title: const Text('Log Maintenance'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // — Service Date Picker —
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    leading: const Icon(Icons.calendar_today_outlined, size: 20),
                    title: Text(
                      'Service Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    subtitle: Text(
                      '${_selectedDate.year}-'
                      '${_selectedDate.month.toString().padLeft(2, '0')}-'
                      '${_selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // — Shared Odometer —
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: TextFormField(
                    controller: _odometerController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Odometer',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.speed_outlined),
                    suffixText: 'km',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter odometer';
                    }
                    if (int.tryParse(_sanitizeDigits(v.trim())) == null) {
                      return 'Invalid number';
                    }
                    return null;
                  },
                  ),
                ),
                const SizedBox(height: 16),

                // — Shared Notes —
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),

                // — Task Checklist —
                tasksAsync.when(
                  data: (state) {
                    final tasks = state.allTasks;
                    if (tasks.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No service tasks loaded.'),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Services',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        ...tasks.map((task) {
                          final controller = _costControllers.putIfAbsent(
                            task.taskKey,
                            () => TextEditingController(),
                          );
                          final isSelected = _selectedTasks.contains(task.taskKey);

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CheckboxListTile(
                                title: Text(task.displayNameEn),
                                value: isSelected,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedTasks.add(task.taskKey);
                                    } else {
                                      _selectedTasks.remove(task.taskKey);
                                    }
                                  });
                                },
                                dense: true,
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 8,
                                  ),
                                  child: TextFormField(
                                    controller: controller,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}'),
                                      ),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Cost (SAR)',
                                      border: OutlineInputBorder(),
                                      suffixText: 'SAR',
                                      isDense: true,
                                    ).copyWith(contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    )),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Enter cost';
                                      }
                                      if (double.tryParse(
                                              _sanitizeDigits(v.trim())) ==
                                          null) {
                                        return 'Invalid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                            ],
                          );
                        }),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, st) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading tasks: $e'),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
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
              : const Text('Save All'),
        ),
      ],
    );
  }
}
