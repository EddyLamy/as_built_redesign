import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/project_phase.dart';
import '../../providers/app_providers.dart';
import '../../widgets/edit_phase_dialog.dart';

class ProjectPhasesScreen extends ConsumerWidget {
  final String projectId;
  final String projectName;

  const ProjectPhasesScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);
    final phasesAsync = ref.watch(projectPhasesProvider(projectId));

    final progressAsync = ref.watch(projectPhasesProgressProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(projectName, style: const TextStyle(fontSize: 18)),
            Text(
              t.translate('project_phases'),
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: phasesAsync.when(
        data: (phases) {
          if (phases.isEmpty) {
            return Center(child: Text(t.translate('no_phases_found')));
          }

          return Column(
            children: [
              // Header com progresso geral
              _buildProgressHeader(context, phases, progressAsync),

              // Lista de fases
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: phases.length,
                  itemBuilder: (context, index) {
                    return _buildPhaseCard(context, ref, phases[index]);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('${t.translate('error')}: $error'),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(
    BuildContext context,
    List<ProjectPhase> phases,
    AsyncValue<double> progressAsync,
  ) {
    final t = TranslationHelper.of(context);
    final completas = phases.where((p) => p.isCompleta).length;
    final total = phases.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Progresso circular
          progressAsync.when(
            data: (progress) => SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 10,
                      backgroundColor: AppColors.borderGray,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primaryBlue),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      Text(
                        t.translate('complete'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Icon(Icons.error),
          ),
          const SizedBox(height: 16),
          Text(
            '$completas / $total ${t.translate('phases_completed')}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseCard(
    BuildContext context,
    WidgetRef ref,
    ProjectPhase phase,
  ) {
    final t = TranslationHelper.of(context);
    final color = _getPhaseColor(phase);
    final icon = _getPhaseIcon(phase);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEditPhaseDialog(context, ref, phase),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t.translate('phase_${phase.nome}'), // ✅ MUDANÇA AQUI
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!phase.obrigatorio)
                          Chip(
                            label: Text(
                              t.translate('optional'),
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor:
                                AppColors.mediumGray.withOpacity(0.2),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Status e datas
                    if (!phase.aplicavel)
                      Text(
                        t.translate('not_applicable'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGray,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else if (phase.dataInicio == null && phase.dataFim == null)
                      Text(
                        t.translate('not_started'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGray,
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (phase.dataInicio != null)
                            Text(
                              '${t.translate('start')}: ${_formatDate(phase.dataInicio!)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          if (phase.dataFim != null)
                            Text(
                              '${t.translate('end')}: ${_formatDate(phase.dataFim!)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                  ],
                ),
              ),

              // Progresso
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Text(
                      '${phase.progresso.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: phase.progresso / 100,
                      backgroundColor: AppColors.borderGray,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditPhaseDialog(
    BuildContext context,
    WidgetRef ref,
    ProjectPhase phase,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditPhaseDialog(
        projectId: projectId,
        phase: phase,
      ),
    );
  }

  Color _getPhaseColor(ProjectPhase phase) {
    if (!phase.aplicavel) return AppColors.mediumGray;
    if (phase.progresso >= 100) return AppColors.successGreen;
    if (phase.progresso > 0) return AppColors.warningOrange;
    return AppColors.mediumGray;
  }

  IconData _getPhaseIcon(ProjectPhase phase) {
    if (!phase.aplicavel) return Icons.block;
    if (phase.progresso >= 100) return Icons.check_circle;
    if (phase.progresso > 0) return Icons.pending;
    return Icons.radio_button_unchecked;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
