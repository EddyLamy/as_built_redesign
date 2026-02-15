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
  void initState() {
    super.initState();
    // Inicialização do dashboard
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final user = FirebaseAuth.instance.currentUser;

    // ══════════════════════════════════════════════════════════════
    // OBTER PROVIDERS (UMA VEZ APENAS)
    // ══════════════════════════════════════════════════════════════
    final currentModule = ref.watch(currentModuleProvider);
    final projectsAsync = ref.watch(userProjectsProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);

    print('═══════════════════════════════════');
    print('🔵 DASHBOARD BUILD');
    print('🔵 USER EMAIL: ${user?.email ?? "NULL"}');
    print('🔵 CURRENT MODULE: $currentModule');
    print('═══════════════════════════════════');

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
            const SizedBox(width: 16),

            // Dropdown de projetos
            projectsAsync.when(
              data: (projects) {
                if (projects.isEmpty) return const SizedBox.shrink();

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                      style: const TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: AppColors.primaryBlue,
                    underline: const SizedBox.shrink(),
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
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
      floatingActionButton: selectedProjectId != null
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
                          Color(
                              0xFF00BCD4), // ✅ Cor turquesa para um visual mais moderno
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.4),
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

  // ══════════════════════════════════════════════════════════════
  // ADICIONAR MÉTODO (logo após o método build)
  // ══════════════════════════════════════════════════════════════

  Widget _buildEmptyState(BuildContext context) {
    final t = TranslationHelper.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.business_outlined,
              size: 100, color: AppColors.mediumGray),
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
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final projectAsync = ref.watch(selectedProjectProvider);
    final turbinasAsync = ref.watch(projectTurbinasProvider);
    final statsAsync = ref.watch(projectStatisticsProvider);
    final t = TranslationHelper.of(context);

    return SingleChildScrollView(
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

          // Timeline das fases
          Consumer(
            builder: (context, ref, _) {
              final selectedProjectId = ref.watch(selectedProjectIdProvider);
              if (selectedProjectId == null) return const SizedBox.shrink();

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
                                  contentPadding: const EdgeInsets.symmetric(
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text('Error loading turbines')),
          ),
        ],
      ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.business,
                size: 32,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                        colors: [
                          AppColors.primaryBlue,
                          Color(
                              0xFF00BCD4), // ✅ Cor turquesa para um visual mais moderno
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.view_list, // ✅ ÍCONE CORRETO
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
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
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
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.wind_power, color: color, size: 14),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.errorRed),
                    iconSize: 14,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showDeleteTurbinaDialog(context, turbina),
                    tooltip: 'Delete',
                  ),
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

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateProjectWizard(),
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
                color: AppColors.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.errorRed.withOpacity(0.3),
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
