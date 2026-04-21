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
import 'package:flutter/foundation.dart';
import 'dart:ui';

class OCRServiceMobile implements OCRService {
  TextRecognizer? _textRecognizer;

  @override
  bool get isOCRAvailable => true;

  @override
  Future<void> inicializar() async {
    debugPrint('🔤 Inicializando OCR Mobile (ML Kit)...');

    try {
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      debugPrint('✅ ML Kit inicializado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar ML Kit: $e');
      rethrow;
    }
  }

  @override
  Future<String> extrairTexto(String imagePath) async {
    if (_textRecognizer == null) {
      await inicializar();
    }

    try {
      debugPrint('🔍 Extraindo texto da imagem: $imagePath');

      // 1. Criar InputImage
      final inputImage = InputImage.fromFilePath(imagePath);

      // 2. Processar com ML Kit
      final RecognizedText recognizedText =
          await _textRecognizer!.processImage(inputImage);

      final texto = recognizedText.text;

      debugPrint('📝 Texto extraído (${texto.length} caracteres):');
      debugPrint(texto);

      return texto;
    } catch (e) {
      debugPrint('❌ Erro ao extrair texto: $e');
      return '';
    }
  }

  @override
  Future<Map<String, String>> extrairDadosComponente(String imagePath) async {
    if (_textRecognizer == null) {
      await inicializar();
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer!.processImage(inputImage);
    final texto = recognizedText.text;

    debugPrint('📌 Fonte dos dados: ML Kit TextRecognizer.processImage()');
    debugPrint('📌 Imagem analisada: $imagePath');

    if (texto.isEmpty) {
      debugPrint('⚠️ Nenhum texto extraído, retornando campos vazios');
      return {'vui': '', 'serial': '', 'item': ''};
    }

    debugPrint('📝 Texto extraído (${texto.length} caracteres):');
    debugPrint(texto);

    debugPrint(
        '\n🔍 Analisando texto para extrair campos (layout + fallback)...');

    final linhasComRect = _extrairLinhasComRect(recognizedText);
    _logLinhasOCR(linhasComRect);

    // PASSE 1: Secções de texto (label → valor na ordem do texto) — fonte principal.
    final porSecoes = _extrairPorSecoesTexto(texto);
    var vui = _validarVUI(porSecoes['vui'] ?? '');
    var item = _validarItem(porSecoes['item'] ?? '');
    var serial = _validarSerial(porSecoes['serial'] ?? '');

    // PASSE 2: Contexto serial — reconstrói seriais partidos (ex: F2102 + E5).
    // Só melhora o serial se o novo valor for mais longo e extensão do atual.
    final serialPorContexto =
        _validarSerial(_extrairSerialPorContextoTexto(texto));
    if (serialPorContexto.isNotEmpty) {
      if (serial.isEmpty ||
          (serialPorContexto.length > serial.length &&
              serialPorContexto.startsWith(serial))) {
        serial = serialPorContexto;
      }
    }

    // PASSE 3: Layout espacial — só para campos ainda em falta.
    var porLayout = <String, String>{'vui': '', 'serial': '', 'item': ''};
    if (vui.isEmpty || item.isEmpty || serial.isEmpty) {
      porLayout = _extrairPorLayout(linhasComRect);
      if (vui.isEmpty) vui = _validarVUI(porLayout['vui'] ?? '');
      if (item.isEmpty) item = _validarItem(porLayout['item'] ?? '');
      if (serial.isEmpty) serial = _validarSerial(porLayout['serial'] ?? '');
    }

    // PASSE 4: Heurística global — último recurso quando ainda faltam campos.
    var porHeuristica = <String, String>{'vui': '', 'serial': '', 'item': ''};
    if (vui.isEmpty || item.isEmpty || serial.isEmpty) {
      porHeuristica = _extrairPorHeuristicaGlobal(
        linhasComRect,
        valuesToIgnore: {vui, item, serial}.where((v) => v.isNotEmpty).toSet(),
      );
      if (vui.isEmpty) {
        vui = _validarVUI(porHeuristica['vui'] ?? '');
      }
      if (item.isEmpty) {
        item = _validarItem(porHeuristica['item'] ?? '');
      }
      if (serial.isEmpty) {
        serial = _validarSerial(porHeuristica['serial'] ?? '');
      }
    }

    final resultado = {
      'vui': vui,
      'serial': serial,
      'item': item,
      'debug_source': 'MLKit TextRecognizer.processImage',
      'debug_rawText': texto,
      'debug_layout_vui': porLayout['vui'] ?? '',
      'debug_layout_serial': porLayout['serial'] ?? '',
      'debug_layout_item': porLayout['item'] ?? '',
      'debug_sections_vui': porSecoes['vui'] ?? '',
      'debug_sections_serial': porSecoes['serial'] ?? '',
      'debug_sections_item': porSecoes['item'] ?? '',
      'debug_heuristic_vui': porHeuristica['vui'] ?? '',
      'debug_heuristic_serial': porHeuristica['serial'] ?? '',
      'debug_heuristic_item': porHeuristica['item'] ?? '',
    };

    debugPrint('📊 Resultado da extração:');
    debugPrint('   VUI: ${resultado['vui']}');
    debugPrint('   Serial: ${resultado['serial']}');
    debugPrint('   Item: ${resultado['item']}');

    return resultado;
  }

  Map<String, String> _extrairPorLayout(List<_OcrLine> linhas) {
    if (linhas.isEmpty) {
      return {'vui': '', 'serial': '', 'item': ''};
    }

    final vui = _valorPorLabelComProximidade(
      linhas,
      labelPatterns: [
        RegExp(r'\bVUI\b', caseSensitive: false),
        RegExp(r'\bUNIT\s*ID\b', caseSensitive: false),
      ],
      preferAlphaNumeric: true,
    );

    final item = _valorPorLabelComProximidade(
      linhas,
      labelPatterns: [
        RegExp(r'\bITEM\b', caseSensitive: false),
        RegExp(r'\bGENERIC\s*ITEM\b', caseSensitive: false),
        RegExp(r'\bGENERIC\b', caseSensitive: false),
        RegExp(r'\bITERN\b', caseSensitive: false),
        RegExp(r'\b1EM\b', caseSensitive: false),
        RegExp(r'\bLTEM\b', caseSensitive: false),
      ],
      preferNumeric: true,
      strictPreferredType: true,
      valuesToIgnore: {vui},
    );

    final serial = _valorPorLabelComProximidade(
      linhas,
      labelPatterns: [
        RegExp(r'\bSERIAL(?:\s+NO)?\b', caseSensitive: false),
        RegExp(r'\bS\s*/\s*N\b', caseSensitive: false),
        RegExp(r'\bSI\s*N\b', caseSensitive: false),
        RegExp(r'\bS1\s*N\b', caseSensitive: false),
        RegExp(r'\bSN\b', caseSensitive: false),
        RegExp(r'\bMANUF\s+S\s*/\s*N\b', caseSensitive: false),
        RegExp(r'\bMANUF\s+SI\s*N\b', caseSensitive: false),
      ],
      preferAlphaNumeric: false,
      strictPreferredType: false,
      valuesToIgnore: {vui, item}.where((v) => v.isNotEmpty).toSet(),
    );

    debugPrint('📍 Resultado por layout: VUI=$vui, Serial=$serial, Item=$item');

    return {
      'vui': vui,
      'serial': serial,
      'item': item,
    };
  }

  Map<String, String> _extrairPorSecoesTexto(String texto) {
    final linhas = texto
        .split('\n')
        .map((l) => l.trim().toUpperCase())
        .where((l) => l.isNotEmpty)
        .toList();

    if (linhas.isEmpty) {
      return {'vui': '', 'serial': '', 'item': ''};
    }

    final idxVui = _findFirstLabelIndex(
      linhas,
      [RegExp(r'\bVUI\b'), RegExp(r'\bUNIT\s*ID\b')],
    );
    final idxItem = _findFirstLabelIndex(
      linhas,
      [
        RegExp(r'\bITEM\b'),
        RegExp(r'\bGENERIC\b'),
        // Erros comuns de OCR ao ler "Item"
        RegExp(r'\bITERN\b'),
        RegExp(r'\b1EM\b'),
        RegExp(r'\bLTEM\b'),
        RegExp(r'\bITEMN\b'),
      ],
    );
    final idxSerial = _findFirstLabelIndex(
      linhas,
      [
        RegExp(r'\bMANUF\b'),
        RegExp(r'\bSERIAL\b'),
        RegExp(r'\bS\s*/\s*N\b'),
        RegExp(r'\bSIN\b'),
        RegExp(r'\bS1N\b'),
        // OCR misread de "S/N" ou "SI N" como "S1" isolado
        RegExp(r'^S1$'),
      ],
    );

    String vui = '';
    String item = '';
    String serial = '';

    if (idxVui >= 0) {
      final fimVui =
          _minPositive([idxItem, idxSerial], defaultValue: idxVui + 5);
      vui = _melhorCandidatoEmIntervalo(
        linhas,
        start: idxVui + 1,
        end: fimVui,
        preferAlphaNumeric: true,
      );
    }

    if (idxItem >= 0) {
      final fimItem = _minPositive([idxSerial], defaultValue: idxItem + 4);
      item = _melhorCandidatoEmIntervalo(
        linhas,
        start: idxItem + 1,
        end: fimItem,
        preferNumeric: true,
        strictPreferredType: true,
      );
    }

    if (idxSerial >= 0) {
      // Serial: sob o label S/N, qualquer valor é serial por contexto de posição.
      // Recolhe todos os candidatos das linhas seguintes e ranqueia:
      // alphanumeric (letras+dígitos) > numérico puro (excluindo o item já encontrado).
      final linhasSerial = linhas
          .skip(idxSerial + 1)
          .take(6)
          .where((l) => !_isLinhaRotuloSemValor(l))
          .toList();

      final alfaNum = <String>[];
      final numPuro = <String>[];

      for (final l in linhasSerial) {
        final c = _extrairSerialCombinadoDaLinha(l);
        if (c.isNotEmpty && !_isLikelyNoiseToken(c) && c != item) {
          alfaNum.add(c);
        }
        final nums = _extrairCandidatosDaLinha(l)
            .where((t) => RegExp(r'^\d{6,14}$').hasMatch(t))
            .where((t) => t != item) // não reutilizar o item já encontrado
            .toList();
        numPuro.addAll(nums);
      }

      if (alfaNum.isNotEmpty) {
        // Prefere o mais longo entre os alfanuméricos
        alfaNum.sort((a, b) => b.length.compareTo(a.length));
        serial = alfaNum.first;
      } else if (numPuro.isNotEmpty) {
        numPuro.sort((a, b) => b.length.compareTo(a.length));
        serial = numPuro.first;
      }
    }

    if (vui.isEmpty) {
      vui = _inferirVuiPorContexto(linhas,
          idxItem: idxItem, idxSerial: idxSerial);
    }

    // Fallback de serial: quando o valor do serial aparece ANTES do label
    // (ex: serial na linha 4, label "S1" na linha 6).
    if (serial.isEmpty && idxItem >= 0) {
      final ini = idxItem + 2;
      final fim = idxSerial >= 0 ? idxSerial : linhas.length - 1;
      for (var i = ini; i <= fim && i < linhas.length; i++) {
        if (_isLinhaRotuloSemValor(linhas[i])) continue;
        final c = _extrairSerialCombinadoDaLinha(linhas[i]);
        if (c.isNotEmpty && !_isLikelyNoiseToken(c)) {
          serial = c;
          break;
        }
        final nums = _extrairCandidatosDaLinha(linhas[i])
            .where((t) => RegExp(r'^\d{6,14}$').hasMatch(t))
            // Não reaproveitar o mesmo valor do item já encontrado
            .where((t) => t != item)
            .toList();
        if (nums.isNotEmpty) {
          nums.sort((a, b) => b.length.compareTo(a.length));
          serial = nums.first;
          break;
        }
      }
    }

    debugPrint(
        '🧩 Resultado por secções: VUI=$vui, Serial=$serial, Item=$item');

    return {
      'vui': vui,
      'serial': serial,
      'item': item,
    };
  }

  int _findFirstLabelIndex(List<String> linhas, List<RegExp> patterns) {
    for (var i = 0; i < linhas.length; i++) {
      if (patterns.any((p) => p.hasMatch(linhas[i]))) {
        return i;
      }
    }
    return -1;
  }

  int _minPositive(List<int> values, {required int defaultValue}) {
    final positivos = values.where((v) => v >= 0).toList();
    if (positivos.isEmpty) return defaultValue;
    positivos.sort();
    return positivos.first;
  }

  String _melhorCandidatoEmIntervalo(
    List<String> linhas, {
    required int start,
    required int end,
    bool preferNumeric = false,
    bool preferAlphaNumeric = false,
    bool strictPreferredType = false,
  }) {
    if (linhas.isEmpty) return '';

    final s = start.clamp(0, linhas.length - 1);
    final e = end.clamp(0, linhas.length - 1);
    if (s > e) return '';

    final candidatos = <String>[];
    for (var i = s; i <= e; i++) {
      candidatos.addAll(_extrairCandidatosDaLinha(linhas[i]));
    }

    return _selecionarMelhorCandidato(
      candidatos,
      preferNumeric: preferNumeric,
      preferAlphaNumeric: preferAlphaNumeric,
      strictPreferredType: strictPreferredType,
    );
  }

  Map<String, String> _extrairPorHeuristicaGlobal(
    List<_OcrLine> linhas, {
    Set<String> valuesToIgnore = const {},
  }) {
    final ignoreNormalizados = valuesToIgnore
        .map((v) => _normalizarCodigoMisto(v.trim().toUpperCase()))
        .toSet();

    final tokens = <String>[];
    for (final linha in linhas) {
      tokens.addAll(_extrairCandidatosDaLinha(linha.text));
    }

    final candidatos = tokens
        .map((t) => _normalizarCodigoMisto(t.trim().toUpperCase()))
        .where((t) => t.isNotEmpty && !ignoreNormalizados.contains(t))
        .toSet()
        .toList();

    String vui = '';
    String item = '';
    String serial = '';

    // VUI típico: alfanumérico, 8-12 chars, muitas vezes com bloco de letras no fim.
    final vuiCandidates = candidatos.where((t) {
      return RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Z0-9-]{8,16}$').hasMatch(t) &&
          !_isLikelyNoiseToken(t);
    }).toList()
      ..sort((a, b) {
        final aStartsCode = RegExp(r'^[0OQDE]').hasMatch(a) ? 1 : 0;
        final bStartsCode = RegExp(r'^[0OQDE]').hasMatch(b) ? 1 : 0;
        if (aStartsCode != bStartsCode) {
          return bStartsCode.compareTo(aStartsCode);
        }
        return b.length.compareTo(a.length);
      });
    if (vuiCandidates.isNotEmpty) {
      vui = _normalizarCodigoMisto(vuiCandidates.first);
    }

    // Item típico: numérico puro, preferencialmente 6-9 dígitos.
    // Numéricos com ≥10 dígitos são tratados como serial;
    // só usamos como item se não houver candidatos mais curtos.
    final numericosLongos =
        candidatos.where((t) => RegExp(r'^\d{10,}$').hasMatch(t)).toSet();
    final numericosCurtos = candidatos
        .where((t) => RegExp(r'^\d{6,9}$').hasMatch(t))
        .toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final numericosTodos = candidatos
        .where((t) => RegExp(r'^\d{6,12}$').hasMatch(t))
        .toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final itemPool =
        numericosCurtos.isNotEmpty ? numericosCurtos : numericosTodos;
    if (itemPool.isNotEmpty) {
      item = itemPool.first;
    }

    // Serial: letra+dígitos, alfanumérico ou numérico longo (≥10 dígitos).
    final serialCandidates = candidatos
        .where((t) {
          return RegExp(r'^[A-Z]{1,3}\d{4,12}$').hasMatch(t) ||
              RegExp(r'^[A-Z0-9-]{6,14}$').hasMatch(t) ||
              numericosLongos.contains(t);
        })
        .where((t) => t != vui && t != item)
        .toList()
      ..sort((a, b) {
        final aStrong = RegExp(r'^[A-Z]{1,3}\d{4,12}$').hasMatch(a) ? 1 : 0;
        final bStrong = RegExp(r'^[A-Z]{1,3}\d{4,12}$').hasMatch(b) ? 1 : 0;
        if (aStrong != bStrong) return bStrong.compareTo(aStrong);

        final aMixed = RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(a) ? 1 : 0;
        final bMixed = RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(b) ? 1 : 0;
        if (aMixed != bMixed) return bMixed.compareTo(aMixed);

        return a.length.compareTo(b.length);
      });
    if (serialCandidates.isNotEmpty) {
      serial = _normalizarCodigoMisto(serialCandidates.first);
    }

    debugPrint(
        '🧠 Resultado heurístico global: VUI=$vui, Serial=$serial, Item=$item');

    return {
      'vui': vui,
      'serial': serial,
      'item': item,
    };
  }

  List<_OcrLine> _extrairLinhasComRect(RecognizedText recognizedText) {
    final linhas = <_OcrLine>[];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final texto = line.text.trim().toUpperCase();
        if (texto.isEmpty) continue;
        final rect = line.boundingBox;
        linhas.add(_OcrLine(text: texto, rect: rect));
      }
    }
    return linhas;
  }

  String _valorPorLabelComProximidade(
    List<_OcrLine> linhas, {
    required List<RegExp> labelPatterns,
    bool preferNumeric = false,
    bool preferAlphaNumeric = false,
    bool strictPreferredType = false,
    Set<String> valuesToIgnore = const {},
  }) {
    final ignoreNormalizados = valuesToIgnore
        .map((v) => _normalizarCodigoMisto(v.trim().toUpperCase()))
        .toSet();

    final labels = linhas
        .where((l) => labelPatterns.any((pattern) => pattern.hasMatch(l.text)))
        .toList();
    if (labels.isEmpty) return '';

    // 1) Tenta extrair na mesma linha do rótulo.
    for (final label in labels) {
      final semLabel = labelPatterns.fold<String>(
        label.text,
        (textoAtual, pattern) => textoAtual.replaceAll(pattern, ' '),
      );

      final candidato = _selecionarMelhorCandidato(
        _extrairCandidatosDaLinha(semLabel)
            .where(
                (v) => !ignoreNormalizados.contains(_normalizarCodigoMisto(v)))
            .toList(),
        preferNumeric: preferNumeric,
        preferAlphaNumeric: preferAlphaNumeric,
        strictPreferredType: strictPreferredType,
      );
      if (candidato.isNotEmpty) return candidato;
    }

    // 2) Tenta linha vizinha por proximidade espacial.
    String melhor = '';
    double melhorScore = double.infinity;

    for (final label in labels) {
      final labelCenterY = label.rect.center.dy;
      final labelCenterX = label.rect.center.dx;

      for (final linha in linhas) {
        if (identical(linha, label)) continue;

        final isOtherLabel =
            labelPatterns.any((pattern) => pattern.hasMatch(linha.text)) ||
                _isLinhaRotuloSemValor(linha.text);
        if (isOtherLabel) continue;

        final candidato = _selecionarMelhorCandidato(
          _extrairCandidatosDaLinha(linha.text)
              .where((v) =>
                  !ignoreNormalizados.contains(_normalizarCodigoMisto(v)))
              .toList(),
          preferNumeric: preferNumeric,
          preferAlphaNumeric: preferAlphaNumeric,
          strictPreferredType: strictPreferredType,
        );
        if (candidato.isEmpty) continue;

        final dy = (linha.rect.center.dy - labelCenterY).abs();
        final dx = linha.rect.center.dx - labelCenterX;

        // Priorização:
        // - texto à direita do rótulo (mesma linha da etiqueta)
        // - ou logo abaixo (etiquetas verticais)
        final horizontalPenalty = dx >= -10 ? 0 : 250;
        final verticalPenalty = dy;
        final farPenalty = dx.abs() * 0.35;
        final score = horizontalPenalty + verticalPenalty + farPenalty;

        if (score < melhorScore) {
          melhorScore = score;
          melhor = candidato;
        }
      }
    }

    return melhor;
  }

  bool _isLinhaRotuloSemValor(String linha) {
    const rotulos = {
      'VUI',
      'UNIT',
      'UNIT ID',
      'SERIAL',
      'SERIAL NO',
      'SN',
      'S/N',
      'SIN',
      'S1N',
      'ITEM',
      'ITEM NO',
      'GENERIC',
      'GENERIC ITEM',
      'MANUF',
      'MANUF S/N',
    };

    final normalizada = linha.replaceAll(RegExp(r'\s+'), ' ').trim();
    return rotulos.contains(normalizada);
  }

  List<String> _extrairCandidatosDaLinha(String linha) {
    final matches = RegExp(r'\b[A-Z0-9][A-Z0-9-]{1,}\b')
        .allMatches(linha)
        .map((m) => m.group(0) ?? '')
        .where((token) => token.isNotEmpty)
        .toList();

    final base = matches.where((token) {
      const ignorar = {
        'VUI',
        'UNIT',
        'ID',
        'SERIAL',
        'NO',
        'S',
        'N',
        'SN',
        'MANUF',
        'ITEM',
        'GENERIC',
        'TEST',
        'APPROVED',
        'GENERATOR',
        'ENERGY',
        'MOUNTED',
        'FULLY',
        // Ruído de logos/fundos de foto
        'INDSERVICE',
        'WINDSERVICE',
        '2WINDSERVICE',
        'INSERVICE',
      };
      if (ignorar.contains(token)) return false;
      if (_isLikelyNoiseToken(token)) return false;
      return true;
    }).toList();

    final combinados = <String>[];
    for (var i = 0; i < base.length - 1; i++) {
      final a = base[i];
      final b = base[i + 1];

      // Só combina tokens quando pelo menos um começa com letra.
      // Isto evita juntar fragmentos de datas puras (ex: "2021" + "10" → "202110").
      final algumTemLetra =
          RegExp(r'^[A-Z]').hasMatch(a) || RegExp(r'^[A-Z]').hasMatch(b);
      if (!algumTemLetra) continue;

      final combinado = '$a$b';
      final aValido = RegExp(r'^[A-Z0-9]{3,10}$').hasMatch(a) &&
          RegExp(r'.*\d.*\d').hasMatch(a);
      final bValido = RegExp(r'^[A-Z0-9]{1,8}$').hasMatch(b);
      final comboValido =
          RegExp(r'^(?=.*\d)[A-Z0-9]{6,16}$').hasMatch(combinado);

      if (aValido && bValido && comboValido) {
        combinados.add(combinado);
      }
    }

    return [...base, ...combinados];
  }

  String _selecionarMelhorCandidato(
    List<String> candidatos, {
    bool preferNumeric = false,
    bool preferAlphaNumeric = false,
    bool strictPreferredType = false,
  }) {
    if (candidatos.isEmpty) return '';

    final limpos =
        candidatos.map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
    if (limpos.isEmpty) return '';

    if (preferNumeric) {
      final numericos =
          limpos.where((c) => RegExp(r'^\d{5,}$').hasMatch(c)).toList();
      if (numericos.isNotEmpty) {
        numericos.sort((a, b) => b.length.compareTo(a.length));
        return numericos.first;
      }

      if (strictPreferredType) {
        return '';
      }
    }

    if (preferAlphaNumeric) {
      final alfanumericos = limpos
          .where(
              (c) => RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Z0-9-]{4,}$').hasMatch(c))
          .toList();
      if (alfanumericos.isNotEmpty) {
        alfanumericos.sort((a, b) => b.length.compareTo(a.length));
        return alfanumericos.first;
      }

      if (strictPreferredType) {
        return '';
      }
    }

    limpos.sort((a, b) => b.length.compareTo(a.length));
    return limpos.first;
  }

  String _validarVUI(String valor) {
    if (valor.isEmpty) return '';
    var v = _normalizarCodigoMisto(valor.trim().toUpperCase());

    // Os VUI Vestas têm sempre 10 caracteres e começam com "000".
    // Se o OCR perdeu zeros iniciais (ex: "0ACE4KFT" em vez de "000ACE4KFT"),
    // repadamos até 10 caracteres para recuperar os zeros em falta.
    if (v.length >= 7 && v.length < 10 && v.startsWith('0')) {
      final padded = v.padLeft(10, '0');
      if (RegExp(r'^[A-Z0-9-]{10}$').hasMatch(padded) &&
          RegExp(r'(?=.*[A-Z])(?=.*\d)').hasMatch(padded)) {
        v = padded;
        debugPrint('   🔧 VUI repadado: $valor → $v');
      }
    }

    final formatoOk = RegExp(r'^[A-Z0-9-]{8,16}$').hasMatch(v) &&
        RegExp(r'(?=.*[A-Z])(?=.*\d)').hasMatch(v);

    if (formatoOk && !_isLikelyNoiseToken(v)) return v;

    debugPrint('   ⚠️ VUI descartado por padrão inválido: $valor');
    return '';
  }

  String _validarSerial(String valor) {
    if (valor.isEmpty) return '';
    final v = _normalizarCodigoMisto(valor.trim().toUpperCase());

    // Padrão 1: 1-3 letras iniciais seguidas de 4-13 dígitos (ex: E57522, F210205, TT220043, L04938).
    // Cobre a maioria dos seriais Vestas alfanuméricos.
    final isLeadingLetterDigits = RegExp(r'^[A-Z]{1,3}\d{4,13}$').hasMatch(v);

    // Padrão 2: numérico puro com 6-14 dígitos (ex: 500149190016).
    final isNumericOnly = RegExp(r'^\d{6,14}$').hasMatch(v);

    // Padrão 3: serial compacto Vestas com sufixo alfanumérico:
    // 1 letra + 3+ dígitos + 1 letra + 0-3 chars (ex: F2102E5, F2102ES).
    // Nota: requer dígitos IMEDIATAMENTE após a primeira letra, pelo que
    // "EF2024" (letra→letra) é rejeitado aqui.
    final isVestasCompact =
        RegExp(r'^[A-Z]\d{3,}[A-Z][A-Z0-9]{0,3}$').hasMatch(v);

    // Padrão 4: alfanumérico mais longo (≥8 chars) com letras e dígitos
    // misturados. Mínimo de 8 chars evita aceitar lixo de QR
    // (ex: "EF2024" com apenas 6 chars é rejeitado aqui).
    final isComplexAlphaNum = RegExp(r'^[A-Z0-9-]{8,20}$').hasMatch(v) &&
        RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Z0-9-]+$').hasMatch(v);

    if (isLeadingLetterDigits ||
        isNumericOnly ||
        isVestasCompact ||
        isComplexAlphaNum) {
      return v;
    }

    debugPrint('   ⚠️ Serial descartado por padrão inválido: $valor');
    return '';
  }

  String _validarItem(String valor) {
    if (valor.isEmpty) return '';
    final raw = valor.trim().toUpperCase();

    // Normaliza confusões típicas de OCR em contexto puramente numérico:
    // O/Q/D → 0,  I/L → 1,  S → 5,  B → 8,  G → 6,  Z → 2
    final v = raw.replaceAllMapped(RegExp(r'[A-Z]'), (m) {
      switch (m.group(0)) {
        case 'O':
        case 'Q':
        case 'D':
          return '0';
        case 'I':
        case 'L':
          return '1';
        case 'S':
          return '5';
        case 'B':
          return '8';
        case 'G':
          return '6';
        case 'Z':
          return '2';
        default:
          return m.group(0)!; // mantém — será rejeitado abaixo
      }
    });

    if (RegExp(r'^\d{5,12}$').hasMatch(v)) return v;

    debugPrint('   ⚠️ Item descartado por padrão inválido: $valor → $v');
    return '';
  }

  String _extrairSerialPorContextoTexto(String texto) {
    final linhas = texto
        .split('\n')
        .map((l) => l.trim().toUpperCase())
        .where((l) => l.isNotEmpty)
        .toList();

    // Recolhe todos os candidatos dentro da janela do label SIN/MANUF/SERIAL.
    // Não devolve o primeiro — escolhe o de maior qualidade.
    final todosOsCandidatos = <String>[];

    for (var i = 0; i < linhas.length; i++) {
      final linha = linhas[i];
      final isLabel = linha.contains('MANUF') ||
          linha.contains('S/N') ||
          linha.contains('SIN') ||
          linha.contains('S1N') ||
          linha.contains('SERIAL');
      if (!isLabel) continue;

      final limite = (i + 6 < linhas.length) ? i + 6 : linhas.length - 1;
      for (var j = i; j <= limite; j++) {
        final candidata = _extrairSerialCombinadoDaLinha(linhas[j]);
        if (candidata.isNotEmpty && !_isLikelyNoiseToken(candidata)) {
          todosOsCandidatos.add(candidata);
        }
      }
    }

    if (todosOsCandidatos.isNotEmpty) {
      // Prefere padrão letra+dígitos (ex: F210205) sobre puramente alfanumérico.
      todosOsCandidatos.sort((a, b) {
        final aStrong = RegExp(r'^[A-Z]{1,3}\d{4,}$').hasMatch(a) ? 1 : 0;
        final bStrong = RegExp(r'^[A-Z]{1,3}\d{4,}$').hasMatch(b) ? 1 : 0;
        if (aStrong != bStrong) return bStrong.compareTo(aStrong);
        return b.length.compareTo(a.length);
      });
      return todosOsCandidatos.first;
    }

    // Fallback global: procura padrão partido em qualquer linha (ex.: F2102 E5)
    for (final linha in linhas) {
      final candidata = _extrairSerialCombinadoDaLinha(linha);
      if (candidata.isNotEmpty && !_isLikelyNoiseToken(candidata)) {
        return candidata;
      }
    }

    return '';
  }

  String _extrairSerialCombinadoDaLinha(String linha) {
    final limpa = linha.replaceAll(RegExp(r'[^A-Z0-9\s/-]'), ' ');

    // Padrão 1: 1-3 letras + dígitos + letras + dígitos opcionais numa só token
    // ex: F2102E5, F210205, F2102ES, TT220043A
    final matchContinuo =
        RegExp(r'\b([A-Z]{1,3}\d{4,12}[A-Z]{1,3}\d{0,4})\b').firstMatch(limpa);
    if (matchContinuo != null) {
      final candidato = _normalizarCodigoMisto(matchContinuo.group(1) ?? '');
      if (!_isLikelyNoiseToken(candidato)) return candidato;
    }

    // Padrão 2: 1-3 letras + dígitos, separados por espaço, ex: F2102 E5, TT220 043
    final matchPartido =
        RegExp(r'\b([A-Z]{1,3}\d{3,10})\s+([A-Z0-9]{1,5})\b').firstMatch(limpa);
    if (matchPartido != null) {
      final combinado =
          '${matchPartido.group(1) ?? ''}${matchPartido.group(2) ?? ''}';
      final candidato = _normalizarCodigoMisto(combinado);
      if (!_isLikelyNoiseToken(candidato) &&
          RegExp(r'\d').hasMatch(candidato)) {
        return candidato;
      }
    }

    // Padrão 3: 1-3 letras + dígitos simples, ex: L04938, F210205, TT220043
    final matchDireto = RegExp(r'\b([A-Z]{1,3}\d{4,12})\b').firstMatch(limpa);
    if (matchDireto != null) {
      final candidato = _normalizarCodigoMisto(matchDireto.group(1) ?? '');
      if (!_isLikelyNoiseToken(candidato)) {
        return candidato;
      }
    }

    return '';
  }

  String _normalizarCodigoMisto(String valor) {
    if (valor.isEmpty) return valor;

    final chars = valor.toUpperCase().split('');
    final normalizados = <String>[];
    // Só corrigimos confusões de OCR enquanto estamos no prefixo numérico
    // (antes de encontrar a primeira letra real do código).
    // Assim 'D' em '000BED5SGK' não é convertido para '0'.
    bool emPrefixoNumerico = true;

    for (var i = 0; i < chars.length; i++) {
      final c = chars[i];

      if (emPrefixoNumerico) {
        if (c == 'O' || c == 'Q' || c == 'D') {
          normalizados.add('0');
          continue;
        }

        if (i < 3 && c == 'E') {
          // Só converte E→0 se o restante da string contém letras (padrão VUI).
          // Se só tiver dígitos a seguir (ex: E57522), é um serial — não converter.
          final restante = valor.toUpperCase().substring(i + 1);
          final temLetrasAFrente = RegExp(r'[A-Z]').hasMatch(restante);
          if (temLetrasAFrente) {
            normalizados.add('0');
            continue;
          }
        }

        // Encontrou uma letra real (não convertida) — fim do prefixo numérico.
        if (RegExp(r'[A-Z]').hasMatch(c)) {
          emPrefixoNumerico = false;
        }
      }

      normalizados.add(c);
    }

    return normalizados.join();
  }

  void _logLinhasOCR(List<_OcrLine> linhas) {
    debugPrint('📌 Linhas OCR reconhecidas: ${linhas.length}');
    for (var i = 0; i < linhas.length; i++) {
      final l = linhas[i];
      debugPrint(
          '   [$i] "${l.text}" @ (${l.rect.left.toStringAsFixed(1)}, ${l.rect.top.toStringAsFixed(1)}) ${l.rect.width.toStringAsFixed(1)}x${l.rect.height.toStringAsFixed(1)}');
    }
  }

  String _inferirVuiPorContexto(
    List<String> linhas, {
    required int idxItem,
    required int idxSerial,
  }) {
    if (linhas.isEmpty) return '';

    final candidatos = <String>[];

    if (idxItem >= 0) {
      final start = (idxItem - 3).clamp(0, linhas.length - 1);
      final end = (idxItem + 2).clamp(0, linhas.length - 1);
      for (var i = start; i <= end; i++) {
        candidatos.addAll(_extrairCandidatosDaLinha(linhas[i]));
      }
    }

    if (idxSerial >= 0) {
      final start = (idxSerial - 2).clamp(0, linhas.length - 1);
      final end = (idxSerial + 3).clamp(0, linhas.length - 1);
      for (var i = start; i <= end; i++) {
        candidatos.addAll(_extrairCandidatosDaLinha(linhas[i]));
      }
    }

    final filtrados = candidatos
        .map((c) => _normalizarCodigoMisto(c.trim().toUpperCase()))
        .where((c) => c.isNotEmpty)
        .where(
            (c) => RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Z0-9-]{8,16}$').hasMatch(c))
        .where((c) => !_isLikelyNoiseToken(c))
        .toSet()
        .toList()
      ..sort((a, b) {
        final aStartsCode = RegExp(r'^[0OQDE]').hasMatch(a) ? 1 : 0;
        final bStartsCode = RegExp(r'^[0OQDE]').hasMatch(b) ? 1 : 0;
        if (aStartsCode != bStartsCode) {
          return bStartsCode.compareTo(aStartsCode);
        }
        return b.length.compareTo(a.length);
      });

    return filtrados.isEmpty ? '' : filtrados.first;
  }

  bool _isLikelyNoiseToken(String token) {
    final t = token.toUpperCase();
    const noiseParts = [
      'MOEN',
      'ENER',
      'MODERN',
      'VESTAS',
      'INSPECT',
      'WHATS',
      'IMAGE',
      'PHOTO',
      'REPORT',
      'APK',
      'GUIDA',
      'GUIA',
      // Ruído do logo/fundo da foto (ex: 2WINDSERVICE)
      'SERVICE',
      'WINDSER',
      'INDSERV',
      // Ruído de embalagens/caixas
      'ASUT',
    ];
    return noiseParts.any((part) => t.contains(part));
  }

  @override
  void dispose() {
    debugPrint('🔄 Fechando OCR Mobile (ML Kit)...');
    _textRecognizer?.close();
    _textRecognizer = null;
    debugPrint('✅ OCR Mobile fechado');
  }
}

class _OcrLine {
  final String text;
  final Rect rect;

  _OcrLine({
    required this.text,
    required this.rect,
  });
}
