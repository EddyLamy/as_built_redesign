import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserService {
  static String? getCurrentUserId(WidgetRef ref) {
    // Prioridade: REST session → SDK user → null
    final sessionUserId = ref.read(userSessionProvider);
    return sessionUserId ?? FirebaseAuth.instance.currentUser?.uid;
  }
}
