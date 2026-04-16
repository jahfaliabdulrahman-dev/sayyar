import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/maintenance_record.dart';
import '../../../providers/maintenance_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/invoice_dialog_lifecycle.dart';

/// ============================================================
/// Edit Record Dialog — Metadata-Only MVP
/// ============================================================
///
/// Allows editing only the metadata of a completed record:
///   - Service date
///   - Odometer reading
///   - Notes
///
/// DESIGN CONSTRAINT (Baselines Paradox):
///   The task list (partsReplaced) is NOT editable in this version.
///   Changing which tasks were performed in a historical record would
///   require recalculating all downstream baseline drifts, which is
///   error-prone and risks data corruption. This constraint will be
///   lifted when a full audit-trail engine is built (Phase 9+).
/// ============================================================
class EditRecordDialog extends ConsumerStatefulWidget {
  final MaintenanceRecord record;

  const EditRecordDialog({super.key, required this.record});

  @override
  ConsumerState<EditRecordDialog> createState() => _EditRecordDialogState();
}

class _EditRecordDialogState extends ConsumerState<EditRecordDialog>
    with InvoiceDialogLifecycle {
  late final TextEditingController _odometerController;
  late final TextEditingController _partsCostController;
  late final TextEditingController _laborCostController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    initInvoiceLifecycle(initialPath: widget.record.invoiceImagePath);
    _odometerController = TextEditingController(
      text: widget.record.odometerKm.toString(),
    );
    _partsCostController = TextEditingController(
      text: widget.record.partsCostSar.toStringAsFixed(2),
    );
    _laborCostController = TextEditingController(
      text: widget.record.laborCostSar.toStringAsFixed(2),
    );
    _notesController = TextEditingController(
      text: widget.record.notes ?? '',
    );
    _selectedDate = widget.record.serviceDate;
  }

  @override
  void dispose() {
    disposeInvoiceLifecycle();
    _odometerController.dispose();
    _partsCostController.dispose();
    _laborCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    setState(() => _isSaving = true);

    final newOdometer =
        int.tryParse(_odometerController.text.trim()) ?? widget.record.odometerKm;
    final newPartsCost =
        double.tryParse(_partsCostController.text.trim()) ??
            widget.record.partsCostSar;
    final newLaborCost =
        double.tryParse(_laborCostController.text.trim()) ??
            widget.record.laborCostSar;
    final newNotes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    final finalInvoicePath = finalizeInvoicePath();

    debugPrint('[INVOICE TRACE] EditDialog — transientImagePath: $transientImagePath');
    debugPrint('[INVOICE TRACE] EditDialog — finalPath from finalizeInvoicePath: $finalInvoicePath');

    final updated = MaintenanceRecord(
      id: widget.record.id,
      vehicleId: widget.record.vehicleId,
      serviceType: widget.record.serviceType,
      notes: newNotes,
      odometerKm: newOdometer,
      totalCostSar: newPartsCost + newLaborCost,
      partsCostSar: newPartsCost,
      laborCostSar: newLaborCost,
      partsReplaced: widget.record.partsReplaced,
      taskKeys: widget.record.taskKeys,
      providerName: widget.record.providerName,
      invoiceImagePath: finalInvoicePath,
      serviceDate: _selectedDate,
      createdAt: widget.record.createdAt,
      isSynced: widget.record.isSynced,
    );

    debugPrint('[INVOICE TRACE] EditDialog — record.invoiceImagePath: ${updated.invoiceImagePath}');

    await ref.read(maintenanceProvider.notifier).updateRecord(updated);

    // Force provider refresh so RecordDetailPage gets the new path
    ref.invalidate(maintenanceProvider);

    // Old image cleanup AFTER Isar save AND provider invalidation
    cleanupOldImage();

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final t = settings.t;

    return AlertDialog(
      title: Text(t('edit_record')),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // — Service Type (read-only) —
            InputDecorator(
              decoration: InputDecoration(
                labelText: t('service_type'),
                border: const OutlineInputBorder(),
                isDense: true,
                prefixIcon: const Icon(Icons.build_outlined, size: 18),
              ),
              child: Text(
                t(widget.record.serviceType),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),

            // — Date + Odometer (side by side) —
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _odometerController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: t('odometer'),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: const Icon(Icons.speed_outlined, size: 18),
                      suffixText: t('km'),
                      suffixStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // — Parts Cost + Labor Cost (side by side) —
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _partsCostController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: t('part_cost'),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixText: 'SAR',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _laborCostController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: t('labor_cost'),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixText: 'SAR',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // — Notes —
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(t('cancel')),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _onSave,
          child: _isSaving
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
