import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/installation/fase_componente.dart';
import '../../models/installation/tipo_fase.dart';

class FaseComponenteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'fases_componente';

  Future<void> updateFaseWithSync(
    String faseId,
    FaseComponente fase,
  ) async {
    print('\n========================================');
    print('🔵 INÍCIO updateFaseWithSync');
    print('========================================');

    final user = _auth.currentUser;
    print('👤 Usuário: ${user?.email ?? "❌ NÃO AUTENTICADO"}');

    if (user == null) {
      print('❌ ERRO: Nenhum usuário autenticado!');
      throw Exception('Usuário não autenticado');
    }

    print('\n📋 DADOS DA FASE:');
    print('   Fase ID: $faseId');
    print('   Turbina ID: ${fase.turbinaId}');
    print('   Componente ID: ${fase.componenteId}');
    print('   Tipo: ${fase.tipo}');
    print('   Progresso: ${fase.progresso}%');
    print('   VUI: ${fase.vui ?? "VAZIO"}');
    print('   Serial: ${fase.serialNumber ?? "VAZIO"}');
    print('   Item: ${fase.itemNumber ?? "VAZIO"}');

    try {
      print('\n🔄 Criando batch write...');
      final batch = _firestore.batch();

      final faseRef = _firestore.collection(_collection).doc(faseId);
      print('📍 Referência fases_componente: ${faseRef.path}');

      final faseData = fase.copyWith(updatedAt: DateTime.now()).toFirestore();
      print('📦 Dados fases_componente: ${faseData.keys.length} campos');

      batch.update(faseRef, faseData);
      print('✅ Adicionado ao batch: fases_componente');

      final installationRef = _firestore
          .collection('installation_data')
          .doc(fase.turbinaId)
          .collection('components')
          .doc(fase.componenteId);

      print('📍 Referência installation_data: ${installationRef.path}');

      final faseKey = _getFaseKey(fase.tipo);
      print('🔑 Chave da fase: $faseKey');

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

      print(
          '📦 Dados installation_data: $faseKey (${faseDataSync[faseKey]!.keys.length} campos)');

      batch.set(installationRef, faseDataSync, SetOptions(merge: true));
      print('✅ Adicionado ao batch: installation_data');

      print('\n🚀 Executando batch.commit()...');
      await batch.commit();
      print('✅✅✅ BATCH COMMIT SUCESSO! ✅✅✅');

      print('\n========================================');
      print('🎉 FIM updateFaseWithSync - SUCESSO');
      print('========================================\n');
    } catch (e, stackTrace) {
      print('\n❌❌❌ ERRO NO BATCH! ❌❌❌');
      print('Erro: $e');
      print('StackTrace: $stackTrace');
      print('========================================\n');
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
      print('⚠️ Erro ao converter time: $e');
      return null;
    }
  }

  Future<void> updateFase(String faseId, FaseComponente fase) async {
    print('⚠️ updateFase() chamado - redirecionando para updateFaseWithSync()');
    await updateFaseWithSync(faseId, fase);
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
