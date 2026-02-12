import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';

// ============================================================================
// 📋 TELA DE DETALHES DA FASE (Quando clica num card de turbina)
// ============================================================================

class PhaseDetailsScreen extends ConsumerStatefulWidget {
  final String turbineId;
  final String turbineName;
  final String phase;

  const PhaseDetailsScreen({
    super.key,
    required this.turbineId,
    required this.turbineName,
    required this.phase,
  });

  @override
  ConsumerState<PhaseDetailsScreen> createState() => _PhaseDetailsScreenState();
}

class _PhaseDetailsScreenState extends ConsumerState<PhaseDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.turbineName, style: const TextStyle(fontSize: 18)),
            Text(
              t.translate('phase_${widget.phase}'),
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: _buildPhaseContent(),
    );
  }

  Widget _buildPhaseContent() {
    // Conteúdo muda baseado na fase
    switch (widget.phase) {
      case 'reception':
        return _buildReceptionContent();
      case 'pre_installation':
        return _buildPreInstallationContent();
      case 'installation':
        return _buildInstallationContent();
      case 'electrical':
        return _buildElectricalContent();
      case 'commissioning':
        return _buildCommissioningContent();
      default:
        return const Center(child: Text('Fase desconhecida'));
    }
  }

  // ============================================================================
  // 📦 FASE: RECEÇÃO
  // ============================================================================
  Widget _buildReceptionContent() {
    final t = TranslationHelper.of(context);

    // TODO: Buscar dados reais do Firebase
    final receptionTasks = [
      {
        'id': 'foundation',
        'nameKey': 'component_foundation',
        'received': true,
        'dateReceived': '2026-01-10',
        'photos': 5,
        'notes': 'OK',
      },
      {
        'id': 'tower_sections',
        'nameKey': 'tower_sections',
        'received': true,
        'dateReceived': '2026-01-12',
        'photos': 8,
        'notes': 'Tudo conforme',
      },
      {
        'id': 'nacelle',
        'nameKey': 'component_nacelle',
        'received': false,
        'dateReceived': null,
        'photos': 0,
        'notes': null,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(t.translate('reception_checklist')),
        const SizedBox(height: 16),
        ...receptionTasks.map((task) => _buildReceptionCard(task)),
      ],
    );
  }

  Widget _buildReceptionCard(Map<String, dynamic> task) {
    final t = TranslationHelper.of(context);
    final received = task['received'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (received ? AppColors.successGreen : AppColors.mediumGray)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            received ? Icons.check_circle : Icons.pending,
            color: received ? AppColors.successGreen : AppColors.mediumGray,
          ),
        ),
        title: Text(t.translate(task['nameKey'])),
        subtitle: received
            ? Text('${t.translate('received')}: ${task['dateReceived']}')
            : Text(t.translate('pending_reception')),
        trailing: received
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_camera, size: 16),
                  const SizedBox(width: 4),
                  Text('${task['photos']}'),
                ],
              )
            : null,
        onTap: () => _openReceptionDetails(task),
      ),
    );
  }

  // ============================================================================
  // 🔧 FASE: PRÉ-INSTALAÇÃO
  // ============================================================================
  Widget _buildPreInstallationContent() {
    final t = TranslationHelper.of(context);

    final preInstallTasks = [
      {
        'id': 'site_preparation',
        'nameKey': 'site_preparation',
        'status': 'completed',
        'progress': 1.0,
      },
      {
        'id': 'foundation_check',
        'nameKey': 'foundation_check',
        'status': 'in_progress',
        'progress': 0.6,
      },
      {
        'id': 'crane_setup',
        'nameKey': 'crane_setup',
        'status': 'pending',
        'progress': 0.0,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(t.translate('pre_installation_tasks')),
        const SizedBox(height: 16),
        ...preInstallTasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  // ============================================================================
  // 🏗️ FASE: INSTALAÇÃO
  // ============================================================================
  Widget _buildInstallationContent() {
    final t = TranslationHelper.of(context);

    final installTasks = [
      {
        'id': 'tower_installation',
        'nameKey': 'tower_installation',
        'status': 'pending',
        'progress': 0.0,
      },
      {
        'id': 'nacelle_installation',
        'nameKey': 'nacelle_installation',
        'status': 'pending',
        'progress': 0.0,
      },
      {
        'id': 'rotor_installation',
        'nameKey': 'rotor_installation',
        'status': 'pending',
        'progress': 0.0,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(t.translate('installation_tasks')),
        const SizedBox(height: 16),
        ...installTasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  // ============================================================================
  // ⚡ FASE: ELÉTRICO
  // ============================================================================
  Widget _buildElectricalContent() {
    final t = TranslationHelper.of(context);

    final electricalTasks = [
      {
        'id': 'cable_installation',
        'nameKey': 'cable_installation',
        'status': 'pending',
        'progress': 0.0,
      },
      {
        'id': 'transformer_connection',
        'nameKey': 'transformer_connection',
        'status': 'pending',
        'progress': 0.0,
      },
      {
        'id': 'electrical_tests',
        'nameKey': 'electrical_tests',
        'status': 'pending',
        'progress': 0.0,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(t.translate('electrical_tasks')),
        const SizedBox(height: 16),
        ...electricalTasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  // ============================================================================
  // ✅ FASE: COMISSIONAMENTO
  // ============================================================================
  Widget _buildCommissioningContent() {
    final t = TranslationHelper.of(context);

    final commissioningTasks = [
      {
        'id': 'functional_tests',
        'nameKey': 'functional_tests',
        'status': 'pending',
        'progress': 0.0,
      },
      {
        'id': 'safety_checks',
        'nameKey': 'safety_checks',
        'status': 'pending',
        'progress': 0.0,
      },
      {
        'id': 'final_inspection',
        'nameKey': 'final_inspection',
        'status': 'pending',
        'progress': 0.0,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(t.translate('commissioning_tasks')),
        const SizedBox(height: 16),
        ...commissioningTasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  // ============================================================================
  // 🎨 WIDGETS AUXILIARES
  // ============================================================================
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final t = TranslationHelper.of(context);
    final status = task['status'] as String;
    final progress = task['progress'] as double;
    final color = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.translate(task['nameKey']),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    t.translate('status_$status'),
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderGray,
              valueColor: AlwaysStoppedAnimation(color),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% ${t.translate('complete')}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.successGreen;
      case 'in_progress':
        return AppColors.warningOrange;
      case 'pending':
        return AppColors.mediumGray;
      default:
        return AppColors.mediumGray;
    }
  }

  void _openReceptionDetails(Map<String, dynamic> task) {
    // TODO: Abrir dialog ou tela com formulário de receção
    final t = TranslationHelper.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate(task['nameKey'])),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Formulário de receção completo'),
            SizedBox(height: 8),
            Text('- Data de receção'),
            Text('- Fotos'),
            Text('- Observações'),
            Text('- Estado do componente'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('close')),
          ),
        ],
      ),
    );
  }
}
