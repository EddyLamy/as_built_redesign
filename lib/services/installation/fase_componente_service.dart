import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/installation/fase_componente.dart';
import '../../models/installation/tipo_fase.dart';
import 'package:flutter/foundation.dart';

class FaseComponenteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'fases_componente';

  Future<void> updateFaseWithSync(
    String faseId,
    FaseComponente fase,
  ) async {
    debugPrint('\n========================================');
    debugPrint('🔵 INÍCIO updateFaseWithSync');
    debugPrint('========================================');

    final user = _auth.currentUser;
    debugPrint('👤 Usuário: ${user?.email ?? "❌ NÃO AUTENTICADO"}');

    if (user == null) {
      debugPrint('❌ ERRO: Nenhum usuário autenticado!');
      throw Exception('Usuário não autenticado');
    }

    debugPrint('\n📋 DADOS DA FASE:');
    debugPrint('   Fase ID: $faseId');
    debugPrint('   Turbina ID: ${fase.turbinaId}');
    debugPrint('   Componente ID: ${fase.componenteId}');
    debugPrint('   Tipo: ${fase.tipo}');
    debugPrint('   Progresso: ${fase.progresso}%');
    debugPrint('   VUI: ${fase.vui ?? "VAZIO"}');
    debugPrint('   Serial: ${fase.serialNumber ?? "VAZIO"}');
    debugPrint('   Item: ${fase.itemNumber ?? "VAZIO"}');

    try {
      debugPrint('\n🔄 Criando batch write...');
      final batch = _firestore.batch();

      final faseRef = _firestore.collection(_collection).doc(faseId);
      debugPrint('📍 Referência fases_componente: ${faseRef.path}');

      final faseData = fase.copyWith(updatedAt: DateTime.now()).toFirestore();
      debugPrint('📦 Dados fases_componente: ${faseData.keys.length} campos');

      batch.update(faseRef, faseData);
      debugPrint('✅ Adicionado ao batch: fases_componente');

      final installationRef = _firestore
          .collection('installation_data')
          .doc(fase.turbinaId)
          .collection('components')
          .doc(fase.componenteId);

      debugPrint('📍 Referência installation_data: ${installationRef.path}');

      final faseKey = _getFaseKey(fase.tipo);
      debugPrint('🔑 Chave da fase: $faseKey');

      final faseDataSync = {
        faseKey: {
          'dataInicio': fase.dataInicio != null
              ? Timestamp.fromDate(fase.dataInicio!)
              : null,
          'dataFim':
              fase.dataFim != null ? Timestamp.fromDate(fase.dataFim!) : null,
          if (fase.horaRecepcao != null)
            'horaRecepcao': _timeToString(fase.horaRecepcao),
          if (fase.horaInicio != null)
            'horaInicio': _timeToString(fase.horaInicio),
          if (fase.horaFim != null) 'horaFim': _timeToString(fase.horaFim),
          if (fase.tipo == TipoFase.recepcao) ...{
            'vui': fase.vui,
            'serialNumber': fase.serialNumber,
            'itemNumber': fase.itemNumber,
          },
          if (fase.posicao != null) 'posicao': fase.posicao,
          'fotos': fase.fotos,
          'observacoes': fase.observacoes,
          'isCompleted': fase.progresso >= 100,
          'isFaseNA': fase.isFaseNA,
          'motivoNA': fase.motivoNA,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        }
      };

      debugPrint(
          '📦 Dados installation_data: $faseKey (${faseDataSync[faseKey]!.keys.length} campos)');

      batch.set(installationRef, faseDataSync, SetOptions(merge: true));
      debugPrint('✅ Adicionado ao batch: installation_data');

      debugPrint('\n🚀 Executando batch.commit()...');
      await batch.commit();
      debugPrint('✅✅✅ BATCH COMMIT SUCESSO! ✅✅✅');

      // Atualizar progresso do componente e da turbina
      await _atualizarProgressoComponenteETurbina(
          fase.componenteId, fase.turbinaId);

      debugPrint('\n========================================');
      debugPrint('🎉 FIM updateFaseWithSync - SUCESSO');
      debugPrint('========================================\n');
    } catch (e, stackTrace) {
      debugPrint('\n❌❌❌ ERRO NO BATCH! ❌❌❌');
      debugPrint('Erro: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('========================================\n');
      rethrow;
    }
  }

  String _getFaseKey(TipoFase tipo) {
    switch (tipo) {
      case TipoFase.recepcao:
        return 'reception';
      case TipoFase.preparacao:
        return 'preparation';
      case TipoFase.preInstalacao:
        return 'preAssembly';
      case TipoFase.instalacao:
        return 'assembly';
      case TipoFase.eletricos:
        return 'electricalWorks';
      case TipoFase.mecanicosGerais:
        return 'mechanicalWorks';
      case TipoFase.finish:
        return 'finish';
      case TipoFase.inspecaoSupervisor:
        return 'supervisorInspection';
      case TipoFase.punchlist:
        return 'punchlist';
      case TipoFase.inspecaoCliente:
        return 'clientInspection';
      case TipoFase.punchlistCliente:
        return 'clientPunchlist';
      default:
        return tipo.toString().split('.').last;
    }
  }

  String? _timeToString(dynamic time) {
    if (time == null) return null;
    try {
      final hour = time.hour as int;
      final minute = time.minute as int;
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      debugPrint('⚠️ Erro ao converter time: $e');
      return null;
    }
  }

  Future<void> updateFase(String faseId, FaseComponente fase) async {
    debugPrint(
        '⚠️ updateFase() chamado - redirecionando para updateFaseWithSync()');
    await updateFaseWithSync(faseId, fase);
  }

  /// Recalcula e grava o progresso do componente (media das suas fases) e
  /// depois o progresso da turbina (média dos seus componentes).
  Future<void> _atualizarProgressoComponenteETurbina(
      String componenteId, String turbinaId) async {
    try {
      // 1. Buscar todas as fases do componente
      final fasesSnap = await _firestore
          .collection(_collection)
          .where('componenteId', isEqualTo: componenteId)
          .get();

      double progressoComponente = 0;
      if (fasesSnap.docs.isNotEmpty) {
        double total = 0;
        for (final doc in fasesSnap.docs) {
          final fase = FaseComponente.fromFirestore(doc);
          total += fase.progresso;
        }
        progressoComponente = total / fasesSnap.docs.length;
      }

      // 2. Atualizar componentes/{componenteId}.progresso
      await _firestore.collection('componentes').doc(componenteId).update({
        'progresso': progressoComponente,
        'updatedAt': Timestamp.fromDate(DateTime.now())
      });
      debugPrint(
          '✅ componentes/$componenteId → progresso: ${progressoComponente.toStringAsFixed(1)}%');

      // 3. Buscar todos os componentes da turbina para calcular progresso da turbina
      final compSnap = await _firestore
          .collection('componentes')
          .where('turbinaId', isEqualTo: turbinaId)
          .get();

      double progressoTurbina = 0;
      if (compSnap.docs.isNotEmpty) {
        double total = 0;
        for (final doc in compSnap.docs) {
          total += (doc.data()['progresso'] ?? 0).toDouble();
        }
        progressoTurbina = total / compSnap.docs.length;
      }

      // 4. Determinar status
      String status;
      if (progressoTurbina == 0) {
        status = 'Planejada';
      } else if (progressoTurbina < 100) {
        status = 'Em Instalação';
      } else {
        status = 'Instalada';
      }

      // 5. Atualizar turbina
      await _firestore.collection('turbinas').doc(turbinaId).update({
        'progresso': progressoTurbina,
        'status': status,
      });
      debugPrint(
          '✅ turbinas/$turbinaId → progresso: ${progressoTurbina.toStringAsFixed(1)}% ($status)');
    } catch (e) {
      debugPrint('⚠️ _atualizarProgressoComponenteETurbina erro: $e');
    }
  }

  /// Verifica se o VUI já está registado noutras fases.
  /// Retorna a primeira [FaseComponente] duplicada encontrada, ou null se OK.
  Future<FaseComponente?> checkVuiDuplicado(
      String vui, String currentFaseId) async {
    if (vui.isEmpty) return null;
    try {
      final snap = await _firestore
          .collection(_collection)
          .where('vui', isEqualTo: vui)
          .limit(5)
          .get();
      final outros = snap.docs.where((doc) => doc.id != currentFaseId).toList();
      if (outros.isEmpty) return null;
      return FaseComponente.fromFirestore(outros.first);
    } catch (e) {
      debugPrint('⚠️ checkVuiDuplicado erro: $e');
      return null;
    }
  }

  /// Retorna o nome legível da turbina (ex: "WTG-01") dado o seu Firestore ID.
  Future<String?> getTurbinaNome(String turbinaId) async {
    try {
      final doc = await _firestore.collection('turbinas').doc(turbinaId).get();
      if (!doc.exists) return null;
      return (doc.data() as Map<String, dynamic>)['nome'] as String?;
    } catch (e) {
      debugPrint('⚠️ getTurbinaNome erro: $e');
      return null;
    }
  }

  Future<String> createFase(FaseComponente fase) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            fase.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar fase: $e');
    }
  }

  Future<void> createFasesBatch(List<FaseComponente> fases) async {
    try {
      final batch = _firestore.batch();
      for (final fase in fases) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, fase.toFirestore());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao criar fases em lote: $e');
    }
  }

  Future<FaseComponente?> getFaseById(String faseId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(faseId).get();
      if (!doc.exists) return null;
      return FaseComponente.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erro ao obter fase: $e');
    }
  }

  Future<List<FaseComponente>> getFasesByComponente(String componenteId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('componenteId', isEqualTo: componenteId)
          .orderBy('createdAt', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => FaseComponente.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter fases do componente: $e');
    }
  }

  Future<FaseComponente?> getFaseByComponenteAndTipo(
    String componenteId,
    TipoFase tipo,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('componenteId', isEqualTo: componenteId)
          .where('tipo', isEqualTo: tipo.toString().split('.').last)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return FaseComponente.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Erro ao obter fase específica: $e');
    }
  }

  Future<List<FaseComponente>> getFasesByTurbina(String turbinaId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .orderBy('createdAt', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => FaseComponente.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter fases da turbina: $e');
    }
  }

  Future<List<FaseComponente>> getFasesByTipo(
    String turbinaId,
    TipoFase tipo,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .where('tipo', isEqualTo: tipo.toString().split('.').last)
          .orderBy('createdAt', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => FaseComponente.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao obter fases por tipo: $e');
    }
  }

  Stream<List<FaseComponente>> streamFasesByComponente(String componenteId) {
    return _firestore
        .collection(_collection)
        .where('componenteId', isEqualTo: componenteId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FaseComponente.fromFirestore(doc))
            .toList());
  }

  Stream<List<FaseComponente>> streamFasesByTurbina(String turbinaId) {
    return _firestore
        .collection(_collection)
        .where('turbinaId', isEqualTo: turbinaId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FaseComponente.fromFirestore(doc))
            .toList());
  }

  Future<void> updateFaseFields(
    String faseId,
    Map<String, dynamic> fields,
  ) async {
    try {
      fields['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection(_collection).doc(faseId).update(fields);
    } catch (e) {
      throw Exception('Erro ao atualizar campos da fase: $e');
    }
  }

  Future<void> marcarComoNA(
    String faseId,
    String motivoNA,
    String motivoNAKey,
    String userId,
  ) async {
    try {
      await updateFaseFields(faseId, {
        'isFaseNA': true,
        'motivoNA': motivoNA,
        'motivoNAKey': motivoNAKey,
        'updatedBy': userId,
      });
    } catch (e) {
      throw Exception('Erro ao marcar fase como N/A: $e');
    }
  }

  Future<void> desmarcarNA(String faseId, String userId) async {
    try {
      await updateFaseFields(faseId, {
        'isFaseNA': false,
        'motivoNA': null,
        'motivoNAKey': null,
        'updatedBy': userId,
      });
    } catch (e) {
      throw Exception('Erro ao desmarcar N/A: $e');
    }
  }

  Future<void> adicionarFoto(String faseId, String fotoUrl) async {
    try {
      await _firestore.collection(_collection).doc(faseId).update({
        'fotos': FieldValue.arrayUnion([fotoUrl]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar foto: $e');
    }
  }

  Future<void> removerFoto(String faseId, String fotoUrl) async {
    try {
      await _firestore.collection(_collection).doc(faseId).update({
        'fotos': FieldValue.arrayRemove([fotoUrl]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erro ao remover foto: $e');
    }
  }

  Future<void> deleteFase(String faseId) async {
    try {
      await _firestore.collection(_collection).doc(faseId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar fase: $e');
    }
  }

  Future<void> deleteFasesByComponente(String componenteId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('componenteId', isEqualTo: componenteId)
          .get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao deletar fases do componente: $e');
    }
  }

  Future<void> deleteFasesByTurbina(String turbinaId) async {
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
      throw Exception('Erro ao deletar fases da turbina: $e');
    }
  }

  Future<List<FaseComponente>> getFasesIncompletas(String turbinaId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .where('isFaseNA', isEqualTo: false)
          .get();
      final fases = snapshot.docs
          .map((doc) => FaseComponente.fromFirestore(doc))
          .where((fase) => fase.progresso < 100)
          .toList();
      return fases;
    } catch (e) {
      throw Exception('Erro ao obter fases incompletas: $e');
    }
  }

  Future<bool> isPosicaoBladeDisponivel(
    String turbinaId,
    String posicao,
    String? excludeFaseId,
  ) async {
    try {
      var query = _firestore
          .collection(_collection)
          .where('turbinaId', isEqualTo: turbinaId)
          .where('tipo', isEqualTo: 'instalacao')
          .where('posicao', isEqualTo: posicao);
      final snapshot = await query.get();
      if (excludeFaseId != null) {
        return snapshot.docs.where((doc) => doc.id != excludeFaseId).isEmpty;
      }
      return snapshot.docs.isEmpty;
    } catch (e) {
      throw Exception('Erro ao validar posição Blade: $e');
    }
  }

  Future<void> copiarDadosRecepcao(
    String componenteId,
    String faseInstalacaoId,
  ) async {
    try {
      final recepcao = await getFaseByComponenteAndTipo(
        componenteId,
        TipoFase.recepcao,
      );
      if (recepcao == null) {
        throw Exception('Fase de receção não encontrada');
      }
      await updateFaseFields(faseInstalacaoId, {
        'vui': recepcao.vui,
        'serialNumber': recepcao.serialNumber,
        'itemNumber': recepcao.itemNumber,
      });
    } catch (e) {
      throw Exception('Erro ao copiar dados da receção: $e');
    }
  }
}
