import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/installation/trabalho_drivetrain.dart';

// ═══════════════════════════════════════════════════════
// TRABALHO DRIVE TRAIN SERVICE - CRUD
// ═══════════════════════════════════════════════════════

class TrabalhoDriveTrainService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'trabalhos_drivetrain';

  // ────── CREATE ──────

  /// Criar novo trabalho de ligação
  Future<String> createTrabalho(TrabalhoDriveTrain trabalho) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            trabalho.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar trabalho: $e');
    }
  }

  /// Criar múltiplos trabalhos (batch)
  Future<void> createTrabalhosBatch(List<TrabalhoDriveTrain> trabalhos) async {
    try {
      final batch = _firestore.batch();

      for (final trabalho in trabalhos) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, trabalho.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao criar trabalhos em lote: $e');
    }
  }

  // ────── READ ──────

  /// Obter trabalho por ID
  Future<TrabalhoDriveTrain?> getTrabalhoById(String trabalhoId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(trabalhoId).get();

      if (!doc.exists) return null;

      return TrabalhoDriveTrain.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao obter trabalho: $e');
    }
  }

  /// Obter todos os trabalhos de uma turbina
  Future<List<TrabalhoDriveTrain>> getTrabalhosByTurbina(
      String turbinaId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => TrabalhoDriveTrain.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter trabalhos Drive Train da turbina: $e');
    }
  }

  /// Obter trabalho específico por ligação
  Future<TrabalhoDriveTrain?> getTrabalhoByLigacao(
    String turbinaId,
    String componenteA,
    String componenteB,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .where('componenteA', isEqualTo: componenteA)
          .where('componenteB', isEqualTo: componenteB)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return TrabalhoDriveTrain.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Erro ao obter trabalho por ligação: $e');
    }
  }

  /// Stream de trabalhos de uma turbina
  Stream<List<TrabalhoDriveTrain>> streamTrabalhosByTurbina(String turbinaId) {
    return _firestore
        .collection(_collection)
        .where('turbinaId', isEqualTo: turbinaId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrabalhoDriveTrain.fromFirestore(doc))
            .toList());
  }

  // ────── UPDATE ──────

  /// Atualizar trabalho
  Future<void> updateTrabalho(
      String trabalhoId, TrabalhoDriveTrain trabalho) async {
    try {
      await _firestore.collection(_collection).doc(trabalhoId).update(
            trabalho.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('Erro ao atualizar trabalho: $e');
    }
  }

  /// Atualizar campos específicos
  Future<void> updateTrabalhoFields(
    String trabalhoId,
    Map<String, dynamic> fields,
  ) async {
    try {
      fields['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection(_collection).doc(trabalhoId).update(fields);
    } catch (e) {
      throw Exception('Erro ao atualizar campos do trabalho: $e');
    }
  }

  /// Marcar trabalho como N/A
  Future<void> marcarComoNA(
    String trabalhoId,
    String motivoNA,
    String motivoNAKey,
    String userId,
  ) async {
    try {
      await updateTrabalhoFields(trabalhoId, {
        'isNA': true,
        'motivoNA': motivoNA,
        'motivoNAKey': motivoNAKey,
        'updatedBy': userId,
      });
    } catch (e) {
      throw Exception('Erro ao marcar trabalho como N/A: $e');
    }
  }

  /// Desmarcar N/A
  Future<void> desmarcarNA(String trabalhoId, String userId) async {
    try {
      await updateTrabalhoFields(trabalhoId, {
        'isNA': false,
        'motivoNA': null,
        'motivoNAKey': null,
        'updatedBy': userId,
      });
    } catch (e) {
      throw Exception('Erro ao desmarcar N/A: $e');
    }
  }

  /// Adicionar foto
  Future<void> adicionarFoto(String trabalhoId, String fotoUrl) async {
    try {
      await _firestore.collection(_collection).doc(trabalhoId).update({
        'fotos': FieldValue.arrayUnion([fotoUrl]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar foto: $e');
    }
  }

  /// Remover foto
  Future<void> removerFoto(String trabalhoId, String fotoUrl) async {
    try {
      await _firestore.collection(_collection).doc(trabalhoId).update({
        'fotos': FieldValue.arrayRemove([fotoUrl]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao remover foto: $e');
    }
  }

  // ────── DELETE ──────

  /// Deletar trabalho
  Future<void> deleteTrabalho(String trabalhoId) async {
    try {
      await _firestore.collection(_collection).doc(trabalhoId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar trabalho: $e');
    }
  }

  /// Deletar todos os trabalhos de uma turbina
  Future<void> deleteTrabalhosByTurbina(String turbinaId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao deletar trabalhos Drive Train da turbina: $e');
    }
  }

  // ────── QUERIES ESPECIAIS ──────

  /// Obter trabalhos incompletos
  Future<List<TrabalhoDriveTrain>> getTrabalhosIncompletos(
      String turbinaId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .where('isNA', isEqualTo: false)
          .get();

      final trabalhos = snapshot.docs
          .map((doc) => TrabalhoDriveTrain.fromFirestore(doc))
          .where((trabalho) => trabalho.progresso < 100)
          .toList();

      return trabalhos;
    } catch (e) {
      throw Exception('Erro ao obter trabalhos incompletos: $e');
    }
  }

  /// Obter trabalhos pendentes (sem tipo definido)
  Future<List<TrabalhoDriveTrain>> getTrabalhosPendentes(
      String turbinaId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .where('isNA', isEqualTo: false)
          .get();

      final trabalhos = snapshot.docs
          .map((doc) => TrabalhoDriveTrain.fromFirestore(doc))
          .where((trabalho) => trabalho.progresso < 100)
          .toList();

      return trabalhos;
    } catch (e) {
      throw Exception('Erro ao obter trabalhos pendentes: $e');
    }
  }
}
