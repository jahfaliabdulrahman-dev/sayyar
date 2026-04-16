import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/maintenance_record.dart';
import '../../../data/models/service_task.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/service_task_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../home/home_root_page.dart';

/// ============================================================
/// Setup Wizard — 2-Step Architecture (No Ghost Data)
/// ============================================================
///
/// Step 1: Task Configuration — enable/disable tasks, edit intervals.
/// Step 2: Historical Logging — real MaintenanceRecords for each task.
///
/// CRITICAL: The wizard creates actual MaintenanceRecord entries
/// through maintenanceProvider.addRecord(), not phantom lastDoneKm
/// writes. This feeds the Z-Score cost predictor with real data.
/// ============================================================

/// Holds user input for a single task's historical record.
class _TaskHistoryEntry {
  final TextEditingController odometer;
  final TextEditingController partsCost;
  final TextEditingController laborCost;

  _TaskHistoryEntry()
      : odometer = TextEditingController(),
        partsCost = TextEditingController(),
        laborCost = TextEditingController();

  void dispose() {
    odometer.dispose();
    partsCost.dispose();
    laborCost.dispose();
  }

  bool get hasData =>
      odometer.text.trim().isNotEmpty ||
      partsCost.text.trim().isNotEmpty ||
      laborCost.text.trim().isNotEmpty;
}

class SetupWizardPage extends ConsumerStatefulWidget {
  final bool isFirstRun;

  const SetupWizardPage({super.key, this.isFirstRun = false});

  @override
  ConsumerState<SetupWizardPage> createState() => _SetupWizardPageState();
}

class _SetupWizardPageState extends ConsumerState<SetupWizardPage> {
  final _pageController = PageController();
  int _currentStep = 0;

  // — Step 1 State: Task Configuration —
  /// Which taskKeys are enabled (checked).
  final Set<String> _enabledTaskKeys = {};

  /// Per-task intervalKm override controllers.
  final Map<String, TextEditingController> _kmControllers = {};

  /// Per-task intervalMonths override controllers.
  final Map<String, TextEditingController> _monthControllers = {};

  // — Step 2 State: Historical Logging —
  /// Per-task history entry (odometer, parts cost, labor cost).
  final Map<String, _TaskHistoryEntry> _historyEntries = {};

  bool _isSaving = false;
  bool _step1Initialized = false;

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _kmControllers.values) c.dispose();
    for (final c in _monthControllers.values) c.dispose();
    for (final e in _historyEntries.values) e.dispose();
    super.dispose();
  }

  /// Pre-populate Step 1 from existing seeded tasks.
  /// All tasks start UNCHECKED — user selects which ones to track.
  void _initStep1(List<ServiceTask> tasks) {
    if (_step1Initialized) return;
    _step1Initialized = true;

    for (final task in tasks) {
      // Do NOT enable by default — user must select.
      _kmControllers[task.taskKey] = TextEditingController(
        text: task.intervalKm?.toString() ?? '',
      );
      _monthControllers[task.taskKey] = TextEditingController(
        text: task.intervalMonths?.toString() ?? '',
      );
    }
  }

  void _goToStep2() {
    // Build history entries for enabled tasks.
    _historyEntries.clear();
    final taskState = ref.read(serviceTaskProvider).valueOrNull;
    if (taskState != null) {
      for (final task in taskState.allTasks) {
        if (_enabledTaskKeys.contains(task.taskKey)) {
          _historyEntries.putIfAbsent(task.taskKey, () => _TaskHistoryEntry());
        }
      }
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToStep1() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onFinish() async {
    // STEP A: Dismiss keyboard immediately to prevent UI thread deadlock
    // (InputMethodManager ANR / Signal 3 when keyboard animation overlaps I/O)
    FocusManager.instance.primaryFocus?.unfocus();

    // STEP B: Animation buffer — let keyboard drop clear the Main Thread queue
    // before starting heavy Isar write operations
    await Future.delayed(const Duration(milliseconds: 150));

    setState(() => _isSaving = true);

    final vehicleState = await ref.read(vehicleProvider.future);
    final vehicle = vehicleState.activeVehicle;
    if (vehicle == null) {
      setState(() => _isSaving = false);
      return;
    }

    final now = DateTime.now();
    final taskState = ref.read(serviceTaskProvider).valueOrNull;
    final tasks = taskState?.allTasks ?? [];

    // 1. Create real MaintenanceRecords for tasks with history data.
    for (final entry in _historyEntries.entries) {
      final taskKey = entry.key;
      final history = entry.value;

      if (!history.hasData) continue;

      final odometer = int.tryParse(history.odometer.text.trim());
      if (odometer == null) continue;

      final partsCost = double.tryParse(history.partsCost.text.trim()) ?? 0.0;
      final laborCost = double.tryParse(history.laborCost.text.trim()) ?? 0.0;

      // Find task display name.
      final task = tasks.where((t) => t.taskKey == taskKey).firstOrNull;
      final serviceName = task?.displayNameEn ?? taskKey;

      final record = MaintenanceRecord(
        vehicleId: vehicle.id,
        serviceType: serviceName,
        odometerKm: odometer,
        totalCostSar: partsCost + laborCost,
        partsCostSar: partsCost,
        laborCostSar: laborCost,
        partsReplaced: [serviceName],
        taskKeys: [taskKey],
        serviceDate: now,
        createdAt: now,
        notes: 'Imported via Setup Wizard',
      );

      await ref.read(maintenanceProvider.notifier).addRecord(record);
    }

    // 2. Batch-update task intervals for enabled tasks.
    final taskRepo = ref.read(serviceTaskProvider.notifier);
    for (final taskKey in _enabledTaskKeys) {
      final kmText = _kmControllers[taskKey]?.text.trim();
      final monthText = _monthControllers[taskKey]?.text.trim();
      final kmInterval = kmText != null && kmText.isNotEmpty
          ? int.tryParse(kmText)
          : null;
      final monthInterval = monthText != null && monthText.isNotEmpty
          ? int.tryParse(monthText)
          : null;

      if (kmInterval != null || monthInterval != null) {
        await taskRepo.updateTask(
          taskKey: taskKey,
          intervalKm: kmInterval,
          intervalMonths: monthInterval,
        );
      }
    }

    // 3. Refresh all providers.
    ref.invalidate(serviceTaskProvider);
    ref.invalidate(maintenanceProvider);

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
      body: tasksAsync.when(
        data: (state) {
          final tasks = state.allTasks;
          _initStep1(tasks);

          return Column(
            children: [
              // — Step Indicator —
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _StepChip(
                      number: 1,
                      label: t('step_config'),
                      isActive: _currentStep == 0,
                      isCompleted: _currentStep > 0,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: _currentStep > 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    _StepChip(
                      number: 2,
                      label: t('step_history'),
                      isActive: _currentStep == 1,
                      isCompleted: false,
                    ),
                  ],
                ),
              ),

              // — Page Content —
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentStep = page),
                  children: [
                    // — STEP 1: Task Configuration —
                    _buildStep1(tasks, t),

                    // — STEP 2: Historical Logging —
                    _buildStep2(t),
                  ],
                ),
              ),

              // — Bottom Navigation —
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentStep > 0) ...[
                      OutlinedButton.icon(
                        onPressed: _goToStep1,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: Text(t('back')),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: _currentStep == 0
                            ? FilledButton.icon(
                                onPressed:
                                    _enabledTaskKeys.isEmpty ? null : _goToStep2,
                                icon: const Icon(Icons.arrow_forward),
                                label: Text(t('next_step')),
                              )
                            : FilledButton.icon(
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
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  // ——— STEP 1: Task Configuration ———

  Widget _buildStep1(List<ServiceTask> tasks, String Function(String) t) {
    if (tasks.isEmpty) {
      return Center(child: Text(t('no_tasks_loaded')));
    }

    return CustomScrollView(
      slivers: [
        // Collapsing context header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              t('step1_context'),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),

        // Task list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = tasks[index];
                final enabled = _enabledTaskKeys.contains(task.taskKey);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        if (enabled) {
                          _enabledTaskKeys.remove(task.taskKey);
                        } else {
                          _enabledTaskKeys.add(task.taskKey);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Checkbox + name
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: enabled,
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _enabledTaskKeys.add(task.taskKey);
                                      } else {
                                        _enabledTaskKeys.remove(task.taskKey);
                                      }
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  t(task.displayNameEn),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: enabled
                                        ? null
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Interval fields (only when enabled)
                          if (enabled) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (task.intervalKm != null) ...[
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          _kmControllers[task.taskKey],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                        labelText: t('interval_km'),
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                        suffixText: t('km'),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                if (task.intervalKm != null &&
                                    task.intervalMonths != null)
                                  const SizedBox(width: 8),
                                if (task.intervalMonths != null) ...[
                                  Expanded(
                                    child: TextFormField(
                                      controller:
                                          _monthControllers[task.taskKey],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                        labelText: t('interval_months'),
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                        suffixText: t('months'),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: tasks.length,
            ),
          ),
        ),

        // Bottom padding for nav bar
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  // ——— STEP 2: Historical Logging ———

  Widget _buildStep2(String Function(String) t) {
    final taskState = ref.read(serviceTaskProvider).valueOrNull;
    final tasks = taskState?.allTasks ?? [];
    final enabledTasks =
        tasks.where((task) => _enabledTaskKeys.contains(task.taskKey)).toList();

    if (enabledTasks.isEmpty) {
      return Center(child: Text(t('no_tasks_selected')));
    }

    return CustomScrollView(
      slivers: [
        // Collapsing context header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              t('step2_context'),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),

        // Enabled tasks history list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = enabledTasks[index];
                final history = _historyEntries.putIfAbsent(
                    task.taskKey, () => _TaskHistoryEntry());

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task name header
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                t(task.displayNameEn),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Odometer
                        TextFormField(
                          controller: history.odometer,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: t('odometer'),
                            border: const OutlineInputBorder(),
                            isDense: true,
                            prefixIcon:
                                const Icon(Icons.speed_outlined, size: 18),
                            suffixText: t('km'),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Costs row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: history.partsCost,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  labelText: t('part_cost'),
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  prefixText: 'SAR ',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: history.laborCost,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  labelText: t('labor_cost'),
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  prefixText: 'SAR ',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: enabledTasks.length,
            ),
          ),
        ),

        // Bottom padding for nav bar
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }
}

/// A small step indicator chip (1 or 2).
class _StepChip extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepChip({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.outlineVariant;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? activeColor
                : isActive
                    ? activeColor
                    : inactiveColor,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? activeColor : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
