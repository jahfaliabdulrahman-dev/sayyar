import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/service_task_provider.dart';
import '../../../providers/settings_provider.dart';

/// ============================================================
/// Edit Task Dialog — Bilingual Name + Intervals
/// ============================================================
///
/// Allows editing:
///   - Task name (Arabic + English) for all tasks.
///   - Interval KM.
///   - Interval Months.
/// ============================================================
class EditTaskDialog extends ConsumerStatefulWidget {
  final dynamic task; // ServiceTask

  const EditTaskDialog({super.key, required this.task});

  @override
  ConsumerState<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends ConsumerState<EditTaskDialog> {
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _kmController;
  late final TextEditingController _monthsController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController(
      text: widget.task.displayNameAr ?? '',
    );
    _nameEnController = TextEditingController(
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
    _nameArController.dispose();
    _nameEnController.dispose();
    _kmController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    setState(() => _isSaving = true);

    final nameAr = _nameArController.text.trim();
    final nameEn = _nameEnController.text.trim();
    final kmText = _kmController.text.trim();
    final monthsText = _monthsController.text.trim();

    final newKm = kmText.isNotEmpty ? int.tryParse(kmText) : null;
    final newMonths = monthsText.isNotEmpty ? int.tryParse(monthsText) : null;

    await ref.read(serviceTaskProvider.notifier).updateTask(
          taskKey: widget.task.taskKey,
          displayNameEn: nameEn.isNotEmpty ? nameEn : null,
          displayNameAr: nameAr.isNotEmpty ? nameAr : null,
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
            // Task Name (Arabic)
            TextFormField(
              controller: _nameArController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: t('task_name_ar'),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Task Name (English)
            TextFormField(
              controller: _nameEnController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: t('task_name_en'),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Interval KM + Months (side by side, short labels)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _kmController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: t('km'),
                      border: const OutlineInputBorder(),
                      isDense: true,
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
                      labelText: t('months'),
                      border: const OutlineInputBorder(),
                      isDense: true,
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
