import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/torque_tensioning.dart';
import '../../providers/torque_tensioning_providers.dart';
import '../../widgets/torque_tensioning_edit_dialog.dart';
import '../../widgets/add_conexao_extra_dialog.dart';

/// Card compacto para fase de Torque & Tensioning
/// Mostra TODAS as conexões numa lista simples sem separação por categorias
class TorqueFaseCard extends ConsumerWidget {
  final String turbinaId;
  final String projectId;
  final int numberOfMiddleSections;

  const TorqueFaseCard({
    super.key,
    required this.turbinaId,
    required this.projectId,
    required this.numberOfMiddleSections,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conexoesAsync = ref.watch(conexoesByTurbinaProvider(turbinaId));
    final stats = ref.watch(estatisticasConexoesProvider(turbinaId));

    return conexoesAsync.when(
      data: (conexoes) {
        if (conexoes.isEmpty) {
          return _buildEmptyState(context, ref);
        }

        // Calcular progresso geral
        final progressoGeral = stats.when(
          data: (s) => s['progressoMedio'] ?? 0.0,
          loading: () => 0.0,
          error: (_, __) => 0.0,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          child: Column(
            children: [
              // Header com progresso geral
              _buildHeader(context, progressoGeral, conexoes.length),

              // Lista compacta de conexões
              _buildConexoesList(context, ref, conexoes),

              // Botão adicionar extra
              _buildAddButton(context, ref),
            ],
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Erro: $error', style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double progresso, int total) {
    Color progressoColor = Colors.grey;
    if (progresso > 0 && progresso < 100) {
      progressoColor = Colors.orange;
    } else if (progresso >= 100) {
      progressoColor = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.construction, color: progressoColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Torque & Tensioning',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${progresso.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: progressoColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progresso / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressoColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$total conexões',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConexoesList(
    BuildContext context,
    WidgetRef ref,
    List<TorqueTensioning> conexoes,
  ) {
    return Column(
      children: conexoes.map((conexao) {
        return _buildConexaoItem(context, ref, conexao);
      }).toList(),
    );
  }

  Widget _buildConexaoItem(
    BuildContext context,
    WidgetRef ref,
    TorqueTensioning conexao,
  ) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.circle_outlined;

    if (conexao.status == 'Pendente') {
      statusColor = Colors.grey;
      statusIcon = Icons.circle_outlined;
    } else if (conexao.status == 'Em Progresso') {
      statusColor = Colors.orange;
      statusIcon = Icons.access_time;
    } else if (conexao.status == 'Concluído') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    }

    return InkWell(
      onTap: () => _openEditDialog(context, ref, conexao),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Ícone de status
            Icon(statusIcon, size: 16, color: statusColor),
            const SizedBox(width: 8),

            // Nome da conexão
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${conexao.componenteOrigem} → ${conexao.componenteDestino}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (conexao.isExtra) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'Extra',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.purple[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Barra de progresso mini
            SizedBox(
              width: 60,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: conexao.progresso / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${conexao.progresso.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _showAddExtraDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          color: Colors.grey[50],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 18, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              'Adicionar Conexão Extra',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.construction, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Nenhuma conexão',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _initializeConexoes(context, ref),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Gerar Conexões'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Utilizador não autenticado');
      }

      await service.gerarConexoesStandard(
        turbinaId: turbinaId,
        projectId: projectId,
        numberOfMiddleSections: numberOfMiddleSections,
        userId: user.uid,
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
