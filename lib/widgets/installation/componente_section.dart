import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../i18n/installation_translations.dart';
import '../../models/installation/fase_componente.dart';
import 'fase_card.dart';
import '../../providers/locale_provider.dart';

class ComponenteSection extends ConsumerStatefulWidget {
  final String nomeComponente;
  final List<FaseComponente> fases;
  final String turbinaId;

  const ComponenteSection({
    super.key,
    required this.nomeComponente,
    required this.fases,
    required this.turbinaId,
  });

  @override
  ConsumerState<ComponenteSection> createState() => _ComponenteSectionState();
}

class _ComponenteSectionState extends ConsumerState<ComponenteSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeStringProvider);
    final t = InstallationTranslations.translations[locale]!;
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final cardSurface = AppColors.adaptiveCardSurface(context);
    final outline = AppColors.adaptiveOutline(context);
    final progressTrack = AppColors.adaptiveProgressTrack(context);

    // Calcular progresso médio do componente
    final progressoMedio = widget.fases.isEmpty
        ? 0.0
        : widget.fases.map((f) => f.progresso).reduce((a, b) => a + b) /
            widget.fases.length;

    Color progressoColor = AppColors.mediumGray;
    if (progressoMedio > 0 && progressoMedio < 100) {
      progressoColor = AppColors.warningOrange;
    } else if (progressoMedio == 100) {
      progressoColor = AppColors.successGreen;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 7,
      shadowColor: AppColors.isDarkContext(context)
          ? Colors.black.withValues(alpha: 0.44)
          : const Color(0xFF0F4C81).withValues(alpha: 0.18),
      color: cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outline, width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _getComponentIcon(widget.nomeComponente),
                    color: progressoColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nomeComponente,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressoMedio / 100,
                            backgroundColor: progressTrack,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(progressoColor),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${progressoMedio.toStringAsFixed(0)}% - ${widget.fases.length} ${t['fases']?.toLowerCase() ?? 'fases'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: secondaryText,
                  ),
                ],
              ),
            ),
          ),

          // Fases expansíveis
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: widget.fases.map((fase) {
                  return FaseCard(
                    fase: fase,
                    turbinaId: widget.turbinaId,
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getComponentIcon(String nomeComponente) {
    if (nomeComponente.contains('Blade')) return Icons.flutter_dash;
    if (nomeComponente.contains('Hub')) return Icons.circle_outlined;
    if (nomeComponente.contains('Nacelle')) return Icons.home_work;
    if (nomeComponente.contains('Bottom') ||
        nomeComponente.contains('Middle') ||
        nomeComponente.contains('Top')) {
      return Icons.view_column;
    }
    if (nomeComponente == 'Drive Train') return Icons.settings;
    if (nomeComponente == 'Elevador') return Icons.elevator;
    if (nomeComponente == 'Contentor') return Icons.inventory_2;
    if (nomeComponente == 'Cable MV') return Icons.cable;
    if (nomeComponente == 'SWG') return Icons.electrical_services;
    if (nomeComponente == 'Cooler Top') return Icons.ac_unit;
    if (nomeComponente == 'Body Parts') return Icons.construction;
    if (nomeComponente == 'Spareparts') return Icons.build_circle;

    return Icons.widgets;
  }
}
