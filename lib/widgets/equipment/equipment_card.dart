// ══════════════════════════════════════════════════════════════
// EQUIPMENT CARD WIDGET - DESIGN COMPACTO
// lib/widgets/equipment/equipment_card.dart
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/equipment.dart';
import '../../core/theme/app_colors.dart';

class EquipmentCard extends StatefulWidget {
  final Equipment equipment;
  final CalibrationAlert? alert;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EquipmentCard({
    super.key,
    required this.equipment,
    this.alert,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends State<EquipmentCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final hasAlert = widget.alert != null;
    final statusColor = _getStatusColor(widget.equipment.status);
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final mutedText = AppColors.adaptiveMutedText(context);
    final cardColor = AppColors.adaptivePanelSurface(context).withValues(
      alpha: AppColors.isDarkContext(context) ? 0.72 : 0.84,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasAlert
              ? _getAlertColor(widget.alert!.severity)
              : AppColors.adaptiveOutline(context),
          width: hasAlert ? 1.5 : 1,
        ),
        boxShadow: AppColors.glassShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // ══════════════════════════════════════════════════════
                // HEADER COMPACTO
                // ══════════════════════════════════════════════════════
                Row(
                  children: [
                    // Ícone do tipo
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: statusColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          _getTypeIcon(widget.equipment.type),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Título e Subtítulo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.equipment.model,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: primaryText,
                            ),
                          ),
                          Text(
                            widget.equipment.manufacturer,
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryText,
                            ),
                          ),
                          Text(
                            'SN: ${widget.equipment.serialNumber}',
                            style: TextStyle(
                              fontSize: 10,
                              color: mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusBadgeColor(widget.equipment.status)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.equipment.status.icon,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getStatusBadgeColor(widget.equipment.status),
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: mutedText,
                    ),
                  ],
                ),

                // ══════════════════════════════════════════════════════
                // ALERTA DE CALIBRAÇÃO (se existir)
                // ══════════════════════════════════════════════════════
                if (hasAlert) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getAlertColor(widget.alert!.severity)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getAlertColor(widget.alert!.severity)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _getAlertIcon(widget.alert!.type),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.alert!.message,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getAlertColor(widget.alert!.severity),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ══════════════════════════════════════════════════════
                // DETALHES EXPANDIDOS
                // ══════════════════════════════════════════════════════
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  _buildCompactInfo(
                    '📍 ${t.translate('location')}',
                    widget.equipment.currentLocation,
                  ),
                  const SizedBox(height: 6),
                  _buildCompactInfo(
                    '📅 ${t.translate('calibration')}',
                    '${widget.equipment.calibration.lastDate} → ${widget.equipment.calibration.expiryDate}',
                  ),
                  const SizedBox(height: 6),
                  _buildCompactInfo(
                    '📄 ${t.translate('certificate')}',
                    widget.equipment.calibration.certificateNumber.isNotEmpty
                        ? widget.equipment.calibration.certificateNumber
                        : t.translate('not_available'),
                  ),
                  if (widget.equipment.currentProjectName != null) ...[
                    const SizedBox(height: 6),
                    _buildCompactInfo(
                      '🚧 ${t.translate('project_name')}',
                      widget.equipment.currentProjectName!,
                      highlight: true,
                    ),
                  ],
                  if (widget.equipment.notes != null) ...[
                    const SizedBox(height: 6),
                    _buildCompactInfo(
                      '📝 ${t.translate('notes')}',
                      widget.equipment.notes!,
                    ),
                  ],

                  // Botões de ação
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget
                          .equipment.calibration.certificatePath.isNotEmpty)
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _openCertificate(context),
                            icon: const Icon(Icons.picture_as_pdf, size: 14),
                            label: Text(t.translate('certificate'),
                                style: const TextStyle(fontSize: 11)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              foregroundColor: AppColors.primaryBlue,
                              backgroundColor:
                                  AppColors.primaryBlue.withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      if (widget.onEdit != null) ...[
                        if (widget
                            .equipment.calibration.certificatePath.isNotEmpty)
                          const SizedBox(width: 6),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: widget.onEdit,
                            icon: const Icon(Icons.edit, size: 14),
                            label: Text(t.translate('edit'),
                                style: const TextStyle(fontSize: 11)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              foregroundColor: AppColors.primaryBlue,
                              backgroundColor:
                                  AppColors.primaryBlue.withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (widget.onDelete != null) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: widget.onDelete,
                            icon: const Icon(Icons.delete_outline, size: 14),
                            label: Text(t.translate('delete'),
                                style: const TextStyle(fontSize: 11)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              foregroundColor: AppColors.errorRed,
                              backgroundColor:
                                  AppColors.errorRed.withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ════════════════════════════════════════════════════════════

  Widget _buildCompactInfo(String label, String value,
      {bool highlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.adaptiveSecondaryText(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              color: highlight
                  ? AppColors.primaryBlue
                  : AppColors.adaptivePrimaryText(context),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════════

  LinearGradient _getStatusColor(EquipmentStatus status) {
    switch (status) {
      case EquipmentStatus.disponivel:
        return AppColors.successGradient;
      case EquipmentStatus.emUso:
        return AppColors.warningGradient;
      case EquipmentStatus.manutencao:
        return AppColors.accentGradient;
      case EquipmentStatus.expirado:
        return const LinearGradient(
          colors: [AppColors.errorRed, AppColors.errorRedLight],
        );
    }
  }

  Color _getStatusBadgeColor(EquipmentStatus status) {
    switch (status) {
      case EquipmentStatus.disponivel:
        return AppColors.successGreen;
      case EquipmentStatus.emUso:
        return AppColors.warningOrange;
      case EquipmentStatus.manutencao:
        return AppColors.accentTeal;
      case EquipmentStatus.expirado:
        return AppColors.errorRed;
    }
  }

  String _getTypeIcon(EquipmentType type) {
    switch (type) {
      case EquipmentType.chaveTorque:
        return '🔧';
      case EquipmentType.bombaTorque:
        return '💪';
      case EquipmentType.puller:
        return '⚙️';
      case EquipmentType.bombaTensionamento:
        return '🏗️';
      case EquipmentType.chaveDinometrica:
        return '📏';
      case EquipmentType.outro:
        return '📦';
    }
  }

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

  Future<void> _openCertificate(BuildContext context) async {
    final t = TranslationHelper.of(context);
    final path = widget.equipment.calibration.certificatePath;

    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('equipment_has_no_certificate'))),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${t.translate('opening')}: $path'),
        action: SnackBarAction(
          label: t.translate('ok'),
          onPressed: () {},
        ),
      ),
    );
  }
}
