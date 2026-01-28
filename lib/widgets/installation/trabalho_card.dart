import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    final locale = ref.watch(localeProvider);
    final t = InstallationTranslations.translations[locale]!;

    if (isDriveTrain) {
      return _buildDriveTrainCard(context, t);
    } else {
      return _buildLigacaoCard(context, t);
    }
  }

  Widget _buildLigacaoCard(BuildContext context, Map<String, String> t) {
    final trabalho = TrabalhoLigacao.fromFirestore(trabalhoDoc);

    Color progressoColor = Colors.grey;
    if (trabalho.progresso > 0 && trabalho.progresso < 100) {
      progressoColor = Colors.orange;
    } else if (trabalho.progresso == 100) {
      progressoColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: InkWell(
        onTap: () {
          showDialog(
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
                  color: progressoColor.withOpacity(0.2),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Tipo de trabalho
                    if (trabalho.tipo != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trabalho.tipo == TipoTrabalhoMecanico.torque
                              ? t['torque'] ?? 'Torque'
                              : t['tensionamento'] ?? 'Tensionamento',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue[800],
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
                        backgroundColor: Colors.grey[200],
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
                            color: Colors.grey[600],
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

  Widget _buildDriveTrainCard(BuildContext context, Map<String, String> t) {
    final trabalho = TrabalhoDriveTrain.fromFirestore(trabalhoDoc);

    // Calcular progresso
    double progressoMedio = trabalho.progresso;

    Color progressoColor = Colors.grey;
    if (progressoMedio > 0 && progressoMedio < 100) {
      progressoColor = Colors.orange;
    } else if (progressoMedio == 100) {
      progressoColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          showDialog(
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
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.settings,
                  color: Colors.purple,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: trabalho.progresso / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    trabalho.progresso == 100
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${trabalho.progresso.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
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
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: trabalho.progresso / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    trabalho.progresso == 100
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${trabalho.progresso.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
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
                        Icon(Icons.analytics,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${t['progressoGeral']}: ${progressoMedio.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
}
