// lib/models/team.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Pessoa dentro de uma empresa ─────────────────────────────────────────────

class CompanyPerson {
  final String id;
  final String name;
  final String? jobRole;
  final String? phone;
  final String? email;
  final String? notes;

  CompanyPerson({
    required this.id,
    required this.name,
    this.jobRole,
    this.phone,
    this.email,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'jobRole': jobRole,
        'phone': phone,
        'email': email,
        'notes': notes,
      };

  factory CompanyPerson.fromMap(Map<String, dynamic> map) => CompanyPerson(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        jobRole: map['jobRole'],
        phone: map['phone'],
        email: map['email'],
        notes: map['notes'],
      );

  CompanyPerson copyWith({
    String? name,
    String? jobRole,
    String? phone,
    String? email,
    String? notes,
  }) =>
      CompanyPerson(
        id: id,
        name: name ?? this.name,
        jobRole: jobRole ?? this.jobRole,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        notes: notes ?? this.notes,
      );
}

// ─── Empresa ───────────────────────────────────────────────────────────────────

class Company {
  final String id;
  final String name;
  final String? contact;
  final String? phone;
  final String? email;
  final String? notes;
  final List<CompanyPerson> people;
  final DateTime createdAt;

  Company({
    required this.id,
    required this.name,
    this.contact,
    this.phone,
    this.email,
    this.notes,
    this.people = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'contact': contact,
        'phone': phone,
        'email': email,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Company.fromMap(Map<String, dynamic> map,
          {List<CompanyPerson> people = const []}) =>
      Company(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        contact: map['contact'],
        phone: map['phone'],
        email: map['email'],
        notes: map['notes'],
        people: people,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Company copyWith({
    String? name,
    String? contact,
    String? phone,
    String? email,
    String? notes,
    List<CompanyPerson>? people,
  }) =>
      Company(
        id: id,
        name: name ?? this.name,
        contact: contact ?? this.contact,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        notes: notes ?? this.notes,
        people: people ?? this.people,
        createdAt: createdAt,
      );
}

// ─── Categoria de equipa ───────────────────────────────────────────────────────

class TeamCategory {
  final String id;
  final String name;
  final String emoji;
  final int colorValue;
  final int order;
  final bool isDefault;
  final List<Company> companies;

  TeamCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
    required this.order,
    this.isDefault = false,
    this.companies = const [],
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'colorValue': colorValue,
        'order': order,
        'isDefault': isDefault,
      };

  factory TeamCategory.fromMap(Map<String, dynamic> map,
          {List<Company> companies = const []}) =>
      TeamCategory(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        emoji: map['emoji'] ?? '🏢',
        colorValue: map['colorValue'] ?? 0xFF607D8B,
        order: map['order'] ?? 99,
        isDefault: map['isDefault'] ?? false,
        companies: companies,
      );

  static List<TeamCategory> get defaults => [
        TeamCategory(
            id: 'civil',
            name: 'Civil',
            emoji: '🏗️',
            colorValue: 0xFFFF9800,
            order: 0,
            isDefault: true),
        TeamCategory(
            id: 'electrical',
            name: 'Elétrica',
            emoji: '⚡',
            colorValue: 0xFFE53935,
            order: 1,
            isDefault: true),
        TeamCategory(
            id: 'turbine_assembly',
            name: 'Montagem Turbinas',
            emoji: '🌀',
            colorValue: 0xFF1976D2,
            order: 2,
            isDefault: true),
        TeamCategory(
            id: 'cranes',
            name: 'Gruas',
            emoji: '🏗️',
            colorValue: 0xFF00897B,
            order: 3,
            isDefault: true),
        TeamCategory(
            id: 'transport',
            name: 'Transporte',
            emoji: '🚛',
            colorValue: 0xFF43A047,
            order: 4,
            isDefault: true),
        TeamCategory(
            id: 'commissioning',
            name: 'Comissionamento',
            emoji: '✅',
            colorValue: 0xFF8E24AA,
            order: 5,
            isDefault: true),
      ];
}
