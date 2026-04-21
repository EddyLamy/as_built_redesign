import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
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
          elevation: 6,
          shadowColor: AppColors.isDarkContext(context)
              ? Colors.black.withValues(alpha: 0.42)
              : const Color(0xFF0F4C81).withValues(alpha: 0.18),
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
          child: Text('Erro: $error',
              style: const TextStyle(color: AppColors.errorRed)),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double progresso, int total) {
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final progressTrack = AppColors.adaptiveProgressTrack(context);
    Color progressoColor = AppColors.mediumGray;
    if (progresso > 0 && progresso < 100) {
      progressoColor = AppColors.warningOrange;
    } else if (progresso >= 100) {
      progressoColor = AppColors.successGreen;
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
                  color: primaryText,
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
              backgroundColor: progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(progressoColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$total conexões',
            style: TextStyle(
              fontSize: 11,
              color: secondaryText,
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
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final progressTrack = AppColors.adaptiveProgressTrack(context);
    final outline = AppColors.adaptiveOutline(context);
    Color statusColor = AppColors.mediumGray;
    IconData statusIcon = Icons.circle_outlined;

    if (conexao.status == 'Pendente') {
      statusColor = AppColors.mediumGray;
      statusIcon = Icons.circle_outlined;
    } else if (conexao.status == 'Em Progresso') {
      statusColor = AppColors.warningOrange;
      statusIcon = Icons.access_time;
    } else if (conexao.status == 'Concluído') {
      statusColor = AppColors.successGreen;
      statusIcon = Icons.check_circle;
    }

    return InkWell(
      onTap: () => _openEditDialog(context, ref, conexao),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: outline.withValues(alpha: 0.6), width: 0.5),
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
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: primaryText,
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
                        color:
                            AppColors.primaryBlueMedium.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'Extra',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.primaryBlueMedium,
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
                      backgroundColor: progressTrack,
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
            Icon(Icons.chevron_right, size: 16, color: secondaryText),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    final outline = AppColors.adaptiveOutline(context);
    final cardSurface = AppColors.adaptiveCardSurface(context);
    return InkWell(
      onTap: () => _showAddExtraDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: outline.withValues(alpha: 0.8), width: 1),
          ),
          color: cardSurface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline,
                size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            const Text(
              'Adicionar Conexão Extra',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final cardSurface = AppColors.adaptiveCardSurface(context);
    final outline = AppColors.adaptiveOutline(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outline, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.construction, size: 40, color: secondaryText),
            const SizedBox(height: 8),
            Text(
              'Nenhuma conexão',
              style: TextStyle(color: secondaryText, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _initializeConexoes(context, ref),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Gerar Conexões'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
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
    showLiquidDialog(
      context: context,
      builder: (context) => TorqueTensioningEditDialog(
        conexao: conexao,
        turbinaId: turbinaId,
        projectId: projectId,
      ),
    );
  }

  void _showAddExtraDialog(BuildContext context, WidgetRef ref) {
    showLiquidDialog(
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
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
}
