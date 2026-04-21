import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/ncr.dart';

class NcrService {
  NcrService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _collection = 'ncrs';

  String newNcrId() => _firestore.collection(_collection).doc().id;

  Stream<List<NcrRecord>> watchProjectNcrs(String projectId) {
    if (projectId.isEmpty) return Stream.value(const <NcrRecord>[]);

    return _firestore
        .collection(_collection)
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map(NcrRecord.fromFirestore).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  Stream<List<NcrRecord>> watchTurbineNcrs(String turbinaId) {
    if (turbinaId.isEmpty) return Stream.value(const <NcrRecord>[]);

    return _firestore
        .collection(_collection)
        .where('turbinaId', isEqualTo: turbinaId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map(NcrRecord.fromFirestore).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  Future<List<NcrRecord>> getProjectNcrs(String projectId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('projectId', isEqualTo: projectId)
        .get();
    final items = snapshot.docs.map(NcrRecord.fromFirestore).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<String> generateNcrCode(String projectId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('projectId', isEqualTo: projectId)
        .get();

    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final sequence = (snapshot.docs.length + 1).toString().padLeft(3, '0');
    return 'NCR-$year$month-$sequence';
  }

  Future<void> createNcr(NcrRecord ncr) async {
    await _firestore.collection(_collection).doc(ncr.ncrId).set(ncr.toMap());
  }

  Future<void> updateNcr(NcrRecord ncr) async {
    await _firestore.collection(_collection).doc(ncr.ncrId).update(ncr.toMap());
  }

  Future<void> deleteNcr(NcrRecord ncr) async {
    for (final evidence in ncr.evidence) {
      try {
        await _storage.refFromURL(evidence.url).delete();
      } catch (_) {
        // Ignore missing or already deleted files.
      }
    }

    await _firestore.collection(_collection).doc(ncr.ncrId).delete();
  }

  Future<NcrEvidence> uploadEvidence({
    required String projectId,
    required String ncrId,
    required PlatformFile file,
    required String userId,
  }) async {
    final extension = file.extension?.toLowerCase() ?? 'bin';
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path =
        'ncrs/$projectId/$ncrId/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final ref = _storage.ref().child(path);

    final metadata = SettableMetadata(
      contentType: _contentTypeForExtension(extension),
      customMetadata: {'uploadedBy': userId},
    );

    if (kIsWeb) {
      final bytes = file.bytes;
      if (bytes == null) {
        throw Exception('Não foi possível ler o ficheiro selecionado.');
      }
      await ref.putData(bytes, metadata);
    } else {
      final filePath = file.path;
      if (filePath == null || filePath.isEmpty) {
        throw Exception('Ficheiro sem caminho válido.');
      }
      await ref.putFile(File(filePath), metadata);
    }

    final url = await ref.getDownloadURL();

    return NcrEvidence(
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
      case 'pdf':
        return 'application/pdf';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}
