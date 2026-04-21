// lib/models/app_user.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Roles Globais (quem é a pessoa na empresa) ────────────────────────────────
enum GlobalRole {
  director('director', 'Director'),
  siteManager('site_manager', 'Site Manager'),
  user('user', 'Utilizador');

  const GlobalRole(this.value, this.label);
  final String value;
  final String label;

  static GlobalRole fromString(String value) {
    return GlobalRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GlobalRole.user,
    );
  }

  /// Directors e Site Managers podem criar projetos e gerir a app globalmente
  bool get isAdmin =>
      this == GlobalRole.director || this == GlobalRole.siteManager;
}

// ─── Roles por Projeto (o que pode fazer neste projeto) ────────────────────────
enum ProjectRole {
  projectManager('project_manager', 'Project Manager'),
  siteSupervisor('site_supervisor', 'Site Supervisor'),
  visitor('visitor', 'Visitante');

  const ProjectRole(this.value, this.label);
  final String value;
  final String label;

  static ProjectRole fromString(String value) {
    return ProjectRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProjectRole.visitor,
    );
  }
}

// ─── Membro de um projeto ──────────────────────────────────────────────────────
class ProjectMember {
  final String uid;
  final String name;
  final String email;
  final String? company;
  final ProjectRole projectRole;
  final bool canGenerateReports;
  final String addedBy;
  final DateTime addedAt;

  ProjectMember({
    required this.uid,
    required this.name,
    required this.email,
    this.company,
    required this.projectRole,
    this.canGenerateReports = true,
    required this.addedBy,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'company': company,
        'projectRole': projectRole.value,
        'canGenerateReports': canGenerateReports,
        'addedBy': addedBy,
        'addedAt': Timestamp.fromDate(addedAt),
      };

  factory ProjectMember.fromMap(Map<String, dynamic> map) => ProjectMember(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        company: map['company'],
        projectRole: ProjectRole.fromString(map['projectRole'] ?? ''),
        canGenerateReports: map['canGenerateReports'] ?? true,
        addedBy: map['addedBy'] ?? '',
        addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  ProjectMember copyWith({
    ProjectRole? projectRole,
    String? company,
    bool? canGenerateReports,
  }) =>
      ProjectMember(
        uid: uid,
        name: name,
        email: email,
        company: company ?? this.company,
        projectRole: projectRole ?? this.projectRole,
        canGenerateReports: canGenerateReports ?? this.canGenerateReports,
        addedBy: addedBy,
        addedAt: addedAt,
      );
}

// ─── Utilizador da app ─────────────────────────────────────────────────────────
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? company;
  final String? phone;
  final GlobalRole globalRole;
  final bool isActive;
  final DateTime createdAt;
  final String? createdBy;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.company,
    this.phone,
    required this.globalRole,
    this.isActive = true,
    required this.createdAt,
    this.createdBy,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'company': company,
        'phone': phone,
        'globalRole': globalRole.value,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        company: map['company'],
        phone: map['phone'],
        globalRole: GlobalRole.fromString(map['globalRole'] ?? ''),
        isActive: map['isActive'] ?? true,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdBy: map['createdBy'],
      );

  AppUser copyWith({
    String? name,
    String? company,
    String? phone,
    GlobalRole? globalRole,
    bool? isActive,
  }) =>
      AppUser(
        uid: uid,
        name: name ?? this.name,
        email: email,
        company: company ?? this.company,
        phone: phone ?? this.phone,
        globalRole: globalRole ?? this.globalRole,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        createdBy: createdBy,
      );
}
