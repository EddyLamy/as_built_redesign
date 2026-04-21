import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de todos os projetos do usuário
  Stream<List<Project>> getProjects(String userId) {
    return _firestore
        .collection('projects')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromFirestore(doc)) // Mais seguro
            .toList());
  }

  // Stream de um projeto específico
  Stream<Project?> getProject(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .snapshots()
        .map((doc) => doc.exists ? Project.fromFirestore(doc) : null);
  }

  // Criar novo projeto
  Future<String> createProject(Project project) async {
    // Garante que o toMap() inclua todos os campos novos (morada, coordenadas, etc)
    final docRef = await _firestore.collection('projects').add(project.toMap());
    return docRef.id;
  }

  // Atualizar projeto
  Future<void> updateProject(
      String projectId, Map<String, dynamic> data) async {
    await _firestore.collection('projects').doc(projectId).update(data);
  }

  // Deletar projeto
  Future<void> deleteProject(String projectId) async {
    final projectRef = _firestore.collection('projects').doc(projectId);

    final turbinasSnapshot = await _firestore
        .collection('turbinas')
        .where('projectId', isEqualTo: projectId)
        .get();

    final turbinaIds = turbinasSnapshot.docs.map((doc) => doc.id).toList();

    for (final turbinaId in turbinaIds) {
      await _deleteByQuery(
        _firestore
            .collection('installation_data')
            .doc(turbinaId)
            .collection('components'),
      );

      await _firestore.collection('installation_data').doc(turbinaId).delete();

      await _deleteByQuery(
        _firestore
            .collection('turbinas')
            .doc(turbinaId)
            .collection('logistica_gruas'),
      );
    }

    for (final turbinaId in turbinaIds) {
      await _deleteByQuery(
        _firestore
            .collection('fases_componente')
            .where('turbinaId', isEqualTo: turbinaId),
      );
      await _deleteByQuery(
        _firestore
            .collection('trabalhos_ligacao')
            .where('turbinaId', isEqualTo: turbinaId),
      );
      await _deleteByQuery(
        _firestore
            .collection('trabalhos_drivetrain')
            .where('turbinaId', isEqualTo: turbinaId),
      );
      await _deleteByQuery(
        _firestore
            .collection('checkpoints_gerais')
            .where('turbinaId', isEqualTo: turbinaId),
      );
      await _deleteByQuery(
        _firestore
            .collection('torque_tensioning')
            .where('turbinaId', isEqualTo: turbinaId),
      );
    }

    await _deleteByQuery(
      _firestore
          .collection('componentes')
          .where('projectId', isEqualTo: projectId),
    );
    await _deleteByQuery(
      _firestore
          .collection('torque_tensioning')
          .where('projectId', isEqualTo: projectId),
    );
    await _deleteByQuery(
      _firestore
          .collection('documentation')
          .where('projectId', isEqualTo: projectId),
    );
    await _deleteByQuery(
      _firestore
          .collection('equipment')
          .where('projectId', isEqualTo: projectId),
    );
    await _deleteByQuery(
      _firestore
          .collection('turbinas')
          .where('projectId', isEqualTo: projectId),
    );

    await _deleteByQuery(projectRef.collection('phases'));
    await _deleteByQuery(projectRef.collection('members'));

    final gruasGerais = await projectRef.collection('gruas_gerais').get();
    for (final gruaDoc in gruasGerais.docs) {
      await _deleteByQuery(gruaDoc.reference.collection('atividades'));
    }
    await _deleteByQuery(projectRef.collection('gruas_gerais'));

    final teamCategories = await projectRef.collection('team_categories').get();
    for (final categoryDoc in teamCategories.docs) {
      final companies =
          await categoryDoc.reference.collection('companies').get();
      for (final companyDoc in companies.docs) {
        await _deleteByQuery(companyDoc.reference.collection('people'));
      }
      await _deleteByQuery(categoryDoc.reference.collection('companies'));
    }
    await _deleteByQuery(projectRef.collection('team_categories'));

    final projectTurbinas = await projectRef.collection('turbinas').get();
    for (final turbinaDoc in projectTurbinas.docs) {
      await _deleteByQuery(turbinaDoc.reference.collection('componentes'));
    }
    await _deleteByQuery(projectRef.collection('turbinas'));

    await projectRef.delete();
  }

  Future<void> _deleteByQuery(
    Query<Map<String, dynamic>> query, {
    int chunkSize = 200,
  }) async {
    while (true) {
      final snapshot = await query.limit(chunkSize).get();
      if (snapshot.docs.isEmpty) break;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snapshot.docs.length < chunkSize) break;
    }
  }

  // Incrementar contador de turbinas
  Future<void> incrementTotalTurbinas(String projectId) async {
    await _firestore.collection('projects').doc(projectId).update({
      'totalTurbinas': FieldValue.increment(1),
      // Mantenha numeroTurbinas em sincronia se o UI mobile ainda o usar
      'numeroTurbinas': FieldValue.increment(1),
    });
  }

  // Decrementar contador de turbinas
  Future<void> decrementTotalTurbinas(String projectId) async {
    await _firestore.collection('projects').doc(projectId).update({
      'totalTurbinas': FieldValue.increment(-1),
      'numeroTurbinas': FieldValue.increment(-1),
    });
  }
}
