// ══════════════════════════════════════════════════════════════
// EQUIPMENT SERVICE
// lib/services/equipment_service.dart
// ══════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipment.dart';
import 'package:flutter/foundation.dart';

class EquipmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'equipment';

  // ════════════════════════════════════════════════════════════
  // STREAM - Todos os equipamentos
  // ════════════════════════════════════════════════════════════

  Stream<List<Equipment>> getEquipmentStream(String projectId) {
    return _firestore
        .collection(_collection)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      final equipment =
          snapshot.docs.map((doc) => Equipment.fromMap(doc.data())).toList();

      equipment.sort(
        (a, b) => a.model.toLowerCase().compareTo(b.model.toLowerCase()),
      );

      return equipment;
    });
  }

  // ════════════════════════════════════════════════════════════
  // STREAM - Equipamento por tipo
  // ════════════════════════════════════════════════════════════

  Stream<List<Equipment>> getEquipmentByTypeStream(
    String projectId,
    EquipmentType type,
  ) {
    return _firestore
        .collection(_collection)
        .where('projectId', isEqualTo: projectId)
        .where('type', isEqualTo: type.value)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Equipment.fromMap(doc.data())).toList();
    });
  }

  // ════════════════════════════════════════════════════════════
  // GET - Equipamento por ID
  // ════════════════════════════════════════════════════════════

  Future<Equipment?> getEquipmentById(
    String equipmentId, {
    String? projectId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_collection)
          .where('equipmentId', isEqualTo: equipmentId);

      if (projectId != null && projectId.isNotEmpty) {
        query = query.where('projectId', isEqualTo: projectId);
      }

      final snapshot = await query.limit(1).get();

      if (snapshot.docs.isEmpty) return null;

      return Equipment.fromMap(snapshot.docs.first.data());
    } catch (e) {
      debugPrint('Error getting equipment: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════
  // CREATE - Adicionar equipamento
  // ════════════════════════════════════════════════════════════

  Future<bool> addEquipment(Equipment equipment) async {
    try {
      await _firestore.collection(_collection).add(equipment.toMap());
      debugPrint('✅ Equipment added: ${equipment.equipmentId}');
      return true;
    } catch (e) {
      debugPrint('❌ Error adding equipment: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // UPDATE - Atualizar equipamento
  // ════════════════════════════════════════════════════════════

  Future<bool> updateEquipment(Equipment equipment) async {
    try {
      // Encontrar documento pelo equipmentId
      final snapshot = await _firestore
          .collection(_collection)
          .where('equipmentId', isEqualTo: equipment.equipmentId)
          .where('projectId', isEqualTo: equipment.projectId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('❌ Equipment not found');
        return false;
      }

      await snapshot.docs.first.reference.update(equipment.toMap());
      debugPrint('✅ Equipment updated: ${equipment.equipmentId}');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating equipment: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // DELETE - Remover equipamento
  // ════════════════════════════════════════════════════════════

  Future<bool> deleteEquipment(String equipmentId, String projectId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('equipmentId', isEqualTo: equipmentId)
          .where('projectId', isEqualTo: projectId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('❌ Equipment not found');
        return false;
      }

      await snapshot.docs.first.reference.delete();
      debugPrint('✅ Equipment deleted: $equipmentId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting equipment: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // USAGE - Adicionar uso ao histórico
  // ════════════════════════════════════════════════════════════

  Future<bool> addUsageRecord(
    String equipmentId,
    EquipmentUsageRecord record,
  ) async {
    try {
      final equipment = await getEquipmentById(
        equipmentId,
        projectId: record.projectId,
      );
      if (equipment == null) return false;

      final updatedHistory = [...equipment.usageHistory, record];

      final updated = equipment.copyWith(
        usageHistory: updatedHistory,
        status: EquipmentStatus.emUso,
        currentProject: record.projectId,
        currentProjectName: record.projectName,
      );

      return await updateEquipment(updated);
    } catch (e) {
      debugPrint('❌ Error adding usage record: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // STATUS - Atualizar status do equipamento
  // ════════════════════════════════════════════════════════════

  Future<bool> updateEquipmentStatus(
    String equipmentId,
    String projectId,
    EquipmentStatus newStatus, {
    String? usageProjectId,
    String? projectName,
  }) async {
    try {
      final equipment = await getEquipmentById(
        equipmentId,
        projectId: projectId,
      );
      if (equipment == null) return false;

      final updated = equipment.copyWith(
        status: newStatus,
        currentProject:
            newStatus == EquipmentStatus.emUso ? usageProjectId : null,
        currentProjectName:
            newStatus == EquipmentStatus.emUso ? projectName : null,
        updatedAt: DateTime.now(),
      );

      return await updateEquipment(updated);
    } catch (e) {
      debugPrint('❌ Error updating status: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // ALERTAS - Obter alertas de calibração
  // ════════════════════════════════════════════════════════════

  Future<List<CalibrationAlert>> getCalibrationAlerts(String projectId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('projectId', isEqualTo: projectId)
          .get();

      final equipment =
          snapshot.docs.map((doc) => Equipment.fromMap(doc.data())).toList();

      final alerts = equipment
          .map((eq) => eq.calibrationAlert)
          .whereType<CalibrationAlert>()
          .toList();

      // Ordenar por dias até expiração (mais urgente primeiro)
      alerts.sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

      return alerts;
    } catch (e) {
      debugPrint('❌ Error getting calibration alerts: $e');
      return [];
    }
  }

  // ════════════════════════════════════════════════════════════
  // SEARCH - Pesquisar equipamento
  // ════════════════════════════════════════════════════════════

  Future<List<Equipment>> searchEquipment(
      String projectId, String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('projectId', isEqualTo: projectId)
          .get();

      final equipment =
          snapshot.docs.map((doc) => Equipment.fromMap(doc.data())).toList();

      final searchLower = query.toLowerCase();

      return equipment.where((eq) {
        return eq.model.toLowerCase().contains(searchLower) ||
            eq.manufacturer.toLowerCase().contains(searchLower) ||
            eq.serialNumber.toLowerCase().contains(searchLower);
      }).toList();
    } catch (e) {
      debugPrint('❌ Error searching equipment: $e');
      return [];
    }
  }
}
