import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/installation/checkpoint_geral.dart';

// ═══════════════════════════════════════════════════════
// CHECKPOINT GERAL SERVICE - CRUD
// ═══════════════════════════════════════════════════════

class CheckpointGeralService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'checkpoints_gerais';

  // ────── CREATE ──────

  /// Criar novo checkpoint
  Future<String> createCheckpoint(CheckpointGeral checkpoint) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            checkpoint.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar checkpoint: $e');
    }
  }

  /// Criar múltiplos checkpoints (batch)
  Future<void> createCheckpointsBatch(List<CheckpointGeral> checkpoints) async {
    try {
      final batch = _firestore.batch();

      for (final checkpoint in checkpoints) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, checkpoint.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao criar checkpoints em lote: $e');
    }
  }

  // ────── READ ──────

  /// Obter checkpoint por ID
  Future<CheckpointGeral?> getCheckpointById(String checkpointId) async {
    try {
      final doc =
          await _firestore.collection(_collection).doc(checkpointId).get();

      if (!doc.exists) return null;

      return CheckpointGeral.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao obter checkpoint: $e');
    }
  }

  /// Obter todos os checkpoints de uma turbina
  Future<List<CheckpointGeral>> getCheckpointsByTurbina(
      String turbinaId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => CheckpointGeral.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter checkpoints da turbina: $e');
    }
  }

  // ────── UPDATE ──────

  /// Atualizar checkpoint
  Future<void> updateCheckpoint(
      String checkpointId, CheckpointGeral checkpoint) async {
    try {
      await _firestore.collection(_collection).doc(checkpointId).update(
            checkpoint.toFirestore(),
          );
    } catch (e) {
      throw Exception('Erro ao atualizar checkpoint: $e');
    }
  }

  /// Deletar checkpoint
  Future<void> deleteCheckpoint(String checkpointId) async {
    try {
      await _firestore.collection(_collection).doc(checkpointId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar checkpoint: $e');
    }
  }

  /// Deletar todos os checkpoints de uma turbina
  Future<void> deleteCheckpointsByTurbina(String turbinaId) async {
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
      throw Exception('Erro ao deletar checkpoints da turbina: $e');
    }
  }
}
