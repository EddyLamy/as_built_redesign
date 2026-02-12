// screens/desktop/logistica_dashboard_pane.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogisticaDashboard extends StatelessWidget {
  final String turbineId;
  const LogisticaDashboard({super.key, required this.turbineId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('turbinas')
          .doc(turbineId)
          .collection('logistica')
          .orderBy('inicio', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final docs = snapshot.data!.docs;

        return Card(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Tipo')),
              DataColumn(label: Text('Início')),
              DataColumn(label: Text('Fim')),
              DataColumn(label: Text('Motivo/Origem-Destino')),
            ],
            rows: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return DataRow(cells: [
                DataCell(Text(data['tipo'])),
                DataCell(
                    Text((data['inicio'] as Timestamp).toDate().toString())),
                DataCell(Text((data['fim'] as Timestamp).toDate().toString())),
                DataCell(Text(data['motivo'] ??
                    '${data['origem']} -> ${data['destino']}')),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}
