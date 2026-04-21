//
// PROPÓSITO:
// - Evitar MissingPluginException em Windows/macOS/Linux
// - Permitir que app compile e rode em desktop sem OCR
// - Desktop é usado para backoffice/validação manual (não precisa OCR)
//
// COMPORTAMENTO:
// - Retorna strings vazias
// - Não tenta acessar plugins nativos
// - Logs informativos
//
// ════════════════════════════════════════════════════════════════════════════

import 'ocr_service.dart';
import 'package:flutter/foundation.dart';

class OCRServiceDesktop implements OCRService {
  @override
  bool get isOCRAvailable => false;

  @override
  Future<void> inicializar() async {
    debugPrint('⚠️ OCR Desktop: Plataforma não suportada');
    debugPrint('   OCR está disponível apenas em Android/iOS');
    debugPrint('   Desktop pode usar a app normalmente (validação manual)');
  }

  @override
  Future<String> extrairTexto(String imagePath) async {
    debugPrint('⚠️ OCR Desktop: extrairTexto() chamado mas não implementado');
    debugPrint('   Foto salva: $imagePath');
    debugPrint('   Para OCR real, usar Android ou iOS');
    return '';
  }

  @override
  Future<Map<String, String>> extrairDadosComponente(String imagePath) async {
    debugPrint(
        '⚠️ OCR Desktop: extrairDadosComponente() chamado mas não implementado');
    debugPrint('   Retornando campos vazios (preencher manualmente)');
    return {
      'vui': '',
      'serial': '',
      'item': '',
    };
  }

  @override
  void dispose() {
    debugPrint('✅ OCR Desktop: dispose() - noop');
  }
}
