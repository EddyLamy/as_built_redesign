import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';

/// Provider do Service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider das Configurações (StateNotifier)
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
