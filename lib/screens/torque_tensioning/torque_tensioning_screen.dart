import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/torque_tensioning.dart';
import '../../providers/torque_tensioning_providers.dart';
import '../../widgets/torque_tensioning_edit_dialog.dart';
import '../../widgets/add_conexao_extra_dialog.dart';

/// Ecrã de Torque & Tensioning com cards tipo componentes
class TorqueTensioningScreen extends ConsumerWidget {
  final String turbinaId;
  final String projectId;
  final String turbinaNome;
  final int numberOfMiddleSections;

  const TorqueTensioningScreen({
    super.key,
    required this.turbinaId,
    required this.projectId,
    required this.turbinaNome,
    required this.numberOfMiddleSections,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conexoesAsync = ref.watch(conexoesByTurbinaProvider(turbinaId));
    final stats = ref.watch(estatisticasConexoesProvider(turbinaId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔩 Torque & Tensioning',
                style: TextStyle(fontSize: 18)),
            Text(turbinaNome,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: const Color(0xFFFF5722),
      ),
      body: conexoesAsync.when(
        data: (conexoes) {
          if (conexoes.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          final conexoesOrdenadas = _ordenarConexoes(conexoes);

          return Column(
            children: [
              // Header com progresso
              _buildProgressHeader(context, stats),

              // Grid de cards tipo componentes
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: conexoesOrdenadas
                        .map((conexao) => _buildComponentCard(
                              context,
                              ref,
                              conexao,
                            ))
                        .toList(),
                  ),
                ),
              ),

              // Botão adicionar
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildAddButton(context, ref),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child:
              Text('Erro: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📊 ORDENAR CONEXÕES
  // ══════════════════════════════════════════════════════════════════════════

  List<TorqueTensioning> _ordenarConexoes(List<TorqueTensioning> conexoes) {
    final ordem = [
      'Fundação → Bottom',
      'Bottom → Middle 1',
      'Middle 1 → Middle 2',
      'Middle 2 → Middle 3',
      'Middle 3 → Middle 4',
      'Middle 4 → Middle 5',
      'Middle 5 → Top',
      'Middle 4 → Top',
      'Middle 3 → Top',
      'Middle 2 → Top',
      'Middle 1 → Top',
      'Top → Nacelle',
      'Drive Train',
      'Nacelle → Hub',
      'Hub → Blade A',
      'Hub → Blade B',
      'Hub → Blade C',
    ];

    final ordenadas = <TorqueTensioning>[];
    final extras = <TorqueTensioning>[];

    for (final conexao in conexoes) {
      if (conexao.isExtra) {
        extras.add(conexao);
      } else {
        ordenadas.add(conexao);
      }
    }

    ordenadas.sort((a, b) {
      final keyA = '${a.componenteOrigem} → ${a.componenteDestino}';
      final keyB = '${b.componenteOrigem} → ${b.componenteDestino}';

      final indexA = ordem.indexWhere((o) => keyA.contains(o));
      final indexB = ordem.indexWhere((o) => keyB.contains(o));

      if (indexA == -1) return 1;
      if (indexB == -1) return -1;

      return indexA.compareTo(indexB);
    });

    ordenadas.addAll(extras);
    return ordenadas;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 HEADER COM PROGRESSO
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildProgressHeader(BuildContext context, AsyncValue stats) {
    return stats.when(
      data: (s) {
        final progressoMedio = s['progressoMedio'] ?? 0.0;
        final total = s['total'] ?? 0;
        final concluidas = s['concluidas'] ?? 0;

        Color cor = progressoMedio >= 100
            ? Colors.green
            : (progressoMedio > 0 ? Colors.orange : Colors.grey);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: progressoMedio / 100,
                      strokeWidth: 5,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(cor),
                    ),
                  ),
                  Text(
                    '${progressoMedio.toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: cor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total', total, Icons.apps, Colors.blue),
                    _buildStatItem('Concluídas', concluidas, Icons.check_circle,
                        Colors.green),
                    _buildStatItem('Pendentes', total - concluidas,
                        Icons.pending, Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 CARD TIPO COMPONENTE (como no print da direita)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildComponentCard(
    BuildContext context,
    WidgetRef ref,
    TorqueTensioning conexao,
  ) {
    // Ícone baseado no componente
    IconData icone = _getIconeConexao(conexao);

    // Cor por status
    Color statusColor = Colors.grey[400]!;
    if (conexao.status == 'Em Progresso') {
      statusColor = Colors.orange;
    } else if (conexao.status == 'Concluído') {
      statusColor = Colors.green;
    }

    // Nome do componente (sem abreviar)
    String nome = _getNomeConexao(conexao);

    return SizedBox(
      width: 140, // 🎯 LARGURA AJUSTÁVEL AQUI
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _openEditDialog(context, ref, conexao),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icone,
                    color: statusColor,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 12),

                // Nome
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Percentagem
                Text(
                  '${conexao.progresso.toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),

                const SizedBox(height: 6),

                // Barra de progresso
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: conexao.progresso / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(statusColor),
                    minHeight: 6,
                  ),
                ),

                // Badge Extra
                if (conexao.isExtra) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'EXTRA',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 ÍCONES POR TIPO DE CONEXÃO
  // ══════════════════════════════════════════════════════════════════════════

  IconData _getIconeConexao(TorqueTensioning conexao) {
    final origem = conexao.componenteOrigem.toLowerCase();
    final destino = conexao.componenteDestino.toLowerCase();

    // Bottom, Middle, Top
    if (origem.contains('bottom') ||
        destino.contains('bottom') ||
        origem.contains('middle') ||
        destino.contains('middle')) {
      return Icons.view_column; // Coluna para secções de torre
    }

    // Fundação
    if (origem.contains('fundação') || origem.contains('foundation')) {
      return Icons.foundation;
    }

    // Top
    if (origem.contains('top') || destino.contains('top')) {
      return Icons.vertical_align_top;
    }

    // Nacelle
    if (origem.contains('nacelle') || destino.contains('nacelle')) {
      return Icons.home_work;
    }

    // Drive Train
    if (origem.contains('drive') || destino.contains('drive')) {
      return Icons.settings;
    }

    // Hub
    if (origem.contains('hub') || destino.contains('hub')) {
      return Icons.album;
    }

    // Blades
    if (origem.contains('blade') || destino.contains('blade')) {
      return Icons.airplanemode_active;
    }

    return Icons.bolt; // Default
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📝 NOME DA CONEXÃO (SEM ABREVIAR)
  // ══════════════════════════════════════════════════════════════════════════

  String _getNomeConexao(TorqueTensioning conexao) {
    // Se for conexão simples de um componente
    if (conexao.componenteOrigem == conexao.componenteDestino ||
        conexao.componenteDestino.isEmpty) {
      return conexao.componenteOrigem;
    }

    // Simplificar nomes longos mas não abreviar demais
    String origem = conexao.componenteOrigem;
    String destino = conexao.componenteDestino;

    // Remover "Section" se existir
    origem = origem.replaceAll(' Section', '');
    destino = destino.replaceAll(' Section', '');

    return '$origem → $destino';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 BOTÃO ADICIONAR
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () => _showAddExtraDialog(context, ref),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Adicionar Conexão Extra'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.blue[700]!, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 EMPTY STATE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Nenhuma conexão',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _initializeConexoes(context, ref),
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Gerar Conexões Standard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 MÉTODOS
  // ══════════════════════════════════════════════════════════════════════════

  void _openEditDialog(
    BuildContext context,
    WidgetRef ref,
    TorqueTensioning conexao,
  ) {
    showDialog(
      context: context,
      builder: (context) => TorqueTensioningEditDialog(
        conexao: conexao,
        turbinaId: turbinaId,
        projectId: projectId,
      ),
    );
  }

  void _showAddExtraDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddConexaoExtraDialog(
        turbinaId: turbinaId,
        projectId: projectId,
      ),
    );
  }

  Future<void> _initializeConexoes(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(torqueTensioningServiceProvider);
      final user =
          await FirebaseFirestore.instance.collection('users').limit(1).get();
      final userId = user.docs.isNotEmpty ? user.docs.first.id : 'system';

      await service.gerarConexoesStandard(
        turbinaId: turbinaId,
        projectId: projectId,
        numberOfMiddleSections: numberOfMiddleSections,
        userId: userId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Conexões geradas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
