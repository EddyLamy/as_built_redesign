// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Criar utilizador (admin cria conta e dá credenciais) ─────────────────
  // NOTA: Firebase não permite criar utilizadores sem fazer logout do current user
  // A solução correcta é usar Firebase Admin SDK via Cloud Functions.
  // Por agora, guardamos o registo no Firestore e o utilizador faz login
  // na primeira vez com as credenciais fornecidas.
  //
  // Alternativa sem Cloud Functions: o utilizador regista-se com email/password
  // e o admin aprova/atribui o role no Firestore.

  /// Guarda o perfil do utilizador no Firestore após registo
  Future<void> saveUserProfile(AppUser user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  /// Atualizar role ou dados de um utilizador
  Future<void> updateUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  /// Desativar utilizador (não apaga, apenas marca isActive: false)
  Future<void> deactivateUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({'isActive': false});
  }

  /// Reativar utilizador
  Future<void> reactivateUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({'isActive': true});
  }

  /// Buscar utilizador por uid
  Future<AppUser?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }

  /// Buscar utilizador por email
  Future<AppUser?> getUserByEmail(String email) async {
    final snap = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return AppUser.fromMap(snap.docs.first.data());
  }

  // ─── Gestão de membros do projeto ─────────────────────────────────────────

  /// Adicionar membro ao projeto
  Future<void> addMemberToProject({
    required String projectId,
    required ProjectMember member,
  }) async {
    // 1. Criar documento na subcoleção members
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('members')
        .doc(member.uid)
        .set(member.toMap());

    // 2. Adicionar uid ao array memberIds do projecto (para queries rápidas)
    await _firestore.collection('projects').doc(projectId).update({
      'memberIds': FieldValue.arrayUnion([member.uid]),
    });
  }

  /// Atualizar role de um membro no projeto
  Future<void> updateMemberRole({
    required String projectId,
    required String uid,
    required ProjectRole newRole,
    bool? canGenerateReports,
  }) async {
    final updates = <String, dynamic>{'projectRole': newRole.value};
    if (canGenerateReports != null) {
      updates['canGenerateReports'] = canGenerateReports;
    }
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('members')
        .doc(uid)
        .update(updates);
  }

  /// Remover membro do projeto
  Future<void> removeMemberFromProject({
    required String projectId,
    required String uid,
  }) async {
    final projectRef = _firestore.collection('projects').doc(projectId);
    final memberRef = projectRef.collection('members').doc(uid);

    final projectSnap = await projectRef.get();
    final projectData = projectSnap.data();

    final ownerId =
        (projectData?['userId'] ?? projectData?['createdBy']) as String?;
    if (ownerId != null && ownerId == uid) {
      throw Exception('Não é permitido remover o dono do projeto.');
    }

    await memberRef.delete();

    final currentMemberIdsRaw = projectData?['memberIds'];
    final currentMemberIds = currentMemberIdsRaw is List
        ? currentMemberIdsRaw.map((e) => e.toString()).toList()
        : <String>[];

    if (currentMemberIds.contains(uid)) {
      final updatedMemberIds =
          currentMemberIds.where((memberId) => memberId != uid).toList();
      await projectRef.set(
        {'memberIds': updatedMemberIds},
        SetOptions(merge: true),
      );
    }
  }

  /// Criar perfil no primeiro login (se não existir)
  Future<void> ensureUserProfile(User firebaseUser) async {
    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (!doc.exists) {
      final newUser = AppUser(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? firebaseUser.email ?? 'Utilizador',
        email: firebaseUser.email ?? '',
        globalRole: GlobalRole.user, // role mínimo por defeito
        createdAt: DateTime.now(),
      );
      await saveUserProfile(newUser);
    }
  }
}
