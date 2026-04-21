// lib/services/documentation_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/documentation.dart';

class DocumentationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'documentation';

  // ─── Stream em tempo real ──────────────────────────────────────────────────

  Stream<List<Documentation>> getDocumentsStream({String? projectId}) {
    Query query = _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true);

    if (projectId != null && projectId.isNotEmpty) {
      query = query.where('projectId', isEqualTo: projectId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Documentation.fromMap(data);
      }).toList();
    });
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  Future<void> addDocument(Documentation document) async {
    // Usa documentId como ID do documento Firestore
    await _firestore
        .collection(_collection)
        .doc(document.documentId)
        .set(document.toMap());
  }

  Future<void> updateDocument(Documentation document) async {
    await _firestore
        .collection(_collection)
        .doc(document.documentId)
        .update(document.toMap());
  }

  Future<void> deleteDocument(String documentId) async {
    await _firestore.collection(_collection).doc(documentId).delete();
  }

  Future<Documentation?> getDocumentById(String documentId) async {
    final doc = await _firestore.collection(_collection).doc(documentId).get();
    if (!doc.exists) return null;
    return Documentation.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ─── Gerar próximo ID ──────────────────────────────────────────────────────

  Future<String> generateDocumentId() async {
    final snapshot = await _firestore.collection(_collection).get();
    final count = snapshot.docs.length + 1;
    return 'DOC${count.toString().padLeft(3, '0')}';
  }

  // ─── Atualizar flag de existência de ficheiro ─────────────────────────────

  Future<void> updateFileExistsFlag(String documentId, bool exists) async {
    await _firestore.collection(_collection).doc(documentId).update({
      'fileExists': exists,
      'lastChecked': Timestamp.fromDate(DateTime.now()),
    });
  }
}
