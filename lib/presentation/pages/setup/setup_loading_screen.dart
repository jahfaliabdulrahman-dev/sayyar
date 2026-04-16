import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/maintenance_record.dart';
import '../../../data/models/service_task.dart';
import '../../../data/models/vehicle.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/service_task_provider.dart';
import '../home/home_root_page.dart';

/// Data transfer object for setup wizard completion.
///
/// Contains all extracted data from the wizard's TextEditingControllers
/// so they can be passed to the loading screen without lifecycle issues.
class SetupPayload {
  final Vehicle vehicle;
  final List<ServiceTask> allTasks;
  final List<MaintenanceRecord> recordsToSave;
  final Map<String, int?> intervalKmOverrides;
  final Map<String, int?> intervalMonthsOverrides;
  final Set<String> enabledTaskKeys;

  const SetupPayload({
    required this.vehicle,
    required this.allTasks,
    required this.recordsToSave,
    required this.intervalKmOverrides,
    required this.intervalMonthsOverrides,
    required this.enabledTaskKeys,
  });
}

/// AIR-LOCK PATTERN — Setup Loading Screen
///
/// This screen exists solely to perform heavy Isar I/O in complete
/// isolation from any keyboard/IME state. The Setup Wizard widget
/// tree is fully destroyed before this screen mounts, guaranteeing:
///
/// 1. All TextFormFields are disposed
/// 2. Keyboard is destroyed at the OS level
/// 3. No InputMethodManager conflicts
/// 4. No Choreographer frame drops
///
/// The Isar I/O is triggered via addPostFrameCallback AFTER the
/// loading screen has fully rendered, with a 500ms safety buffer
/// to ensure the page transition animation completes.
class SetupLoadingScreen extends ConsumerStatefulWidget {
  final SetupPayload payload;

  const SetupLoadingScreen({super.key, required this.payload});

  @override
  ConsumerState<SetupLoadingScreen> createState() =>
      _SetupLoadingScreenState();
}

class _SetupLoadingScreenState extends ConsumerState<SetupLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule I/O AFTER the first frame renders — this guarantees:
    // 1. The loading screen is fully mounted
    // 2. The previous screen (Setup Wizard) is fully unmounted
    // 3. The keyboard is destroyed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executeAirLockedSave();
    });
  }

  Future<void> _executeAirLockedSave() async {
    try {
      // Safety buffer — let page transition animation complete
      await Future.delayed(const Duration(milliseconds: 500));

      final payload = widget.payload;

      // Phase 1: Persist maintenance records
      for (final record in payload.recordsToSave) {
        await ref.read(maintenanceProvider.notifier).addRecord(record);
      }

      // Phase 2: Batch-update task intervals
      final taskRepo = ref.read(serviceTaskProvider.notifier);
      for (final taskKey in payload.enabledTaskKeys) {
        final kmInterval = payload.intervalKmOverrides[taskKey];
        final monthInterval = payload.intervalMonthsOverrides[taskKey];

        if (kmInterval != null || monthInterval != null) {
          await taskRepo.updateTask(
            taskKey: taskKey,
            intervalKm: kmInterval,
            intervalMonths: monthInterval,
          );
        }
      }

      // Phase 3: Refresh providers
      ref.invalidate(serviceTaskProvider);
      ref.invalidate(maintenanceProvider);

      // Phase 4: Navigate to home
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeRootPage()),
          (route) => false,
        );
      }
    } catch (e) {
      // If I/O fails, show error and allow retry
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setup failed: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _executeAirLockedSave(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Setting up your workspace...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a moment',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
