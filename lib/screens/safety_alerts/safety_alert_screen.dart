import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/safety_alert.dart';
import '../../providers/app_providers.dart';
import '../../providers/permission_provider.dart';
import '../../providers/safety_alert_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/background_watermark.dart';
import '../../widgets/liquid_glass_overlays.dart';
import 'safety_alert_dialog.dart';

class SafetyAlertScreen extends ConsumerStatefulWidget {
  const SafetyAlertScreen({
    super.key,
    this.embeddedInDesktopShell = false,
    this.projectIdOverride,
    this.projectNameOverride,
  });

  final bool embeddedInDesktopShell;
  final String? projectIdOverride;
  final String? projectNameOverride;

  @override
  ConsumerState<SafetyAlertScreen> createState() => _SafetyAlertScreenState();
}

class _SafetyAlertScreenState extends ConsumerState<SafetyAlertScreen> {
  final TextEditingController _searchController = TextEditingController();
  SafetyAlertCategory? _categoryFilter;
  SafetyAlertStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _glassPanelColor(BuildContext context) {
    final base = AppColors.adaptivePanelSurface(context);
    return base.withValues(
      alpha: AppColors.isDarkContext(context) ? 0.72 : 0.88,
    );
  }

  Color _mutedText(BuildContext context) =>
      AppColors.adaptiveSecondaryText(context);

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final selectedProjectId = ref.watch(accessibleSelectedProjectIdProvider);
    final projectId = widget.projectIdOverride ?? selectedProjectId;
    final selectedProject = ref.watch(selectedProjectProvider).asData?.value;
    final permissions = ref.watch(permissionProvider(projectId));
    final projectName = widget.projectNameOverride?.trim().isNotEmpty == true
        ? widget.projectNameOverride!.trim()
        : selectedProject?.nome ?? '';

    final bodyContent = projectId == null
        ? _buildProjectRequiredState(context, t)
        : _buildContent(
            context,
            ref,
            projectId,
            projectName,
            permissions,
            t,
          );

    final screenBody = Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.isDarkContext(context) ? null : Colors.white,
              gradient: AppColors.isDarkContext(context)
                  ? AppColors.liquidGlassBackgroundDark
                  : null,
            ),
          ),
        ),
        const BackgroundWatermark(
          size: 520,
          opacity: 0.025,
          alignment: Alignment.centerRight,
        ),
        bodyContent,
      ],
    );

    if (widget.embeddedInDesktopShell) {
      return screenBody;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        title: Text(t.translate('safety_alert_management')),
      ),
      body: screenBody,
    );
  }

  Widget _buildProjectRequiredState(
    BuildContext context,
    TranslationHelper t,
  ) {
    return Center(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _glassPanelColor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.adaptiveOutline(context)),
          boxShadow: AppColors.glassShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.folder_open_outlined,
              size: 56,
              color: AppColors.infoBlue,
            ),
            const SizedBox(height: 12),
            Text(
              t.translate('select_project_first'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.adaptivePrimaryText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String projectName,
    PermissionNotifier permissions,
    TranslationHelper t,
  ) {
    final alertsAsync = ref.watch(projectSafetyAlertsProvider(projectId));
    final summaryAsync =
        ref.watch(projectSafetyAlertSummaryProvider(projectId));
    final outline = AppColors.adaptiveOutline(context);
    final panel = _glassPanelColor(context);
    final fieldFill = AppColors.adaptiveCardSurface(context).withValues(
      alpha: AppColors.isDarkContext(context) ? 0.8 : 0.94,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.health_and_safety_outlined,
                          color: AppColors.warningOrange,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            t.translate('safety_alert_management'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.adaptivePrimaryText(context),
                            ),
                          ),
                        ),
                        if (projectName.trim().isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.adaptiveCardSurface(context)
                                    .withValues(
                                  alpha: AppColors.isDarkContext(context)
                                      ? 0.86
                                      : 0.92,
                                ),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: outline),
                                boxShadow: AppColors.glassShadow,
                              ),
                              child: Text(
                                projectName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _mutedText(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.translate('safety_alert_search_hint'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: _mutedText(context),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: ElevatedButton.icon(
                  onPressed: permissions.isLoading ||
                          !permissions.canManageInstallation
                      ? null
                      : () => _openAlertDialog(context, projectId),
                  icon: const Icon(Icons.add_alert_outlined),
                  label: Text(t.translate('safety_alert_new')),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: summaryAsync.when(
            data: (summary) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryCard(
                  label: t.translate('safety_alert_total'),
                  value: summary.total,
                  color: AppColors.primaryBlue,
                  compact: true,
                ),
                _SummaryCard(
                  label: t.translate('safety_alert_status_resolved'),
                  value: summary.resolved,
                  color: AppColors.successGreen,
                  compact: true,
                ),
                _SummaryCard(
                  label: t.translate('safety_alert_status_under_study'),
                  value: summary.underStudy,
                  color: AppColors.warningOrange,
                  compact: true,
                ),
                _SummaryCard(
                  label: t.translate('safety_alert_status_in_resolution'),
                  value: summary.inResolution,
                  color: AppColors.infoBlue,
                  compact: true,
                ),
                _SummaryCard(
                  label: t.translate('safety_alert_status_requires_action'),
                  value: summary.futureCompanyAction,
                  color: AppColors.errorRed,
                  compact: true,
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(minHeight: 2),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: outline),
              boxShadow: AppColors.glassShadow,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 820;

                InputDecoration filterDecoration(String label) {
                  return InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: fieldFill,
                    hintText: label,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: AppColors.adaptiveSecondaryText(context),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 1.2,
                      ),
                    ),
                  );
                }

                Widget categoryField() {
                  return DropdownButtonFormField<SafetyAlertCategory?>(
                    initialValue: _categoryFilter,
                    isExpanded: true,
                    isDense: true,
                    iconSize: 20,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.adaptivePrimaryText(context),
                    ),
                    decoration: filterDecoration(
                      t.translate('safety_alert_category'),
                    ),
                    items: [
                      DropdownMenuItem<SafetyAlertCategory?>(
                        value: null,
                        child: Text(t.translate('all')),
                      ),
                      ...SafetyAlertCategory.values.map(
                        (item) => DropdownMenuItem<SafetyAlertCategory?>(
                          value: item,
                          child: Text(
                            t.translate(
                              'safety_alert_category_${item.value}',
                            ),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _categoryFilter = value);
                    },
                  );
                }

                Widget statusField() {
                  return DropdownButtonFormField<SafetyAlertStatus?>(
                    initialValue: _statusFilter,
                    isExpanded: true,
                    isDense: true,
                    iconSize: 20,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.adaptivePrimaryText(context),
                    ),
                    decoration: filterDecoration(
                      t.translate('safety_alert_status'),
                    ),
                    items: [
                      DropdownMenuItem<SafetyAlertStatus?>(
                        value: null,
                        child: Text(t.translate('all')),
                      ),
                      ...SafetyAlertStatus.values.map(
                        (item) => DropdownMenuItem<SafetyAlertStatus?>(
                          value: item,
                          child: Text(
                            t.translate(
                              'safety_alert_status_${item.value}',
                            ),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _statusFilter = value);
                    },
                  );
                }

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: fieldFill,
                            hintText: t.translate('safety_alert_search_hint'),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: outline),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: categoryField(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: statusField(),
                      ),
                    ],
                  );
                }

                final filterWidth = constraints.maxWidth < 760
                    ? constraints.maxWidth
                    : ((constraints.maxWidth - 12) / 2).clamp(0.0, 360.0);

                return Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: fieldFill,
                        hintText: t.translate('safety_alert_search_hint'),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: outline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(width: filterWidth, child: categoryField()),
                        SizedBox(width: filterWidth, child: statusField()),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Expanded(
          child: alertsAsync.when(
            data: (alerts) {
              final filtered = alerts.where(_matchesFilters).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    t.translate('safety_alert_empty'),
                    style: TextStyle(color: _mutedText(context)),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final alert = filtered[index];
                  return _SafetyAlertCard(
                    alert: alert,
                    categoryLabel: t.translate(
                      'safety_alert_category_${alert.category.value}',
                    ),
                    statusLabel: t.translate(
                      'safety_alert_status_${alert.status.value}',
                    ),
                    onEdit: permissions.canManageInstallation
                        ? () =>
                            _openAlertDialog(context, projectId, alert: alert)
                        : null,
                    onDelete: permissions.canManageInstallation
                        ? () => _deleteAlert(
                              context,
                              ref,
                              alert,
                              t,
                            )
                        : null,
                    onExport: () => _exportAlertPdf(
                      context,
                      ref,
                      alert,
                      t,
                      projectName: projectName,
                    ),
                    onPrint: () => _printAlertPdf(
                      context,
                      ref,
                      alert,
                      t,
                      projectName: projectName,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                '$error',
                style: TextStyle(color: _mutedText(context)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _matchesFilters(SafetyAlertRecord alert) {
    final query = _searchController.text.trim().toLowerCase();
    final matchesQuery = query.isEmpty ||
        alert.code.toLowerCase().contains(query) ||
        alert.destinationTo.toLowerCase().contains(query) ||
        alert.department.toLowerCase().contains(query) ||
        alert.problemDescription.toLowerCase().contains(query) ||
        alert.proposedSolution.toLowerCase().contains(query) ||
        alert.resolucaoEfetuada.toLowerCase().contains(query);
    final matchesCategory =
        _categoryFilter == null || alert.category == _categoryFilter;
    final matchesStatus =
        _statusFilter == null || alert.status == _statusFilter;
    return matchesQuery && matchesCategory && matchesStatus;
  }

  void _openAlertDialog(
    BuildContext context,
    String projectId, {
    SafetyAlertRecord? alert,
  }) {
    showLiquidDialog(
      context: context,
      builder: (_) => SafetyAlertDialog(projectId: projectId, alert: alert),
    );
  }

  Future<void> _deleteAlert(
    BuildContext context,
    WidgetRef ref,
    SafetyAlertRecord alert,
    TranslationHelper t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.translate('delete')),
          content: Text(t.translate('safety_alert_delete_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(t.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(t.translate('delete')),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(safetyAlertServiceProvider).deleteAlert(alert);
      if (!context.mounted) {
        return;
      }
      showAppFeedback(
        t.translate('safety_alert_deleted_success'),
        type: AppFeedbackType.success,
      );
    }
  }

  Future<void> _exportAlertPdf(
    BuildContext context,
    WidgetRef ref,
    SafetyAlertRecord alert,
    TranslationHelper t, {
    required String projectName,
  }) async {
    try {
      final savedPath =
          await ref.read(safetyAlertPdfExportServiceProvider).savePdf(
                alert: alert,
                t: t,
                projectName: projectName,
              );

      if (!context.mounted) {
        return;
      }

      final message = savedPath == null || savedPath.isEmpty
          ? t.translate('safety_alert_export_saved')
          : '${t.translate('safety_alert_export_saved')}\n$savedPath';
      showAppFeedback(message, type: AppFeedbackType.success);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      showAppFeedback(
        '${t.translate('safety_alert_export_error')}\n$error',
        type: AppFeedbackType.error,
      );
    }
  }

  Future<void> _printAlertPdf(
    BuildContext context,
    WidgetRef ref,
    SafetyAlertRecord alert,
    TranslationHelper t, {
    required String projectName,
  }) async {
    try {
      await ref.read(safetyAlertPdfExportServiceProvider).printPdf(
            alert: alert,
            t: t,
            projectName: projectName,
          );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      showAppFeedback(
        '${t.translate('safety_alert_export_error')}\n$error',
        type: AppFeedbackType.error,
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
  });

  final String label;
  final int value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: compact ? 11 : 12,
      fontWeight: FontWeight.w500,
      color: AppColors.adaptiveSecondaryText(context),
    );
    final valueStyle = TextStyle(
      fontSize: compact ? 21 : 24,
      fontWeight: FontWeight.w800,
      color: color,
    );

    return Container(
      width: 180,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardSurface(context).withValues(
          alpha: AppColors.isDarkContext(context) ? 0.74 : 0.9,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
        boxShadow: AppColors.glassShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$value',
            textAlign: TextAlign.right,
            style: valueStyle,
          ),
        ],
      ),
    );
  }
}

class _SafetyAlertCard extends StatelessWidget {
  const _SafetyAlertCard({
    required this.alert,
    required this.categoryLabel,
    required this.statusLabel,
    required this.onExport,
    required this.onPrint,
    this.onEdit,
    this.onDelete,
  });

  final SafetyAlertRecord alert;
  final String categoryLabel;
  final String statusLabel;
  final VoidCallback onExport;
  final VoidCallback onPrint;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardSurface(context).withValues(
          alpha: AppColors.isDarkContext(context) ? 0.74 : 0.9,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
        boxShadow: AppColors.glassShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          initiallyExpanded: false,
          iconColor: AppColors.adaptiveSecondaryText(context),
          collapsedIconColor: AppColors.adaptiveSecondaryText(context),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.code,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.infoBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Tag(
                            text: categoryLabel,
                            color: AppColors.warningOrange),
                        _Tag(
                            text: statusLabel,
                            color: _statusColor(alert.status)),
                        _Tag(
                          text:
                              '${alert.evidence.length}/3 ${TranslationHelper.of(context).translate('safety_alert_photos')}',
                          color: AppColors.primaryBlue,
                        ),
                        _Tag(
                          text:
                              '${alert.resolutionEvidence.length}/3 ${TranslationHelper.of(context).translate('safety_alert_resolution_photos')}',
                          color: AppColors.successGreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDate(alert.updatedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.adaptiveSecondaryText(context),
                ),
              ),
            ],
          ),
          children: [
            _FieldBlock(
              label: TranslationHelper.of(context)
                  .translate('safety_alert_destination_to'),
              value: alert.destinationTo,
            ),
            const SizedBox(height: 12),
            _FieldBlock(
              label: TranslationHelper.of(context)
                  .translate('safety_alert_department'),
              value: alert.department,
            ),
            const SizedBox(height: 12),
            _FieldBlock(
              label: TranslationHelper.of(context)
                  .translate('safety_alert_problem_description'),
              value: alert.problemDescription,
            ),
            const SizedBox(height: 12),
            _FieldBlock(
              label: TranslationHelper.of(context)
                  .translate('safety_alert_possible_solution'),
              value: alert.proposedSolution,
            ),
            const SizedBox(height: 12),
            _FieldBlock(
              label: TranslationHelper.of(context)
                  .translate('safety_alert_resolucao_efetuada'),
              value: alert.resolucaoEfetuada,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.download_outlined),
                  label:
                      Text(TranslationHelper.of(context).translate('export')),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: onPrint,
                  icon: const Icon(Icons.print_outlined),
                  label: Text(
                    TranslationHelper.of(context)
                        .translate('safety_alert_print'),
                  ),
                ),
                const Spacer(),
                if (onEdit != null) ...[
                  IconButton(
                    onPressed: onEdit,
                    tooltip: TranslationHelper.of(context).translate('edit'),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
                if (onDelete != null) ...[
                  IconButton(
                    onPressed: onDelete,
                    tooltip: TranslationHelper.of(context).translate('delete'),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(SafetyAlertStatus status) {
    switch (status) {
      case SafetyAlertStatus.resolved:
        return AppColors.successGreen;
      case SafetyAlertStatus.underStudy:
        return AppColors.warningOrange;
      case SafetyAlertStatus.inResolution:
        return AppColors.infoBlue;
      case SafetyAlertStatus.futureCompanyAction:
        return AppColors.errorRed;
    }
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.adaptiveSecondaryText(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.trim().isEmpty ? '-' : value.trim(),
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: AppColors.adaptivePrimaryText(context),
          ),
        ),
      ],
    );
  }
}
