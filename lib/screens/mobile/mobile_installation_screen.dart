import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/mobile/phase_selector.dart';
import '../../widgets/mobile/reception_form.dart';
import '../../widgets/mobile/preparation_form.dart';
import '../../widgets/mobile/pre_assembly_form.dart';
import '../../widgets/mobile/assembly_form.dart';
import '../../widgets/mobile/torque_form.dart';
import '../../widgets/mobile/final_phases_form.dart';

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
  int _currentPhaseIndex = 0;

  final List<Map<String, dynamic>> _phases = [
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
        title: Column(
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
            child: _buildPhaseForm(_phases[_currentPhaseIndex]['key']),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseForm(String phaseKey) {
    switch (phaseKey) {
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
        return const Center(
          child: Text('Fase não implementada'),
        );
    }
  }
}
