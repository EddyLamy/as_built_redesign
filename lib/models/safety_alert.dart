import 'package:cloud_firestore/cloud_firestore.dart';

enum SafetyAlertCategory {
  nearMiss('near_miss'),
  hazardousObservation('hazardous_observation'),
  walkAndTalk('walk_and_talk');

  const SafetyAlertCategory(this.value);
  final String value;

  static SafetyAlertCategory fromValue(String? value) {
    return SafetyAlertCategory.values.firstWhere(
      (item) => item.value == value,
      orElse: () => SafetyAlertCategory.nearMiss,
    );
  }
}

enum SafetyAlertStatus {
  resolved('resolved'),
  underStudy('under_study'),
  inResolution('in_resolution'),
  futureCompanyAction('future_company_action');

  const SafetyAlertStatus(this.value);
  final String value;

  static SafetyAlertStatus fromValue(String? value) {
    return SafetyAlertStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => SafetyAlertStatus.underStudy,
    );
  }
}

class SafetyAlertEvidence {
  const SafetyAlertEvidence({
    required this.id,
    required this.name,
    required this.url,
    required this.contentType,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  final String id;
  final String name;
  final String url;
  final String contentType;
  final DateTime uploadedAt;
  final String uploadedBy;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'contentType': contentType,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'uploadedBy': uploadedBy,
    };
  }

  factory SafetyAlertEvidence.fromMap(Map<String, dynamic> map) {
    final uploadedAt = map['uploadedAt'];
    return SafetyAlertEvidence(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      contentType: map['contentType'] ?? '',
      uploadedAt: uploadedAt is Timestamp
          ? uploadedAt.toDate()
          : DateTime.tryParse('$uploadedAt') ?? DateTime.now(),
      uploadedBy: map['uploadedBy'] ?? '',
    );
  }
}

class SafetyAlertRecord {
  const SafetyAlertRecord({
    required this.alertId,
    required this.code,
    required this.projectId,
    required this.category,
    required this.destinationTo,
    required this.department,
    required this.problemDescription,
    required this.proposedSolution,
    required this.resolucaoEfetuada,
    required this.status,
    required this.evidence,
    required this.resolutionEvidence,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  final String alertId;
  final String code;
  final String projectId;
  final SafetyAlertCategory category;
  final String destinationTo;
  final String department;
  final String problemDescription;
  final String proposedSolution;
  final String resolucaoEfetuada;
  final SafetyAlertStatus status;
  final List<SafetyAlertEvidence> evidence;
  final List<SafetyAlertEvidence> resolutionEvidence;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'alertId': alertId,
      'code': code,
      'projectId': projectId,
      'category': category.value,
      'destinationTo': destinationTo,
      'department': department,
      'problemDescription': problemDescription,
      'proposedSolution': proposedSolution,
      'resolucaoEfetuada': resolucaoEfetuada,
      'status': status.value,
      'evidence': evidence.map((item) => item.toMap()).toList(),
      'resolutionEvidence':
          resolutionEvidence.map((item) => item.toMap()).toList(),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SafetyAlertRecord.fromMap(Map<String, dynamic> map) {
    DateTime readDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is DateTime) {
        return value;
      }
      return DateTime.tryParse('$value') ?? DateTime.now();
    }

    return SafetyAlertRecord(
      alertId: map['alertId'] ?? '',
      code: map['code'] ?? '',
      projectId: map['projectId'] ?? '',
      category: SafetyAlertCategory.fromValue(map['category']),
      destinationTo: map['destinationTo'] ?? '',
      department: map['department'] ?? '',
      problemDescription: map['problemDescription'] ?? '',
      proposedSolution: map['proposedSolution'] ?? '',
      resolucaoEfetuada: map['resolucaoEfetuada'] ?? '',
      status: SafetyAlertStatus.fromValue(map['status']),
      evidence: (map['evidence'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (item) => SafetyAlertEvidence.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      resolutionEvidence:
          (map['resolutionEvidence'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map(
                (item) => SafetyAlertEvidence.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      createdAt: readDate(map['createdAt']),
      updatedAt: readDate(map['updatedAt']),
    );
  }

  factory SafetyAlertRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return SafetyAlertRecord.fromMap({...data, 'alertId': doc.id});
  }

  SafetyAlertRecord copyWith({
    String? alertId,
    String? code,
    String? projectId,
    SafetyAlertCategory? category,
    String? destinationTo,
    String? department,
    String? problemDescription,
    String? proposedSolution,
    String? resolucaoEfetuada,
    SafetyAlertStatus? status,
    List<SafetyAlertEvidence>? evidence,
    List<SafetyAlertEvidence>? resolutionEvidence,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SafetyAlertRecord(
      alertId: alertId ?? this.alertId,
      code: code ?? this.code,
      projectId: projectId ?? this.projectId,
      category: category ?? this.category,
      destinationTo: destinationTo ?? this.destinationTo,
      department: department ?? this.department,
      problemDescription: problemDescription ?? this.problemDescription,
      proposedSolution: proposedSolution ?? this.proposedSolution,
      resolucaoEfetuada: resolucaoEfetuada ?? this.resolucaoEfetuada,
      status: status ?? this.status,
      evidence: evidence ?? this.evidence,
      resolutionEvidence: resolutionEvidence ?? this.resolutionEvidence,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
