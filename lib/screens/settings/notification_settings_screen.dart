import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../providers/app_providers.dart';

/// Ecrã de Configurações de Notificações
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('notification_settings')),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Seção: Geral
          _buildSectionTitle(t.translate('general')),
          _buildCard([
            SwitchListTile(
              title: Text(t.translate('enable_notifications')),
              subtitle: Text(t.translate('enable_notifications_desc')),
              value: settings.enabled,
              onChanged: (_) => notifier.toggleEnabled(),
            ),
            if (settings.enabled) ...[
              const Divider(),
              SwitchListTile(
                title: Text(t.translate('show_badge_appbar')),
                subtitle: Text(t.translate('show_badge_appbar_desc')),
                value: settings.showBadge,
                onChanged: (_) => notifier.toggleShowBadge(),
              ),
              const Divider(),
              SwitchListTile(
                title: Text(t.translate('show_in_dashboard')),
                subtitle: Text(t.translate('show_in_dashboard_desc')),
                value: settings.showInDashboard,
                onChanged: (_) => notifier.toggleShowInDashboard(),
              ),
            ],
          ]),

          const SizedBox(height: 24),

          // Seção: Tipos de Alertas
          _buildSectionTitle(t.translate('alert_types')),
          _buildCard([
            SwitchListTile(
              title: Text(t.translate('phase_alerts')),
              subtitle: Text(t.translate('phase_alerts_desc')),
              value: settings.phaseAlerts,
              onChanged:
                  settings.enabled ? (_) => notifier.togglePhaseAlerts() : null,
            ),
            const Divider(),
            SwitchListTile(
              title: Text(t.translate('component_alerts')),
              subtitle: Text(t.translate('component_alerts_desc')),
              value: settings.componentAlerts,
              onChanged: settings.enabled
                  ? (_) => notifier.toggleComponentAlerts()
                  : null,
            ),
            const Divider(),
            SwitchListTile(
              title: Text(t.translate('turbine_alerts')),
              subtitle: Text(t.translate('turbine_alerts_desc')),
              value: settings.turbineAlerts,
              onChanged: settings.enabled
                  ? (_) => notifier.toggleTurbineAlerts()
                  : null,
            ),
          ]),

          const SizedBox(height: 24),

          // Seção: Thresholds
          _buildSectionTitle(t.translate('thresholds')),
          _buildCard([
            _buildSliderTile(
              context,
              title: t.translate('phase_warning_days'),
              subtitle: t.translate('phase_warning_days_desc'),
              value: settings.daysBeforePhaseWarning,
              min: 1,
              max: 30,
              divisions: 29,
              onChanged: settings.enabled && settings.phaseAlerts
                  ? (value) => notifier.updatePhaseWarningDays(value.toInt())
                  : null,
              suffix: t.translate('days'),
            ),
            const Divider(),
            _buildSliderTile(
              context,
              title: t.translate('component_stalled_days'),
              subtitle: t.translate('component_stalled_days_desc'),
              value: settings.daysComponentStalled,
              min: 7,
              max: 90,
              divisions: 83,
              onChanged: settings.enabled && settings.componentAlerts
                  ? (value) =>
                      notifier.updateComponentStalledDays(value.toInt())
                  : null,
              suffix: t.translate('days'),
            ),
            const Divider(),
            _buildSliderTile(
              context,
              title: t.translate('turbine_stalled_days'),
              subtitle: t.translate('turbine_stalled_days_desc'),
              value: settings.daysTurbineStalled,
              min: 7,
              max: 180,
              divisions: 173,
              onChanged: settings.enabled && settings.turbineAlerts
                  ? (value) => notifier.updateTurbineStalledDays(value.toInt())
                  : null,
              suffix: t.translate('days'),
            ),
          ]),

          const SizedBox(height: 24),

          // Seção: Manutenção
          _buildSectionTitle(t.translate('maintenance')),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.cleaning_services,
                  color: AppColors.primaryBlue),
              title: Text(t.translate('cleanup_old_data')),
              subtitle: Text(t.translate('cleanup_old_data_desc')),
              trailing: ElevatedButton(
                onPressed: () async {
                  await notifier.cleanup();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t.translate('cleanup_success')),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                  }
                },
                child: Text(t.translate('cleanup')),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore, color: AppColors.accentOrange),
              title: Text(t.translate('reset_settings')),
              subtitle: Text(t.translate('reset_settings_desc')),
              trailing: ElevatedButton(
                onPressed: () => _confirmReset(context, notifier, t),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.white,
                ),
                child: Text(t.translate('reset')),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.translate('notification_settings_info'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int value,
    required double min,
    required double max,
    required int divisions,
    required Function(double)? onChanged,
    required String suffix,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.mediumGray),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: '$value $suffix',
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 70,
                child: Text(
                  '$value $suffix',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmReset(
    BuildContext context,
    NotificationSettingsNotifier notifier,
    TranslationHelper t,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate('reset_settings')),
        content: Text(t.translate('reset_settings_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await notifier.reset();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(t.translate('settings_reset_success')),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text(t.translate('reset')),
          ),
        ],
      ),
    );
  }
}
