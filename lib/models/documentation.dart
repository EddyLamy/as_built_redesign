// ══════════════════════════════════════════════════════════════
// DOCUMENTATION MODEL
// lib/models/documentation.dart
// ══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';

enum DocumentCategory {
  relatorios('relatorios', 'Relatórios Técnicos', '📊'),
  procedimentos('procedimentos', 'Procedimentos', '📘'),
  certificados('certificados', 'Certificados', '📜'),
  reportsDanos('reports_danos', 'Reports de Danos', '⚠️'),
  desenhosTecnicos('desenhos_tecnicos', 'Desenhos Técnicos', '📐'),
  manuais('manuais', 'Manuais', '📖'),
  outro('outro', 'Outros', '📄');

  const DocumentCategory(this.value, this.label, this.icon);
  final String value;
  final String label;
  final String icon;
}

class DocumentRelations {
  final List<String> turbines;
  final List<String> phases;
  final List<String> equipment;
  final List<String> connections;

  DocumentRelations({
    this.turbines = const [],
    this.phases = const [],
    this.equipment = const [],
    this.connections = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'turbines': turbines,
      'phases': phases,
      'equipment': equipment,
      'connections': connections,
    };
  }

  factory DocumentRelations.fromMap(Map<String, dynamic> map) {
    return DocumentRelations(
      turbines: List<String>.from(map['turbines'] ?? []),
      phases: List<String>.from(map['phases'] ?? []),
      equipment: List<String>.from(map['equipment'] ?? []),
      connections: List<String>.from(map['connections'] ?? []),
    );
  }

  DocumentRelations copyWith({
    List<String>? turbines,
    List<String>? phases,
    List<String>? equipment,
    List<String>? connections,
  }) {
    return DocumentRelations(
      turbines: turbines ?? this.turbines,
      phases: phases ?? this.phases,
      equipment: equipment ?? this.equipment,
      connections: connections ?? this.connections,
    );
  }
}

class Documentation {
  final String documentId;
  final String projectId;
  final String title;
  final String? description;
  final DocumentCategory category;
  final String? subcategory;
  final List<String> tags;
  final String filePath;
  final String fileName;
  final String fileExtension;
  final bool? fileExists;
  final DateTime? lastChecked;
  final String documentDate;
  final String registeredDate;
  final DocumentRelations? relatedTo;
  final String visibility;
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  Documentation({
    required this.documentId,
    required this.projectId,
    required this.title,
    this.description,
    required this.category,
    this.subcategory,
    required this.tags,
    required this.filePath,
    required this.fileName,
    required this.fileExtension,
    this.fileExists,
    this.lastChecked,
    required this.documentDate,
    required this.registeredDate,
    this.relatedTo,
    this.visibility = 'all',
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'projectId': projectId,
      'title': title,
      'description': description,
      'category': category.value,
      'subcategory': subcategory,
      'tags': tags,
      'filePath': filePath,
      'fileName': fileName,
      'fileExtension': fileExtension,
      'fileExists': fileExists,
      'lastChecked':
          lastChecked != null ? Timestamp.fromDate(lastChecked!) : null,
      'documentDate': documentDate,
      'registeredDate': registeredDate,
      'relatedTo': relatedTo?.toMap(),
      'visibility': visibility,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedBy': updatedBy,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Documentation.fromMap(Map<String, dynamic> map) {
    return Documentation(
      documentId: map['documentId'] ?? '',
      projectId: map['projectId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      category: DocumentCategory.values.firstWhere(
        (e) => e.value == map['category'],
        orElse: () => DocumentCategory.outro,
      ),
      subcategory: map['subcategory'],
      tags: List<String>.from(map['tags'] ?? []),
      filePath: map['filePath'] ?? '',
      fileName: map['fileName'] ?? '',
      fileExtension: map['fileExtension'] ?? '',
      fileExists: map['fileExists'],
      lastChecked: map['lastChecked'] != null
          ? (map['lastChecked'] as Timestamp).toDate()
          : null,
      documentDate: map['documentDate'] ?? '',
      registeredDate: map['registeredDate'] ?? '',
      relatedTo: map['relatedTo'] != null
          ? DocumentRelations.fromMap(map['relatedTo'])
          : null,
      visibility: map['visibility'] ?? 'all',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedBy: map['updatedBy'],
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Documentation copyWith({
    String? documentId,
    String? projectId,
    String? title,
    String? description,
    DocumentCategory? category,
    String? subcategory,
    List<String>? tags,
    String? filePath,
    String? fileName,
    String? fileExtension,
    bool? fileExists,
    DateTime? lastChecked,
    String? documentDate,
    String? registeredDate,
    DocumentRelations? relatedTo,
    String? visibility,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return Documentation(
      documentId: documentId ?? this.documentId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      tags: tags ?? this.tags,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileExtension: fileExtension ?? this.fileExtension,
      fileExists: fileExists ?? this.fileExists,
      lastChecked: lastChecked ?? this.lastChecked,
      documentDate: documentDate ?? this.documentDate,
      registeredDate: registeredDate ?? this.registeredDate,
      relatedTo: relatedTo ?? this.relatedTo,
      visibility: visibility ?? this.visibility,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
