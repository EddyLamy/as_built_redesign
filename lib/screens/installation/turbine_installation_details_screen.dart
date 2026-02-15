import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/installation/fase_componente.dart';
import '../../models/installation/tipo_fase.dart';
import 'fase_edit_dialog.dart';
import '../../providers/app_providers.dart';
import '../../screens/torque_tensioning/torque_tensioning_screen.dart';
import '../../screens/mobile/logistica_form_screen.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';

part 'turbine_installation_details_screen.g.dart';

// ============================================================================
// 🏗️ TELA DE DETALHES DA INSTALAÇÃO DA TURBINA - COM BOTÕES MOBILE
// ============================================================================

// Riverpod 3.x annotation-based provider for installation phase selection
@riverpod
class SelectedInstallationPhase extends _$SelectedInstallationPhase {
  @override
  String build() => 'reception';

  void setPhase(String phase) => state = phase;
}

class TurbineInstallationDetailsScreen extends ConsumerStatefulWidget {
  final String turbineId;
  final String turbineName;
  final String turbineModel;
  final int turbineSequence;
  final int numberOfMiddleSections; // Número de seções middle da torre

  const TurbineInstallationDetailsScreen({
    super.key,
    required this.turbineId,
    required this.turbineName,
    required this.turbineModel,
    required this.turbineSequence,
    this.numberOfMiddleSections = 3, // Default: 3 middles
  });

  @override
  ConsumerState<TurbineInstallationDetailsScreen> createState() =>
      _TurbineInstallationDetailsScreenState();
}

class _TurbineInstallationDetailsScreenState
    extends ConsumerState<TurbineInstallationDetailsScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  bool _isMigrating = false;

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 HELPER: VERIFICAR SE É MOBILE
  // ══════════════════════════════════════════════════════════════════════════
  bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void initState() {
    super.initState();
    _checkAndMigrateIfNeeded();
  }

  Future<void> _checkAndMigrateIfNeeded() async {
    setState(() => _isMigrating = true);

    try {
      final componenteService = ref.read(componenteServiceProvider);

      // Verificar status
      final status =
          await componenteService.getMigrationStatus(widget.turbineId);

      print('📊 Status migração Instalação turbina ${widget.turbineName}:');
      print('   Total: ${status['total']}');
      print('   Migrados: ${status['migrated']}');
      print('   Pendentes: ${status['pending']}');

      // Se houver componentes pendentes, migrar automaticamente
      if (status['pending'] > 0) {
        print('🔄 Instalação: Migrando ${status['pending']} componentes...');

        await componenteService.migrateComponentesForTurbina(widget.turbineId);

        print('✅ Instalação: Migração automática concluída!');
      }
    } catch (e) {
      print('❌ Erro na migração automática: $e');
      // Não bloquear a UI por erro de migração
    } finally {
      if (mounted) {
        setState(() => _isMigrating = false);
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📋 DEFINIÇÃO DAS 5 FASES
  // ══════════════════════════════════════════════════════════════════════════
  final List<Map<String, dynamic>> _phases = [
    {
      'id': 'reception',
      'tipoFase': TipoFase.recepcao,
      'icon': Icons.local_shipping,
      'nameKey': 'reception',
      'color': const Color(0xFF2196F3), // Azul
    },
    {
      'id': 'preparation',
      'tipoFase': TipoFase.preparacao,
      'icon': Icons.assignment,
      'nameKey': 'preparation',
      'color': const Color(0xFF9C27B0), // Roxo
    },
    {
      'id': 'preAssembly',
      'tipoFase': TipoFase.preInstalacao,
      'icon': Icons.construction,
      'nameKey': 'pre_assembly',
      'color': const Color(0xFF00BCD4), // Ciano
    },
    {
      'id': 'assembly',
      'tipoFase': TipoFase.instalacao,
      'icon': Icons.build_circle,
      'nameKey': 'assembly',
      'color': const Color(0xFFFF9800), // Laranja
    },
    {
      'id': 'logistics',
      'icon': Icons.construction, // ✅ Ícone de grua
      'nameKey': 'cranes', // ✅ Novo nome
      'color': const Color(0xFF607D8B), // Blue Grey
    },
    {
      'id': 'torqueTensioning',
      'tipoFase': TipoFase.torqueTensionamento,
      'icon': Icons.bolt,
      'nameKey': 'torqueTensioning',
      'color': const Color(0xFFFF5722), // Laranja/Vermelho forte
    },
    {
      'id': 'finalPhases',
      'icon': Icons.checklist_rtl,
      'nameKey': 'final_phases',
      'color': const Color(0xFF4CAF50), // Verde
    },
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // 📦 COMPONENTES DA FASE RECEÇÃO (HARDCODED) - DINÂMICO
  // ══════════════════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _getReceptionComponents() {
    List<Map<String, dynamic>> components = [
      // AUXILIARY SYSTEMS
      {
        'id': 'spare_parts',
        'nameKey': 'spare_parts',
        'icon': Icons.inventory,
        'hasAddButton': true,
        'items': [],
      },
      {
        'id': 'bodies_parts',
        'nameKey': 'bodies_parts',
        'icon': Icons.view_in_ar,
        'hasAddButton': true,
        'items': [],
      },

      // ELECTRICAL SYSTEMS
      {'id': 'mv_cable', 'nameKey': 'mv_cable', 'icon': Icons.cable},
      {'id': 'swg', 'nameKey': 'swg', 'icon': Icons.electrical_services},
      {'id': 'transformador', 'nameKey': 'transformador', 'icon': Icons.power},
      {'id': 'gerador', 'nameKey': 'gerador', 'icon': Icons.electric_bolt},
      {
        'id': 'ground_control',
        'nameKey': 'ground_control',
        'icon': Icons.power_input
      },
      {
        'id': 'light_control',
        'nameKey': 'light_control',
        'icon': Icons.lightbulb
      },
      {
        'id': 'light_battery',
        'nameKey': 'light_battery',
        'icon': Icons.battery_charging_full
      },
      {'id': 'ups', 'nameKey': 'ups', 'icon': Icons.power_settings_new},

      // MECHANICAL SYSTEMS
      {
        'id': 'gearbox',
        'nameKey': 'gearbox',
        'icon': Icons.settings_applications
      },
      {'id': 'coupling', 'nameKey': 'coupling', 'icon': Icons.link},
      {'id': 'service_lift', 'nameKey': 'service_lift', 'icon': Icons.elevator},
      {
        'id': 'lift_cables',
        'nameKey': 'lift_cables',
        'icon': Icons.cable,
        'isMultiItem': true
      },

      // AUXILIARY SYSTEMS
      {'id': 'resq', 'nameKey': 'resq', 'icon': Icons.sos},
      {
        'id': 'aviation_light_1',
        'nameKey': 'aviation_light_1',
        'displayName': 'Aviation Light 1',
        'icon': Icons.local_airport
      },
      {
        'id': 'aviation_light_2',
        'nameKey': 'aviation_light_2',
        'displayName': 'Aviation Light 2 (Optional)',
        'icon': Icons.flight
      },
      {
        'id': 'grua_interna',
        'nameKey': 'grua_interna',
        'icon': Icons.construction
      },
      {'id': 'cms', 'nameKey': 'cms', 'icon': Icons.monitor_heart},

      // CIVIL WORKS
      {'id': 'anchor_bolts', 'nameKey': 'anchor_bolts', 'icon': Icons.handyman},

      // MAIN COMPONENTS
      {'id': 'top_cooler', 'nameKey': 'top_cooler', 'icon': Icons.ac_unit},
      {'id': 'bottom', 'nameKey': 'tower_bottom', 'icon': Icons.filter_1},
    ];

    // ✅ Adicionar Middles DINAMICAMENTE
    for (int i = 1; i <= widget.numberOfMiddleSections; i++) {
      components.add({
        'id': 'middle$i',
        'nameKey': 'tower_middle',
        'displayName': 'Middle $i',
        'icon': Icons.filter_2,
      });
    }

    components.addAll([
      {'id': 'top', 'nameKey': 'tower_top', 'icon': Icons.filter_3},
      {'id': 'nacelle', 'nameKey': 'nacelle', 'icon': Icons.home_work},
      {'id': 'drive_train', 'nameKey': 'drive_train', 'icon': Icons.settings},
      {'id': 'hub', 'nameKey': 'hub', 'icon': Icons.album},
      {
        'id': 'blade_1',
        'nameKey': 'blade',
        'displayName': 'Blade 1',
        'icon': Icons.wind_power
      },
      {
        'id': 'blade_2',
        'nameKey': 'blade',
        'displayName': 'Blade 2',
        'icon': Icons.wind_power
      },
      {
        'id': 'blade_3',
        'nameKey': 'blade',
        'displayName': 'Blade 3',
        'icon': Icons.wind_power
      },
    ]);

    return components;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📋 COMPONENTES DA FASE PREPARAÇÃO
  // ══════════════════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _getPreparationComponents() {
    List<Map<String, dynamic>> components = [
      {'id': 'mv_cable', 'nameKey': 'mv_cable', 'icon': Icons.cable},
      {'id': 'top_cooler', 'nameKey': 'top_cooler', 'icon': Icons.ac_unit},
      {'id': 'bottom', 'nameKey': 'tower_bottom', 'icon': Icons.filter_1},
    ];

    // ✅ Middles DINÂMICOS
    for (int i = 1; i <= widget.numberOfMiddleSections; i++) {
      components.add({
        'id': 'middle$i',
        'nameKey': 'tower_middle',
        'displayName': 'Middle $i',
        'icon': Icons.filter_2,
      });
    }

    components.addAll([
      {'id': 'top', 'nameKey': 'tower_top', 'icon': Icons.filter_3},
      {'id': 'nacelle', 'nameKey': 'nacelle', 'icon': Icons.home_work},
      {
        'id': 'drive_train',
        'nameKey': 'drive_train',
        'icon': Icons.settings,
        'hasNA': true
      },
      {'id': 'hub', 'nameKey': 'hub', 'icon': Icons.album, 'hasNA': true},
      {
        'id': 'blade_1',
        'nameKey': 'blade',
        'displayName': 'Blade 1',
        'icon': Icons.wind_power,
        'hasNA': true
      },
      {
        'id': 'blade_2',
        'nameKey': 'blade',
        'displayName': 'Blade 2',
        'icon': Icons.wind_power,
        'hasNA': true
      },
      {
        'id': 'blade_3',
        'nameKey': 'blade',
        'displayName': 'Blade 3',
        'icon': Icons.wind_power,
        'hasNA': true
      },
    ]);

    return components;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 COMPONENTES DA FASE PRE-ASSEMBLY
  // ══════════════════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _getPreAssemblyComponents() {
    return [
      {'id': 'top_cooler', 'nameKey': 'top_cooler', 'icon': Icons.ac_unit},
      {'id': 'drive_train', 'nameKey': 'drive_train', 'icon': Icons.settings},
      {'id': 'hub', 'nameKey': 'hub', 'icon': Icons.album},
      {
        'id': 'blade_1',
        'nameKey': 'blade',
        'displayName': 'Blade 1',
        'icon': Icons.wind_power
      },
      {
        'id': 'blade_2',
        'nameKey': 'blade',
        'displayName': 'Blade 2',
        'icon': Icons.wind_power
      },
      {
        'id': 'blade_3',
        'nameKey': 'blade',
        'displayName': 'Blade 3',
        'icon': Icons.wind_power
      },
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🏗️ COMPONENTES DA FASE ASSEMBLY
  // ══════════════════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _getAssemblyComponents() {
    List<Map<String, dynamic>> components = [
      {'id': 'bottom', 'nameKey': 'tower_bottom', 'icon': Icons.filter_1},
    ];

    // ✅ Middles DINÂMICOS (começando do 2)
    for (int i = 2; i <= widget.numberOfMiddleSections; i++) {
      components.add({
        'id': 'middle$i',
        'nameKey': 'tower_middle',
        'displayName': 'Middle $i',
        'icon': Icons.filter_2,
      });
    }

    components.addAll([
      {'id': 'top', 'nameKey': 'tower_top', 'icon': Icons.filter_3},
      {'id': 'nacelle', 'nameKey': 'nacelle', 'icon': Icons.home_work},
      {
        'id': 'drive_train',
        'nameKey': 'drive_train',
        'icon': Icons.settings,
        'conditional': true
      },
      {'id': 'hub', 'nameKey': 'hub', 'icon': Icons.album, 'conditional': true},
      {
        'id': 'blade_1',
        'nameKey': 'blade',
        'displayName': 'Blade 1',
        'icon': Icons.wind_power,
        'conditional': true
      },
      {
        'id': 'blade_2',
        'nameKey': 'blade',
        'displayName': 'Blade 2',
        'icon': Icons.wind_power,
        'conditional': true
      },
      {
        'id': 'blade_3',
        'nameKey': 'blade',
        'displayName': 'Blade 3',
        'icon': Icons.wind_power,
        'conditional': true
      },
    ]);

    return components;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎯 7 FASES FINAIS (SEM COMPONENTES)
  // ══════════════════════════════════════════════════════════════════════════
  final List<Map<String, String>> _finalPhases = [
    {'id': 'electricalWorks', 'nameKey': 'electricalWorks', 'icon': '⚡'},
    {'id': 'mechanicalWorks', 'nameKey': 'mechanicalWorks', 'icon': '🔩'},
    {'id': 'finish', 'nameKey': 'finish', 'icon': '🎨'},
    {
      'id': 'supervisorInspection',
      'nameKey': 'supervisorInspection',
      'icon': '🔍'
    },
    {'id': 'punchlist', 'nameKey': 'punchlist', 'icon': '📝'},
    {'id': 'clientInspection', 'nameKey': 'clientInspection', 'icon': '👥'},
    {'id': 'clientPunchlist', 'nameKey': 'clientPunchlist', 'icon': '📋'},
  ];

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final selectedPhase = ref.watch(selectedInstallationPhaseProvider);

    // Mostrar indicador se estiver migrando
    if (_isMigrating) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.turbineName)),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Preparing components...'),
              SizedBox(height: 8),
              Text(
                'This only happens once per turbine',
                style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.turbineName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref
                .read(selectedInstallationPhaseProvider.notifier)
                .setPhase('reception');
            Navigator.pop(context);
          },
        ),
        // ════════════════════════════════════════════════════════════════════
        // 🆕 BOTÕES MOBILE: PARQUE + LOGOUT
        // ════════════════════════════════════════════════════════════════════
        actions: _isMobile
            ? [
                // Botão Escolher Parque
                IconButton(
                  icon: const Icon(Icons.home_outlined),
                  onPressed: () => _showProjectSelectionDialog(),
                  tooltip: t.translate('select_project'),
                ),
                // Botão Logout
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _showLogoutDialog(),
                  tooltip: t.translate('logout'),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          _buildTurbineInfoCard(t),
          _buildPhasesBar(selectedPhase, t),
          Expanded(
            child: _buildPhaseContent(selectedPhase, t),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, Color(0xFF00BCD4)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openLogisticaForm(),
            borderRadius: BorderRadius.circular(32),
            splashColor: Colors.white.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.precision_manufacturing_sharp,
                      color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    t.translate('register_activity'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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

  // ══════════════════════════════════════════════════════════════════════════
  // 🏠 DIALOG: ESCOLHER PARQUE/PROJETO
  // ══════════════════════════════════════════════════════════════════════════
  void _showProjectSelectionDialog() async {
    final t = TranslationHelper.of(context);
    final projectsAsync = ref.read(userProjectsProvider);

    await projectsAsync.when(
      data: (projects) async {
        if (projects.isEmpty) {
          // Nenhum projeto disponível
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.translate('no_projects_available')),
                backgroundColor: AppColors.warningOrange,
              ),
            );
          }
          return;
        }

        // Mostrar diálogo com lista de projetos
        final selectedProject = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.business, color: AppColors.primaryBlue),
                const SizedBox(width: 12),
                Text(t.translate('select_project')),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ListTile(
                    leading: const Icon(Icons.wind_power,
                        color: AppColors.primaryBlue),
                    title: Text(project.nome),
                    subtitle: Text('ID: ${project.projectId}'),
                    onTap: () => Navigator.of(context).pop(project.id),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t.translate('cancel')),
              ),
            ],
          ),
        );

        // Se selecionou um projeto, navegar para o dashboard
        if (selectedProject != null && mounted) {
          ref
              .read(selectedProjectIdProvider.notifier)
              .setValue(selectedProject);

          // Voltar para o dashboard
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (route) => false,
          );
        }
      },
      loading: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.translate('loading')),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      error: (error, _) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${t.translate('error')}: $error'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🚪 DIALOG: CONFIRMAR LOGOUT
  // ══════════════════════════════════════════════════════════════════════════
  void _showLogoutDialog() async {
    final t = TranslationHelper.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.warningOrange),
            const SizedBox(width: 12),
            Text(t.translate('logout')),
          ],
        ),
        content: Text(t.translate('logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: Text(t.translate('logout')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        // Fazer logout
        await FirebaseAuth.instance.signOut();

        // Limpar providers
        ref.read(selectedProjectIdProvider.notifier).setValue(null);
        ref.read(selectedTurbinaIdProvider.notifier).setValue(null);

        // Navegar para login
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${t.translate('error')}: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 WIDGET: CARD DA TURBINA (FIXO NO TOPO)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTurbineInfoCard(TranslationHelper t) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.wind_power, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.turbineName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t.translate('turbine_model')}: ${widget.turbineModel} | ${t.translate('sequence')}: ${widget.turbineSequence}',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.mediumGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 WIDGET: BARRA DE FASES
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPhasesBar(String selectedPhase, TranslationHelper t) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _phases.length,
        itemBuilder: (context, index) {
          final phase = _phases[index];
          final isSelected = selectedPhase == phase['id'];
          return _buildPhaseButton(phase, isSelected, t);
        },
      ),
    );
  }

  Widget _buildPhaseButton(
      Map<String, dynamic> phase, bool isSelected, TranslationHelper t) {
    final color = phase['color'] as Color;

    return GestureDetector(
      onTap: () {
        ref
            .read(selectedInstallationPhaseProvider.notifier)
            .setPhase(phase['id'] as String);
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.borderGray,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(phase['icon'] as IconData,
                size: 28, color: isSelected ? Colors.white : color),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                t.translate(phase['nameKey'] as String),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📝 WIDGET: CONTEÚDO DA FASE (COMPONENTES)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPhaseContent(String selectedPhase, TranslationHelper t) {
    switch (selectedPhase) {
      case 'reception':
        return _buildComponentsList(
            _getReceptionComponents(), TipoFase.recepcao, t);
      case 'preparation':
        return _buildComponentsList(
            _getPreparationComponents(), TipoFase.preparacao, t);
      case 'preAssembly':
        return _buildComponentsList(
            _getPreAssemblyComponents(), TipoFase.preInstalacao, t);
      case 'assembly':
        return _buildComponentsList(
            _getAssemblyComponents(), TipoFase.instalacao, t);
      case 'logistics':
        return _buildLogisticaList(t);
      case 'torqueTensioning':
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _openTorqueTensioningScreen();
          }
        });
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                t.translate('loading'),
                style:
                    const TextStyle(fontSize: 14, color: AppColors.mediumGray),
              ),
            ],
          ),
        );
      case 'finalPhases':
        return _buildFinalPhasesContent(t);
      default:
        return const Center(child: Text('Unknown phase'));
    }
  }

  void _openLogisticaForm({Map<String, dynamic>? existingData, String? docId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogisticaFormScreen(
          turbineId: widget.turbineId,
          turbineName: widget.turbineName,
          initialData: existingData,
          docId: docId,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📦 WIDGET: LISTA DE COMPONENTES (GRID COMPACTO COM DINÂMICOS)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildComponentsList(List<Map<String, dynamic>> components,
      TipoFase tipoFase, TranslationHelper t) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbineId)
          .where('isDynamic', isEqualTo: true)
          .snapshots(),
      builder: (context, dynamicSnapshot) {
        final allComponents = <Map<String, dynamic>>[...components];

        if (dynamicSnapshot.hasData && dynamicSnapshot.data != null) {
          for (var doc in dynamicSnapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final selectedPhases =
                List<String>.from(data['selectedPhases'] ?? []);
            final tipoFaseString = tipoFase.toString().split('.').last;

            String? phaseId;
            switch (tipoFaseString) {
              case 'recepcao':
                phaseId = 'reception';
                break;
              case 'preparacao':
                phaseId = 'preparation';
                break;
              case 'preInstalacao':
                phaseId = 'preAssembly';
                break;
              case 'instalacao':
                phaseId = 'assembly';
                break;
            }

            if (phaseId != null && selectedPhases.contains(phaseId)) {
              allComponents.add({
                'id': data['hardcodedId'] ?? doc.id,
                'nameKey': data['nome'],
                'displayName': data['nome'],
                'icon': Icons.inventory_2,
                'isDynamic': true,
              });
            }
          }
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 8 : 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: allComponents.length,
          itemBuilder: (context, index) {
            return _buildComponentCard(allComponents[index], tipoFase, t);
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 WIDGET: CARD DE COMPONENTE (CLICÁVEL - ABRE DIALOG)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildComponentCard(
      Map<String, dynamic> component, TipoFase tipoFase, TranslationHelper t) {
    final componentId = '${component['id']}_${widget.turbineId}';
    final displayName =
        component['displayName'] ?? t.translate(component['nameKey']);

    return FutureBuilder<FaseComponente?>(
      future: _getFaseDoComponente(componentId, tipoFase),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          print('❌ Erro ao buscar fase: ${snapshot.error}');
        }

        final fase = snapshot.data;
        final progresso = fase?.progresso ?? 0.0;
        final Color statusColor = progresso >= 100
            ? AppColors.successGreen
            : progresso > 0
                ? AppColors.warningOrange
                : AppColors.mediumGray;

        return Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: () =>
                _openComponentDialog(componentId, component, tipoFase, fase, t),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(component['icon'] as IconData,
                      size: 28, color: statusColor),
                  const SizedBox(height: 2),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${progresso.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<FaseComponente?> _getFaseDoComponente(
      String componenteId, TipoFase tipoFase) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('fases_componente')
          .where('componenteId', isEqualTo: componenteId)
          .where('turbinaId', isEqualTo: widget.turbineId)
          .where('tipo', isEqualTo: tipoFase.toString().split('.').last)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return FaseComponente.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar fase: $e');
      return null;
    }
  }

  void _openComponentDialog(
    String componenteId,
    Map<String, dynamic> component,
    TipoFase tipoFase,
    FaseComponente? faseExistente,
    TranslationHelper t,
  ) async {
    FaseComponente fase;

    if (faseExistente != null) {
      fase = faseExistente;
    } else {
      final novaFase = FaseComponente(
        id: '',
        turbinaId: widget.turbineId,
        componenteId: componenteId,
        tipo: tipoFase,
        fotos: [],
        isFaseNA: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await FirebaseFirestore.instance
          .collection('fases_componente')
          .add(novaFase.toFirestore());

      fase = novaFase.copyWith(id: docRef.id);
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FaseEditDialog(
        fase: fase,
        turbinaId: widget.turbineId,
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  Widget _buildFinalPhasesContent(TranslationHelper t) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _finalPhases.length,
      itemBuilder: (context, index) {
        final phase = _finalPhases[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: Text(phase['icon']!, style: const TextStyle(fontSize: 24)),
            title: Text(t.translate(phase['nameKey']!),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildDateField(
                                label: t.translate('startDate'),
                                hint: 'DD/MM/AAAA')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildDateField(
                                label: t.translate('endDate'),
                                hint: 'DD/MM/AAAA')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPhotoField(t),
                    const SizedBox(height: 12),
                    _buildTextField(
                        label: t.translate('observations'),
                        hint: t.translate('add_notes_optional'),
                        icon: Icons.notes,
                        maxLines: 3),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.not_interested),
                            label: const Text('N/A'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.save),
                            label: Text(t.translate('save')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(
      {required String label,
      required String hint,
      IconData? icon,
      int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onTap: () async {
            await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030));
          },
        ),
      ],
    );
  }

  Widget _buildPhotoField(TranslationHelper t) {
    return InkWell(
      onTap: () async {
        await _imagePicker.pickImage(source: ImageSource.camera);
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.borderGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGray, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt,
                  size: 40, color: AppColors.mediumGray),
              const SizedBox(height: 8),
              Text(t.translate('add_photo'),
                  style: const TextStyle(color: AppColors.mediumGray)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openTorqueTensioningScreen() async {
    try {
      final turbinaDoc = await FirebaseFirestore.instance
          .collection('turbinas')
          .doc(widget.turbineId)
          .get();

      if (!turbinaDoc.exists) {
        throw Exception('Turbina não encontrada');
      }

      final projectId = turbinaDoc.data()?['projectId'] as String? ?? '';

      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TorqueTensioningScreen(
              turbinaId: widget.turbineId,
              projectId: projectId,
              turbinaNome: widget.turbineName,
              numberOfMiddleSections: widget.numberOfMiddleSections,
            ),
          ),
        );

        if (mounted) {
          ref
              .read(selectedInstallationPhaseProvider.notifier)
              .setPhase('assembly');
        }
      }
    } catch (e) {
      print('❌ Erro ao abrir Torque: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir Torque: $e'),
            backgroundColor: Colors.red,
          ),
        );
        ref
            .read(selectedInstallationPhaseProvider.notifier)
            .setPhase('assembly');
      }
    }
  }

  Widget _buildLogisticaList(TranslationHelper t) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('turbinas')
          .doc(widget.turbineId)
          .collection('logistica_gruas')
          .orderBy('inicio', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(child: Text(t.translate('no_logs_found')));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final docId = doc.id;
            final logData = doc.data() as Map<String, dynamic>;

            final DateTime inicio = (logData['inicio'] as Timestamp).toDate();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: Icon(_getIconForTipo(logData['tipo']),
                      color: AppColors.primaryBlue),
                ),
                title: Text(
                  t.translate(logData['tipo'] ?? 'trabalho'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    "${inicio.day}/${inicio.month} - ${inicio.hour}:${inicio.minute.toString().padLeft(2, '0')}h"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => _showLogDetail(logData, docId, t),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconForTipo(String? tipo) {
    switch (tipo) {
      case 'paragem':
        return Icons.pause_circle_filled;
      case 'transferencia':
        return Icons.swap_horiz;
      case 'mobilizacao':
        return Icons.flight_land;
      default:
        return Icons.engineering;
    }
  }

  void _showLogDetail(
      Map<String, dynamic> data, String docId, TranslationHelper t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(t.translate(data['tipo'] ?? 'trabalho'),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteLog(docId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.primaryBlue),
                    onPressed: () {
                      Navigator.pop(context);
                      _openLogisticaForm(existingData: data, docId: docId);
                    },
                  ),
                ],
              ),
              const Divider(height: 32),
              if (data['motivo'] != null) ...[
                Text(t.translate('reason'),
                    style: const TextStyle(color: Colors.grey)),
                Text(t.translate(data['motivo']),
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
              ],
              if (data['observacoes'] != null &&
                  data['observacoes'].toString().isNotEmpty) ...[
                Text(t.translate('notes'),
                    style: const TextStyle(color: Colors.grey)),
                Text(data['observacoes'], style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
              ],
              if (data['origem'] != null &&
                  data['origem'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text("Path: ${data['origem']} ➔ ${data['destino']}",
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
              if (data['observacoes'] != null &&
                  data['observacoes'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text("Obs: ${data['observacoes']}",
                      style: const TextStyle(color: Colors.grey)),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Fechar"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteLog(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Registo"),
        content: const Text("Tens a certeza que queres apagar esta atividade?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('turbinas')
          .doc(widget.turbineId)
          .collection('logistica_gruas')
          .doc(docId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registo eliminado com sucesso")),
        );
      }
    }
  }
}
