import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider do serviço de relatórios
final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

/// Serviço para gerar relatórios (Excel/PDF)
class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gerar e enviar relatório por email
  Future<void> generateAndSendReport({
    required String projectId,
    required String projectName,
    required String format, // 'excel' ou 'pdf'
    required List<String> selectedPhases,
  }) async {
    print('🔵 Gerando relatório...');
    print('   Projeto: $projectName');
    print('   Formato: $format');
    print('   Fases: $selectedPhases');

    // Buscar dados de todas as turbinas do projeto
    final turbinasSnapshot = await _firestore
        .collection('turbinas')
        .where('projectId', isEqualTo: projectId)
        .get();

    if (turbinasSnapshot.docs.isEmpty) {
      throw Exception('Nenhuma turbina encontrada no projeto');
    }

    // Coletar dados por fase
    final Map<String, List<Map<String, dynamic>>> dataByPhase = {};

    for (var phase in selectedPhases) {
      dataByPhase[phase] = await _collectPhaseData(
        projectId,
        turbinasSnapshot.docs.map((d) => d.id).toList(),
        phase,
      );
    }

    // Gerar arquivo conforme formato
    String filePath;
    if (format == 'excel') {
      filePath = await _generateExcelReport(
        projectName,
        dataByPhase,
        selectedPhases,
      );
    } else {
      filePath = await _generatePDFReport(
        projectName,
        dataByPhase,
        selectedPhases,
      );
    }

    // Enviar por email
    await _sendReportByEmail(filePath, projectName, format);

    print('✅ Relatório gerado e enviado!');
  }

  /// Coletar dados de uma fase específica
  Future<List<Map<String, dynamic>>> _collectPhaseData(
    String projectId,
    List<String> turbinaIds,
    String phase,
  ) async {
    final List<Map<String, dynamic>> phaseData = [];

    for (var turbinaId in turbinaIds) {
      // Buscar todos os componentes da turbina
      final componentesSnapshot = await _firestore
          .collection('installation_data')
          .doc(turbinaId)
          .collection('components')
          .get();

      for (var componentDoc in componentesSnapshot.docs) {
        final componentData = componentDoc.data();
        final componentId = componentDoc.id;

        // Extrair dados da fase específica
        final phaseInfo = _extractPhaseInfo(
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
  Map<String, dynamic>? _extractPhaseInfo(
    Map<String, dynamic> componentData,
    String phase,
    String turbinaId,
    String componentId,
  ) {
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

    // Extrair campos comuns
    final Map<String, dynamic> info = {
      'turbinaId': turbinaId,
      'componentId': componentId,
      'phase': phase,
    };

    // Campos específicos por fase
    if (phase == 'recepcao') {
      info['vui'] = phaseData['vui'] ?? '';
      info['serialNumber'] = phaseData['serialNumber'] ?? '';
      info['itemNumber'] = phaseData['itemNumber'] ?? '';
      info['dataDescarga'] = phaseData['dataInicio'] != null
          ? (phaseData['dataInicio'] as Timestamp).toDate()
          : null;
    } else if (phase == 'torqueTensionamento') {
      // Dados de torque são diferentes - buscar de conexões
      return null; // Implementar separadamente
    } else {
      // Fases normais (preparação, pré-assemblagem, assemblagem)
      info['vui'] = componentData['reception']?['vui'] ?? '';
      info['serialNumber'] = componentData['reception']?['serialNumber'] ?? '';
      info['itemNumber'] = componentData['reception']?['itemNumber'] ?? '';
      info['dataInicio'] = phaseData['dataInicio'] != null
          ? (phaseData['dataInicio'] as Timestamp).toDate()
          : null;
      info['dataFim'] = phaseData['dataFim'] != null
          ? (phaseData['dataFim'] as Timestamp).toDate()
          : null;
    }

    return info;
  }

  /// Gerar relatório Excel
  Future<String> _generateExcelReport(
    String projectName,
    Map<String, List<Map<String, dynamic>>> dataByPhase,
    List<String> selectedPhases,
  ) async {
    // Este método será implementado usando openpyxl
    // Vou criar um script Python separado para isso
    throw UnimplementedError('Excel generation not implemented yet');
  }

  /// Gerar relatório PDF
  Future<String> _generatePDFReport(
    String projectName,
    Map<String, List<Map<String, dynamic>>> dataByPhase,
    List<String> selectedPhases,
  ) async {
    // Este método será implementado usando PDF generation
    throw UnimplementedError('PDF generation not implemented yet');
  }

  /// Enviar relatório por email
  Future<void> _sendReportByEmail(
    String filePath,
    String projectName,
    String format,
  ) async {
    // Obter email do utilizador
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Utilizador não autenticado');
    }

    // TODO: Implementar envio de email
    // Opções:
    // 1. Firebase Functions com SendGrid/Mailgun
    // 2. Cloud Functions com Gmail API
    // 3. Email service externo

    print('📧 Enviando relatório para: ${user.email}');
    print('   Ficheiro: $filePath');
  }
}
