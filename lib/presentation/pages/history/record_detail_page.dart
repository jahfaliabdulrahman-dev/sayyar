import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/maintenance_record.dart';
import '../../../data/services/local_invoice_storage_service.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/service_task_provider.dart';
import '../../providers/settings_provider.dart';
import 'history_page.dart' show resolveServiceName;
import 'widgets/edit_record_dialog.dart';
import '../../widgets/invoice_image_picker_widget.dart';

/// ============================================================
/// Record Detail Page — View / Edit / Delete
/// ============================================================
///
/// Read-only view of a single maintenance record with edit and
/// delete actions in the AppBar.
/// ============================================================
class RecordDetailPage extends ConsumerWidget {
  final int recordId;
  final MaintenanceRecord initialRecord;

  const RecordDetailPage({
    super.key,
    required this.recordId,
    required this.initialRecord,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final t = settings.t;
    final colorScheme = Theme.of(context).colorScheme;
    final allTasks = ref.watch(serviceTaskProvider).valueOrNull?.allTasks ?? [];
    final isArabic = settings.isRtl;

    // Watch the provider for live state — picks up changes after edit
    final maintenanceAsync = ref.watch(maintenanceProvider);

    // Find the latest version of this record from provider state
    final record = maintenanceAsync.valueOrNull?.records
            .firstWhere((r) => r.id == recordId, orElse: () => initialRecord) ??
        initialRecord;

    final resolvedName = resolveServiceName(record, allTasks, t, isArabic: isArabic);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('record_details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: t('edit_record'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => EditRecordDialog(record: record),
              ).then((_) {
                // Refresh the page by popping and letting history rebuild.
                if (context.mounted) Navigator.of(context).pop();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            tooltip: t('delete'),
            onPressed: () => _confirmDelete(context, ref, record),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // — Service Type Header —
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.build,
                        size: 24,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resolvedName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${record.serviceDate.year}-'
                            '${record.serviceDate.month.toString().padLeft(2, '0')}-'
                            '${record.serviceDate.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // — Stats Row —
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.speed_outlined,
                    label: t('odometer'),
                    value: '${record.odometerKm} ${t('km')}',
                    colorScheme: colorScheme,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.account_balance_wallet_outlined,
                    label: t('total_cost'),
                    value: '${record.totalCostSar.toStringAsFixed(2)} ${t('currency')}',
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // — Cost Breakdown —
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('cost'),
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: t('cost'),
                      value: '${record.partsCostSar.toStringAsFixed(2)} ${t('currency')}',
                    ),
                    const Divider(height: 16),
                    _InfoRow(
                      label: t('labor_cost'),
                      value: '${record.laborCostSar.toStringAsFixed(2)} ${t('currency')}',
                    ),
                    const Divider(height: 16),
                    _InfoRow(
                      label: t('total_cost'),
                      value: '${record.totalCostSar.toStringAsFixed(2)} ${t('currency')}',
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // — Services Performed —
            if (record.partsReplaced != null && record.partsReplaced!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('services_performed'),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ...record.partsReplaced!.map(
                        (part) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 18, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  t(part),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

              // — Notes —
            if (record.notes != null && record.notes!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('notes'),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // — Invoice Image —
            if (record.invoiceImagePath != null) ...[
              Builder(
                builder: (context) {
                  debugPrint('[INVOICE DETAIL] record.invoiceImagePath: ${record.invoiceImagePath}');
                  return const SizedBox.shrink();
                },
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => InvoiceFullscreenViewer(
                        imagePath: record.invoiceImagePath!,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Invoice', // TODO: t('invoice')
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.fullscreen,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder(
                        future: LocalInvoiceStorageService()
                            .resolveInvoiceFile(record.invoiceImagePath),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              ),
                            );
                          }
                          final file = snapshot.data;
                          if (file == null) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    color: colorScheme.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Image not found',
                                    style: TextStyle(
                                        color: colorScheme.error),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Image(
                            image: ResizeImage(
                              FileImage(file),
                              width: 1080, // Max decode width — prevents OOM on 12MP+ photos
                            ),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MaintenanceRecord record) {
    final t = ref.read(settingsProvider).t;

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('delete_confirm_title')),
        content: Text(t('delete_confirm_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop(true);
              await ref
                  .read(maintenanceProvider.notifier)
                  .deleteRecord(record.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(t('delete')),
          ),
        ],
      ),
    );
  }
}

/// Compact stat card for the detail page.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label-value row for cost breakdown.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
