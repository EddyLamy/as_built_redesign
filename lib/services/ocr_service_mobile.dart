//
// DEPENDÊNCIA:
// google_mlkit_text_recognition: ^0.11.0
//
// PADRÕES SUPORTADOS:
// - VUI: "VUI: ABC123", "UNIT ID ABC123", "VUI ABC123"
// - Serial: "SN: 123", "SERIAL: ABC789", "S/N 123"
// - Item: "ITEM: 001", "ITEM NO: 123", "ITEM 456"
//
// ════════════════════════════════════════════════════════════════════════════

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ocr_service.dart';

class OCRServiceMobile implements OCRService {
  TextRecognizer? _textRecognizer;

  @override
  bool get isOCRAvailable => true;

  @override
  Future<void> inicializar() async {
    print('🔤 Inicializando OCR Mobile (ML Kit)...');

    try {
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      print('✅ ML Kit inicializado com sucesso');
    } catch (e) {
      print('❌ Erro ao inicializar ML Kit: $e');
      rethrow;
    }
  }

  @override
  Future<String> extrairTexto(String imagePath) async {
    if (_textRecognizer == null) {
      await inicializar();
    }

    try {
      print('🔍 Extraindo texto da imagem: $imagePath');

      // 1. Criar InputImage
      final inputImage = InputImage.fromFilePath(imagePath);

      // 2. Processar com ML Kit
      final RecognizedText recognizedText =
          await _textRecognizer!.processImage(inputImage);

      final texto = recognizedText.text;

      print('📝 Texto extraído (${texto.length} caracteres):');
      print(texto);

      return texto;
    } catch (e) {
      print('❌ Erro ao extrair texto: $e');
      return '';
    }
  }

  @override
  Future<Map<String, String>> extrairDadosComponente(String imagePath) async {
    final texto = await extrairTexto(imagePath);

    if (texto.isEmpty) {
      print('⚠️ Nenhum texto extraído, retornando campos vazios');
      return {'vui': '', 'serial': '', 'item': ''};
    }

    print('\n🔍 Analisando texto para extrair campos...');

    final resultado = {
      'vui': _extrairVUI(texto),
      'serial': _extrairSerial(texto),
      'item': _extrairItem(texto),
    };

    print('📊 Resultado da extração:');
    print('   VUI: ${resultado['vui']}');
    print('   Serial: ${resultado['serial']}');
    print('   Item: ${resultado['item']}');

    return resultado;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔍 EXTRAÇÃO DE VUI
  // ══════════════════════════════════════════════════════════════════════════

  String _extrairVUI(String texto) {
    final linhas = texto.split('\n');

    for (var linha in linhas) {
      final cleanLine = linha.trim().toUpperCase();

      // Padrão 1: "VUI: ABC123" ou "VUI:ABC123"
      if (cleanLine.contains('VUI')) {
        final match = RegExp(r'VUI[:\s]+([A-Z0-9-]+)', caseSensitive: false)
            .firstMatch(cleanLine);
        if (match != null) {
          final vui = match.group(1)!;
          print('   ✅ VUI encontrado (padrão "VUI:"): $vui');
          return vui;
        }
      }

      // Padrão 2: "UNIT ID: ABC123" ou "UNIT ID ABC123"
      if (cleanLine.contains('UNIT') && cleanLine.contains('ID')) {
        final match =
            RegExp(r'UNIT\s+ID[:\s]+([A-Z0-9-]+)', caseSensitive: false)
                .firstMatch(cleanLine);
        if (match != null) {
          final vui = match.group(1)!;
          print('   ✅ VUI encontrado (padrão "UNIT ID"): $vui');
          return vui;
        }
      }

      // Padrão 3: "UNIT: ABC123"
      if (cleanLine.contains('UNIT')) {
        final match = RegExp(r'UNIT[:\s]+([A-Z0-9-]+)', caseSensitive: false)
            .firstMatch(cleanLine);
        if (match != null) {
          final vui = match.group(1)!;
          print('   ✅ VUI encontrado (padrão "UNIT:"): $vui');
          return vui;
        }
      }
    }

    print('   ❌ VUI não encontrado');
    return '';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔍 EXTRAÇÃO DE SERIAL
  // ══════════════════════════════════════════════════════════════════════════

  String _extrairSerial(String texto) {
    final linhas = texto.split('\n');

    for (var linha in linhas) {
      final cleanLine = linha.trim().toUpperCase();

      // Padrão 1: "SERIAL: 123456" ou "SERIAL NO: 123"
      if (cleanLine.contains('SERIAL')) {
        final match = RegExp(
          r'SERIAL(?:\s+NO)?[:\s]+([A-Z0-9-]+)',
          caseSensitive: false,
        ).firstMatch(cleanLine);
        if (match != null) {
          final serial = match.group(1)!;
          print('   ✅ Serial encontrado (padrão "SERIAL"): $serial');
          return serial;
        }
      }

      // Padrão 2: "S/N: 123456" ou "S/N 123456"
      if (cleanLine.contains('S/N')) {
        final match = RegExp(r'S/N[:\s]+([A-Z0-9-]+)', caseSensitive: false)
            .firstMatch(cleanLine);
        if (match != null) {
          final serial = match.group(1)!;
          print('   ✅ Serial encontrado (padrão "S/N"): $serial');
          return serial;
        }
      }

      // Padrão 3: "SN: 123456" ou "SN 123456"
      if (RegExp(r'\bSN\b').hasMatch(cleanLine)) {
        final match = RegExp(r'\bSN[:\s]+([A-Z0-9-]+)', caseSensitive: false)
            .firstMatch(cleanLine);
        if (match != null) {
          final serial = match.group(1)!;
          print('   ✅ Serial encontrado (padrão "SN"): $serial');
          return serial;
        }
      }
    }

    // Fallback: Procurar número longo (8+ caracteres alfanuméricos)
    for (var linha in linhas) {
      final match = RegExp(r'\b([A-Z0-9]{8,})\b', caseSensitive: false)
          .firstMatch(linha.toUpperCase());
      if (match != null) {
        final possibleSerial = match.group(1)!;
        print(
            '   ⚠️ Possível serial encontrado (número longo): $possibleSerial');
        return possibleSerial;
      }
    }

    print('   ❌ Serial não encontrado');
    return '';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔍 EXTRAÇÃO DE ITEM
  // ══════════════════════════════════════════════════════════════════════════

  String _extrairItem(String texto) {
    final linhas = texto.split('\n');

    for (var linha in linhas) {
      final cleanLine = linha.trim().toUpperCase();

      // Padrão 1: "ITEM: 001" ou "ITEM NO: 123"
      if (cleanLine.contains('ITEM')) {
        final match = RegExp(
          r'ITEM(?:\s+NO)?[:\s]+([A-Z0-9-]+)',
          caseSensitive: false,
        ).firstMatch(cleanLine);
        if (match != null) {
          final item = match.group(1)!;
          print('   ✅ Item encontrado: $item');
          return item;
        }
      }

      // Padrão 2: "P/N: 123" (Part Number)
      if (cleanLine.contains('P/N')) {
        final match = RegExp(r'P/N[:\s]+([A-Z0-9-]+)', caseSensitive: false)
            .firstMatch(cleanLine);
        if (match != null) {
          final item = match.group(1)!;
          print('   ✅ Item encontrado (padrão "P/N"): $item');
          return item;
        }
      }
    }

    print('   ❌ Item não encontrado');
    return '';
  }

  @override
  void dispose() {
    print('🔄 Fechando OCR Mobile (ML Kit)...');
    _textRecognizer?.close();
    _textRecognizer = null;
    print('✅ OCR Mobile fechado');
  }
}
