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

class OCRServiceDesktop implements OCRService {
  @override
  bool get isOCRAvailable => false;

  @override
  Future<void> inicializar() async {
    print('⚠️ OCR Desktop: Plataforma não suportada');
    print('   OCR está disponível apenas em Android/iOS');
    print('   Desktop pode usar a app normalmente (validação manual)');
  }

  @override
  Future<String> extrairTexto(String imagePath) async {
    print('⚠️ OCR Desktop: extrairTexto() chamado mas não implementado');
    print('   Foto salva: $imagePath');
    print('   Para OCR real, usar Android ou iOS');
    return '';
  }

  @override
  Future<Map<String, String>> extrairDadosComponente(String imagePath) async {
    print(
        '⚠️ OCR Desktop: extrairDadosComponente() chamado mas não implementado');
    print('   Retornando campos vazios (preencher manualmente)');
    return {
      'vui': '',
      'serial': '',
      'item': '',
    };
  }

  @override
  void dispose() {
    print('✅ OCR Desktop: dispose() - noop');
  }
}
