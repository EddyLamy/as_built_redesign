import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import 'package:as_built/widgets/add_turbina_dialog.dart';
import '../../core/localization/translation_helper.dart';
import '../project/project_phases_screen.dart';
import 'package:as_built/widgets/project_phases_timeline.dart';
import '../../widgets/notification_badge.dart';
import '../../widgets/notifications_panel.dart';
import '../../widgets/enhanced_drawer.dart';
import '../../widgets/create_project_dialog.dart';
import '../turbinas/turbina_detalhes_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showFilters = false;
  String _statusFilter = 'All';
  String _progressFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final user = FirebaseAuth.instance.currentUser;

    // ============================================================================
    // 🎯 VERIFICAR MÓDULO ATUAL
    // ============================================================================
    final currentModule = ref.watch(currentModuleProvider);

    print('═══════════════════════════════════');
    print('🔵 DASHBOARD BUILD');
    print('🔵 USER EMAIL: ${user?.email ?? "NULL"}');
    print('🔵 CURRENT MODULE: $currentModule');
    print('═══════════════════════════════════');

    final projectsAsync = ref.watch(userProjectsProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);

    // Debug notifications
    final notificationsAsync = ref.watch(notificationsProvider);
    notificationsAsync.whenData((notifications) {
      print('🔔 TOTAL NOTIFICAÇÕES: ${notifications.length}');
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(t.translate('as_built_dashboard')),
            SizedBox(width: 16),

            // ============================================================================
            // 🎯 INDICADOR DE MÓDULO
            // ============================================================================
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    currentModule == AppModule.asBuilt
                        ? Icons.assignment_turned_in
                        : Icons.construction,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6),
                  Text(
                    currentModule == AppModule.asBuilt
                        ? 'As-Built'
                        : 'Instalação',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16),

            // Dropdown de projetos
            projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) return SizedBox.shrink();

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: projects.any((p) => p.id == selectedProjectId)
                        ? selectedProjectId
                        : null,
                    hint: Text(
                      t.translate('select_project'),
                      style: TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: AppColors.primaryBlue,
                    underline: SizedBox.shrink(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    items: projects.map((project) {
                      return DropdownMenuItem(
                        value: project.id,
                        child: Text(
                          project.nome,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (projectId) {
                      if (projectId != null) {
                        ref.read(selectedProjectIdProvider.notifier).state =
                            projectId;
                      }
                    },
                  ),
                );
              },
              loading: () => SizedBox.shrink(),
              error: (_, __) => SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          // Notification Badge
          NotificationBadge(
            onTap: () {
              showDialog(
                context: context,
                barrierColor: Colors.black54,
                builder: (context) => Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    type: MaterialType.transparency,
                    child: NotificationsPanel(),
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.accentTeal,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),

      // ============================================================================
      // 🎯 USA O NOVO ENHANCED DRAWER
      // ============================================================================
      drawer: EnhancedDrawer(),

      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _buildEmptyState(context);
          }

          if (selectedProjectId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(selectedProjectIdProvider.notifier).state =
                  projects.first.id;
            });
            return Center(child: CircularProgressIndicator());
          }

          return _buildDashboardContent(context);
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: selectedProjectId != null
          ? FloatingActionButton(
              onPressed: () =>
                  _showAddTurbinaDialog(context, selectedProjectId),
              tooltip: t.translate('add_turbine'),
              child: Icon(Icons.wind_power),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final t = TranslationHelper.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 100, color: AppColors.mediumGray),
          SizedBox(height: 24),
          Text(
            t.translate('no_projects_yet'),
            style: Theme.of(context).textTheme.displaySmall,
          ),
          SizedBox(height: 16),
          Text(
            t.translate('create_first_project'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateProjectDialog(context),
            icon: Icon(Icons.add),
            label: Text(t.translate('create_project')),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final projectAsync = ref.watch(selectedProjectProvider);
    final turbinasAsync = ref.watch(projectTurbinasProvider);
    final statsAsync = ref.watch(projectStatisticsProvider);
    final t = TranslationHelper.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          projectAsync.when(
            data: (project) => project != null
                ? _buildProjectHeader(context, project)
                : SizedBox.shrink(),
            loading: () => SizedBox.shrink(),
            error: (_, __) => SizedBox.shrink(),
          ),
          SizedBox(height: 24),

          statsAsync.when(
            data: (stats) => _buildKPICards(stats),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (_, __) => SizedBox.shrink(),
          ),
          SizedBox(height: 24),

          // Timeline das fases
          Consumer(
            builder: (context, ref, _) {
              final selectedProjectId = ref.watch(selectedProjectIdProvider);
              if (selectedProjectId == null) return SizedBox.shrink();

              return ProjectPhasesTimeline(projectId: selectedProjectId);
            },
          ),

          // Search bar INLINE
          Row(
            children: [
              Text(
                t.translate('turbines'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Spacer(),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search turbines...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
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
                    contentPadding: EdgeInsets.symmetric(
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
              SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
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

          // Painel de filtros (expansível)
          if (_showFilters) ...[
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
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
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                selectedItemBuilder: (BuildContext context) {
                                  return [
                                    'All',
                                    'Planejada',
                                    'Em Instalação',
                                    'Instalada',
                                    'Comissionada',
                                  ]
                                      .map(
                                          (s) => Text(t.translate('status_$s')))
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
                                          child: Text(t.translate('status_$s')),
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
                        SizedBox(width: 16),
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
                            decoration: InputDecoration(
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
                        SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _statusFilter = 'All';
                              _progressFilter = 'All';
                            });
                          },
                          icon: Icon(Icons.clear_all),
                          label: Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 16),

          // Lista de turbinas
          turbinasAsync.when(
            data: (turbinas) {
              final filteredTurbinas = turbinas.where((turbina) {
                final matchesSearch = turbina.nome
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());

                final matchesStatus =
                    _statusFilter == 'All' || turbina.status == _statusFilter;

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
                          child: _buildTurbinaCard(context, turbina),
                        ))
                    .toList(),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text('Error loading turbines')),
          ),
        ],
      ),
    );
  }

  // ... (resto dos métodos _build permanecem iguais)

  Widget _buildNoResultsCard(BuildContext context) {
    final t = TranslationHelper.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: AppColors.mediumGray),
              SizedBox(height: 16),
              Text(
                t.translate('no_turbines_found'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
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
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.business,
                size: 32,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.nome,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ID: ${project.projectId} • ${project.turbineType}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, _) {
                      final selectedProjectId =
                          ref.watch(selectedProjectIdProvider);
                      final progressAsync = ref.watch(
                          projectPhasesProgressProvider(selectedProjectId!));
                      return progressAsync.when(
                        data: (progress) => Row(
                          children: [
                            Icon(Icons.timeline,
                                size: 16, color: AppColors.primaryBlue),
                            SizedBox(width: 4),
                            Text(
                              'Fases: ${progress.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        loading: () => SizedBox.shrink(),
                        error: (_, __) => SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.timeline, color: AppColors.primaryBlue),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProjectPhasesScreen(
                      projectId: project.id,
                      projectName: project.nome,
                    ),
                  ),
                );
              },
              tooltip: t.translate('view_phases'),
            ),
            SizedBox(width: 8),
            Chip(
              label: Text(project.status),
              backgroundColor: AppColors.getStatusColor(
                project.status,
              ).withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
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
        SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            t.translate('average_progress'),
            '${progressoMedio.toStringAsFixed(1)}%',
            Icons.trending_up,
            AppColors.accentTeal,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            t.translate('in_installation'),
            emInstalacao.toString(),
            Icons.construction,
            AppColors.warningOrange,
          ),
        ),
        SizedBox(width: 16),
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
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurbinaCard(BuildContext context, turbina) {
    final t = TranslationHelper.of(context);
    final color = AppColors.getStatusColor(turbina.status);

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
          padding: EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.wind_power, color: color, size: 14),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.errorRed),
                    iconSize: 14,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () => _showDeleteTurbinaDialog(context, turbina),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                turbina.nome,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3),
              Text(
                t.translateStatus(turbina.status),
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.mediumGray,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6),
              LinearProgressIndicator(
                value: turbina.progresso / 100,
                backgroundColor: AppColors.borderGray,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 3,
              ),
              SizedBox(height: 3),
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

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateProjectWizard(),
    );
  }

  void _showAddTurbinaDialog(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (context) => AddTurbinaDialog(projectId: projectId),
    );
  }

  void _showDeleteTurbinaDialog(BuildContext context, turbina) {
    final t = TranslationHelper.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            SizedBox(width: 12),
            Text(t.translate('delete_turbine')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.translate('delete_turbine_confirm')} "${turbina.nome}"?'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.errorRed.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.errorRed, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.translate('delete_all_components_warning'),
                      style: TextStyle(fontSize: 12, color: AppColors.errorRed),
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
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
