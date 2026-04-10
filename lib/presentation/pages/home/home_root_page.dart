import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';
import '../dashboard/dashboard_page.dart';
import '../tasks/tasks_page.dart';
import '../history/history_page.dart';

/// ============================================================
/// Home Root Page — BottomNavigationBar Shell
/// ============================================================
///
/// Three-tab navigation structure:
///   0. Dashboard — vehicle overview, spending, task summary.
///   1. Tasks     — service tasks list (overdue, upcoming, done).
///   2. History   — full maintenance records log.
///
/// Uses IndexedStack to preserve state when switching tabs.
/// Labels are localized via settingsProvider.
/// ============================================================
class HomeRootPage extends ConsumerStatefulWidget {
  const HomeRootPage({super.key});

  @override
  ConsumerState<HomeRootPage> createState() => _HomeRootPageState();
}

class _HomeRootPageState extends ConsumerState<HomeRootPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const DashboardPage(),
    const TasksPage(),
    const HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(settingsProvider).t;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: t('nav_dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist),
            label: t('nav_tasks'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: t('nav_history'),
          ),
        ],
      ),
    );
  }
}
