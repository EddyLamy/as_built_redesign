//
// LÓGICA:
// - Detecta plataforma automaticamente
// - Retorna implementação correta
// - Sem imports condicionais (usa dart:io)
//
// USO:
// ```dart
// final ocrService = OCRFactory.criarServicoOCR();
// await ocrService.inicializar();
// ```
//
// ════════════════════════════════════════════════════════════════════════════

import 'dart:io' show Platform;
import 'ocr_service.dart';
import 'ocr_service_mobile.dart';
import 'ocr_service_desktop.dart';

class OCRFactory {
  /// Cria instância de OCRService baseado na plataforma atual
  ///
  /// **Retorna:**
  /// - `OCRServiceMobile` em Android/iOS
  /// - `OCRServiceDesktop` em Windows/macOS/Linux
  static OCRService criarServicoOCR() {
    if (Platform.isAndroid || Platform.isIOS) {
      print('📱 Criando OCR Service para MOBILE (ML Kit)');
      return OCRServiceMobile();
    } else {
      print('💻 Criando OCR Service para DESKTOP (stub)');
      return OCRServiceDesktop();
    }
  }

  /// Verifica se a plataforma atual suporta OCR
  static bool get isOCRSupported {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Retorna nome da plataforma atual
  static String get platformName {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
