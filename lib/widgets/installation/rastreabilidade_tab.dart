import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../i18n/installation_translations.dart';
import '../../providers/locale_provider.dart';

class RastreabilidadeTab extends ConsumerWidget {
  final String turbinaId;

  const RastreabilidadeTab({super.key, required this.turbinaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeStringProvider);
    final t = locale == 'pt'
        ? InstallationTranslations.ptTranslations
        : InstallationTranslations.enTranslations;

    return Column(
      children: [
        // Header com botão de exportação
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t['rastreabilidade'] ?? 'Rastreabilidade',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Exportação disponível em breve')),
                  );
                },
                icon: const Icon(Icons.download),
                label: Text(t['exportar'] ?? 'Exportar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
        ),

        // Tabela
        Expanded(
          child: FutureBuilder<List<RastreabilidadeItem>>(
            future: _carregarDados(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('${t['erro']}: ${snapshot.error}'));
              }

              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.table_chart,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        t['nenhumDadoEncontrado'] ?? 'Nenhum dado encontrado',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(Colors.orange[100]),
                    columns: [
                      DataColumn(
                          label: Text(t['componente'] ?? 'Componente',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      const DataColumn(
                          label: Text('VUI',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(t['serial'] ?? 'Serial',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(t['item'] ?? 'Item',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(t['dataRececao'] ?? 'Data Receção',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(t['dataInstalacao'] ?? 'Data Instalação',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(t['posicao'] ?? 'Posição',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                    ],
                    rows: items.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item.componente)),
                        DataCell(Text(item.vui ?? '-')),
                        DataCell(Text(item.serial ?? '-')),
                        DataCell(Text(item.item ?? '-')),
                        DataCell(Text(item.dataRececao ?? '-')),
                        DataCell(Text(item.dataInstalacao ?? '-')),
                        DataCell(Text(item.posicao ?? '-')),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<RastreabilidadeItem>> _carregarDados() async {
    final items = <RastreabilidadeItem>[];

    // Agrupar fases por componente
    final fasesSnapshot = await FirebaseFirestore.instance
        .collection('fases_componente')
        .where('turbinaId', isEqualTo: turbinaId)
        .get();

    final Map<String, Map<String, dynamic>> componentes = {};

    for (var doc in fasesSnapshot.docs) {
      final nomeComponente = doc['nomeComponente'] as String;
      final tipo = doc['tipo'] as String;

      if (!componentes.containsKey(nomeComponente)) {
        componentes[nomeComponente] = {};
      }

      if (tipo == 'rececao') {
        componentes[nomeComponente]!['vui'] = doc['vui'];
        componentes[nomeComponente]!['serial'] = doc['serial'];
        componentes[nomeComponente]!['item'] = doc['item'];
        componentes[nomeComponente]!['dataRececao'] =
            _formatDate((doc['dataInicio'] as Timestamp).toDate());
      }

      if (tipo == 'instalacao') {
        componentes[nomeComponente]!['dataInstalacao'] =
            _formatDate((doc['dataInicio'] as Timestamp).toDate());
        componentes[nomeComponente]!['posicao'] = doc['posicaoBlade'];
      }
    }

    // Converter para lista
    componentes.forEach((nomeComponente, dados) {
      items.add(RastreabilidadeItem(
        componente: nomeComponente,
        vui: dados['vui'],
        serial: dados['serial'],
        item: dados['item'],
        dataRececao: dados['dataRececao'],
        dataInstalacao: dados['dataInstalacao'],
        posicao: dados['posicao'],
      ));
    });

    // Ordenar alfabeticamente
    items.sort((a, b) => a.componente.compareTo(b.componente));

    return items;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class RastreabilidadeItem {
  final String componente;
  final String? vui;
  final String? serial;
  final String? item;
  final String? dataRececao;
  final String? dataInstalacao;
  final String? posicao;

  RastreabilidadeItem({
    required this.componente,
    this.vui,
    this.serial,
    this.item,
    this.dataRececao,
    this.dataInstalacao,
    this.posicao,
  });
}
