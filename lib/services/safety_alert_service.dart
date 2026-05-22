import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/safety_alert.dart';

class SafetyAlertService {
  SafetyAlertService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _collection = 'safety_alerts';
  final String _counterCollection = 'ims_counters';

  String newAlertId() => _firestore.collection(_collection).doc().id;

  Stream<List<SafetyAlertRecord>> watchProjectAlerts(String projectId) {
    if (projectId.isEmpty) {
      return Stream.value(const <SafetyAlertRecord>[]);
    }

    return _firestore
        .collection(_collection)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map(SafetyAlertRecord.fromFirestore).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  Future<String> generateAlertCode(SafetyAlertCategory category) async {
    final sequence = await _nextCategorySequence(category);
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final sequencePart = sequence.toString().padLeft(4, '0');
    final prefix = _categoryPrefix(category);
    return '$prefix-$year$month-$sequencePart';
  }

  String _categoryPrefix(SafetyAlertCategory category) {
    switch (category) {
      case SafetyAlertCategory.nearMiss:
        return 'NM';
      case SafetyAlertCategory.hazardousObservation:
        return 'SA';
      case SafetyAlertCategory.walkAndTalk:
        return 'WT';
    }
  }

  Future<int> _nextCategorySequence(SafetyAlertCategory category) async {
    final counterRef =
        _firestore.collection(_counterCollection).doc(category.value);

    final existingCount = await _firestore
        .collection(_collection)
        .where('category', isEqualTo: category.value)
        .count()
        .get();

    final initialSequence = existingCount.count ?? 0;

    return _firestore.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(counterRef);
      final currentSequence = snapshot.exists
          ? (snapshot.data()?['lastSequence'] as num?)?.toInt() ?? 0
          : initialSequence;
      final nextSequence = currentSequence + 1;

      transaction.set(
        counterRef,
        {
          'category': category.value,
          'lastSequence': nextSequence,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return nextSequence;
    });
  }

  Future<void> createAlert(SafetyAlertRecord alert) async {
    await _firestore
        .collection(_collection)
        .doc(alert.alertId)
        .set(alert.toMap());
  }

  Future<void> updateAlert(SafetyAlertRecord alert) async {
    await _firestore
        .collection(_collection)
        .doc(alert.alertId)
        .update(alert.toMap());
  }

  Future<void> deleteAlert(SafetyAlertRecord alert) async {
    for (final evidence in alert.evidence) {
      try {
        await _storage.refFromURL(evidence.url).delete();
      } catch (_) {
        // Ignore already deleted files.
      }
    }

    for (final evidence in alert.resolutionEvidence) {
      try {
        await _storage.refFromURL(evidence.url).delete();
      } catch (_) {
        // Ignore already deleted files.
      }
    }

    await _firestore.collection(_collection).doc(alert.alertId).delete();
  }

  Future<void> deleteEvidenceFile(SafetyAlertEvidence evidence) async {
    try {
      await _storage.refFromURL(evidence.url).delete();
    } catch (_) {
      // Ignore already deleted files.
    }
  }

  Future<SafetyAlertEvidence> uploadEvidence({
    required String projectId,
    required String alertId,
    required PlatformFile file,
    required String userId,
  }) async {
    final extension = file.extension?.toLowerCase() ?? 'jpg';
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path =
        'safety_alerts/$projectId/$alertId/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final ref = _storage.ref().child(path);

    final metadata = SettableMetadata(
      contentType: _contentTypeForExtension(extension),
      customMetadata: {'uploadedBy': userId},
    );

    if (kIsWeb) {
      final bytes = file.bytes;
      if (bytes == null) {
        throw Exception('Não foi possível ler a imagem selecionada.');
      }
      await ref.putData(bytes, metadata);
    } else {
      final filePath = file.path;
      if (filePath == null || filePath.isEmpty) {
        throw Exception('Imagem sem caminho válido.');
      }
      await ref.putFile(File(filePath), metadata);
    }

    final url = await ref.getDownloadURL();
    return SafetyAlertEvidence(
      id: ref.name,
      name: file.name,
      url: url,
      contentType: metadata.contentType ?? extension,
      uploadedAt: DateTime.now(),
      uploadedBy: userId,
    );
  }

  String _contentTypeForExtension(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
