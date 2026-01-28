import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/turbina.dart';

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
}
