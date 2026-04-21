import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/project.dart';
import '../models/turbina.dart';
import '../models/componente.dart';
import '../models/project_phase.dart';
import '../models/notification_settings.dart';
import '../models/notification.dart';
import '../models/app_user.dart';

import '../services/project_service.dart';
import '../services/turbina_service.dart';
import '../services/componente_service.dart';
import '../services/project_phase_service.dart';
import '../services/notification_service.dart';
import 'auth_providers.dart';
import 'permission_provider.dart';

part 'app_providers.g.dart';

// ============================================================================
// 🔔 NOTIFICATION SYSTEM - NOVO
// ============================================================================

// Service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider das Configurações (StateNotifier)
// COMENTADO: Classe problemática que usa StateNotifier obsoleto no Riverpod 3.x
// Substituída por FutureProvider simples abaixo
/*
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(NotificationSettings()) {
    _loadSettings();
  }

  /// Carregar settings do SharedPreferences
  Future<void> _loadSettings() async {
    final settings = await NotificationSettings.load();
    state = settings;
  }

  /// Atualizar settings
  Future<void> updateSettings(NotificationSettings newSettings) async {
    state = newSettings;
    await newSettings.save();
  }

  /// Toggle global
  Future<void> toggleEnabled() async {
    final newSettings = state.copyWith(enabled: !state.enabled);
    await updateSettings(newSettings);
  }

  /// Toggle alertas de fases
  Future<void> togglePhaseAlerts() async {
    final newSettings = state.copyWith(phaseAlerts: !state.phaseAlerts);
    await updateSettings(newSettings);
  }

  /// Toggle alertas de componentes
  Future<void> toggleComponentAlerts() async {
    final newSettings = state.copyWith(componentAlerts: !state.componentAlerts);
    await updateSettings(newSettings);
  }

  /// Toggle alertas de turbinas
  Future<void> toggleTurbineAlerts() async {
    final newSettings = state.copyWith(turbineAlerts: !state.turbineAlerts);
    await updateSettings(newSettings);
  }

  /// Toggle badge
  Future<void> toggleShowBadge() async {
    final newSettings = state.copyWith(showBadge: !state.showBadge);
    await updateSettings(newSettings);
  }

  /// Toggle dashboard
  Future<void> toggleShowInDashboard() async {
    final newSettings = state.copyWith(showInDashboard: !state.showInDashboard);
    await updateSettings(newSettings);
  }

  /// Atualizar threshold de fases
  Future<void> updatePhaseWarningDays(int days) async {
    final newSettings = state.copyWith(daysBeforePhaseWarning: days);
    await updateSettings(newSettings);
  }

  /// Atualizar threshold de componentes
  Future<void> updateComponentStalledDays(int days) async {
    final newSettings = state.copyWith(daysComponentStalled: days);
    await updateSettings(newSettings);
  }

  /// Atualizar threshold de turbinas
  Future<void> updateTurbineStalledDays(int days) async {
    final newSettings = state.copyWith(daysTurbineStalled: days);
    await updateSettings(newSettings);
  }

  /// Silenciar projeto
  Future<void> muteProject(String projectId, int days) async {
    final newSettings = state.muteProject(projectId, days);
    await updateSettings(newSettings);
  }

  /// Reativar projeto
  Future<void> unmuteProject(String projectId) async {
    final newSettings = state.unmuteProject(projectId);
    await updateSettings(newSettings);
  }

  /// Dispensar alerta
  Future<void> dismissAlert(String alertId) async {
    final newSettings = state.dismissAlert(alertId);
    await updateSettings(newSettings);
  }

  /// Limpar alertas antigos
  Future<void> cleanup() async {
    var newSettings = state.cleanupDismissed();
    newSettings = newSettings.cleanupMutedProjects();
    await updateSettings(newSettings);
  }

  /// Resetar para padrão
  Future<void> reset() async {
    await NotificationSettings.clear();
    state = NotificationSettings();
  }

  /// Cleanup do Notifier (quando não está mais em uso)
}

/// Provider do StateNotifier
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  return NotificationSettingsNotifier();
});
*/

/// Provider simplificado para NotificationSettings (Riverpod 3.x compatible)
final notificationSettingsProvider =
    FutureProvider<NotificationSettings>((ref) async {
  return await NotificationSettings.load();
});

/// Trigger para refrescar notificações quando equipamento mudar
final equipmentNotificationRefreshProvider =
    StreamProvider.autoDispose<int>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(0);

  return FirebaseFirestore.instance
      .collection('equipment')
      .where('createdBy', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

/// Provider das Notificações (auto-refresh)
final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  final selectedProjectId = ref.watch(accessibleSelectedProjectIdProvider);
  final accessibleProjects =
      ref.watch(userProjectsProvider).asData?.value ?? const <Project>[];

  // Recalcular quando houver mudanças de equipamento (calibração)
  ref.watch(equipmentNotificationRefreshProvider);

  final service = ref.watch(notificationServiceProvider);
  final settingsAsync = ref.watch(notificationSettingsProvider);

  // Extrair as settings do AsyncValue
  final settings = settingsAsync.maybeWhen(
    data: (settings) => settings,
    orElse: () => NotificationSettings(),
  );

  // Gerar notificações
  final notifications = await service.generateNotifications(
    user.uid,
    settings,
    selectedProjectId: selectedProjectId,
    accessibleProjects: accessibleProjects,
  );

  return notifications;
});

/// Provider de contagem de notificações
final notificationCountProvider = Provider.autoDispose<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);

  return notificationsAsync.when(
    data: (notifications) => notifications.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider de contagem por prioridade
final notificationCountByPriorityProvider =
    Provider.autoDispose<Map<NotificationPriority, int>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  final service = ref.watch(notificationServiceProvider);

  return notificationsAsync.when(
    data: (notifications) => service.countByPriority(notifications),
    loading: () => {
      NotificationPriority.critical: 0,
      NotificationPriority.warning: 0,
      NotificationPriority.info: 0,
    },
    error: (_, __) => {
      NotificationPriority.critical: 0,
      NotificationPriority.warning: 0,
      NotificationPriority.info: 0,
    },
  );
});

/// Provider de notificações críticas
final criticalNotificationsProvider =
    Provider.autoDispose<List<AppNotification>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);

  return notificationsAsync.when(
    data: (notifications) => notifications
        .where((n) => n.priority == NotificationPriority.critical)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider de notificações de aviso
final warningNotificationsProvider =
    Provider.autoDispose<List<AppNotification>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);

  return notificationsAsync.when(
    data: (notifications) => notifications
        .where((n) => n.priority == NotificationPriority.warning)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider de notificações informativas
final infoNotificationsProvider =
    Provider.autoDispose<List<AppNotification>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);

  return notificationsAsync.when(
    data: (notifications) => notifications
        .where((n) => n.priority == NotificationPriority.info)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider para verificar se há notificações críticas
final hasCriticalAlertsProvider = Provider.autoDispose<bool>((ref) {
  final counts = ref.watch(notificationCountByPriorityProvider);
  return (counts[NotificationPriority.critical] ?? 0) > 0;
});

// ============================================================================
// PROJECT PHASES (EXISTENTE)
// ============================================================================

// Service provider
final projectPhaseServiceProvider = Provider((ref) => ProjectPhaseService());

// Stream de fases do projeto selecionado
final projectPhasesProvider =
    StreamProvider.family<List<ProjectPhase>, String>((ref, projectId) {
  final phaseService = ref.watch(projectPhaseServiceProvider);
  return phaseService.getPhasesByProject(projectId);
});

// Progresso das fases do projeto
final projectPhasesProgressProvider =
    StreamProvider.family<double, String>((ref, projectId) {
  // Escuta as fases em tempo real
  final phasesAsync = ref.watch(projectPhasesProvider(projectId));

  return phasesAsync.when(
    data: (phases) {
      // Calcula % baseado nas fases atuais
      int concluidas =
          phases.where((p) => p.dataFim != null && p.aplicavel).length;
      int aplicaveis = phases.where((p) => p.aplicavel).length;
      double progress =
          aplicaveis == 0 ? 100.0 : (concluidas / aplicaveis) * 100;

      return Stream.value(progress);
    },
    loading: () => Stream.value(0.0),
    error: (_, __) => Stream.value(0.0),
  );
});

// Fase atual do projeto
final currentPhaseProvider =
    FutureProvider.family<ProjectPhase?, String>((ref, projectId) async {
  final projectId = ref.watch(selectedProjectIdProvider);
  if (projectId == null) return null;

  final phaseService = ref.watch(projectPhaseServiceProvider);
  return phaseService.getCurrentPhase(projectId);
});

// ============================================================================
// AUTH / SESSION (EXISTENTE)
// ============================================================================
// AUTH PROVIDERS - Moved to auth_providers.dart
// ============================================================================

// ============================================================================
// SERVICE PROVIDERS (EXISTENTE)
// ============================================================================

final projectServiceProvider = Provider((ref) => ProjectService());

final turbinaServiceProvider = Provider<TurbinaService>((ref) {
  return TurbinaService();
});

final componenteServiceProvider = Provider<ComponenteService>((ref) {
  return ComponenteService();
});

// ============================================================================
// PROJECT PROVIDERS (EXISTENTE)
// ============================================================================

// Stream de projetos — directores/site managers vêem todos, outros só os seus
// SUBSTITUIR o userProjectsProvider no app_providers.dart

final userProjectsProvider = StreamProvider<List<Project>>((ref) {
  ref.watch(authProvider);
  final userId = ref.watch(currentUserIdProvider);
  debugPrint('🔵 USER ID PROVIDER: $userId');

  if (userId == null) {
    debugPrint('❌ USER ID É NULL!');
    return Stream.value(<Project>[]);
  }

  final appUserAsync = ref.watch(currentAppUserProvider);
  final appUser = appUserAsync.asData?.value;
  final isGlobalAdmin = appUser?.globalRole == GlobalRole.director ||
      appUser?.globalRole == GlobalRole.siteManager;

  if (isGlobalAdmin) {
    return FirebaseFirestore.instance
        .collection('projects')
        .snapshots()
        .map((snapshot) {
      final projects =
          snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList();
      debugPrint('🟢 PROJETOS RECEBIDOS (admin): ${projects.length}');
      return projects;
    });
  }

  // Utilizadores normais — projectos criados por eles OU onde são membros
  // Usa memberIds array no documento do projecto
  return FirebaseFirestore.instance
      .collection('projects')
      .where(Filter.or(
        Filter('userId', isEqualTo: userId),
        Filter('memberIds', arrayContains: userId),
      ))
      .snapshots()
      .asyncMap((snapshot) async {
    final projects = <Project>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final ownerId = data['userId'] as String?;

      // Dono do projeto mantém acesso sempre
      if (ownerId == userId) {
        projects.add(Project.fromFirestore(doc));
        continue;
      }

      // Membro só tem acesso se ainda existir na subcoleção members
      final memberDoc =
          await doc.reference.collection('members').doc(userId).get();
      if (memberDoc.exists) {
        projects.add(Project.fromFirestore(doc));
      }
    }

    debugPrint('🟢 PROJETOS RECEBIDOS (user): ${projects.length}');
    for (var p in projects) {
      debugPrint('  - ${p.nome}');
    }
    return projects;
  });
});

// TODO: Migrar para local widget state em Riverpod 3.x
// Projeto selecionado - Riverpod 3.x annotation-based
@riverpod
class SelectedProjectId extends _$SelectedProjectId {
  @override
  String? build() => null;

  void setValue(String? id) {
    if (state == id) return;

    state = id;

    ref.invalidate(notificationsProvider);
    ref.invalidate(notificationCountProvider);
    ref.invalidate(notificationCountByPriorityProvider);
    ref.invalidate(criticalNotificationsProvider);
    ref.invalidate(warningNotificationsProvider);
    ref.invalidate(infoNotificationsProvider);
    ref.invalidate(hasCriticalAlertsProvider);
  }
}

/// ID do projeto selecionado apenas se ainda for acessível ao utilizador atual
final accessibleSelectedProjectIdProvider = Provider<String?>((ref) {
  final selectedProjectId = ref.watch(selectedProjectIdProvider);
  if (selectedProjectId == null) return null;

  final projectsAsync = ref.watch(userProjectsProvider);
  final projects = projectsAsync.asData?.value;

  // Enquanto a lista de projetos não resolve, mantém o valor atual
  if (projects == null) {
    return selectedProjectId;
  }

  final hasAccess = projects.any((project) => project.id == selectedProjectId);
  return hasAccess ? selectedProjectId : null;
});

/// Stream do projeto selecionado (sem Riverpod state providers)
final selectedProjectProvider = StreamProvider<Project?>((ref) {
  final projectId = ref.watch(accessibleSelectedProjectIdProvider);
  if (projectId == null) return Stream.value(null);

  final projectService = ref.watch(projectServiceProvider);
  return projectService.getProject(projectId);
});

// ============================================================================
// TURBINA PROVIDERS (EXISTENTE)
// ============================================================================

// Stream de turbinas do projeto selecionado
final projectTurbinasProvider = StreamProvider<List<Turbina>>((ref) {
  final projectId = ref.watch(accessibleSelectedProjectIdProvider);
  if (projectId == null) return Stream.value(<Turbina>[]);

  final turbinaService = ref.watch(turbinaServiceProvider);
  return turbinaService.getTurbinasPorProjeto(projectId);
});

// Stream de turbinas por projeto (uso direto em rotas mobile)
final projectTurbinasByProjectProvider =
    StreamProvider.family<List<Turbina>, String>((ref, projectId) {
  if (projectId.isEmpty) return Stream.value(<Turbina>[]);

  final turbinaService = ref.watch(turbinaServiceProvider);
  return turbinaService.getTurbinasPorProjeto(projectId);
});

// Turbina selecionada (Provider simples) - Riverpod 3.x annotation-based
@riverpod
class SelectedTurbinaId extends _$SelectedTurbinaId {
  @override
  String? build() => null;

  void setValue(String? id) => state = id;
}

// Stream da turbina selecionada
final selectedTurbinaProvider = StreamProvider<Turbina?>((ref) {
  final turbinaId = ref.watch(selectedTurbinaIdProvider);
  if (turbinaId == null) return Stream.value(null);

  final turbinaService = ref.watch(turbinaServiceProvider);
  return turbinaService.getTurbina(turbinaId);
});

final turbinaByIdProvider =
    StreamProvider.family<Turbina?, String>((ref, turbinaId) {
  if (turbinaId.isEmpty) return Stream.value(null);

  final turbinaService = ref.watch(turbinaServiceProvider);
  return turbinaService.getTurbina(turbinaId);
});

// ============================================================================
// COMPONENTE PROVIDERS (EXISTENTE)
// ============================================================================

// Stream de componentes da turbina selecionada
final turbinaComponentesProvider = StreamProvider<List<Componente>>((ref) {
  final turbinaId = ref.watch(selectedTurbinaIdProvider);
  if (turbinaId == null) return Stream.value(<Componente>[]);

  final componenteService = ref.watch(componenteServiceProvider);
  return componenteService.getComponentesPorTurbina(turbinaId);
});

// Stream de um componente específico
final componenteProvider =
    StreamProvider.family<Componente?, String>((ref, componenteId) {
  final componenteService = ref.watch(componenteServiceProvider);
  return componenteService.getComponente(componenteId);
});

// ============================================================================
// STATISTICS PROVIDERS (EXISTENTE)
// ============================================================================

// Provider para estatísticas do projeto
final projectStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final projectId = ref.watch(accessibleSelectedProjectIdProvider);
  if (projectId == null) return {};

  final turbinas = await ref.watch(projectTurbinasProvider.future);

  int totalTurbinas = turbinas.length;
  int planejadas = 0;
  int emInstalacao = 0;
  int instaladas = 0;
  int comissionadas = 0;
  double progressoTotal = 0;

  for (var turbina in turbinas) {
    progressoTotal += turbina.progresso;

    switch (turbina.status) {
      case 'Planejada':
        planejadas++;
        break;
      case 'Em Instalação':
        emInstalacao++;
        break;
      case 'Instalada':
        instaladas++;
        break;
      case 'Comissionada':
        comissionadas++;
        break;
    }
  }

  return {
    'totalTurbinas': totalTurbinas,
    'planejadas': planejadas,
    'emInstalacao': emInstalacao,
    'instaladas': instaladas,
    'comissionadas': comissionadas,
    'progressoMedio': totalTurbinas > 0 ? progressoTotal / totalTurbinas : 0.0,
  };

  // ═══════════════════════════════════════════════════════
// INSTALAÇÃO - PROVIDERS
// ═══════════════════════════════════════════════════════

// Fase Componente Service (criar depois)
// final faseComponenteServiceProvider = Provider((ref) {
//   return FaseComponenteService();
// });

// Trabalho Ligação Service (criar depois)
// final trabalhoLigacaoServiceProvider = Provider((ref) {
//   return TrabalhoLigacaoService();
// });

// ... (resto dos providers dos services)
});
