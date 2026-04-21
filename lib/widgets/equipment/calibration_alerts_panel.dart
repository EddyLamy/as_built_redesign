// ══════════════════════════════════════════════════════════════
// CALIBRATION ALERTS PANEL WIDGET - COMPACTO
// lib/widgets/equipment/calibration_alerts_panel.dart
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../models/equipment.dart';
import '../../core/theme/app_colors.dart';

class CalibrationAlertsPanel extends StatefulWidget {
  final List<CalibrationAlert> alerts;

  const CalibrationAlertsPanel({
    super.key,
    required this.alerts,
  });

  @override
  State<CalibrationAlertsPanel> createState() => _CalibrationAlertsPanelState();
}

class _CalibrationAlertsPanelState extends State<CalibrationAlertsPanel> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) return const SizedBox.shrink();

    // Contar por tipo
    final expired = widget.alerts
        .where((a) => a.type == CalibrationAlertType.expirado)
        .length;
    final urgent = widget.alerts
        .where((a) => a.type == CalibrationAlertType.urgente)
        .length;
    final warning =
        widget.alerts.where((a) => a.type == CalibrationAlertType.aviso).length;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.errorRed.withValues(alpha: 0.1),
            AppColors.warningOrange.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.errorRed.withValues(alpha: 0.3), width: 1.5),
        boxShadow: AppColors.glassShadow,
      ),
      child: Column(
        children: [
          // ══════════════════════════════════════════════════════
          // HEADER
          // ══════════════════════════════════════════════════════
          InkWell(
            onTap: () {
              setState(() {
                _isCollapsed = !_isCollapsed;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Ícone com gradiente
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.errorRed, AppColors.warningOrange],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Título compacto
                  const Expanded(
                    child: Text(
                      '⚠️ Alertas de Calibração',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Badges de contagem
                  if (expired > 0)
                    _buildCountBadge('⛔', expired, AppColors.errorRed),
                  if (urgent > 0) ...[
                    const SizedBox(width: 6),
                    _buildCountBadge('🔴', urgent, AppColors.warningOrange),
                  ],
                  if (warning > 0) ...[
                    const SizedBox(width: 6),
                    _buildCountBadge('🟡', warning, AppColors.accentAmber),
                  ],

                  const SizedBox(width: 8),

                  // Toggle
                  Icon(
                    _isCollapsed ? Icons.expand_more : Icons.expand_less,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // ══════════════════════════════════════════════════════
          // BODY - Lista de alertas
          // ══════════════════════════════════════════════════════
          if (!_isCollapsed)
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: widget.alerts.map((alert) {
                  return _buildAlertItem(alert);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ALERT ITEM
  // ════════════════════════════════════════════════════════════

  Widget _buildAlertItem(CalibrationAlert alert) {
    final color = _getAlertColor(alert.severity);
    final itemColor = AppColors.adaptivePanelSurface(context).withValues(
      alpha: AppColors.isDarkContext(context) ? 0.74 : 0.9,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: itemColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.5),
        boxShadow: AppColors.glassShadow,
      ),
      child: Row(
        children: [
          // Ícone do alerta
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              _getAlertIcon(alert.type),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),

          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Equipamento
                Text(
                  alert.equipment.model,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.adaptivePrimaryText(context),
                  ),
                ),
                // Série
                Text(
                  '(${alert.equipment.serialNumber})',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.adaptiveSecondaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
                // Mensagem
                Text(
                  alert.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Data de validade
                Text(
                  'Validade: ${alert.equipment.calibration.expiryDate}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.adaptiveSecondaryText(context),
                  ),
                ),
              ],
            ),
          ),

          // Dias restantes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              alert.daysUntilExpiry <= 0
                  ? 'EXPIRADO'
                  : '${alert.daysUntilExpiry} dia(s)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ════════════════════════════════════════════════════════════

  Widget _buildCountBadge(String icon, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$icon $count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════════

  Color _getAlertColor(CalibrationAlertSeverity severity) {
    switch (severity) {
      case CalibrationAlertSeverity.critical:
        return AppColors.errorRed;
      case CalibrationAlertSeverity.high:
        return AppColors.warningOrange;
      case CalibrationAlertSeverity.medium:
        return AppColors.accentAmber;
    }
  }

  String _getAlertIcon(CalibrationAlertType type) {
    switch (type) {
      case CalibrationAlertType.expirado:
        return '⛔';
      case CalibrationAlertType.urgente:
        return '🔴';
      case CalibrationAlertType.aviso:
        return '🟡';
    }
  }
}
