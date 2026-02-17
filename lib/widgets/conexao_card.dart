import 'package:flutter/material.dart';
import '../models/torque_tensioning.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CONEXAO CARD - Widget para exibir uma conexão - Visual Modernizado
// ═══════════════════════════════════════════════════════════════════════════

class ConexaoCard extends StatefulWidget {
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
  State<ConexaoCard> createState() => _ConexaoCardState();
}

class _ConexaoCardState extends State<ConexaoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.defaultCurve,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: AppDecorations.cardHoverable(isHovered: _isHovered),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getBorderColor(),
                  width: 2,
                ),
              ),
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getCategoryColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getCategoryColor().withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                _getCategoryIcon(),
                                color: _getCategoryColor(),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.conexao.componenteOrigem} → ${widget.conexao.componenteDestino}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.15,
                                    ),
                                  ),
                                  if (widget.conexao.descricao != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.conexao.descricao!,
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
                      if (widget.onDelete != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: AppColors.errorRed,
                          onPressed: widget.onDelete,
                          tooltip: 'Deletar conexão extra',
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ════════════════════════════════════════════════════════
                  // PROGRESSO BAR
                  // ════════════════════════════════════════════════════════
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.conexao.progresso / 100,
                      backgroundColor: AppColors.lightGray,
                      valueColor: AlwaysStoppedAnimation(_getProgressColor()),
                      minHeight: 8,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ════════════════════════════════════════════════════════
                  // DADOS RESUMIDOS (se houver)
                  // ════════════════════════════════════════════════════════
                  if (widget.conexao.progresso > 0) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        // Torque
                        if (widget.conexao.torqueValue != null &&
                            widget.conexao.torqueUnit != null)
                          _buildDataChip(
                            icon: Icons.build,
                            label:
                                'Torque: ${widget.conexao.torqueValue} ${widget.conexao.torqueUnit}',
                          ),

                        // Tensionamento
                        if (widget.conexao.tensioningValue != null &&
                            widget.conexao.tensioningUnit != null)
                          _buildDataChip(
                            icon: Icons.compress,
                            label:
                                'Tensão: ${widget.conexao.tensioningValue} ${widget.conexao.tensioningUnit}',
                          ),

                        // Parafusos
                        if (widget.conexao.boltMetric != null)
                          _buildDataChip(
                            icon: Icons.hardware,
                            label: widget.conexao.boltQuantity != null
                                ? '${widget.conexao.boltMetric} x ${widget.conexao.boltQuantity}'
                                : widget.conexao.boltMetric!,
                          ),

                        // Fotos
                        if (widget.conexao.photoUrls.isNotEmpty)
                          _buildDataChip(
                            icon: Icons.photo_library,
                            label:
                                '${widget.conexao.photoUrls.length} foto${widget.conexao.photoUrls.length > 1 ? 's' : ''}',
                          ),

                        // Data execução
                        if (widget.conexao.dataInicio != null)
                          _buildDataChip(
                            icon: Icons.calendar_today,
                            label: _formatDate(widget.conexao.dataInicio!),
                          ),
                      ],
                    ),
                  ],

                  // ════════════════════════════════════════════════════════
                  // FOOTER - Tipo de conexão (se extra)
                  // ════════════════════════════════════════════════════════
                  if (widget.conexao.isExtra) ...[
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
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS - CORES E ÍCONES
  // ══════════════════════════════════════════════════════════════════════════

  Color _getCategoryColor() {
    switch (widget.conexao.categoria) {
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
    switch (widget.conexao.categoria) {
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
    if (widget.conexao.isCompleto) return AppColors.successGreen;
    if (widget.conexao.isEmProgresso) return AppColors.warningOrange;
    return AppColors.borderGray;
  }

  Color _getProgressColor() {
    if (widget.conexao.progresso >= 100) return AppColors.successGreen;
    if (widget.conexao.progresso >= 50) return AppColors.warningOrange;
    return AppColors.accentTeal;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STATUS BADGE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStatusBadge() {
    final String text;
    final Color color;
    final IconData icon;

    if (widget.conexao.isCompleto) {
      text = 'Concluído';
      color = AppColors.successGreen;
      icon = Icons.check_circle;
    } else if (widget.conexao.isEmProgresso) {
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
