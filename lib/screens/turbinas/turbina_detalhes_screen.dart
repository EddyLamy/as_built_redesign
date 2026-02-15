import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../models/componente.dart';
import '../../core/localization/translation_helper.dart';
import '../../utils/component_mapping.dart';
import '../../services/installation/photo_service.dart';

class TurbinaDetalhesScreen extends ConsumerStatefulWidget {
  final String turbinaId;
  final int numberOfMiddleSections;

  const TurbinaDetalhesScreen({
    super.key,
    required this.turbinaId,
    this.numberOfMiddleSections = 3,
  });

  @override
  ConsumerState<TurbinaDetalhesScreen> createState() =>
      _TurbinaDetalhesScreenState();
}

class _TurbinaDetalhesScreenState extends ConsumerState<TurbinaDetalhesScreen> {
  final Map<String, bool> _expandedCategories = {
    'Main Components': true,
    'Electrical Systems': true,
    'Mechanical Systems': true,
    'Auxiliary Systems': true,
    'Civil Works': true,
  };

  bool _isMigrating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedTurbinaIdProvider.notifier).setValue(widget.turbinaId);
      _checkAndMigrateIfNeeded();
    });
  }

  Future<void> _checkAndMigrateIfNeeded() async {
    setState(() => _isMigrating = true);

    try {
      final componenteService = ref.read(componenteServiceProvider);
      final status =
          await componenteService.getMigrationStatus(widget.turbinaId);

      print('📊 Status migração As-Built:');
      print('   Total: ${status['total']}');
      print('   Migrados: ${status['migrated']}');
      print('   Pendentes: ${status['pending']}');

      if (status['pending'] > 0) {
        print('🔄 As-Built: Migrando ${status['pending']} componentes...');
        await componenteService.migrateComponentesForTurbina(widget.turbinaId);
        print('✅ As-Built: Migração automática concluída!');
      }

      // ════════════════════════════════════════════════════════════════════
      // 🔧 CORREÇÃO AUTOMÁTICA DE COMPONENTES (SÓ UMA VEZ)
      // ════════════════════════════════════════════════════════════════════
      await _checkAndFixComponentsIfNeeded();
    } catch (e) {
      print('❌ Erro na migração automática: $e');
    } finally {
      if (mounted) {
        setState(() => _isMigrating = false);
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 VERIFICAR E CORRIGIR COMPONENTES AUTOMATICAMENTE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _checkAndFixComponentsIfNeeded() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Verificar se já foi feita a correção nesta turbina
      final turbinaDoc =
          await firestore.collection('turbinas').doc(widget.turbinaId).get();

      final turbinaData = turbinaDoc.data();
      final alreadyFixed = turbinaData?['componentsFixed'] == true;

      if (alreadyFixed) {
        print('✅ Componentes desta turbina já foram corrigidos anteriormente');
        return;
      }

      print('🔄 Primeira vez abrindo esta turbina. Verificando componentes...');

      // Buscar componentes da turbina
      final snapshot = await firestore
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbinaId)
          .get();

      // Verificar se há componentes que precisam de correção
      bool needsFix = false;

      final problematicNames = [
        'Trafo',
        'Nacelle Top Cooler',
        'Ground Controller',
        'Anchor bolts',
        'Blade 1 / a',
        'Blade 2 / b',
        'Blade 3 / c',
      ];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nome = data['nome'] as String;

        // Verificar se tem nome problemático OU não tem hardcodedId
        if (problematicNames.contains(nome) ||
            !data.containsKey('hardcodedId') ||
            data['hardcodedId'] == null) {
          needsFix = true;
          break;
        }
      }

      // Verificar se faltam componentes novos
      final requiredComponents = [
        'transformador',
        'gerador',
        'light_control',
        'light_battery',
        'ups',
        'gearbox',
        'coupling',
        'lift_cables',
        'aviation_light_1',
        'aviation_light_2',
        'grua_interna',
        'cms',
      ];

      for (var hardcodedId in requiredComponents) {
        final componentId = '${hardcodedId}_${widget.turbinaId}';
        final exists =
            await firestore.collection('componentes').doc(componentId).get();

        if (!exists.exists) {
          needsFix = true;
          print('⚠️  Componente faltando: $hardcodedId');
          break;
        }
      }

      if (needsFix) {
        print(
            '🔧 Componentes precisam de correção. Corrigindo automaticamente...');
        await _fixAllComponents();

        // Marcar turbina como corrigida
        await firestore.collection('turbinas').doc(widget.turbinaId).update({
          'componentsFixed': true,
          'componentsFixedAt': FieldValue.serverTimestamp(),
        });

        print('✅ Componentes corrigidos e turbina marcada!');
      } else {
        print('✅ Todos os componentes estão OK!');

        // Marcar como OK mesmo sem correção
        await firestore.collection('turbinas').doc(widget.turbinaId).update({
          'componentsFixed': true,
          'componentsFixedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('❌ Erro na verificação automática: $e');
      // Não bloquear a UI por erro de verificação
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final turbinaAsync = ref.watch(selectedTurbinaProvider);

    if (_isMigrating) {
      return Scaffold(
        appBar: AppBar(
          title: turbinaAsync.when(
            data: (turbina) => Text(turbina?.nome ?? 'Turbina'),
            loading: () => const Text('Loading...'),
            error: (_, __) => const Text('Error'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(strokeWidth: 6),
              ),
              const SizedBox(height: 24),
              Text(
                t.translate('preparing_components'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  t.translate('migration_once_per_turbine'),
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.mediumGray),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🔧 Auto-fixing components...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '✓ Adding hardcodedId fields\n'
                      '✓ Fixing component names\n'
                      '✓ Creating missing components',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mediumGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: turbinaAsync.when(
          data: (turbina) =>
              Text(turbina?.nome ?? t.translate('turbine_details')),
          loading: () => Text(t.translate('loading')),
          error: (_, __) => Text(t.translate('error')),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final turbinaService = ref.read(turbinaServiceProvider);
              turbinaService.atualizarProgressoTurbina(widget.turbinaId);
            },
            tooltip: t.translate('refresh_progress'),
          ),
        ],
      ),
      body: turbinaAsync.when(
        data: (turbina) {
          if (turbina == null) {
            return Center(child: Text(t.translate('turbine_not_found')));
          }
          return _buildContent(context, turbina, t);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, turbina, TranslationHelper t) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderCard(turbina, t),
          _buildCategoriesSection(t),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(turbina, TranslationHelper t) {
    final color = AppColors.getStatusColor(turbina.status);
    final progresso = turbina.progresso;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: progresso / 100,
                      strokeWidth: 12,
                      backgroundColor: AppColors.borderGray,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${progresso.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        turbina.status,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.mediumGray,
                        ),
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

  // ══════════════════════════════════════════════════════════════════════════
  // 📋 DEFINIÇÃO DE COMPONENTES POR CATEGORIA (HARDCODED)
  // ══════════════════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> _getMainComponents() {
    List<Map<String, dynamic>> components = [
      {'id': 'top_cooler', 'nameKey': 'top_cooler', 'icon': Icons.ac_unit},
      {'id': 'bottom', 'nameKey': 'tower_bottom', 'icon': Icons.filter_1},
    ];

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

  List<Map<String, dynamic>> _getElectricalSystemsComponents() {
    return [
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
    ];
  }

  List<Map<String, dynamic>> _getMechanicalSystemsComponents() {
    return [
      {
        'id': 'gearbox',
        'nameKey': 'gearbox',
        'icon': Icons.settings_applications
      },
      {'id': 'coupling', 'nameKey': 'coupling', 'icon': Icons.link},
      {'id': 'service_lift', 'nameKey': 'service_lift', 'icon': Icons.elevator},
      {'id': 'lift_cables', 'nameKey': 'lift_cables', 'icon': Icons.cable},
    ];
  }

  List<Map<String, dynamic>> _getAuxiliarySystemsComponents() {
    return [
      {'id': 'resq', 'nameKey': 'resq', 'icon': Icons.sos},
      {
        'id': 'aviation_light_1',
        'nameKey': 'aviation_light_1',
        'icon': Icons.local_airport
      },
      {
        'id': 'aviation_light_2',
        'nameKey': 'aviation_light_2',
        'icon': Icons.flight
      },
      {
        'id': 'grua_interna',
        'nameKey': 'grua_interna',
        'icon': Icons.construction
      },
      {'id': 'cms', 'nameKey': 'cms', 'icon': Icons.monitor_heart},
      {'id': 'spare_parts', 'nameKey': 'spare_parts', 'icon': Icons.inventory},
      {
        'id': 'bodies_parts',
        'nameKey': 'bodies_parts',
        'icon': Icons.view_in_ar
      },
    ];
  }

  List<Map<String, dynamic>> _getCivilWorksComponents() {
    return [
      {'id': 'anchor_bolts', 'nameKey': 'anchor_bolts', 'icon': Icons.handyman},
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 SEÇÃO DE CATEGORIAS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildCategoriesSection(TranslationHelper t) {
    final categories = {
      'Main Components': _getMainComponents(),
      'Electrical Systems': _getElectricalSystemsComponents(),
      'Mechanical Systems': _getMechanicalSystemsComponents(),
      'Auxiliary Systems': _getAuxiliarySystemsComponents(),
      'Civil Works': _getCivilWorksComponents(),
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: categories.entries.map((entry) {
          return _buildCategoryCard(entry.key, entry.value, t);
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryCard(String categoria,
      List<Map<String, dynamic>> components, TranslationHelper t) {
    final isExpanded = _expandedCategories[categoria] ?? false;
    final categoryColor = _getCategoryColor(categoria);
    final allowsDynamicComponents = [
      'Auxiliary Systems',
      'Mechanical Systems',
    ].contains(categoria);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[categoria] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(categoria),
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.translate(categoria.toLowerCase().replaceAll(' ', '_')),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // ════════════════════════════════════════════════════════════════
                  // 🆕 ADICIONAR ISTO (botão "+")
                  // ════════════════════════════════════════════════════════════════
                  if (allowsDynamicComponents && isExpanded)
                    IconButton(
                      icon: Icon(Icons.add_circle, color: categoryColor),
                      onPressed: () => _showAddDynamicComponentDialog(
                        context,
                        categoria,
                        categoryColor,
                        t,
                      ),
                      tooltip: 'Adicionar componente',
                    ),
                  // ════════════════════════════════════════════════════════════════

                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.mediumGray,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: allowsDynamicComponents
                  ? _buildComponentsGridWithDynamic(
                      components, categoria, t) // ← NOVO
                  : _buildComponentsGrid(components, t), // ← MANTÉM ORIGINAL
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📦 GRID DE COMPONENTES (IGUAL À INSTALAÇÃO)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildComponentsGrid(
      List<Map<String, dynamic>> components, TranslationHelper t) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 8 : 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: components.length,
      itemBuilder: (context, index) {
        return _buildComponentCard(components[index], t);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 CARD DE COMPONENTE COM SINCRONIZAÇÃO EM TEMPO REAL
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildComponentCard(
      Map<String, dynamic> component, TranslationHelper t) {
    final componentHardcodedId = component['id'] as String;
    final fullComponentId = ComponentMapping.buildFullComponentId(
      componentHardcodedId,
      widget.turbinaId,
    );

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('installation_data')
          .doc(widget.turbinaId)
          .collection('components')
          .doc(fullComponentId)
          .snapshots(),
      builder: (context, snapshot) {
        // ─────────────────────────────────────────────────────────────────
        // LOADING
        // ─────────────────────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCardSkeleton(component, t);
        }

        // ─────────────────────────────────────────────────────────────────
        // ERROR
        // ─────────────────────────────────────────────────────────────────
        if (snapshot.hasError) {
          print('❌ Erro ao buscar $fullComponentId: ${snapshot.error}');
          return _buildErrorCard(component, t);
        }

        // ─────────────────────────────────────────────────────────────────
        // SEM DADOS
        // ─────────────────────────────────────────────────────────────────
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildEmptyCard(component, t);
        }

        // ─────────────────────────────────────────────────────────────────
        // DADOS RECEBIDOS ✅
        // ─────────────────────────────────────────────────────────────────
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) {
          return _buildEmptyCard(component, t);
        }

        // Calcular progresso
        double progresso = _calculateProgressFromData(data);

        // Extrair VUI
        String? vui;
        if (data['reception'] != null) {
          final reception = data['reception'] as Map<String, dynamic>;
          vui = reception['vui'] as String?;
        }

        return _buildFilledCard(component, progresso, vui, t);
      },
    );
  }

  double _calculateProgressFromData(Map<String, dynamic> data) {
    double progress = 0;

    // Receção: 20%
    if (data['reception'] != null) {
      final reception = data['reception'] as Map<String, dynamic>;
      bool hasData = (reception['vui'] != null &&
              reception['vui'].toString().isNotEmpty) ||
          (reception['serialNumber'] != null &&
              reception['serialNumber'].toString().isNotEmpty) ||
          (reception['itemNumber'] != null &&
              reception['itemNumber'].toString().isNotEmpty);

      if (reception['isCompleted'] == true || hasData) {
        progress += 20;
      }
    }

    // Preparação: 20%
    if (data['preparation'] != null) {
      final preparation = data['preparation'] as Map<String, dynamic>;
      if (preparation['isCompleted'] == true ||
          preparation['dataInicio'] != null ||
          preparation['dataFim'] != null) {
        progress += 20;
      }
    }

    // Pre-Assembly: 20%
    if (data['preAssembly'] != null) {
      final preAssembly = data['preAssembly'] as Map<String, dynamic>;
      if (preAssembly['isCompleted'] == true ||
          preAssembly['dataInicio'] != null ||
          preAssembly['dataFim'] != null) {
        progress += 20;
      }
    }

    // Assembly: 20%
    if (data['assembly'] != null) {
      final assembly = data['assembly'] as Map<String, dynamic>;
      if (assembly['isCompleted'] == true ||
          assembly['dataInicio'] != null ||
          assembly['dataFim'] != null) {
        progress += 20;
      }
    }

    // Fases Finais: 20%
    if (data['finalPhases'] != null) {
      final finalPhases = data['finalPhases'] as Map<String, dynamic>;
      int completedFinalPhases = 0;
      int totalFinalPhases = 0;

      finalPhases.forEach((key, value) {
        if (value is Map && value['isCompleted'] == true) {
          completedFinalPhases++;
        }
        totalFinalPhases++;
      });

      if (totalFinalPhases > 0) {
        progress += (completedFinalPhases / totalFinalPhases) * 20;
      }
    }

    return progress.clamp(0.0, 100.0);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 VARIAÇÕES DO CARD
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFilledCard(Map<String, dynamic> component, double progresso,
      String? vui, TranslationHelper t) {
    final Color statusColor = progresso >= 100
        ? AppColors.successGreen
        : progresso > 0
            ? AppColors.warningOrange
            : AppColors.mediumGray;

    final displayName =
        component['displayName'] ?? t.translate(component['nameKey'] as String);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _openComponentDetails(component),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(component['icon'] as IconData, size: 28, color: statusColor),
              const SizedBox(height: 4),
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
              if (vui != null && vui.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  vui,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${progresso.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(Map<String, dynamic> component, TranslationHelper t) {
    final displayName =
        component['displayName'] ?? t.translate(component['nameKey'] as String);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _openComponentDetails(component),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(component['icon'] as IconData,
                  size: 28, color: AppColors.mediumGray),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mediumGray,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              const Text(
                '0%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSkeleton(
      Map<String, dynamic> component, TranslationHelper t) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(Map<String, dynamic> component, TranslationHelper t) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _openComponentDetails(component),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 28, color: Colors.red[300]),
              const SizedBox(height: 4),
              Text(
                'Erro',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 ABRIR DIALOG DE DETALHES (COM DEBUG COMPLETO)
  // ══════════════════════════════════════════════════════════════════════════

  void _openComponentDetails(Map<String, dynamic> component) async {
    final componentHardcodedId = component['id'] as String;
    final fullComponentId = ComponentMapping.buildFullComponentId(
      componentHardcodedId,
      widget.turbinaId,
    );

    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║  🔍 ABRINDO DETALHES DO COMPONENTE                        ║');
    print('╚════════════════════════════════════════════════════════════╝');
    print('   hardcodedId: $componentHardcodedId');
    print('   fullComponentId: $fullComponentId');
    print('   turbinaId: ${widget.turbinaId}');
    print('───────────────────────────────────────────────────────────');

    try {
      // ════════════════════════════════════════════════════════════════════
      // ESTRATÉGIA 1: Busca Direta por ID
      // ════════════════════════════════════════════════════════════════════
      print('🔄 Tentando busca direta por ID: $fullComponentId');

      final snapshot = await FirebaseFirestore.instance
          .collection('componentes')
          .doc(fullComponentId)
          .get();

      if (snapshot.exists) {
        print('✅ ENCONTRADO via busca direta!');
        final data = snapshot.data()!;

        // Debug: Mostrar TODOS os campos
        print('📋 Campos do componente:');
        data.forEach((key, value) {
          print('   • $key: $value');
        });
        print('───────────────────────────────────────────────────────────');

        final componente = Componente.fromFirestore(snapshot);
        print('✅ Componente parseado com sucesso: ${componente.nome}');

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => EditComponenteDialog(componente: componente),
          );
        }
        return;
      }

      print('❌ NÃO encontrado via busca direta');

      // ════════════════════════════════════════════════════════════════════
      // ESTRATÉGIA 2: Busca por Query (Fallback)
      // ════════════════════════════════════════════════════════════════════
      print('🔄 Tentando busca por query...');
      print('   turbinaId: ${widget.turbinaId}');
      print('   hardcodedId: $componentHardcodedId');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbinaId)
          .where('hardcodedId', isEqualTo: componentHardcodedId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('✅ ENCONTRADO via query!');
        final doc = querySnapshot.docs.first;
        final data = doc.data();

        // Debug: Mostrar TODOS os campos
        print('📋 Campos do componente:');
        data.forEach((key, value) {
          print('   • $key: $value');
        });
        print('───────────────────────────────────────────────────────────');

        final componente = Componente.fromFirestore(doc);
        print('✅ Componente parseado com sucesso: ${componente.nome}');

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => EditComponenteDialog(componente: componente),
          );
        }
        return;
      }

      print('❌ NÃO encontrado via query');

      // ════════════════════════════════════════════════════════════════════
      // ESTRATÉGIA 3: Listar TODOS os componentes da turbina (DEBUG)
      // ════════════════════════════════════════════════════════════════════
      print('🔍 Listando TODOS os componentes desta turbina:');

      final allComponents = await FirebaseFirestore.instance
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbinaId)
          .get();

      print('📊 Total encontrados: ${allComponents.docs.length}');

      for (var doc in allComponents.docs) {
        final data = doc.data();
        print('   • ID: ${doc.id}');
        print('     nome: ${data['nome']}');
        print('     hardcodedId: ${data['hardcodedId'] ?? "[NÃO TEM]"}');
        print('     categoria: ${data['categoria']}');
      }
      print('───────────────────────────────────────────────────────────');

      // ════════════════════════════════════════════════════════════════════
      // ESTRATÉGIA 4: Buscar por NOME (último recurso)
      // ════════════════════════════════════════════════════════════════════
      final componentName =
          ComponentMapping.hardcodedToName[componentHardcodedId];
      if (componentName != null) {
        print('🔄 Tentando buscar por nome: $componentName');

        final nameQuerySnapshot = await FirebaseFirestore.instance
            .collection('componentes')
            .where('turbinaId', isEqualTo: widget.turbinaId)
            .where('nome', isEqualTo: componentName)
            .limit(1)
            .get();

        if (nameQuerySnapshot.docs.isNotEmpty) {
          print('✅ ENCONTRADO por nome!');
          final doc = nameQuerySnapshot.docs.first;

          print(
              '⚠️  PROBLEMA: Componente existe mas não tem hardcodedId correto!');
          print('   Executar script de correção: fixComponentsHardcodedId()');

          final componente = Componente.fromFirestore(doc);

          if (mounted) {
            showDialog(
              context: context,
              builder: (context) =>
                  EditComponenteDialog(componente: componente),
            );
          }
          return;
        }
      }

      // ════════════════════════════════════════════════════════════════════
      // Nenhuma estratégia funcionou
      // ════════════════════════════════════════════════════════════════════
      print('❌ COMPONENTE NÃO ENCONTRADO em nenhuma estratégia!');
      print('═══════════════════════════════════════════════════════════\n');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Component not found: $componentName'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (error, stackTrace) {
      print('❌ ERRO ao buscar componente: $error');
      print('StackTrace: $stackTrace');
      print('═══════════════════════════════════════════════════════════\n');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Color _getCategoryColor(String categoria) {
    switch (categoria) {
      case 'Civil Works':
        return const Color(0xFF94A3B8);
      case 'Main Components':
        return const Color(0xFF1E3A8A);
      case 'Electrical Systems':
        return const Color(0xFFEA580C);
      case 'Mechanical Systems':
        return const Color(0xFF059669);
      case 'Auxiliary Systems':
        return const Color(0xFF0891B2);
      default:
        return AppColors.mediumGray;
    }
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case 'Civil Works':
        return Icons.foundation;
      case 'Main Components':
        return Icons.wind_power;
      case 'Electrical Systems':
        return Icons.electrical_services;
      case 'Mechanical Systems':
        return Icons.precision_manufacturing;
      case 'Auxiliary Systems':
        return Icons.elevator;
      default:
        return Icons.widgets;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 MÉTODO DE CORREÇÃO DE COMPONENTES
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _fixAllComponents() async {
    final firestore = FirebaseFirestore.instance;

    print('\n╔════════════════════════════════════════════════════════════╗');
    print('║  🔧 CORREÇÃO COMPLETA DE COMPONENTES                      ║');
    print('╚════════════════════════════════════════════════════════════╝\n');

    final componentFixes = {
      'Trafo': {
        'newName': 'Transformador',
        'hardcodedId': 'transformador',
        'categoria': 'Electrical Systems',
      },
      'Nacelle Top Cooler': {
        'newName': 'Top Cooler',
        'hardcodedId': 'top_cooler',
        'categoria': 'Main Components',
      },
      'Ground Controller': {
        'newName': 'Ground Control',
        'hardcodedId': 'ground_control',
        'categoria': 'Electrical Systems',
      },
      'Anchor bolts': {
        'newName': 'Anchor Bolts',
        'hardcodedId': 'anchor_bolts',
        'categoria': 'Civil Works',
      },
      'Blade 1 / a': {
        'newName': 'Blade 1',
        'hardcodedId': 'blade_1',
        'categoria': 'Main Components',
      },
      'Blade 2 / b': {
        'newName': 'Blade 2',
        'hardcodedId': 'blade_2',
        'categoria': 'Main Components',
      },
      'Blade 3 / c': {
        'newName': 'Blade 3',
        'hardcodedId': 'blade_3',
        'categoria': 'Main Components',
      },
    };

    try {
      final snapshot = await firestore
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbinaId)
          .get();

      print('✅ Encontrados ${snapshot.docs.length} componentes\n');

      int fixed = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nome = data['nome'] as String;

        if (componentFixes.containsKey(nome)) {
          final fix = componentFixes[nome]!;
          final newName = fix['newName']!;
          final hardcodedId = fix['hardcodedId']!;
          final newId = '${hardcodedId}_${widget.turbinaId}';

          print('🔧 Corrigindo: $nome → $newName');

          await firestore.collection('componentes').doc(newId).set({
            ...data,
            'nome': newName,
            'hardcodedId': hardcodedId,
            'categoria': fix['categoria']!,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          await doc.reference.delete();

          print('   ✅ CORRIGIDO: $newId');
          fixed++;
        }
      }

      // Criar componentes novos
      final newComponents = [
        {
          'hardcodedId': 'gerador',
          'nome': 'Gerador',
          'categoria': 'Electrical Systems'
        },
        {
          'hardcodedId': 'light_control',
          'nome': 'Light Control',
          'categoria': 'Electrical Systems'
        },
        {
          'hardcodedId': 'light_battery',
          'nome': 'Light Battery',
          'categoria': 'Electrical Systems'
        },
        {
          'hardcodedId': 'ups',
          'nome': 'UPS',
          'categoria': 'Electrical Systems'
        },
        {
          'hardcodedId': 'gearbox',
          'nome': 'Gearbox',
          'categoria': 'Mechanical Systems'
        },
        {
          'hardcodedId': 'coupling',
          'nome': 'Coupling',
          'categoria': 'Mechanical Systems'
        },
        {
          'hardcodedId': 'lift_cables',
          'nome': 'Lift Cables',
          'categoria': 'Mechanical Systems'
        },
        {
          'hardcodedId': 'aviation_light_1',
          'nome': 'Aviation Light 1',
          'categoria': 'Auxiliary Systems'
        },
        {
          'hardcodedId': 'aviation_light_2',
          'nome': 'Aviation Light 2',
          'categoria': 'Auxiliary Systems'
        },
        {
          'hardcodedId': 'grua_interna',
          'nome': 'Grua Interna',
          'categoria': 'Auxiliary Systems'
        },
        {'hardcodedId': 'cms', 'nome': 'CMS', 'categoria': 'Auxiliary Systems'},
      ];

      int created = 0;

      for (var comp in newComponents) {
        final hardcodedId = comp['hardcodedId']!;
        final newId = '${hardcodedId}_${widget.turbinaId}';

        final exists =
            await firestore.collection('componentes').doc(newId).get();

        if (!exists.exists) {
          print('🆕 Criando: ${comp['nome']}');

          final turbinaDoc = await firestore
              .collection('turbinas')
              .doc(widget.turbinaId)
              .get();
          final projectId = turbinaDoc.data()?['projectId'] ?? '';

          await firestore.collection('componentes').doc(newId).set({
            'nome': comp['nome']!,
            'hardcodedId': hardcodedId,
            'categoria': comp['categoria']!,
            'turbinaId': widget.turbinaId,
            'projectId': projectId,
            'progresso': 0.0,
            'status': 'Pendente',
            'aplicavel': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          print('   ✅ CRIADO: $newId');
          created++;
        }
      }

      print('\n═══════════════════════════════════════════════════════════');
      print('📊 RESUMO: $fixed corrigidos, $created criados');
      print('═══════════════════════════════════════════════════════════\n');
    } catch (e, stackTrace) {
      print('❌ ERRO: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }
  // ══════════════════════════════════════════════════════════════════════════
  // 🆕 MÉTODO 1: GRID COM COMPONENTES DINÂMICOS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildComponentsGridWithDynamic(
    List<Map<String, dynamic>> staticComponents,
    String categoria,
    TranslationHelper t,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('componentes')
          .where('turbinaId', isEqualTo: widget.turbinaId)
          .where('isDynamic', isEqualTo: true)
          .where('categoria', isEqualTo: categoria)
          .snapshots(),
      builder: (context, dynamicSnapshot) {
        final allComponents = <Map<String, dynamic>>[...staticComponents];

        if (dynamicSnapshot.hasData && dynamicSnapshot.data != null) {
          for (var doc in dynamicSnapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            allComponents.add({
              'id': data['hardcodedId'] ?? doc.id,
              'nameKey': data['nome'],
              'displayName': data['nome'],
              'icon': Icons.inventory_2,
              'isDynamic': true,
            });
          }
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 8 : 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: allComponents.length,
          itemBuilder: (context, index) {
            return _buildComponentCard(allComponents[index], t);
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🆕 MÉTODO 2: DIALOG PARA CRIAR COMPONENTE
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
                const SizedBox(width: 12),
                const Text('Adicionar Componente'),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nome do Componente',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Ex: Spare Part 1',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Fases de Integração',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
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
                                const SizedBox(width: 8),
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
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
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
                child: const Text('Cancelar'),
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
                icon: const Icon(Icons.add),
                label: const Text('Criar'),
                style: ElevatedButton.styleFrom(backgroundColor: categoryColor),
              ),
            ],
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🆕 MÉTODO 3: CRIAR COMPONENTE NO FIREBASE
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _createDynamicComponent(
    String componentName,
    String categoria,
    List<String> selectedPhases,
  ) async {
    try {
      print('🆕 Criando: $componentName');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
      final fullComponentId = '${hardcodedId}_${widget.turbinaId}';

      final turbinaDoc =
          await firestore.collection('turbinas').doc(widget.turbinaId).get();
      final projectId = turbinaDoc.data()?['projectId'] ?? '';

      await firestore.collection('componentes').doc(fullComponentId).set({
        'nome': componentName,
        'hardcodedId': hardcodedId,
        'categoria': categoria,
        'turbinaId': widget.turbinaId,
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
          .doc(widget.turbinaId)
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
          'turbinaId': widget.turbinaId,
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
            duration: const Duration(seconds: 3),
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
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

class EditComponenteDialog extends ConsumerStatefulWidget {
  final Componente componente;

  const EditComponenteDialog({
    super.key,
    required this.componente,
  });

  @override
  ConsumerState<EditComponenteDialog> createState() =>
      _EditComponenteDialogState();
}

class _EditComponenteDialogState extends ConsumerState<EditComponenteDialog> {
  late double _progresso;
  late String _status;
  late bool _aplicavel;
  late String turbinaId;
  late String _componenteId;

  final _itemNumberController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _vuiController = TextEditingController();
  final _observacoesController = TextEditingController();

  bool _isLoading = false;
  bool _isBlocked = false;
  String? _blockReason;
  String? _blockedBy;

  List<String> _photos = [];
  List<Map<String, dynamic>> _aggregatedNotes = [];

  StreamSubscription<DocumentSnapshot>? _installationListener;
  bool _isSyncingFromInstallation = false;

  @override
  void initState() {
    super.initState();

    turbinaId = widget.componente.turbinaId; // ← linha nova
    _componenteId = widget.componente.id; // ← linha nova

    _progresso = widget.componente.progresso;
    _status = widget.componente.status;

    if (!['Pendente', 'Em Progresso', 'Concluído', 'Bloqueado', 'N/A']
        .contains(_status)) {
      _status = 'Pendente';
    }

    _aplicavel = widget.componente.aplicavel;
    _itemNumberController.text = widget.componente.itemNumber ?? '';
    _serialNumberController.text = widget.componente.serialNumber ?? '';
    _vuiController.text = widget.componente.vui ?? '';
    _observacoesController.text = widget.componente.observacoes ?? '';

    if (_status == 'N/A') {
      _aplicavel = false;
    }

    if (_status == 'Bloqueado') {
      _isBlocked = true;
    }

    _startInstallationListener();
  }

  void _startInstallationListener() {
    print(
        '🔄 Iniciando listener para: ${widget.componente.turbinaId} / ${widget.componente.id}');
    print('📋 hardcodedId: ${widget.componente.hardcodedId}');

    String installationDocId;

    if (widget.componente.hardcodedId != null) {
      installationDocId = ComponentMapping.buildFullComponentId(
        widget.componente.hardcodedId!,
        widget.componente.turbinaId,
      );
      print('✅ Usando hardcodedId: $installationDocId');
    } else {
      installationDocId = widget.componente.id;
      print('⚠️ Sem hardcodedId, usando ID do componente: $installationDocId');
    }

    _installationListener = FirebaseFirestore.instance
        .collection('installation_data')
        .doc(widget.componente.turbinaId)
        .collection('components')
        .doc(installationDocId)
        .snapshots()
        .listen(
      (snapshot) {
        if (!snapshot.exists) {
          print(
              'ℹ️ Documento de instalação ainda não existe: $installationDocId');
          return;
        }

        print('✅ Dados da instalação recebidos para: $installationDocId');
        _syncFromInstallation(snapshot.data() as Map<String, dynamic>);
      },
      onError: (error) {
        print('❌ Erro no listener: $error');
      },
    );
  }

  void _syncFromInstallation(Map<String, dynamic> data) {
    if (_isSyncingFromInstallation) return;

    setState(() {
      _isSyncingFromInstallation = true;

      if (data['reception'] != null) {
        final reception = data['reception'] as Map<String, dynamic>;

        _vuiController.text = reception['vui'] ?? '';
        _serialNumberController.text = reception['serialNumber'] ?? '';
        _itemNumberController.text = reception['itemNumber'] ?? '';

        print('📦 Campos auto-preenchidos da Receção');
      }

      _progresso = _calculateProgressFromPhases(data);
      print('📊 Progresso calculado: $_progresso%');

      if (!_isBlocked && _status != 'N/A') {
        _status = _getAutoStatus();
        print('📊 Status atualizado: $_status');
      }

      _aggregatedNotes = _aggregateNotes(data);
      print('📝 ${_aggregatedNotes.length} notas agregadas');

      _photos = _aggregatePhotos(data);
      print('📸 ${_photos.length} fotos agregadas');

      _isSyncingFromInstallation = false;
    });

    _updateComponenteInAsBuilt();
  }

  double _calculateProgressFromPhases(Map<String, dynamic> data) {
    double progress = 0;

    if (data['reception'] != null) {
      final reception = data['reception'] as Map<String, dynamic>;
      bool hasData = (reception['vui'] != null &&
              reception['vui'].toString().isNotEmpty) ||
          (reception['serialNumber'] != null &&
              reception['serialNumber'].toString().isNotEmpty) ||
          (reception['itemNumber'] != null &&
              reception['itemNumber'].toString().isNotEmpty);

      if (reception['isCompleted'] == true || hasData) {
        progress += 20;
      }
    }

    if (data['preparation'] != null) {
      final preparation = data['preparation'] as Map<String, dynamic>;
      bool hasData =
          preparation['dataInicio'] != null || preparation['dataFim'] != null;

      if (preparation['isCompleted'] == true || hasData) {
        progress += 20;
      }
    }

    if (data['preAssembly'] != null) {
      final preAssembly = data['preAssembly'] as Map<String, dynamic>;
      bool hasData =
          preAssembly['dataInicio'] != null || preAssembly['dataFim'] != null;

      if (preAssembly['isCompleted'] == true || hasData) {
        progress += 20;
      }
    }

    if (data['assembly'] != null) {
      final assembly = data['assembly'] as Map<String, dynamic>;
      bool hasData =
          assembly['dataInicio'] != null || assembly['dataFim'] != null;

      if (assembly['isCompleted'] == true || hasData) {
        progress += 20;
      }
    }

    final finalPhases = data['finalPhases'] as Map<String, dynamic>?;
    if (finalPhases != null) {
      int completedFinalPhases = 0;
      int totalFinalPhases = 0;

      finalPhases.forEach((key, value) {
        if (value is Map && value['isCompleted'] == true) {
          completedFinalPhases++;
        }
        totalFinalPhases++;
      });

      if (totalFinalPhases > 0) {
        progress += (completedFinalPhases / totalFinalPhases) * 20;
      }
    }

    return progress.clamp(0.0, 100.0);
  }

  String _getAutoStatus() {
    if (_progresso == 0) return 'Pendente';
    if (_progresso >= 100) return 'Concluído';
    return 'Em Progresso';
  }

  List<Map<String, dynamic>> _aggregateNotes(Map<String, dynamic> data) {
    List<Map<String, dynamic>> notes = [];

    final phaseConfig = {
      'reception': {'icon': '📦', 'name': 'reception'},
      'preparation': {'icon': '📋', 'name': 'preparation'},
      'preAssembly': {'icon': '🔧', 'name': 'pre_assembly'},
      'assembly': {'icon': '🏗️', 'name': 'assembly'},
      'electricalWorks': {'icon': '⚡', 'name': 'electricalWorks'},
      'mechanicalWorks': {'icon': '🔩', 'name': 'mechanicalWorks'},
    };

    phaseConfig.forEach((phaseKey, config) {
      if (data[phaseKey] != null) {
        final phaseData = data[phaseKey] as Map<String, dynamic>;

        if (phaseData['observacoes'] != null &&
            phaseData['observacoes'].toString().trim().isNotEmpty) {
          DateTime? date;
          if (phaseData['dataFim'] != null) {
            date = (phaseData['dataFim'] as Timestamp).toDate();
          } else if (phaseData['dataInicio'] != null) {
            date = (phaseData['dataInicio'] as Timestamp).toDate();
          } else {
            date = DateTime.now();
          }

          notes.add({
            'phase': config['name'],
            'phaseIcon': config['icon'],
            'date': date,
            'text': phaseData['observacoes'],
          });
        }
      }
    });

    notes.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return notes;
  }

  List<String> _aggregatePhotos(Map<String, dynamic> data) {
    List<String> photos = [];

    final phases = [
      'reception',
      'preparation',
      'preAssembly',
      'assembly',
      'electricalWorks',
      'mechanicalWorks',
    ];

    for (var phase in phases) {
      if (data[phase] != null) {
        final phaseData = data[phase] as Map<String, dynamic>;

        if (phaseData['fotos'] != null && phaseData['fotos'] is List) {
          photos.addAll(List<String>.from(phaseData['fotos']));
        }
      }
    }

    return photos;
  }

  Future<void> _updateComponenteInAsBuilt() async {
    try {
      final componenteService = ref.read(componenteServiceProvider);

      await componenteService.updateComponente(widget.componente.id, {
        'progresso': _progresso,
        'status': _status,
        'vui': _vuiController.text.trim().isEmpty
            ? null
            : _vuiController.text.trim(),
        'itemNumber': _itemNumberController.text.trim().isEmpty
            ? null
            : _itemNumberController.text.trim(),
        'serialNumber': _serialNumberController.text.trim().isEmpty
            ? null
            : _serialNumberController.text.trim(),
      });

      final turbinaService = ref.read(turbinaServiceProvider);
      await turbinaService
          .atualizarProgressoTurbina(widget.componente.turbinaId);

      print('✅ Componente atualizado no As-Built');
    } catch (e) {
      print('❌ Erro ao atualizar componente: $e');
    }
  }

  @override
  void dispose() {
    _installationListener?.cancel();
    _itemNumberController.dispose();
    _serialNumberController.dispose();
    _vuiController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final isNA = _status == 'N/A';

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            _buildHeader(t),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isSyncingFromInstallation)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.primaryBlue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              t.translate('syncing_from_installation'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildNAToggle(t, isNA),
                    if (!isNA) ...[
                      const SizedBox(height: 16),
                      _buildProgressSection(t),
                      const SizedBox(height: 16),
                      _buildStatusDropdown(t),
                      const SizedBox(height: 16),
                      _buildAutoFilledFields(t),
                      const SizedBox(height: 16),
                      _buildAggregatedNotes(t),
                      const SizedBox(height: 16),
                      _buildPhotosGallery(t),
                      const SizedBox(height: 16),
                      _buildObservationsField(t),
                    ],
                  ],
                ),
              ),
            ),
            _buildFooter(t, isNA),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TODOS OS WIDGETS DO DIALOG (CÓDIGO ORIGINAL MANTIDO)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(TranslationHelper t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        border: Border(bottom: BorderSide(color: AppColors.borderGray)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.componente.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.componente.categoria,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_canBlock())
            IconButton(
              icon: Icon(_isBlocked ? Icons.lock : Icons.lock_open,
                  color: Colors.white),
              onPressed: () => _showBlockDialog(t),
              tooltip:
                  _isBlocked ? t.translate('unblock') : t.translate('block'),
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNAToggle(TranslationHelper t, bool isNA) {
    return Card(
      color: isNA
          ? AppColors.mediumGray.withOpacity(0.1)
          : AppColors.accentTeal.withOpacity(0.1),
      child: SwitchListTile(
        title: Text(
          t.translate('not_applicable'),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isNA
              ? t.translate('component_not_used')
              : t.translate('mark_if_not_installed'),
          style: const TextStyle(fontSize: 12),
        ),
        value: isNA,
        onChanged: _isBlocked
            ? null
            : (value) {
                setState(() {
                  if (value) {
                    _status = 'N/A';
                    _aplicavel = false;
                    _progresso = 0;
                  } else {
                    _status = 'Pendente';
                    _aplicavel = true;
                  }
                });
              },
        activeThumbColor: AppColors.mediumGray,
      ),
    );
  }

  Widget _buildProgressSection(TranslationHelper t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.translate('progress'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.mediumGray,
              ),
            ),
            Text(
              '${_progresso.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(20, (index) {
            final isFilled = index < (_progresso / 5).round();
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: isFilled ? AppColors.primaryBlue : AppColors.borderGray,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _progresso,
          min: 0,
          max: 100,
          divisions: 20,
          label: '${_progresso.toStringAsFixed(0)}%',
          onChanged: _isBlocked
              ? null
              : (value) {
                  setState(() {
                    _progresso = value;
                    if (value >= 100) {
                      _status = 'Concluído';
                    } else if (value > 0) {
                      _status = 'Em Progresso';
                    } else {
                      _status = 'Pendente';
                    }
                  });
                },
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(TranslationHelper t) {
    final statuses = [
      {'value': 'Pendente', 'color': AppColors.mediumGray},
      {'value': 'Em Progresso', 'color': AppColors.warningOrange},
      {'value': 'Concluído', 'color': AppColors.successGreen},
      {'value': 'Bloqueado', 'color': Colors.red},
      {'value': 'N/A', 'color': AppColors.mediumGray},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('status'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGray),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: statuses.any((s) => s['value'] == _status)
                  ? _status
                  : 'Pendente',
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status['value'] as String,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: status['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(t.translate('component_status_${status['value']}')),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isBlocked
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
            ),
          ),
        ),
        if (_isBlocked) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${t.translate('blocked_by')}: $_blockedBy',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _blockReason ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAutoFilledFields(TranslationHelper t) {
    return Column(
      children: [
        _buildReadOnlyField(
          label: 'VUI / Unit ID',
          controller: _vuiController,
          icon: Icons.qr_code,
          t: t,
        ),
        const SizedBox(height: 12),
        _buildReadOnlyField(
          label: t.translate('item_number'),
          controller: _itemNumberController,
          icon: Icons.numbers,
          t: t,
        ),
        const SizedBox(height: 12),
        _buildReadOnlyField(
          label: t.translate('serial_number'),
          controller: _serialNumberController,
          icon: Icons.tag,
          t: t,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required TranslationHelper t,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            suffixIcon: const Icon(Icons.sync, color: AppColors.successGreen),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: AppColors.successGreen.withOpacity(0.05),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAggregatedNotes(TranslationHelper t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('notes'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 12),
        if (_aggregatedNotes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.borderGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                t.translate('no_notes'),
                style: const TextStyle(color: AppColors.mediumGray),
              ),
            ),
          )
        else
          ..._aggregatedNotes.map((note) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderGray),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        note['phaseIcon'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.translate(note['phase']),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(note['date']),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note['text'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPhotosGallery(TranslationHelper t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📸 ${t.translate('photos')} (${_photos.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            TextButton.icon(
              onPressed: _addPhoto,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(t.translate('add')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_photos.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.borderGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                t.translate('no_photos'),
                style: const TextStyle(color: AppColors.mediumGray),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showPhotoFullscreen(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.borderGray,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderGray),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const Icon(Icons.image,
                          size: 40, color: AppColors.mediumGray),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '📦',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildObservationsField(TranslationHelper t) {
    return TextField(
      controller: _observacoesController,
      decoration: InputDecoration(
        labelText: t.translate('observations'),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.notes),
        hintText: t.translate('add_notes_optional'),
      ),
      maxLines: 3,
      enabled: !_isBlocked,
    );
  }

  Widget _buildFooter(TranslationHelper t, bool isNA) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundGray,
        border: Border(top: BorderSide(color: AppColors.borderGray)),
      ),
      child: Row(
        children: [
          if (!isNA && widget.componente.status != 'Substituído')
            TextButton.icon(
              onPressed: _isLoading || _isBlocked
                  ? null
                  : () => _showReplaceDialog(context, t),
              icon:
                  const Icon(Icons.swap_horiz, color: AppColors.warningOrange),
              label: Text(
                t.translate('replace'),
                style: const TextStyle(color: AppColors.warningOrange),
              ),
            ),
          const Spacer(),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isLoading || _isBlocked ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(t.translate('save')),
          ),
        ],
      ),
    );
  }

  final PhotoService _photoService = PhotoService();

  void _addPhoto() async {
    try {
      print('🔵 _addPhoto START');

      final String? turbinaId = ref.read(selectedTurbinaIdProvider);
      if (turbinaId == null) {
        print('❌ turbinaId null em _addPhoto');
        return;
      }

      print('🔵 _addPhoto -> turbinaId=$turbinaId componenteId=$_componenteId');

      final url = await _photoService.pickAndUploadPhotoForFase(
        turbinaId: turbinaId,
        componenteId: _componenteId,
        tipoFase: 'as_built',
      );

      print('🔵 _addPhoto -> url retornada: $url');

      if (url == null) {
        print('⚠️ _addPhoto: url null, não vou atualizar Firestore/UI');
        return;
      }

      setState(() {
        _photos.add(url);
      });

      final installationRef = FirebaseFirestore.instance
          .collection('installation_data')
          .doc(turbinaId)
          .collection('components')
          .doc(_componenteId);
      await installationRef.update({
        'asBuiltPhotos': FieldValue.arrayUnion([url]),
      });
    } catch (e, st) {
      print('❌ ERRO em _addPhoto: $e');
      print(st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao adicionar foto: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showPhotoFullscreen(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, size: 100, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'Photo ${index + 1}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockDialog(TranslationHelper t) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isBlocked
            ? t.translate('unblock_component')
            : t.translate('block_component')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isBlocked) ...[
              Text(t.translate('block_reason_required')),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: t.translate('enter_block_reason'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ] else ...[
              Text(t.translate('confirm_unblock')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (!_isBlocked && reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.translate('reason_required'))),
                );
                return;
              }

              setState(() {
                _isBlocked = !_isBlocked;
                if (_isBlocked) {
                  _blockReason = reasonController.text;
                  _blockedBy = 'João Silva';
                  _status = 'Bloqueado';
                } else {
                  _blockReason = null;
                  _blockedBy = null;
                  _status = 'Pendente';
                }
              });

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isBlocked ? AppColors.successGreen : Colors.red,
            ),
            child: Text(
                _isBlocked ? t.translate('unblock') : t.translate('block')),
          ),
        ],
      ),
    );
  }

  bool _canBlock() {
    return true;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _handleSave() async {
    final t = TranslationHelper.of(context);
    setState(() => _isLoading = true);

    try {
      final componenteService = ref.read(componenteServiceProvider);
      final turbinaService = ref.read(turbinaServiceProvider);

      await componenteService.updateComponente(widget.componente.id, {
        'progresso': _progresso,
        'status': _status,
        'aplicavel': _aplicavel,
        'itemNumber': _itemNumberController.text.trim().isEmpty
            ? null
            : _itemNumberController.text.trim(),
        'serialNumber': _serialNumberController.text.trim().isEmpty
            ? null
            : _serialNumberController.text.trim(),
        'vui': _vuiController.text.trim().isEmpty
            ? null
            : _vuiController.text.trim(),
        'observacoes': _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
      });

      await turbinaService.atualizarProgressoTurbina(
        widget.componente.turbinaId,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('component_updated_success')),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.translate('error')}: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showReplaceDialog(BuildContext context, TranslationHelper t) {
    // Use existing replace dialog
  }
}
