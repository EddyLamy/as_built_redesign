import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/torque_tensioning.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TORQUE & TENSIONING SERVICE - CRUD COMPLETO
// ═══════════════════════════════════════════════════════════════════════════

class TorqueTensioningService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'torque_tensioning';

  // ══════════════════════════════════════════════════════════════════════════
  // CREATE
  // ══════════════════════════════════════════════════════════════════════════

  /// Criar nova conexão
  Future<String> createConexao(TorqueTensioning conexao) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            conexao.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar conexão: $e');
    }
  }

  /// Criar múltiplas conexões (batch)
  Future<void> createConexoesBatch(List<TorqueTensioning> conexoes) async {
    try {
      final batch = _firestore.batch();

      for (final conexao in conexoes) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, conexao.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao criar conexões em lote: $e');
    }
  }

  /// Gerar conexões standard para uma turbina
  /// Chamado quando turbina é criada ou quando user abre a página
  Future<void> gerarConexoesStandard({
    required String turbinaId,
    required String projectId,
    required int numberOfMiddleSections,
    required String userId,
  }) async {
    try {
      // 1. Verificar quais conexões já existem
      final existentes = await getConexoesByTurbina(turbinaId);
      final tiposExistentes = existentes
          .map((c) => '${c.componenteOrigem}_${c.componenteDestino}')
          .toSet();

      // 2. Gerar templates
      final templates = _gerarTemplates(numberOfMiddleSections);

      // 3. Criar apenas as que não existem
      final novasConexoes = <TorqueTensioning>[];
      final now = DateTime.now();

      for (final template in templates) {
        final tipo = '${template.origem}_${template.destino}';

        // Pular se já existe
        if (tiposExistentes.contains(tipo)) continue;

        novasConexoes.add(TorqueTensioning(
          id: '', // Será gerado pelo Firestore
          turbinaId: turbinaId,
          projectId: projectId,
          componenteOrigem: template.origem,
          componenteDestino: template.destino,
          categoria: template.categoria,
          isStandard: true,
          isExtra: false,
          createdAt: now,
          createdBy: userId,
          updatedAt: now,
          updatedBy: userId,
        ));
      }

      // 4. Criar em batch
      if (novasConexoes.isNotEmpty) {
        await createConexoesBatch(novasConexoes);
        print('✅ ${novasConexoes.length} conexões standard criadas');
      } else {
        print('ℹ️ Todas as conexões standard já existem');
      }
    } catch (e) {
      throw Exception('Erro ao gerar conexões standard: $e');
    }
  }

  /// Gerar templates de conexões baseado no número de middle sections
  List<ConexaoTemplate> _gerarTemplates(int numberOfMiddleSections) {
    final templates = <ConexaoTemplate>[];
    int ordem = 0;

    // ════════════════════════════════════════════════════════════════════
    // CIVIL WORKS
    // ════════════════════════════════════════════════════════════════════
    templates.add(ConexaoTemplate(
      tipo: 'fundacao_bottom',
      origem: 'Fundação',
      destino: 'Bottom',
      categoria: 'Civil Works',
      ordem: ordem++,
    ));

    // ════════════════════════════════════════════════════════════════════
    // TORRE - Bottom to First Middle
    // ════════════════════════════════════════════════════════════════════
    templates.add(ConexaoTemplate(
      tipo: 'bottom_middle1',
      origem: 'Bottom',
      destino: 'Middle 1',
      categoria: 'Torre',
      ordem: ordem++,
    ));

    // TORRE - Middle to Middle
    for (int i = 1; i < numberOfMiddleSections; i++) {
      templates.add(ConexaoTemplate(
        tipo: 'middle${i}_middle${i + 1}',
        origem: 'Middle $i',
        destino: 'Middle ${i + 1}',
        categoria: 'Torre',
        ordem: ordem++,
      ));
    }

    // TORRE - Last Middle to Top
    templates.add(ConexaoTemplate(
      tipo: 'middle${numberOfMiddleSections}_top',
      origem: 'Middle $numberOfMiddleSections',
      destino: 'Top',
      categoria: 'Torre',
      ordem: ordem++,
    ));

    // ════════════════════════════════════════════════════════════════════
    // NACELLE ASSEMBLY
    // ════════════════════════════════════════════════════════════════════
    templates.add(ConexaoTemplate(
      tipo: 'top_nacelle',
      origem: 'Top',
      destino: 'Nacelle',
      categoria: 'Nacelle',
      ordem: ordem++,
    ));

    // NOTA: Drive Train é gerido separadamente (pode ser N/A)
    // Não incluir aqui

    // ════════════════════════════════════════════════════════════════════
    // ROTOR ASSEMBLY
    // ════════════════════════════════════════════════════════════════════
    templates.add(ConexaoTemplate(
      tipo: 'nacelle_hub',
      origem: 'Nacelle',
      destino: 'Hub',
      categoria: 'Rotor',
      ordem: ordem++,
    ));

    templates.add(ConexaoTemplate(
      tipo: 'hub_blade_a',
      origem: 'Hub',
      destino: 'Blade A',
      categoria: 'Rotor',
      ordem: ordem++,
    ));

    templates.add(ConexaoTemplate(
      tipo: 'hub_blade_b',
      origem: 'Hub',
      destino: 'Blade B',
      categoria: 'Rotor',
      ordem: ordem++,
    ));

    templates.add(ConexaoTemplate(
      tipo: 'hub_blade_c',
      origem: 'Hub',
      destino: 'Blade C',
      categoria: 'Rotor',
      ordem: ordem++,
    ));

    return templates;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // READ
  // ══════════════════════════════════════════════════════════════════════════

  /// Obter conexão por ID
  Future<TorqueTensioning?> getConexaoById(String conexaoId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(conexaoId).get();

      if (!doc.exists) return null;

      return TorqueTensioning.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao obter conexão: $e');
    }
  }

  /// Obter todas as conexões de uma turbina
  Future<List<TorqueTensioning>> getConexoesByTurbina(String turbinaId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .get();

      return snapshot.docs
          .map((doc) => TorqueTensioning.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter conexões da turbina: $e');
    }
  }

  /// Obter conexões por categoria
  Future<List<TorqueTensioning>> getConexoesByCategoria(
    String turbinaId,
    String categoria,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .where('categoria', isEqualTo: categoria)
          .get();

      return snapshot.docs
          .map((doc) => TorqueTensioning.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter conexões por categoria: $e');
    }
  }

  /// Obter apenas conexões standard
  Future<List<TorqueTensioning>> getConexoesStandard(String turbinaId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .where('isStandard', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => TorqueTensioning.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter conexões standard: $e');
    }
  }

  /// Obter apenas conexões extras
  Future<List<TorqueTensioning>> getConexoesExtras(String turbinaId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .where('isExtra', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => TorqueTensioning.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter conexões extras: $e');
    }
  }

  /// Stream de conexões de uma turbina
  Stream<List<TorqueTensioning>> streamConexoesByTurbina(String turbinaId) {
    return _firestore
        .collection(_collection)
        .where('turbinaId', isEqualTo: turbinaId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TorqueTensioning.fromFirestore(doc))
            .toList());
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE
  // ══════════════════════════════════════════════════════════════════════════

  /// Atualizar conexão
  Future<void> updateConexao(
    String conexaoId,
    TorqueTensioning conexao,
  ) async {
    try {
      await _firestore.collection(_collection).doc(conexaoId).update(
            conexao.copyWith(updatedAt: DateTime.now()).toFirestore(),
          );
    } catch (e) {
      throw Exception('Erro ao atualizar conexão: $e');
    }
  }

  /// Atualizar campos específicos
  Future<void> updateConexaoFields(
    String conexaoId,
    Map<String, dynamic> fields,
  ) async {
    try {
      fields['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection(_collection).doc(conexaoId).update(fields);
    } catch (e) {
      throw Exception('Erro ao atualizar campos da conexão: $e');
    }
  }

  /// Adicionar foto
  Future<void> adicionarFoto(String conexaoId, String fotoUrl) async {
    try {
      await _firestore.collection(_collection).doc(conexaoId).update({
        'photoUrls': FieldValue.arrayUnion([fotoUrl]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar foto: $e');
    }
  }

  /// Remover foto
  Future<void> removerFoto(String conexaoId, String fotoUrl) async {
    try {
      await _firestore.collection(_collection).doc(conexaoId).update({
        'photoUrls': FieldValue.arrayRemove([fotoUrl]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao remover foto: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ══════════════════════════════════════════════════════════════════════════

  /// Deletar conexão (apenas extras podem ser deletadas)
  Future<void> deleteConexao(String conexaoId) async {
    try {
      // Verificar se é extra
      final conexao = await getConexaoById(conexaoId);
      if (conexao == null) {
        throw Exception('Conexão não encontrada');
      }

      if (conexao.isStandard) {
        throw Exception('Conexões standard não podem ser deletadas');
      }

      await _firestore.collection(_collection).doc(conexaoId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar conexão: $e');
    }
  }

  /// Deletar todas as conexões de uma turbina
  Future<void> deleteConexoesByTurbina(String turbinaId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao deletar conexões da turbina: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // QUERIES ESPECIAIS
  // ══════════════════════════════════════════════════════════════════════════

  /// Obter conexões pendentes (sem dados)
  Future<List<TorqueTensioning>> getConexoesPendentes(String turbinaId) async {
    try {
      final todas = await getConexoesByTurbina(turbinaId);
      return todas.where((c) => c.isPendente).toList();
    } catch (e) {
      throw Exception('Erro ao obter conexões pendentes: $e');
    }
  }

  /// Obter conexões em progresso
  Future<List<TorqueTensioning>> getConexoesEmProgresso(
      String turbinaId) async {
    try {
      final todas = await getConexoesByTurbina(turbinaId);
      return todas.where((c) => c.isEmProgresso).toList();
    } catch (e) {
      throw Exception('Erro ao obter conexões em progresso: $e');
    }
  }

  /// Obter conexões completas
  Future<List<TorqueTensioning>> getConexoesCompletas(String turbinaId) async {
    try {
      final todas = await getConexoesByTurbina(turbinaId);
      return todas.where((c) => c.isCompleto).toList();
    } catch (e) {
      throw Exception('Erro ao obter conexões completas: $e');
    }
  }

  /// Obter estatísticas das conexões
  Future<Map<String, dynamic>> getEstatisticas(String turbinaId) async {
    try {
      final todas = await getConexoesByTurbina(turbinaId);

      final total = todas.length;
      final completas = todas.where((c) => c.isCompleto).length;
      final emProgresso = todas.where((c) => c.isEmProgresso).length;
      final pendentes = todas.where((c) => c.isPendente).length;

      final progressoMedio = total > 0
          ? (todas.map((c) => c.progresso).reduce((a, b) => a + b) / total)
              .round()
          : 0;

      return {
        'total': total,
        'completas': completas,
        'emProgresso': emProgresso,
        'pendentes': pendentes,
        'progressoMedio': progressoMedio,
        'percentagemCompleto':
            total > 0 ? ((completas / total) * 100).round() : 0,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  /// Obter estatísticas por categoria
  Future<Map<String, Map<String, int>>> getEstatisticasPorCategoria(
    String turbinaId,
  ) async {
    try {
      final todas = await getConexoesByTurbina(turbinaId);

      final stats = <String, Map<String, int>>{};

      for (final conexao in todas) {
        if (!stats.containsKey(conexao.categoria)) {
          stats[conexao.categoria] = {
            'total': 0,
            'completas': 0,
            'emProgresso': 0,
            'pendentes': 0,
          };
        }

        stats[conexao.categoria]!['total'] =
            stats[conexao.categoria]!['total']! + 1;

        if (conexao.isCompleto) {
          stats[conexao.categoria]!['completas'] =
              stats[conexao.categoria]!['completas']! + 1;
        } else if (conexao.isEmProgresso) {
          stats[conexao.categoria]!['emProgresso'] =
              stats[conexao.categoria]!['emProgresso']! + 1;
        } else {
          stats[conexao.categoria]!['pendentes'] =
              stats[conexao.categoria]!['pendentes']! + 1;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Erro ao obter estatísticas por categoria: $e');
    }
  }
}
