import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/installation/fase_componente.dart';
import '../../models/installation/tipo_fase.dart';
import 'fase_edit_dialog.dart';
import '../../providers/app_providers.dart';
import '../../screens/torque_tensioning/torque_tensioning_screen.dart';

// ============================================================================
// 🏗️ TELA DE DETALHES DA INSTALAÇÃO DA TURBINA - COMPONENTES HARDCODED
// ============================================================================

// Provider para a fase selecionada
final selectedInstallationPhaseProvider =
    StateProvider<String>((ref) => 'reception');

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

// ← ADICIONAR ESTE MÉTODO
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
      'color': Color(0xFF2196F3), // Azul
    },
    {
      'id': 'preparation',
      'tipoFase': TipoFase.preparacao,
      'icon': Icons.assignment,
      'nameKey': 'preparation',
      'color': Color(0xFF9C27B0), // Roxo
    },
    {
      'id': 'preAssembly',
      'tipoFase': TipoFase.preInstalacao,
      'icon': Icons.construction,
      'nameKey': 'pre_assembly',
      'color': Color(0xFF00BCD4), // Ciano
    },
    {
      'id': 'assembly',
      'tipoFase': TipoFase.instalacao,
      'icon': Icons.build_circle,
      'nameKey': 'assembly',
      'color': Color(0xFFFF9800), // Laranja
    },
    // ════════════════════════════════════════════════════════════════════════
    // 🆕 NOVO: TORQUE & TENSIONING
    // ════════════════════════════════════════════════════════════════════════
    {
      'id': 'torqueTensioning',
      'tipoFase': TipoFase.torqueTensionamento,
      'icon': Icons.bolt,
      'nameKey': 'torqueTensioning',
      'color': Color(0xFFFF5722), // Laranja/Vermelho forte
    },
    // ════════════════════════════════════════════════════════════════════════
    {
      'id': 'finalPhases',
      'icon': Icons.checklist_rtl,
      'nameKey': 'final_phases',
      'color': Color(0xFF4CAF50), // Verde
    },
  ];

// ══════════════════════════════════════════════════════════════════════════
  // 📦 COMPONENTES DA FASE RECEÇÃO (HARDCODED) - ATUALIZADO COM 17 NOVOS
  // ══════════════════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _getReceptionComponents() {
    List<Map<String, dynamic>> components = [
      // ────────────────────────────────────────────────────────────────────
      // 🆕 AUXILIARY SYSTEMS (com botão Add - opcional)
      // ────────────────────────────────────────────────────────────────────
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

      // ────────────────────────────────────────────────────────────────────
      // 🆕 ELECTRICAL SYSTEMS - NOVOS COMPONENTES
      // ────────────────────────────────────────────────────────────────────
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

      // ────────────────────────────────────────────────────────────────────
      // 🆕 MECHANICAL SYSTEMS - NOVOS COMPONENTES
      // ────────────────────────────────────────────────────────────────────
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
      }, // 4 itens

      // ────────────────────────────────────────────────────────────────────
      // 🆕 AUXILIARY SYSTEMS - NOVOS COMPONENTES
      // ────────────────────────────────────────────────────────────────────
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

      // ────────────────────────────────────────────────────────────────────
      // 🆕 CIVIL WORKS - NOVOS COMPONENTES
      // ────────────────────────────────────────────────────────────────────
      {'id': 'anchor_bolts', 'nameKey': 'anchor_bolts', 'icon': Icons.handyman},

      // ────────────────────────────────────────────────────────────────────
      // ✅ COMPONENTES EXISTENTES (MAIN COMPONENTS)
      // ────────────────────────────────────────────────────────────────────
      {'id': 'top_cooler', 'nameKey': 'top_cooler', 'icon': Icons.ac_unit},
      {'id': 'bottom', 'nameKey': 'tower_bottom', 'icon': Icons.filter_1},
    ];

    // Adicionar Middles dinamicamente
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
  // 📋 COMPONENTES DA FASE PREPARAÇÃO (HARDCODED)
  // ══════════════════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _getPreparationComponents() {
    List<Map<String, dynamic>> components = [
      {'id': 'mv_cable', 'nameKey': 'mv_cable', 'icon': Icons.cable},
      {'id': 'top_cooler', 'nameKey': 'top_cooler', 'icon': Icons.ac_unit},
      {'id': 'bottom', 'nameKey': 'tower_bottom', 'icon': Icons.filter_1},
    ];

    // Middles
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
  // 🔧 COMPONENTES DA FASE PRE-ASSEMBLY (HARDCODED)
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
  // 🏗️ COMPONENTES DA FASE ASSEMBLY (HARDCODED)
  // ══════════════════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _getAssemblyComponents() {
    List<Map<String, dynamic>> components = [
      {'id': 'bottom', 'nameKey': 'tower_bottom', 'icon': Icons.filter_1},
    ];

    // Middles (começando do 2)
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
        body: Center(
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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(selectedInstallationPhaseProvider.notifier).state =
                'reception';
            Navigator.pop(context);
          },
        ),
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
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 WIDGET: CARD DA TURBINA (FIXO NO TOPO)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTurbineInfoCard(TranslationHelper t) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.wind_power, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.turbineName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${t.translate('turbine_model')}: ${widget.turbineModel} | ${t.translate('sequence')}: ${widget.turbineSequence}',
                  style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        ref.read(selectedInstallationPhaseProvider.notifier).state =
            phase['id'] as String;
      },
      child: Container(
        width: 90,
        margin: EdgeInsets.only(right: 12),
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
                      offset: Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(phase['icon'] as IconData,
                size: 28, color: isSelected ? Colors.white : color),
            SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
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
  // 📝 WIDGET: CONTEÚDO DA FASE (COMPONENTES HARDCODED)
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

      // ════════════════════════════════════════════════════════════════════════
      // 🆕 TORQUE: NAVEGAÇÃO DIRETA (SEM ECRÃ INTERMEDIÁRIO)
      // ════════════════════════════════════════════════════════════════════════
      case 'torqueTensioning':
        // Navegar imediatamente (executado no próximo frame)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _openTorqueTensioningScreen();
          }
        });
        // Mostrar loading enquanto navega
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                t.translate('loading'),
                style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
              ),
            ],
          ),
        );

      case 'finalPhases':
        return _buildFinalPhasesContent(t);
      default:
        return Center(child: Text('Unknown phase'));
    }
  }

// ══════════════════════════════════════════════════════════════════════════
  // 📦 WIDGET: LISTA DE COMPONENTES (GRID COMPACTO COM DINÂMICOS)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildComponentsList(List<Map<String, dynamic>> components,
      TipoFase tipoFase, TranslationHelper t) {
    // Determinar categoria baseada no tipo de fase
    String categoria = 'Unknown';
    if (components.isNotEmpty) {
      // Inferir categoria pelos componentes
      if (components
          .any((c) => c['id'] == 'spare_parts' || c['id'] == 'bodies_parts')) {
        categoria = 'Auxiliary Systems';
      } else if (components.any((c) => c['id'] == 'lift_cables')) {
        categoria = 'Mechanical Systems';
      }
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbineId)
          .where('isDynamic', isEqualTo: true)
          .snapshots(),
      builder: (context, dynamicSnapshot) {
        // Combinar estáticos + dinâmicos
        final allComponents = <Map<String, dynamic>>[...components];

        // Adicionar dinâmicos se existirem
        if (dynamicSnapshot.hasData && dynamicSnapshot.data != null) {
          for (var doc in dynamicSnapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            // Verificar se o componente tem a fase atual selecionada
            final selectedPhases =
                List<String>.from(data['selectedPhases'] ?? []);
            final tipoFaseString = tipoFase.toString().split('.').last;

            // Mapear tipo de fase para phase ID
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

            // Só adicionar se o componente tem esta fase selecionada
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
          padding: EdgeInsets.all(8),
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
        // Aguardando dados
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
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

        // Erro ao buscar
        if (snapshot.hasError) {
          print('❌ Erro ao buscar fase: ${snapshot.error}');
        }

        // Dados recebidos (pode ser null se não existe fase)
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
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(component['icon'] as IconData,
                      size: 28, color: statusColor),
                  SizedBox(height: 2),
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    '${progresso.toStringAsFixed(0)}%',
                    style: TextStyle(
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

  // ══════════════════════════════════════════════════════════════════════════
  // 🔍 BUSCAR FASE DO FIREBASE (ou criar se não existir)
  // ══════════════════════════════════════════════════════════════════════════
  Future<FaseComponente?> _getFaseDoComponente(
      String componenteId, TipoFase tipoFase) async {
    try {
      print('🔍 Buscando fase: $componenteId - $tipoFase');

      final snapshot = await FirebaseFirestore.instance
          .collection('fases_componente')
          .where('componenteId', isEqualTo: componenteId)
          .where('turbinaId', isEqualTo: widget.turbineId)
          .where('tipo', isEqualTo: tipoFase.toString().split('.').last)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        print('   ✅ Fase encontrada!');
        final fase = FaseComponente.fromFirestore(snapshot.docs.first);
        print('   📊 Progresso: ${fase.progresso}%');
        return fase;
      }

      print('   ℹ️ Fase não existe ainda (será criada ao clicar)');
      return null;
    } catch (e, stack) {
      print('❌ Erro ao buscar fase: $e');
      print('StackTrace: $stack');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📝 ABRIR DIALOG DE EDIÇÃO (CRIAR FASE SE NÃO EXISTIR)
  // ══════════════════════════════════════════════════════════════════════════
  void _openComponentDialog(
    String componenteId,
    Map<String, dynamic> component,
    TipoFase tipoFase,
    FaseComponente? faseExistente,
    TranslationHelper t,
  ) async {
    print('\n🟢 ABRINDO DIALOG PARA COMPONENTE');
    print('   Componente ID: $componenteId');
    print('   Tipo Fase: $tipoFase');
    print('   Fase existe? ${faseExistente != null}');

    FaseComponente fase;

    if (faseExistente != null) {
      // Usar fase existente
      fase = faseExistente;
    } else {
      // Criar nova fase no Firebase
      print('   🆕 Criando nova fase...');
      final novaFase = FaseComponente(
        id: '', // Firebase vai gerar
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
      print('   ✅ Fase criada com ID: ${docRef.id}');
    }

    // Abrir dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FaseEditDialog(
        fase: fase,
        turbinaId: widget.turbineId,
      ),
    );

    if (result == true && mounted) {
      print('✅ Dados salvos! Recarregando UI...');
      setState(() {}); // Forçar rebuild para atualizar progresso
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎯 FASES FINAIS (SEM COMPONENTES - FORMULÁRIO DIRETO)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFinalPhasesContent(TranslationHelper t) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _finalPhases.length,
      itemBuilder: (context, index) {
        final phase = _finalPhases[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: Text(phase['icon']!, style: TextStyle(fontSize: 24)),
            title: Text(t.translate(phase['nameKey']!),
                style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildDateField(
                                label: t.translate('startDate'),
                                hint: 'DD/MM/AAAA')),
                        SizedBox(width: 12),
                        Expanded(
                            child: _buildDateField(
                                label: t.translate('endDate'),
                                hint: 'DD/MM/AAAA')),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildPhotoField(t),
                    SizedBox(height: 12),
                    _buildTextField(
                        label: t.translate('observations'),
                        hint: t.translate('add_notes_optional'),
                        icon: Icons.notes,
                        maxLines: 3),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.not_interested),
                            label: Text('N/A'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.save),
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

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 COMPONENTES REUTILIZÁVEIS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTextField(
      {required String label,
      required String hint,
      IconData? icon,
      int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(Icons.calendar_today),
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
              Icon(Icons.camera_alt, size: 40, color: AppColors.mediumGray),
              SizedBox(height: 8),
              Text(t.translate('add_photo'),
                  style: TextStyle(color: AppColors.mediumGray)),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🆕 MÉTODOS PARA COMPONENTES DINÂMICOS
  // ══════════════════════════════════════════════════════════════════════════

  void _showAddDynamicComponentDialog(
    BuildContext context,
    String categoria,
    Color categoryColor,
    TranslationHelper t,
  ) {
    final nameController = TextEditingController();
    final selectedPhases = <String>{};

    final availablePhases = [
      {'id': 'reception', 'name': 'Reception', 'icon': '📦'},
      {'id': 'preparation', 'name': 'Preparation', 'icon': '📋'},
      {'id': 'preAssembly', 'name': 'Pre-Assembly', 'icon': '🔧'},
      {'id': 'assembly', 'name': 'Assembly', 'icon': '🏗️'},
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_circle, color: categoryColor),
                SizedBox(width: 12),
                Text('Adicionar Componente'),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nome do Componente',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Spare Part 1',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text('Fases de Integração',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: availablePhases.map((phase) {
                          final phaseId = phase['id'] as String;
                          final phaseName = phase['name'] as String;
                          final phaseIcon = phase['icon'] as String;
                          final isSelected = selectedPhases.contains(phaseId);

                          return CheckboxListTile(
                            title: Row(
                              children: [
                                Text(phaseIcon),
                                SizedBox(width: 8),
                                Text(phaseName),
                              ],
                            ),
                            value: isSelected,
                            activeColor: categoryColor,
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedPhases.add(phaseId);
                                } else {
                                  selectedPhases.remove(phaseId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    if (selectedPhases.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange, size: 20),
                              SizedBox(width: 8),
                              Text('Selecione pelo menos uma fase',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton.icon(
                onPressed: nameController.text.trim().isEmpty ||
                        selectedPhases.isEmpty
                    ? null
                    : () async {
                        final componentName = nameController.text.trim();
                        Navigator.pop(context);
                        await _createDynamicComponent(
                            componentName, categoria, selectedPhases.toList());
                      },
                icon: Icon(Icons.add),
                label: Text('Criar'),
                style: ElevatedButton.styleFrom(backgroundColor: categoryColor),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createDynamicComponent(
    String componentName,
    String categoria,
    List<String> selectedPhases,
  ) async {
    try {
      print('🆕 Criando (Installation): $componentName');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text('Criando componente...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      final firestore = FirebaseFirestore.instance;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = componentName
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
      final hardcodedId = '${sanitizedName}_$timestamp';
      final fullComponentId = '${hardcodedId}_${widget.turbineId}';

      final turbinaDoc =
          await firestore.collection('turbinas').doc(widget.turbineId).get();
      final projectId = turbinaDoc.data()?['projectId'] ?? '';

      await firestore.collection('componentes').doc(fullComponentId).set({
        'nome': componentName,
        'hardcodedId': hardcodedId,
        'categoria': categoria,
        'turbinaId': widget.turbineId,
        'projectId': projectId,
        'progresso': 0.0,
        'status': 'Pendente',
        'aplicavel': true,
        'isDynamic': true,
        'selectedPhases': selectedPhases,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final installationRef = firestore
          .collection('installation_data')
          .doc(widget.turbineId)
          .collection('components')
          .doc(fullComponentId);

      final installationData = <String, dynamic>{};
      for (var phase in selectedPhases) {
        installationData[phase] = {
          'isCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
        };
      }
      await installationRef.set(installationData);

      final phaseMapping = {
        'reception': 'recepcao',
        'preparation': 'preparacao',
        'preAssembly': 'preInstalacao',
        'assembly': 'instalacao',
      };

      for (var phase in selectedPhases) {
        final tipoFase = phaseMapping[phase];
        if (tipoFase == null) continue;

        final faseId = '${fullComponentId}_$tipoFase';
        await firestore.collection('fases_componente').doc(faseId).set({
          'componenteId': fullComponentId,
          'turbinaId': widget.turbineId,
          'tipo': tipoFase,
          'progresso': 0.0,
          'isFaseNA': false,
          'fotos': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "$componentName" criado!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {});
      }
    } catch (e) {
      print('❌ Erro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _openTorqueTensioningScreen() async {
    try {
      // Buscar projectId da turbina
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

        // Voltar para a fase anterior ao regressar
        if (mounted) {
          ref.read(selectedInstallationPhaseProvider.notifier).state =
              'assembly';
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
        // Voltar para assembly em caso de erro
        ref.read(selectedInstallationPhaseProvider.notifier).state = 'assembly';
      }
    }
  }
}
