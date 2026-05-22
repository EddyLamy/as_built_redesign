import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/localization/translation_helper.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_providers.dart';
import '../providers/locale_provider.dart';
import '../providers/permission_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/equipment/equipment_screen.dart';
import '../screens/help/help_screen.dart';
import '../screens/installation/installation_screen.dart';
import '../screens/mobile/gruas_gerais_screen.dart';
import '../screens/ncr/ncr_screen.dart';
import '../screens/safety_alerts/safety_alert_screen.dart';
import '../screens/daily_journal/daily_journal_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/team/team_screen.dart';
import 'create_project_dialog.dart';
import 'generate_report_dialog.dart';

part 'enhanced_drawer.g.dart';

enum AppModule {
  asBuilt,
  installation,
}

enum DrawerMenuItemKey {
  dashboard,
  newProject,
  reports,
  dailyJournal,
  ncrs,
  safetyAlerts,
  generalCranes,
  equipment,
  team,
  users,
  settings,
  help,
}

class DesktopSelectedItemNotifier extends Notifier<DrawerMenuItemKey> {
  @override
  DrawerMenuItemKey build() => DrawerMenuItemKey.dashboard;

  void setItem(DrawerMenuItemKey item) {
    state = item;
  }
}

final desktopSelectedItemProvider =
    NotifierProvider<DesktopSelectedItemNotifier, DrawerMenuItemKey>(
  DesktopSelectedItemNotifier.new,
);

@riverpod
class CurrentModule extends _$CurrentModule {
  @override
  AppModule build() => AppModule.asBuilt;

  void setModule(AppModule module) => state = module;
}

class EnhancedDrawer extends ConsumerStatefulWidget {
  const EnhancedDrawer({super.key});

  @override
  ConsumerState<EnhancedDrawer> createState() => _EnhancedDrawerState();
}

class _EnhancedDrawerState extends ConsumerState<EnhancedDrawer> {
  DrawerMenuItemKey _selectedDrawerItem = DrawerMenuItemKey.dashboard;
  bool _isLogoutHovered = false;

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _sidebarBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF111827) : const Color(0xFFEAF1F7);

  Color _sidebarSection(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1F2937) : const Color(0xFFD9E5F0);

  Color _sidebarBorder(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1F2937) : const Color(0xFFB8CADB);

  Color _sidebarPrimaryText(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF17324D);

  Color _sidebarMutedText(BuildContext context) =>
      _isDark(context) ? const Color(0xFF9CA3AF) : const Color(0xFF516A83);

  void _openHelpScreen({bool closeDrawer = false}) {
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    if (closeDrawer) {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        rootNavigator.push(
          MaterialPageRoute(builder: (_) => const HelpScreen()),
        );
      });
      return;
    }

    rootNavigator.push(
      MaterialPageRoute(builder: (_) => const HelpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final t = TranslationHelper.of(context);
    final currentModule = ref.watch(currentModuleProvider);
    final user = FirebaseAuth.instance.currentUser;
    final globalPermissions = ref.watch(globalPermissionProvider);
    final sidebarBackground = _sidebarBackground(context);
    final sidebarSection = _sidebarSection(context);
    final sidebarBorder = _sidebarBorder(context);
    final primaryText = _sidebarPrimaryText(context);
    final mutedText = _sidebarMutedText(context);

    return Drawer(
      width: 220,
      backgroundColor: sidebarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      elevation: 0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            color: sidebarBackground,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.wind_power,
                          size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'As-Built',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: sidebarSection,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sidebarBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModuleButton(
                    label: t.translate('as_built'),
                    icon: Icons.assignment_turned_in,
                    isSelected: currentModule == AppModule.asBuilt,
                    foregroundColor: mutedText,
                    onTap: () {
                      ref
                          .read(currentModuleProvider.notifier)
                          .setModule(AppModule.asBuilt);
                      Navigator.pop(context);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _ModuleButton(
                    label: t.translate('installation'),
                    icon: Icons.construction,
                    isSelected: currentModule == AppModule.installation,
                    foregroundColor: mutedText,
                    onTap: () {
                      ref
                          .read(currentModuleProvider.notifier)
                          .setModule(AppModule.installation);
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InstallationScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Divider(color: sidebarBorder),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerMenuItem(
                  icon: Icons.dashboard,
                  label: t.translate('dashboard'),
                  isSelected:
                      _selectedDrawerItem == DrawerMenuItemKey.dashboard ||
                          currentModule == AppModule.asBuilt,
                  mutedColor: mutedText,
                  hoverColor: sidebarSection,
                  onTap: () {
                    setState(() {
                      _selectedDrawerItem = DrawerMenuItemKey.dashboard;
                    });
                    ref
                        .read(currentModuleProvider.notifier)
                        .setModule(AppModule.asBuilt);
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.add_business,
                  label: t.translate('new_project'),
                  isSelected:
                      _selectedDrawerItem == DrawerMenuItemKey.newProject,
                  mutedColor: mutedText,
                  hoverColor: sidebarSection,
                  onTap: () {
                    setState(() {
                      _selectedDrawerItem = DrawerMenuItemKey.newProject;
                    });
                    Navigator.pop(context);
                    _showCreateProjectDialog(context);
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.description,
                  label: t.translate('reports'),
                  isSelected: _selectedDrawerItem == DrawerMenuItemKey.reports,
                  mutedColor: mutedText,
                  hoverColor: sidebarSection,
                  onTap: () {
                    setState(() {
                      _selectedDrawerItem = DrawerMenuItemKey.reports;
                    });
                    Navigator.pop(context);
                    final projectId = ref.read(selectedProjectIdProvider);
                    if (projectId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.translate('select_project_first')),
                        ),
                      );
                      return;
                    }

                    final projectAsync = ref.read(selectedProjectProvider);
                    projectAsync.whenData((project) {
                      if (project != null) {
                        showLiquidDialog(
                          context: context,
                          builder: (_) => GenerateReportDialog(
                            projectId: project.id,
                            projectName: project.nome,
                          ),
                        );
                      }
                    });
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.menu_book_outlined,
                  label: t.translate('daily_journal'),
                  isSelected:
                      _selectedDrawerItem == DrawerMenuItemKey.dailyJournal,
                  mutedColor: mutedText,
                  hoverColor: sidebarSection,
                  onTap: () {
                    setState(() {
                      _selectedDrawerItem = DrawerMenuItemKey.dailyJournal;
                    });
                    Navigator.pop(context);
                    final projectId = ref.read(selectedProjectIdProvider);
                    if (projectId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.translate('select_project_first')),
                        ),
                      );
                      return;
                    }

                    final projectAsync = ref.read(selectedProjectProvider);
                    projectAsync.whenData((project) {
                      if (project != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DailyJournalScreen(project: project),
                          ),
                        );
                      }
                    });
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.rule_folder_outlined,
                  label: t.translate('ncrs'),
                  isSelected: _selectedDrawerItem == DrawerMenuItemKey.ncrs,
                  mutedColor: mutedText,
                  hoverColor: sidebarSection,
                  onTap: () {
                    setState(() {
                      _selectedDrawerItem = DrawerMenuItemKey.ncrs;
                    });
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NcrScreen(),
                      ),
                    );
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.health_and_safety_outlined,
                  label: t.translate('safety_alerts'),
                  isSelected:
                      _selectedDrawerItem == DrawerMenuItemKey.safetyAlerts,
                  mutedColor: mutedText,
                  hoverColor: sidebarSection,
                  onTap: () {
                    setState(() {
                      _selectedDrawerItem = DrawerMenuItemKey.safetyAlerts;
                    });
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SafetyAlertScreen(),
                      ),
                    );
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.precision_manufacturing,
                  label: t.translate('general_cranes'),
                  isSelected:
                      _selectedDrawerItem == DrawerMenuItemKey.generalCranes,
                  mutedColor: mutedText,
                  hoverColor: sidebarSection,
                  onTap: () {
                    setState(() {
                      _selectedDrawerItem = DrawerMenuItemKey.generalCranes;
                    });
                    Navigator.pop(context);
                    final projectId = ref.read(selectedProjectIdProvider);
                    final projectAsync = ref.read(selectedProjectProvider);
                    if (projectId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.translate('select_project_first')),
                        ),
                      );
                      return;
                    }

                    projectAsync.whenData((project) {
                      if (project != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GruasGeraisScreen(
                              projectId: projectId,
                              projectName: project.nome,
                            ),
                          ),
                        );
                      }
                    });
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.build,
                  label: t.translate('equipment'),
                  isSelected:
                      _selectedDrawerItem == DrawerMenuItemKey.equipment,
                  mutedColor: mutedText,
                  hoverColor: sidebarSection,
                  onTap: () {
                    setState(() {
                      _selectedDrawerItem = DrawerMenuItemKey.equipment;
                    });
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EquipmentScreen(),
                      ),
                    );
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.groups,
                  label: t.translate('team'),
                  isSelected: _selectedDrawerItem == DrawerMenuItemKey.team,
                  mutedColor: mutedText,
                  hoverColor: sidebarSection,
                  onTap: () {
                    final selectedProjectId =
                        ref.read(selectedProjectIdProvider);

                    if (selectedProjectId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.translate('select_project_first')),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _selectedDrawerItem = DrawerMenuItemKey.team;
                    });

                    final projectAsync = ref.read(selectedProjectProvider);
                    final projectName = projectAsync.asData?.value?.nome ?? '';

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeamScreen(
                          projectId: selectedProjectId,
                          projectName: projectName,
                        ),
                      ),
                    );
                  },
                ),
                if (globalPermissions.isDirector)
                  _DrawerMenuItem(
                    icon: Icons.manage_accounts,
                    label: t.translate('users'),
                    isSelected: _selectedDrawerItem == DrawerMenuItemKey.users,
                    mutedColor: mutedText,
                    hoverColor: sidebarSection,
                    onTap: () {
                      final selectedProjectId =
                          ref.read(selectedProjectIdProvider);

                      if (selectedProjectId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.translate('select_project_first')),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _selectedDrawerItem = DrawerMenuItemKey.users;
                      });

                      final projectAsync = ref.read(selectedProjectProvider);
                      final projectName =
                          projectAsync.asData?.value?.nome ?? '';

                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeamScreen(
                            projectId: selectedProjectId,
                            projectName: projectName,
                          ),
                        ),
                      );
                    },
                  ),
                _DrawerMenuItem(
                  icon: Icons.settings,
                  label: t.translate('settings'),
                  isSelected: _selectedDrawerItem == DrawerMenuItemKey.settings,
                  mutedColor: mutedText,
                  hoverColor: sidebarSection,
                  onTap: () {
                    setState(() {
                      _selectedDrawerItem = DrawerMenuItemKey.settings;
                    });
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                _DrawerMenuItem(
                  icon: Icons.help_outline,
                  label: t.translate('help'),
                  isSelected: _selectedDrawerItem == DrawerMenuItemKey.help,
                  mutedColor: mutedText,
                  hoverColor: sidebarSection,
                  onTap: () {
                    setState(() {
                      _selectedDrawerItem = DrawerMenuItemKey.help;
                    });
                    _openHelpScreen(closeDrawer: true);
                  },
                ),
              ],
            ),
          ),
          Divider(color: sidebarBorder),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: MouseRegion(
              onEnter: (_) => setState(() => _isLogoutHovered = true),
              onExit: (_) => setState(() => _isLogoutHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: _isLogoutHovered
                      ? AppColors.errorRed.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => _handleLogout(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: _isLogoutHovered
                                ? AppColors.errorRed
                                : mutedText,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t.translate('logout'),
                            style: TextStyle(
                              fontSize: 13,
                              color: _isLogoutHovered
                                  ? AppColors.errorRed
                                  : mutedText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    showLiquidDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateProjectWizard(),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final t = TranslationHelper.of(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate('confirm_logout')),
        content: Text(t.translate('confirm_logout_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: Text(t.translate('logout')),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }
}

class _ModuleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color foregroundColor;

  const _ModuleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : foregroundColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : foregroundColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color mutedColor;
  final Color hoverColor;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.mutedColor,
    required this.hoverColor,
  });

  @override
  State<_DrawerMenuItem> createState() => _DrawerMenuItemState();
}

class _DrawerMenuItemState extends State<_DrawerMenuItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _isPressed;

    BoxDecoration decoration;
    if (isActive) {
      decoration = BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primaryBlueDark,
          width: 1.5,
        ),
      );
    } else if (_isHovered) {
      decoration = BoxDecoration(
        color: widget.hoverColor,
        borderRadius: BorderRadius.circular(999),
      );
    } else {
      decoration = BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      );
    }

    final foregroundColor = isActive
        ? Colors.white
        : _isHovered
            ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF17324D))
            : widget.mutedColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: decoration,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: widget.onTap,
              onHighlightChanged: (value) {
                if (!mounted) return;
                setState(() => _isPressed = value);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: foregroundColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: foregroundColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// APP SIDEBAR — Permanent sidebar for desktop layout
// ═══════════════════════════════════════════════════════════════════

class AppSidebar extends ConsumerStatefulWidget {
  const AppSidebar({super.key});

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> {
  DrawerMenuItemKey _selectedItem = DrawerMenuItemKey.dashboard;
  bool _isLogoutHovered = false;

  static const Color _bg = Color(0xFF111827);
  static const Color _border = Color(0xFF1F2937);
  static const Color _muted = Color(0xFF9CA3AF);

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _sidebarBackground(BuildContext context) =>
      _isDark(context) ? _bg : const Color(0xFFEAF1F7);

  Color _sidebarBorder(BuildContext context) =>
      _isDark(context) ? _border : const Color(0xFFB8CADB);

  Color _sidebarSection(BuildContext context) =>
      _isDark(context) ? _border : const Color(0xFFD9E5F0);

  Color _sidebarMuted(BuildContext context) =>
      _isDark(context) ? _muted : const Color(0xFF516A83);

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final t = TranslationHelper.of(context);
    final currentModule = ref.watch(currentModuleProvider);
    final globalPermissions = ref.watch(globalPermissionProvider);
    final selectedProjectName =
        ref.watch(selectedProjectProvider).asData?.value?.nome;
    final sidebarBackground = _sidebarBackground(context);
    final sidebarBorder = _sidebarBorder(context);
    final sidebarSection = _sidebarSection(context);
    final sidebarMuted = _sidebarMuted(context);
    final isDark = _isDark(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
        child: Container(
          width: 226,
          decoration: BoxDecoration(
            color: sidebarBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: sidebarBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              children: [
                // ── Logo + Project ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.wind_power,
                                size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'As-Built',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      if (selectedProjectName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          selectedProjectName,
                          style: TextStyle(color: sidebarMuted, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Module toggle ──────────────────────────────────────────
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: sidebarSection,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sidebarBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModuleTab(
                          label: t.translate('as_built'),
                          icon: Icons.assignment_turned_in,
                          isSelected: currentModule == AppModule.asBuilt,
                          mutedColor: sidebarMuted,
                          hoverColor: sidebarSection,
                          onTap: () {
                            ref
                                .read(desktopSelectedItemProvider.notifier)
                                .setItem(DrawerMenuItemKey.dashboard);
                            ref
                                .read(currentModuleProvider.notifier)
                                .setModule(AppModule.asBuilt);
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const DashboardScreen()),
                              (route) => false,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: _ModuleTab(
                          label: t.translate('installation'),
                          icon: Icons.construction,
                          isSelected: currentModule == AppModule.installation,
                          mutedColor: sidebarMuted,
                          hoverColor: sidebarSection,
                          onTap: () {
                            ref
                                .read(currentModuleProvider.notifier)
                                .setModule(AppModule.installation);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const InstallationScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(color: sidebarBorder, height: 18),
                ),

                // ── Nav items ──────────────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
                    children: [
                      _SidebarNavItem(
                        icon: Icons.dashboard,
                        label: t.translate('dashboard'),
                        isSelected:
                            _selectedItem == DrawerMenuItemKey.dashboard,
                        mutedColor: sidebarMuted,
                        hoverColor: sidebarSection,
                        onTap: () {
                          setState(() =>
                              _selectedItem = DrawerMenuItemKey.dashboard);
                          ref
                              .read(desktopSelectedItemProvider.notifier)
                              .setItem(DrawerMenuItemKey.dashboard);
                          ref
                              .read(currentModuleProvider.notifier)
                              .setModule(AppModule.asBuilt);
                        },
                      ),
                      _SidebarNavItem(
                        icon: Icons.add_business,
                        label: t.translate('new_project'),
                        isSelected:
                            _selectedItem == DrawerMenuItemKey.newProject,
                        mutedColor: sidebarMuted,
                        hoverColor: sidebarSection,
                        onTap: () {
                          setState(() =>
                              _selectedItem = DrawerMenuItemKey.newProject);
                          _showCreateProjectDialog(context);
                        },
                      ),
                      _SidebarNavItem(
                        icon: Icons.description,
                        label: t.translate('reports'),
                        isSelected: _selectedItem == DrawerMenuItemKey.reports,
                        mutedColor: sidebarMuted,
                        hoverColor: sidebarSection,
                        onTap: () {
                          setState(
                              () => _selectedItem = DrawerMenuItemKey.reports);
                          final projectId = ref.read(selectedProjectIdProvider);
                          if (projectId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(t.translate('select_project_first'))));
                            return;
                          }
                          ref.read(selectedProjectProvider).whenData((project) {
                            if (project != null) {
                              showLiquidDialog(
                                context: context,
                                builder: (_) => GenerateReportDialog(
                                    projectId: project.id,
                                    projectName: project.nome),
                              );
                            }
                          });
                        },
                      ),
                      _SidebarNavItem(
                        icon: Icons.menu_book_outlined,
                        label: t.translate('daily_journal'),
                        isSelected:
                            _selectedItem == DrawerMenuItemKey.dailyJournal,
                        mutedColor: sidebarMuted,
                        hoverColor: sidebarSection,
                        onTap: () {
                          setState(() =>
                              _selectedItem = DrawerMenuItemKey.dailyJournal);
                          final projectId = ref.read(selectedProjectIdProvider);
                          if (projectId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(t.translate('select_project_first'))));
                            return;
                          }
                          ref
                              .read(desktopSelectedItemProvider.notifier)
                              .setItem(DrawerMenuItemKey.dailyJournal);
                        },
                      ),
                      _SidebarNavItem(
                        icon: Icons.rule_folder_outlined,
                        label: t.translate('ncrs'),
                        isSelected: _selectedItem == DrawerMenuItemKey.ncrs,
                        mutedColor: sidebarMuted,
                        hoverColor: sidebarSection,
                        onTap: () {
                          setState(
                              () => _selectedItem = DrawerMenuItemKey.ncrs);
                          ref
                              .read(desktopSelectedItemProvider.notifier)
                              .setItem(DrawerMenuItemKey.ncrs);
                        },
                      ),
                      _SidebarNavItem(
                        icon: Icons.health_and_safety_outlined,
                        label: t.translate('safety_alerts'),
                        isSelected:
                            _selectedItem == DrawerMenuItemKey.safetyAlerts,
                        mutedColor: sidebarMuted,
                        hoverColor: sidebarSection,
                        onTap: () {
                          setState(() =>
                              _selectedItem = DrawerMenuItemKey.safetyAlerts);
                          ref
                              .read(desktopSelectedItemProvider.notifier)
                              .setItem(DrawerMenuItemKey.safetyAlerts);
                        },
                      ),
                      _SidebarNavItem(
                        icon: Icons.precision_manufacturing,
                        label: t.translate('general_cranes'),
                        isSelected:
                            _selectedItem == DrawerMenuItemKey.generalCranes,
                        mutedColor: sidebarMuted,
                        hoverColor: sidebarSection,
                        onTap: () {
                          setState(() =>
                              _selectedItem = DrawerMenuItemKey.generalCranes);
                          final projectId = ref.read(selectedProjectIdProvider);
                          if (projectId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(t.translate('select_project_first'))));
                            return;
                          }
                          ref
                              .read(desktopSelectedItemProvider.notifier)
                              .setItem(DrawerMenuItemKey.generalCranes);
                        },
                      ),
                      _SidebarNavItem(
                        icon: Icons.build,
                        label: t.translate('equipment'),
                        isSelected:
                            _selectedItem == DrawerMenuItemKey.equipment,
                        mutedColor: sidebarMuted,
                        hoverColor: sidebarSection,
                        onTap: () {
                          setState(() =>
                              _selectedItem = DrawerMenuItemKey.equipment);
                          ref
                              .read(desktopSelectedItemProvider.notifier)
                              .setItem(DrawerMenuItemKey.equipment);
                        },
                      ),
                      _SidebarNavItem(
                        icon: Icons.groups,
                        label: t.translate('team'),
                        isSelected: _selectedItem == DrawerMenuItemKey.team,
                        mutedColor: sidebarMuted,
                        hoverColor: sidebarSection,
                        onTap: () {
                          final projectId = ref.read(selectedProjectIdProvider);
                          if (projectId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(t.translate('select_project_first'))));
                            return;
                          }
                          setState(
                              () => _selectedItem = DrawerMenuItemKey.team);
                          ref
                              .read(desktopSelectedItemProvider.notifier)
                              .setItem(DrawerMenuItemKey.team);
                        },
                      ),
                      if (globalPermissions.isDirector)
                        _SidebarNavItem(
                          icon: Icons.manage_accounts,
                          label: t.translate('users'),
                          isSelected: _selectedItem == DrawerMenuItemKey.users,
                          mutedColor: sidebarMuted,
                          hoverColor: sidebarSection,
                          onTap: () {
                            final projectId =
                                ref.read(selectedProjectIdProvider);
                            if (projectId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(t
                                          .translate('select_project_first'))));
                              return;
                            }
                            setState(
                                () => _selectedItem = DrawerMenuItemKey.users);
                            ref
                                .read(desktopSelectedItemProvider.notifier)
                                .setItem(DrawerMenuItemKey.users);
                          },
                        ),
                      _SidebarNavItem(
                        icon: Icons.settings,
                        label: t.translate('settings'),
                        isSelected: _selectedItem == DrawerMenuItemKey.settings,
                        mutedColor: sidebarMuted,
                        hoverColor: sidebarSection,
                        onTap: () {
                          setState(
                              () => _selectedItem = DrawerMenuItemKey.settings);
                          ref
                              .read(desktopSelectedItemProvider.notifier)
                              .setItem(DrawerMenuItemKey.settings);
                        },
                      ),
                      _SidebarNavItem(
                        icon: Icons.help_outline,
                        label: t.translate('help'),
                        isSelected: _selectedItem == DrawerMenuItemKey.help,
                        mutedColor: sidebarMuted,
                        hoverColor: sidebarSection,
                        onTap: () {
                          setState(
                              () => _selectedItem = DrawerMenuItemKey.help);
                          ref
                              .read(desktopSelectedItemProvider.notifier)
                              .setItem(DrawerMenuItemKey.help);
                        },
                      ),
                    ],
                  ),
                ),

                // ── Logout ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(color: sidebarBorder, height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _isLogoutHovered = true),
                    onExit: (_) => setState(() => _isLogoutHovered = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: _isLogoutHovered
                            ? AppColors.errorRed.withValues(alpha: 0.15)
                            : sidebarSection.withValues(
                                alpha: isDark ? 0.18 : 0.45),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _isLogoutHovered
                              ? AppColors.errorRed.withValues(alpha: 0.22)
                              : sidebarBorder.withValues(alpha: 0.75),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _handleLogoutSidebar(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: _isLogoutHovered
                                      ? AppColors.errorRed
                                      : sidebarMuted,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t.translate('logout'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _isLogoutHovered
                                          ? AppColors.errorRed
                                          : sidebarMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    showLiquidDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateProjectWizard(),
    );
  }

  Future<void> _handleLogoutSidebar(BuildContext context) async {
    final t = TranslationHelper.of(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate('confirm_logout')),
        content: Text(t.translate('confirm_logout_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: Text(t.translate('logout')),
          ),
        ],
      ),
    );
    if (shouldLogout == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// MODULE TAB — Sidebar module toggle button
// ═══════════════════════════════════════════════════════════════════

class _ModuleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color mutedColor;
  final Color hoverColor;

  const _ModuleTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.mutedColor,
    required this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : hoverColor,
          borderRadius: BorderRadius.circular(13),
          boxShadow: isSelected ? AppColors.glassShadow : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : mutedColor,
              size: 18,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : mutedColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SIDEBAR NAV ITEM — Navigation item for AppSidebar
// ═══════════════════════════════════════════════════════════════════

class _SidebarNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color mutedColor;
  final Color hoverColor;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.mutedColor,
    required this.hoverColor,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppColors.primaryGradient : null,
            color:
                (!widget.isSelected && _isHovered) ? widget.hoverColor : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.white.withValues(alpha: 0.12)
                  : ((_isHovered ? widget.hoverColor : Colors.transparent)
                      .withValues(alpha: _isHovered ? 0.95 : 0)),
            ),
            boxShadow: widget.isSelected ? AppColors.glassShadow : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.isSelected
                          ? Colors.white
                          : _isHovered
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF17324D))
                              : widget.mutedColor,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.isSelected
                              ? Colors.white
                              : _isHovered
                                  ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF17324D))
                                  : widget.mutedColor,
                          fontSize: 13,
                          fontWeight: widget.isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
