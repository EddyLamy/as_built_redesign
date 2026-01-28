import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';
import '../models/notification_settings.dart';
import '../models/project.dart';
import '../models/project_phase.dart';
import '../models/turbina.dart';
import '../models/componente.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gerar todas as notificações para um utilizador
  Future<List<AppNotification>> generateNotifications(
    String userId,
    NotificationSettings settings,
  ) async {
    if (!settings.enabled) return [];

    final notifications = <AppNotification>[];

    // Obter todos os projetos do user
    final projectsSnapshot = await _firestore
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .get();

    for (var projectDoc in projectsSnapshot.docs) {
      final project = Project.fromFirestore(projectDoc);

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

  /// Gerar alertas de fases
  Future<List<AppNotification>> _generatePhaseAlerts(
    Project project,
    NotificationSettings settings,
  ) async {
    final alerts = <AppNotification>[];
    final now = DateTime.now();

    // Obter fases do projeto
    final phasesSnapshot = await _firestore
        .collection('projects')
        .doc(project.id)
        .collection('phases')
        .orderBy('ordem')
        .get();

    final phases = phasesSnapshot.docs
        .map((doc) => ProjectPhase.fromFirestore(doc))
        .toList();

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

    // Obter todas as turbinas do projeto
    final turbinasSnapshot = await _firestore
        .collection('projects')
        .doc(project.id)
        .collection('turbinas')
        .get();

    int totalStalled = 0;
    int totalMissingData = 0;
    int totalReplaced = 0;

    for (var turbinaDoc in turbinasSnapshot.docs) {
      final turbina = Turbina.fromFirestore(turbinaDoc);

      // Obter componentes da turbina
      final componentesSnapshot = await _firestore
          .collection('projects')
          .doc(project.id)
          .collection('turbinas')
          .doc(turbina.id)
          .collection('componentes')
          .get();

      for (var compDoc in componentesSnapshot.docs) {
        final comp = Componente.fromFirestore(compDoc);

        // 1. WARNING - Componente sem progresso há muito tempo
        if (comp.progresso == 0) {
          final daysSinceCreated = now.difference(comp.createdAt).inDays;

          if (daysSinceCreated >= settings.daysComponentStalled) {
            totalStalled++;
          }
        }

        // 2. INFO - Componente sem dados importantes
        if (comp.serialNumber == null || comp.vui == null) {
          totalMissingData++;
        }

        // 3. INFO - Componente substituído recentemente
        if (comp.substituicoes.isNotEmpty) {
          final lastReplacement = comp.substituicoes.last;
          final daysSinceReplacement =
              now.difference(lastReplacement['data'] as DateTime).inDays;

          if (daysSinceReplacement <= 7) {
            // Últimos 7 dias
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

    // Obter turbinas do projeto
    final turbinasSnapshot = await _firestore
        .collection('projects')
        .doc(project.id)
        .collection('turbinas')
        .get();

    int totalLowProgress = 0;

    for (var turbinaDoc in turbinasSnapshot.docs) {
      final turbina = Turbina.fromFirestore(turbinaDoc);

      // Turbina com baixo progresso há muito tempo
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
}
