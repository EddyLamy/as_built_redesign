import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

/// User ID atual
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.uid;
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
