import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/torque_tensioning.dart';
import '../services/torque_tensioning_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS - TORQUE & TENSIONING
// ═══════════════════════════════════════════════════════════════════════════

// ──────────────────────────────────────────────────────────────────────────
// SERVICE PROVIDER
// ──────────────────────────────────────────────────────────────────────────

final torqueTensioningServiceProvider =
    Provider<TorqueTensioningService>((ref) {
  return TorqueTensioningService();
});

// ──────────────────────────────────────────────────────────────────────────
// STREAM PROVIDERS
// ──────────────────────────────────────────────────────────────────────────

/// Stream de todas as conexões de uma turbina
final conexoesByTurbinaProvider =
    StreamProvider.family<List<TorqueTensioning>, String>((ref, turbinaId) {
  final service = ref.watch(torqueTensioningServiceProvider);
  return service.streamConexoesByTurbina(turbinaId);
});

/// Stream de uma conexão específica
final conexaoByIdProvider =
    StreamProvider.family<TorqueTensioning?, String>((ref, conexaoId) {
  final service = ref.watch(torqueTensioningServiceProvider);
  return service.getConexaoById(conexaoId).asStream();
});

// ──────────────────────────────────────────────────────────────────────────
// FUTURE PROVIDERS
// ──────────────────────────────────────────────────────────────────────────

/// Obter conexões por categoria
final conexoesByCategoriaProvider = FutureProvider.family<
    List<TorqueTensioning>, ({String turbinaId, String categoria})>(
  (ref, params) {
    final service = ref.watch(torqueTensioningServiceProvider);
    return service.getConexoesByCategoria(
      params.turbinaId,
      params.categoria,
    );
  },
);

/// Obter apenas conexões standard
final conexoesStandardProvider =
    FutureProvider.family<List<TorqueTensioning>, String>((ref, turbinaId) {
  final service = ref.watch(torqueTensioningServiceProvider);
  return service.getConexoesStandard(turbinaId);
});

/// Obter apenas conexões extras
final conexoesExtrasProvider =
    FutureProvider.family<List<TorqueTensioning>, String>((ref, turbinaId) {
  final service = ref.watch(torqueTensioningServiceProvider);
  return service.getConexoesExtras(turbinaId);
});

/// Obter conexões pendentes
final conexoesPendentesProvider =
    FutureProvider.family<List<TorqueTensioning>, String>((ref, turbinaId) {
  final service = ref.watch(torqueTensioningServiceProvider);
  return service.getConexoesPendentes(turbinaId);
});

/// Obter conexões em progresso
final conexoesEmProgressoProvider =
    FutureProvider.family<List<TorqueTensioning>, String>((ref, turbinaId) {
  final service = ref.watch(torqueTensioningServiceProvider);
  return service.getConexoesEmProgresso(turbinaId);
});

/// Obter conexões completas
final conexoesCompletasProvider =
    FutureProvider.family<List<TorqueTensioning>, String>((ref, turbinaId) {
  final service = ref.watch(torqueTensioningServiceProvider);
  return service.getConexoesCompletas(turbinaId);
});

// ──────────────────────────────────────────────────────────────────────────
// ESTATÍSTICAS
// ──────────────────────────────────────────────────────────────────────────

/// Estatísticas gerais das conexões
final estatisticasConexoesProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, turbinaId) {
  final service = ref.watch(torqueTensioningServiceProvider);
  return service.getEstatisticas(turbinaId);
});

/// Estatísticas por categoria
final estatisticasPorCategoriaProvider =
    FutureProvider.family<Map<String, Map<String, int>>, String>(
        (ref, turbinaId) {
  final service = ref.watch(torqueTensioningServiceProvider);
  return service.getEstatisticasPorCategoria(turbinaId);
});

// ──────────────────────────────────────────────────────────────────────────
// STATE NOTIFIER PROVIDERS (para UI state)
// ──────────────────────────────────────────────────────────────────────────

/// Selected category filter
final selectedCategoriaProvider = StateProvider<String?>((ref) => null);

/// Selected connection for editing
final selectedConexaoProvider = StateProvider<TorqueTensioning?>((ref) => null);

/// Loading state for operations
final isLoadingConexaoProvider = StateProvider<bool>((ref) => false);

// ──────────────────────────────────────────────────────────────────────────
// COMPUTED PROVIDERS
// ──────────────────────────────────────────────────────────────────────────

/// Conexões filtradas por categoria selecionada
final conexoesFiltradas =
    Provider.family<AsyncValue<List<TorqueTensioning>>, String>(
  (ref, turbinaId) {
    final categoriaSelecionada = ref.watch(selectedCategoriaProvider);
    final todasConexoesAsync = ref.watch(conexoesByTurbinaProvider(turbinaId));

    if (categoriaSelecionada == null) {
      return todasConexoesAsync;
    }

    return todasConexoesAsync.whenData(
      (conexoes) =>
          conexoes.where((c) => c.categoria == categoriaSelecionada).toList(),
    );
  },
);

/// Progresso geral da turbina (baseado em todas as conexões)
final progressoGeralTurbinaProvider =
    Provider.family<AsyncValue<int>, String>((ref, turbinaId) {
  final estatisticasAsync = ref.watch(estatisticasConexoesProvider(turbinaId));

  return estatisticasAsync.whenData(
    (stats) => stats['progressoMedio'] as int? ?? 0,
  );
});

/// Número de conexões completas
final numeroConexoesCompletasProvider =
    Provider.family<AsyncValue<int>, String>((ref, turbinaId) {
  final estatisticasAsync = ref.watch(estatisticasConexoesProvider(turbinaId));

  return estatisticasAsync.whenData(
    (stats) => stats['completas'] as int? ?? 0,
  );
});

/// Número total de conexões
final numeroTotalConexoesProvider =
    Provider.family<AsyncValue<int>, String>((ref, turbinaId) {
  final estatisticasAsync = ref.watch(estatisticasConexoesProvider(turbinaId));

  return estatisticasAsync.whenData(
    (stats) => stats['total'] as int? ?? 0,
  );
});
