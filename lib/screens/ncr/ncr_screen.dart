import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ncr.dart';
import '../../providers/app_providers.dart';
import '../../providers/ncr_provider.dart';
import '../../providers/permission_provider.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../widgets/background_watermark.dart';
import '../../widgets/generate_report_dialog.dart';
import '../../widgets/ncr/ncr_card.dart';
import 'ncr_dialog.dart';

class NcrScreen extends ConsumerStatefulWidget {
  const NcrScreen({
    super.key,
    this.embeddedInDesktopShell = false,
  });

  final bool embeddedInDesktopShell;

  @override
  ConsumerState<NcrScreen> createState() => _NcrScreenState();
}

class _NcrScreenState extends ConsumerState<NcrScreen> {
  final TextEditingController _searchController = TextEditingController();
  NcrStatus? _statusFilter;
  NcrSeverity? _severityFilter;
  NcrCategory? _categoryFilter;
  bool _showOverdueOnly = false;
  bool _gridView = false;

  Color _glassPanelColor(BuildContext context) {
    final base = AppColors.adaptivePanelSurface(context);
    return base.withValues(
      alpha: AppColors.isDarkContext(context) ? 0.72 : 0.88,
    );
  }

  Color _mutedText(BuildContext context) =>
      AppColors.adaptiveSecondaryText(context);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final projectId = ref.watch(accessibleSelectedProjectIdProvider);
    final selectedProject = ref.watch(selectedProjectProvider).asData?.value;
    final permissions = ref.watch(permissionProvider(projectId));
    final bodyContent = projectId == null
        ? _buildProjectRequiredState(context, t)
        : _buildContent(context, ref, projectId, selectedProject?.nome ?? '',
            permissions, t);

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
        title: DashboardShortcutTitle(
          child: Text('📋 ${t.translate('ncrs')}'),
        ),
        actions: [
          IconButton(
            onPressed: projectId == null || selectedProject == null
                ? null
                : () {
                    showLiquidDialog(
                      context: context,
                      builder: (_) => GenerateReportDialog(
                        projectId: selectedProject.id,
                        projectName: selectedProject.nome,
                      ),
                    );
                  },
            icon: const Icon(Icons.description_outlined),
            tooltip: t.translate('generate_report'),
          ),
        ],
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
            const Icon(Icons.folder_open_outlined,
                size: 56, color: AppColors.infoBlue),
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
    final ncrsAsync = ref.watch(projectNcrsProvider(projectId));
    final summaryAsync = ref.watch(projectNcrSummaryProvider(projectId));
    final outline = AppColors.adaptiveOutline(context);
    final panel = _glassPanelColor(context);

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
                          Icons.rule_folder_outlined,
                          color: AppColors.errorRed,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            t.translate('ncr_management'),
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
                      t.translate('ncr_search_hint'),
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
                  onPressed: permissions.isLoading
                      ? null
                      : () => _handleCreateNcrTap(
                            context,
                            projectId,
                            permissions,
                            t,
                          ),
                  icon: permissions.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(t.translate('ncr_new')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE87511),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.white.withValues(alpha: 0.7),
                    disabledForegroundColor: AppColors.mediumGray,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: summaryAsync.when(
              data: (summary) => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _SummaryCard(
                    label: t.translate('ncr_total'),
                    value: summary.total,
                    color: AppColors.primaryBlue,
                  ),
                  _SummaryCard(
                    label: t.translate('ncr_open_count'),
                    value: summary.open,
                    color: AppColors.infoBlue,
                  ),
                  _SummaryCard(
                    label: t.translate('ncr_in_progress_count'),
                    value: summary.inProgress,
                    color: AppColors.accentTeal,
                  ),
                  _SummaryCard(
                    label: t.translate('ncr_overdue_count'),
                    value: summary.overdue,
                    color: AppColors.warningOrange,
                  ),
                  _SummaryCard(
                    label: t.translate('ncr_critical_count'),
                    value: summary.critical,
                    color: AppColors.errorRed,
                  ),
                ],
              ),
              loading: () => Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: outline),
                  boxShadow: AppColors.glassShadow,
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: outline),
            boxShadow: AppColors.glassShadow,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final searchField = TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: t.translate('ncr_search_hint'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );

              final controls = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OverdueIconButton(
                    selected: _showOverdueOnly,
                    tooltip: t.translate('ncr_overdue_only'),
                    onTap: () {
                      setState(() => _showOverdueOnly = !_showOverdueOnly);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildStatusFilterChip(t),
                  const SizedBox(width: 8),
                  _buildSeverityFilterChip(t),
                  const SizedBox(width: 8),
                  _buildCategoryFilterChip(t),
                  const SizedBox(width: 8),
                  _ViewModeToggle(
                    isGridView: _gridView,
                    onChanged: (value) {
                      setState(() => _gridView = value);
                    },
                  ),
                ],
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: searchField),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: controls,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: ncrsAsync.when(
            data: (ncrs) {
              final filtered = _applyFilters(ncrs);
              if (filtered.isEmpty) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: outline),
                      boxShadow: AppColors.glassShadow,
                    ),
                    child: Text(
                      t.translate('ncr_empty'),
                      style: TextStyle(color: _mutedText(context)),
                    ),
                  ),
                );
              }

              if (_gridView) {
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.18,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ncr = filtered[index];
                    return NcrCard(
                      ncr: ncr,
                      compact: true,
                      onPrintPdf: () => _printNcrPdf(
                        context,
                        ref,
                        ncr,
                        t,
                        projectName: projectName,
                      ),
                      onExportPdf: () => _exportNcrPdf(
                        context,
                        ref,
                        ncr,
                        t,
                        projectName: projectName,
                      ),
                      onTap: permissions.canManageEquipmentAndDocs
                          ? () => _openNcrDialog(context, projectId, ncr: ncr)
                          : () {},
                      onDelete: permissions.canManageEquipmentAndDocs
                          ? () => _deleteNcr(context, ref, ncr, t)
                          : null,
                    );
                  },
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ncr = filtered[index];
                  return NcrCard(
                    ncr: ncr,
                    compact: true,
                    onPrintPdf: () => _printNcrPdf(
                      context,
                      ref,
                      ncr,
                      t,
                      projectName: projectName,
                    ),
                    onExportPdf: () => _exportNcrPdf(
                      context,
                      ref,
                      ncr,
                      t,
                      projectName: projectName,
                    ),
                    onTap: permissions.canManageEquipmentAndDocs
                        ? () => _openNcrDialog(context, projectId, ncr: ncr)
                        : () {},
                    onDelete: permissions.canManageEquipmentAndDocs
                        ? () => _deleteNcr(context, ref, ncr, t)
                        : null,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('${t.translate('error')}: $error'),
            ),
          ),
        ),
      ],
    );
  }

  List<NcrRecord> _applyFilters(List<NcrRecord> ncrs) {
    final query = _searchController.text.trim().toLowerCase();
    return ncrs.where((ncr) {
      final matchesQuery = query.isEmpty ||
          ncr.code.toLowerCase().contains(query) ||
          ncr.title.toLowerCase().contains(query) ||
          ncr.description.toLowerCase().contains(query) ||
          ncr.turbinaNome.toLowerCase().contains(query) ||
          ncr.assignedTo.toLowerCase().contains(query);
      final matchesStatus =
          _statusFilter == null || ncr.status == _statusFilter;
      final matchesSeverity =
          _severityFilter == null || ncr.severity == _severityFilter;
      final matchesCategory =
          _categoryFilter == null || ncr.category == _categoryFilter;
      final matchesOverdue = !_showOverdueOnly || ncr.isOverdue;
      return matchesQuery &&
          matchesStatus &&
          matchesSeverity &&
          matchesCategory &&
          matchesOverdue;
    }).toList();
  }

  void _handleCreateNcrTap(
    BuildContext context,
    String projectId,
    PermissionNotifier permissions,
    TranslationHelper t,
  ) {
    if (!permissions.canManageEquipmentAndDocs) {
      showAppFeedback(
        t.translate('no_permission'),
        type: AppFeedbackType.warning,
      );
      return;
    }

    _openNcrDialog(context, projectId);
  }

  Widget _buildStatusFilterChip(TranslationHelper t) {
    return PopupMenuButton<NcrStatus?>(
      onSelected: (value) => setState(() => _statusFilter = value),
      itemBuilder: (context) => [
        PopupMenuItem<NcrStatus?>(value: null, child: Text(t.translate('all'))),
        ...NcrStatus.values.map(
          (status) => PopupMenuItem<NcrStatus?>(
            value: status,
            child: Text(t.translate('ncr_status_${status.value}')),
          ),
        ),
      ],
      child: _FilterBadge(
        icon: Icons.track_changes_outlined,
        label: _statusFilter == null
            ? t.translate('status')
            : t.translate('ncr_status_${_statusFilter!.value}'),
      ),
    );
  }

  Widget _buildSeverityFilterChip(TranslationHelper t) {
    return PopupMenuButton<NcrSeverity?>(
      onSelected: (value) => setState(() => _severityFilter = value),
      itemBuilder: (context) => [
        PopupMenuItem<NcrSeverity?>(
            value: null, child: Text(t.translate('all'))),
        ...NcrSeverity.values.map(
          (severity) => PopupMenuItem<NcrSeverity?>(
            value: severity,
            child: Text(t.translate('ncr_severity_${severity.value}')),
          ),
        ),
      ],
      child: _FilterBadge(
        icon: Icons.priority_high_outlined,
        label: _severityFilter == null
            ? t.translate('ncr_severity')
            : t.translate('ncr_severity_${_severityFilter!.value}'),
      ),
    );
  }

  Widget _buildCategoryFilterChip(TranslationHelper t) {
    return PopupMenuButton<NcrCategory?>(
      onSelected: (value) => setState(() => _categoryFilter = value),
      itemBuilder: (context) => [
        PopupMenuItem<NcrCategory?>(
            value: null, child: Text(t.translate('all'))),
        ...NcrCategory.values.map(
          (category) => PopupMenuItem<NcrCategory?>(
            value: category,
            child: Text(t.translate('ncr_category_${category.value}')),
          ),
        ),
      ],
      child: _FilterBadge(
        icon: Icons.category_outlined,
        label: _categoryFilter == null
            ? t.translate('ncr_category')
            : t.translate('ncr_category_${_categoryFilter!.value}'),
      ),
    );
  }

  void _openNcrDialog(BuildContext context, String projectId,
      {NcrRecord? ncr}) {
    showLiquidDialog(
      context: context,
      builder: (_) => NcrDialog(projectId: projectId, ncr: ncr),
    );
  }

  Future<void> _deleteNcr(
    BuildContext context,
    WidgetRef ref,
    NcrRecord ncr,
    TranslationHelper t,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.translate('delete')),
          content: Text(t.translate('ncr_delete_confirm')),
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
      await ref.read(ncrServiceProvider).deleteNcr(ncr);
      if (!context.mounted) {
        return;
      }
      if (mounted) {
        showAppFeedback(
          t.translate('ncr_deleted_success'),
          type: AppFeedbackType.success,
        );
      }
    }
  }

  Future<void> _exportNcrPdf(
    BuildContext context,
    WidgetRef ref,
    NcrRecord ncr,
    TranslationHelper t, {
    required String projectName,
  }) async {
    try {
      final savedPath = await ref.read(ncrPdfExportServiceProvider).savePdf(
            ncr: ncr,
            t: t,
            projectName: projectName,
          );

      if (!context.mounted) {
        return;
      }

      final message = savedPath == null || savedPath.isEmpty
          ? t.translate('ncr_pdf_saved')
          : '${t.translate('ncr_pdf_saved')}\n$savedPath';

      showAppFeedback(
        message,
        type: AppFeedbackType.success,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      showAppFeedback(
        '${t.translate('ncr_pdf_error')}\n$error',
        type: AppFeedbackType.error,
      );
    }
  }

  Future<void> _printNcrPdf(
    BuildContext context,
    WidgetRef ref,
    NcrRecord ncr,
    TranslationHelper t, {
    required String projectName,
  }) async {
    try {
      await ref.read(ncrPdfExportServiceProvider).printPdf(
            ncr: ncr,
            t: t,
            projectName: projectName,
          );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      showAppFeedback(
        '${t.translate('ncr_pdf_error')}\n$error',
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
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final panel = AppColors.adaptiveCardSurface(context).withValues(
      alpha: AppColors.isDarkContext(context) ? 0.74 : 0.9,
    );

    return Container(
      width: 132,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.24)),
        boxShadow: AppColors.glassShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _FilterBadge extends StatelessWidget {
  const _FilterBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.adaptiveCardSurface(context).withValues(
      alpha: AppColors.isDarkContext(context) ? 0.78 : 0.92,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
        boxShadow: AppColors.glassShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.adaptiveSecondaryText(context)),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.adaptivePrimaryText(context),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.expand_more,
            size: 16,
            color: AppColors.adaptiveSecondaryText(context),
          ),
        ],
      ),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({
    required this.isGridView,
    required this.onChanged,
  });

  final bool isGridView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.adaptiveCardSurface(context).withValues(
      alpha: AppColors.isDarkContext(context) ? 0.8 : 0.94,
    );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
        boxShadow: AppColors.glassShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewModeButton(
            icon: Icons.grid_view_rounded,
            label: 'Cards',
            selected: isGridView,
            onTap: () => onChanged(true),
          ),
          _ViewModeButton(
            icon: Icons.view_list_rounded,
            label: 'Lista',
            selected: !isGridView,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _OverdueIconButton extends StatelessWidget {
  const _OverdueIconButton({
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.errorRed;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.errorRed.withValues(alpha: 0.12)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.watch_later_outlined, color: color, size: 22),
        ),
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.adaptivePanelSurface(context).withValues(
                  alpha: AppColors.isDarkContext(context) ? 0.82 : 0.96,
                )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected ? AppColors.glassShadow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: AppColors.adaptiveSecondaryText(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.adaptivePrimaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
