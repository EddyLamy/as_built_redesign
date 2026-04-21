import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_providers.g.dart';

// ══════════════════════════════════════════════════════════════════════════
// AUTH PROVIDERS - Firebase Authentication
// ══════════════════════════════════════════════════════════════════════════

/// Stream do estado de autenticação (padrão recomendado)
final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Alias para compatibilidade com código existente
final authStateProvider = authProvider;

/// User atual (SÍNCRONO - acesso direto ao FirebaseAuth)
/// IMPORTANTE: Este provider retorna SEMPRE o estado atual sem depender de streams
final currentUserProvider = Provider<User?>((ref) {
  // Força refresh quando authProvider muda
  ref.watch(authProvider);
  // Retorna SEMPRE o valor atual (síncrono)
  return FirebaseAuth.instance.currentUser;
});

/// Guarda apenas o userId vindo do REST (String) – porque não existe class UserSession no projeto
@riverpod
class UserSession extends _$UserSession {
  @override
  String? build() => null;

  void setUserId(String? id) => state = id;
}

/// User ID atual
final currentUserIdProvider = Provider<String?>((ref) {
  final authUser = ref.watch(authProvider).maybeWhen(
        data: (user) => user,
        orElse: () => null,
      );
  final restUserId = ref.watch(userSessionProvider);

  if (authUser != null) {
    return authUser.uid;
  }

  return restUserId;
});

/// User está autenticado?
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// User email
final currentUserEmailProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.email;
});

/// User display name
final currentUserDisplayNameProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.displayName;
});
