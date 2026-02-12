import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String userId;
  final String nome;
  final String projectId;
  final String projectManager;
  final String siteManager;
  final int totalTurbinas; // Mantido como solicitado
  final int numeroTurbinas; // ADICIONADO para resolver os erros de compilação
  final String turbineType;
  final String foundationType;
  final DateTime? siteOpeningDate;
  final DateTime? estimatedGridAvailability;
  final DateTime? estimatedHandover;
  final String? localizacao;
  final String? morada;
  final String? coordenadasGPS;
  final String status;
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
    this.numeroTurbinas = 0, // Adicionado ao construtor
    required this.turbineType,
    required this.foundationType,
    this.siteOpeningDate,
    this.estimatedGridAvailability,
    this.estimatedHandover,
    this.localizacao,
    this.morada,
    this.coordenadasGPS,
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
      'numeroTurbinas': numeroTurbinas, // Persistindo o novo campo
      'turbineType': turbineType,
      'foundationType': foundationType,
      'siteOpeningDate':
          siteOpeningDate != null ? Timestamp.fromDate(siteOpeningDate!) : null,
      'estimatedGridAvailability': estimatedGridAvailability != null
          ? Timestamp.fromDate(estimatedGridAvailability!)
          : null,
      'estimatedHandover': estimatedHandover != null
          ? Timestamp.fromDate(estimatedHandover!)
          : null,
      'localizacao': localizacao,
      'morada': morada,
      'coordenadasGPS': coordenadasGPS,
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
      numeroTurbinas: map['numeroTurbinas'] ?? 0, // Lendo do Firestore
      turbineType: map['turbineType'] ?? '',
      foundationType: map['foundationType'] ?? '',
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
      morada: map['morada'],
      coordenadasGPS: map['coordenadasGPS'],
      status: map['status'] ?? 'Planejado',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Project.fromMap(doc.id, data);
  }

  Project copyWith({
    String? id,
    String? userId,
    String? nome,
    String? projectId,
    String? projectManager,
    String? siteManager,
    int? totalTurbinas,
    int? numeroTurbinas, // Adicionado ao copyWith
    String? turbineType,
    String? foundationType,
    DateTime? siteOpeningDate,
    DateTime? estimatedGridAvailability,
    DateTime? estimatedHandover,
    String? localizacao,
    String? morada,
    String? coordenadasGPS,
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
      numeroTurbinas: numeroTurbinas ?? this.numeroTurbinas,
      turbineType: turbineType ?? this.turbineType,
      foundationType: foundationType ?? this.foundationType,
      siteOpeningDate: siteOpeningDate ?? this.siteOpeningDate,
      estimatedGridAvailability:
          estimatedGridAvailability ?? this.estimatedGridAvailability,
      estimatedHandover: estimatedHandover ?? this.estimatedHandover,
      localizacao: localizacao ?? this.localizacao,
      morada: morada ?? this.morada,
      coordenadasGPS: coordenadasGPS ?? this.coordenadasGPS,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
