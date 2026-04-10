import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../presentation/providers/maintenance_provider.dart';
import '../../../presentation/providers/service_task_provider.dart';
import '../../../presentation/providers/settings_provider.dart';
import '../../../presentation/providers/vehicle_provider.dart';
import 'widgets/cost_trend_chart.dart';
import 'widgets/odometer_update_dialog.dart';

/// ============================================================
/// Dashboard Page — Main Screen
/// ============================================================
///
/// Layout: three cards stacked vertically in a scrollable view.
///   1. Vehicle Card — name, odometer, edit button.
///   2. Service Tasks Card — overdue count badge.
///   3. Spending Card — total SAR spent on maintenance.
///
/// Material 3. RTL/LTR ready. No external icon libraries.
/// ============================================================
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleProvider);
    final tasksAsync = ref.watch(serviceTaskProvider);
    final maintenanceAsync = ref.watch(maintenanceProvider);
    final settings = ref.watch(settingsProvider);
    final t = settings.t;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // — App Bar —
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sayyar',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showFeedbackSheet(context),
                          icon: const Icon(Icons.feedback_outlined),
                          tooltip: 'Feedback',
                        ),
                        IconButton(
                          onPressed: () => ref
                              .read(settingsProvider.notifier)
                              .toggleLocale(),
                          icon: const Icon(Icons.language),
                          tooltip:
                              settings.locale == AppLocale.en ? 'عربي' : 'English',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // — Vehicle Card —
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: vehicleAsync.when(
                      data: (vState) {
                        final vehicle = vState.activeVehicle;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.directions_car,
                                    color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    vehicle?.name ?? 'No Vehicle',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => const OdometerUpdateDialog(),
                                    );
                                  },
                                  icon: const Icon(Icons.speed, size: 18),
                                  label: Text(t('update')),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatChip(
                                  icon: Icons.speed_outlined,
                                  label: t('odometer'),
                                  value:
                                      '${vehicle?.currentOdometerKm.toString() ?? '0'} km',
                                ),
                                _StatChip(
                                  icon: Icons.calendar_today_outlined,
                                  label: t('year'),
                                  value: '${vehicle?.year.toString() ?? '--'}',
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: LinearProgressIndicator(),
                        ),
                      ),
                      error: (e, st) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text('Error: $e'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // — Cost Trend Chart Card —
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.trending_up_outlined,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              t('cost_trend'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Text(
                              t('monthly'),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const CostTrendChart(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // — Smart Action Banner —
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: tasksAsync.when(
                  data: (tState) {
                    final overdueCount = tState.overdueTasks.length;
                    final upcomingCount = tState.upcomingTasks.length;

                    final Color bgColor;
                    final Color borderColor;
                    final IconData bannerIcon;
                    final String bannerText;

                    if (overdueCount > 0) {
                      bgColor = Colors.red.withValues(alpha: 0.08);
                      borderColor = Colors.red.withValues(alpha: 0.3);
                      bannerIcon = Icons.warning_amber_rounded;
                      bannerText =
                          '\u26a0\ufe0f ${t('action_required')} $overdueCount ${t('services_overdue')}';
                    } else if (upcomingCount > 0) {
                      bgColor = Colors.blue.withValues(alpha: 0.08);
                      borderColor = Colors.blue.withValues(alpha: 0.3);
                      bannerIcon = Icons.info_outline;
                      bannerText =
                          '\u2139\ufe0f ${t('heads_up')} $upcomingCount ${t('services_upcoming')}';
                    } else {
                      bgColor = Colors.green.withValues(alpha: 0.08);
                      borderColor = Colors.green.withValues(alpha: 0.3);
                      bannerIcon = Icons.check_circle_outline;
                      bannerText =
                          '\u2705 ${t('all_systems_go')}';
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(bannerIcon, color: borderColor, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              bannerText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            // — Spending Card (Gradient) —
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: maintenanceAsync.when(
                      data: (mState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined,
                                    color: Colors.white.withValues(alpha: 0.9)),
                                const SizedBox(width: 12),
                                Text(
                                  t('total_spending'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${mState.totalSpending.toStringAsFixed(2)} SAR',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${mState.totalRecords} ${t('service_records')}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(4),
                        child: LinearProgressIndicator(),
                      ),
                      error: (e, st) => Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text('Error: $e'),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the Beta Feedback Hub.
  /// Responsive: BottomSheet on mobile, centered Dialog on tablet/desktop.
  static void _showFeedbackSheet(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Beta Feedback',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
          title: const Text('WhatsApp Support'),
          subtitle: const Text('Quick chat with the team'),
          onTap: () {
            Navigator.of(context).pop();
            launchUrl(Uri.parse(
              'https://wa.me/966500000000?text=Hello%20MaintLogic',
            ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.assignment, color: Colors.blue),
          title: const Text('Quick Survey'),
          subtitle: const Text('Help us improve (2 min)'),
          onTap: () {
            Navigator.of(context).pop();
            launchUrl(Uri.parse('https://forms.gle/placeholder'));
          },
        ),
        ListTile(
          leading: Icon(Icons.email,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          title: const Text('Email Support'),
          subtitle: const Text('beta@maintlogic.com'),
          onTap: () {
            Navigator.of(context).pop();
            launchUrl(Uri.parse('mailto:beta@maintlogic.com'));
          },
        ),
        const SizedBox(height: 8),
      ],
    );

    if (isWide) {
      // Tablet/Desktop: centered dialog.
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: content,
          ),
        ),
      );
    } else {
      // Mobile: bottom sheet.
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => SafeArea(child: content),
      );
    }
  }
}

/// Small stat chip used inside cards for compact data display.
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
