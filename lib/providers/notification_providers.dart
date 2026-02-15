import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';

/// Provider do Service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider das Configurações (FutureProvider - Riverpod 3.x compatible)
final notificationSettingsProvider =
    FutureProvider<NotificationSettings>((ref) async {
  return await NotificationSettings.load();
});

/// Provider das Notificações (auto-refresh)
final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final service = ref.watch(notificationServiceProvider);
  final settingsAsync = ref.watch(notificationSettingsProvider);

  // Extrair as settings do AsyncValue
  final settings = settingsAsync.maybeWhen(
    data: (settings) => settings,
    orElse: () => NotificationSettings(),
  );

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
