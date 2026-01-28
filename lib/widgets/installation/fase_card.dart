import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/installation/fase_componente.dart';
import '../../models/installation/tipo_fase.dart';
import '../../providers/locale_provider.dart';
import '../../screens/installation/fase_edit_dialog.dart';

class FaseCard extends ConsumerWidget {
  final FaseComponente fase;
  final String turbinaId;

  const FaseCard({
    super.key,
    required this.fase,
    required this.turbinaId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    Color progressoColor = Colors.grey;
    if (fase.progresso > 0 && fase.progresso < 100) {
      progressoColor = Colors.orange;
    } else if (fase.progresso == 100) {
      progressoColor = Colors.green;
    }

    final tipoNome = fase.tipo.getName(locale);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => FaseEditDialog(
              fase: fase,
              turbinaId: turbinaId,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ícone da fase
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: progressoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFaseIcon(fase.tipo),
                  color: progressoColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Info da fase
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipoNome,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Barra de progresso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: fase.progresso / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressoColor),
                        minHeight: 4,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Info adicional
                    Row(
                      children: [
                        Text(
                          '${fase.progresso.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (fase.isFaseNA) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'N/A',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                        if (_hasData(fase)) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle,
                              size: 14, color: Colors.green),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              Icon(Icons.edit, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFaseIcon(TipoFase tipo) {
    switch (tipo) {
      case TipoFase.recepcao:
        return Icons.local_shipping;
      case TipoFase.preparacao:
        return Icons.build;
      case TipoFase.preInstalacao:
        return Icons.handyman;
      case TipoFase.instalacao:
        return Icons.construction;
      case TipoFase.torqueTensionamento: // 🆕 Adicionado para evitar erro
        return Icons.bolt;
      case TipoFase.eletricos:
        return Icons.electrical_services;
      case TipoFase.mecanicosGerais:
        return Icons.construction;
      case TipoFase.finish:
        return Icons.check_circle;
      case TipoFase.inspecaoSupervisor:
        return Icons.visibility;
      case TipoFase.punchlist:
        return Icons.checklist;
      case TipoFase.inspecaoCliente:
        return Icons.assessment;
      case TipoFase.punchlistCliente:
        return Icons.assignment_turned_in;
    }
  }

  bool _hasData(FaseComponente fase) {
    // Verificar se tem dados preenchidos além das datas obrigatórias
    if (fase.tipo == TipoFase.recepcao) {
      return fase.vui != null ||
          fase.serialNumber != null ||
          fase.itemNumber != null;
    }
    return false;
  }
}
