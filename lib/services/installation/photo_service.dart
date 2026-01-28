import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Escolhe a imagem conforme a plataforma e faz upload.
  /// Devolve o URL público ou null se o utilizador cancelar.
  Future<String?> pickAndUploadPhotoForFase({
    required String turbinaId,
    required String componenteId,
    required String tipoFase, // usa tipo.toString() ou name
  }) async {
    final XFile? image = await _pickImagePerPlatform();
    if (image == null) return null;

    final file = File(image.path);

    // Caminho organizado por turbina / componente / fase
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path =
        'installation_photos/$turbinaId/$componenteId/$tipoFase/$fileName.jpg';

    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }

  Future<XFile?> _pickImagePerPlatform() async {
    // Android: oferecer câmara primeiro (podes adaptar a UX mais tarde)
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _picker.pickImage(source: ImageSource.camera);
    }

    // Windows (e outros desktop): só ficheiro/galeria (sem câmara)
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return _picker.pickImage(source: ImageSource.gallery);
    }

    // Fallback genérico
    return _picker.pickImage(source: ImageSource.gallery);
  }

  // ADICIONA no PhotoService:
  Future<String?> uploadPhotoFromFile({
    required XFile file,
    required String turbinaId,
    required String componenteId,
    required String tipoFase,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path =
          'turbinas/$turbinaId/componentes/$componenteId/$tipoFase/foto_$timestamp.jpg';

      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putData(bytes);

      final url = await ref.getDownloadURL();
      print('✅ Upload: $url');
      return url;
    } catch (e) {
      print('❌ Upload erro: $e');
      return null;
    }
  }
}
