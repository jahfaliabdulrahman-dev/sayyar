import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/vehicle.dart';
import '../../../presentation/providers/maintenance_provider.dart';
import '../../../presentation/providers/service_task_provider.dart';
import '../../../presentation/providers/settings_provider.dart';
import '../../../presentation/providers/vehicle_provider.dart';
import '../setup/setup_wizard_page.dart';
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
                          t('app_title'),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Text(
                            t('beta_badge'),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'language':
                            ref
                                .read(settingsProvider.notifier)
                                .toggleLocale();
                          case 'theme':
                            ref
                                .read(settingsProvider.notifier)
                                .toggleTheme();
                          case 'feedback':
                            _showFeedbackSheet(context, t);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'language',
                          child: Row(
                            children: [
                              Icon(Icons.translate,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20),
                              const SizedBox(width: 12),
                              Text(t('menu_language')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'theme',
                          child: Row(
                            children: [
                              Icon(Icons.brightness_medium_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20),
                              const SizedBox(width: 12),
                              Text(t('menu_theme')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'feedback',
                          child: Row(
                            children: [
                              Icon(Icons.feedback_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20),
                              const SizedBox(width: 12),
                              Text(t('menu_feedback')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // — Setup Banner (dismissible) —
            SliverToBoxAdapter(
              child: vehicleAsync.when(
                data: (vState) {
                  final vehicle = vState.activeVehicle;
                  if (vehicle == null || vehicle.isSetupDismissed) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(Icons.auto_fix_high,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t('setup_banner_title'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    height: 32,
                                    child: FilledButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const SetupWizardPage(),
                                          ),
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      child: Text(t('setup_banner_action')),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                ref.read(vehicleProvider.notifier).dismissSetup();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
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
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${vehicle?.make ?? 'My'} ${vehicle?.model ?? 'Car'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () => _showEditVehicleDialog(
                                          context, ref, vehicle, t,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
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

  /// Shows the Edit Vehicle dialog for updating make/model.
  static void _showEditVehicleDialog(
    BuildContext context,
    WidgetRef ref,
    Vehicle? vehicle,
    String Function(String) t,
  ) {
    if (vehicle == null) return;

    final makeController = TextEditingController(text: vehicle.make);
    final modelController = TextEditingController(text: vehicle.model);
    final yearController = TextEditingController(
      text: vehicle.year > 0 ? vehicle.year.toString() : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('edit_vehicle')),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: makeController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: t('make'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.business_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter make';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: modelController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: t('model'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.directions_car_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: yearController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  labelText: t('year'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final parsed = int.tryParse(v.trim());
                    if (parsed == null || parsed < 1900 || parsed > 2100) {
                      return 'Invalid year';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final newMake = makeController.text.trim();
              final newModel = modelController.text.trim();
              final yearText = yearController.text.trim();
              final newYear = yearText.isNotEmpty ? int.tryParse(yearText) : null;
              ref.read(vehicleProvider.notifier).updateVehicle(
                    vehicleId: vehicle.id,
                    make: newMake,
                    model: newModel,
                    name: '$newMake $newModel',
                    year: newYear,
                  );
              Navigator.of(ctx).pop();
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  /// Feedback channel URLs.
  static const _whatsappUrl =
      'https://wa.me/966543190284?text=Hello%20CarSah%20Team';
  static const _emailUrl =
      'mailto:jahfaliabdulrahman@gmail.com?subject=CarSah%20App%20Feedback';
  static const _surveyUrl = 'https://forms.gle/72dJFFKmubRkp5Cz8';

  /// Shows the Beta Feedback Hub.
  /// Responsive: BottomSheet on mobile, centered Dialog on tablet/desktop.
  static void _showFeedbackSheet(
      BuildContext context, String Function(String) t) {
    final isWide = MediaQuery.of(context).size.width > 600;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            t('feedback_hub'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
          title: const Text('WhatsApp'),
          subtitle: Text(t('whatsapp_tooltip')),
          onTap: () {
            Navigator.of(context).pop();
            launchUrl(
              Uri.parse(_whatsappUrl),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.assignment, color: Colors.blue),
          title: Text(t('survey_title')),
          subtitle: Text(t('survey_subtitle')),
          onTap: () {
            Navigator.of(context).pop();
            launchUrl(
              Uri.parse(_surveyUrl),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.email,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          title: Text(t('email_title')),
          subtitle: const Text('jahfaliabdulrahman@gmail.com'),
          onTap: () {
            Navigator.of(context).pop();
            launchUrl(
              Uri.parse(_emailUrl),
              mode: LaunchMode.externalApplication,
            );
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
