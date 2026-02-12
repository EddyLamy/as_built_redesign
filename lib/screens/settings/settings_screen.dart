import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _emailNotifications = true;
  bool _deadlineAlerts = true;
  bool _turbineChanges = false;
  bool _weeklyReports = false;
  String _dateFormat = 'DD/MM/YYYY';

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.white),
            const SizedBox(width: 12),
            Text(t.translate('settings')),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ══════════════════════════════════════════════════════════════
          // IDIOMA
          // ══════════════════════════════════════════════════════════════
          _buildSectionHeader(
            context,
            Icons.language,
            t.translate('language'),
            AppColors.primaryBlue,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Português'),
                    value: 'pt',
                    groupValue: currentLocale,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(localeProvider.notifier).setLocale(value);
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('English'),
                    value: 'en',
                    groupValue: currentLocale,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(localeProvider.notifier).setLocale(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ══════════════════════════════════════════════════════════════
          // TEMA
          // ══════════════════════════════════════════════════════════════
          _buildSectionHeader(
            context,
            Icons.palette_outlined,
            t.translate('theme'),
            AppColors.successGreen,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Builder(
                builder: (context) {
                  final currentTheme = ref.watch(themeProvider);
                  final isDarkMode = currentTheme == 'dark';
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDarkMode
                                  ? t.translate('dark_theme')
                                  : t.translate('light_theme'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isDarkMode
                                  ? t.translate('dark_mode_enabled')
                                  : t.translate('light_mode_enabled'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isDarkMode,
                        onChanged: (_) {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                        activeThumbColor: AppColors.primaryBlue,
                        inactiveThumbColor: Colors.grey,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          // ══════════════════════════════════════════════════════════════
          // NOTIFICAÇÕES
          // ══════════════════════════════════════════════════════════════
          _buildSectionHeader(
            context,
            Icons.notifications_outlined,
            t.translate('notifications'),
            AppColors.accentTeal,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(t.translate('email_phase_complete')),
                    subtitle: Text(
                      t.translate('email_phase_complete_desc'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _emailNotifications,
                    activeThumbColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() => _emailNotifications = value);
                      // TODO: Salvar preferência
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(t.translate('deadline_alerts')),
                    subtitle: Text(
                      t.translate('deadline_alerts_desc'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _deadlineAlerts,
                    activeThumbColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() => _deadlineAlerts = value);
                      // TODO: Salvar preferência
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(t.translate('turbine_changes')),
                    subtitle: Text(
                      t.translate('turbine_changes_desc'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _turbineChanges,
                    activeThumbColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() => _turbineChanges = value);
                      // TODO: Salvar preferência
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(t.translate('weekly_reports')),
                    subtitle: Text(
                      t.translate('weekly_reports_desc'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _weeklyReports,
                    activeThumbColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() => _weeklyReports = value);
                      // TODO: Salvar preferência
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ══════════════════════════════════════════════════════════════
          // FORMATO DE DATA
          // ══════════════════════════════════════════════════════════════
          _buildSectionHeader(
            context,
            Icons.calendar_today,
            t.translate('date_format'),
            AppColors.warningOrange,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                initialValue: _dateFormat,
                decoration: InputDecoration(
                  labelText: t.translate('date_format'),
                  border: const OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'DD/MM/YYYY',
                      child: Text('DD/MM/YYYY (07/02/2026)')),
                  DropdownMenuItem(
                      value: 'MM/DD/YYYY',
                      child: Text('MM/DD/YYYY (02/07/2026)')),
                  DropdownMenuItem(
                      value: 'YYYY-MM-DD',
                      child: Text('YYYY-MM-DD (2026-02-07)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _dateFormat = value);
                    // TODO: Salvar preferência
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ══════════════════════════════════════════════════════════════
          // DADOS
          // ══════════════════════════════════════════════════════════════
          _buildSectionHeader(
            context,
            Icons.storage_outlined,
            t.translate('data'),
            AppColors.mediumGray,
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download,
                      color: AppColors.primaryBlue),
                  title: Text(t.translate('export_all_data')),
                  subtitle: Text(t.translate('export_all_data_desc')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implementar exportação
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.translate('coming_soon'))),
                    );
                  },
                ),
                const Divider(height: 1),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
