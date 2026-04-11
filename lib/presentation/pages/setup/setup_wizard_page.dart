import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/service_task.dart';
import '../../../domain/repositories/service_task_repository.dart' show TaskUpdatePayload;
import '../../providers/service_task_provider.dart';
import '../../providers/settings_provider.dart';
import '../home/home_root_page.dart';

/// ============================================================
/// Setup Wizard Page — Past Maintenance Records Only
/// ============================================================
///
/// Vehicle identity (make/model/year/odometer) is handled by
/// WelcomePage. This screen focuses exclusively on recording
/// which maintenance tasks were done previously, and at what
/// odometer reading.
///
/// A Skip button in the AppBar lets users bypass the wizard.
/// On Finish, task baselines and interval overrides are saved.
/// ============================================================
class SetupWizardPage extends ConsumerStatefulWidget {
  /// When true, this is the first run — skip navigates to dashboard.
  /// When false (re-opened from settings), skip just pops back.
  final bool isFirstRun;

  const SetupWizardPage({super.key, this.isFirstRun = false});

  @override
  ConsumerState<SetupWizardPage> createState() => _SetupWizardPageState();
}

class _SetupWizardPageState extends ConsumerState<SetupWizardPage> {
  /// Per-task controllers: baseline done_at_km.
  final Map<String, TextEditingController> _baselineControllers = {};
  /// Per-task controllers: intervalKm override.
  final Map<String, TextEditingController> _kmIntervalControllers = {};
  /// Per-task controllers: intervalMonths override.
  final Map<String, TextEditingController> _monthIntervalControllers = {};

  /// Set of taskKeys the user has toggled as "done previously".
  final Set<String> _selectedBaselines = {};

  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in _baselineControllers.values) c.dispose();
    for (final c in _kmIntervalControllers.values) c.dispose();
    for (final c in _monthIntervalControllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _onFinish() async {
    setState(() => _isSaving = true);

    // Batch-update all task settings (intervals + baselines).
    final updates = <String, TaskUpdatePayload>{};
    final taskState = ref.read(serviceTaskProvider).valueOrNull;
    if (taskState != null) {
      for (final task in taskState.allTasks) {
        final kmInterval = int.tryParse(
          _kmIntervalControllers[task.taskKey]?.text.trim() ?? '',
        );
        final monthInterval = int.tryParse(
          _monthIntervalControllers[task.taskKey]?.text.trim() ?? '',
        );
        final lastDoneKm = _selectedBaselines.contains(task.taskKey)
            ? int.tryParse(
                _baselineControllers[task.taskKey]?.text.trim() ?? '',
              )
            : null;

        // Only include tasks where something changed.
        if (kmInterval != null || monthInterval != null || lastDoneKm != null) {
          updates[task.taskKey] = TaskUpdatePayload(
            intervalKm: kmInterval,
            intervalMonths: monthInterval,
            lastDoneKm: lastDoneKm,
          );
        }
      }
    }
    if (updates.isNotEmpty) {
      await ref.read(serviceTaskProvider.notifier).batchUpdateTaskSettings(updates);
    }

    if (widget.isFirstRun) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeRootPage()),
          (route) => false,
        );
      }
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final t = settings.t;
    final tasksAsync = ref.watch(serviceTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('setup_wizard')),
        actions: [
          TextButton(
            onPressed: () {
              if (widget.isFirstRun) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeRootPage()),
                  (route) => false,
                );
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              t('skip_for_now'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // — Header —
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.history,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('past_maintenance'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t('mark_as_done'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // — Task List —
            tasksAsync.when(
              data: (state) {
                final tasks = state.allTasks;
                if (tasks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(t('no_tasks_loaded'))),
                  );
                }
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: tasks.map((task) {
                        return _TaskSetupTile(
                          task: task,
                          t: t,
                          isSelected: _selectedBaselines.contains(task.taskKey),
                          baselineController: _baselineControllers.putIfAbsent(
                            task.taskKey,
                            () => TextEditingController(
                              text: task.lastDoneKm?.toString() ?? '',
                            ),
                          ),
                          kmIntervalController: _kmIntervalControllers.putIfAbsent(
                            task.taskKey,
                            () => TextEditingController(
                              text: task.intervalKm?.toString() ?? '',
                            ),
                          ),
                          monthIntervalController:
                              _monthIntervalControllers.putIfAbsent(
                            task.taskKey,
                            () => TextEditingController(
                              text: task.intervalMonths?.toString() ?? '',
                            ),
                          ),
                          onToggle: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedBaselines.add(task.taskKey);
                              } else {
                                _selectedBaselines.remove(task.taskKey);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Error: $e')),
              ),
            ),
            const SizedBox(height: 20),

            // — Finish Button —
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _onFinish,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(t('finish_setup')),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// A compact task tile showing editable intervals + optional baseline.
class _TaskSetupTile extends StatelessWidget {
  final ServiceTask task;
  final String Function(String) t;
  final bool isSelected;
  final TextEditingController baselineController;
  final TextEditingController kmIntervalController;
  final TextEditingController monthIntervalController;
  final ValueChanged<bool?> onToggle;

  const _TaskSetupTile({
    required this.task,
    required this.t,
    required this.isSelected,
    required this.baselineController,
    required this.kmIntervalController,
    required this.monthIntervalController,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasKm = task.intervalKm != null;
    final hasMonths = task.intervalMonths != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task name + switch
          Row(
            children: [
              Expanded(
                child: Text(
                  t(task.displayNameEn),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 32,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Switch(
                    value: isSelected,
                    onChanged: onToggle,
                  ),
                ),
              ),
            ],
          ),

          // Editable interval fields (always visible)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                if (hasKm) ...[
                  Expanded(
                    child: TextFormField(
                      controller: kmIntervalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: t('interval_km'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixText: t('km'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
                if (hasKm && hasMonths) const SizedBox(width: 8),
                if (hasMonths) ...[
                  Expanded(
                    child: TextFormField(
                      controller: monthIntervalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: t('interval_months'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixText: t('months'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Baseline input (only when toggled ON)
          if (isSelected) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: TextFormField(
                controller: baselineController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: t('done_at_km'),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: const Icon(Icons.check_circle_outline, size: 18),
                  suffixText: t('km'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
