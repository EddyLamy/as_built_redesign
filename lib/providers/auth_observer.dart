import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'equipment_provider.dart';
import 'auth_providers.dart';
import 'app_providers.dart';
// ✅ NOVO: providers de permissões e equipa
import 'permission_provider.dart';
import 'team_provider.dart';
import 'documentation_provider.dart';

final class AuthStateObserver extends ProviderObserver {
  String? _previousUserId;

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    final container = context.container;
    final provider = context.provider;

    if (provider != authProvider) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;
    final userChanged = _previousUserId != currentUserId;

    if (!userChanged) {
      return;
    }

    if (_previousUserId == null && currentUserId != null) {
      debugPrint('✅ LOGIN: ${currentUser?.email ?? currentUserId}');
    } else if (_previousUserId != null && currentUserId == null) {
      debugPrint('🔴 LOGOUT: $_previousUserId');
    } else if (_previousUserId != null && currentUserId != null) {
      debugPrint('🔄 TROCA: $_previousUserId → $currentUserId');
    }

    _syncUserSession(container, currentUserId);
    _resetUserScopedState(container);

    _previousUserId = currentUserId;
  }

  void _syncUserSession(ProviderContainer container, String? userId) {
    try {
      container.read(userSessionProvider.notifier).setUserId(userId);
    } catch (_) {}
  }

  void _resetUserScopedState(ProviderContainer container) {
    debugPrint('🧹 A limpar estado de utilizador...');

    _resetSelectionState(container);

    // ── Projeto e turbinas ─────────────────────────────────────────────────
    _invalidateSafe(container, userProjectsProvider);
    _invalidateSafe(container, selectedProjectProvider);
    _invalidateSafe(container, projectTurbinasProvider);
    _invalidateSafe(container, selectedTurbinaProvider);
    _invalidateSafe(container, turbinaComponentesProvider);
    _invalidateSafe(container, projectStatisticsProvider);

    // ── Equipamento ────────────────────────────────────────────────────────
    _invalidateSafe(container, equipmentStreamProvider);
    _invalidateSafe(container, calibrationAlertsProvider);
    _invalidateSafe(container, equipmentFiltersProvider);
    _invalidateSafe(container, filteredEquipmentProvider);
    _invalidateSafe(container, groupedEquipmentProvider);

    // ── Notificações ───────────────────────────────────────────────────────
    _invalidateSafe(container, notificationsProvider);
    _invalidateSafe(container, notificationCountProvider);
    _invalidateSafe(container, notificationCountByPriorityProvider);
    _invalidateSafe(container, criticalNotificationsProvider);
    _invalidateSafe(container, warningNotificationsProvider);
    _invalidateSafe(container, infoNotificationsProvider);
    _invalidateSafe(container, hasCriticalAlertsProvider);

    // ── Auth / User ────────────────────────────────────────────────────────
    _invalidateSafe(container, currentUserProvider);
    _invalidateSafe(container, currentUserIdProvider);
    _invalidateSafe(container, currentUserEmailProvider);
    _invalidateSafe(container, currentUserDisplayNameProvider);

    // ── ✅ NOVO: Permissões ────────────────────────────────────────────────
    // NOTA: currentAppUserProvider NÃO é invalidado aqui porque já ouve
    // authStateChanges() directamente e se actualiza sozinho.
    // Invalidá-lo causava uma race condition que impedia o AppUser de carregar.
    _invalidateSafe(container, allUsersProvider);
    // permissionProvider e projectMemberProvider são .family — o invalidate
    // global limpa todas as instâncias em cache
    _invalidateSafe(container, permissionProvider);
    _invalidateSafe(container, projectMemberProvider);
    _invalidateSafe(container, projectMembersListProvider);

    // ── ✅ NOVO: Equipa (team) ─────────────────────────────────────────────
    // São todos .family — limpa todas as instâncias em cache
    _invalidateSafe(container, teamCategoriesProvider);
    _invalidateSafe(container, companiesProvider);
    _invalidateSafe(container, peopleProvider);

    // ── ✅ NOVO: Documentação ─────────────────────────────────────────────
    _invalidateSafe(container, documentationStreamProvider);
    _invalidateSafe(container,
        docFilterProvider); // gerado como docFilterProvider pelo build_runner
    _invalidateSafe(container, filteredDocumentsProvider);
    _invalidateSafe(container, groupedDocumentsProvider);
    _invalidateSafe(container, allTagsProvider);

    debugPrint('✅ Limpeza concluída!');
  }

  void _resetSelectionState(ProviderContainer container) {
    try {
      container.read(selectedProjectIdProvider.notifier).setValue(null);
    } catch (_) {}

    try {
      container.read(selectedTurbinaIdProvider.notifier).setValue(null);
    } catch (_) {}
  }

  void _invalidateSafe(ProviderContainer container, dynamic provider) {
    try {
      container.invalidate(provider);
      debugPrint('  ✓ ${provider.name ?? provider.runtimeType} limpo');
    } catch (_) {}
  }
}
