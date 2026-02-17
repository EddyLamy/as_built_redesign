import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../widgets/background_watermark.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String _appVersion = '...';

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
        _appVersion = '2.1.0'; // Fallback
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(t.translate('help')),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background watermark
          const BackgroundWatermark(
            size: 600,
            opacity: 0.02,
            alignment: Alignment.bottomRight,
          ),
          // Main content
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ══════════════════════════════════════════════════════════════
              // DOCUMENTAÇÃO
              // ══════════════════════════════════════════════════════════════
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
                  Icons.rocket_launch,
                  t.translate('quick_start_guide'),
                  t.translate('quick_start_guide_desc'),
                  () => _showDocumentation(context, 'quick_start'),
                ),
                const Divider(height: 1),
                _buildDocTile(
                  context,
                  Icons.wind_power,
                  t.translate('how_to_add_turbines'),
                  t.translate('how_to_add_turbines_desc'),
                  () => _showDocumentation(context, 'add_turbines'),
                ),
                const Divider(height: 1),
                _buildDocTile(
                  context,
                  Icons.timeline,
                  t.translate('phase_management'),
                  t.translate('phase_management_desc'),
                  () => _showDocumentation(context, 'phases'),
                ),
                const Divider(height: 1),
                _buildDocTile(
                  context,
                  Icons.assessment,
                  t.translate('reports_help'),
                  t.translate('reports_help_desc'),
                  () => _showDocumentation(context, 'reports'),
                ),
                const Divider(height: 1),
                _buildDocTile(
                  context,
                  Icons.construction,
                  t.translate('cranes_logistics'),
                  t.translate('cranes_logistics_desc'),
                  () => _showDocumentation(context, 'cranes'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ══════════════════════════════════════════════════════════════
          // SUPORTE
          // ══════════════════════════════════════════════════════════════
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
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.email, color: AppColors.primaryBlue),
                  ),
                  title: Text(t.translate('contact_support')),
                  subtitle: const Text('support@asbuilt.com'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _contactSupport(context, 'email'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.chat, color: AppColors.successGreen),
                  ),
                  title: Row(
                    children: [
                      Text(t.translate('live_chat')),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          t.translate('online'),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(t.translate('avg_response_2min')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _contactSupport(context, 'chat'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.bug_report, color: AppColors.errorRed),
                  ),
                  title: Text(t.translate('report_bug')),
                  subtitle: Text(t.translate('report_bug_desc')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _reportBug(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ══════════════════════════════════════════════════════════════
          // SOBRE
          // ══════════════════════════════════════════════════════════════
          _buildSectionHeader(
            context,
            Icons.info_outline,
            t.translate('about'),
            AppColors.mediumGray,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Logo with gradient
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
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.wind_power,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'As-Built',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.translate('wind_turbine_installation'),
                    style: const TextStyle(color: AppColors.mediumGray),
                  ),
                  const SizedBox(height: 24),

                  // Informações
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        Icons.smartphone,
                        t.translate('version'),
                        _appVersion,
                      ),
                      _buildInfoItem(
                        Icons.calendar_today,
                        t.translate('updated'),
                        '07/02/2026',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Links
                  _buildLinkTile(
                    Icons.description,
                    t.translate('terms_of_service'),
                    () => _openLink('terms'),
                  ),
                  _buildLinkTile(
                    Icons.privacy_tip,
                    t.translate('privacy_policy'),
                    () => _openLink('privacy'),
                  ),
                  _buildLinkTile(
                    Icons.gavel,
                    t.translate('licenses'),
                    () => _showLicenses(context),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ══════════════════════════════════════════════════════════════
          // ATUALIZAÇÕES
          // ══════════════════════════════════════════════════════════════
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
                              style: const TextStyle(
                                color: AppColors.mediumGray,
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

          const SizedBox(height: 32),

          // ══════════════════════════════════════════════════════════════
// ATALHOS DE TECLADO
// ══════════════════════════════════════════════════════════════
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
                  _buildShortcutRow('Ctrl + N', t.translate('new_project')),
                  _buildShortcutRow('Ctrl + T', t.translate('add_turbine')),
                  _buildShortcutRow('Ctrl + R', t.translate('generate_report')),
                  _buildShortcutRow('Ctrl + F', t.translate('search')),
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
                  _buildShortcutRow('Ctrl + ,', t.translate('settings')),
                  _buildShortcutRow('F1', t.translate('help')),
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
                  _buildShortcutRow('Ctrl + L', t.translate('toggle_language')),
                  _buildShortcutRow('Ctrl + D', t.translate('toggle_theme')),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.accentTeal.withOpacity(0.3),
                      ),
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
            ],  // fecha children do ListView
          ),    // fecha ListView
        ],      // fecha children do Stack
      ),        // fecha Stack (body)
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
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.mediumGray,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title),
            ),
            const Icon(Icons.open_in_new,
                size: 16, color: AppColors.mediumGray),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutRow(String keys, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              action,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderGray),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
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

    // TODO: Implementar páginas de documentação detalhadas
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Text(t.translate(topic)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.translate('${topic}_content'),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 20, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.translate('full_docs_available'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('close')),
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context, String method) {
    final t = TranslationHelper.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${t.translate('opening')}: $method')),
    );
    // TODO: Abrir email ou chat
  }

  void _reportBug(BuildContext context) {
    final t = TranslationHelper.of(context);
    showDialog(
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
              decoration: InputDecoration(
                labelText: t.translate('bug_title'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.translate('bug_reported')),
                  backgroundColor: AppColors.successGreen,
                ),
              );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: $link')),
    );
    // TODO: Abrir link externo
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.translate('checking_updates'))),
    );
    // TODO: Verificar atualizações
  }
}
