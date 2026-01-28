import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/project.dart';
import '../models/turbina.dart';
import '../models/componente.dart';
import '../models/project_phase.dart';

import '../services/project_service.dart';
import '../services/turbina_service.dart';
import '../services/componente_service.dart';
import '../services/project_phase_service.dart';

// ============================================================================
// 🔔 NOTIFICATION SYSTEM - NOVO
// ============================================================================
import '../services/notification_service.dart';
import '../models/notification.dart';
import '../models/notification_settings.dart';

// Service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Provider das Configurações (StateNotifier)
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
}

/// Provider do StateNotifier
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  return NotificationSettingsNotifier();
});

/// Provider das Notificações (auto-refresh)
final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final service = ref.watch(notificationServiceProvider);
  final settings = ref.watch(notificationSettingsProvider);

  // Gerar notificações
  final notifications = await service.generateNotifications(user.uid, settings);

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

// AUTH STREAM (Firebase SDK)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider de user atual (SDK apenas)
final currentUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

// Guarda apenas o userId vindo do REST (String) – porque não existe class UserSession no projeto
final userSessionProvider = StateProvider<String?>((ref) => null);

// USER ID UNIFICADO (REST ou SDK) - ÚNICO
final currentUserIdProvider = Provider<String?>((ref) {
  final restUserId = ref.watch(userSessionProvider);
  final firebaseUser = FirebaseAuth.instance.currentUser;
  return restUserId ?? firebaseUser?.uid;
});

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

// Stream de projetos do usuário atual
final userProjectsProvider = StreamProvider<List<Project>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  print('🔵 USER ID PROVIDER: $userId');

  if (userId == null) {
    print('❌ USER ID É NULL!');
    return Stream.value(<Project>[]);
  }

  final projectService = ref.watch(projectServiceProvider);

  return projectService.getProjects(userId).map((projects) {
    print('🟢 PROJETOS RECEBIDOS: ${projects.length}');
    for (var p in projects) {
      print('  - ${p.nome} (userId: ${p.userId})');
    }
    return projects;
  });
});

// Projeto selecionado (StateProvider)
final selectedProjectIdProvider = StateProvider<String?>((ref) => null);

// Stream do projeto selecionado
final selectedProjectProvider = StreamProvider<Project?>((ref) {
  final projectId = ref.watch(selectedProjectIdProvider);
  if (projectId == null) return Stream.value(null);

  final projectService = ref.watch(projectServiceProvider);
  return projectService.getProject(projectId);
});

// ============================================================================
// TURBINA PROVIDERS (EXISTENTE)
// ============================================================================

// Stream de turbinas do projeto selecionado
final projectTurbinasProvider = StreamProvider<List<Turbina>>((ref) {
  final projectId = ref.watch(selectedProjectIdProvider);
  if (projectId == null) return Stream.value(<Turbina>[]);

  final turbinaService = ref.watch(turbinaServiceProvider);
  return turbinaService.getTurbinasPorProjeto(projectId);
});

// Turbina selecionada (StateProvider)
final selectedTurbinaIdProvider = StateProvider<String?>((ref) => null);

// Stream da turbina selecionada
final selectedTurbinaProvider = StreamProvider<Turbina?>((ref) {
  final turbinaId = ref.watch(selectedTurbinaIdProvider);
  if (turbinaId == null) return Stream.value(null);

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
  final projectId = ref.watch(selectedProjectIdProvider);
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
