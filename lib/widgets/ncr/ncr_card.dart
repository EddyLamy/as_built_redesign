import 'package:flutter/material.dart';

import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ncr.dart';

class NcrCard extends StatelessWidget {
  const NcrCard({
    super.key,
    required this.ncr,
    required this.onTap,
    this.onDelete,
    this.onExportPdf,
    this.onPrintPdf,
    this.compact = false,
  });

  final NcrRecord ncr;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onExportPdf;
  final VoidCallback? onPrintPdf;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final panel = AppColors.adaptivePanelSurface(context).withValues(
      alpha: AppColors.isDarkContext(context) ? 0.72 : 0.82,
    );
    final outline = AppColors.adaptiveOutline(context);
    final severityColor = _severityColor(ncr.severity);
    final statusColor = _statusColor(ncr.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(compact ? 14 : 16),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ncr.isOverdue ? AppColors.warningOrange : outline,
            width: ncr.isOverdue ? 1.2 : 1,
          ),
          boxShadow: AppColors.glassShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ncr.code,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                _Pill(
                  label: _translateSeverity(t, ncr.severity),
                  color: severityColor,
                ),
                const SizedBox(width: 8),
                _Pill(
                  label: _translateStatus(t, ncr.status),
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ncr.title,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryText,
                fontSize: compact ? 15 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(
                  icon: Icons.wind_power,
                  label: ncr.turbinaNome,
                  color: AppColors.primaryBlue,
                ),
                _MetaChip(
                  icon: Icons.category_outlined,
                  label: _translateCategory(t, ncr.category),
                  color: AppColors.accentTeal,
                ),
                _MetaChip(
                  icon: Icons.calendar_today_outlined,
                  label: _formatDate(ncr.dueDate),
                  color: ncr.isOverdue
                      ? AppColors.warningOrange
                      : AppColors.mediumGray,
                ),
                if (ncr.assignedTo.trim().isNotEmpty)
                  _MetaChip(
                    icon: Icons.person_outline,
                    label: ncr.assignedTo,
                    color: AppColors.infoBlue,
                  ),
                if (ncr.statusHistory.isNotEmpty)
                  _MetaChip(
                    icon: Icons.history_toggle_off,
                    label:
                        '${ncr.statusHistory.length} ${t.translate('ncr_status_history')}',
                    color: AppColors.infoBlue,
                  ),
                if (ncr.evidence.isNotEmpty)
                  _MetaChip(
                    icon: Icons.attach_file,
                    label:
                        '${ncr.evidence.length} ${t.translate('ncr_evidence')}',
                    color: AppColors.successGreen,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ncr.description,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: secondaryText,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            if (ncr.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ncr.tags
                    .take(4)
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.adaptivePanelSurface(context)
                              .withValues(
                            alpha:
                                AppColors.isDarkContext(context) ? 0.84 : 0.82,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: outline),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            if (ncr.closureNote.trim().isNotEmpty) ...[
              Text(
                t.translate('ncr_closure_note'),
                style: TextStyle(
                  color: primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ncr.closureNote,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Text(
                  '${t.translate('created')}: ${_formatDate(ncr.createdAt)}',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                if (ncr.closedByName.trim().isNotEmpty)
                  Text(
                    '${t.translate('ncr_closed_by')}: ${ncr.closedByName}',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 11,
                    ),
                  ),
                if (ncr.closedByName.trim().isNotEmpty)
                  const SizedBox(width: 10),
                if (onPrintPdf != null)
                  IconButton(
                    onPressed: onPrintPdf,
                    icon: const Icon(Icons.print_outlined),
                    color: secondaryText,
                    tooltip: t.translate('print'),
                    visualDensity: VisualDensity.compact,
                  ),
                if (onExportPdf != null)
                  IconButton(
                    onPressed: onExportPdf,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    color: secondaryText,
                    tooltip: 'PDF',
                    visualDensity: VisualDensity.compact,
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.errorRed,
                    tooltip: t.translate('delete'),
                    visualDensity: VisualDensity.compact,
                  ),
                Icon(
                  Icons.chevron_right,
                  color: secondaryText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _severityColor(NcrSeverity severity) {
    switch (severity) {
      case NcrSeverity.low:
        return AppColors.successGreen;
      case NcrSeverity.medium:
        return AppColors.infoBlue;
      case NcrSeverity.high:
        return AppColors.warningOrange;
      case NcrSeverity.critical:
        return AppColors.errorRed;
    }
  }

  Color _statusColor(NcrStatus status) {
    switch (status) {
      case NcrStatus.open:
        return AppColors.warningOrange;
      case NcrStatus.inProgress:
        return AppColors.infoBlue;
      case NcrStatus.pendingValidation:
        return AppColors.accentTeal;
      case NcrStatus.resolved:
        return AppColors.successGreen;
      case NcrStatus.closed:
        return AppColors.mediumGray;
    }
  }

  String _translateCategory(TranslationHelper t, NcrCategory category) {
    return t.translate('ncr_category_${category.value}');
  }

  String _translateSeverity(TranslationHelper t, NcrSeverity severity) {
    return t.translate('ncr_severity_${severity.value}');
  }

  String _translateStatus(TranslationHelper t, NcrStatus status) {
    return t.translate('ncr_status_${status.value}');
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
