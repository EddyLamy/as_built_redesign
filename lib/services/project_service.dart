import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de todos os projetos do usuário
  Stream<List<Project>> getProjects(String userId) {
    print('🔍 BUSCANDO PROJETOS COM userId = $userId');
    return _firestore
        .collection('projects')
        .where('userId', isEqualTo: userId) // ← MUDANÇA AQUI
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Project.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Stream de um projeto específico
  Stream<Project?> getProject(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Project.fromMap(doc.id, doc.data()!);
    });
  }

  // Criar novo projeto
  Future<String> createProject(Project project) async {
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
    // TODO: Também deletar turbinas e componentes relacionados
    await _firestore.collection('projects').doc(projectId).delete();
  }

  // Incrementar contador de turbinas
  Future<void> incrementTotalTurbinas(String projectId) async {
    await _firestore.collection('projects').doc(projectId).update({
      'totalTurbinas': FieldValue.increment(1),
    });
  }

  // Decrementar contador de turbinas
  Future<void> decrementTotalTurbinas(String projectId) async {
    await _firestore.collection('projects').doc(projectId).update({
      'totalTurbinas': FieldValue.increment(-1),
    });
  }
}
