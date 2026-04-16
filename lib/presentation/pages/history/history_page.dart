import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/maintenance_record.dart';
import '../../../data/models/service_task.dart';
import '../../../presentation/providers/maintenance_provider.dart';
import '../../../presentation/providers/service_task_provider.dart';
import '../../../presentation/providers/settings_provider.dart';
import 'record_detail_page.dart';
import 'widgets/add_record_dialog.dart';
import 'widgets/edit_record_dialog.dart';

/// Resolves the display name for a record's service type.
/// Uses taskKey lookup first (dynamic), falls back to stored name.
/// Bilingual-aware: returns Arabic or English based on locale.
String resolveServiceName(
  MaintenanceRecord record,
  List<ServiceTask> allTasks,
  String Function(String) t, {
  bool isArabic = false,
}) {
  if (record.taskKeys != null && record.taskKeys!.isNotEmpty) {
    final taskKey = record.taskKeys!.first;
    final match = allTasks.where((task) => task.taskKey == taskKey);
    if (match.isNotEmpty) {
      final task = match.first;
      return isArabic ? task.displayNameAr : t(task.displayNameEn);
    }
  }
  return t(record.serviceType);
}

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
    final tasksAsync = ref.watch(serviceTaskProvider);
    final allTasks = tasksAsync.valueOrNull?.allTasks ?? [];
    final settings = ref.watch(settingsProvider);
    final t = settings.t;
    final isArabic = settings.isRtl;

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
                confirmDismiss: (_) => _showDeleteConfirmation(context, ref),
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
                  resolvedName: resolveServiceName(record, allTasks, t, isArabic: isArabic),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecordDetailPage(
                          recordId: record.id,
                          initialRecord: record,
                        ),
                      ),
                    );
                  },
                  onEdit: () {
                    showDialog(
                      context: context,
                      builder: (_) => EditRecordDialog(record: record),
                    );
                  },
                  t: t,
                  isArabic: ref.watch(settingsProvider).isRtl,
                  onDelete: () async {
                    final confirmed =
                        await _showDeleteConfirmation(context, ref);
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
        heroTag: null, // Prevents Hero tag collision with TasksPage FAB in IndexedStack
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(t('log_service')),
      ),
    );
  }

  static Future<bool?> _showDeleteConfirmation(
      BuildContext context, WidgetRef ref) {
    final t = ref.read(settingsProvider).t;
    return showDialog<bool>(
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
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(t('delete')),
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

}

/// Accent-border history card with tap-to-detail + edit/delete actions.
class _HistoryCard extends StatelessWidget {
  final MaintenanceRecord record;
  final String resolvedName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(String) t;
  final bool isArabic;

  const _HistoryCard({
    required this.record,
    required this.resolvedName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.t,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                            resolvedName,
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
      ),
    );
  }
}
