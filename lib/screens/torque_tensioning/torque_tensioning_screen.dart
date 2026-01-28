import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/torque_tensioning.dart';
import '../../providers/torque_tensioning_providers.dart';
import '../../widgets/torque_tensioning_edit_dialog.dart';
import '../../widgets/add_conexao_extra_dialog.dart';

/// Ecrã SIMPLIFICADO de Torque & Tensioning
/// Mostra APENAS as conexões da Torre (sem categorias)
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🔩 Torque & Tensioning', style: TextStyle(fontSize: 18)),
            Text(turbinaNome,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Color(0xFFFF5722),
      ),
      body: conexoesAsync.when(
        data: (conexoes) {
          if (conexoes.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          return Column(
            children: [
              // Header com progresso geral
              _buildProgressHeader(context, stats),

              // Lista de conexões
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    // Título da secção
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.view_column,
                              color: Color(0xFFFF5722), size: 24),
                          SizedBox(width: 8),
                          Text(
                            '🏗️ Torre',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Conexões
                    ...conexoes.map(
                        (conexao) => _buildConexaoCard(context, ref, conexao)),

                    SizedBox(height: 16),

                    // Botão adicionar extra
                    _buildAddExtraButton(context, ref),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Erro: $error', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 HEADER COM PROGRESSO GERAL
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildProgressHeader(BuildContext context, AsyncValue stats) {
    return stats.when(
      data: (s) {
        final progressoMedio = s['progressoMedio'] ?? 0.0;
        final total = s['total'] ?? 0;
        final concluidas = s['concluidas'] ?? 0;
        final emProgresso = s['emProgresso'] ?? 0;
        final pendentes = s['pendentes'] ?? 0;

        Color progressoColor = Colors.grey;
        if (progressoMedio > 0 && progressoMedio < 100) {
          progressoColor = Colors.orange;
        } else if (progressoMedio >= 100) {
          progressoColor = Colors.green;
        }

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: progressoColor.withOpacity(0.1),
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              // Barra de progresso
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progresso Geral',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressoMedio / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                AlwaysStoppedAnimation<Color>(progressoColor),
                            minHeight: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    '${progressoMedio.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: progressoColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Estatísticas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip('Total', total, Colors.blue),
                  _buildStatChip('Concluídas', concluidas, Colors.green),
                  _buildStatChip('Em Progresso', emProgresso, Colors.orange),
                  _buildStatChip('Pendentes', pendentes, Colors.grey),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => SizedBox.shrink(),
    );
  }

  Widget _buildStatChip(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 CARD DE CONEXÃO
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildConexaoCard(
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

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _openEditDialog(context, ref, conexao),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone de status
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, size: 24, color: statusColor),
              ),

              SizedBox(width: 16),

              // Info da conexão
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${conexao.componenteOrigem} → ${conexao.componenteDestino}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (conexao.isExtra)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Extra',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.purple[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: conexao.progresso / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(statusColor),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '${conexao.progresso.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 BOTÃO ADICIONAR CONEXÃO EXTRA
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAddExtraButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () => _showAddExtraDialog(context, ref),
      icon: Icon(Icons.add_circle_outline),
      label: Text('Adicionar Conexão Extra'),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.blue, width: 2),
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
          SizedBox(height: 16),
          Text(
            'Nenhuma conexão',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _initializeConexoes(context, ref),
            icon: Icon(Icons.refresh, size: 20),
            label: Text('Gerar Conexões Standard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF5722),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔧 MÉTODOS DE AÇÃO
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

      // Buscar userId
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
          SnackBar(
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
