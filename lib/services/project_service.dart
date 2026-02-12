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
    // TODO: Também deletar turbinas e componentes relacionados
    await _firestore.collection('projects').doc(projectId).delete();
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
