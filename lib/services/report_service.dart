import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'daily_journal_service.dart';
import 'export_translation_service.dart';
import 'safety_alert_service.dart';
import 'team_service.dart';

/// Provider do serviço de relatórios
final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

/// Serviço para gerar relatórios (Excel)
class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TeamService _teamService = TeamService();
  final ExportTranslationService _exportTranslationService =
      ExportTranslationService();
  final SafetyAlertService _safetyAlertService = SafetyAlertService();

  static const String _dailyJournalPhaseKey = 'dailyJournal';
  static const String _exportLanguage = 'en';

  Future<String> _getTurbineName(String turbinaId) async {
    try {
      final turbinaDoc =
          await _firestore.collection('turbinas').doc(turbinaId).get();
      if (turbinaDoc.exists) {
        return turbinaDoc.data()?['nome'] ?? turbinaId;
      }
    } catch (e) {
      debugPrint('Erro ao buscar nome da turbina: $e');
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

  int? _parseJournalTimeToMinutes(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final hours = int.tryParse(match.group(1)!);
    final minutes = int.tryParse(match.group(2)!);
    if (hours == null || minutes == null || minutes < 0 || minutes > 59) {
      return null;
    }

    return (hours * 60) + minutes;
  }

  String _formatJournalMinutes(int minutes) {
    final safeMinutes = minutes < 0 ? 0 : minutes;
    final hours = safeMinutes ~/ 60;
    final remainingMinutes = safeMinutes % 60;
    return '$hours:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _normalizePeopleHoursEntries(dynamic value) {
    final rows = value as List<dynamic>? ?? const [];

    return rows
        .map((row) {
          if (row is! Map) {
            return null;
          }

          final mapped = row.map(
            (key, rowValue) => MapEntry(key.toString(), rowValue),
          );
          final initials = (mapped['initials'] as String?)?.trim() ?? '';
          final startTime = (mapped['startTime'] as String?)?.trim() ?? '';
          final finishTime = (mapped['finishTime'] as String?)?.trim() ?? '';
          final travellingTime =
              (mapped['travellingTime'] as String?)?.trim().isNotEmpty == true
                  ? (mapped['travellingTime'] as String).trim()
                  : '0:00';

          if (initials.isEmpty &&
              startTime.isEmpty &&
              finishTime.isEmpty &&
              travellingTime == '0:00') {
            return null;
          }

          final startMinutes = _parseJournalTimeToMinutes(startTime);
          final finishMinutes = _parseJournalTimeToMinutes(finishTime);
          final travellingMinutes =
              _parseJournalTimeToMinutes(travellingTime) ?? 0;
          final manhours = (startMinutes != null && finishMinutes != null)
              ? _formatJournalMinutes(
                  finishMinutes - startMinutes - travellingMinutes,
                )
              : '0:00';

          return {
            'initials': initials,
            'startTime': startTime,
            'finishTime': finishTime,
            'travellingTime': travellingTime,
            'manhours': manhours,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  String _sumPeopleHours(List<Map<String, dynamic>> rows) {
    var totalMinutes = 0;
    for (final row in rows) {
      totalMinutes += _parseJournalTimeToMinutes(
            (row['manhours'] as String?) ?? '',
          ) ??
          0;
    }

    return _formatJournalMinutes(totalMinutes);
  }

  List<Map<String, dynamic>> _normalizeWaitingTimeEntries(dynamic value) {
    final rows = value as List<dynamic>? ?? const [];

    return rows
        .map((row) {
          if (row is! Map) {
            return null;
          }

          final mapped = row.map(
            (key, rowValue) => MapEntry(key.toString(), rowValue),
          );
          final responsible = (mapped['responsible'] as String?)?.trim() ?? '';
          final company = (mapped['company'] as String?)?.trim() ?? '';
          final people = (mapped['people'] as String?)?.trim() ?? '';
          final totalHours = (mapped['totalHours'] as String?)?.trim() ?? '';
          final description = (mapped['description'] as String?)?.trim() ?? '';

          if (responsible.isEmpty &&
              company.isEmpty &&
              people.isEmpty &&
              totalHours.isEmpty &&
              description.isEmpty) {
            return null;
          }

          final peopleCount = int.tryParse(people) ?? 0;
          final totalMinutes = _parseJournalTimeToMinutes(totalHours) ?? 0;

          return {
            'responsible': responsible,
            'company': company,
            'people': people,
            'totalHours': totalHours,
            'manhours': _formatJournalMinutes(totalMinutes * peopleCount),
            'description': description,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  String _sumWaitingTime(List<Map<String, dynamic>> rows) {
    var totalMinutes = 0;
    for (final row in rows) {
      totalMinutes += _parseJournalTimeToMinutes(
            (row['manhours'] as String?) ?? '',
          ) ??
          0;
    }

    return _formatJournalMinutes(totalMinutes);
  }

  List<Map<String, dynamic>> _normalizeWindMeasurements(dynamic value) {
    const expectedSlots = ['8:00', '10:00', '12:00', '14:00', '16:00', '18:00'];
    final rows = value as List<dynamic>? ?? const [];
    final availableSlots = <String>{};

    for (final row in rows) {
      if (row is! Map) {
        continue;
      }

      final mapped = row.map(
        (key, rowValue) => MapEntry(key.toString(), rowValue),
      );
      final timeLabel = (mapped['timeLabel'] as String?)?.trim() ?? '';
      if (timeLabel.isNotEmpty) {
        availableSlots.add(timeLabel);
      }
    }

    return expectedSlots
        .map(
          (slot) => {
            'timeLabel': slot,
            if (availableSlots.contains(slot)) 'registered': true,
          },
        )
        .toList(growable: false);
  }

  String _equipmentTypeLabel(String type, {String language = _exportLanguage}) {
    const mapPt = {
      'chave_torque': 'Chave de Torque',
      'bomba_torque': 'Bomba de Torque',
      'puller': 'Puller',
      'bomba_tensionamento': 'Bomba de Tensionamento',
      'chave_dinometrica': 'Chave Dinométrica',
      'outro': 'Outro',
    };
    const mapEn = {
      'chave_torque': 'Torque Wrench',
      'bomba_torque': 'Torque Pump',
      'puller': 'Puller',
      'bomba_tensionamento': 'Tensioning Pump',
      'chave_dinometrica': 'Dynamometric Wrench',
      'outro': 'Other',
    };
    final map = language == 'en' ? mapEn : mapPt;
    return map[type] ?? type;
  }

  String _equipmentStatusLabel(String status,
      {String language = _exportLanguage}) {
    const mapPt = {
      'disponivel': 'Disponível',
      'em_uso': 'Em Uso',
      'manutencao': 'Manutenção',
      'expirado': 'Expirado',
    };
    const mapEn = {
      'disponivel': 'Available',
      'em_uso': 'In Use',
      'manutencao': 'Maintenance',
      'expirado': 'Expired',
    };
    final map = language == 'en' ? mapEn : mapPt;
    return map[status] ?? status;
  }

  String _equipmentConditionLabel(String condition,
      {String language = _exportLanguage}) {
    const mapPt = {
      'bom': 'Bom',
      'regular': 'Regular',
      'necessita_manutencao': 'Necessita Manutenção',
    };
    const mapEn = {
      'bom': 'Good',
      'regular': 'Fair',
      'necessita_manutencao': 'Needs Maintenance',
    };
    final map = language == 'en' ? mapEn : mapPt;
    return map[condition] ?? condition;
  }

  String _ncrCategoryLabel(String category,
      {String language = _exportLanguage}) {
    const mapEn = {
      'quality': 'Quality',
      'mechanical': 'Mechanical',
      'electrical': 'Electrical',
      'civil': 'Civil',
      'safety': 'Safety',
      'logistics': 'Logistics',
      'documentation': 'Documentation',
      'other': 'Other',
    };
    const mapPt = {
      'quality': 'Qualidade',
      'mechanical': 'Mecânica',
      'electrical': 'Elétrica',
      'civil': 'Civil',
      'safety': 'Segurança',
      'logistics': 'Logística',
      'documentation': 'Documentação',
      'other': 'Outro',
    };
    final map = language == 'en' ? mapEn : mapPt;
    return map[category] ?? category;
  }

  String _ncrSeverityLabel(String severity,
      {String language = _exportLanguage}) {
    const mapEn = {
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'critical': 'Critical',
    };
    const mapPt = {
      'low': 'Baixa',
      'medium': 'Média',
      'high': 'Alta',
      'critical': 'Crítica',
    };
    final map = language == 'en' ? mapEn : mapPt;
    return map[severity] ?? severity;
  }

  String _ncrStatusLabel(String status, {String language = _exportLanguage}) {
    const mapEn = {
      'open': 'Open',
      'in_progress': 'In Progress',
      'pending_validation': 'Pending Validation',
      'resolved': 'Resolved',
      'closed': 'Closed',
    };
    const mapPt = {
      'open': 'Aberta',
      'in_progress': 'Em Curso',
      'pending_validation': 'Validação Pendente',
      'resolved': 'Resolvida',
      'closed': 'Fechada',
    };
    final map = language == 'en' ? mapEn : mapPt;
    return map[status] ?? status;
  }

  String _safetyAlertCategoryLabel(String category,
      {String language = _exportLanguage}) {
    const mapEn = {
      'near_miss': 'Near Miss',
      'hazardous_observation': 'Safety Alert',
      'walk_and_talk': 'Walk and Talk',
    };
    const mapPt = {
      'near_miss': 'Near Miss',
      'hazardous_observation': 'Safety Alert',
      'walk_and_talk': 'Walk and Talk',
    };
    final map = language == 'en' ? mapEn : mapPt;
    return map[category] ?? category;
  }

  String _safetyAlertStatusLabel(String status,
      {String language = _exportLanguage}) {
    const mapEn = {
      'resolved': 'Resolved',
      'under_study': 'Under Study',
      'in_resolution': 'In Resolution',
      'future_company_action': 'Future Company Action Required',
    };
    const mapPt = {
      'resolved': 'Resolvido',
      'under_study': 'Em estudo',
      'in_resolution': 'Em fase de resolução',
      'future_company_action': 'Requer ação futura da companhia',
    };
    final map = language == 'en' ? mapEn : mapPt;
    return map[status] ?? status;
  }

  /// Gerar e salvar relatório localmente
  Future<void> generateAndSendReport({
    required String projectId,
    required String projectName,
    required bool completeReport,
    required List<String> selectedPhases,
    required String language,
  }) async {
    final exportLanguage = _exportLanguage;
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint(' GERANDO RELATÓRIO');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('   Projeto: $projectName ($projectId)');
    debugPrint('   Formato: excel');
    debugPrint('   Completo: $completeReport');
    debugPrint('   Fases: $selectedPhases');
    debugPrint('───────────────────────────────────────────────────────────');

    final includeDailyJournal = selectedPhases.contains(_dailyJournalPhaseKey);
    final standardPhases = selectedPhases
        .where((phase) => phase != _dailyJournalPhaseKey)
        .toList(growable: false);
    final generatedFiles = <String>[];

    if (standardPhases.isNotEmpty) {
      // Buscar dados de todas as turbinas do projeto (quando necessário)
      final turbinasSnapshot = await _firestore
          .collection('turbinas')
          .where('projectId', isEqualTo: projectId)
          .get();

      debugPrint('Turbinas encontradas: ${turbinasSnapshot.docs.length}');

      final phasesWithoutTurbines = {
        'gruasGerais',
        'equipamentos',
        'ncrs',
        'safetyAlerts',
      };
      final needsTurbines = standardPhases.any(
        (phase) => !phasesWithoutTurbines.contains(phase),
      );

      if (needsTurbines && turbinasSnapshot.docs.isEmpty) {
        throw Exception('Nenhuma turbina encontrada no projeto');
      }

      // Coletar dados por fase
      final Map<String, List<Map<String, dynamic>>> dataByPhase = {};

      for (var phase in standardPhases) {
        debugPrint('Coletando dados da fase: $phase');

        // [NEW] VERIFICAR SE É FASE DE GRUAS
        if (phase == 'gruasPads') {
          dataByPhase[phase] = await _collectGruasPadsData(projectId);
        } else if (phase == 'gruasGerais') {
          dataByPhase[phase] = await _collectGruasGeraisData(projectId);
        } else if (phase == 'equipamentos') {
          dataByPhase[phase] = await _collectEquipamentosData(projectId,
              language: exportLanguage);
        } else if (phase == 'ncrs') {
          dataByPhase[phase] =
              await _collectNcrsData(projectId, language: exportLanguage);
        } else if (phase == 'safetyAlerts') {
          dataByPhase[phase] = await _collectSafetyAlertsData(
            projectId,
            language: exportLanguage,
          );
        } else {
          dataByPhase[phase] = await _collectPhaseData(
            projectId,
            turbinasSnapshot.docs.map((d) => d.id).toList(),
            phase,
          );
        }

        debugPrint(' ${dataByPhase[phase]!.length} registros encontrados');
      }

      debugPrint('Gerando Excel...');
      final translatedProjectName =
          await _exportTranslationService.translateText(projectName);
      final translatedDataByPhase =
          await _translateExportDataForEnglish(dataByPhase);
      final reportPath = await _generateExcelReport(
        translatedProjectName,
        translatedDataByPhase,
        standardPhases,
        completeReport,
        exportLanguage,
      );
      debugPrint('Ficheiro gerado: $reportPath');
      generatedFiles.add(reportPath);
    }

    if (includeDailyJournal) {
      final dailyJournalPath =
          await _generateDailyJournalTemplate(projectId, projectName);
      debugPrint('Daily Journal gerado: $dailyJournalPath');
      generatedFiles.add(dailyJournalPath);
    }

    if (generatedFiles.isEmpty) {
      throw Exception('Nenhum tipo de relatório foi selecionado');
    }

    for (final filePath in generatedFiles) {
      await _openFile(filePath);
    }

    debugPrint('═══════════════════════════════════════════════════════════\n');
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
    debugPrint('Coletando dados de Gruas de Pads...');
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

    debugPrint('Gruas de Pads: ${gruasData.length} atividades');
    return gruasData;
  }

  /// Coletar dados de gruas gerais (não atribuídas a turbinas)
  Future<List<Map<String, dynamic>>> _collectGruasGeraisData(
    String projectId,
  ) async {
    debugPrint('Coletando dados de Gruas Gerais...');
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

    debugPrint('Gruas Gerais: ${gruasData.length} atividades');
    return gruasData;
  }

  /// Coletar dados de rastreabilidade de equipamentos do projeto
  Future<List<Map<String, dynamic>>> _collectEquipamentosData(String projectId,
      {String language = _exportLanguage}) async {
    debugPrint('Coletando dados de Equipamentos...');

    final List<Map<String, dynamic>> equipamentosData = [];
    final snapshot = await _firestore
        .collection('equipment')
        .where('projectId', isEqualTo: projectId)
        .get();

    final sortedDocs = [...snapshot.docs]..sort((a, b) {
        final modelA = (a.data()['model'] ?? '').toString().toLowerCase();
        final modelB = (b.data()['model'] ?? '').toString().toLowerCase();
        return modelA.compareTo(modelB);
      });

    for (final doc in sortedDocs) {
      final data = doc.data();
      final usageHistory = (data['usageHistory'] as List<dynamic>? ?? const []);

      final baseData = {
        'equipmentId': data['equipmentId'] ?? doc.id,
        'type': _equipmentTypeLabel(
          (data['type'] ?? '').toString(),
          language: language,
        ),
        'manufacturer': data['manufacturer'] ?? '',
        'model': data['model'] ?? '',
        'serialNumber': data['serialNumber'] ?? '',
        'status': _equipmentStatusLabel(
          (data['status'] ?? '').toString(),
          language: language,
        ),
        'condition': _equipmentConditionLabel(
          (data['condition'] ?? '').toString(),
          language: language,
        ),
        'calibrationLastDate': data['calibration']?['lastDate'] ?? '',
        'calibrationExpiryDate': data['calibration']?['expiryDate'] ?? '',
        'certificateNumber': data['calibration']?['certificateNumber'] ?? '',
        'currentLocation': data['currentLocation'] ?? '',
        'currentProjectName': data['currentProjectName'] ?? '',
        'notes': data['notes'] ?? '',
      };

      if (usageHistory.isEmpty) {
        equipamentosData.add({
          ...baseData,
          'usageDate': '',
          'usageTurbineId': '',
          'usageConnection': '',
          'usageOperation': '',
          'usageUser': '',
        });
        continue;
      }

      for (final record in usageHistory) {
        if (record is! Map) continue;

        equipamentosData.add({
          ...baseData,
          'usageDate': record['date'] ?? '',
          'usageTurbineId': record['turbineId'] ?? '',
          'usageConnection': record['connection'] ?? '',
          'usageOperation': record['operation'] ?? '',
          'usageUser': record['user'] ?? '',
        });
      }
    }

    debugPrint('Equipamentos: ${equipamentosData.length} registros');
    return equipamentosData;
  }

  Future<List<Map<String, dynamic>>> _collectNcrsData(
    String projectId, {
    String language = _exportLanguage,
  }) async {
    debugPrint('Coletando dados de NCRs...');

    final snapshot = await _firestore
        .collection('ncrs')
        .where('projectId', isEqualTo: projectId)
        .get();

    final docs = [...snapshot.docs]..sort((a, b) {
        final aDate = (a.data()['createdAt'] as Timestamp?)?.toDate();
        final bDate = (b.data()['createdAt'] as Timestamp?)?.toDate();
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

    return docs.map((doc) {
      final data = doc.data();
      final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      final closedAt = (data['closedAt'] as Timestamp?)?.toDate();
      final evidence = data['evidence'] as List<dynamic>? ?? const <dynamic>[];
      final history =
          data['statusHistory'] as List<dynamic>? ?? const <dynamic>[];

      return {
        'code': data['code'] ?? doc.id,
        'title': data['title'] ?? '',
        'description': data['description'] ?? '',
        'turbina': data['turbinaNome'] ?? '',
        'category': _ncrCategoryLabel(
          (data['category'] ?? '').toString(),
          language: language,
        ),
        'severity': _ncrSeverityLabel(
          (data['severity'] ?? '').toString(),
          language: language,
        ),
        'status': _ncrStatusLabel(
          (data['status'] ?? '').toString(),
          language: language,
        ),
        'assignedTo': data['assignedTo'] ?? '',
        'dueDate': _formatDate(dueDate),
        'createdAt': _formatDate(createdAt),
        'closedAt': _formatDate(closedAt),
        'closedByName': data['closedByName'] ?? '',
        'closureNote': data['closureNote'] ?? '',
        'historyCount': history.length,
        'latestStatusNote':
            history.isNotEmpty ? ((history.last as Map?)?['note'] ?? '') : '',
        'evidenceCount': evidence.length,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _collectSafetyAlertsData(
    String projectId, {
    String language = _exportLanguage,
  }) async {
    debugPrint('Coletando dados de IMS...');

    final alerts =
        await _safetyAlertService.watchProjectAlerts(projectId).first;

    return alerts.map((alert) {
      return {
        'code': alert.code,
        'category': _safetyAlertCategoryLabel(
          alert.category.value,
          language: language,
        ),
        'status': _safetyAlertStatusLabel(
          alert.status.value,
          language: language,
        ),
        'destinationTo': alert.destinationTo,
        'department': alert.department,
        'problemDescription': alert.problemDescription,
        'proposedSolution': alert.proposedSolution,
        'resolucaoEfetuada': alert.resolucaoEfetuada,
        'problemPhotos': alert.evidence.length,
        'resolutionPhotos': alert.resolutionEvidence.length,
        'createdByName': alert.createdByName,
        'createdAt': _formatDate(alert.createdAt),
        'updatedAt': _formatDate(alert.updatedAt),
      };
    }).toList();
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      _translateExportDataForEnglish(
    Map<String, List<Map<String, dynamic>>> dataByPhase,
  ) async {
    final translated = <String, List<Map<String, dynamic>>>{};

    for (final entry in dataByPhase.entries) {
      switch (entry.key) {
        case 'gruasPads':
        case 'gruasGerais':
          translated[entry.key] = await _exportTranslationService.translateRows(
            entry.value,
            fields: const {'descricao', 'observacoes'},
          );
          break;
        case 'equipamentos':
          translated[entry.key] = await _exportTranslationService.translateRows(
            entry.value,
            fields: const {'currentProjectName', 'notes'},
          );
          break;
        case 'ncrs':
          translated[entry.key] = await _exportTranslationService.translateRows(
            entry.value,
            fields: const {
              'title',
              'description',
              'closureNote',
              'latestStatusNote',
            },
          );
          break;
        case 'safetyAlerts':
          translated[entry.key] = await _exportTranslationService.translateRows(
            entry.value,
            fields: const {
              'destinationTo',
              'department',
              'problemDescription',
              'proposedSolution',
              'resolucaoEfetuada',
            },
          );
          break;
        default:
          translated[entry.key] = entry.value;
      }
    }

    return translated;
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

    debugPrint('Executando script Python Excel...');
    debugPrint('   Script: $scriptPath');
    debugPrint('   Output: $outputPath');

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

    debugPrint('Python stdout: $stdout');
    if (stderr.isNotEmpty) debugPrint('[WARN] Python stderr: $stderr');
    debugPrint('Exit code: $exitCode');

    if (exitCode != 0) {
      throw Exception('Erro ao gerar Excel: $stderr');
    }

    final outputFile = File(outputPath);
    if (!await outputFile.exists()) {
      throw Exception('Ficheiro Excel não foi gerado: $outputPath');
    }

    return outputPath;
  }

  Future<String> _generateDailyJournalTemplate(
    String projectId,
    String projectName,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final documentsPath = Platform.environment['USERPROFILE'] ?? '';
    final documentsDir = Directory('$documentsPath\\Documents');

    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }

    final templateFile = await _findDailyJournalTemplate();
    final safeProjectName = _sanitizeFileName(projectName);
    final outputPath =
        '$documentsPath\\Documents\\daily_journal_${safeProjectName}_$timestamp.xlsm';

    await templateFile.copy(outputPath);
    final dailyJournalData =
        await _buildDailyJournalExportData(projectId, projectName);
    await _populateDailyJournalHeader(
      workbookPath: outputPath,
      headerData: dailyJournalData,
    );

    return outputPath;
  }

  Future<Map<String, dynamic>> _buildDailyJournalExportData(
    String projectId,
    String projectName,
  ) async {
    final projectDoc =
        await _firestore.collection('projects').doc(projectId).get();
    final projectData = projectDoc.data() ?? const <String, dynamic>{};
    final journals = await DailyJournalService().getAllJournals(projectId);

    if (journals.isEmpty) {
      throw Exception(
          'Ainda não existe nenhum Daily Journal guardado para este projeto.');
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> appUserData = const <String, dynamic>{};
    if (firebaseUser != null) {
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      appUserData = userDoc.data() ?? const <String, dynamic>{};
    }

    final currentUserName =
        (appUserData['name'] as String?)?.trim().isNotEmpty == true
            ? (appUserData['name'] as String).trim()
            : (firebaseUser?.displayName?.trim().isNotEmpty == true
                ? firebaseUser!.displayName!.trim()
                : _nameFromEmail(firebaseUser?.email));

    final installationTeamCount =
        await _teamService.countPeopleInCategory(projectId, 'turbine_assembly');
    final craneCrewCount =
        await _teamService.countPeopleInCategory(projectId, 'cranes');
    final sortedJournals = List<Map<String, dynamic>>.from(journals)
      ..sort((left, right) {
        final leftDate = (left['journalDate'] as Timestamp?)?.toDate();
        final rightDate = (right['journalDate'] as Timestamp?)?.toDate();
        final byDate =
            (leftDate ?? DateTime(1970)).compareTo(rightDate ?? DateTime(1970));
        if (byDate != 0) {
          return byDate;
        }

        final leftReportNo = (left['reportNo'] as num?)?.toInt() ?? 0;
        final rightReportNo = (right['reportNo'] as num?)?.toInt() ?? 0;
        return leftReportNo.compareTo(rightReportNo);
      });

    final journalsByDate = <String, Map<String, dynamic>>{};
    for (final journal in sortedJournals) {
      final journalDate = (journal['journalDate'] as Timestamp?)?.toDate();
      final journalDateKey =
          (journal['journalDateKey'] as String?)?.trim().isNotEmpty == true
              ? (journal['journalDateKey'] as String).trim()
              : journalDate?.toIso8601String().split('T').first ??
                  'report_${(journal['reportNo'] as num?)?.toInt() ?? 0}';
      final peopleHoursEntries =
          _normalizePeopleHoursEntries(journal['peopleHoursEntries']);
      final waitingTimeEntries =
          _normalizeWaitingTimeEntries(journal['waitingTimeEntries']);
      final windMeasurements =
          _normalizeWindMeasurements(journal['windMeasurements']);

      journalsByDate[journalDateKey] = {
        'reportNo': (journal['reportNo'] as num?)?.toInt() ?? 0,
        'initials': (journal['initials'] as String?)?.trim().isNotEmpty == true
            ? (journal['initials'] as String).trim()
            : _buildInitials(currentUserName, firebaseUser?.email),
        'journalDate': journalDate?.toIso8601String(),
        'installationTeamCount':
            (journal['installationTeamCount'] as num?)?.toInt() ??
                installationTeamCount,
        'craneCrewCount':
            (journal['craneCrewCount'] as num?)?.toInt() ?? craneCrewCount,
        'remarks': (journal['remarks'] as String?)?.trim() ?? '',
        'peopleHoursEntries': peopleHoursEntries,
        'totalManhours': _sumPeopleHours(peopleHoursEntries),
        'waitingTimeEntries': waitingTimeEntries,
        'totalWaitingManhours': _sumWaitingTime(waitingTimeEntries),
        'windMeasurements': windMeasurements,
        'siteWorkProgress':
            (journal['siteWorkProgress'] as List<dynamic>? ?? const []),
      };
    }

    final exportJournals = journalsByDate.values.toList(growable: false)
      ..sort((left, right) {
        final leftDate =
            DateTime.tryParse(left['journalDate'] as String? ?? '');
        final rightDate =
            DateTime.tryParse(right['journalDate'] as String? ?? '');
        return (leftDate ?? DateTime(1970))
            .compareTo(rightDate ?? DateTime(1970));
      });

    final translatedProjectName = await _exportTranslationService.translateText(
      ((projectData['nome'] as String?)?.trim().isNotEmpty == true)
          ? (projectData['nome'] as String).trim()
          : projectName,
    );

    final translatedJournals = await Future.wait(
      exportJournals.map((journal) async {
        final translatedSiteWorkProgress = await Future.wait(
          (journal['siteWorkProgress'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map((row) => _exportTranslationService.translateSelectedFields(
                    Map<String, dynamic>.from(row),
                    fields: const {'category', 'subCategory', 'notes'},
                  )),
        );

        final translatedWaitingEntries =
            await _exportTranslationService.translateRows(
          List<Map<String, dynamic>>.from(
            (journal['waitingTimeEntries'] as List<dynamic>? ??
                    const <dynamic>[])
                .whereType<Map>()
                .map((row) => Map<String, dynamic>.from(row)),
          ),
          fields: const {'description'},
        );

        return {
          ...journal,
          'remarks': await _exportTranslationService.translateText(
            (journal['remarks'] as String?) ?? '',
          ),
          'siteWorkProgress': translatedSiteWorkProgress,
          'waitingTimeEntries': translatedWaitingEntries,
        };
      }),
    );

    return {
      'projectNo':
          ((projectData['projectId'] as String?)?.trim().isNotEmpty == true)
              ? (projectData['projectId'] as String).trim()
              : projectId,
      'projectName': translatedProjectName,
      'journals': translatedJournals,
      if (installationTeamCount > 0)
        'installationTeamCount': installationTeamCount,
      if (craneCrewCount > 0) 'craneCrewCount': craneCrewCount,
    };
  }

  Future<void> _populateDailyJournalHeader({
    required String workbookPath,
    required Map<String, dynamic> headerData,
  }) async {
    if (!Platform.isWindows) {
      debugPrint(
          'Daily Journal header auto-fill está disponível apenas no Windows.');
      return;
    }

    final currentDir = Directory.current.path;
    final scriptPath =
        '$currentDir\\lib\\scripts\\fill_daily_journal_header.ps1';
    final scriptFile = File(scriptPath);
    if (!await scriptFile.exists()) {
      throw Exception('Script PowerShell não encontrado: $scriptPath');
    }

    final headerJsonBase64 = base64Encode(utf8.encode(json.encode(headerData)));
    final result = await Process.run(
      'powershell',
      [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        scriptPath,
        '-WorkbookPath',
        workbookPath,
        '-HeaderJsonBase64',
        headerJsonBase64,
      ],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      final stderr = result.stderr.toString().trim();
      throw Exception(
        stderr.isEmpty
            ? 'Falha ao preencher o cabeçalho do Daily Journal.'
            : 'Falha ao preencher o cabeçalho do Daily Journal: $stderr',
      );
    }

    final stdout = result.stdout.toString().trim();
    if (stdout.isNotEmpty) {
      debugPrint('Daily Journal header: $stdout');
    }
  }

  Future<File> _findDailyJournalTemplate() async {
    final currentDir = Directory.current;
    final entries = await currentDir.list().toList();
    final xlsmFiles = entries.whereType<File>().where((file) {
      return file.path.toLowerCase().endsWith('.xlsm');
    }).toList();

    if (xlsmFiles.isEmpty) {
      throw Exception(
          'Template Daily Journal (.xlsm) não encontrado no projeto');
    }

    xlsmFiles.sort((a, b) {
      final aName = a.uri.pathSegments.last.toLowerCase();
      final bName = b.uri.pathSegments.last.toLowerCase();
      final aScore = (aName.contains('daily') ? 2 : 0) +
          (aName.contains('journal') ? 1 : 0);
      final bScore = (bName.contains('daily') ? 2 : 0) +
          (bName.contains('journal') ? 1 : 0);
      return bScore.compareTo(aScore);
    });

    return xlsmFiles.first;
  }

  String _sanitizeFileName(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  String _nameFromEmail(String? email) {
    if (email == null || email.trim().isEmpty) return 'Utilizador';
    return email.split('@').first.trim();
  }

  String _buildInitials(String? name, String? email) {
    final normalized = (name ?? '').trim();
    if (normalized.isNotEmpty) {
      final parts = normalized
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) {
        final letters = parts.take(3).map((part) => part[0]).join();
        return letters.toLowerCase();
      }
    }

    final fallback =
        _nameFromEmail(email).replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    return fallback.isEmpty
        ? 'user'
        : fallback.substring(0, fallback.length.clamp(1, 4)).toLowerCase();
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
      debugPrint('Ficheiro aberto: $filePath');
    } catch (e) {
      debugPrint('Erro ao abrir ficheiro: $e');
    }
  }
}
