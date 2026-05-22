import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../widgets/background_watermark.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../utils/app_feedback.dart';
import 'documentation_content.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({
    super.key,
    this.embeddedInDesktopShell = false,
  });

  final bool embeddedInDesktopShell;

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String _appVersion = '...';

  Color _cardSurface(BuildContext context, {double lightAlpha = 0.92}) {
    return AppColors.adaptiveCardSurface(context).withValues(
      alpha: AppColors.isDarkContext(context) ? 0.84 : lightAlpha,
    );
  }

  Color _secondaryText(BuildContext context) =>
      AppColors.adaptiveSecondaryText(context);

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      setState(() {
        _appVersion = '2.1.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);

    final screenBody = Stack(
      children: [
        const BackgroundWatermark(
          size: 600,
          opacity: 0.02,
          alignment: Alignment.bottomRight,
        ),
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader(
              context,
              Icons.menu_book,
              t.translate('documentation'),
              AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _buildDocTile(
                    context,
                    Icons.play_circle_outline,
                    t.translate('quick_start_guide'),
                    t.translate('getting_started_subtitle'),
                    () => _showDocumentation(context, 'quick_start'),
                  ),
                  const Divider(height: 1),
                  _buildDocTile(
                    context,
                    Icons.add_circle_outline,
                    t.translate('how_to_add_turbines'),
                    t.translate('turbine_management_help'),
                    () => _showDocumentation(context, 'add_turbines'),
                  ),
                  const Divider(height: 1),
                  _buildDocTile(
                    context,
                    Icons.wind_power,
                    t.translate('phase_management'),
                    t.translate('project_management_help'),
                    () => _showDocumentation(context, 'phases'),
                  ),
                  const Divider(height: 1),
                  _buildDocTile(
                    context,
                    Icons.menu_book_outlined,
                    t.translate('daily_journal'),
                    t.translate('daily_journal_help'),
                    () => _showDocumentation(context, 'daily_journal'),
                  ),
                  const Divider(height: 1),
                  _buildDocTile(
                    context,
                    Icons.rule_folder_outlined,
                    t.translate('ncrs'),
                    t.translate('ncr_help'),
                    () => _showDocumentation(context, 'ncrs'),
                  ),
                  const Divider(height: 1),
                  _buildDocTile(
                    context,
                    Icons.health_and_safety_outlined,
                    t.translate('safety_alerts_help'),
                    t.translate('safety_alerts_help_desc'),
                    () => _showDocumentation(context, 'safety_alerts'),
                  ),
                  const Divider(height: 1),
                  _buildDocTile(
                    context,
                    Icons.description_outlined,
                    t.translate('reports_help'),
                    t.translate('reports_and_exports_help'),
                    () => _showDocumentation(context, 'reports'),
                  ),
                  const Divider(height: 1),
                  _buildDocTile(
                    context,
                    Icons.precision_manufacturing,
                    t.translate('cranes_logistics'),
                    t.translate('general_cranes_subtitle'),
                    () => _showDocumentation(context, 'cranes'),
                  ),
                  const Divider(height: 1),
                  _buildDocTile(
                    context,
                    Icons.security_outlined,
                    t.translate('users_permissions_help'),
                    t.translate('team_management_help'),
                    () => _showDocumentation(context, 'users_permissions'),
                  ),
                  const Divider(height: 1),
                  _buildDocTile(
                    context,
                    Icons.groups_outlined,
                    t.translate('team_management_help'),
                    t.translate('companies'),
                    () => _showDocumentation(context, 'team_management'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              context,
              Icons.support_agent,
              t.translate('support'),
              AppColors.accentTeal,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.email, color: AppColors.primaryBlue),
                    ),
                    title: Text(t.translate('contact_support')),
                    subtitle: const Text('support@asbuilt.com'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showAppFeedback(
                        '${t.translate('opening')}: email',
                        type: AppFeedbackType.info,
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bug_report,
                          color: AppColors.errorRed),
                    ),
                    title: Text(t.translate('report_bug')),
                    subtitle: Text(t.translate('report_bug_desc')),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _reportBug(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              context,
              Icons.info_outline,
              t.translate('about'),
              AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryBlue, Color(0xFF00BCD4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.wind_power,
                            size: 32, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'As-Built',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.translate('wind_turbine_installation'),
                      style: TextStyle(color: _secondaryText(context)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          context,
                          Icons.smartphone,
                          t.translate('version'),
                          _appVersion,
                        ),
                        _buildInfoItem(
                          context,
                          Icons.calendar_today,
                          t.translate('updated'),
                          '23/02/2026',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildLinkTile(
                      context,
                      Icons.description,
                      t.translate('terms_of_service'),
                      () => _openLink('terms'),
                    ),
                    _buildLinkTile(
                      context,
                      Icons.privacy_tip,
                      t.translate('privacy_policy'),
                      () => _openLink('privacy'),
                    ),
                    _buildLinkTile(
                      context,
                      Icons.gavel,
                      t.translate('licenses'),
                      () => _showLicenses(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              context,
              Icons.system_update,
              t.translate('updates'),
              AppColors.successGreen,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.successGreen, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.translate('app_up_to_date'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${t.translate('version')} $_appVersion',
                                style: TextStyle(
                                  color: _secondaryText(context),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _checkForUpdates(context),
                      icon: const Icon(Icons.refresh),
                      label: Text(t.translate('check_updates')),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              context,
              Icons.keyboard,
              t.translate('keyboard_shortcuts'),
              AppColors.warningOrange,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.translate('productivity_shortcuts'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildShortcutRow(
                        context, 'Ctrl + N', t.translate('new_project')),
                    _buildShortcutRow(
                        context, 'Ctrl + T', t.translate('add_turbine')),
                    _buildShortcutRow(
                        context, 'Ctrl + R', t.translate('generate_report')),
                    _buildShortcutRow(
                        context, 'Ctrl + F', t.translate('search')),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      t.translate('navigation_shortcuts'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildShortcutRow(
                        context, 'Ctrl + ,', t.translate('settings')),
                    _buildShortcutRow(context, 'F1', t.translate('help')),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      t.translate('appearance_shortcuts'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildShortcutRow(
                        context, 'Ctrl + L', t.translate('toggle_language')),
                    _buildShortcutRow(
                        context, 'Ctrl + D', t.translate('toggle_theme')),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentTeal.withValues(
                          alpha: AppColors.isDarkContext(context) ? 0.18 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accentTeal.withValues(
                            alpha:
                                AppColors.isDarkContext(context) ? 0.34 : 0.3,
                          ),
                        ),
                        boxShadow: AppColors.glassShadow,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.accentTeal,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.translate('shortcuts_tip'),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
              const Icon(Icons.help_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text(t.translate('help')),
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

  Widget _buildDocTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: _secondaryText(context)),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: _secondaryText(context),
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _secondaryText(context)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.adaptivePrimaryText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            Icon(Icons.open_in_new, size: 16, color: _secondaryText(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutRow(BuildContext context, String keys, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(action, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _cardSurface(context, lightAlpha: 0.96),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.adaptiveOutline(context)),
              boxShadow: AppColors.glassShadow,
            ),
            child: Text(
              keys,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDocumentation(BuildContext context, String topic) {
    final t = TranslationHelper.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    // Mapa de títulos por tópico
    final titles = {
      'quick_start': t.translate('quick_start_guide'),
      'add_turbines': t.translate('how_to_add_turbines'),
      'phases': t.translate('phase_management'),
      'daily_journal': t.translate('daily_journal_help'),
      'ncrs': t.translate('ncr_help'),
      'safety_alerts': t.translate('safety_alerts_help'),
      'reports': t.translate('reports_help'),
      'cranes': t.translate('cranes_logistics'),
      'users_permissions': t.translate('users_permissions_help'),
      'team_management': t.translate('team_management_help'),
    };

    final content = DocumentationContent.getContent(topic, locale);

    showLiquidDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        titles[topic] ?? topic,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.adaptivePrimaryText(context),
                    ),
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.translate('close')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reportBug(BuildContext context) {
    final t = TranslationHelper.of(context);
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showLiquidDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.bug_report, color: AppColors.errorRed),
            const SizedBox(width: 12),
            Text(t.translate('report_bug')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: t.translate('bug_title'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: t.translate('bug_description'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final desc = descController.text.trim();

              if (title.isEmpty && desc.isEmpty) {
                showAppFeedback(
                  'Please fill in at least the title',
                  type: AppFeedbackType.warning,
                );
                return;
              }

              Navigator.pop(context);

              const String supportEmail = 'support@asbuilt.com';
              final String userEmail =
                  FirebaseAuth.instance.currentUser?.email ?? '';
              final String appVersion = _appVersion;

              final String subject = Uri.encodeComponent(
                '[Bug Report] ${title.isNotEmpty ? title : "As-Built Bug"}',
              );
              final String body = Uri.encodeComponent(
                'Reported by: $userEmail\n'
                'App Version: $appVersion\n'
                '\n--- Description ---\n'
                '${desc.isNotEmpty ? desc : "No description provided"}',
              );

              final Uri emailUri = Uri.parse(
                'mailto:$supportEmail?subject=$subject&body=$body',
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                if (context.mounted) {
                  showAppFeedback(
                    'Could not open email client',
                    type: AppFeedbackType.error,
                  );
                }
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: Text(t.translate('submit')),
          ),
        ],
      ),
    );
  }

  void _openLink(String link) {
    showAppFeedback(
      'Opening: $link',
      type: AppFeedbackType.info,
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'As-Built',
      applicationVersion: _appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.accentTeal],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.business, color: Colors.white, size: 32),
      ),
    );
  }

  void _checkForUpdates(BuildContext context) {
    final t = TranslationHelper.of(context);
    showAppFeedback(
      t.translate('checking_updates'),
      type: AppFeedbackType.info,
    );
    Future.delayed(const Duration(seconds: 2), () {
      showAppFeedback(
        t.translate('app_up_to_date'),
        type: AppFeedbackType.success,
      );
    });
  }
}
