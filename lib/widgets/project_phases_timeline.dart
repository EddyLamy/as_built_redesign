import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/project_phase.dart';
import '../../providers/app_providers.dart';
import '../../widgets/edit_phase_dialog.dart';

class ProjectPhasesTimeline extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectPhasesTimeline({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectPhasesTimeline> createState() =>
      _ProjectPhasesTimelineState();
}

class _ProjectPhasesTimelineState extends ConsumerState<ProjectPhasesTimeline> {
  static const Set<String> _hiddenPhaseKeys = {
    'phase_subcontractors',
    'phase_accessories_receipt',
    'phase_swg_receipt',
    'phase_mv_cables_receipt',
  };

  static const Set<String> _hiddenPhaseNames = {
    'Subcontratados',
    'Recepção Acessórios',
    'Recepção SWG',
    'Recepção Cabos MV',
    'Receção de Acessórios',
    'Receção de SWG',
    'Receção de Cabos MV',
  };

  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScrollChange);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScrollChange)
      ..dispose();
    super.dispose();
  }

  void _handleScrollChange() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final canScrollLeft = position.pixels > 4;
    final canScrollRight = position.pixels < position.maxScrollExtent - 4;

    if (canScrollLeft != _canScrollLeft || canScrollRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canScrollLeft;
        _canScrollRight = canScrollRight;
      });
    }
  }

  void _syncArrowState() {
    if (!_scrollController.hasClients) {
      if (_canScrollLeft || _canScrollRight) {
        setState(() {
          _canScrollLeft = false;
          _canScrollRight = false;
        });
      }
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _handleScrollChange();
    });
  }

  Future<void> _scrollTimeline(double direction) async {
    if (!_scrollController.hasClients) return;

    final target = (_scrollController.offset + (direction * 280)).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final phasesAsync = ref.watch(projectPhasesProvider(widget.projectId));

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
                final visiblePhases =
                    phases.where((phase) => !_isHiddenPhase(phase)).toList();

                if (visiblePhases.isEmpty) {
                  return Center(
                    child: Text(t.translate('no_phases_found')),
                  );
                }

                return _buildTimeline(context, t, visiblePhases, ref);
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

  bool _isHiddenPhase(ProjectPhase phase) {
    final nomeKey = phase.nomeKey?.trim();
    final nome = phase.nome.trim();
    return _hiddenPhaseKeys.contains(nomeKey) ||
        _hiddenPhaseNames.contains(nome);
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

    return LayoutBuilder(
      builder: (context, constraints) {
        const minItemWidth = 58.0;
        const maxItemWidth = 92.0;
        const timelineHeight = 138.0;
        const arrowZoneWidth = 44.0;

        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final fittedItemWidth =
            (availableWidth / phases.length).clamp(minItemWidth, maxItemWidth);
        final contentWidth = phases.length * fittedItemWidth;
        final needsScroll = contentWidth > availableWidth;

        _syncArrowState();

        return SizedBox(
          height: timelineHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: needsScroll ? arrowZoneWidth : 0,
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    physics: needsScroll
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      width: contentWidth,
                      child: CustomPaint(
                        painter: _TimelinePainter(
                          phases: phases,
                          minDate: minDateNonNull,
                          maxDate: maxDateNonNull,
                          itemWidth: fittedItemWidth,
                          context: context,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: phases.map((phase) {
                            return _buildPhaseMarker(
                              context,
                              t,
                              phase,
                              minDateNonNull,
                              maxDateNonNull,
                              fittedItemWidth,
                              ref,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (needsScroll && _canScrollLeft)
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildScrollArrow(
                    icon: Icons.chevron_left,
                    onTap: () => _scrollTimeline(-1),
                  ),
                ),
              if (needsScroll && _canScrollRight)
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildScrollArrow(
                    icon: Icons.chevron_right,
                    onTap: () => _scrollTimeline(1),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScrollArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.white.withValues(alpha: 0.88),
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: const Color(0xFF0F4C81).withValues(alpha: 0.18),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: AppColors.primaryBlue, size: 22),
          ),
        ),
      ),
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
        height: 138,
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
                    _abbreviatePhaseName(
                      phase.nomeKey != null
                          ? t.translate(phase.nomeKey!)
                          : t.translateValueOrKey('phase_${phase.nome}'),
                    ),
                    style: TextStyle(
                      fontSize: itemWidth < 64 ? 9 : 10,
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
    showLiquidDialog(
      context: context,
      builder: (context) => EditPhaseDialog(
        projectId: widget.projectId,
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
