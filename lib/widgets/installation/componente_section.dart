import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    // Calcular progresso médio do componente
    final progressoMedio = widget.fases.isEmpty
        ? 0.0
        : widget.fases.map((f) => f.progresso).reduce((a, b) => a + b) /
            widget.fases.length;

    Color progressoColor = Colors.grey;
    if (progressoMedio > 0 && progressoMedio < 100) {
      progressoColor = Colors.orange;
    } else if (progressoMedio == 100) {
      progressoColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressoMedio / 100,
                            backgroundColor: Colors.grey[200],
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
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
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
