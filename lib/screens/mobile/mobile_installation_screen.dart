import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../providers/app_providers.dart';
import '../../widgets/mobile/phase_selector.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../widgets/mobile/reception_form.dart';
import '../../widgets/mobile/preparation_form.dart';
import '../../widgets/mobile/pre_assembly_form.dart';
import '../../widgets/mobile/assembly_form.dart';
import '../../widgets/mobile/torque_form.dart';
import '../../widgets/mobile/final_phases_form.dart';
import '../../widgets/mobile/turbine_location_sheet.dart';

/// Tela de instalação mobile com fases horizontais
class MobileInstallationScreen extends ConsumerStatefulWidget {
  final String turbinaId;
  final String turbinaNome;
  final String componentId;
  final String componentName;

  const MobileInstallationScreen({
    super.key,
    required this.turbinaId,
    required this.turbinaNome,
    required this.componentId,
    required this.componentName,
  });

  @override
  ConsumerState<MobileInstallationScreen> createState() =>
      _MobileInstallationScreenState();
}

class _MobileInstallationScreenState
    extends ConsumerState<MobileInstallationScreen> {
  int? _currentPhaseIndex;

  final List<Map<String, dynamic>> _phases = [
    {'key': 'location', 'label': 'Localização', 'icon': Icons.location_on},
    {'key': 'reception', 'label': 'Receção', 'icon': Icons.unarchive},
    {'key': 'preparation', 'label': 'Preparação', 'icon': Icons.checklist},
    {
      'key': 'preAssembly',
      'label': 'Pré-Assemblagem',
      'icon': Icons.construction
    },
    {'key': 'assembly', 'label': 'Assemblagem', 'icon': Icons.build},
    {'key': 'torqueTensioning', 'label': 'Torque', 'icon': Icons.bolt},
    {'key': 'finalPhases', 'label': 'Fases Finais', 'icon': Icons.check_circle},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: DashboardShortcutTitle(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.turbinaNome,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                widget.componentName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════════
          // PHASE SELECTOR (Horizontal Scroll)
          // ═══════════════════════════════════════════════════════════
          PhaseSelector(
            phases: _phases,
            currentIndex: _currentPhaseIndex,
            onPhaseChanged: (index) {
              setState(() {
                _currentPhaseIndex = index;
              });
            },
          ),

          const Divider(height: 1),

          // ═══════════════════════════════════════════════════════════
          // FORM POR FASE
          // ═══════════════════════════════════════════════════════════
          Expanded(
            child: _currentPhaseIndex == null
                ? _buildPhaseSelectionPlaceholder(context)
                : _buildPhaseForm(_phases[_currentPhaseIndex!]['key']),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseSelectionPlaceholder(BuildContext context) {
    final t = TranslationHelper.of(context);
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

  Widget _buildPhaseForm(String phaseKey) {
    final t = TranslationHelper.of(context);
    switch (phaseKey) {
      case 'location':
        return ref.watch(turbinaByIdProvider(widget.turbinaId)).when(
              data: (turbina) => TurbineLocationSheet(
                turbinaId: widget.turbinaId,
                turbinaNome: widget.turbinaNome,
                initialLocation: turbina?.localizacao,
                embedded: true,
                onCancel: () {
                  setState(() {
                    _currentPhaseIndex = null;
                  });
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Text(t.translate('error')),
              ),
            );

      case 'reception':
        return ReceptionForm(
          turbinaId: widget.turbinaId,
          componentId: widget.componentId,
        );

      case 'preparation':
        return PreparationForm(
          turbinaId: widget.turbinaId,
          componentId: widget.componentId,
        );

      case 'preAssembly':
        return PreAssemblyForm(
          turbinaId: widget.turbinaId,
          componentId: widget.componentId,
        );

      case 'assembly':
        return AssemblyForm(
          turbinaId: widget.turbinaId,
          componentId: widget.componentId,
        );

      case 'torqueTensioning':
        return TorqueForm(
          turbinaId: widget.turbinaId,
          componentId: widget.componentId,
        );

      case 'finalPhases':
        return FinalPhasesForm(
          turbinaId: widget.turbinaId,
          componentId: widget.componentId,
        );

      default:
        return Center(
          child: Text(t.translate('phase_not_implemented')),
        );
    }
  }
}
