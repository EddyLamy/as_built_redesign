// widgets/desktop/logistica_table_view.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/localization/translation_helper.dart';

class LogisticaTableView extends StatelessWidget {
  final String turbineId;
  const LogisticaTableView({super.key, required this.turbineId});

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('turbinas')
          .doc(turbineId)
          .collection('logistica_gruas')
          .orderBy('inicio', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        return Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text(t.translate('activity_type'))),
                DataColumn(label: Text(t.translate('start'))),
                DataColumn(label: Text(t.translate('end'))),
                DataColumn(label: Text(t.translate('reason'))),
                DataColumn(label: Text(t.translate('notes'))),
              ],
              rows: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(t.translate(data['tipo']))),
                  DataCell(Text((data['inicio'] as Timestamp)
                      .toDate()
                      .toString()
                      .substring(0, 16))),
                  DataCell(Text((data['fim'] as Timestamp)
                      .toDate()
                      .toString()
                      .substring(0, 16))),
                  DataCell(Text(data['motivo'] ??
                      (data['origem'] != null
                          ? "${data['origem']} -> ${data['destino']}"
                          : "-"))),
                  DataCell(Text(data['observacoes'] ?? "-")),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
