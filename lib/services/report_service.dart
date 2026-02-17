import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider do serviço de relatórios
final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

/// Serviço para gerar relatórios (Excel)
class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _getTurbineName(String turbinaId) async {
    try {
      final turbinaDoc =
          await _firestore.collection('turbinas').doc(turbinaId).get();
      if (turbinaDoc.exists) {
        return turbinaDoc.data()?['nome'] ?? turbinaId;
      }
    } catch (e) {
      print('Erro ao buscar nome da turbina: $e');
    }
    return turbinaId;
  }

  String _cleanComponentName(String componentId) {
    if (componentId.contains('_')) {
      final parts = componentId.split('_');
      if (parts.length >= 2) {
        return _formatComponentName(parts[0]);
      }
    }
    return _formatComponentName(componentId);
  }

  String _formatComponentName(String name) {
    final Map<String, String> nameMapping = {
      'bottom': 'Bottom',
      'middle1': 'Middle 1',
      'middle2': 'Middle 2',
      'middle3': 'Middle 3',
      'middle4': 'Middle 4',
      'middle5': 'Middle 5',
      'top': 'Top',
      'nacelle': 'Nacelle',
      'hub': 'Hub',
      'blade_1': 'Blade 1',
      'blade_2': 'Blade 2',
      'blade_3': 'Blade 3',
      'top_cooler': 'Top Cooler',
      'drive_train': 'Drive Train',
      'mv_cable': 'MV Cable',
      'swg': 'SWG',
      'transformador': 'Transformador',
      'gerador': 'Gerador',
      'ground_control': 'Ground Control',
    };
    return nameMapping[name.toLowerCase()] ?? name;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Gerar e salvar relatório localmente
  Future<void> generateAndSendReport({
    required String projectId,
    required String projectName,
    required bool completeReport,
    required List<String> selectedPhases,
    required String language,
  }) async {
    print('═══════════════════════════════════════════════════════════');
    print(' GERANDO RELATÓRIO');
    print('═══════════════════════════════════════════════════════════');
    print('   Projeto: $projectName ($projectId)');
    print('   Formato: excel');
    print('   Completo: $completeReport');
    print('   Fases: $selectedPhases');
    print('───────────────────────────────────────────────────────────');

    // Buscar dados de todas as turbinas do projeto
    final turbinasSnapshot = await _firestore
        .collection('turbinas')
        .where('projectId', isEqualTo: projectId)
        .get();

    print('Turbinas encontradas: ${turbinasSnapshot.docs.length}');

    if (turbinasSnapshot.docs.isEmpty) {
      throw Exception('Nenhuma turbina encontrada no projeto');
    }

    // Coletar dados por fase
    final Map<String, List<Map<String, dynamic>>> dataByPhase = {};

    for (var phase in selectedPhases) {
      print('Coletando dados da fase: $phase');

      // [NEW] VERIFICAR SE É FASE DE GRUAS
      if (phase == 'gruasPads') {
        dataByPhase[phase] = await _collectGruasPadsData(projectId);
      } else if (phase == 'gruasGerais') {
        dataByPhase[phase] = await _collectGruasGeraisData(projectId);
      } else {
        dataByPhase[phase] = await _collectPhaseData(
          projectId,
          turbinasSnapshot.docs.map((d) => d.id).toList(),
          phase,
        );
      }

      print(' ${dataByPhase[phase]!.length} registros encontrados');
    }

    // Gerar arquivo Excel
    print('Gerando Excel...');
    final filePath = await _generateExcelReport(
      projectName,
      dataByPhase,
      selectedPhases,
      completeReport,
      language,
    );
    print('Ficheiro gerado: $filePath');

    // Abrir ficheiro automaticamente
    await _openFile(filePath);

    print('═══════════════════════════════════════════════════════════\n');
  }

  /// Coletar dados de uma fase específica
  Future<List<Map<String, dynamic>>> _collectPhaseData(
    String projectId,
    List<String> turbinaIds,
    String phase,
  ) async {
    final List<Map<String, dynamic>> phaseData = [];

    for (var turbinaId in turbinaIds) {
      final componentesSnapshot = await _firestore
          .collection('installation_data')
          .doc(turbinaId)
          .collection('components')
          .get();

      for (var componentDoc in componentesSnapshot.docs) {
        final componentData = componentDoc.data();
        final componentId = componentDoc.id;

        final phaseInfo = await _extractPhaseInfo(
          componentData,
          phase,
          turbinaId,
          componentId,
        );

        if (phaseInfo != null) {
          phaseData.add(phaseInfo);
        }
      }
    }

    return phaseData;
  }

  /// Extrair informação de uma fase
  Future<Map<String, dynamic>?> _extractPhaseInfo(
    Map<String, dynamic> componentData,
    String phase,
    String turbinaId,
    String componentId,
  ) async {
    final Map<String, String> phaseMapping = {
      'recepcao': 'reception',
      'preparacao': 'preparation',
      'preAssemblagem': 'preAssembly',
      'assemblagem': 'assembly',
      'torqueTensionamento': 'torqueTensioning',
      'fasesFinais': 'finalPhases',
    };

    final phaseKey = phaseMapping[phase];
    if (phaseKey == null) return null;

    final phaseData = componentData[phaseKey];
    if (phaseData == null) return null;

    final turbinaNome = await _getTurbineName(turbinaId);
    final componenteNome = _cleanComponentName(componentId);

    final Map<String, dynamic> info = {
      'turbinaId': turbinaNome,
      'componentId': componenteNome,
      'phase': phase,
    };

    if (phase == 'recepcao') {
      final dataDescarga = phaseData['dataInicio'] != null
          ? (phaseData['dataInicio'] as Timestamp).toDate()
          : null;

      info['vui'] = phaseData['vui'] ?? '';
      info['serialNumber'] = phaseData['serialNumber'] ?? '';
      info['itemNumber'] = phaseData['itemNumber'] ?? '';
      info['dataDescarga'] = _formatDate(dataDescarga);
      info['horaDescarga'] = _formatTime(dataDescarga);
    } else if (phase == 'torqueTensionamento') {
      return null;
    } else {
      final dataInicio = phaseData['dataInicio'] != null
          ? (phaseData['dataInicio'] as Timestamp).toDate()
          : null;
      final dataFim = phaseData['dataFim'] != null
          ? (phaseData['dataFim'] as Timestamp).toDate()
          : null;

      info['vui'] = componentData['reception']?['vui'] ?? '';
      info['serialNumber'] = componentData['reception']?['serialNumber'] ?? '';
      info['itemNumber'] = componentData['reception']?['itemNumber'] ?? '';
      info['dataInicio'] = _formatDate(dataInicio);
      info['horaInicio'] = _formatTime(dataInicio);
      info['dataFim'] = _formatDate(dataFim);
      info['horaFim'] = _formatTime(dataFim);
    }

    return info;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // [NEW] MÉTODOS DE GRUAS
  // ═══════════════════════════════════════════════════════════════════════

  /// Coletar dados de gruas de pads (atribuídas a turbinas)
  Future<List<Map<String, dynamic>>> _collectGruasPadsData(
    String projectId,
  ) async {
    print('Coletando dados de Gruas de Pads...');
    final List<Map<String, dynamic>> gruasData = [];

    final turbinasSnapshot = await _firestore
        .collection('turbinas')
        .where('projectId', isEqualTo: projectId)
        .get();

    for (var turbinaDoc in turbinasSnapshot.docs) {
      final turbinaId = turbinaDoc.id;
      final turbinaNome = turbinaDoc.data()['nome'] ?? turbinaId;

      // Usando a coleção correta: logistica_gruas
      final gruasSnapshot = await _firestore
          .collection('turbinas')
          .doc(turbinaId)
          .collection('logistica_gruas')
          .orderBy('inicio', descending: false)
          .get();

      for (var gruaDoc in gruasSnapshot.docs) {
        final gruaData = gruaDoc.data();

        final inicio = (gruaData['inicio'] as Timestamp?)?.toDate();
        final fim = (gruaData['fim'] as Timestamp?)?.toDate();

        gruasData.add({
          'turbinaId': turbinaNome,
          'gruaModelo':
              gruaData['gruaModelo'] ?? gruaData['modelo'] ?? 'Sem modelo',
          'tipo': gruaData['tipo'] ?? 'trabalho',
          'dataInicio': _formatDate(inicio),
          'horaInicio': _formatTime(inicio),
          'dataFim': _formatDate(fim),
          'horaFim': _formatTime(fim),
          'duracao': _calculateDuration(inicio, fim),
          'motivo': gruaData['motivo'] ?? '',
          'origem': gruaData['origem'] ?? '',
          'destino': gruaData['destino'] ?? '',
          'observacoes': gruaData['observacoes'] ?? '',
        });
      }
    }

    print('Gruas de Pads: ${gruasData.length} atividades');
    return gruasData;
  }

  /// Coletar dados de gruas gerais (não atribuídas a turbinas)
  Future<List<Map<String, dynamic>>> _collectGruasGeraisData(
    String projectId,
  ) async {
    print('Coletando dados de Gruas Gerais...');
    final List<Map<String, dynamic>> gruasData = [];

    final gruasSnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('gruas_gerais')
        .get();

    for (var gruaDoc in gruasSnapshot.docs) {
      final gruaId = gruaDoc.id;
      final gruaData = gruaDoc.data();
      final modelo = gruaData['modelo'] ?? 'Sem modelo';
      final descricao = gruaData['descricao'] ?? '';

      final atividadesSnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('gruas_gerais')
          .doc(gruaId)
          .collection('atividades')
          .orderBy('inicio', descending: false)
          .get();

      for (var atividadeDoc in atividadesSnapshot.docs) {
        final atividadeData = atividadeDoc.data();

        final inicio = (atividadeData['inicio'] as Timestamp?)?.toDate();
        final fim = (atividadeData['fim'] as Timestamp?)?.toDate();

        gruasData.add({
          'turbinaId': 'N/A',
          'gruaModelo': modelo,
          'descricao': descricao,
          'tipo': atividadeData['tipo'] ?? 'trabalho',
          'dataInicio': _formatDate(inicio),
          'horaInicio': _formatTime(inicio),
          'dataFim': _formatDate(fim),
          'horaFim': _formatTime(fim),
          'duracao': _calculateDuration(inicio, fim),
          'motivo': atividadeData['motivo'] ?? '',
          'origem': atividadeData['origem'] ?? '',
          'destino': atividadeData['destino'] ?? '',
          'observacoes': atividadeData['observacoes'] ?? '',
        });
      }
    }

    print('Gruas Gerais: ${gruasData.length} atividades');
    return gruasData;
  }

  /// Calcular duração entre duas datas
  String _calculateDuration(DateTime? inicio, DateTime? fim) {
    if (inicio == null || fim == null) return '';

    final duration = fim.difference(inicio);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    }

    return '';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MÉTODOS DE GERAÇÃO (MANTÉM-SE IGUAL)
  // ═══════════════════════════════════════════════════════════════════════

  Future<String> _generateExcelReport(
    String projectName,
    Map<String, List<Map<String, dynamic>>> dataByPhase,
    List<String> selectedPhases,
    bool completeReport,
    String language,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final documentsPath = Platform.environment['USERPROFILE'] ?? '';
    final documentsDir = Directory('$documentsPath\\Documents');

    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }

    final outputPath = '$documentsPath\\Documents\\report_$timestamp.xlsx';
    final currentDir = Directory.current.path;
    final scriptPath = '$currentDir\\lib\\scripts\\excel_report_generator.py';

    final scriptFile = File(scriptPath);
    if (!await scriptFile.exists()) {
      throw Exception('Script Python não encontrado: $scriptPath');
    }

    final inputData = {
      'projectName': projectName,
      'dataByPhase': _serializeDataForPython(dataByPhase),
      'selectedPhases': selectedPhases,
      'outputPath': outputPath,
      'completeReport': completeReport,
      'language': language,
    };

    final jsonInput = json.encode(inputData);

    print('Executando script Python Excel...');
    print('   Script: $scriptPath');
    print('   Output: $outputPath');

    final process = await Process.start(
      'python',
      [scriptPath],
      runInShell: true,
    );

    process.stdin.write(jsonInput);
    await process.stdin.close();

    final stdout = await process.stdout.transform(utf8.decoder).join();
    final stderr = await process.stderr.transform(utf8.decoder).join();
    final exitCode = await process.exitCode;

    print('Python stdout: $stdout');
    if (stderr.isNotEmpty) print('[WARN] Python stderr: $stderr');
    print('Exit code: $exitCode');

    if (exitCode != 0) {
      throw Exception('Erro ao gerar Excel: $stderr');
    }

    final outputFile = File(outputPath);
    if (!await outputFile.exists()) {
      throw Exception('Ficheiro Excel não foi gerado: $outputPath');
    }

    return outputPath;
  }

  Map<String, dynamic> _serializeDataForPython(
    Map<String, List<Map<String, dynamic>>> dataByPhase,
  ) {
    final serialized = <String, dynamic>{};

    for (var entry in dataByPhase.entries) {
      serialized[entry.key] = entry.value.map((item) {
        final Map<String, dynamic> serializedItem = {};

        for (var itemEntry in item.entries) {
          final value = itemEntry.value;

          if (value is DateTime) {
            serializedItem[itemEntry.key] = value.toIso8601String();
          } else {
            serializedItem[itemEntry.key] = value;
          }
        }

        return serializedItem;
      }).toList();
    }

    return serialized;
  }

  Future<void> _openFile(String filePath) async {
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', filePath],
            runInShell: true);
      } else if (Platform.isMacOS) {
        await Process.run('open', [filePath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [filePath]);
      }
      print('Ficheiro aberto: $filePath');
    } catch (e) {
      print('Erro ao abrir ficheiro: $e');
    }
  }
}
