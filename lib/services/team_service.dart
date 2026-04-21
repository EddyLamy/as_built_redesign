// lib/services/team_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';

class TeamService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Paths helper ─────────────────────────────────────────────────────────

  CollectionReference _categoriesRef(String projectId) =>
      _db.collection('projects').doc(projectId).collection('team_categories');

  CollectionReference _companiesRef(String projectId, String categoryId) =>
      _categoriesRef(projectId).doc(categoryId).collection('companies');

  CollectionReference _peopleRef(
          String projectId, String categoryId, String companyId) =>
      _companiesRef(projectId, categoryId).doc(companyId).collection('people');

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIAS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Inicializa as categorias por defeito quando o projeto é criado
  Future<void> initDefaultCategories(String projectId) async {
    final existing = await _categoriesRef(projectId).limit(1).get();
    if (existing.docs.isNotEmpty) return; // já inicializado

    final batch = _db.batch();
    for (final cat in TeamCategory.defaults) {
      batch.set(_categoriesRef(projectId).doc(cat.id), cat.toMap());
    }
    await batch.commit();
  }

  /// Stream de categorias (sem empresas carregadas)
  Stream<List<TeamCategory>> getCategoriesStream(String projectId) {
    return _categoriesRef(projectId).orderBy('order').snapshots().map((snap) =>
        snap.docs
            .map((d) => TeamCategory.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  /// Adicionar categoria personalizada
  Future<void> addCategory(String projectId, TeamCategory category) async {
    await _categoriesRef(projectId).doc(category.id).set(category.toMap());
  }

  /// Atualizar categoria
  Future<void> updateCategory(String projectId, TeamCategory category) async {
    await _categoriesRef(projectId).doc(category.id).update(category.toMap());
  }

  /// Eliminar categoria (só se não for default e não tiver empresas)
  Future<void> deleteCategory(String projectId, String categoryId) async {
    final companies = await _companiesRef(projectId, categoryId).limit(1).get();
    if (companies.docs.isNotEmpty) {
      throw Exception(
          'Não é possível eliminar uma categoria com empresas. Remove as empresas primeiro.');
    }
    await _categoriesRef(projectId).doc(categoryId).delete();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMPRESAS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Stream de empresas de uma categoria
  Stream<List<Company>> getCompaniesStream(
      String projectId, String categoryId) {
    return _companiesRef(projectId, categoryId).orderBy('name').snapshots().map(
        (snap) => snap.docs
            .map((d) => Company.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  /// Adicionar empresa
  Future<void> addCompany(
      String projectId, String categoryId, Company company) async {
    await _companiesRef(projectId, categoryId)
        .doc(company.id)
        .set(company.toMap());
  }

  /// Atualizar empresa
  Future<void> updateCompany(
      String projectId, String categoryId, Company company) async {
    await _companiesRef(projectId, categoryId)
        .doc(company.id)
        .update(company.toMap());
  }

  /// Eliminar empresa (e todas as pessoas)
  Future<void> deleteCompany(
      String projectId, String categoryId, String companyId) async {
    // Apagar pessoas primeiro
    final people = await _peopleRef(projectId, categoryId, companyId).get();
    final batch = _db.batch();
    for (final p in people.docs) {
      batch.delete(p.reference);
    }
    batch.delete(_companiesRef(projectId, categoryId).doc(companyId));
    await batch.commit();
  }

  /// Gerar ID único para empresa
  String generateCompanyId() =>
      _db.collection('_').doc().id; // usa o gerador do Firestore

  // ═══════════════════════════════════════════════════════════════════════════
  // PESSOAS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Stream de pessoas de uma empresa
  Stream<List<CompanyPerson>> getPeopleStream(
      String projectId, String categoryId, String companyId) {
    return _peopleRef(projectId, categoryId, companyId)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CompanyPerson.fromMap(d.data() as Map<String, dynamic>))
            .toList());
  }

  /// Adicionar pessoa
  Future<void> addPerson(String projectId, String categoryId, String companyId,
      CompanyPerson person) async {
    await _peopleRef(projectId, categoryId, companyId)
        .doc(person.id)
        .set(person.toMap());
  }

  /// Atualizar pessoa
  Future<void> updatePerson(String projectId, String categoryId,
      String companyId, CompanyPerson person) async {
    await _peopleRef(projectId, categoryId, companyId)
        .doc(person.id)
        .update(person.toMap());
  }

  /// Eliminar pessoa
  Future<void> deletePerson(String projectId, String categoryId,
      String companyId, String personId) async {
    await _peopleRef(projectId, categoryId, companyId).doc(personId).delete();
  }

  /// Gerar ID único para pessoa
  String generatePersonId() => _db.collection('_').doc().id;

  /// Gerar ID único para categoria
  String generateCategoryId() => _db.collection('_').doc().id;

  /// Conta o número total de pessoas numa categoria
  Future<int> countPeopleInCategory(String projectId, String categoryId) async {
    final companies = await _companiesRef(projectId, categoryId).get();

    var total = 0;
    for (final companyDoc in companies.docs) {
      final people = await companyDoc.reference.collection('people').get();
      total += people.docs.length;
    }

    return total;
  }
}
