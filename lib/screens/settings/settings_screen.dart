import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../widgets/background_watermark.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    this.embeddedInDesktopShell = false,
  });

  final bool embeddedInDesktopShell;

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
    final currentLocale = ref.watch(localeStringProvider);

    final screenBody = Stack(
      children: [
        const BackgroundWatermark(
          size: 520,
          opacity: 0.03,
          alignment: Alignment.bottomRight,
        ),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        currentLocale == 'pt'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: currentLocale == 'pt'
                            ? AppColors.primaryBlue
                            : AppColors.mediumGray,
                      ),
                      title: const Text('Português'),
                      onTap: () async {
                        await ref.read(localeProvider.notifier).setLocale('pt');
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        currentLocale == 'en'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: currentLocale == 'en'
                            ? AppColors.primaryBlue
                            : AppColors.mediumGray,
                      ),
                      title: const Text('English'),
                      onTap: () async {
                        await ref.read(localeProvider.notifier).setLocale('en');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(
              context,
              Icons.palette,
              t.translate('theme'),
              AppColors.accentTeal,
            ),
            const SizedBox(height: 12),
            _buildThemeSelector(context, ref, t),
            const SizedBox(height: 32),
            _buildSectionHeader(
              context,
              Icons.notifications,
              t.translate('notifications'),
              AppColors.warningOrange,
            ),
            const SizedBox(height: 12),
            _buildNotificationsCard(t),
            const SizedBox(height: 32),
            _buildSectionHeader(
              context,
              Icons.date_range,
              t.translate('date_format'),
              AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            _buildDateFormatCard(),
          ],
        ),
      ],
    );

    if (widget.embeddedInDesktopShell) {
      return screenBody;
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: DashboardShortcutTitle(
          child: Row(
            children: [
              const Icon(Icons.settings, color: Colors.white),
              const SizedBox(width: 12),
              Text(t.translate('settings')),
            ],
          ),
        ),
      ),
      body: screenBody,
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

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    TranslationHelper t,
  ) {
    final currentTheme = ref.watch(themeStringProvider);
    final isDarkMode = currentTheme == 'dark';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Switch(
              value: isDarkMode,
              activeThumbColor: AppColors.primaryBlue,
              onChanged: (_) async {
                await ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsCard(TranslationHelper t) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: Text(t.translate('email_notifications')),
            subtitle: Text(
              t.translate('email_notifications_desc'),
              style: const TextStyle(fontSize: 12),
            ),
            value: _emailNotifications,
            activeThumbColor: AppColors.primaryBlue,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateFormatCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          initialValue: _dateFormat,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'DD/MM/YYYY',
              child: Text('DD/MM/YYYY (07/02/2026)'),
            ),
            DropdownMenuItem(
              value: 'MM/DD/YYYY',
              child: Text('MM/DD/YYYY (02/07/2026)'),
            ),
            DropdownMenuItem(
              value: 'YYYY-MM-DD',
              child: Text('YYYY-MM-DD (2026-02-07)'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _dateFormat = value);
            }
          },
        ),
      ),
    );
  }
}
