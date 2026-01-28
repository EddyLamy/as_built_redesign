import 'package:cloud_firestore/cloud_firestore.dart';

class Componente {
  final String id;
  final String turbinaId;
  final String projectId;
  final String nome;
  final String tipo;
  final String categoria;
  final int ordem;
  final double progresso;
  final String status;
  final bool aplicavel;
  final String? itemNumber;
  final String? serialNumber;
  final String? vui;
  final DateTime? deliveryDate;
  final DateTime? dataInicio;
  final DateTime? dataConclusao;
  final String? observacoes;
  final String? hardcodedId;
  final String? substituicaoRazao;
  final String? substituicaoObservacoes;
  final DateTime? substituicaoData;
  final String? substituicaoUsuario;
  final String? substituidoPor;
  final String? substituiuComponente;

  // ============================================================================
  // 🔔 NOTIFICATION SYSTEM - CAMPOS NOVOS
  // ============================================================================
  final DateTime createdAt; // Data de criação do componente
  final List<Map<String, dynamic>> substituicoes; // Histórico de substituições
  // ============================================================================

  Componente({
    required this.id,
    required this.turbinaId,
    required this.projectId,
    required this.nome,
    required this.tipo,
    required this.categoria,
    required this.ordem,
    this.progresso = 0.0,
    this.status = 'Pendente',
    this.aplicavel = true,
    this.itemNumber,
    this.serialNumber,
    this.vui,
    this.deliveryDate,
    this.dataInicio,
    this.dataConclusao,
    this.observacoes,
    this.hardcodedId,
    this.substituicaoRazao,
    this.substituicaoObservacoes,
    this.substituicaoData,
    this.substituicaoUsuario,
    this.substituidoPor,
    this.substituiuComponente,
    DateTime? createdAt, // ← Opcional para backwards compatibility
    this.substituicoes = const [],
  }) : createdAt =
            createdAt ?? DateTime.now(); // ← Default para componentes antigos

  Map<String, dynamic> toMap() {
    return {
      'turbinaId': turbinaId,
      'projectId': projectId,
      'nome': nome,
      'tipo': tipo,
      'categoria': categoria,
      'ordem': ordem,
      'progresso': progresso,
      'status': status,
      'aplicavel': aplicavel,
      'itemNumber': itemNumber,
      'serialNumber': serialNumber,
      'vui': vui,
      'deliveryDate':
          deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
      'dataInicio': dataInicio != null ? Timestamp.fromDate(dataInicio!) : null,
      'dataConclusao':
          dataConclusao != null ? Timestamp.fromDate(dataConclusao!) : null,
      'observacoes': observacoes,
      'hardcodedId': hardcodedId,
      'substituicaoRazao': substituicaoRazao,
      'substituicaoObservacoes': substituicaoObservacoes,
      'substituicaoData': substituicaoData != null
          ? Timestamp.fromDate(substituicaoData!)
          : null,
      'substituicaoUsuario': substituicaoUsuario,
      'substituidoPor': substituidoPor,
      'substituiuComponente': substituiuComponente,
      // 🔔 Novos campos
      'createdAt': Timestamp.fromDate(createdAt),
      'substituicoes': substituicoes,
    };
  }

  factory Componente.fromMap(String id, Map<String, dynamic> map) {
    return Componente(
      id: id,
      turbinaId: map['turbinaId'] ?? '',
      projectId: map['projectId'] ?? '',
      nome: map['nome'] ?? '',
      tipo: map['tipo'] ?? '',
      categoria: map['categoria'] ?? '',
      ordem: map['ordem'] ?? 0,
      progresso: (map['progresso'] ?? 0).toDouble(),
      status: map['status'] ?? 'Pendente',
      aplicavel: map['aplicavel'] ?? true,
      itemNumber: map['itemNumber'],
      serialNumber: map['serialNumber'],
      vui: map['vui'],
      deliveryDate: map['deliveryDate'] != null
          ? (map['deliveryDate'] as Timestamp).toDate()
          : null,
      dataInicio: map['dataInicio'] != null
          ? (map['dataInicio'] as Timestamp).toDate()
          : null,
      dataConclusao: map['dataConclusao'] != null
          ? (map['dataConclusao'] as Timestamp).toDate()
          : null,
      observacoes: map['observacoes'],
      hardcodedId: map['hardcodedId'],
      substituicaoRazao: map['substituicaoRazao'],
      substituicaoObservacoes: map['substituicaoObservacoes'],
      substituicaoData: map['substituicaoData'] != null
          ? (map['substituicaoData'] as Timestamp).toDate()
          : null,
      substituicaoUsuario: map['substituicaoUsuario'],
      substituidoPor: map['substituidoPor'],
      substituiuComponente: map['substituiuComponente'],
      // 🔔 Novos campos com fallback para componentes antigos
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // Default se não existir
      substituicoes: map['substituicoes'] != null
          ? List<Map<String, dynamic>>.from(map['substituicoes'])
          : [],
    );
  }

  // ============================================================================
  // 🔔 NOTIFICATION SYSTEM - MÉTODO NOVO
  // ============================================================================
  /// Criar Componente a partir de DocumentSnapshot do Firestore
  factory Componente.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Componente.fromMap(doc.id, data);
  }
  // ============================================================================

  Componente copyWith({
    String? id,
    String? turbinaId,
    String? projectId,
    String? nome,
    String? tipo,
    String? categoria,
    int? ordem,
    double? progresso,
    String? status,
    bool? aplicavel,
    String? itemNumber,
    String? serialNumber,
    String? vui,
    DateTime? deliveryDate,
    DateTime? dataInicio,
    DateTime? dataConclusao,
    String? observacoes,
    String? hardcodedId,
    String? substituicaoRazao,
    String? substituicaoObservacoes,
    DateTime? substituicaoData,
    String? substituicaoUsuario,
    String? substituidoPor,
    String? substituiuComponente,
    DateTime? createdAt,
    List<Map<String, dynamic>>? substituicoes,
  }) {
    return Componente(
      id: id ?? this.id,
      turbinaId: turbinaId ?? this.turbinaId,
      projectId: projectId ?? this.projectId,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      ordem: ordem ?? this.ordem,
      progresso: progresso ?? this.progresso,
      status: status ?? this.status,
      aplicavel: aplicavel ?? this.aplicavel,
      itemNumber: itemNumber ?? this.itemNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      vui: vui ?? this.vui,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      dataInicio: dataInicio ?? this.dataInicio,
      dataConclusao: dataConclusao ?? this.dataConclusao,
      observacoes: observacoes ?? this.observacoes,
      hardcodedId: hardcodedId ?? this.hardcodedId,
      substituicaoRazao: substituicaoRazao ?? this.substituicaoRazao,
      substituicaoObservacoes:
          substituicaoObservacoes ?? this.substituicaoObservacoes,
      substituicaoData: substituicaoData ?? this.substituicaoData,
      substituicaoUsuario: substituicaoUsuario ?? this.substituicaoUsuario,
      substituidoPor: substituidoPor ?? this.substituidoPor,
      substituiuComponente: substituiuComponente ?? this.substituiuComponente,
      createdAt: createdAt ?? this.createdAt,
      substituicoes: substituicoes ?? this.substituicoes,
    );
  }
}
