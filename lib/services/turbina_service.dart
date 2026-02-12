import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/turbina.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class TurbinaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de turbinas por projeto
  Stream<List<Turbina>> getTurbinasPorProjeto(String projectId) {
    return _firestore
        .collection('turbinas')
        .where('projectId', isEqualTo: projectId)
        .orderBy('sequenceNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Turbina.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Stream de uma turbina específica
  Stream<Turbina?> getTurbina(String turbinaId) {
    return _firestore
        .collection('turbinas')
        .doc(turbinaId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Turbina.fromMap(doc.id, doc.data()!);
    });
  }

  // Criar turbina + auto-criar componentes do Master Template
  Future<String> createTurbinaComComponentes({
    required String projectId,
    required String nome,
    required int sequenceNumber,
    String? localizacao,
    required String userId,
    int numberOfMiddleSections = 3,
  }) async {
    final turbinaId = _firestore.collection('turbinas').doc().id;

    // Criar turbina no Firestore
    await _firestore.collection('turbinas').doc(turbinaId).set({
      'nome': nome,
      'sequenceNumber': sequenceNumber,
      'localizacao': localizacao,
      'projectId': projectId,
      'turbinaId': turbinaId,
      'numberOfMiddleSections': numberOfMiddleSections,
      'progresso': 0.0,
      'status': 'Pendente',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdBy': userId,
    });

    // Criar componentes automáticos
    await _criarComponentesAutomaticos(
      turbinaId: turbinaId,
      projectId: projectId,
      userId: userId,
      numberOfMiddleSections: numberOfMiddleSections,
    );

    return turbinaId;
  }

  // Atualizar turbina
  Future<void> updateTurbina(
      String turbinaId, Map<String, dynamic> data) async {
    await _firestore.collection('turbinas').doc(turbinaId).update(data);
  }

  // Deletar turbina (e seus componentes)
  Future<void> deleteTurbina(String turbinaId) async {
    // 1. Deletar todos componentes da turbina
    final componentesSnapshot = await _firestore
        .collection('componentes')
        .where('turbinaId', isEqualTo: turbinaId)
        .get();

    final batch = _firestore.batch();
    for (var doc in componentesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 2. Deletar turbina
    batch.delete(_firestore.collection('turbinas').doc(turbinaId));

    await batch.commit();
  }

  // Atualizar progresso da turbina baseado nos componentes
  Future<void> atualizarProgressoTurbina(String turbinaId) async {
    // Buscar todos componentes da turbina
    final componentesSnapshot = await _firestore
        .collection('componentes')
        .where('turbinaId', isEqualTo: turbinaId)
        .get();

    if (componentesSnapshot.docs.isEmpty) {
      return;
    }

    // Calcular progresso médio
    double totalProgresso = 0;
    int count = 0;

    for (var doc in componentesSnapshot.docs) {
      final data = doc.data();
      totalProgresso += (data['progresso'] ?? 0).toDouble();
      count++;
    }

    final progressoMedio = count > 0 ? totalProgresso / count : 0.0;

    // Determinar status baseado no progresso
    String status;
    if (progressoMedio == 0) {
      status = 'Planejada';
    } else if (progressoMedio < 100) {
      status = 'Em Instalação';
    } else {
      status = 'Instalada';
    }

    // Atualizar turbina
    await _firestore.collection('turbinas').doc(turbinaId).update({
      'progresso': progressoMedio,
      'status': status,
    });
  }

  // Obter próximo número de sequência
  Future<int> getProximoNumeroSequencia(String projectId) async {
    final snapshot = await _firestore
        .collection('turbinas')
        .where('projectId', isEqualTo: projectId)
        .orderBy('sequenceNumber', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return 1;
    }

    final ultimaSequencia = snapshot.docs.first.data()['sequenceNumber'] as int;
    return ultimaSequencia + 1;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MÉTODO PRIVADO: CRIAR COMPONENTES AUTOMATICAMENTE
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _criarComponentesAutomaticos({
    required String turbinaId,
    required String projectId,
    required String userId,
    int numberOfMiddleSections = 3,
  }) async {
    final componentes = <Map<String, dynamic>>[];
    int ordem = 0;

    // ════════════════════════════════════════════════════════════════════════
    // MAIN COMPONENTS
    // ════════════════════════════════════════════════════════════════════════
    componentes.add(_criarComponente(
      hardcodedId: 'top_cooler',
      nome: 'Top Cooler',
      categoria: 'Main Components',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'bottom',
      nome: 'Tower Bottom',
      categoria: 'Main Components',
      ordem: ordem++,
    ));

    for (int i = 1; i <= numberOfMiddleSections; i++) {
      componentes.add(_criarComponente(
        hardcodedId: 'middle$i',
        nome: 'Middle $i',
        categoria: 'Main Components',
        ordem: ordem++,
      ));
    }

    componentes.add(_criarComponente(
      hardcodedId: 'top',
      nome: 'Tower Top',
      categoria: 'Main Components',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'nacelle',
      nome: 'Nacelle',
      categoria: 'Main Components',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'drive_train',
      nome: 'Drive Train',
      categoria: 'Main Components',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'hub',
      nome: 'Hub',
      categoria: 'Main Components',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'blade_1',
      nome: 'Blade 1',
      categoria: 'Main Components',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'blade_2',
      nome: 'Blade 2',
      categoria: 'Main Components',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'blade_3',
      nome: 'Blade 3',
      categoria: 'Main Components',
      ordem: ordem++,
    ));

    // ════════════════════════════════════════════════════════════════════════
    // ELECTRICAL SYSTEMS
    // ════════════════════════════════════════════════════════════════════════
    componentes.add(_criarComponente(
      hardcodedId: 'mv_cable',
      nome: 'MV Cable',
      categoria: 'Electrical Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'swg',
      nome: 'SWG',
      categoria: 'Electrical Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'transformador',
      nome: 'Transformador',
      categoria: 'Electrical Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'gerador',
      nome: 'Gerador',
      categoria: 'Electrical Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'ground_control',
      nome: 'Ground Control',
      categoria: 'Electrical Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'light_control',
      nome: 'Light Control',
      categoria: 'Electrical Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'light_battery',
      nome: 'Light Battery',
      categoria: 'Electrical Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'ups',
      nome: 'UPS',
      categoria: 'Electrical Systems',
      ordem: ordem++,
    ));

    // ════════════════════════════════════════════════════════════════════════
    // MECHANICAL SYSTEMS
    // ════════════════════════════════════════════════════════════════════════
    componentes.add(_criarComponente(
      hardcodedId: 'gearbox',
      nome: 'Gearbox',
      categoria: 'Mechanical Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'coupling',
      nome: 'Coupling',
      categoria: 'Mechanical Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'service_lift',
      nome: 'Service Lift',
      categoria: 'Mechanical Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'lift_cables',
      nome: 'Lift Cables',
      categoria: 'Mechanical Systems',
      ordem: ordem++,
    ));

    // ════════════════════════════════════════════════════════════════════════
    // AUXILIARY SYSTEMS
    // ════════════════════════════════════════════════════════════════════════
    componentes.add(_criarComponente(
      hardcodedId: 'resq',
      nome: 'RESQ',
      categoria: 'Auxiliary Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'aviation_light_1',
      nome: 'Aviation Light 1',
      categoria: 'Auxiliary Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'aviation_light_2',
      nome: 'Aviation Light 2',
      categoria: 'Auxiliary Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'grua_interna',
      nome: 'Grua Interna',
      categoria: 'Auxiliary Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'cms',
      nome: 'CMS',
      categoria: 'Auxiliary Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'spare_parts',
      nome: 'Spare Parts',
      categoria: 'Auxiliary Systems',
      ordem: ordem++,
    ));

    componentes.add(_criarComponente(
      hardcodedId: 'bodies_parts',
      nome: 'Bodies Parts',
      categoria: 'Auxiliary Systems',
      ordem: ordem++,
    ));

    // ════════════════════════════════════════════════════════════════════════
    // CIVIL WORKS
    // ════════════════════════════════════════════════════════════════════════
    componentes.add(_criarComponente(
      hardcodedId: 'anchor_bolts',
      nome: 'Anchor Bolts',
      categoria: 'Civil Works',
      ordem: ordem++,
    ));

    // ════════════════════════════════════════════════════════════════════════
    // GUARDAR NO FIREBASE (batch write)
    // ════════════════════════════════════════════════════════════════════════
    final batch = _firestore.batch();

    for (var comp in componentes) {
      final componentId = '${comp['hardcodedId']}_$turbinaId';
      final docRef = _firestore.collection('componentes').doc(componentId);

      batch.set(docRef, {
        ...comp,
        'turbinaId': turbinaId,
        'projectId': projectId,
        'progresso': 0.0,
        'status': 'Pendente',
        'aplicavel': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': userId,
      });
    }

    await batch.commit();

    print(
        '✅ ${componentes.length} componentes criados para turbina $turbinaId');
    print('   📦 Main Components: ${10 + numberOfMiddleSections}');
    print('   ⚡ Electrical Systems: 8');
    print('   🔧 Mechanical Systems: 4');
    print('   🛠️  Auxiliary Systems: 7');
    print('   🏗️  Civil Works: 1');
    print('   🌪️  Middle Sections: $numberOfMiddleSections');

    // ════════════════════════════════════════════════════════════════════════
    // 🆕 CRIAR FASE TORQUE & TENSIONING AUTOMATICAMENTE
    // ════════════════════════════════════════════════════════════════════════
    try {
      await _firestore.collection('fases_componente').add({
        'turbinaId': turbinaId,
        'projectId': projectId,
        'componenteId': 'Torque & Tensioning',
        'nomeComponente': 'Torque & Tensioning',
        'tipo': 'torqueTensionamento',
        'ordem': 5,
        'progresso': 0.0,
        'isFaseNA': false,
        'motivoNA': null,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': userId,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': userId,
      });

      print('✅ Fase Torque & Tensioning criada automaticamente');
    } catch (e) {
      print('⚠️  Erro ao criar fase Torque: $e');
    }
  }

  Map<String, dynamic> _criarComponente({
    required String hardcodedId,
    required String nome,
    required String categoria,
    required int ordem,
  }) {
    return {
      'hardcodedId': hardcodedId,
      'nome': nome,
      'categoria': categoria,
      'ordem': ordem,
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
// ADICIONAR AO TurbinaService (lib/services/turbina_service.dart)
// ══════════════════════════════════════════════════════════════════════════

  /// Obter componentes agrupados por categoria para mobile
  Future<Map<String, List<Map<String, dynamic>>>>
      getComponentsGroupedByCategory(
    String turbinaId, {
    int numberOfMiddleSections = 3,
  }) async {
    try {
      debugPrint(
          '🔵 getComponentsGroupedByCategory - turbinaId: $turbinaId, numberOfMiddleSections: $numberOfMiddleSections');

      // ════════════════════════════════════════════════════════════════════════
      // 1. USAR NÚMERO DE MIDDLE SECTIONS PASSADO OU BUSCAR DA TURBINA
      // ════════════════════════════════════════════════════════════════════════
      // Se numberOfMiddleSections for 3 (default), tenta buscar da turbina
      if (numberOfMiddleSections == 3) {
        // Buscar da coleção turbinas para verificar se há valor diferente
        final turbinaDoc = await FirebaseFirestore.instance
            .collection('turbinas')
            .doc(turbinaId)
            .get();

        if (turbinaDoc.exists) {
          final turbinaData = turbinaDoc.data() as Map<String, dynamic>;
          numberOfMiddleSections =
              turbinaData['numberOfMiddleSections'] as int? ?? 3;
          debugPrint('🔵 Middle sections da turbina: $numberOfMiddleSections');
        } else {
          debugPrint('⚠️ Turbina não encontrada, usando default: 3 middles');
        }
      } else {
        debugPrint(
            '🔵 Using passed numberOfMiddleSections: $numberOfMiddleSections');
      }

      // ════════════════════════════════════════════════════════════════════════
      // 2. BUSCAR DADOS DE INSTALAÇÃO
      // ════════════════════════════════════════════════════════════════════════
      final installationDoc = await FirebaseFirestore.instance
          .collection('installation_data')
          .doc(turbinaId)
          .get();

      debugPrint('🔵 installationDoc existe: ${installationDoc.exists}');

      if (!installationDoc.exists) {
        debugPrint('❌ Documento installation_data não existe');
        // Criar estrutura default COM o número correto de middles
        return _createDefaultComponents(turbinaId, numberOfMiddleSections);
      }

      // ════════════════════════════════════════════════════════════════════════
      // 3. BUSCAR PROGRESSO DE CADA COMPONENTE
      // ════════════════════════════════════════════════════════════════════════
      final componentsSnapshot = await FirebaseFirestore.instance
          .collection('installation_data')
          .doc(turbinaId)
          .collection('components')
          .get();

      debugPrint(
          '🔵 Componentes encontrados: ${componentsSnapshot.docs.length}');

      // Criar mapa de progresso
      final Map<String, double> progressMap = {};
      for (var doc in componentsSnapshot.docs) {
        final progress = _calculateComponentProgress(doc.data());
        progressMap[doc.id] = progress;
        debugPrint('  - ${doc.id}: ${progress.toStringAsFixed(1)}%');
      }

      // ════════════════════════════════════════════════════════════════════════
      // 4. ORGANIZAR POR CATEGORIA
      // ════════════════════════════════════════════════════════════════════════
      final Map<String, List<Map<String, dynamic>>> grouped = {
        'Torre': [],
        'Nacelle': [],
        'Rotor': [],
      };

      // TORRE - Bottom
      grouped['Torre']!.add({
        'id': 'bottom_$turbinaId',
        'name': 'Bottom',
        'progress': progressMap['bottom_$turbinaId'] ?? 0.0,
      });

      // TORRE - Middle sections (dinâmico!)
      for (int i = 1; i <= numberOfMiddleSections; i++) {
        grouped['Torre']!.add({
          'id': 'middle${i}_$turbinaId',
          'name': 'Middle $i',
          'progress': progressMap['middle${i}_$turbinaId'] ?? 0.0,
        });
      }

      // TORRE - Top
      grouped['Torre']!.add({
        'id': 'top_$turbinaId',
        'name': 'Top',
        'progress': progressMap['top_$turbinaId'] ?? 0.0,
      });

      // NACELLE
      grouped['Nacelle']!.add({
        'id': 'nacelle_$turbinaId',
        'name': 'Nacelle',
        'progress': progressMap['nacelle_$turbinaId'] ?? 0.0,
      });

      // ROTOR
      grouped['Rotor']!.addAll([
        {
          'id': 'hub_$turbinaId',
          'name': 'Hub',
          'progress': progressMap['hub_$turbinaId'] ?? 0.0,
        },
        {
          'id': 'blade_1_$turbinaId',
          'name': 'Blade 1',
          'progress': progressMap['blade_1_$turbinaId'] ?? 0.0,
        },
        {
          'id': 'blade_2_$turbinaId',
          'name': 'Blade 2',
          'progress': progressMap['blade_2_$turbinaId'] ?? 0.0,
        },
        {
          'id': 'blade_3_$turbinaId',
          'name': 'Blade 3',
          'progress': progressMap['blade_3_$turbinaId'] ?? 0.0,
        },
      ]);

      debugPrint('✅ Componentes agrupados:');
      grouped.forEach((category, components) {
        debugPrint('  $category: ${components.length} componentes');
      });

      return grouped;
    } catch (e) {
      debugPrint('❌ Erro ao buscar componentes agrupados: $e');
      // Em caso de erro, tentar buscar da turbina mesmo assim
      try {
        final turbinaDoc = await FirebaseFirestore.instance
            .collection('turbinas')
            .doc(turbinaId)
            .get();

        if (turbinaDoc.exists) {
          final turbinaData = turbinaDoc.data() as Map<String, dynamic>;
          final numberOfMiddleSections =
              turbinaData['numberOfMiddleSections'] as int? ?? 3;
          return _createDefaultComponents(turbinaId, numberOfMiddleSections);
        }
      } catch (e2) {
        debugPrint('❌ Erro ao buscar turbina: $e2');
      }

      return _createDefaultComponents(turbinaId, 3);
    }
  }

  /// Criar componentes default quando não há dados no Firestore
  /// AGORA RECEBE numberOfMiddleSections como parâmetro!
  Map<String, List<Map<String, dynamic>>> _createDefaultComponents(
    String turbinaId,
    int numberOfMiddleSections,
  ) {
    debugPrint(
        '🟡 Criando componentes default com $numberOfMiddleSections middles');

    final Map<String, List<Map<String, dynamic>>> result = {
      'Torre': [],
      'Nacelle': [],
      'Rotor': [],
    };

    // TORRE - Bottom
    result['Torre']!.add({
      'id': 'bottom_$turbinaId',
      'name': 'Bottom',
      'progress': 0.0,
    });

    // TORRE - Middle sections (dinâmico!)
    for (int i = 1; i <= numberOfMiddleSections; i++) {
      result['Torre']!.add({
        'id': 'middle${i}_$turbinaId',
        'name': 'Middle $i',
        'progress': 0.0,
      });
    }

    // TORRE - Top
    result['Torre']!.add({
      'id': 'top_$turbinaId',
      'name': 'Top',
      'progress': 0.0,
    });

    // NACELLE
    result['Nacelle']!.add({
      'id': 'nacelle_$turbinaId',
      'name': 'Nacelle',
      'progress': 0.0,
    });

    // ROTOR
    result['Rotor']!.addAll([
      {'id': 'hub_$turbinaId', 'name': 'Hub', 'progress': 0.0},
      {'id': 'blade_1_$turbinaId', 'name': 'Blade 1', 'progress': 0.0},
      {'id': 'blade_2_$turbinaId', 'name': 'Blade 2', 'progress': 0.0},
      {'id': 'blade_3_$turbinaId', 'name': 'Blade 3', 'progress': 0.0},
    ]);

    return result;
  }

  /// Calcular progresso de um componente
  double _calculateComponentProgress(Map<String, dynamic> data) {
    int completedPhases = 0;
    const int totalPhases = 6;

    final phases = [
      'reception',
      'preparation',
      'preAssembly',
      'assembly',
      'torqueTensioning',
      'finalPhases'
    ];

    for (var phase in phases) {
      final phaseData = data[phase];
      if (phaseData != null && phaseData is Map) {
        if (phase == 'reception') {
          if (phaseData['dataInicio'] != null) {
            completedPhases++;
          }
        } else {
          if (phaseData['dataFim'] != null) {
            completedPhases++;
          }
        }
      }
    }

    return (completedPhases / totalPhases) * 100;
  }
}
