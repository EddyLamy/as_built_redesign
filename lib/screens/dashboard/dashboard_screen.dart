// lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_map/flutter_map.dart';
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project.dart';
import '../../providers/app_providers.dart';
import '../../providers/permission_provider.dart';
import 'package:as_built/widgets/add_turbina_dialog.dart';
import '../../core/localization/translation_helper.dart';
import '../project/project_phases_screen.dart';
import 'package:as_built/widgets/project_phases_timeline.dart';
import '../../widgets/notification_badge.dart';
import '../../widgets/notifications_panel.dart';
import '../../widgets/enhanced_drawer.dart';
import '../../widgets/create_project_dialog.dart';
import '../../widgets/generate_report_dialog.dart';
import '../turbinas/turbina_detalhes_screen.dart';
import '../../widgets/background_watermark.dart';
import '../../utils/app_feedback.dart';
import '../../utils/map_launcher.dart';
import '../admin/user_management_screen.dart';
import '../daily_journal/daily_journal_screen.dart';
import '../equipment/equipment_screen.dart';
import '../help/help_screen.dart';
import '../mobile/gruas_gerais_screen.dart';
import '../ncr/ncr_screen.dart';
import '../safety_alerts/safety_alert_screen.dart';
import '../settings/settings_screen.dart';
import '../team/team_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  static const LatLng _defaultProjectMapCenter = LatLng(39.6, -8.2);
  final _searchController = TextEditingController();
  final _dailyJournalShellController = DailyJournalShellController();
  final Map<String, GlobalObjectKey<State<StatefulWidget>>> _desktopScreenKeys =
      {};
  late final AnimationController _desktopContentTransitionController;
  DrawerMenuItemKey _activeDesktopItem = DrawerMenuItemKey.dashboard;
  DrawerMenuItemKey? _outgoingDesktopItem;
  Project? _activeDesktopProject;
  Project? _outgoingDesktopProject;
  int _desktopSwipeDirection = 1;
  String _searchQuery = '';
  bool _showFilters = false;
  String _statusFilter = 'All';
  String _progressFilter = 'All';

  @override
  void initState() {
    super.initState();
    _desktopContentTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      reverseDuration: const Duration(milliseconds: 1100),
      value: 1,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _outgoingDesktopItem = null;
            _outgoingDesktopProject = null;
          });
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(desktopSelectedItemProvider.notifier)
            .setItem(DrawerMenuItemKey.dashboard);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dailyJournalShellController.dispose();
    _desktopContentTransitionController.dispose();
    super.dispose();
  }

  bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  Color _mapOverlaySurface(BuildContext context, {double lightAlpha = 0.94}) {
    return AppColors.adaptiveCardSurface(context).withValues(
      alpha: AppColors.isDarkContext(context) ? 0.88 : lightAlpha,
    );
  }

  Color _mapOverlaySecondaryText(BuildContext context) =>
      AppColors.adaptiveSecondaryText(context);

  GlobalObjectKey<State<StatefulWidget>> _desktopScreenKey(String id) {
    return _desktopScreenKeys.putIfAbsent(
      id,
      () => GlobalObjectKey<State<StatefulWidget>>(id),
    );
  }

  IconData _desktopSectionIcon(DrawerMenuItemKey item) {
    switch (item) {
      case DrawerMenuItemKey.dashboard:
        return Icons.dashboard_rounded;
      case DrawerMenuItemKey.dailyJournal:
        return Icons.menu_book_outlined;
      case DrawerMenuItemKey.ncrs:
        return Icons.rule_folder_outlined;
      case DrawerMenuItemKey.safetyAlerts:
        return Icons.health_and_safety_outlined;
      case DrawerMenuItemKey.generalCranes:
        return Icons.precision_manufacturing;
      case DrawerMenuItemKey.equipment:
        return Icons.build;
      case DrawerMenuItemKey.team:
        return Icons.groups;
      case DrawerMenuItemKey.users:
        return Icons.manage_accounts;
      case DrawerMenuItemKey.settings:
        return Icons.settings;
      case DrawerMenuItemKey.help:
        return Icons.help_outline;
      case DrawerMenuItemKey.newProject:
        return Icons.add_business;
      case DrawerMenuItemKey.reports:
        return Icons.description_outlined;
    }
  }

  String _desktopSectionTitle(BuildContext context, DrawerMenuItemKey item) {
    final t = TranslationHelper.of(context);
    switch (item) {
      case DrawerMenuItemKey.dashboard:
        return t.translate('as_built_dashboard');
      case DrawerMenuItemKey.dailyJournal:
        return t.translate('daily_journal');
      case DrawerMenuItemKey.ncrs:
        return t.translate('ncrs');
      case DrawerMenuItemKey.safetyAlerts:
        return t.translate('safety_alerts');
      case DrawerMenuItemKey.generalCranes:
        return t.translate('general_cranes');
      case DrawerMenuItemKey.equipment:
        return t.translate('equipment');
      case DrawerMenuItemKey.team:
        return t.translate('team');
      case DrawerMenuItemKey.users:
        return t.translate('users');
      case DrawerMenuItemKey.settings:
        return t.translate('settings');
      case DrawerMenuItemKey.help:
        return t.translate('help');
      case DrawerMenuItemKey.newProject:
        return t.translate('new_project');
      case DrawerMenuItemKey.reports:
        return t.translate('reports');
    }
  }

  String? _desktopSectionSubtitle(
    DrawerMenuItemKey item, {
    required String? projectName,
    required bool isDirector,
  }) {
    switch (item) {
      case DrawerMenuItemKey.dailyJournal:
      case DrawerMenuItemKey.safetyAlerts:
      case DrawerMenuItemKey.generalCranes:
      case DrawerMenuItemKey.team:
        return projectName;
      case DrawerMenuItemKey.users:
        return isDirector ? 'Roles e acessos globais' : null;
      default:
        return null;
    }
  }

  Widget _buildDesktopSectionContent(
    BuildContext context,
    DrawerMenuItemKey item,
    Project? selectedProject,
  ) {
    switch (item) {
      case DrawerMenuItemKey.dashboard:
        return _buildDashboardContent(context);
      case DrawerMenuItemKey.dailyJournal:
        if (selectedProject == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return DailyJournalScreen(
          key: _desktopScreenKey('daily-journal-${selectedProject.id}'),
          project: selectedProject,
          embeddedInDesktopShell: true,
          shellController: _dailyJournalShellController,
        );
      case DrawerMenuItemKey.ncrs:
        return const NcrScreen(embeddedInDesktopShell: true);
      case DrawerMenuItemKey.safetyAlerts:
        return const SafetyAlertScreen(embeddedInDesktopShell: true);
      case DrawerMenuItemKey.generalCranes:
        if (selectedProject == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return GruasGeraisScreen(
          projectId: selectedProject.id,
          projectName: selectedProject.nome,
          embeddedInDesktopShell: true,
        );
      case DrawerMenuItemKey.equipment:
        return const EquipmentScreen(embeddedInDesktopShell: true);
      case DrawerMenuItemKey.team:
        if (selectedProject == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return TeamScreen(
          projectId: selectedProject.id,
          projectName: selectedProject.nome,
          embeddedInDesktopShell: true,
        );
      case DrawerMenuItemKey.users:
        return const UserManagementScreen(embeddedInDesktopShell: true);
      case DrawerMenuItemKey.settings:
        return const SettingsScreen(embeddedInDesktopShell: true);
      case DrawerMenuItemKey.help:
        return const HelpScreen(embeddedInDesktopShell: true);
      case DrawerMenuItemKey.newProject:
      case DrawerMenuItemKey.reports:
        return _buildDashboardContent(context);
    }
  }

  List<Widget> _buildDesktopSectionActions(
    BuildContext context,
    DrawerMenuItemKey item,
    TranslationHelper t,
    Project? selectedProject,
    dynamic permissions,
  ) {
    switch (item) {
      case DrawerMenuItemKey.dailyJournal:
        if (selectedProject == null) {
          return const [];
        }
        return [
          AnimatedBuilder(
            animation: _dailyJournalShellController,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.adaptiveCardSurface(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.adaptiveOutline(context)),
                ),
                child: IconButton(
                  onPressed: _dailyJournalShellController.isSaving
                      ? null
                      : () => _dailyJournalShellController.save(),
                  tooltip: t.translate('save_daily_journal'),
                  icon: _dailyJournalShellController.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.save_outlined,
                          color: AppColors.adaptiveSecondaryText(context),
                        ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.adaptiveCardSurface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.adaptiveOutline(context)),
            ),
            child: IconButton(
              onPressed: () {
                showLiquidDialog(
                  context: context,
                  builder: (_) => GenerateReportDialog(
                    projectId: selectedProject.id,
                    projectName: selectedProject.nome,
                  ),
                );
              },
              tooltip: t.translate('generate_report'),
              icon: Icon(
                Icons.description_outlined,
                color: AppColors.adaptiveSecondaryText(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ];
      case DrawerMenuItemKey.ncrs:
        if (selectedProject == null) {
          return const [];
        }
        return [
          Container(
            decoration: BoxDecoration(
              color: AppColors.adaptiveCardSurface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.adaptiveOutline(context)),
            ),
            child: IconButton(
              onPressed: () {
                showLiquidDialog(
                  context: context,
                  builder: (_) => GenerateReportDialog(
                    projectId: selectedProject.id,
                    projectName: selectedProject.nome,
                  ),
                );
              },
              tooltip: t.translate('generate_report'),
              icon: Icon(
                Icons.description_outlined,
                color: AppColors.adaptiveSecondaryText(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ];
      case DrawerMenuItemKey.safetyAlerts:
        return const [];
      case DrawerMenuItemKey.equipment:
        return [
          Container(
            decoration: BoxDecoration(
              color: AppColors.adaptiveCardSurface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.adaptiveOutline(context)),
            ),
            child: IconButton(
              onPressed: permissions.isLoading
                  ? null
                  : () => showAddEquipmentDialogForShell(
                        context,
                        ref,
                        t,
                      ),
              tooltip: t.translate('add'),
              icon: permissions.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.add,
                      color: AppColors.adaptiveSecondaryText(context),
                    ),
            ),
          ),
          const SizedBox(width: 8),
        ];
      default:
        return const [];
    }
  }

  Widget _buildAnimatedDesktopContent(
    BuildContext context,
    DrawerMenuItemKey item,
    Project? selectedProject,
  ) {
    final previousActiveProject = _activeDesktopProject;

    if (item == _activeDesktopItem) {
      _activeDesktopProject = selectedProject;
    }

    if (item != _activeDesktopItem) {
      _desktopSwipeDirection = item.index >= _activeDesktopItem.index ? 1 : -1;
      _outgoingDesktopItem = _activeDesktopItem;
      _outgoingDesktopProject = previousActiveProject;
      _activeDesktopItem = item;
      _activeDesktopProject = selectedProject;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _desktopContentTransitionController.forward(from: 0);
        }
      });
    }

    if (_outgoingDesktopItem == null) {
      return KeyedSubtree(
        key:
            ValueKey('${_activeDesktopItem.toString()}-${selectedProject?.id}'),
        child: _buildDesktopSectionContent(
          context,
          _activeDesktopItem,
          _activeDesktopProject,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _desktopContentTransitionController,
      builder: (context, _) {
        final rawProgress = _desktopContentTransitionController.isAnimating
            ? _desktopContentTransitionController.value
            : 0.0;
        final progress = Curves.easeInOutCubicEmphasized.transform(rawProgress);
        final incomingOffset = (1 - progress) * _desktopSwipeDirection;
        final outgoingOffset = -progress * _desktopSwipeDirection;

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FractionalTranslation(
                translation: Offset(outgoingOffset.toDouble(), 0),
                child: KeyedSubtree(
                  key: ValueKey(
                    '${_outgoingDesktopItem.toString()}-${_outgoingDesktopProject?.id}-outgoing',
                  ),
                  child: _buildDesktopSectionContent(
                    context,
                    _outgoingDesktopItem!,
                    _outgoingDesktopProject,
                  ),
                ),
              ),
              FractionalTranslation(
                translation: Offset(incomingOffset.toDouble(), 0),
                child: KeyedSubtree(
                  key: ValueKey(
                    '${_activeDesktopItem.toString()}-${_activeDesktopProject?.id}-incoming',
                  ),
                  child: _buildDesktopSectionContent(
                    context,
                    _activeDesktopItem,
                    _activeDesktopProject,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDesktopSectionHeader(
    BuildContext context, {
    required DrawerMenuItemKey selectedDesktopItem,
    required String? projectName,
    required bool isDirector,
    required Color primaryText,
    required Color secondaryText,
  }) {
    final subtitle = _desktopSectionSubtitle(
      selectedDesktopItem,
      projectName: projectName,
      isDirector: isDirector,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(
          '${selectedDesktopItem.toString()}-$projectName-$isDirector',
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _desktopSectionIcon(selectedDesktopItem),
              color: primaryText,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _desktopSectionTitle(context, selectedDesktopItem),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryText,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDesktopSectionActions(
    BuildContext context, {
    required DrawerMenuItemKey selectedDesktopItem,
    required TranslationHelper t,
    required Project? selectedProject,
    required dynamic permissions,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(selectedDesktopItem.toString()),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildDesktopSectionActions(
            context,
            selectedDesktopItem,
            t,
            selectedProject,
            permissions,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final user = FirebaseAuth.instance.currentUser;

    final currentModule = ref.watch(currentModuleProvider);
    if (currentModule != AppModule.asBuilt) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentModuleProvider.notifier).setModule(AppModule.asBuilt);
      });
    }
    final projectsAsync = ref.watch(userProjectsProvider);
    final selectedProjectId = ref.watch(accessibleSelectedProjectIdProvider);
    final selectedProject = ref.watch(selectedProjectProvider).asData?.value;

    // Permissões baseadas no projeto selecionado
    final permissions = ref.watch(permissionProvider(selectedProjectId));
    final canCreateTurbine = selectedProjectId != null &&
        (permissions.canManageInstallation ||
            permissions.canManageProjects ||
            selectedProject?.userId == user?.uid);
    final canDeleteProject = selectedProjectId != null &&
        (permissions.canManageProjects || selectedProject?.userId == user?.uid);

    debugPrint('═══════════════════════════════════');
    debugPrint('🔵 DASHBOARD BUILD');
    debugPrint('🔵 USER EMAIL: ${user?.email ?? "NULL"}');
    debugPrint('🔵 CURRENT MODULE: $currentModule');
    debugPrint('═══════════════════════════════════');

    final notificationsAsync = ref.watch(notificationsProvider);
    notificationsAsync.whenData((notifications) {
      debugPrint('🔔 TOTAL NOTIFICAÇÕES: ${notifications.length}');
    });

    if (!_isMobile) return _buildDesktopLayout(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const _HamburgerLikeIcon(),
          ),
        ),
        title: Row(
          children: [
            Text(t.translate('as_built_dashboard')),
            const SizedBox(width: 16),

            // Dropdown de projetos
            projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) return const SizedBox.shrink();

                final selectedId =
                    projects.any((p) => p.id == selectedProjectId)
                        ? selectedProjectId
                        : null;
                final selectedName = selectedId == null
                    ? null
                    : projects
                        .firstWhere((project) => project.id == selectedId)
                        .nome;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: selectedId,
                        hint: Text(
                          t.translate('select_project'),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        dropdownColor: AppColors.primaryBlue,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        items: projects.map((project) {
                          return DropdownMenuItem(
                            value: project.id,
                            child: Text(
                              project.nome,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (projectId) {
                          if (projectId != null) {
                            ref
                                .read(selectedProjectIdProvider.notifier)
                                .setValue(projectId);
                          }
                        },
                      ),
                    ),
                    if (canDeleteProject && selectedId != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: t.translate('delete_project'),
                        onPressed: () => _showDeleteProjectDialog(
                          context,
                          selectedId,
                          selectedName ?? '',
                        ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          NotificationBadge(
            onTap: () {
              showLiquidDialog(
                context: context,
                barrierColor: Colors.black54,
                builder: (context) => const Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    type: MaterialType.transparency,
                    child: NotificationsPanel(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const EnhancedDrawer(),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _buildEmptyState(context);
          }

          final hasSelectedProjectAccess = selectedProjectId != null &&
              projects.any((project) => project.id == selectedProjectId);

          if (selectedProjectId != null && !hasSelectedProjectAccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(selectedProjectIdProvider.notifier)
                  .setValue(projects.first.id);
            });
            return const Center(child: CircularProgressIndicator());
          }

          if (selectedProjectId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(selectedProjectIdProvider.notifier)
                  .setValue(projects.first.id);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return _buildDashboardContent(context);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),

      // ════════════════════════════════════════════════════════
      // FAB — só para quem pode gerir instalação
      // ════════════════════════════════════════════════════════
      floatingActionButton: canCreateTurbine
          ? Tooltip(
              message: t.translate('add_turbine'),
              waitDuration: const Duration(milliseconds: 500),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      _showAddTurbinaDialog(context, selectedProjectId),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.accentCyan,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.wind_power,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final t = TranslationHelper.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final projectsAsync = ref.watch(userProjectsProvider);
    final selectedProjectId = ref.watch(accessibleSelectedProjectIdProvider);
    final selectedProject = ref.watch(selectedProjectProvider).asData?.value;
    final selectedDesktopItem = ref.watch(desktopSelectedItemProvider);
    final permissions = ref.watch(permissionProvider(selectedProjectId));
    final canCreateTurbine = selectedProjectId != null &&
        (permissions.canManageInstallation ||
            permissions.canManageProjects ||
            selectedProject?.userId == user?.uid);
    final canDeleteProject = selectedProjectId != null &&
        (permissions.canManageProjects || selectedProject?.userId == user?.uid);

    final projects = projectsAsync.asData?.value ?? [];
    final selectedId = projects.any((p) => p.id == selectedProjectId)
        ? selectedProjectId
        : null;
    final selectedName = selectedId == null
        ? null
        : projects.firstWhere((p) => p.id == selectedId).nome;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topBarColor = AppColors.adaptivePanelSurface(context);
    final topBarBorder = AppColors.adaptiveOutline(context);
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final controlColor = AppColors.adaptiveCardSurface(context);
    final isDirector = ref.watch(globalPermissionProvider).isDirector;

    final body = projectsAsync.when(
      data: (projs) {
        if (projs.isEmpty) return _buildEmptyState(context);
        final hasAccess = selectedProjectId != null &&
            projs.any((p) => p.id == selectedProjectId);
        if (selectedProjectId != null && !hasAccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(selectedProjectIdProvider.notifier)
                .setValue(projs.first.id);
          });
          return const Center(child: CircularProgressIndicator());
        }
        if (selectedProjectId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(selectedProjectIdProvider.notifier)
                .setValue(projs.first.id);
          });
          return const Center(child: CircularProgressIndicator());
        }
        return _buildAnimatedDesktopContent(
          context,
          selectedDesktopItem,
          selectedProject,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: Column(
              children: [
                // ─── Top bar ────────────────────────────────────────
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 12, 16, 0),
                    child: Container(
                      height: 68,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: topBarColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: topBarBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: isDark ? 0.18 : 0.07),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildAnimatedDesktopSectionHeader(
                            context,
                            selectedDesktopItem: selectedDesktopItem,
                            projectName: selectedProject?.nome,
                            isDirector: isDirector,
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                          ),
                          const SizedBox(width: 20),
                          if (projects.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: controlColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: topBarBorder),
                              ),
                              child: DropdownButton<String>(
                                value: selectedId,
                                hint: Text(
                                  t.translate('select_project'),
                                  style: TextStyle(
                                      color: secondaryText, fontSize: 13),
                                ),
                                dropdownColor: controlColor,
                                underline: const SizedBox.shrink(),
                                icon: Icon(Icons.arrow_drop_down,
                                    color: secondaryText),
                                style:
                                    TextStyle(color: primaryText, fontSize: 13),
                                items: projects
                                    .map((p) => DropdownMenuItem(
                                          value: p.id,
                                          child: Text(p.nome,
                                              style: TextStyle(
                                                  color: primaryText)),
                                        ))
                                    .toList(),
                                onChanged: (id) {
                                  if (id != null) {
                                    ref
                                        .read(
                                            selectedProjectIdProvider.notifier)
                                        .setValue(id);
                                  }
                                },
                              ),
                            ),
                          if (canDeleteProject && selectedId != null)
                            ...[].followedBy([
                              const SizedBox(width: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: controlColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: topBarBorder),
                                ),
                                child: IconButton(
                                  tooltip: t.translate('delete_project'),
                                  onPressed: () => _showDeleteProjectDialog(
                                      context, selectedId, selectedName ?? ''),
                                  icon: Icon(Icons.delete_outline,
                                      color: secondaryText),
                                  iconSize: 20,
                                ),
                              ),
                            ]),
                          _buildAnimatedDesktopSectionActions(
                            context,
                            selectedDesktopItem: selectedDesktopItem,
                            t: t,
                            selectedProject: selectedProject,
                            permissions: permissions,
                          ),
                          const Spacer(),
                          NotificationBadge(
                            onTap: () {
                              showLiquidDialog(
                                context: context,
                                barrierColor: Colors.black54,
                                builder: (context) => const Align(
                                  alignment: Alignment.centerRight,
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: NotificationsPanel(),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                // ─── Content ────────────────────────────────────────
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          selectedDesktopItem == DrawerMenuItemKey.dashboard && canCreateTurbine
              ? Tooltip(
                  message: t.translate('add_turbine'),
                  waitDuration: const Duration(milliseconds: 500),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          _showAddTurbinaDialog(context, selectedProjectId),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.accentCyan,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primaryBlue.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wind_power,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final t = TranslationHelper.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        BackgroundWatermark(
          size: 320,
          opacity: isDark ? 0.05 : 0.08,
          alignment: Alignment.center,
          color: isDark ? Colors.white : AppColors.primaryBlue,
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 100,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.42)
                    : AppColors.mediumGray,
              ),
              const SizedBox(height: 24),
              Text(
                t.translate('no_projects_yet'),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              Text(
                t.translate('create_first_project'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _showCreateProjectDialog(context),
                icon: const Icon(Icons.add),
                label: Text(t.translate('create_project')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final projectAsync = ref.watch(selectedProjectProvider);
    final turbinasAsync = ref.watch(projectTurbinasProvider);
    final statsAsync = ref.watch(projectStatisticsProvider);
    final selectedProjectId = ref.watch(accessibleSelectedProjectIdProvider);
    final permissions = ref.watch(permissionProvider(selectedProjectId));
    final t = TranslationHelper.of(context);

    return Stack(
      children: [
        const BackgroundWatermark(
          size: 500,
          opacity: 0.03,
          alignment: Alignment.center,
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              projectAsync.when(
                data: (project) => project != null
                    ? _buildProjectHeader(context, project)
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              statsAsync.when(
                data: (stats) => _buildKPICards(stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, _) {
                  final selectedProjectId =
                      ref.watch(selectedProjectIdProvider);
                  if (selectedProjectId == null) return const SizedBox.shrink();
                  return ProjectPhasesTimeline(projectId: selectedProjectId);
                },
              ),
              Row(
                children: [
                  Text(
                    t.translate('turbines'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search turbines...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _showFilters
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                      color: _showFilters ? AppColors.primaryBlue : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    tooltip: 'Filters',
                  ),
                ],
              ),
              if (_showFilters) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final t = TranslationHelper.of(context);
                                  return DropdownButtonFormField<String>(
                                    initialValue: [
                                      'All',
                                      'Planejada',
                                      'Em Instalação',
                                      'Instalada',
                                      'Comissionada'
                                    ].contains(_statusFilter)
                                        ? _statusFilter
                                        : 'All',
                                    decoration: InputDecoration(
                                      labelText: t.translate('status'),
                                      border: const OutlineInputBorder(),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    selectedItemBuilder:
                                        (BuildContext context) {
                                      return [
                                        'All',
                                        'Planejada',
                                        'Em Instalação',
                                        'Instalada',
                                        'Comissionada',
                                      ]
                                          .map((s) =>
                                              Text(t.translate('status_$s')))
                                          .toList();
                                    },
                                    items: [
                                      'All',
                                      'Planejada',
                                      'Em Instalação',
                                      'Instalada',
                                      'Comissionada',
                                    ]
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                  t.translate('status_$s')),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => _statusFilter = value);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: [
                                  'All',
                                  'Not Started (0%)',
                                  'In Progress (1-99%)',
                                  'Completed (100%)',
                                ].contains(_progressFilter)
                                    ? _progressFilter
                                    : 'All',
                                decoration: const InputDecoration(
                                  labelText: 'Progress',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: [
                                  'All',
                                  'Not Started (0%)',
                                  'In Progress (1-99%)',
                                  'Completed (100%)',
                                ]
                                    .map((s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _progressFilter = value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _statusFilter = 'All';
                                  _progressFilter = 'All';
                                });
                              },
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Clear'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              turbinasAsync.when(
                data: (turbinas) {
                  final filteredTurbinas = turbinas.where((turbina) {
                    final matchesSearch = turbina.nome
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                    final normalizedStatus =
                        _normalizeStatusForFilter((turbina.status).toString());
                    final matchesStatus = _statusFilter == 'All' ||
                        normalizedStatus == _statusFilter;
                    final matchesProgress = _progressFilter == 'All' ||
                        (_progressFilter == 'Not Started (0%)' &&
                            turbina.progresso == 0) ||
                        (_progressFilter == 'In Progress (1-99%)' &&
                            turbina.progresso > 0 &&
                            turbina.progresso < 100) ||
                        (_progressFilter == 'Completed (100%)' &&
                            turbina.progresso == 100);
                    return matchesSearch && matchesStatus && matchesProgress;
                  }).toList();

                  if (filteredTurbinas.isEmpty) {
                    return _buildNoResultsCard(context);
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: filteredTurbinas
                        .map((turbina) => SizedBox(
                              width: 100,
                              child: _buildTurbinaCard(context, turbina,
                                  permissions.canManageInstallation),
                            ))
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Error loading turbines')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsCard(BuildContext context) {
    final t = TranslationHelper.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.search_off,
                  size: 64, color: AppColors.mediumGray),
              const SizedBox(height: 16),
              Text(
                t.translate('no_turbines_found'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                t.translate('try_adjusting_search'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectHeader(BuildContext context, project) {
    final t = TranslationHelper.of(context);
    if (_isMobile) {
      return _buildProjectInfoCard(context, project, t);
    }

    final rawLocation = _projectRawLocation(project);
    final coordinates = MapLauncher.tryParseCoordinates(rawLocation);
    const headerCardHeight = 158.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            height: headerCardHeight,
            child: _buildProjectInfoCard(context, project, t),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: headerCardHeight,
            child: _buildProjectMapCard(
              context,
              project,
              t,
              coordinates,
              rawLocation,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectInfoCard(
      BuildContext context, dynamic project, TranslationHelper t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.business,
                size: 24,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.nome,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${project.projectId} • ${project.turbineType}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if ((project.localizacao ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      project.localizacao.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, _) {
                      final selectedProjectId =
                          ref.watch(selectedProjectIdProvider);
                      final progressAsync = ref.watch(
                          projectPhasesProgressProvider(selectedProjectId!));
                      return progressAsync.when(
                        data: (progress) => Row(
                          children: [
                            const Icon(Icons.timeline,
                                size: 16, color: AppColors.primaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              'Fases: ${progress.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Tooltip(
              message: t.translate('view_phases'),
              waitDuration: const Duration(milliseconds: 500),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProjectPhasesScreen(
                          projectId: project.id,
                          projectName: project.nome,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.accentCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.view_list,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectMapCard(
    BuildContext context,
    dynamic project,
    TranslationHelper t,
    ParsedCoordinates? coordinates,
    String rawLocation,
  ) {
    final mapLabel = _projectMapLabel(project);
    final mapCenter = coordinates != null
        ? LatLng(coordinates.latitude, coordinates.longitude)
        : _defaultProjectMapCenter;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox.expand(
        child: Tooltip(
          message: coordinates == null
              ? 'Definir coordenadas do projeto'
              : 'Abrir no mapa ou atualizar coordenadas',
          waitDuration: const Duration(milliseconds: 500),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                if (coordinates == null) {
                  await _showProjectCoordinatePicker(context, project);
                  return;
                }

                final opened = await MapLauncher.openLocation(rawLocation);
                if (!opened && context.mounted) {
                  showAppFeedback(
                    t.translate('unable_to_open_map'),
                    type: AppFeedbackType.warning,
                  );
                }
              },
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: mapCenter,
                      initialZoom: coordinates == null ? 6.6 : 10.5,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.asbuilt.app',
                      ),
                      if (coordinates != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                coordinates.latitude,
                                coordinates.longitude,
                              ),
                              width: 52,
                              height: 52,
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.errorRed,
                                size: 34,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _mapOverlaySurface(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.adaptiveOutline(context)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          coordinates == null
                              ? Icons.edit_location_alt
                              : Icons.open_in_new,
                          size: 18,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  if (coordinates == null)
                    Positioned(
                      left: 14,
                      right: 14,
                      top: 14,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _mapOverlaySurface(context),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.adaptiveOutline(context),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Text(
                              'Sem coordenadas',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _mapOverlaySurface(context, lightAlpha: 0.92),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.adaptiveOutline(context)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mapLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGray,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              coordinates != null
                                  ? coordinates.displayValue
                                  : 'Clique para escolher as coordenadas do projeto',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: _mapOverlaySecondaryText(context),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showProjectCoordinatePicker(
    BuildContext context,
    dynamic project,
  ) async {
    final initialValue = project.coordenadasGPS?.toString().trim() ?? '';
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _DashboardProjectCoordinateDialog(
        initialValue: initialValue,
        projectName: project.nome?.toString() ?? 'Projeto',
      ),
    );

    if (result == null) {
      return;
    }

    final value = result.trim();
    final parsedCoordinates = MapLauncher.tryParseCoordinates(value);
    if (parsedCoordinates == null) {
      if (!context.mounted) {
        return;
      }
      showAppFeedback(
        'Coordenadas inválidas.',
        type: AppFeedbackType.warning,
      );
      return;
    }

    try {
      await ref.read(projectServiceProvider).updateProject(project.id, {
        'coordenadasGPS': MapLauncher.formatCoordinates(
          parsedCoordinates.latitude,
          parsedCoordinates.longitude,
        ),
      });

      if (!context.mounted) {
        return;
      }
      showAppFeedback(
        'Coordenadas do projeto gravadas.',
        type: AppFeedbackType.success,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      showAppFeedback(
        'Nao foi possivel gravar as coordenadas.',
        type: AppFeedbackType.error,
      );
    }
  }

  String _projectRawLocation(dynamic project) {
    final coordinates = project.coordenadasGPS?.toString().trim() ?? '';
    if (coordinates.isNotEmpty) {
      return coordinates;
    }

    return project.localizacao?.toString().trim() ?? '';
  }

  String _projectMapLabel(dynamic project) {
    final projectName = project.nome?.toString().trim() ?? '';
    if (projectName.isNotEmpty) {
      return projectName;
    }

    final location = project.localizacao?.toString().trim() ?? '';
    if (location.isNotEmpty) {
      return location;
    }

    return 'Site';
  }

  Widget _buildKPICards(Map<String, dynamic> stats) {
    final totalTurbinas = stats['totalTurbinas'] ?? 0;
    final progressoMedio = stats['progressoMedio'] ?? 0.0;
    final emInstalacao = stats['emInstalacao'] ?? 0;
    final instaladas = stats['instaladas'] ?? 0;
    final t = TranslationHelper.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildKPICard(
            t.translate('total_turbines'),
            totalTurbinas.toString(),
            Icons.wind_power,
            AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            t.translate('average_progress'),
            '${progressoMedio.toStringAsFixed(1)}%',
            Icons.trending_up,
            AppColors.accentTeal,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            t.translate('in_installation'),
            emInstalacao.toString(),
            Icons.construction,
            AppColors.warningOrange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            t.translate('installed'),
            instaladas.toString(),
            Icons.check_circle,
            AppColors.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: AppColors.mediumGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurbinaCard(BuildContext context, turbina, bool canDelete) {
    final t = TranslationHelper.of(context);
    final color = AppColors.getStatusColor(
      _normalizeStatusForColor((turbina.status).toString()),
    );

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TurbinaDetalhesScreen(
                turbinaId: turbina.id,
                numberOfMiddleSections: turbina.numberOfMiddleSections,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.wind_power, color: color, size: 14),
                  ),
                  // Botão de apagar só visível para quem tem permissão
                  if (canDelete)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.errorRed),
                      iconSize: 14,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () =>
                          _showDeleteTurbinaDialog(context, turbina),
                      tooltip: 'Delete',
                    )
                  else
                    const SizedBox(width: 14),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                turbina.nome,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                t.translateStatus(turbina.status),
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.mediumGray,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: turbina.progresso / 100,
                backgroundColor: AppColors.borderGray,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 3,
              ),
              const SizedBox(height: 3),
              Text(
                '${turbina.progresso.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _normalizeStatusForFilter(String status) {
    final rawStatus = status.startsWith('status_')
        ? status.substring(7).trim()
        : status.trim();

    switch (rawStatus.toLowerCase()) {
      case 'pending':
      case 'pendente':
        return 'Planejada';
      case 'in progress':
      case 'em progresso':
        return 'Em Instalação';
      case 'completed':
      case 'concluído':
      case 'concluido':
        return 'Instalada';
      default:
        return rawStatus;
    }
  }

  String _normalizeStatusForColor(String status) {
    return status.startsWith('status_') ? status.substring(7).trim() : status;
  }

  void _showCreateProjectDialog(BuildContext context) {
    showLiquidDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateProjectWizard(),
    );
  }

  void _showAddTurbinaDialog(BuildContext context, String projectId) {
    showLiquidDialog(
      context: context,
      builder: (context) => AddTurbinaDialog(projectId: projectId),
    );
  }

  Future<void> _showDeleteProjectDialog(
    BuildContext context,
    String projectId,
    String projectName,
  ) async {
    final t = TranslationHelper.of(context);
    final confirmed = await showLiquidDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 12),
            Text(t.translate('delete_project')),
          ],
        ),
        content: Text(
          '${t.translate('delete_project_confirm')} "$projectName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: Text(t.translate('delete')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(projectServiceProvider).deleteProject(projectId);
      ref.read(selectedProjectIdProvider.notifier).setValue(null);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate('project_deleted_success')),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (_) {
      final projectDoc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .get();

      if (!projectDoc.exists) {
        ref.read(selectedProjectIdProvider.notifier).setValue(null);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('project_deleted_success')),
            backgroundColor: AppColors.successGreen,
          ),
        );
        return;
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate('delete_project_error')),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _showDeleteTurbinaDialog(BuildContext context, turbina) {
    final t = TranslationHelper.of(context);
    showLiquidDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 12),
            Text(t.translate('delete_turbine')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.translate('delete_turbine_confirm')} "${turbina.nome}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.errorRed.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.errorRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.translate('delete_all_components_warning'),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.errorRed),
                    ),
                  ),
                ],
              ),
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
              try {
                final turbinaService = ref.read(turbinaServiceProvider);
                final projectService = ref.read(projectServiceProvider);

                await turbinaService.deleteTurbina(turbina.id);
                await projectService.decrementTotalTurbinas(turbina.projectId);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Turbine "${turbina.nome}" deleted'),
                      backgroundColor: AppColors.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${t.translate('turbine_deleted')}: "${turbina.nome}"'),
                      backgroundColor: AppColors.errorRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DashboardProjectCoordinateDialog extends StatefulWidget {
  const _DashboardProjectCoordinateDialog({
    required this.initialValue,
    required this.projectName,
  });

  final String initialValue;
  final String projectName;

  @override
  State<_DashboardProjectCoordinateDialog> createState() =>
      _DashboardProjectCoordinateDialogState();
}

class _DashboardProjectCoordinateDialogState
    extends State<_DashboardProjectCoordinateDialog> {
  late final TextEditingController _coordinatesController;
  late final MapController _mapController;
  LatLng? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _coordinatesController = TextEditingController(text: widget.initialValue);
    _mapController = MapController();

    final initialCoordinates =
        MapLauncher.tryParseCoordinates(widget.initialValue);
    if (initialCoordinates != null) {
      _selectedPoint =
          LatLng(initialCoordinates.latitude, initialCoordinates.longitude);
    }
  }

  @override
  void dispose() {
    _coordinatesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCoordinates =
        MapLauncher.tryParseCoordinates(_coordinatesController.text);

    return Dialog(
      child: SizedBox(
        width: 980,
        height: 720,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined,
                      color: AppColors.primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Definir coordenadas do projeto',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.projectName,
                          style: const TextStyle(color: AppColors.mediumGray),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _selectedPoint ??
                                _DashboardScreenState._defaultProjectMapCenter,
                            initialZoom: _selectedPoint == null ? 6.6 : 12,
                            onTap: (_, point) => _selectPoint(point),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.asbuilt.app',
                            ),
                            if (_selectedPoint != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _selectedPoint!,
                                    width: 60,
                                    height: 60,
                                    child: const Icon(
                                      Icons.location_on,
                                      size: 40,
                                      color: AppColors.errorRed,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Clique no mapa para escolher as coordenadas ou introduza-as manualmente.',
                      style: TextStyle(color: AppColors.mediumGray),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _coordinatesController,
                      onChanged: _handleManualCoordinateChange,
                      decoration: const InputDecoration(
                        labelText: 'Coordenadas GPS',
                        hintText: 'Ex: 38.7223, -9.1393',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedCoordinates?.displayValue ??
                          'Nenhuma coordenada selecionada.',
                      style: TextStyle(
                        color: selectedCoordinates != null
                            ? AppColors.primaryBlue
                            : AppColors.mediumGray,
                        fontWeight: selectedCoordinates != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _coordinatesController.clear();
                      setState(() {
                        _selectedPoint = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpar seleção'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(
                          _coordinatesController.text.trim(),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPoint(LatLng point) {
    setState(() {
      _selectedPoint = point;
      _coordinatesController.text =
          MapLauncher.formatCoordinates(point.latitude, point.longitude);
    });
  }

  void _handleManualCoordinateChange(String value) {
    final parsedCoordinates = MapLauncher.tryParseCoordinates(value);
    if (parsedCoordinates == null) {
      setState(() {});
      return;
    }

    final point =
        LatLng(parsedCoordinates.latitude, parsedCoordinates.longitude);
    setState(() {
      _selectedPoint = point;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _mapController.move(point, 12);
    });
  }
}

class _HamburgerLikeIcon extends StatelessWidget {
  const _HamburgerLikeIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        children: [
          Positioned(
            top: 1,
            left: 1,
            right: 1,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.white, width: 1.8),
              ),
              alignment: const Alignment(0.72, 0),
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 1,
            left: 1,
            right: 1,
            child: Container(
              height: 13,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.white, width: 1.8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 1.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 2.3),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 9,
                        height: 1.8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
