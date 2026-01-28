import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectPhase {
  final String id;
  final String projectId;
  final String nome;
  final String? nomeKey;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final bool aplicavel; // false = N/A
  final bool obrigatorio; // true = obrigatório para fechar projeto
  final int ordem; // Ordem de apresentação (1-20)
  final String? observacoes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectPhase({
    required this.id,
    required this.projectId,
    required this.nome,
    this.nomeKey,
    this.dataInicio,
    this.dataFim,
    this.aplicavel = true,
    this.obrigatorio = true,
    required this.ordem,
    this.observacoes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Converter do Firestore
  factory ProjectPhase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectPhase(
      id: doc.id,
      projectId: data['projectId'] ?? '',
      nome: data['nome'] ?? '',
      nomeKey: data['nomeKey'], // ✅ Lê do Firestore
      dataInicio: data['dataInicio'] != null
          ? (data['dataInicio'] as Timestamp).toDate()
          : null,
      dataFim: data['dataFim'] != null
          ? (data['dataFim'] as Timestamp).toDate()
          : null,
      aplicavel: data['aplicavel'] ?? true,
      obrigatorio: data['obrigatorio'] ?? true,
      ordem: data['ordem'] ?? 0,
      observacoes: data['observacoes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Converter para Map (salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'nome': nome,
      'nomeKey': nomeKey, // ✅ ADICIONA ISTO - guarda a key de tradução
      'dataInicio': dataInicio != null ? Timestamp.fromDate(dataInicio!) : null,
      'dataFim': dataFim != null ? Timestamp.fromDate(dataFim!) : null,
      'aplicavel': aplicavel,
      'obrigatorio': obrigatorio,
      'ordem': ordem,
      'observacoes': observacoes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Verificar se fase está completa
  bool get isCompleta {
    if (!aplicavel) return true; // N/A conta como completa
    return dataInicio != null && dataFim != null;
  }

  // Calcular progresso (0-100%)
  double get progresso {
    if (!aplicavel) return 100;
    if (dataInicio == null && dataFim == null) return 0;
    if (dataInicio != null && dataFim == null) return 50;
    if (dataInicio != null && dataFim != null) return 100;
    return 0;
  }

  // CopyWith para atualizações
  ProjectPhase copyWith({
    String? id,
    String? projectId,
    String? nome,
    String? nomeKey,
    DateTime? dataInicio,
    DateTime? dataFim,
    bool? aplicavel,
    bool? obrigatorio,
    int? ordem,
    String? observacoes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectPhase(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      nome: nome ?? this.nome,
      nomeKey: nomeKey ?? this.nomeKey,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      aplicavel: aplicavel ?? this.aplicavel,
      obrigatorio: obrigatorio ?? this.obrigatorio,
      ordem: ordem ?? this.ordem,
      observacoes: observacoes ?? this.observacoes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
