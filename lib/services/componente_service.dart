import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/componente.dart';
import '../utils/component_mapping.dart';
import 'package:flutter/foundation.dart';

class ComponenteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de componentes por turbina
  Stream<List<Componente>> getComponentesPorTurbina(String turbinaId) {
    return _firestore
        .collection('componentes')
        .where('turbinaId', isEqualTo: turbinaId)
        .orderBy('ordem')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Componente.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Stream de um componente específico
  Stream<Componente?> getComponente(String componenteId) {
    return _firestore
        .collection('componentes')
        .doc(componenteId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return Componente.fromMap(doc.id, doc.data()!);
    });
  }

  // Atualizar componente
  Future<void> updateComponente(
    String componenteId,
    Map<String, dynamic> data,
  ) async {
    // Se status mudou para "Em Progresso" e não tem dataInicio, adiciona
    if (data['status'] == 'Em Progresso') {
      final doc =
          await _firestore.collection('componentes').doc(componenteId).get();
      if (doc.data()?['dataInicio'] == null) {
        data['dataInicio'] = Timestamp.now();
      }
    }

    // Se status mudou para "Concluído" e não tem dataConclusao, adiciona
    if (data['status'] == 'Concluído') {
      final doc =
          await _firestore.collection('componentes').doc(componenteId).get();
      if (doc.data()?['dataConclusao'] == null) {
        data['dataConclusao'] = Timestamp.now();
      }
      // Força progresso 100% quando concluído
      data['progresso'] = 100.0;
    }

    await _firestore.collection('componentes').doc(componenteId).update(data);
  }

  // Obter estatísticas de componentes por turbina
  Future<Map<String, dynamic>> getEstatisticasComponentes(
    String turbinaId,
  ) async {
    final snapshot = await _firestore
        .collection('componentes')
        .where('turbinaId', isEqualTo: turbinaId)
        .get();

    int total = snapshot.docs.length;
    int concluidos = 0;
    int emProgresso = 0;
    int pendentes = 0;
    int bloqueados = 0;
    double progressoTotal = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String;
      final progresso = (data['progresso'] ?? 0).toDouble();

      progressoTotal += progresso;

      switch (status) {
        case 'Concluído':
          concluidos++;
          break;
        case 'Em Progresso':
          emProgresso++;
          break;
        case 'Bloqueado':
          bloqueados++;
          break;
        default:
          pendentes++;
      }
    }

    return {
      'total': total,
      'concluidos': concluidos,
      'emProgresso': emProgresso,
      'pendentes': pendentes,
      'bloqueados': bloqueados,
      'progressoMedio': total > 0 ? progressoTotal / total : 0.0,
    };
  }

  // Obter componentes agrupados por categoria
  Future<Map<String, List<Componente>>> getComponentesAgrupadosPorCategoria(
    String turbinaId,
  ) async {
    final snapshot = await _firestore
        .collection('componentes')
        .where('turbinaId', isEqualTo: turbinaId)
        .orderBy('ordem')
        .get();

    final Map<String, List<Componente>> agrupados = {};

    for (var doc in snapshot.docs) {
      final componente = Componente.fromMap(doc.id, doc.data());

      if (!agrupados.containsKey(componente.categoria)) {
        agrupados[componente.categoria] = [];
      }

      agrupados[componente.categoria]!.add(componente);
    }

    return agrupados;
  }

  // Substituir componente (criar novo e marcar antigo como substituído)
  Future<String> substituirComponente({
    required String componenteAntigoId,
    required String razao,
    required String observacoes,
    required String userId,
  }) async {
    // 1. Buscar componente antigo
    final antigoDoc = await _firestore
        .collection('componentes')
        .doc(componenteAntigoId)
        .get();

    if (!antigoDoc.exists) {
      throw Exception('Componente não encontrado');
    }

    final antigoData = antigoDoc.data()!;
    final componente = Componente.fromMap(componenteAntigoId, antigoData);

    // 2. Criar novo componente (cópia do antigo, progresso zerado)
    final novoComponenteRef = _firestore.collection('componentes').doc();
    final novoComponente = Componente(
      id: novoComponenteRef.id,
      turbinaId: componente.turbinaId,
      projectId: componente.projectId,
      nome: componente.nome,
      tipo: componente.tipo,
      categoria: componente.categoria,
      ordem: componente.ordem,
      progresso: 0.0,
      status: 'Pendente',
      aplicavel: true,
      substituiuComponente: componenteAntigoId,
    );

    // 3. Atualizar componente antigo (marcar como substituído)
    await _firestore.collection('componentes').doc(componenteAntigoId).update({
      'status': 'Substituído',
      'aplicavel': false,
      'substituicaoRazao': razao,
      'substituicaoObservacoes': observacoes,
      'substituicaoData': FieldValue.serverTimestamp(),
      'substituicaoUsuario': userId,
      'substituidoPor': novoComponenteRef.id,
    });

    // 4. Criar novo componente
    await novoComponenteRef.set(novoComponente.toMap());

    return novoComponenteRef.id;
  }

  // Buscar histórico de substituições de um componente
  Future<List<Componente>> getHistoricoSubstituicoes(
    String turbinaId,
    String nomeComponente,
  ) async {
    final snapshot = await _firestore
        .collection('componentes')
        .where('turbinaId', isEqualTo: turbinaId)
        .where('nome', isEqualTo: nomeComponente)
        .where('status', isEqualTo: 'Substituído')
        .orderBy('substituicaoData', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Componente.fromMap(doc.id, doc.data()))
        .toList();
  }

// Criar componente customizado
  Future<String> createComponenteCustom({
    required String turbinaId,
    required String projectId,
    required String nome,
    required String tipo,
    required String categoria,
    required int ordem,
    String? itemNumber,
    String? serialNumber,
    String? vui,
  }) async {
    try {
      final componenteRef = _firestore.collection('componentes').doc();

      // 🔑 TENTAR OBTER hardcodedId
      String? hardcodedId = ComponentMapping.getHardcodedId(nome);

      if (hardcodedId != null) {
        debugPrint('✅ hardcodedId auto-atribuído: "$hardcodedId" para "$nome"');
      } else {
        debugPrint('ℹ️ Componente customizado sem hardcodedId: "$nome"');
      }

      final componente = Componente(
        id: componenteRef.id,
        turbinaId: turbinaId,
        projectId: projectId,
        nome: nome,
        tipo: tipo,
        categoria: categoria,
        ordem: ordem,
        progresso: 0.0,
        status: 'Pendente',
        aplicavel: true,
        itemNumber: itemNumber,
        serialNumber: serialNumber,
        vui: vui,
        hardcodedId: hardcodedId, // ← ADICIONAR ESTA LINHA
      );

      await componenteRef.set(componente.toMap());

      return componenteRef.id;
    } catch (e) {
      debugPrint('Erro ao criar componente custom: $e');
      rethrow;
    }
  }

// Buscar componentes por categoria (para sugerir próxima ordem)
  Future<List<Componente>> getComponentesPorCategoria(
    String turbinaId,
    String categoria,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('componentes')
          .where('turbinaId', isEqualTo: turbinaId)
          .where('categoria', isEqualTo: categoria)
          .orderBy('ordem')
          .get();

      return snapshot.docs
          .map((doc) => Componente.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar componentes por categoria: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🧹 MIGRAÇÃO AUTOMÁTICA POR PROJETO (NOVO MÉTODO)
  // ══════════════════════════════════════════════════════════════════════════
  /// Migra todos os componentes de um projeto específico
  ///
  /// Útil para migrar um parque completo de uma vez
  Future<void> migrateComponentesForProject(String projectId) async {
    debugPrint('\n🔄 Iniciando migração para projeto: $projectId');

    try {
      final snapshot = await _firestore
          .collection('componentes')
          .where('projectId', isEqualTo: projectId)
          .get();

      // Filtrar os que não têm hardcodedId
      final docsToMigrate = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['hardcodedId'] == null;
      }).toList();

      if (docsToMigrate.isEmpty) {
        debugPrint('✅ Todos os componentes do projeto já têm hardcodedId');
        return;
      }

      debugPrint('📊 Encontrados ${docsToMigrate.length} componentes para migrar');

      // Processar em batches de 500 (limite do Firestore)
      final batches = <WriteBatch>[];
      WriteBatch currentBatch = _firestore.batch();
      int operationsInBatch = 0;
      int totalMigrated = 0;

      for (var doc in docsToMigrate) {
        final data = doc.data();
        final nome = data['nome'] as String?;

        if (nome != null) {
          final hardcodedId = ComponentMapping.getHardcodedId(nome);

          if (hardcodedId != null) {
            currentBatch.update(doc.reference, {'hardcodedId': hardcodedId});
            operationsInBatch++;
            totalMigrated++;

            // Criar novo batch se atingir limite
            if (operationsInBatch >= 500) {
              batches.add(currentBatch);
              currentBatch = _firestore.batch();
              operationsInBatch = 0;
            }
          }
        }
      }

      // Adicionar último batch se tiver operações
      if (operationsInBatch > 0) {
        batches.add(currentBatch);
      }

      // Executar todos os batches
      debugPrint('💾 Executando ${batches.length} batches...');
      for (var batch in batches) {
        await batch.commit();
      }

      debugPrint('✅ Migrados $totalMigrated componentes para projeto $projectId\n');
    } catch (e) {
      debugPrint('❌ Erro na migração: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🧹 MIGRAÇÃO AUTOMÁTICA POR TURBINA
  // ══════════════════════════════════════════════════════════════════════════
  /// Migra todos os componentes de uma turbina específica
  Future<void> migrateComponentesForTurbina(String turbinaId) async {
    debugPrint('\n🔄 Iniciando migração para turbina: $turbinaId');

    try {
      // Buscar componentes da turbina SEM hardcodedId
      final snapshot = await _firestore
          .collection('componentes')
          .where('turbinaId', isEqualTo: turbinaId)
          .get();

      // Filtrar os que não têm hardcodedId
      final docsToMigrate = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['hardcodedId'] == null;
      }).toList();

      if (docsToMigrate.isEmpty) {
        debugPrint('✅ Todos os componentes já têm hardcodedId');
        return;
      }

      debugPrint('📊 Encontrados ${docsToMigrate.length} componentes para migrar');

      final batch = _firestore.batch();
      int migrated = 0;

      for (var doc in docsToMigrate) {
        final data = doc.data();
        final nome = data['nome'] as String?;

        if (nome != null) {
          final hardcodedId = ComponentMapping.getHardcodedId(nome);

          if (hardcodedId != null) {
            batch.update(doc.reference, {'hardcodedId': hardcodedId});
            debugPrint('  ✅ ${doc.id}: "$nome" → "$hardcodedId"');
            migrated++;
          } else {
            debugPrint('  ℹ️ ${doc.id}: "$nome" → Componente customizado');
          }
        }
      }

      if (migrated > 0) {
        await batch.commit();
        debugPrint('✅ Migrados $migrated componentes para turbina $turbinaId\n');
      }
    } catch (e) {
      debugPrint('❌ Erro na migração: $e');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📊 VERIFICAR STATUS DA MIGRAÇÃO
  // ══════════════════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> getMigrationStatus(String turbinaId) async {
    final snapshot = await _firestore
        .collection('componentes')
        .where('turbinaId', isEqualTo: turbinaId)
        .get();

    final total = snapshot.docs.length;
    final comHardcodedId =
        snapshot.docs.where((doc) => doc.data()['hardcodedId'] != null).length;
    final semHardcodedId = total - comHardcodedId;

    return {
      'total': total,
      'migrated': comHardcodedId,
      'pending': semHardcodedId,
      'percentage':
          total > 0 ? (comHardcodedId / total * 100).toStringAsFixed(1) : '0',
      'isComplete': semHardcodedId == 0,
    };
  }
}
