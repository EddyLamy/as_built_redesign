import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/installation/checkpoint_geral.dart';
import '../../models/installation/tipo_fase.dart';
import '../../screens/installation/checkpoint_edit_dialog.dart';
import '../../services/installation/checkpoint_geral_service.dart';
import 'final_phase_visuals.dart';
import '../liquid_glass_overlays.dart';

class FinalPhasesCardsView extends StatelessWidget {
  const FinalPhasesCardsView({
    super.key,
    required this.turbinaId,
    this.padding = const EdgeInsets.all(16),
    this.shrinkWrap = false,
    this.physics,
  });

  final String turbinaId;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  static const List<TipoFase> _configs = [
    TipoFase.eletricos,
    TipoFase.mecanicosGerais,
    TipoFase.finish,
    TipoFase.inspecaoSupervisor,
    TipoFase.punchlist,
    TipoFase.inspecaoCliente,
    TipoFase.punchlistCliente,
  ];

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('checkpoints_gerais')
          .where('turbinaId', isEqualTo: turbinaId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t.translate('error_loading_data'),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final checkpointsByType = <TipoFase, CheckpointGeral>{};
        for (final doc in snapshot.data?.docs ?? const []) {
          final checkpoint = CheckpointGeral.fromFirestore(doc);
          checkpointsByType[checkpoint.tipo] = checkpoint;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 1700
                ? 7
                : width >= 1450
                    ? 6
                    : width >= 1180
                        ? 5
                        : width >= 920
                            ? 4
                            : width >= 700
                                ? 3
                                : width >= 480
                                    ? 2
                                    : 1;
            final childAspectRatio = crossAxisCount >= 5
                ? 0.92
                : crossAxisCount == 4
                    ? 0.98
                    : crossAxisCount == 3
                        ? 1.08
                        : crossAxisCount == 2
                            ? 1.2
                            : 2.0;

            return GridView.builder(
              padding: padding,
              shrinkWrap: shrinkWrap,
              physics: physics,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: _configs.length,
              itemBuilder: (context, index) {
                final tipo = _configs[index];
                final checkpoint =
                    checkpointsByType[tipo] ?? _buildDraftCheckpoint(tipo);

                return _FinalPhaseCard(
                  checkpoint: checkpoint,
                  title: t.translate(tipo.nameKey),
                  onTap: () => _openCheckpointDialog(context, checkpoint),
                );
              },
            );
          },
        );
      },
    );
  }

  CheckpointGeral _buildDraftCheckpoint(TipoFase tipo) {
    return CheckpointGeral(
      id: '',
      turbinaId: turbinaId,
      tipo: tipo,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _openCheckpointDialog(
    BuildContext context,
    CheckpointGeral checkpoint,
  ) async {
    try {
      var checkpointToEdit = checkpoint;

      if (checkpointToEdit.id.isEmpty) {
        final service = CheckpointGeralService();
        final checkpointId = await service.createCheckpoint(checkpointToEdit);
        checkpointToEdit = checkpointToEdit.copyWith(id: checkpointId);
      }

      if (!context.mounted) return;

      await showLiquidDialog<void>(
        context: context,
        builder: (context) => CheckpointEditDialog(
          checkpoint: checkpointToEdit,
          turbinaId: turbinaId,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(TranslationHelper.of(context).translate('error_saving')),
        ),
      );
    }
  }
}

class _FinalPhaseCard extends StatelessWidget {
  const _FinalPhaseCard({
    required this.checkpoint,
    required this.title,
    required this.onTap,
  });

  final CheckpointGeral checkpoint;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visuals = FinalPhaseVisuals.of(checkpoint.tipo);
    final progress = checkpoint.progresso;
    final progressColor = checkpoint.isNA
        ? AppColors.mediumGray
        : AppColors.getProgressColor(progress);
    final cardSurface = AppColors.adaptiveCardSurface(context);
    final outline = AppColors.adaptiveOutline(context);

    return Card(
      elevation: 6,
      shadowColor: AppColors.isDarkContext(context)
          ? Colors.black.withValues(alpha: 0.42)
          : const Color(0xFF0F4C81).withValues(alpha: 0.18),
      margin: EdgeInsets.zero,
      color: cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: outline, width: 1),
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: cardSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: visuals.accentColor.withValues(alpha: 0.85),
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: visuals.accentColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: visuals.accentColor.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Icon(
                    visuals.icon,
                    size: 22,
                    color: visuals.accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: visuals.accentColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${progress.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: progressColor,
                  ),
                ),
                if (checkpoint.isNA) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cardSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: outline.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Text(
                      'N/A',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.adaptiveSecondaryText(context),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
