import 'package:cloud_firestore/cloud_firestore.dart';

enum NcrCategory {
  quality('quality'),
  mechanical('mechanical'),
  electrical('electrical'),
  civil('civil'),
  safety('safety'),
  logistics('logistics'),
  documentation('documentation'),
  other('other');

  const NcrCategory(this.value);
  final String value;

  static NcrCategory fromValue(String? value) {
    return NcrCategory.values.firstWhere(
      (item) => item.value == value,
      orElse: () => NcrCategory.other,
    );
  }
}

enum NcrSeverity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const NcrSeverity(this.value);
  final String value;

  static NcrSeverity fromValue(String? value) {
    return NcrSeverity.values.firstWhere(
      (item) => item.value == value,
      orElse: () => NcrSeverity.medium,
    );
  }
}

enum NcrStatus {
  open('open'),
  inProgress('in_progress'),
  pendingValidation('pending_validation'),
  resolved('resolved'),
  closed('closed');

  const NcrStatus(this.value);
  final String value;

  static NcrStatus fromValue(String? value) {
    return NcrStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => NcrStatus.open,
    );
  }
}

class NcrEvidence {
  final String id;
  final String name;
  final String url;
  final String contentType;
  final DateTime uploadedAt;
  final String uploadedBy;

  const NcrEvidence({
    required this.id,
    required this.name,
    required this.url,
    required this.contentType,
    required this.uploadedAt,
    required this.uploadedBy,
  });

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

  factory NcrEvidence.fromMap(Map<String, dynamic> map) {
    final uploadedAt = map['uploadedAt'];
    return NcrEvidence(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      contentType: map['contentType'] ?? '',
      uploadedAt: uploadedAt is Timestamp
          ? uploadedAt.toDate()
          : DateTime.tryParse('${map['uploadedAt']}') ?? DateTime.now(),
      uploadedBy: map['uploadedBy'] ?? '',
    );
  }
}

class NcrStatusChange {
  final String id;
  final NcrStatus fromStatus;
  final NcrStatus toStatus;
  final String note;
  final String changedBy;
  final String changedByName;
  final DateTime changedAt;

  const NcrStatusChange({
    required this.id,
    required this.fromStatus,
    required this.toStatus,
    required this.note,
    required this.changedBy,
    required this.changedByName,
    required this.changedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromStatus': fromStatus.value,
      'toStatus': toStatus.value,
      'note': note,
      'changedBy': changedBy,
      'changedByName': changedByName,
      'changedAt': Timestamp.fromDate(changedAt),
    };
  }

  factory NcrStatusChange.fromMap(Map<String, dynamic> map) {
    final changedAt = map['changedAt'];
    return NcrStatusChange(
      id: map['id'] ?? '',
      fromStatus: NcrStatus.fromValue(map['fromStatus']),
      toStatus: NcrStatus.fromValue(map['toStatus']),
      note: map['note'] ?? '',
      changedBy: map['changedBy'] ?? '',
      changedByName: map['changedByName'] ?? '',
      changedAt: changedAt is Timestamp
          ? changedAt.toDate()
          : DateTime.tryParse('$changedAt') ?? DateTime.now(),
    );
  }
}

class NcrRecord {
  final String ncrId;
  final String code;
  final String projectId;
  final String turbinaId;
  final String turbinaNome;
  final String title;
  final String description;
  final NcrCategory category;
  final NcrSeverity severity;
  final NcrStatus status;
  final DateTime dueDate;
  final String assignedToUid;
  final String assignedTo;
  final List<String> tags;
  final List<NcrEvidence> evidence;
  final List<NcrStatusChange> statusHistory;
  final String closureNote;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final String closedBy;
  final String closedByName;

  const NcrRecord({
    required this.ncrId,
    required this.code,
    required this.projectId,
    required this.turbinaId,
    required this.turbinaNome,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.status,
    required this.dueDate,
    this.assignedToUid = '',
    required this.assignedTo,
    required this.tags,
    required this.evidence,
    this.statusHistory = const <NcrStatusChange>[],
    this.closureNote = '',
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
    this.closedBy = '',
    this.closedByName = '',
  });

  bool get isClosed =>
      status == NcrStatus.resolved || status == NcrStatus.closed;

  bool get isOverdue => !isClosed && dueDate.isBefore(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'ncrId': ncrId,
      'code': code,
      'projectId': projectId,
      'turbinaId': turbinaId,
      'turbinaNome': turbinaNome,
      'title': title,
      'description': description,
      'category': category.value,
      'severity': severity.value,
      'status': status.value,
      'dueDate': Timestamp.fromDate(dueDate),
      'assignedToUid': assignedToUid,
      'assignedTo': assignedTo,
      'tags': tags,
      'evidence': evidence.map((item) => item.toMap()).toList(),
      'statusHistory': statusHistory.map((item) => item.toMap()).toList(),
      'closureNote': closureNote,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'closedBy': closedBy,
      'closedByName': closedByName,
    };
  }

  factory NcrRecord.fromMap(Map<String, dynamic> map) {
    DateTime readDate(dynamic value, {DateTime? fallback}) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.tryParse('$value') ?? fallback ?? DateTime.now();
    }

    return NcrRecord(
      ncrId: map['ncrId'] ?? '',
      code: map['code'] ?? '',
      projectId: map['projectId'] ?? '',
      turbinaId: map['turbinaId'] ?? '',
      turbinaNome: map['turbinaNome'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: NcrCategory.fromValue(map['category']),
      severity: NcrSeverity.fromValue(map['severity']),
      status: NcrStatus.fromValue(map['status']),
      dueDate: readDate(map['dueDate']),
      assignedToUid: map['assignedToUid'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      tags: List<String>.from(map['tags'] ?? const <String>[]),
      evidence: (map['evidence'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => NcrEvidence.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      statusHistory:
          (map['statusHistory'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map(
                (item) =>
                    NcrStatusChange.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList(),
      closureNote: map['closureNote'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      createdAt: readDate(map['createdAt']),
      updatedAt: readDate(map['updatedAt']),
      closedAt: map['closedAt'] != null
          ? readDate(map['closedAt'], fallback: null)
          : null,
      closedBy: map['closedBy'] ?? '',
      closedByName: map['closedByName'] ?? '',
    );
  }

  factory NcrRecord.fromFirestore(DocumentSnapshot doc) {
    return NcrRecord.fromMap({
      ...(doc.data() as Map<String, dynamic>? ?? const <String, dynamic>{}),
      'ncrId': doc.id,
    });
  }

  NcrRecord copyWith({
    String? ncrId,
    String? code,
    String? projectId,
    String? turbinaId,
    String? turbinaNome,
    String? title,
    String? description,
    NcrCategory? category,
    NcrSeverity? severity,
    NcrStatus? status,
    DateTime? dueDate,
    String? assignedToUid,
    String? assignedTo,
    List<String>? tags,
    List<NcrEvidence>? evidence,
    List<NcrStatusChange>? statusHistory,
    String? closureNote,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
    String? closedBy,
    String? closedByName,
    bool clearClosedAt = false,
  }) {
    return NcrRecord(
      ncrId: ncrId ?? this.ncrId,
      code: code ?? this.code,
      projectId: projectId ?? this.projectId,
      turbinaId: turbinaId ?? this.turbinaId,
      turbinaNome: turbinaNome ?? this.turbinaNome,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      assignedToUid: assignedToUid ?? this.assignedToUid,
      assignedTo: assignedTo ?? this.assignedTo,
      tags: tags ?? this.tags,
      evidence: evidence ?? this.evidence,
      statusHistory: statusHistory ?? this.statusHistory,
      closureNote: closureNote ?? this.closureNote,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: clearClosedAt ? null : closedAt ?? this.closedAt,
      closedBy: closedBy ?? this.closedBy,
      closedByName: closedByName ?? this.closedByName,
    );
  }
}
