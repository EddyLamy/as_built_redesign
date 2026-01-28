import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de notificação/alerta
enum NotificationType {
  phaseOverdue, // Fase atrasada
  phaseApproaching, // Fase próxima do prazo
  phaseNotStarted, // Fase obrigatória não iniciada
  phaseNoEndDate, // Fase em progresso sem data fim
  componentStalled, // Componente sem progresso há muito tempo
  componentMissingData, // Componente sem Serial/VUI
  componentReplaced, // Componente substituído recentemente
  turbineLowProgress, // Turbina com baixo progresso
}

/// Nível de criticidade
enum NotificationPriority {
  info, // Informação
  warning, // Atenção
  critical, // Crítico
}

/// Modelo de Notificação/Alerta
class AppNotification {
  final String id;
  final String projectId;
  final String projectName;
  final NotificationType type;
  final NotificationPriority priority;
  final String icon;
  final String title;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>?
      metadata; // Dados extras (phaseId, turbinaId, etc)
  final bool dismissed; // Se foi dispensado pelo user
  final DateTime? dismissedAt;

  AppNotification({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.type,
    required this.priority,
    required this.icon,
    required this.title,
    required this.description,
    required this.createdAt,
    this.metadata,
    this.dismissed = false,
    this.dismissedAt,
  });

  /// Copy with
  AppNotification copyWith({
    String? id,
    String? projectId,
    String? projectName,
    NotificationType? type,
    NotificationPriority? priority,
    String? icon,
    String? title,
    String? description,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    bool? dismissed,
    DateTime? dismissedAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      dismissed: dismissed ?? this.dismissed,
      dismissedAt: dismissedAt ?? this.dismissedAt,
    );
  }

  /// Converter para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'projectName': projectName,
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
      'dismissed': dismissed,
      'dismissedAt':
          dismissedAt != null ? Timestamp.fromDate(dismissedAt!) : null,
    };
  }

  /// Criar de Map (Firestore)
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      projectId: map['projectId'] ?? '',
      projectName: map['projectName'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.phaseOverdue,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => NotificationPriority.info,
      ),
      icon: map['icon'] ?? '🔔',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      metadata: map['metadata'],
      dismissed: map['dismissed'] ?? false,
      dismissedAt: map['dismissedAt'] != null
          ? (map['dismissedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Criar do DocumentSnapshot
  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification.fromMap({...data, 'id': doc.id});
  }

  /// Helpers - Ícone por tipo
  String get typeIcon {
    switch (type) {
      case NotificationType.phaseOverdue:
        return '⚠️';
      case NotificationType.phaseApproaching:
        return '⏰';
      case NotificationType.phaseNotStarted:
        return '🔴';
      case NotificationType.phaseNoEndDate:
        return '📅';
      case NotificationType.componentStalled:
        return '⚠️';
      case NotificationType.componentMissingData:
        return '🟡';
      case NotificationType.componentReplaced:
        return '🔄';
      case NotificationType.turbineLowProgress:
        return '📊';
    }
  }

  /// Helper - Cor por prioridade
  String get colorHex {
    switch (priority) {
      case NotificationPriority.info:
        return '#3498db'; // Azul
      case NotificationPriority.warning:
        return '#f39c12'; // Laranja
      case NotificationPriority.critical:
        return '#e74c3c'; // Vermelho
    }
  }

  /// Helper - É crítico?
  bool get isCritical => priority == NotificationPriority.critical;

  /// Helper - É aviso?
  bool get isWarning => priority == NotificationPriority.warning;

  /// Helper - É info?
  bool get isInfo => priority == NotificationPriority.info;

  /// Helper - Dias desde criação
  int get daysOld {
    return DateTime.now().difference(createdAt).inDays;
  }
}
