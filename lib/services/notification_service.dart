import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';
import '../models/notification_settings.dart';
import '../models/project.dart';
import '../models/project_phase.dart';
import '../models/turbina.dart';
import '../models/componente.dart';
import '../models/equipment.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gerar todas as notificações para um utilizador
  Future<List<AppNotification>> generateNotifications(
    String userId,
    NotificationSettings settings, {
    String? selectedProjectId,
    List<Project>? accessibleProjects,
  }) async {
    if (!settings.enabled) return [];

    final notifications = <AppNotification>[];

    final projects = await _resolveProjects(
      userId,
      selectedProjectId: selectedProjectId,
      accessibleProjects: accessibleProjects,
    );

    for (final project in projects) {
      // Skip se projeto está silenciado
      if (settings.isProjectMuted(project.id)) {
        continue;
      }

      // Gerar alertas de fases
      if (settings.phaseAlerts) {
        final phaseAlerts = await _generatePhaseAlerts(
          project,
          settings,
        );
        notifications.addAll(phaseAlerts);
      }

      // Gerar alertas de componentes
      if (settings.componentAlerts) {
        final componentAlerts = await _generateComponentAlerts(
          project,
          settings,
        );
        notifications.addAll(componentAlerts);
      }

      // Gerar alertas de turbinas
      if (settings.turbineAlerts) {
        final turbineAlerts = await _generateTurbineAlerts(
          project,
          settings,
        );
        notifications.addAll(turbineAlerts);
      }
    }

    // Gerar alertas de calibração de equipamento (global)
    if (settings.componentAlerts) {
      final allowedProjectIds = projects.map((project) => project.id).toSet();
      final projectNamesById = {
        for (final project in projects) project.id: project.nome,
      };

      final equipmentAlerts = await _generateEquipmentCalibrationAlerts(
        userId: userId,
        allowedProjectIds: allowedProjectIds,
        projectNamesById: projectNamesById,
      );
      notifications.addAll(equipmentAlerts);
    }

    // Filtrar alertas dispensados
    final filtered = notifications.where((n) {
      return !settings.isAlertDismissed(n.id);
    }).toList();

    // Ordenar por prioridade e data
    filtered.sort((a, b) {
      // Primeiro por prioridade (crítico > warning > info)
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;

      // Depois por data (mais recente primeiro)
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  Future<List<Project>> _resolveProjects(
    String userId, {
    String? selectedProjectId,
    List<Project>? accessibleProjects,
  }) async {
    final projects = accessibleProjects ??
        (await _firestore
                .collection('projects')
                .where('userId', isEqualTo: userId)
                .get())
            .docs
            .map(Project.fromFirestore)
            .toList();

    return projects
        .where((project) =>
            selectedProjectId == null || project.id == selectedProjectId)
        .toList();
  }

  /// Gerar alertas de calibração de equipamento
  Future<List<AppNotification>> _generateEquipmentCalibrationAlerts({
    required String userId,
    required Set<String> allowedProjectIds,
    required Map<String, String> projectNamesById,
  }) async {
    final alerts = <AppNotification>[];
    final now = DateTime.now();

    if (allowedProjectIds.isEmpty) {
      return alerts;
    }

    final equipmentSnapshot = await _firestore
        .collection('equipment')
        .where('createdBy', isEqualTo: userId)
        .get();

    for (final doc in equipmentSnapshot.docs) {
      final equipment = Equipment.fromMap(doc.data());
      if (!allowedProjectIds.contains(equipment.projectId)) {
        continue;
      }

      final calibrationAlert = equipment.calibrationAlert;

      if (calibrationAlert == null) continue;

      final priority =
          calibrationAlert.severity == CalibrationAlertSeverity.critical
              ? NotificationPriority.critical
              : NotificationPriority.warning;

      final type =
          calibrationAlert.severity == CalibrationAlertSeverity.critical
              ? NotificationType.componentStalled
              : NotificationType.componentMissingData;

      final alertId =
          'equipment_${equipment.equipmentId}_calibration_${calibrationAlert.type.name}';

      alerts.add(AppNotification(
        id: alertId,
        projectId: equipment.projectId,
        projectName: projectNamesById[equipment.projectId] ??
            equipment.currentProjectName ??
            'Equipamento',
        type: type,
        priority: priority,
        icon: calibrationAlert.type == CalibrationAlertType.expirado
            ? '⛔'
            : '🛠️',
        title: calibrationAlert.type == CalibrationAlertType.expirado
            ? 'Calibração expirada'
            : 'Calibração a expirar',
        description:
            '${equipment.model} (${equipment.serialNumber}) • ${calibrationAlert.message}',
        createdAt: now,
        metadata: {
          'equipmentId': equipment.equipmentId,
          'equipmentModel': equipment.model,
          'serialNumber': equipment.serialNumber,
          'daysUntilExpiry': calibrationAlert.daysUntilExpiry,
          'source': 'equipment_calibration',
        },
      ));
    }

    return alerts;
  }

  /// Gerar alertas de fases
  Future<List<AppNotification>> _generatePhaseAlerts(
    Project project,
    NotificationSettings settings,
  ) async {
    final alerts = <AppNotification>[];
    final now = DateTime.now();

    final phases = await _loadProjectPhases(project.id);

    for (var phase in phases) {
      // Skip se não aplicável
      if (!phase.aplicavel) continue;

      final phaseId = '${project.id}_phase_${phase.id}';

      // ✅ FIX: Usar nome se nomeKey for null
      final phaseName = phase.nomeKey ?? phase.nome;

      // 1. CRÍTICO - Fase atrasada
      if (phase.dataFim != null && now.isAfter(phase.dataFim!)) {
        final daysOverdue = now.difference(phase.dataFim!).inDays;

        alerts.add(AppNotification(
          id: '${phaseId}_overdue',
          projectId: project.id,
          projectName: project.nome,
          type: NotificationType.phaseOverdue,
          priority: NotificationPriority.critical,
          title: 'phase_overdue_title', // ✅ Key de tradução
          description: 'phase_overdue_desc', // ✅ Key de tradução
          icon: '⚠️',
          createdAt: now,
          metadata: {
            'phaseId': phase.id,
            'phaseName': phaseName,
            'daysOverdue': daysOverdue,
            'dueDate': phase.dataFim!.toIso8601String(),
          },
        ));
      }

      // 2. WARNING - Fase próxima do prazo
      if (phase.dataFim != null && !now.isAfter(phase.dataFim!)) {
        final daysUntilDue = phase.dataFim!.difference(now).inDays;

        if (daysUntilDue <= settings.daysBeforePhaseWarning &&
            daysUntilDue >= 0) {
          alerts.add(AppNotification(
            id: '${phaseId}_approaching',
            projectId: project.id,
            projectName: project.nome,
            type: NotificationType.phaseApproaching,
            priority: NotificationPriority.warning,
            title: 'phase_approaching_title', // ✅ Key
            description: 'phase_approaching_desc', // ✅ Key
            icon: '🟠',
            createdAt: now,
            metadata: {
              'phaseId': phase.id,
              'phaseName': phaseName,
              'daysUntilDue': daysUntilDue,
              'dueDate': phase.dataFim!.toIso8601String(),
            },
          ));
        }
      }

      // 3. CRÍTICO - Fase obrigatória não iniciada
      if (phase.obrigatorio &&
          phase.dataInicio == null &&
          phase.dataFim == null) {
        alerts.add(AppNotification(
          id: '${phaseId}_not_started',
          projectId: project.id,
          projectName: project.nome,
          type: NotificationType.phaseNotStarted,
          priority: NotificationPriority.critical,
          title: 'phase_not_started_title', // ✅ Key
          description: 'phase_not_started_desc', // ✅ Key
          icon: '🔴',
          createdAt: now,
          metadata: {
            'phaseId': phase.id,
            'phaseName': phaseName,
          },
        ));
      }

      // 4. INFO - Fase em progresso sem data de fim
      if (phase.dataInicio != null && phase.dataFim == null) {
        final daysSinceStart = now.difference(phase.dataInicio!).inDays;

        // ✅ Sempre mostrar alerta se não tem data fim (removido threshold de 30 dias)
        alerts.add(AppNotification(
          id: '${phaseId}_no_end_date',
          projectId: project.id,
          projectName: project.nome,
          type: NotificationType.phaseNoEndDate,
          priority: NotificationPriority.info,
          title: 'phase_no_end_date_title', // ✅ Key
          description: 'phase_no_end_date_desc', // ✅ Key
          icon: 'ℹ️',
          createdAt: now,
          metadata: {
            'phaseId': phase.id,
            'phaseName': phaseName,
            'daysSinceStart': daysSinceStart,
            'startDate': phase.dataInicio!.toIso8601String(),
          },
        ));
      }
    }

    return alerts;
  }

  /// Gerar alertas de componentes
  Future<List<AppNotification>> _generateComponentAlerts(
    Project project,
    NotificationSettings settings,
  ) async {
    final alerts = <AppNotification>[];
    final now = DateTime.now();

    final turbinas = await _loadProjectTurbinas(project.id);
    final componentes = await _loadProjectComponentes(project.id, turbinas);

    int totalStalled = 0;
    int totalMissingData = 0;
    int totalReplaced = 0;

    for (final comp in componentes) {
      if (comp.progresso == 0) {
        final daysSinceCreated = now.difference(comp.createdAt).inDays;

        if (daysSinceCreated >= settings.daysComponentStalled) {
          totalStalled++;
        }
      }

      final serialNumber = comp.serialNumber?.trim();
      final vui = comp.vui?.trim();
      if ((serialNumber == null || serialNumber.isEmpty) ||
          (vui == null || vui.isEmpty)) {
        totalMissingData++;
      }

      if (comp.substituicoes.isNotEmpty) {
        final replacementDate = _readReplacementDate(comp.substituicoes.last);
        if (replacementDate != null) {
          final daysSinceReplacement = now.difference(replacementDate).inDays;
          if (daysSinceReplacement <= 7) {
            totalReplaced++;
          }
        }
      }
    }

    // Criar alertas agregados
    if (totalStalled > 0) {
      alerts.add(AppNotification(
        id: '${project.id}_components_stalled',
        projectId: project.id,
        projectName: project.nome,
        type: NotificationType.componentStalled,
        priority: NotificationPriority.warning,
        icon: '🟠',
        title: '$totalStalled componentes sem progresso',
        description:
            'Há $totalStalled componentes sem progresso há mais de ${settings.daysComponentStalled} dias',
        createdAt: now,
        metadata: {
          'count': totalStalled,
          'threshold': settings.daysComponentStalled,
        },
      ));
    }

    if (totalMissingData > 0) {
      alerts.add(AppNotification(
        id: '${project.id}_components_missing_data',
        projectId: project.id,
        projectName: project.nome,
        type: NotificationType.componentMissingData,
        priority: NotificationPriority.info,
        icon: 'ℹ️',
        title: '$totalMissingData componentes sem dados',
        description:
            'Há $totalMissingData componentes sem Serial Number ou VUI',
        createdAt: now,
        metadata: {
          'count': totalMissingData,
        },
      ));
    }

    if (totalReplaced > 0) {
      alerts.add(AppNotification(
        id: '${project.id}_components_replaced',
        projectId: project.id,
        projectName: project.nome,
        type: NotificationType.componentReplaced,
        priority: NotificationPriority.info,
        icon: '🔄',
        title: '$totalReplaced componentes substituídos',
        description:
            'Foram substituídos $totalReplaced componentes nos últimos 7 dias',
        createdAt: now,
        metadata: {
          'count': totalReplaced,
        },
      ));
    }

    return alerts;
  }

  /// Gerar alertas de turbinas
  Future<List<AppNotification>> _generateTurbineAlerts(
    Project project,
    NotificationSettings settings,
  ) async {
    final alerts = <AppNotification>[];
    final now = DateTime.now();

    final turbinas = await _loadProjectTurbinas(project.id);

    int totalLowProgress = 0;

    for (final turbina in turbinas) {
      if (turbina.progresso < 50) {
        final daysSinceCreated = now.difference(turbina.createdAt).inDays;

        if (daysSinceCreated >= settings.daysTurbineStalled) {
          totalLowProgress++;
        }
      }
    }

    if (totalLowProgress > 0) {
      alerts.add(AppNotification(
        id: '${project.id}_turbines_low_progress',
        projectId: project.id,
        projectName: project.nome,
        type: NotificationType.turbineLowProgress,
        priority: NotificationPriority.warning,
        icon: '🟠',
        title: '$totalLowProgress turbinas com baixo progresso',
        description:
            'Há $totalLowProgress turbinas com menos de 50% de progresso há mais de ${settings.daysTurbineStalled} dias',
        createdAt: now,
        metadata: {
          'count': totalLowProgress,
          'threshold': settings.daysTurbineStalled,
        },
      ));
    }

    return alerts;
  }

  /// Contar notificações por prioridade
  Map<NotificationPriority, int> countByPriority(
      List<AppNotification> notifications) {
    final counts = {
      NotificationPriority.critical: 0,
      NotificationPriority.warning: 0,
      NotificationPriority.info: 0,
    };

    for (var notif in notifications) {
      counts[notif.priority] = (counts[notif.priority] ?? 0) + 1;
    }

    return counts;
  }

  /// Contar notificações por tipo
  Map<NotificationType, int> countByType(List<AppNotification> notifications) {
    final counts = <NotificationType, int>{};

    for (var notif in notifications) {
      counts[notif.type] = (counts[notif.type] ?? 0) + 1;
    }

    return counts;
  }

  Future<List<ProjectPhase>> _loadProjectPhases(String projectId) async {
    final nestedSnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('phases')
        .orderBy('ordem')
        .get();

    if (nestedSnapshot.docs.isNotEmpty) {
      return nestedSnapshot.docs.map(ProjectPhase.fromFirestore).toList();
    }

    final topLevelSnapshot = await _firestore
        .collection('project_phases')
        .where('projectId', isEqualTo: projectId)
        .orderBy('ordem')
        .get();

    return topLevelSnapshot.docs.map(ProjectPhase.fromFirestore).toList();
  }

  Future<List<Turbina>> _loadProjectTurbinas(String projectId) async {
    final topLevelSnapshot = await _firestore
        .collection('turbinas')
        .where('projectId', isEqualTo: projectId)
        .get();

    if (topLevelSnapshot.docs.isNotEmpty) {
      return topLevelSnapshot.docs.map(Turbina.fromFirestore).toList();
    }

    final nestedSnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('turbinas')
        .get();

    return nestedSnapshot.docs.map(Turbina.fromFirestore).toList();
  }

  Future<List<Componente>> _loadProjectComponentes(
    String projectId,
    List<Turbina> turbinas,
  ) async {
    final topLevelSnapshot = await _firestore
        .collection('componentes')
        .where('projectId', isEqualTo: projectId)
        .get();

    if (topLevelSnapshot.docs.isNotEmpty) {
      return topLevelSnapshot.docs.map(Componente.fromFirestore).toList();
    }

    final componentes = <Componente>[];
    for (final turbina in turbinas) {
      final nestedSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('turbinas')
          .doc(turbina.id)
          .collection('componentes')
          .get();
      componentes.addAll(nestedSnapshot.docs.map(Componente.fromFirestore));
    }

    return componentes;
  }

  DateTime? _readReplacementDate(Map<String, dynamic> replacement) {
    final value = replacement['data'];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
