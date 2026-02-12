import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/project_phase.dart';
import '../../providers/app_providers.dart';
import '../../widgets/edit_phase_dialog.dart';

class ProjectPhasesTimeline extends ConsumerWidget {
  final String projectId;

  const ProjectPhasesTimeline({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);
    final phasesAsync = ref.watch(projectPhasesProvider(projectId));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.timeline, color: AppColors.primaryBlue, size: 24),
                const SizedBox(width: 12),
                Text(
                  t.translate('phases_timeline'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildLegend(t),
              ],
            ),
            const SizedBox(height: 24),

            // Timeline
            phasesAsync.when(
              data: (phases) {
                if (phases.isEmpty) {
                  return Center(
                    child: Text(t.translate('no_phases_found')),
                  );
                }

                return _buildTimeline(context, t, phases, ref);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Center(
                child: Text('${t.translate('error')}: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(TranslationHelper t) {
    return Wrap(
      spacing: 16,
      children: [
        _buildLegendItem(
          Icons.check_circle,
          t.translate('complete'),
          AppColors.successGreen,
        ),
        _buildLegendItem(
          Icons.pending,
          t.translate('in_progress'),
          AppColors.warningOrange,
        ),
        _buildLegendItem(
          Icons.radio_button_unchecked,
          t.translate('pending'),
          AppColors.mediumGray,
        ),
        _buildLegendItem(
          Icons.block,
          t.translate('not_applicable'),
          AppColors.mediumGray,
        ),
      ],
    );
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
        ),
      ],
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    TranslationHelper t,
    List<ProjectPhase> phases,
    WidgetRef ref,
  ) {
    // Filtrar fases com datas para calcular range
    final phasesComDatas = phases.where((p) {
      return p.aplicavel && (p.dataInicio != null || p.dataFim != null);
    }).toList();

    if (phasesComDatas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.timeline,
                size: 64,
                color: AppColors.mediumGray.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                t.translate('no_phases_with_dates'),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calcular data mínima e máxima
    DateTime? minDate;
    DateTime? maxDate;

    for (var phase in phasesComDatas) {
      if (phase.dataInicio != null) {
        if (minDate == null || phase.dataInicio!.isBefore(minDate)) {
          minDate = phase.dataInicio;
        }
      }
      if (phase.dataFim != null) {
        if (maxDate == null || phase.dataFim!.isAfter(maxDate)) {
          maxDate = phase.dataFim;
        }
      }
    }

    if (minDate == null || maxDate == null) {
      return Center(child: Text(t.translate('insufficient_date_data')));
    }

    // Força os tipos como não-null
    final minDateNonNull = minDate;
    final maxDateNonNull = maxDate;

    const itemWidth = 59.0; // Largura de cada fase

    return Column(
      children: [
        // Timeline horizontal com scroll
        SizedBox(
          height: 130, // ✅ AUMENTA para 180
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none, // ✅ Permite overflow
            child: SizedBox(
              width: phases.length * itemWidth,
              child: CustomPaint(
                painter: _TimelinePainter(
                  phases: phases,
                  minDate: minDateNonNull,
                  maxDate: maxDateNonNull,
                  itemWidth: itemWidth,
                  context: context,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // ✅ Centraliza
                  children: phases.map((phase) {
                    return _buildPhaseMarker(
                      context,
                      t,
                      phase,
                      minDateNonNull,
                      maxDateNonNull,
                      itemWidth,
                      ref,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseMarker(
    BuildContext context,
    TranslationHelper t,
    ProjectPhase phase,
    DateTime minDate,
    DateTime maxDate,
    double itemWidth,
    WidgetRef ref,
  ) {
    final color = _getPhaseColor(phase);
    final icon = _getPhaseIcon(phase);

    // ✅ Determinar offset vertical
    double verticalOffset;
    if (!phase.aplicavel || phase.progresso >= 100) {
      verticalOffset = 10; // ← ACIMA
    } else if (phase.progresso > 0 && phase.progresso < 100) {
      verticalOffset = 30; // ← MEIO
    } else {
      verticalOffset = 40; // ← ABAIXO
    }

    return InkWell(
      onTap: () => _showEditPhaseDialog(context, ref, phase),
      child: SizedBox(
        width: itemWidth,
        height: 130,
        child: Transform.translate(
          offset: Offset(0, verticalOffset),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 6),

                // Nome
                SizedBox(
                  width: itemWidth - 16,
                  child: Text(
                    _abbreviatePhaseName(t.translate('phase_${phase.nome}')),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),

                // Data
                if (phase.aplicavel && phase.dataInicio != null)
                  Text(
                    _formatDateShort(phase.dataInicio!),
                    style: TextStyle(fontSize: 8, color: AppColors.mediumGray),
                  ),

                // Progresso
                const SizedBox(height: 2),
                Text(
                  '${phase.progresso.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
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

  String _abbreviatePhaseName(String name) {
    // Abreviar nomes longos
    final words = name.split(' ');
    if (words.length <= 2) return name;

    // Pegar primeira palavra completa + iniciais
    return '${words[0]} ${words.sublist(1).map((w) => w[0]).join('')}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

// Custom Painter para desenhar a linha de conexão entre fases
class _TimelinePainter extends CustomPainter {
  final List<ProjectPhase> phases;
  final DateTime minDate;
  final DateTime maxDate;
  final double itemWidth;
  final BuildContext context;

  _TimelinePainter({
    required this.phases,
    required this.minDate,
    required this.maxDate,
    required this.itemWidth,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderGray
      ..strokeWidth = 2;

    // Linha horizontal no meio
    final middleY = size.height / 2;
    canvas.drawLine(
      Offset(0, middleY),
      Offset(size.width, middleY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
