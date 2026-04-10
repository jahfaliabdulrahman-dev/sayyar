import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/providers/service_task_provider.dart';
import '../../../presentation/providers/settings_provider.dart';
import '../../../presentation/providers/vehicle_provider.dart';
import 'widgets/add_custom_task_dialog.dart';
import 'widgets/edit_task_dialog.dart';

/// ============================================================
/// Tasks Page — 3-Tier Service Task Management
/// ============================================================
///
/// Layout:
///   1. Live summary header (primary container with opacity).
///   2. Three sections, only shown if non-empty:
///      - Overdue Services (red).
///      - Upcoming Services (blue).
///      - Future Services (green).
///   3. Each task shows: name, interval, drift-based next due.
/// ============================================================
class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(serviceTaskProvider);
    final vehicleAsync = ref.watch(vehicleProvider);
    final t = ref.watch(settingsProvider).t;
    final isArabic = ref.watch(settingsProvider).isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('service_tasks')),
      ),
      body: tasksAsync.when(
        data: (state) {
          if (state.allTasks.isEmpty) {
            return const Center(
              child: Text('No service tasks yet.'),
            );
          }

          final currentOdometer = vehicleAsync.valueOrNull
                  ?.activeVehicle?.currentOdometerKm ??
              0;
          final overdueCount = state.overdueTasks.length;
          final upcomingCount = state.upcomingTasks.length;
          final futureCount = state.futureTasks.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // — Live Summary Header —
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      overdueCount > 0
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: overdueCount > 0
                          ? Colors.orange
                          : Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$overdueCount ${t('short_overdue')} \u2022 '
                        '$upcomingCount ${t('short_upcoming')} \u2022 '
                        '$futureCount ${t('short_future')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // — Section 1: Overdue Services —
              if (overdueCount > 0) ...[
                _SectionHeader(
                  title: t('overdue_services'),
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                  count: overdueCount,
                ),
                const SizedBox(height: 8),
                ...state.overdueTasks.map((task) {
                  final nextDue = state.getNextDue(task);
                  return _buildDeletableTask(
                    context: context,
                    ref: ref,
                    task: task,
                    tier: _TaskTier.overdue,
                    nextDueKm: nextDue.nextDueKm,
                    nextDueDate: nextDue.nextDueDate,
                    currentOdometer: currentOdometer,
                    t: t,
                    isArabic: isArabic,
                  );
                }),
                const SizedBox(height: 12),
              ],

              // — Section 2: Upcoming Services —
              if (upcomingCount > 0) ...[
                _SectionHeader(
                  title: t('upcoming_services'),
                  icon: Icons.schedule_outlined,
                  color: Colors.blue,
                  count: upcomingCount,
                ),
                const SizedBox(height: 8),
                ...state.upcomingTasks.map((task) {
                  final nextDue = state.getNextDue(task);
                  return _buildDeletableTask(
                    context: context,
                    ref: ref,
                    task: task,
                    tier: _TaskTier.upcoming,
                    nextDueKm: nextDue.nextDueKm,
                    nextDueDate: nextDue.nextDueDate,
                    currentOdometer: currentOdometer,
                    t: t,
                    isArabic: isArabic,
                  );
                }),
                const SizedBox(height: 12),
              ],

              // — Section 3: Future Services —
              if (futureCount > 0) ...[
                _SectionHeader(
                  title: t('future_services'),
                  icon: Icons.event_outlined,
                  color: Colors.green,
                  count: futureCount,
                ),
                const SizedBox(height: 8),
                ...state.futureTasks.map((task) {
                  final nextDue = state.getNextDue(task);
                  return _buildDeletableTask(
                    context: context,
                    ref: ref,
                    task: task,
                    tier: _TaskTier.future,
                    nextDueKm: nextDue.nextDueKm,
                    nextDueDate: nextDue.nextDueDate,
                    currentOdometer: currentOdometer,
                    t: t,
                    isArabic: isArabic,
                  );
                }),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddCustomTaskDialog(),
        ),
        icon: const Icon(Icons.add_task),
        label: Text(t('add_custom_task')),
      ),
    );
  }

  /// Wraps a task item in a Dismissible for swipe-to-delete.
  static Widget _buildDeletableTask({
    required BuildContext context,
    required WidgetRef ref,
    required dynamic task,
    required _TaskTier tier,
    int? nextDueKm,
    DateTime? nextDueDate,
    required int currentOdometer,
    required String Function(String) t,
    required bool isArabic,
  }) {
    return Dismissible(
      key: ValueKey(task.taskKey),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t('delete_task_title')),
            content: Text(t('delete_task_body')),
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
      },
      onDismissed: (_) async {
        await ref.read(serviceTaskProvider.notifier).deleteTask(task.taskKey);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _TaskListItem(
          task: task,
          tier: tier,
          nextDueKm: nextDueKm,
          nextDueDate: nextDueDate,
          currentOdometerKm: currentOdometer,
          t: t,
          isArabic: isArabic,
          onEdit: () {
            showDialog(
              context: context,
              builder: (_) => EditTaskDialog(task: task),
            );
          },
        ),
      ),
    );
  }
}

/// Section header with icon, title, and count badge.
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

enum _TaskTier { overdue, upcoming, future }

/// Single task list tile — color-coded by tier.
class _TaskListItem extends StatelessWidget {
  final dynamic task;
  final _TaskTier tier;
  final int? nextDueKm;
  final DateTime? nextDueDate;
  final int currentOdometerKm;
  final String Function(String) t;
  final bool isArabic;
  final VoidCallback onEdit;

  const _TaskListItem({
    required this.task,
    required this.tier,
    this.nextDueKm,
    this.nextDueDate,
    required this.currentOdometerKm,
    required this.t,
    required this.isArabic,
    required this.onEdit,
  });

  Color _tierColor(BuildContext context) {
    switch (tier) {
      case _TaskTier.overdue:
        return Colors.orange;
      case _TaskTier.upcoming:
        return Colors.blue;
      case _TaskTier.future:
        return Colors.green;
    }
  }

  IconData _tierIcon() {
    switch (tier) {
      case _TaskTier.overdue:
        return Icons.warning_amber_rounded;
      case _TaskTier.upcoming:
        return Icons.schedule_outlined;
      case _TaskTier.future:
        return Icons.check_circle_outline;
    }
  }

  String _tierLabel(String Function(String) t) {
    switch (tier) {
      case _TaskTier.overdue:
        return t('overdue');
      case _TaskTier.upcoming:
        return t('soon');
      case _TaskTier.future:
        return t('ok');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(_tierIcon(), color: color),
        title: Text(
          isArabic ? (task.displayNameAr ?? task.displayNameEn) : task.displayNameEn,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.intervalKm != null || task.intervalMonths != null)
              Text(
                _buildIntervalHint(
                  task.intervalKm,
                  task.intervalMonths,
                  t,
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            if (nextDueKm != null || nextDueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _buildDriftHint(nextDueKm, nextDueDate),
                  style: TextStyle(
                    color: tier == _TaskTier.overdue
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (nextDueKm != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${t('remaining')}: ${math.max(0, nextDueKm! - currentOdometerKm)} ${t('km')}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _tierLabel(t),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildIntervalHint(int? km, int? months, String Function(String) t) {
    final parts = <String>[];
    if (km != null) parts.add('$km ${t('km')}');
    if (months != null) parts.add('$months ${t('months')}');
    return '${t('every_km')} ${parts.join(' / ')}';
  }

  /// Dynamic drift text:
  ///   - Overdue, exceededBy == 0: "Due Now" (red).
  ///   - Overdue, exceededBy > 0: "Overdue by X km" (red).
  ///   - Upcoming/Future: "Next: X km or YYYY-MM-DD".
  String _buildDriftHint(int? km, DateTime? date) {
    if (tier == _TaskTier.overdue && km != null) {
      final exceededBy = currentOdometerKm - km;
      if (exceededBy == 0) {
        return t('due_now');
      }
      if (exceededBy > 0) {
        return '${t('overdue_by')} $exceededBy ${t('km')}';
      }
    }

    final parts = <String>[];
    if (km != null) parts.add('$km ${t('km')}');
    if (date != null) {
      parts.add(
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      );
    }
    return '${t('next')}: ${parts.join(' / ')}';
  }
}
