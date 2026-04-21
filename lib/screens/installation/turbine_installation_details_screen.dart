import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/installation/fase_componente.dart';
import '../../models/installation/tipo_fase.dart';
import '../../widgets/installation/final_phases_cards_view.dart';
import 'fase_edit_dialog.dart';
import '../../providers/app_providers.dart';
import '../../screens/torque_tensioning/torque_tensioning_screen.dart';
import '../../screens/mobile/logistica_form_screen.dart';
import '../../screens/mobile/mobile_app.dart';
import '../../screens/mobile/mobile_projects_screen.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../widgets/mobile/turbine_location_sheet.dart';
import '../auth/login_screen.dart';

part 'turbine_installation_details_screen.g.dart';

// ============================================================================
// 🏗️ TELA DE DETALHES DA INSTALAÇÃO DA TURBINA - COM BOTÕES MOBILE
// ============================================================================

// Riverpod 3.x annotation-based provider for installation phase selection
@riverpod
class SelectedInstallationPhase extends _$SelectedInstallationPhase {
  @override
  String? build() => null;

  void setPhase(String? phase) => state = phase;
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
  bool _isMigrating = false;
  bool _isOpeningTorqueScreen = false;

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

      debugPrint(
          '📊 Status migração Instalação turbina ${widget.turbineName}:');
      debugPrint('   Total: ${status['total']}');
      debugPrint('   Migrados: ${status['migrated']}');
      debugPrint('   Pendentes: ${status['pending']}');

      // Se houver componentes pendentes, migrar automaticamente
      if (status['pending'] > 0) {
        debugPrint(
            '🔄 Instalação: Migrando ${status['pending']} componentes...');

        await componenteService.migrateComponentesForTurbina(widget.turbineId);

        debugPrint('✅ Instalação: Migração automática concluída!');
      }
    } catch (e) {
      debugPrint('❌ Erro na migração automática: $e');
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
  List<Map<String, dynamic>> get _phases {
    final phases = <Map<String, dynamic>>[
      {
        'id': 'reception',
        'tipoFase': TipoFase.recepcao,
        'icon': Icons.local_shipping,
        'nameKey': 'reception',
        'color': AppColors.primaryBlue,
      },
      {
        'id': 'preparation',
        'tipoFase': TipoFase.preparacao,
        'icon': Icons.assignment,
        'nameKey': 'preparation',
        'color': AppColors.primaryBlueMedium,
      },
      {
        'id': 'preAssembly',
        'tipoFase': TipoFase.preInstalacao,
        'icon': Icons.construction,
        'nameKey': 'pre_assembly',
        'color': AppColors.accentCyan,
      },
      {
        'id': 'assembly',
        'tipoFase': TipoFase.instalacao,
        'icon': Icons.build_circle,
        'nameKey': 'assembly',
        'color': AppColors.warningOrange,
      },
      {
        'id': 'logistics',
        'icon': Icons.construction,
        'nameKey': 'cranes',
        'color': AppColors.darkGray,
      },
      {
        'id': 'torqueTensioning',
        'tipoFase': TipoFase.torqueTensionamento,
        'icon': Icons.bolt,
        'nameKey': 'torqueTensioning',
        'color': AppColors.errorRed,
      },
      {
        'id': 'finalPhases',
        'icon': Icons.checklist_rtl,
        'nameKey': 'final_phases',
        'color': AppColors.successGreen,
      },
    ];

    if (_isMobile) {
      phases.insert(0, {
        'id': 'location',
        'icon': Icons.location_on,
        'nameKey': 'location',
        'color': AppColors.accentTeal,
      });
    }

    return phases;
  }

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

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final selectedPhase = ref.watch(selectedInstallationPhaseProvider);

    // Mostrar indicador se estiver migrando
    if (_isMigrating) {
      return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
          title: DashboardShortcutTitle(
            child: Text(widget.turbineName),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(t.translate('preparing_components')),
              const SizedBox(height: 8),
              Text(
                t.translate('migration_once_per_turbine'),
                style:
                    const TextStyle(fontSize: 12, color: AppColors.mediumGray),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: DashboardShortcutTitle(
          child: Text(widget.turbineName),
        ),
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
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MobileProjectsScreen(),
                      ),
                      (route) => false,
                    );
                  },
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
      floatingActionButton: selectedPhase == 'logistics'
          ? Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryBlue, AppColors.accentCyan],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
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
                  splashColor: Colors.white.withValues(alpha: 0.3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
            )
          : null,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🚪 DIALOG: CONFIRMAR LOGOUT
  // ══════════════════════════════════════════════════════════════════════════
  void _showLogoutDialog() async {
    final t = TranslationHelper.of(context);

    final confirmed = await showLiquidDialog<bool>(
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

        // Navegar para login correto por plataforma
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) =>
                  _isMobile ? const MobileApp() : const LoginScreen(),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.glassSurfaceDark
        : AppColors.primaryBlue.withValues(alpha: 0.1);
    final borderColor = isDark
        ? const Color(0xFF758392)
        : AppColors.primaryBlue.withValues(alpha: 0.3);
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t.translate('turbine_model')}: ${widget.turbineModel} | ${t.translate('sequence')}: ${widget.turbineSequence}',
                  style: TextStyle(fontSize: 14, color: secondaryText),
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
  Widget _buildPhasesBar(String? selectedPhase, TranslationHelper t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor =
        isDark ? AppColors.glassSurfaceDark : AppColors.glassSurfaceStrongLight;
    final borderColor = isDark ? const Color(0xFF6F7E8C) : AppColors.borderGray;

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: panelColor,
        border: Border(
          bottom: BorderSide(color: borderColor.withValues(alpha: 0.55)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = phase['color'] as Color;
    final borderColor = isDark ? const Color(0xFF758392) : AppColors.borderGray;
    final backgroundColor = isDark
        ? AppColors.glassSurfaceDark.withValues(alpha: isSelected ? 0.94 : 0.88)
        : (isSelected ? color : Colors.white);
    final iconColor = isDark ? color : (isSelected ? Colors.white : color);
    final textColor =
        isDark ? color : (isSelected ? Colors.white : AppColors.darkGray);

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
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? borderColor : color)
                        .withValues(alpha: isDark ? 0.18 : 0.3),
                    blurRadius: isDark ? 10 : 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(phase['icon'] as IconData, size: 28, color: iconColor),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                t.translate(phase['nameKey'] as String),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
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
  Widget _buildPhaseContent(String? selectedPhase, TranslationHelper t) {
    if (selectedPhase == null) {
      return _buildPhaseSelectionPlaceholder(t);
    }

    switch (selectedPhase) {
      case 'location':
        return ref.watch(turbinaByIdProvider(widget.turbineId)).when(
              data: (turbina) => TurbineLocationSheet(
                turbinaId: widget.turbineId,
                turbinaNome: widget.turbineName,
                initialLocation: turbina?.localizacao,
                embedded: true,
                onCancel: () {
                  ref
                      .read(selectedInstallationPhaseProvider.notifier)
                      .setPhase(null);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Text(t.translate('error')),
              ),
            );

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
        if (!_isOpeningTorqueScreen) {
          _isOpeningTorqueScreen = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            final currentPhase = ref.read(selectedInstallationPhaseProvider);
            if (currentPhase != 'torqueTensioning') {
              _isOpeningTorqueScreen = false;
              return;
            }

            _openTorqueTensioningScreen();
          });
        }
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
        return _buildFinalPhasesContent();
      default:
        return Center(child: Text(t.translate('unknown_phase')));
    }
  }

  Widget _buildPhaseSelectionPlaceholder(TranslationHelper t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              size: 48,
              color: AppColors.mediumGray.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 16),
            Text(
              t.translate('select_phase_to_open'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF758392) : AppColors.borderGray;
    final cardColor =
        isDark ? AppColors.glassSurfaceDark : Theme.of(context).cardTheme.color;

    return FutureBuilder<FaseComponente?>(
      future: _getFaseDoComponente(componentId, tipoFase),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: borderColor, width: 1),
            ),
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
          debugPrint('❌ Erro ao buscar fase: ${snapshot.error}');
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
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: borderColor, width: 1),
          ),
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
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
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
      debugPrint('❌ Erro ao buscar fase: $e');
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

      if (!mounted) return;
      fase = novaFase.copyWith(id: docRef.id);
    }

    final result = await showLiquidDialog<bool>(
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

  Widget _buildFinalPhasesContent() {
    return FinalPhasesCardsView(
      turbinaId: widget.turbineId,
      physics: const BouncingScrollPhysics(),
    );
  }

  Future<void> _openTorqueTensioningScreen() async {
    if (!_isOpeningTorqueScreen) {
      _isOpeningTorqueScreen = true;
    }

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
      debugPrint('❌ Erro ao abrir Torque: $e');
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
    } finally {
      _isOpeningTorqueScreen = false;
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
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
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
    showLiquidBottomSheet(
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
    final confirmed = await showLiquidDialog<bool>(
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
