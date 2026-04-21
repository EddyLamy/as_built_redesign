import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../i18n/installation_translations.dart';
import '../../models/installation/trabalho_ligacao.dart';
import '../../models/installation/trabalho_drivetrain.dart';
import '../../models/installation/tipo_fase.dart';
import '../../screens/installation/trabalho_edit_dialog.dart';
import '../../screens/installation/drivetrain_edit_dialog.dart';
import '../../providers/locale_provider.dart';

class TrabalhoCard extends ConsumerWidget {
  final DocumentSnapshot trabalhoDoc;
  final String turbinaId;
  final bool isDriveTrain;

  const TrabalhoCard({
    super.key,
    required this.trabalhoDoc,
    required this.turbinaId,
    this.isDriveTrain = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeStringProvider);
    final t = InstallationTranslations.translations[locale]!;

    if (isDriveTrain) {
      return _buildDriveTrainCard(context, t);
    } else {
      return _buildLigacaoCard(context, t);
    }
  }

  Widget _buildLigacaoCard(BuildContext context, Map<String, String> t) {
    final trabalho = TrabalhoLigacao.fromFirestore(trabalhoDoc);
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final cardSurface = AppColors.adaptiveCardSurface(context);
    final outline = AppColors.adaptiveOutline(context);
    final progressTrack = AppColors.adaptiveProgressTrack(context);

    Color progressoColor = AppColors.mediumGray;
    if (trabalho.progresso > 0 && trabalho.progresso < 100) {
      progressoColor = AppColors.warningOrange;
    } else if (trabalho.progresso == 100) {
      progressoColor = AppColors.successGreen;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 6,
      shadowColor: AppColors.isDarkContext(context)
          ? Colors.black.withValues(alpha: 0.42)
          : const Color(0xFF0F4C81).withValues(alpha: 0.18),
      color: cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outline, width: 1),
      ),
      child: InkWell(
        onTap: () {
          showLiquidDialog(
            context: context,
            builder: (context) => TrabalhoEditDialog(
              trabalho: trabalho,
              turbinaId: turbinaId,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: progressoColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.link,
                  color: progressoColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trabalho.componenteA} → ${trabalho.componenteB}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Tipo de trabalho
                    if (trabalho.tipo != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trabalho.tipo == TipoTrabalhoMecanico.torque
                              ? t['torque'] ?? 'Torque'
                              : t['tensionamento'] ?? 'Tensionamento',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    const SizedBox(height: 6),

                    // Barra de progresso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: trabalho.progresso / 100,
                        backgroundColor: progressTrack,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressoColor),
                        minHeight: 4,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Progresso e badges
                    Row(
                      children: [
                        Text(
                          '${trabalho.progresso.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (trabalho.isNA) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'N/A',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryText,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              Icon(Icons.edit, size: 18, color: secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriveTrainCard(BuildContext context, Map<String, String> t) {
    final trabalho = TrabalhoDriveTrain.fromFirestore(trabalhoDoc);
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final cardSurface = AppColors.adaptiveCardSurface(context);
    final outline = AppColors.adaptiveOutline(context);
    final progressTrack = AppColors.adaptiveProgressTrack(context);

    // Calcular progresso
    double progressoMedio = trabalho.progresso;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 7,
      shadowColor: AppColors.isDarkContext(context)
          ? Colors.black.withValues(alpha: 0.44)
          : const Color(0xFF0F4C81).withValues(alpha: 0.18),
      color: cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outline, width: 1),
      ),
      child: InkWell(
        onTap: () {
          showLiquidDialog(
            context: context,
            builder: (context) => DriveTrainEditDialog(
              trabalho: trabalho,
              turbinaId: turbinaId,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ícone especial para Drive Train
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueMedium.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings,
                  color: AppColors.primaryBlueMedium,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drive Train',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Duas sub-barras: Torque e Tensionamento
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['torque'] ?? 'Torque',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: trabalho.progresso / 100,
                                  backgroundColor: progressTrack,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    trabalho.progresso == 100
                                        ? AppColors.successGreen
                                        : AppColors.primaryBlue,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${trabalho.progresso.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['tensionamento'] ?? 'Tensionamento',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: trabalho.progresso / 100,
                                  backgroundColor: progressTrack,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    trabalho.progresso == 100
                                        ? AppColors.successGreen
                                        : AppColors.warningOrange,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${trabalho.progresso.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Progresso geral
                    Row(
                      children: [
                        Icon(Icons.analytics, size: 14, color: secondaryText),
                        const SizedBox(width: 4),
                        Text(
                          '${t['progressoGeral']}: ${progressoMedio.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Icon(Icons.edit, size: 18, color: secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}
