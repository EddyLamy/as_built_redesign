import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_providers.g.dart';

// ══════════════════════════════════════════════════════════════════════════
// AUTH PROVIDERS - Firebase Authentication
// ══════════════════════════════════════════════════════════════════════════

/// Stream do estado de autenticação (recomendado)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// User atual (síncrono)
final currentUserProvider = Provider<User?>((ref) {
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
  final restUserId = ref.watch(userSessionProvider);
  final firebaseUser = FirebaseAuth.instance.currentUser;
  return restUserId ?? firebaseUser?.uid;
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
