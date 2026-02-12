import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../i18n/installation_translations.dart';
import '../../providers/locale_provider.dart';

class TimelineTab extends ConsumerWidget {
  final String turbinaId;

  const TimelineTab({super.key, required this.turbinaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final t = locale == 'pt'
        ? InstallationTranslations.ptTranslations
        : InstallationTranslations.enTranslations;

    return FutureBuilder<List<TimelineEvent>>(
      future: _carregarEventos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('${t['erro']}: ${snapshot.error}'));
        }

        final eventos = snapshot.data ?? [];

        if (eventos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timeline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(t['nenhumEventoEncontrado'] ?? 'Nenhum evento encontrado',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: eventos.length,
          itemBuilder: (context, index) {
            final evento = eventos[index];
            final isFirst = index == 0;
            final isLast = index == eventos.length - 1;

            return _TimelineItem(
              evento: evento,
              isFirst: isFirst,
              isLast: isLast,
            );
          },
        );
      },
    );
  }

  Future<List<TimelineEvent>> _carregarEventos() async {
    final eventos = <TimelineEvent>[];

    // Carregar fases
    final fasesSnapshot = await FirebaseFirestore.instance
        .collection('fases_componente')
        .where('turbinaId', isEqualTo: turbinaId)
        .get();

    for (var doc in fasesSnapshot.docs) {
      eventos.add(TimelineEvent(
        data: (doc['dataInicio'] as Timestamp).toDate(),
        titulo: '${doc['nomeComponente']} - ${doc['tipo']}',
        subtitulo: 'Início',
        tipo: 'fase',
        icon: Icons.play_arrow,
        color: Colors.green,
      ));

      eventos.add(TimelineEvent(
        data: (doc['dataFim'] as Timestamp).toDate(),
        titulo: '${doc['nomeComponente']} - ${doc['tipo']}',
        subtitulo: 'Fim',
        tipo: 'fase',
        icon: Icons.stop,
        color: Colors.red,
      ));
    }

    // Carregar trabalhos
    final trabalhosSnapshot = await FirebaseFirestore.instance
        .collection('trabalhos_ligacao')
        .where('turbinaId', isEqualTo: turbinaId)
        .get();

    for (var doc in trabalhosSnapshot.docs) {
      eventos.add(TimelineEvent(
        data: (doc['dataInicio'] as Timestamp).toDate(),
        titulo: '${doc['componenteOrigem']} → ${doc['componenteDestino']}',
        subtitulo: 'Trabalho Mecânico',
        tipo: 'trabalho',
        icon: Icons.build,
        color: Colors.orange,
      ));
    }

    // Ordenar por data
    eventos.sort((a, b) => a.data.compareTo(b.data));

    return eventos;
  }
}

class TimelineEvent {
  final DateTime data;
  final String titulo;
  final String subtitulo;
  final String tipo;
  final IconData icon;
  final Color color;

  TimelineEvent({
    required this.data,
    required this.titulo,
    required this.subtitulo,
    required this.tipo,
    required this.icon,
    required this.color,
  });
}

class _TimelineItem extends StatelessWidget {
  final TimelineEvent evento;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.evento,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline vertical
          SizedBox(
            width: 60,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[300],
                    ),
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: evento.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(evento.icon, color: Colors.white, size: 16),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),

          // Conteúdo
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(left: 8, bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(evento.data),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      evento.titulo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      evento.subtitulo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
