import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/notification_settings.dart';

/// Ecrã de Configurações de Notificações
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  late NotificationSettings _localSettings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await NotificationSettings.load();
      setState(() {
        _localSettings = settings;
      });
    } catch (e) {
      print('Erro ao carregar settings: $e');
      setState(() {
        _localSettings = NotificationSettings();
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      await _localSettings.save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurações guardadas com sucesso')),
        );
      }
    } catch (e) {
      print('Erro ao guardar settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao guardar: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleEnabled() {
    setState(() {
      _localSettings = _localSettings.copyWith(
        enabled: !_localSettings.enabled,
      );
    });
    _saveSettings();
  }

  void _toggleShowBadge() {
    setState(() {
      _localSettings = _localSettings.copyWith(
        showBadge: !_localSettings.showBadge,
      );
    });
    _saveSettings();
  }

  void _toggleShowInDashboard() {
    setState(() {
      _localSettings = _localSettings.copyWith(
        showInDashboard: !_localSettings.showInDashboard,
      );
    });
    _saveSettings();
  }

  void _togglePhaseAlerts() {
    setState(() {
      _localSettings = _localSettings.copyWith(
        phaseAlerts: !_localSettings.phaseAlerts,
      );
    });
    _saveSettings();
  }

  void _toggleComponentAlerts() {
    setState(() {
      _localSettings = _localSettings.copyWith(
        componentAlerts: !_localSettings.componentAlerts,
      );
    });
    _saveSettings();
  }

  void _toggleTurbineAlerts() {
    setState(() {
      _localSettings = _localSettings.copyWith(
        turbineAlerts: !_localSettings.turbineAlerts,
      );
    });
    _saveSettings();
  }

  void _updatePhaseWarningDays(int days) {
    setState(() {
      _localSettings = _localSettings.copyWith(
        daysBeforePhaseWarning: days,
      );
    });
    _saveSettings();
  }

  void _updateComponentStalledDays(int days) {
    setState(() {
      _localSettings = _localSettings.copyWith(
        daysComponentStalled: days,
      );
    });
    _saveSettings();
  }

  void _updateTurbineStalledDays(int days) {
    setState(() {
      _localSettings = _localSettings.copyWith(
        daysTurbineStalled: days,
      );
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('notification_settings')),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Seção: Geral
                _buildSectionTitle(t.translate('general')),
                _buildCard([
                  SwitchListTile(
                    title: Text(t.translate('enable_notifications')),
                    subtitle: Text(t.translate('enable_notifications_desc')),
                    value: _localSettings.enabled,
                    onChanged: (_) => _toggleEnabled(),
                  ),
                  if (_localSettings.enabled) ...[
                    const Divider(),
                    SwitchListTile(
                      title: Text(t.translate('show_badge_appbar')),
                      subtitle: Text(t.translate('show_badge_appbar_desc')),
                      value: _localSettings.showBadge,
                      onChanged: (_) => _toggleShowBadge(),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text(t.translate('show_in_dashboard')),
                      subtitle: Text(t.translate('show_in_dashboard_desc')),
                      value: _localSettings.showInDashboard,
                      onChanged: (_) => _toggleShowInDashboard(),
                    ),
                  ],
                ]),
                const SizedBox(height: 24),

                // Seção: Alertas
                _buildSectionTitle(t.translate('alerts')),
                _buildCard([
                  SwitchListTile(
                    title: Text(t.translate('phase_alerts')),
                    subtitle: Text(t.translate('phase_alerts_desc')),
                    value: _localSettings.phaseAlerts,
                    onChanged: _localSettings.enabled
                        ? (_) => _togglePhaseAlerts()
                        : null,
                  ),
                  if (_localSettings.phaseAlerts && _localSettings.enabled) ...[
                    const Divider(),
                    _buildSliderTile(
                      context,
                      title: t.translate('phase_warning_days'),
                      subtitle: t.translate('phase_warning_days_desc'),
                      value: _localSettings.daysBeforePhaseWarning.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      onChanged: (value) =>
                          _updatePhaseWarningDays(value.toInt()),
                      suffix: t.translate('days'),
                    ),
                  ],
                  const Divider(),
                  SwitchListTile(
                    title: Text(t.translate('component_alerts')),
                    subtitle: Text(t.translate('component_alerts_desc')),
                    value: _localSettings.componentAlerts,
                    onChanged: _localSettings.enabled
                        ? (_) => _toggleComponentAlerts()
                        : null,
                  ),
                  if (_localSettings.componentAlerts &&
                      _localSettings.enabled) ...[
                    const Divider(),
                    _buildSliderTile(
                      context,
                      title: t.translate('component_stalled_days'),
                      subtitle: t.translate('component_stalled_days_desc'),
                      value: _localSettings.daysComponentStalled.toDouble(),
                      min: 7,
                      max: 90,
                      divisions: 83,
                      onChanged: (value) =>
                          _updateComponentStalledDays(value.toInt()),
                      suffix: t.translate('days'),
                    ),
                  ],
                  const Divider(),
                  SwitchListTile(
                    title: Text(t.translate('turbine_alerts')),
                    subtitle: Text(t.translate('turbine_alerts_desc')),
                    value: _localSettings.turbineAlerts,
                    onChanged: _localSettings.enabled
                        ? (_) => _toggleTurbineAlerts()
                        : null,
                  ),
                  if (_localSettings.turbineAlerts &&
                      _localSettings.enabled) ...[
                    const Divider(),
                    _buildSliderTile(
                      context,
                      title: t.translate('turbine_stalled_days'),
                      subtitle: t.translate('turbine_stalled_days_desc'),
                      value: _localSettings.daysTurbineStalled.toDouble(),
                      min: 7,
                      max: 180,
                      divisions: 173,
                      onChanged: (value) =>
                          _updateTurbineStalledDays(value.toInt()),
                      suffix: t.translate('days'),
                    ),
                  ],
                ]),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12, top: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required String suffix,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          const SizedBox(height: 8),
          Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            label: '${value.toInt()} $suffix',
            onChanged: onChanged,
          ),
          Text(
            '${value.toInt()} $suffix',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
