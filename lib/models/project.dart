import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String userId;
  final String nome;
  final String projectId; // SP-40195
  final String projectManager;
  final String siteManager;
  final int totalTurbinas;
  final String turbineType;
  final String foundationType;
  // ❌ REMOVIDO: final int towerSections; (vai para cada turbina)
  final DateTime? siteOpeningDate;
  final DateTime? estimatedGridAvailability;
  final DateTime? estimatedHandover;
  final String? localizacao;
  final String? morada; // 🆕 NOVO CAMPO (opcional)
  final String? coordenadasGPS; // 🆕 NOVO CAMPO (opcional)
  final String status; // 'Planejado', 'Em Progresso', 'Concluído'
  final DateTime createdAt;
  final String createdBy;

  Project({
    required this.id,
    required this.userId,
    required this.nome,
    required this.projectId,
    required this.projectManager,
    required this.siteManager,
    this.totalTurbinas = 0,
    required this.turbineType,
    required this.foundationType,
    // ❌ REMOVIDO: this.towerSections = 4,
    this.siteOpeningDate,
    this.estimatedGridAvailability,
    this.estimatedHandover,
    this.localizacao,
    this.morada, // 🆕 NOVO
    this.coordenadasGPS, // 🆕 NOVO
    this.status = 'Planejado',
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nome': nome,
      'projectId': projectId,
      'projectManager': projectManager,
      'siteManager': siteManager,
      'totalTurbinas': totalTurbinas,
      'turbineType': turbineType,
      'foundationType': foundationType,
      // ❌ REMOVIDO: 'towerSections': towerSections,
      'siteOpeningDate':
          siteOpeningDate != null ? Timestamp.fromDate(siteOpeningDate!) : null,
      'estimatedGridAvailability': estimatedGridAvailability != null
          ? Timestamp.fromDate(estimatedGridAvailability!)
          : null,
      'estimatedHandover': estimatedHandover != null
          ? Timestamp.fromDate(estimatedHandover!)
          : null,
      'localizacao': localizacao,
      'morada': morada, // 🆕 NOVO
      'coordenadasGPS': coordenadasGPS, // 🆕 NOVO
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory Project.fromMap(String id, Map<String, dynamic> map) {
    return Project(
      id: id,
      userId: map['userId'] ?? '',
      nome: map['nome'] ?? '',
      projectId: map['projectId'] ?? '',
      projectManager: map['projectManager'] ?? '',
      siteManager: map['siteManager'] ?? '',
      totalTurbinas: map['totalTurbinas'] ?? 0,
      turbineType: map['turbineType'] ?? '',
      foundationType: map['foundationType'] ?? '',
      // ❌ REMOVIDO: towerSections: map['towerSections'] ?? 4,
      siteOpeningDate: map['siteOpeningDate'] != null
          ? (map['siteOpeningDate'] as Timestamp).toDate()
          : null,
      estimatedGridAvailability: map['estimatedGridAvailability'] != null
          ? (map['estimatedGridAvailability'] as Timestamp).toDate()
          : null,
      estimatedHandover: map['estimatedHandover'] != null
          ? (map['estimatedHandover'] as Timestamp).toDate()
          : null,
      localizacao: map['localizacao'],
      morada: map['morada'], // 🆕 NOVO
      coordenadasGPS: map['coordenadasGPS'], // 🆕 NOVO
      status: map['status'] ?? 'Planejado',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  // ============================================================================
  // 🔔 NOTIFICATION SYSTEM - MÉTODO NOVO
  // ============================================================================
  /// Criar Project a partir de DocumentSnapshot do Firestore
  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project.fromMap(doc.id, data);
  }
  // ============================================================================

  Project copyWith({
    String? id,
    String? userId,
    String? nome,
    String? projectId,
    String? projectManager,
    String? siteManager,
    int? totalTurbinas,
    String? turbineType,
    String? foundationType,
    // ❌ REMOVIDO: int? towerSections,
    DateTime? siteOpeningDate,
    DateTime? estimatedGridAvailability,
    DateTime? estimatedHandover,
    String? localizacao,
    String? morada, // 🆕 NOVO
    String? coordenadasGPS, // 🆕 NOVO
    String? status,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nome: nome ?? this.nome,
      projectId: projectId ?? this.projectId,
      projectManager: projectManager ?? this.projectManager,
      siteManager: siteManager ?? this.siteManager,
      totalTurbinas: totalTurbinas ?? this.totalTurbinas,
      turbineType: turbineType ?? this.turbineType,
      foundationType: foundationType ?? this.foundationType,
      // ❌ REMOVIDO: towerSections: towerSections ?? this.towerSections,
      siteOpeningDate: siteOpeningDate ?? this.siteOpeningDate,
      estimatedGridAvailability:
          estimatedGridAvailability ?? this.estimatedGridAvailability,
      estimatedHandover: estimatedHandover ?? this.estimatedHandover,
      localizacao: localizacao ?? this.localizacao,
      morada: morada ?? this.morada, // 🆕 NOVO
      coordenadasGPS: coordenadasGPS ?? this.coordenadasGPS, // 🆕 NOVO
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
