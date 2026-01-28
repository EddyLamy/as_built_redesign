import 'package:cloud_firestore/cloud_firestore.dart';

class Turbina {
  final String id;
  final String projectId;
  final String nome; // WTG-01, PAD-15, etc (user-defined)
  final int sequenceNumber; // ordem de instalação
  final int numberOfMiddleSections; // 🆕 Número de secções Middle da torre
  final double progresso; // 0-100
  final String
      status; // 'Planejada', 'Em Instalação', 'Instalada', 'Comissionada'
  final DateTime? dataInicio;
  final DateTime? dataConclusao;
  final String? localizacao; // Lat/Long ou texto
  final DateTime createdAt;
  final String createdBy;

  Turbina({
    required this.id,
    required this.projectId,
    required this.nome,
    required this.sequenceNumber,
    this.numberOfMiddleSections = 3, // 🆕 Default: 3 middle sections
    this.progresso = 0.0,
    this.status = 'Planejada',
    this.dataInicio,
    this.dataConclusao,
    this.localizacao,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'nome': nome,
      'sequenceNumber': sequenceNumber,
      'numberOfMiddleSections': numberOfMiddleSections, // 🆕
      'progresso': progresso,
      'status': status,
      'dataInicio': dataInicio != null ? Timestamp.fromDate(dataInicio!) : null,
      'dataConclusao':
          dataConclusao != null ? Timestamp.fromDate(dataConclusao!) : null,
      'localizacao': localizacao,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory Turbina.fromMap(String id, Map<String, dynamic> map) {
    return Turbina(
      id: id,
      projectId: map['projectId'] ?? '',
      nome: map['nome'] ?? '',
      sequenceNumber: map['sequenceNumber'] ?? 0,
      numberOfMiddleSections:
          map['numberOfMiddleSections'] ?? 3, // 🆕 Default: 3
      progresso: (map['progresso'] ?? 0).toDouble(),
      status: map['status'] ?? 'Planejada',
      dataInicio: map['dataInicio'] != null
          ? (map['dataInicio'] as Timestamp).toDate()
          : null,
      dataConclusao: map['dataConclusao'] != null
          ? (map['dataConclusao'] as Timestamp).toDate()
          : null,
      localizacao: map['localizacao'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  // ============================================================================
  // 🔔 NOTIFICATION SYSTEM - MÉTODO NOVO
  // ============================================================================
  /// Criar Turbina a partir de DocumentSnapshot do Firestore
  factory Turbina.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Turbina.fromMap(doc.id, data);
  }
  // ============================================================================

  Turbina copyWith({
    String? id,
    String? projectId,
    String? nome,
    int? sequenceNumber,
    int? numberOfMiddleSections, // 🆕
    double? progresso,
    String? status,
    DateTime? dataInicio,
    DateTime? dataConclusao,
    String? localizacao,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Turbina(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      nome: nome ?? this.nome,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      numberOfMiddleSections:
          numberOfMiddleSections ?? this.numberOfMiddleSections, // 🆕
      progresso: progresso ?? this.progresso,
      status: status ?? this.status,
      dataInicio: dataInicio ?? this.dataInicio,
      dataConclusao: dataConclusao ?? this.dataConclusao,
      localizacao: localizacao ?? this.localizacao,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
