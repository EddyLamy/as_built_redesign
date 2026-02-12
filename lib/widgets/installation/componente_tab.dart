import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../i18n/installation_translations.dart';
import '../../models/installation/fase_componente.dart';
import 'componente_section.dart';
import 'trabalho_card.dart';
import 'checkpoint_card.dart';
import '../../providers/locale_provider.dart';

class ComponentesTab extends ConsumerWidget {
  final String turbinaId;

  const ComponentesTab({super.key, required this.turbinaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final t = InstallationTranslations.translations[locale]!;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('fases_componente')
          .where('turbinaId', isEqualTo: turbinaId)
          .orderBy('ordem')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${t['erro']}: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final fases = snapshot.data?.docs ?? [];

        // Agrupar fases por componente
        final Map<String, List<FaseComponente>> componentesMap = {};

        for (var doc in fases) {
          final fase = FaseComponente.fromFirestore(doc);

          // 🆕 Ignorar fase Torque & Tensioning no As-Built
          if (fase.componenteId == 'Torque & Tensioning') {
            continue;
          }

          if (!componentesMap.containsKey(fase.componenteId)) {
            componentesMap[fase.componenteId] = [];
          }
          componentesMap[fase.componenteId]!.add(fase);
        }

        // Ordenar componentes por ordem definida
        final componentesOrdenados =
            _ordenarComponentes(componentesMap.keys.toList());

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Componentes e suas fases
            ...componentesOrdenados.map((componenteId) {
              final fasesComponente = componentesMap[componenteId]!;
              fasesComponente
                  .sort((a, b) => a.tipo.index.compareTo(b.tipo.index));

              return ComponenteSection(
                nomeComponente: componenteId,
                fases: fasesComponente,
                turbinaId: turbinaId,
              );
            }),

            const SizedBox(height: 24),

            // Trabalhos Mecânicos
            _TrabalhosMecanicosSection(turbinaId: turbinaId),

            const SizedBox(height: 24),

            // Checkpoints Gerais
            _CheckpointsSection(turbinaId: turbinaId),
          ],
        );
      },
    );
  }

  List<String> _ordenarComponentes(List<String> componentes) {
    // Ordem preferencial
    const ordemPreferencial = [
      'Contentor',
      'Spareparts',
      'SWG',
      'Cable MV',
      'Hub',
      'Nacelle',
      'Cooler Top',
      'Drive Train',
      'Body Parts',
      'Elevador',
      // Secções
      'Bottom',
      'Top',
      // Blades
      'Blade 1',
      'Blade 2',
      'Blade 3',
    ];

    componentes.sort((a, b) {
      // Tratar Middle sections especialmente
      if (a.startsWith('Middle') && b.startsWith('Middle')) {
        return a.compareTo(b);
      }

      final indexA = ordemPreferencial.indexOf(a);
      final indexB = ordemPreferencial.indexOf(b);

      if (indexA != -1 && indexB != -1) {
        return indexA.compareTo(indexB);
      } else if (indexA != -1) {
        return -1;
      } else if (indexB != -1) {
        return 1;
      } else {
        // Middle sections vêm depois do Bottom
        if (a.startsWith('Middle')) return 0;
        if (b.startsWith('Middle')) return 0;
        return a.compareTo(b);
      }
    });

    return componentes;
  }
}

class _TrabalhosMecanicosSection extends ConsumerWidget {
  final String turbinaId;

  const _TrabalhosMecanicosSection({required this.turbinaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final t = InstallationTranslations.translations[locale]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.build, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                t['trabalhosMecanicos'] ?? 'Trabalhos Mecânicos',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Trabalhos de Ligação
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('trabalhos_ligacao')
              .where('turbinaId', isEqualTo: turbinaId)
              .orderBy('ordem')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final trabalhos = snapshot.data!.docs;

            return Column(
              children: trabalhos.map((doc) {
                return TrabalhoCard(
                  trabalhoDoc: doc,
                  turbinaId: turbinaId,
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 12),

        // Drive Train (especial)
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('trabalhos_drivetrain')
              .where('turbinaId', isEqualTo: turbinaId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();

            final trabalhos = snapshot.data!.docs;
            if (trabalhos.isEmpty) return const SizedBox.shrink();

            return Column(
              children: trabalhos.map((doc) {
                return TrabalhoCard(
                  trabalhoDoc: doc,
                  turbinaId: turbinaId,
                  isDriveTrain: true,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CheckpointsSection extends ConsumerWidget {
  final String turbinaId;

  const _CheckpointsSection({required this.turbinaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final t = InstallationTranslations.translations[locale]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                t['checkpointsGerais'] ?? 'Checkpoints Gerais',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('checkpoints_gerais')
              .where('turbinaId', isEqualTo: turbinaId)
              .orderBy('ordem')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final checkpoints = snapshot.data!.docs;

            return Column(
              children: checkpoints.map((doc) {
                return CheckpointCard(
                  checkpointDoc: doc,
                  turbinaId: turbinaId,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
