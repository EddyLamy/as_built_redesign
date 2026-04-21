import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/localization/translation_helper.dart';

class ExportTranslationService {
  ExportTranslationService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final TranslationHelper _englishTranslations =
      TranslationHelper(const Locale('en'));
  final Map<String, String> _cache = <String, String>{};

  static const String _targetLanguage = 'en';
  static const Map<String, String> _glossary = {
    'não aplicável': 'Not applicable',
    'nao aplicável': 'Not applicable',
    'nao aplicavel': 'Not applicable',
    'em curso': 'In progress',
    'em progresso': 'In progress',
    'pendente': 'Pending',
    'concluído': 'Completed',
    'concluido': 'Completed',
    'fechado': 'Closed',
    'fechada': 'Closed',
    'aberto': 'Open',
    'aberta': 'Open',
    'resolvido': 'Resolved',
    'resolvida': 'Resolved',
    'segurança': 'Safety',
    'qualidade': 'Quality',
    'mecânica': 'Mechanical',
    'mecanica': 'Mechanical',
    'elétrica': 'Electrical',
    'eletrica': 'Electrical',
    'civil': 'Civil',
    'logística': 'Logistics',
    'logistica': 'Logistics',
    'documentação': 'Documentation',
    'documentacao': 'Documentation',
  };

  Future<String> translateText(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty || _shouldPreserve(trimmed)) {
      return value;
    }

    if (value.contains('\n')) {
      final lines = value.split('\n');
      final translatedLines = await Future.wait(
        lines.map((line) async {
          if (line.trim().isEmpty) {
            return line;
          }
          return _translateSingleLine(line);
        }),
      );
      return translatedLines.join('\n');
    }

    return _translateSingleLine(value);
  }

  Future<Map<String, dynamic>> translateSelectedFields(
    Map<String, dynamic> source, {
    required Set<String> fields,
  }) async {
    final translated = Map<String, dynamic>.from(source);
    for (final field in fields) {
      final value = translated[field];
      if (value is String && value.trim().isNotEmpty) {
        translated[field] = await translateText(value);
      }
    }
    return translated;
  }

  Future<List<Map<String, dynamic>>> translateRows(
    List<Map<String, dynamic>> rows, {
    required Set<String> fields,
  }) async {
    return Future.wait(
      rows.map((row) => translateSelectedFields(row, fields: fields)),
    );
  }

  Future<List<String>> translateListItems(List<String> values) async {
    return Future.wait(values.map(translateText));
  }

  String translateKnownValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return value;
    }

    final translated = _englishTranslations.translateValueOrKey(trimmed);
    if (translated != trimmed) {
      return _rebuildWithWhitespace(value, translated);
    }

    final glossaryValue = _glossary[trimmed.toLowerCase()];
    if (glossaryValue != null) {
      return _rebuildWithWhitespace(value, glossaryValue);
    }

    return value;
  }

  Future<String> _translateSingleLine(String original) async {
    final trimmed = original.trim();
    if (trimmed.isEmpty || _shouldPreserve(trimmed)) {
      return original;
    }

    final knownValue = translateKnownValue(original);
    if (knownValue != original) {
      return knownValue;
    }

    final cacheKey = trimmed.toLowerCase();
    final cached = _cache[cacheKey];
    if (cached != null) {
      return _rebuildWithWhitespace(original, cached);
    }

    try {
      final uri = Uri.https(
        'translate.googleapis.com',
        '/translate_a/single',
        <String, String>{
          'client': 'gtx',
          'sl': 'auto',
          'tl': _targetLanguage,
          'dt': 't',
          'q': trimmed,
        },
      );

      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        return original;
      }

      final translated = _extractTranslatedText(response.bodyBytes);
      if (translated.isEmpty) {
        return original;
      }

      _cache[cacheKey] = translated;
      return _rebuildWithWhitespace(original, translated);
    } catch (error) {
      debugPrint('Export translation failed for "$trimmed": $error');
      return original;
    }
  }

  String _extractTranslatedText(List<int> bodyBytes) {
    final decoded = json.decode(utf8.decode(bodyBytes));
    if (decoded is! List || decoded.isEmpty || decoded.first is! List) {
      return '';
    }

    final segments = decoded.first as List<dynamic>;
    final buffer = StringBuffer();
    for (final segment in segments) {
      if (segment is List && segment.isNotEmpty && segment.first is String) {
        buffer.write(segment.first as String);
      }
    }

    return buffer.toString().trim();
  }

  bool _shouldPreserve(String value) {
    if (value.isEmpty) {
      return true;
    }

    if (RegExp(r'^[\d\s\-_/.:()#@+%]+$').hasMatch(value)) {
      return true;
    }

    if (RegExp(r'^[A-Z0-9][A-Z0-9\s\-_/.:()#@+%]*$').hasMatch(value)) {
      return true;
    }

    if (RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        .hasMatch(value)) {
      return true;
    }

    if (value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('www.')) {
      return true;
    }

    if (RegExp(r'^[A-Z]{2,}-\d+$').hasMatch(value)) {
      return true;
    }

    return false;
  }

  String _rebuildWithWhitespace(String original, String translated) {
    final leadingWhitespace =
        original.substring(0, original.length - original.trimLeft().length);
    final trailingWhitespace =
        original.substring(original.trimRight().length, original.length);
    return '$leadingWhitespace$translated$trailingWhitespace';
  }
}
