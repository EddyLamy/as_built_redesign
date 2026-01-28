import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../i18n/installation_translations.dart';
import '../../models/installation/checkpoint_geral.dart';
import '../../models/installation/tipo_fase.dart'; // ✅ ADICIONAR
import '../../screens/installation/checkpoint_edit_dialog.dart'; // ✅ CORRIGIR PATH
import '../../providers/locale_provider.dart';

class CheckpointCard extends ConsumerWidget {
  final DocumentSnapshot checkpointDoc;
  final String turbinaId;

  const CheckpointCard({
    super.key,
    required this.checkpointDoc,
    required this.turbinaId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final t = InstallationTranslations.translations[locale]!;
    final checkpoint = CheckpointGeral.fromFirestore(checkpointDoc);

    Color progressoColor = checkpoint.progresso == 100
        ? Colors.green
        : (checkpoint.progresso > 0 ? Colors.orange : Colors.grey);
    final nomeCheckpoint = _getNomeCheckpoint(checkpoint.tipo, t);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (context) => CheckpointEditDialog(
            checkpoint: checkpoint,
            turbinaId: turbinaId,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: progressoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCheckpointIcon(checkpoint.tipo),
                  color: progressoColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeCheckpoint,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: checkpoint.progresso / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressoColor),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${checkpoint.progresso.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (checkpoint.isNA) ...[
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

  // ✅ CORRIGIDO: TipoCheckpoint → TipoFase
  String _getNomeCheckpoint(TipoFase tipo, Map<String, String> t) {
    switch (tipo) {
      case TipoFase.eletricos:
        return t['checkpointEletricos'] ?? 'Checkpoint Elétricos';
      case TipoFase.mecanicosGerais:
        return t['checkpointMecanicos'] ?? 'Checkpoint Mecânicos';
      case TipoFase.finish:
        return 'Finish';
      case TipoFase.inspecaoSupervisor:
        return t['inspecaoSupervisor'] ?? 'Inspeção Supervisor';
      case TipoFase.punchlist:
        return 'Punch-List';
      case TipoFase.inspecaoCliente:
        return t['inspecaoCliente'] ?? 'Inspeção Cliente';
      case TipoFase.punchlistCliente:
        return 'Punch-List Cliente';
      default:
        return tipo.name;
    }
  }

  // ✅ CORRIGIDO: TipoCheckpoint → TipoFase
  IconData _getCheckpointIcon(TipoFase tipo) {
    switch (tipo) {
      case TipoFase.eletricos:
        return Icons.electrical_services;
      case TipoFase.mecanicosGerais:
        return Icons.build;
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
      default:
        return Icons.help_outline;
    }
  }
}
