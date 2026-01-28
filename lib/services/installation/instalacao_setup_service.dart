import '../../models/installation/fase_componente.dart';
import '../../models/installation/trabalho_ligacao.dart';
import '../../models/installation/trabalho_drivetrain.dart';
import '../../models/installation/checkpoint_geral.dart';
import '../../models/installation/tipo_fase.dart';
import 'fase_componente_service.dart';
import 'trabalho_ligacao_service.dart';
import 'trabalho_drivetrain_service.dart';
import 'checkpoint_geral_service.dart';

// ═══════════════════════════════════════════════════════
// INSTALAÇÃO SETUP SERVICE
// Criação automática de componentes, fases, ligações e checkpoints
// ═══════════════════════════════════════════════════════

class InstalacaoSetupService {
  final FaseComponenteService _faseService;
  final TrabalhoLigacaoService _trabalhoService;
  final TrabalhoDriveTrainService _driveTrainService;
  final CheckpointGeralService _checkpointService;

  InstalacaoSetupService({
    FaseComponenteService? faseService,
    TrabalhoLigacaoService? trabalhoService,
    TrabalhoDriveTrainService? driveTrainService,
    CheckpointGeralService? checkpointService,
  })  : _faseService = faseService ?? FaseComponenteService(),
        _trabalhoService = trabalhoService ?? TrabalhoLigacaoService(),
        _driveTrainService = driveTrainService ?? TrabalhoDriveTrainService(),
        _checkpointService = checkpointService ?? CheckpointGeralService();

  // ────── SETUP COMPLETO ──────

  /// Setup completo de instalação para uma turbina
  Future<void> setupTurbinaInstalacao({
    required String turbinaId,
    required String turbinaName,
    required int numeroSeccoes,
    required String userId,
    List<String>? componenteIdsExistentes, // IDs de componentes já criados
  }) async {
    try {
      // 1. Criar fases para componentes padrão
      await _criarFasesComponentesPadrao(
        turbinaId: turbinaId,
        turbinaName: turbinaName,
        numeroSeccoes: numeroSeccoes,
        userId: userId,
        componenteIds: componenteIdsExistentes ?? [],
      );

      // 2. Criar trabalhos mecânicos (ligações)
      await _criarTrabalhosLigacao(
        turbinaId: turbinaId,
        numeroSeccoes: numeroSeccoes,
        userId: userId,
      );

      // 3. Criar trabalho Drive Train
      await _criarTrabalhoDriveTrain(
        turbinaId: turbinaId,
        driveTrainId: componenteIdsExistentes?.firstWhere(
              (id) => id.contains('drivetrain'),
              orElse: () => 'drivetrain_$turbinaId',
            ) ??
            'drivetrain_$turbinaId',
        userId: userId,
      );

      // 4. Criar checkpoints gerais
      await _criarCheckpointsGerais(
        turbinaId: turbinaId,
        cableMVId: componenteIdsExistentes?.firstWhere(
          (id) => id.contains('cablemv'),
          orElse: () => 'cablemv_$turbinaId',
        ),
        userId: userId,
      );
    } catch (e) {
      throw Exception('Erro no setup de instalação da turbina: $e');
    }
  }

  // ────── COMPONENTES PADRÃO ──────

  /// Criar fases para todos os componentes padrão
  Future<void> _criarFasesComponentesPadrao({
    required String turbinaId,
    required String turbinaName,
    required int numeroSeccoes,
    required String userId,
    required List<String> componenteIds,
  }) async {
    final fases = <FaseComponente>[];
    final now = DateTime.now();

    // Lista de componentes padrão (únicos)
    final componentesPadrao = [
      'contentor',
      'spareparts',
      'swg',
      'cablemv',
      'hub',
      'nacelle',
      'coolertop',
      'drivetrain',
      'bodyparts',
      'elevador',
    ];

    // Criar fases para componentes únicos
    for (final componenteNome in componentesPadrao) {
      final componenteId =
          _getComponenteId(componenteIds, componenteNome, turbinaId);
      fases.addAll(_criarFasesComponente(
        turbinaId: turbinaId,
        componenteId: componenteId,
        userId: userId,
        now: now,
      ));
    }

    // Criar fases para secções (dinâmico)
    // Bottom
    final bottomId = _getComponenteId(componenteIds, 'bottom', turbinaId);
    fases.addAll(_criarFasesComponente(
      turbinaId: turbinaId,
      componenteId: bottomId,
      userId: userId,
      now: now,
    ));

    // Middles (baseado em numeroSeccoes)
    for (int i = 1; i <= numeroSeccoes - 2; i++) {
      final middleId = _getComponenteId(componenteIds, 'middle$i', turbinaId);
      fases.addAll(_criarFasesComponente(
        turbinaId: turbinaId,
        componenteId: middleId,
        userId: userId,
        now: now,
      ));
    }

    // Top
    final topId = _getComponenteId(componenteIds, 'top', turbinaId);
    fases.addAll(_criarFasesComponente(
      turbinaId: turbinaId,
      componenteId: topId,
      userId: userId,
      now: now,
    ));

    // Blades (3x)
    for (int i = 1; i <= 3; i++) {
      final bladeId = _getComponenteId(componenteIds, 'blade$i', turbinaId);
      fases.addAll(_criarFasesComponente(
        turbinaId: turbinaId,
        componenteId: bladeId,
        userId: userId,
        now: now,
      ));
    }

    // Criar todas as fases em batch
    await _faseService.createFasesBatch(fases);
  }

  /// Criar as 4 fases de um componente
  List<FaseComponente> _criarFasesComponente({
    required String turbinaId,
    required String componenteId,
    required String userId,
    required DateTime now,
  }) {
    return [
      // Receção
      FaseComponente(
        id: '', // Firestore gera
        turbinaId: turbinaId,
        componenteId: componenteId,
        tipo: TipoFase.recepcao,
        createdAt: now,
        updatedAt: now,
        createdBy: userId,
      ),
      // Preparação
      FaseComponente(
        id: '',
        turbinaId: turbinaId,
        componenteId: componenteId,
        tipo: TipoFase.preparacao,
        createdAt: now,
        updatedAt: now,
        createdBy: userId,
      ),
      // Pré-Instalação
      FaseComponente(
        id: '',
        turbinaId: turbinaId,
        componenteId: componenteId,
        tipo: TipoFase.preInstalacao,
        createdAt: now,
        updatedAt: now,
        createdBy: userId,
      ),
      // Instalação
      FaseComponente(
        id: '',
        turbinaId: turbinaId,
        componenteId: componenteId,
        tipo: TipoFase.instalacao,
        createdAt: now,
        updatedAt: now,
        createdBy: userId,
      ),
    ];
  }

  // ────── TRABALHOS MECÂNICOS ──────

  /// Criar trabalhos de ligação (torque/tensionamento)
  Future<void> _criarTrabalhosLigacao({
    required String turbinaId,
    required int numeroSeccoes,
    required String userId,
  }) async {
    final trabalhos = <TrabalhoLigacao>[];
    final now = DateTime.now();

    // Fundação → Bottom
    trabalhos.add(TrabalhoLigacao(
      id: '',
      turbinaId: turbinaId,
      componenteA: 'Fundação',
      componenteB: 'Bottom',
      nomeLigacao: 'Fundação/Bottom',
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
    ));

    // Bottom → Middle 1
    trabalhos.add(TrabalhoLigacao(
      id: '',
      turbinaId: turbinaId,
      componenteA: 'Bottom',
      componenteB: 'Middle 1',
      nomeLigacao: 'Bottom/Middle 1',
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
    ));

    // Middle X → Middle X+1 (dinâmico)
    for (int i = 1; i < numeroSeccoes - 2; i++) {
      trabalhos.add(TrabalhoLigacao(
        id: '',
        turbinaId: turbinaId,
        componenteA: 'Middle $i',
        componenteB: 'Middle ${i + 1}',
        nomeLigacao: 'Middle $i/Middle ${i + 1}',
        createdAt: now,
        updatedAt: now,
        createdBy: userId,
      ));
    }

    // Middle Last → Top
    final lastMiddle = numeroSeccoes - 2;
    trabalhos.add(TrabalhoLigacao(
      id: '',
      turbinaId: turbinaId,
      componenteA: 'Middle $lastMiddle',
      componenteB: 'Top',
      nomeLigacao: 'Middle $lastMiddle/Top',
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
    ));

    // Top → Nacelle
    trabalhos.add(TrabalhoLigacao(
      id: '',
      turbinaId: turbinaId,
      componenteA: 'Top',
      componenteB: 'Nacelle',
      nomeLigacao: 'Top/Nacelle',
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
    ));

    // Nacelle → Hub
    trabalhos.add(TrabalhoLigacao(
      id: '',
      turbinaId: turbinaId,
      componenteA: 'Nacelle',
      componenteB: 'Hub',
      nomeLigacao: 'Nacelle/Hub',
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
    ));

    // Hub → Blades
    trabalhos.add(TrabalhoLigacao(
      id: '',
      turbinaId: turbinaId,
      componenteA: 'Hub',
      componenteB: 'Blades',
      nomeLigacao: 'Hub/Blades',
      createdAt: now,
      updatedAt: now,
      createdBy: userId,
    ));

    // Criar todos os trabalhos em batch
    await _trabalhoService.createTrabalhosBatch(trabalhos);
  }

  /// Criar trabalho Drive Train (torque + tensionamento)
  Future<void> _criarTrabalhoDriveTrain({
    required String turbinaId,
    required String driveTrainId,
    required String userId,
  }) async {
    final trabalho = TrabalhoDriveTrain(
      id: '',
      turbinaId: turbinaId,
      componenteId: driveTrainId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: userId,
    );

    await _driveTrainService.createTrabalho(trabalho);
  }

  // ────── CHECKPOINTS ──────

  /// Criar checkpoints gerais
  Future<void> _criarCheckpointsGerais({
    required String turbinaId,
    String? cableMVId,
    required String userId,
  }) async {
    final checkpoints = <CheckpointGeral>[];
    final now = DateTime.now();

    // Lista de checkpoints
    final tiposCheckpoint = [
      TipoFase.eletricos,
      TipoFase.mecanicosGerais,
      TipoFase.finish,
      TipoFase.inspecaoSupervisor,
      TipoFase.punchlist,
      TipoFase.inspecaoCliente,
      TipoFase.punchlistCliente,
    ];

    for (final tipo in tiposCheckpoint) {
      checkpoints.add(CheckpointGeral(
        id: '',
        turbinaId: turbinaId,
        tipo: tipo,
        componenteAssociadoId: tipo == TipoFase.eletricos ? cableMVId : null,
        createdAt: now,
        updatedAt: now,
        createdBy: userId,
      ));
    }

    // Criar todos os checkpoints em batch
    await _checkpointService.createCheckpointsBatch(checkpoints);
  }

  // ────── HELPERS ──────

  /// Obter ID do componente (ou gerar se não existir)
  String _getComponenteId(
    List<String> componenteIds,
    String componenteNome,
    String turbinaId,
  ) {
    // Tentar encontrar nos IDs existentes
    try {
      return componenteIds.firstWhere(
        (id) => id.toLowerCase().contains(componenteNome.toLowerCase()),
      );
    } catch (e) {
      // Se não encontrar, gerar ID
      return '${componenteNome}_$turbinaId';
    }
  }

  // ────── LIMPEZA ──────

  /// Deletar todo o setup de instalação de uma turbina
  Future<void> deleteTurbinaInstalacao(String turbinaId) async {
    try {
      await Future.wait<void>([
        _faseService.deleteFasesByTurbina(turbinaId),
        _trabalhoService.deleteTrabalhosByTurbina(turbinaId),
        _driveTrainService.deleteTrabalhosByTurbina(turbinaId),
        _checkpointService.deleteCheckpointsByTurbina(turbinaId),
      ]);
    } catch (e) {
      throw Exception('Erro ao deletar setup de instalação: $e');
    }
  }
}
