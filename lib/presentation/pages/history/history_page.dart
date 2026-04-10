import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/maintenance_record.dart';
import '../../../presentation/providers/maintenance_provider.dart';
import '../../../presentation/providers/settings_provider.dart';
import 'widgets/add_record_dialog.dart';

/// ============================================================
/// History Page — Maintenance Records List
/// ============================================================
///
/// Accent-border card design with swipe-to-delete and explicit
/// edit/delete buttons. Localized via settingsProvider.
/// ============================================================
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceAsync = ref.watch(maintenanceProvider);
    final t = ref.watch(settingsProvider).t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('maintenance_history')),
      ),
      body: maintenanceAsync.when(
        data: (state) {
          final records = state.records;

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.build_circle_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('no_records'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('tap_to_log'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final record = records[index];
              return Dismissible(
                key: ValueKey(record.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _showDeleteConfirmation(context),
                onDismissed: (_) async {
                  await ref
                      .read(maintenanceProvider.notifier)
                      .deleteRecord(record.id);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                child: _HistoryCard(
                  record: record,
                  onEdit: () => _showEditRecordDialog(context, ref, record),
                  t: t,
                  isArabic: ref.watch(settingsProvider).isRtl,
                  onDelete: () async {
                    final confirmed =
                        await _showDeleteConfirmation(context);
                    if (confirmed == true && context.mounted) {
                      await ref
                          .read(maintenanceProvider.notifier)
                          .deleteRecord(record.id);
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(t('log_service')),
      ),
    );
  }

  static Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
          'Are you sure you want to delete this record? '
          'This will recalculate your upcoming maintenance tasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => const AddBatchRecordDialog(),
    );
  }

  static void _showEditRecordDialog(
    BuildContext context,
    WidgetRef ref,
    MaintenanceRecord record,
  ) {
    final costController = TextEditingController(
      text: record.totalCostSar.toStringAsFixed(2),
    );
    final odometerController = TextEditingController(
      text: record.odometerKm.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        DateTime selectedDate = record.serviceDate;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text('Edit: ${record.serviceType}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4,
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
                      '${selectedDate.year}-'
                      '${selectedDate.month.toString().padLeft(2, '0')}-'
                      '${selectedDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: odometerController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Odometer (km)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: costController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Cost (SAR)',
                      border: OutlineInputBorder(),
                      isDense: true,
                      suffixText: 'SAR',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final newOdometer =
                      int.tryParse(odometerController.text.trim()) ??
                          record.odometerKm;
                  final newCost =
                      double.tryParse(costController.text.trim()) ??
                          record.totalCostSar;

                  final updated = MaintenanceRecord(
                    id: record.id,
                    vehicleId: record.vehicleId,
                    serviceType: record.serviceType,
                    notes: record.notes,
                    odometerKm: newOdometer,
                    totalCostSar: newCost,
                    partsCostSar: newCost,
                    laborCostSar: record.laborCostSar,
                    partsReplaced: record.partsReplaced,
                    providerName: record.providerName,
                    serviceDate: selectedDate,
                    createdAt: selectedDate,
                    isSynced: record.isSynced,
                  );

                  await ref
                      .read(maintenanceProvider.notifier)
                      .updateRecord(updated);

                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Accent-border history card with inline edit/delete actions.
class _HistoryCard extends StatelessWidget {
  final MaintenanceRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(String) t;
  final bool isArabic;

  const _HistoryCard({
    required this.record,
    required this.onEdit,
    required this.onDelete,
    required this.t,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Accent border bar.
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.build,
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t(record.serviceType),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${record.serviceDate.toLocal().toString().split(' ')[0]}  \u00b7  ${record.odometerKm} ${t('km')}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          record.totalCostSar.toStringAsFixed(2),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          t('currency'),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: onEdit,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
