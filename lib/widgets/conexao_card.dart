import 'package:flutter/material.dart';
import '../models/torque_tensioning.dart';
import '../core/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CONEXAO CARD - Widget para exibir uma conexão
// ═══════════════════════════════════════════════════════════════════════════

class ConexaoCard extends StatelessWidget {
  final TorqueTensioning conexao;
  final VoidCallback onTap;
  final VoidCallback? onDelete; // Null se não pode deletar (standard)

  const ConexaoCard({
    super.key,
    required this.conexao,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ════════════════════════════════════════════════════════
              // HEADER - Nome da conexão + Badge
              // ════════════════════════════════════════════════════════
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getCategoryIcon(),
                          color: _getCategoryColor(),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${conexao.componenteOrigem} → ${conexao.componenteDestino}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (conexao.descricao != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  conexao.descricao!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mediumGray,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: AppColors.errorRed,
                      onPressed: onDelete,
                      tooltip: 'Deletar conexão extra',
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // ════════════════════════════════════════════════════════
              // PROGRESSO BAR
              // ════════════════════════════════════════════════════════
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: conexao.progresso / 100,
                  backgroundColor: AppColors.lightGray,
                  valueColor: AlwaysStoppedAnimation(_getProgressColor()),
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 8),

              // ════════════════════════════════════════════════════════
              // DADOS RESUMIDOS (se houver)
              // ════════════════════════════════════════════════════════
              if (conexao.progresso > 0) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    // Torque
                    if (conexao.torqueValue != null &&
                        conexao.torqueUnit != null)
                      _buildDataChip(
                        icon: Icons.build,
                        label:
                            'Torque: ${conexao.torqueValue} ${conexao.torqueUnit}',
                      ),

                    // Tensionamento
                    if (conexao.tensioningValue != null &&
                        conexao.tensioningUnit != null)
                      _buildDataChip(
                        icon: Icons.compress,
                        label:
                            'Tensão: ${conexao.tensioningValue} ${conexao.tensioningUnit}',
                      ),

                    // Parafusos
                    if (conexao.boltMetric != null)
                      _buildDataChip(
                        icon: Icons.hardware,
                        label: conexao.boltQuantity != null
                            ? '${conexao.boltMetric} x ${conexao.boltQuantity}'
                            : conexao.boltMetric!,
                      ),

                    // Fotos
                    if (conexao.photoUrls.isNotEmpty)
                      _buildDataChip(
                        icon: Icons.photo_library,
                        label:
                            '${conexao.photoUrls.length} foto${conexao.photoUrls.length > 1 ? 's' : ''}',
                      ),

                    // Data execução
                    if (conexao.dataInicio != null)
                      _buildDataChip(
                        icon: Icons.calendar_today,
                        label: _formatDate(conexao.dataInicio!),
                      ),
                  ],
                ),
              ],

              // ════════════════════════════════════════════════════════
              // FOOTER - Tipo de conexão (se extra)
              // ════════════════════════════════════════════════════════
              if (conexao.isExtra) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 14,
                      color: AppColors.accentTeal,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Conexão Extra',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accentTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS - CORES E ÍCONES
  // ══════════════════════════════════════════════════════════════════════════

  Color _getCategoryColor() {
    switch (conexao.categoria) {
      case 'Civil Works':
        return AppColors.warningOrange;
      case 'Torre':
        return AppColors.accentTeal;
      case 'Nacelle':
        return AppColors.primaryBlue;
      case 'Rotor':
        return AppColors.successGreen;
      default:
        return AppColors.mediumGray;
    }
  }

  IconData _getCategoryIcon() {
    switch (conexao.categoria) {
      case 'Civil Works':
        return Icons.foundation;
      case 'Torre':
        return Icons.layers;
      case 'Nacelle':
        return Icons.settings;
      case 'Rotor':
        return Icons.autorenew;
      default:
        return Icons.link;
    }
  }

  Color _getBorderColor() {
    if (conexao.isCompleto) return AppColors.successGreen;
    if (conexao.isEmProgresso) return AppColors.warningOrange;
    return AppColors.borderGray;
  }

  Color _getProgressColor() {
    if (conexao.progresso >= 100) return AppColors.successGreen;
    if (conexao.progresso >= 50) return AppColors.warningOrange;
    return AppColors.accentTeal;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STATUS BADGE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStatusBadge() {
    final String text;
    final Color color;
    final IconData icon;

    if (conexao.isCompleto) {
      text = 'Concluído';
      color = AppColors.successGreen;
      icon = Icons.check_circle;
    } else if (conexao.isEmProgresso) {
      text = 'Em Progresso';
      color = AppColors.warningOrange;
      icon = Icons.pending;
    } else {
      text = 'Pendente';
      color = AppColors.mediumGray;
      icon = Icons.radio_button_unchecked;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DATA CHIP
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildDataChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.darkGray),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FORMAT DATE
  // ══════════════════════════════════════════════════════════════════════════

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
