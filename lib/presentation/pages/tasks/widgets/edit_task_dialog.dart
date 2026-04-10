import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/service_task_provider.dart';
import '../../../providers/settings_provider.dart';

/// ============================================================
/// Edit Task Dialog — Interval & Name Mutation
/// ============================================================
///
/// Allows editing:
///   - Task name (only for custom tasks, not OEM).
///   - Interval KM.
///   - Interval Months.
///
/// OEM tasks (taskKey not starting with 'custom_') have the name
/// field set to read-only to prevent accidental OEM data corruption.
/// ============================================================
class EditTaskDialog extends ConsumerStatefulWidget {
  final dynamic task; // ServiceTask

  const EditTaskDialog({super.key, required this.task});

  @override
  ConsumerState<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends ConsumerState<EditTaskDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _kmController;
  late final TextEditingController _monthsController;
  bool _isSaving = false;

  bool get _isCustom => widget.task.taskKey.startsWith('custom_');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.task.displayNameEn,
    );
    _kmController = TextEditingController(
      text: widget.task.intervalKm?.toString() ?? '',
    );
    _monthsController = TextEditingController(
      text: widget.task.intervalMonths?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _kmController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    setState(() => _isSaving = true);

    final nameText = _nameController.text.trim();
    final kmText = _kmController.text.trim();
    final monthsText = _monthsController.text.trim();

    final newKm = kmText.isNotEmpty ? int.tryParse(kmText) : null;
    final newMonths = monthsText.isNotEmpty ? int.tryParse(monthsText) : null;

    await ref.read(serviceTaskProvider.notifier).updateTask(
          taskKey: widget.task.taskKey,
          displayNameEn: _isCustom && nameText.isNotEmpty ? nameText : null,
          displayNameAr: _isCustom && nameText.isNotEmpty ? nameText : null,
          intervalKm: newKm,
          intervalMonths: newMonths,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final t = settings.t;

    return AlertDialog(
      title: Text(t('edit_task')),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Task Name (read-only for OEM, editable for custom)
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              readOnly: !_isCustom,
              decoration: InputDecoration(
                labelText: t('task_name'),
                border: const OutlineInputBorder(),
                isDense: true,
                prefixIcon: const Icon(Icons.build_outlined, size: 18),
                suffixIcon: !_isCustom
                    ? const Icon(Icons.lock_outline, size: 16)
                    : null,
              ),
            ),
            if (!_isCustom) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'OEM tasks cannot be renamed',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // Interval KM + Months (side by side)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _kmController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: t('interval_km'),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixText: t('km'),
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
                    controller: _monthsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: t('interval_months'),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixText: t('months'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
