import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/maintenance_record.dart';
import '../../../providers/maintenance_provider.dart';
import '../../../providers/service_task_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/vehicle_provider.dart';
import '../../../widgets/invoice_dialog_lifecycle.dart';

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

class _AddBatchRecordDialogState extends ConsumerState<AddBatchRecordDialog>
    with InvoiceDialogLifecycle {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _laborController = TextEditingController();
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
    initInvoiceLifecycle(initialPath: null);
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
    disposeInvoiceLifecycle();
    _odometerController.dispose();
    _laborController.dispose();
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

    // Read and distribute labor cost evenly across selected tasks.
    final laborText = _sanitizeDigits(_laborController.text.trim());
    final totalLaborCost = double.tryParse(laborText) ?? 0.0;
    final taskCount = _selectedTasks.length;
    final laborPerTask = taskCount > 0 ? totalLaborCost / taskCount : 0.0;

    final taskState = ref.read(serviceTaskProvider).valueOrNull;
    final isArabic = ref.read(settingsProvider).isRtl;
    if (taskState == null) {
      _showError('Tasks not loaded');
      setState(() => _isSubmitting = false);
      return;
    }

    final taskMap = <String, String>{};
    for (final task in taskState.allTasks) {
      taskMap[task.taskKey] =
          isArabic ? task.displayNameAr : task.displayNameEn;
    }

    final finalInvoicePath = finalizeInvoicePath();

    int savedCount = 0;
    int failedCount = 0;

    for (final taskKey in _selectedTasks) {
      final costText = _costControllers[taskKey]?.text.trim() ?? '';
      final sanitizedCost = _sanitizeDigits(costText);
      final partsCost = double.tryParse(sanitizedCost) ?? 0.0;

      final record = MaintenanceRecord(
        vehicleId: vehicleId,
        serviceType: taskMap[taskKey] ?? taskKey,
        notes: sharedNotes,
        odometerKm: odometer,
        totalCostSar: partsCost + laborPerTask,
        partsCostSar: partsCost,
        laborCostSar: laborPerTask,
        partsReplaced: [taskMap[taskKey] ?? taskKey],
        taskKeys: [taskKey],
        invoiceImagePath: finalInvoicePath,
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
    final settings = ref.watch(settingsProvider);
    final t = settings.t;
    final isArabic = settings.isRtl;

    return AlertDialog(
      title: Text(t('log_service')),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // — Date + Odometer (side by side) —
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Picker
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
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
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: t('service_date'),
                          border: const OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        child: Text(
                          '${_selectedDate.year}-'
                          '${_selectedDate.month.toString().padLeft(2, '0')}-'
                          '${_selectedDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Odometer
                  Expanded(
                    child: TextFormField(
                      controller: _odometerController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: t('odometer'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: const Icon(Icons.speed_outlined, size: 18),
                        suffixText: t('km'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return t('odometer');
                        }
                        if (int.tryParse(_sanitizeDigits(v.trim())) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
                const SizedBox(height: 12),

                // — Shared Labor Cost —
                TextFormField(
                  controller: _laborController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: '${t('labor_cost')} (SAR)',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: const Icon(Icons.engineering_outlined, size: 18),
                    suffixText: 'SAR',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // — Shared Notes (compact) —
                TextFormField(
                  controller: _notesController,
                minLines: 1,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: '${t('notes')} (${t('optional')})',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),

              // — Invoice Photo —
              buildInvoicePicker(),
              const SizedBox(height: 10),

              // — Task Checklist (scrollable, capped height) —
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t('select_services'),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: tasksAsync.when(
                      data: (state) {
                        final tasks = state.allTasks;
                        if (tasks.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(t('no_tasks_loaded')),
                          );
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: tasks.map((task) {
                            final controller = _costControllers.putIfAbsent(
                              task.taskKey,
                              () => TextEditingController(),
                            );
                            final isSelected = _selectedTasks.contains(task.taskKey);

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              CheckboxListTile(
                                title: Text(
                                  isArabic
                                      ? task.displayNameAr
                                      : t(task.displayNameEn),
                                ),
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
                                  visualDensity:
                                      const VisualDensity(horizontal: 0, vertical: -4),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 4,
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
                                      decoration: InputDecoration(
                                        labelText: '${t('part_cost')} (SAR)',
                                        border: const OutlineInputBorder(),
                                        suffixText: 'SAR',
                                        isDense: true,
                                      ).copyWith(contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      )),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return t('cost');
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
                          }).toList(),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      error: (e, st) => Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('Error: $e'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(t('cancel')),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _onSave,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(t('save_all')),
        ),
      ],
    );
  }
}
