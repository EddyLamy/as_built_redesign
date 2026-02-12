import 'package:cloud_firestore/cloud_firestore.dart';

class LogisticaEvento {
  final String? id;
  final String
      tipo; // 'mobilizacao', 'paragem', 'trabalho', 'transferencia', 'desmobilizacao'
  final DateTime dataInicio;
  final DateTime dataFim;
  final String? motivo; // Usado em paragens
  final String? padOrigem; // Usado em transferências
  final String? padDestino;
  final String observacoes;

  LogisticaEvento({
    this.id,
    required this.tipo,
    required this.dataInicio,
    required this.dataFim,
    this.motivo,
    this.padOrigem,
    this.padDestino,
    this.observacoes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': Timestamp.fromDate(dataFim),
      'motivo': motivo,
      'padOrigem': padOrigem,
      'padDestino': padDestino,
      'observacoes': observacoes,
      'criadoEm': FieldValue.serverTimestamp(),
    };
  }
}
