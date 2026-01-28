import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_phase.dart';

class ProjectPhaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mapa de nomes das fases em PT
  static const Map<String, String> phaseNames = {
    'phase_project_start': 'Início do Projeto',
    'phase_civil_works': 'Trabalhos Civis',
    'phase_facilities': 'Instalações',
    'phase_subcontractors': 'Subcontratados',
    'phase_tools_container': 'Tools Contêiner',
    'phase_main_components_receipt': 'Recepção Componentes Principais',
    'phase_accessories_receipt': 'Recepção Acessórios',
    'phase_swg_receipt': 'Recepção SWG',
    'phase_mv_cables_receipt': 'Recepção Cabos MV',
    'phase_component_preparation': 'Preparação de Componentes',
    'phase_pre_installation': 'Pré-Instalação',
    'phase_main_installation': 'Instalação Principal',
    'phase_electrical_works': 'Trabalhos Elétricos',
    'phase_inspections': 'Inspeções',
    'phase_client_inspections': 'Inspeções do Cliente',
    'phase_pre_commissioning': 'Pré-Comissionamento',
    'phase_commissioning': 'Comissionamento',
    'phase_turbine_tests': 'Testes às Turbinas',
    'phase_handover': 'Handover',
    'phase_final_observations': 'Observações Finais',
  };

  // Template das 20 fases padrão
  static const List<Map<String, dynamic>> defaultPhases = [
    {
      'ordem': 1,
      'nomeKey': 'phase_project_start',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 2,
      'nomeKey': 'phase_civil_works',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 3,
      'nomeKey': 'phase_facilities',
      'obrigatorio': false,
      'aplicavel': true,
    },
    {
      'ordem': 4,
      'nomeKey': 'phase_subcontractors',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 5,
      'nomeKey': 'phase_tools_container',
      'obrigatorio': false,
      'aplicavel': true,
    },
    {
      'ordem': 6,
      'nomeKey': 'phase_main_components_receipt',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 7,
      'nomeKey': 'phase_accessories_receipt',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 8,
      'nomeKey': 'phase_swg_receipt',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 9,
      'nomeKey': 'phase_mv_cables_receipt',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 10,
      'nomeKey': 'phase_component_preparation',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 11,
      'nomeKey': 'phase_pre_installation',
      'obrigatorio': false,
      'aplicavel': true,
    },
    {
      'ordem': 12,
      'nomeKey': 'phase_main_installation',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 13,
      'nomeKey': 'phase_electrical_works',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 14,
      'nomeKey': 'phase_inspections',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 15,
      'nomeKey': 'phase_client_inspections',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 16,
      'nomeKey': 'phase_pre_commissioning',
      'obrigatorio': false,
      'aplicavel': true,
    },
    {
      'ordem': 17,
      'nomeKey': 'phase_commissioning',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 18,
      'nomeKey': 'phase_turbine_tests',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 19,
      'nomeKey': 'phase_handover',
      'obrigatorio': true,
      'aplicavel': true,
    },
    {
      'ordem': 20,
      'nomeKey': 'phase_final_observations',
      'obrigatorio': false,
      'aplicavel': true,
    },
  ];

  /// Criar fases padrão ao criar projeto
  Future<void> createDefaultPhases(String projectId) async {
    final now = DateTime.now();
    final batch = _firestore.batch();

    for (var template in defaultPhases) {
      final docRef = _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .doc();

      final nomeKey = template['nomeKey'] as String;
      final nomeFase = phaseNames[nomeKey] ?? nomeKey;

      final phase = ProjectPhase(
        id: docRef.id,
        projectId: projectId,
        nome: nomeFase,
        nomeKey: nomeKey,
        ordem: template['ordem'] as int,
        obrigatorio: template['obrigatorio'] as bool,
        aplicavel: template['aplicavel'] as bool,
        createdAt: now,
        updatedAt: now,
      );

      batch.set(docRef, phase.toMap());
    }

    await batch.commit();
  }

  /// Criar fases com datas personalizadas
  Future<void> createPhasesWithCustomDates(
    String projectId,
    Map<int, DateTime?> startDates,
    Map<int, DateTime?> endDates,
    Map<int, bool> naPhases,
  ) async {
    final now = DateTime.now();
    final batch = _firestore.batch();

    for (var template in defaultPhases) {
      final ordem = template['ordem'] as int;
      final docRef = _firestore
          .collection('projects')
          .doc(projectId)
          .collection('phases')
          .doc();

      final nomeKey = template['nomeKey'] as String;
      final nomeFase = phaseNames[nomeKey] ?? nomeKey;

      final phase = ProjectPhase(
        id: docRef.id,
        projectId: projectId,
        nome: nomeFase,
        nomeKey: nomeKey,
        ordem: ordem,
        obrigatorio: template['obrigatorio'] as bool,
        aplicavel: !(naPhases[ordem] ?? false),
        dataInicio: startDates[ordem],
        dataFim: endDates[ordem],
        createdAt: now,
        updatedAt: now,
      );

      batch.set(docRef, phase.toMap());
    }

    await batch.commit();
  }

  /// Obter fases de um projeto (stream)
  Stream<List<ProjectPhase>> getPhasesByProject(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection('phases')
        .orderBy('ordem')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProjectPhase.fromFirestore(doc))
          .toList();
    });
  }

  /// Atualizar fase
  Future<void> updatePhase(
      String projectId, String phaseId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());

    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('phases')
        .doc(phaseId)
        .update(data);
  }

  /// Marcar fase como N/A
  Future<void> togglePhaseNA(
      String projectId, String phaseId, bool isNA) async {
    await updatePhase(projectId, phaseId, {
      'aplicavel': !isNA,
      'dataInicio': null,
      'dataFim': null,
    });
  }

  /// Verificar se projeto pode ser fechado
  Future<bool> canCloseProject(String projectId) async {
    final snapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('phases')
        .get();

    final phases =
        snapshot.docs.map((doc) => ProjectPhase.fromFirestore(doc)).toList();

    // Verificar se todas as fases obrigatórias estão completas
    for (var phase in phases) {
      if (phase.obrigatorio && !phase.isCompleta) {
        return false;
      }
    }

    return true;
  }

  /// Calcular progresso geral das fases (0-100%)
  Future<double> calculateProjectPhasesProgress(String projectId) async {
    final snapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('phases')
        .get();

    if (snapshot.docs.isEmpty) return 0;

    final phases =
        snapshot.docs.map((doc) => ProjectPhase.fromFirestore(doc)).toList();

    // Contar fases concluídas (tem dataFim OU é N/A)
    int concluidas = 0;
    int aplicaveis = 0;

    for (var phase in phases) {
      if (phase.aplicavel) {
        aplicaveis++;
        if (phase.dataFim != null) {
          concluidas++;
        }
      }
    }

    if (aplicaveis == 0) return 100.0;

    return (concluidas / aplicaveis) * 100;
  }

  /// Obter fase atual (primeira incompleta)
  Future<ProjectPhase?> getCurrentPhase(String projectId) async {
    final snapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('phases')
        .orderBy('ordem')
        .get();

    final phases =
        snapshot.docs.map((doc) => ProjectPhase.fromFirestore(doc)).toList();

    // Retornar primeira fase não completa
    for (var phase in phases) {
      if (!phase.isCompleta) {
        return phase;
      }
    }

    // Se todas completas, retornar última
    return phases.isNotEmpty ? phases.last : null;
  }

  /// Deletar todas as fases de um projeto
  Future<void> deleteProjectPhases(String projectId) async {
    final snapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('phases')
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
