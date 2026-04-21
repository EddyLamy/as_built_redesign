// lib/providers/permission_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';

// ─── AppUser atual (carregado do Firestore) ────────────────────────────────────

final currentAppUserProvider = StreamProvider<AppUser?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncExpand((firebaseUser) {
    if (firebaseUser == null) {
      debugPrint('👤 currentAppUserProvider: firebaseUser é null');
      return Stream.value(null);
    }

    debugPrint('👤 currentAppUserProvider: a buscar users/${firebaseUser.uid}');

    return FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .snapshots()
        .map((doc) {
      debugPrint('👤 doc.exists: ${doc.exists}');
      debugPrint('👤 doc.data: ${doc.data()}');
      if (!doc.exists) return null;
      try {
        final user = AppUser.fromMap(doc.data()!);
        debugPrint('👤 AppUser carregado: ${user.name} / ${user.globalRole}');
        return user;
      } catch (e) {
        debugPrint('👤 ERRO em AppUser.fromMap: $e');
        return null;
      }
    });
  });
});

// ─── Project Role do utilizador atual num projeto específico ──────────────────

final projectMemberProvider =
    StreamProvider.family<ProjectMember?, String>((ref, projectId) {
  return FirebaseAuth.instance.authStateChanges().asyncExpand((firebaseUser) {
    if (firebaseUser == null) return Stream.value(null);

    return FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .collection('members')
        .doc(firebaseUser.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return ProjectMember.fromMap(doc.data()!);
    });
  });
});

// ─── Provider de permissões resolvidas ────────────────────────────────────────
// Este é o provider que usas em toda a app para verificar permissões

class PermissionNotifier {
  final AppUser? appUser;
  final ProjectMember? projectMember;
  final bool isLoading; // ✅ true enquanto o appUser ainda não carregou

  PermissionNotifier({
    this.appUser,
    this.projectMember,
    this.isLoading = false,
  });

  // ── Checks globais ──────────────────────────────────────────────────────────

  bool get isDirector => appUser?.globalRole == GlobalRole.director;

  bool get isSiteManager => appUser?.globalRole == GlobalRole.siteManager;

  bool get isGlobalAdmin => isDirector || isSiteManager;

  bool get isAuthenticated => appUser != null;

  // ── Checks no projeto atual ─────────────────────────────────────────────────

  bool get isProjectManager =>
      isGlobalAdmin || projectMember?.projectRole == ProjectRole.projectManager;

  bool get isSiteSupervisor =>
      isGlobalAdmin ||
      projectMember?.projectRole == ProjectRole.projectManager ||
      projectMember?.projectRole == ProjectRole.siteSupervisor;

  bool get isVisitor => projectMember?.projectRole == ProjectRole.visitor;

  bool get hasSomeProjectAccess => isGlobalAdmin || projectMember != null;

  // ── Permissões de ação ──────────────────────────────────────────────────────

  /// Criar, editar, apagar projetos
  bool get canManageProjects => isGlobalAdmin || isProjectManager;

  /// Gerir equipa do projeto (convidar, alterar roles)
  bool get canManageTeam => isGlobalAdmin || isProjectManager;

  /// Criar/editar/apagar equipamento e documentação
  bool get canManageEquipmentAndDocs => isSiteSupervisor;

  /// Criar/editar/apagar dados de instalação
  bool get canManageInstallation => isSiteSupervisor;

  /// Ver As-Built e dados do projeto
  bool get canViewProject => hasSomeProjectAccess;

  /// Gerar relatórios
  bool get canGenerateReports =>
      hasSomeProjectAccess && (projectMember?.canGenerateReports ?? true);

  /// Criar utilizadores na app
  bool get canCreateUsers => isGlobalAdmin;
}

/// Provider que recebe um projectId e devolve as permissões resolvidas
final permissionProvider =
    Provider.family<PermissionNotifier, String?>((ref, projectId) {
  final appUserAsync = ref.watch(currentAppUserProvider);

  // ✅ Enquanto o stream do utilizador ainda não resolveu, isLoading = true
  if (appUserAsync.isLoading) {
    return PermissionNotifier(isLoading: true);
  }

  final appUser = appUserAsync.asData?.value;

  ProjectMember? member;
  if (projectId != null && projectId.isNotEmpty) {
    final memberAsync = ref.watch(projectMemberProvider(projectId));

    if (memberAsync.isLoading) {
      return PermissionNotifier(appUser: appUser, isLoading: true);
    }

    member = memberAsync.asData?.value;
  }

  return PermissionNotifier(appUser: appUser, projectMember: member);
});

/// Provider sem projeto (para verificações globais)
final globalPermissionProvider = Provider<PermissionNotifier>((ref) {
  final appUserAsync = ref.watch(currentAppUserProvider);

  if (appUserAsync.isLoading) {
    return PermissionNotifier(isLoading: true);
  }

  return PermissionNotifier(appUser: appUserAsync.asData?.value);
});

// ─── Lista de todos os utilizadores (para o admin) ────────────────────────────

final allUsersProvider = StreamProvider<List<AppUser>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs.map((d) => AppUser.fromMap(d.data())).toList());
});

// ─── Membros de um projeto ─────────────────────────────────────────────────────

final projectMembersListProvider =
    StreamProvider.family<List<ProjectMember>, String>((ref, projectId) {
  return FirebaseFirestore.instance
      .collection('projects')
      .doc(projectId)
      .collection('members')
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => ProjectMember.fromMap(d.data())).toList());
});
