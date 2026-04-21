// lib/screens/equipment/equipment_screen.dart

import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/equipment.dart';
import '../../providers/equipment_provider.dart';
import '../../providers/permission_provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/equipment/equipment_card.dart';
import '../../widgets/equipment/add_equipment_dialog.dart';
import '../../widgets/equipment/calibration_alerts_panel.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../widgets/background_watermark.dart';
import '../../core/theme/app_colors.dart';

void showAddEquipmentDialogForShell(
  BuildContext context,
  WidgetRef ref,
  TranslationHelper t,
) {
  final projectId = ref.read(accessibleSelectedProjectIdProvider);
  final permissions = ref.read(permissionProvider(projectId));

  if (permissions.isLoading) {
    return;
  }

  if (projectId == null || projectId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.translate('select_project_first'))),
    );
    return;
  }

  if (!permissions.canManageEquipmentAndDocs) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.translate('no_permission'))),
    );
    return;
  }

  showLiquidDialog(
    context: context,
    builder: (context) => const AddEquipmentDialog(),
  );
}

class EquipmentScreen extends ConsumerWidget {
  const EquipmentScreen({
    super.key,
    this.embeddedInDesktopShell = false,
  });

  final bool embeddedInDesktopShell;

  Color _glassPanelColor(BuildContext context) {
    final base = AppColors.adaptivePanelSurface(context);
    return base.withValues(
      alpha: AppColors.isDarkContext(context) ? 0.72 : 0.9,
    );
  }

  Color _glassInputColor(BuildContext context) {
    final base = AppColors.adaptiveCardSurface(context);
    return base.withValues(
      alpha: AppColors.isDarkContext(context) ? 0.9 : 0.94,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);
    final equipmentAsync = ref.watch(filteredEquipmentProvider);
    final groupedAsync = ref.watch(groupedEquipmentProvider);
    final alertsAsync = ref.watch(calibrationAlertsProvider);
    final filters = ref.watch(equipmentFiltersProvider);

    final projectId = ref.watch(accessibleSelectedProjectIdProvider);
    final permissions = ref.watch(permissionProvider(projectId));

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
          size: 420,
          opacity: 0.04,
          alignment: Alignment.centerRight,
        ),
        SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1460),
              child: Column(
                children: [
                  alertsAsync.when(
                    data: (alerts) {
                      if (alerts.isEmpty) return const SizedBox.shrink();
                      return CalibrationAlertsPanel(alerts: alerts);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: _buildFilters(context, ref, filters, t),
                  ),
                  Expanded(
                    child: equipmentAsync.when(
                      data: (equipment) {
                        if (equipment.isEmpty) {
                          return _buildEmptyState(
                            context,
                            true,
                            t,
                          );
                        }

                        return groupedAsync.when(
                          data: (grouped) => _buildGroupedList(
                            context,
                            ref,
                            grouped,
                            alertsAsync.value,
                            permissions.canManageEquipmentAndDocs,
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, s) => Center(
                              child: Text('${t.translate('error')}: $e')),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 56, color: AppColors.errorRed),
                              const SizedBox(height: 12),
                              Text(
                                '${t.translate('equipment_load_error')}:\n$error',
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () =>
                                    ref.refresh(equipmentStreamProvider),
                                child: Text(t.translate('try_again')),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (embeddedInDesktopShell) {
      return screenBody;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: DashboardShortcutTitle(
          child: Text('🔧 ${t.translate('equipment')}'),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            onPressed: permissions.isLoading
                ? null
                : () => _handleAddEquipmentTap(
                      context,
                      projectId,
                      permissions,
                      t,
                    ),
            tooltip: t.translate('add'),
            icon: permissions.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add),
          ),
        ],
      ),
      body: screenBody,

      // ════════════════════════════════════════════════════════
      // FAB — só visível para quem pode gerir equipamento
      // ════════════════════════════════════════════════════════
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.accentTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: permissions.isLoading
              ? null
              : () => _handleAddEquipmentTap(
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.add),
          label: Text(t.translate('add')),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // FILTROS
  // ════════════════════════════════════════════════════════════

  Widget _buildFilters(BuildContext context, WidgetRef ref,
      EquipmentFilters filters, TranslationHelper t) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _glassPanelColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
        boxShadow: AppColors.glassShadow,
      ),
      child: Column(
        children: [
          // Pesquisa
          TextField(
            decoration: InputDecoration(
              hintText: '🔍 ${t.translate('search_equipment_hint')}',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: filters.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        ref
                            .read(equipmentFiltersProvider.notifier)
                            .setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: _glassInputColor(context),
            ),
            onChanged: (value) {
              ref.read(equipmentFiltersProvider.notifier).setSearchQuery(value);
            },
          ),
          const SizedBox(height: 10),

          // Filtros em linha
          Row(
            children: [
              // Tipo
              Expanded(
                child: _buildDropdown<EquipmentType?>(
                  context: context,
                  label: t.translate('type'),
                  value: filters.typeFilter,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(t.translate('all')),
                    ),
                    ...EquipmentType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    ref
                        .read(equipmentFiltersProvider.notifier)
                        .setTypeFilter(value);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Status
              Expanded(
                child: _buildDropdown<EquipmentStatus?>(
                  context: context,
                  label: t.translate('status'),
                  value: filters.statusFilter,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(t.translate('all')),
                    ),
                    ...EquipmentStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text('${status.icon} ${status.label}'),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    ref
                        .read(equipmentFiltersProvider.notifier)
                        .setStatusFilter(value);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Calibração
              Expanded(
                child: _buildDropdown<CalibrationFilterType>(
                  context: context,
                  label: t.translate('calibration'),
                  value: filters.calibrationFilter,
                  items: [
                    DropdownMenuItem(
                        value: CalibrationFilterType.all,
                        child: Text(t.translate('all'))),
                    DropdownMenuItem(
                        value: CalibrationFilterType.expiring,
                        child: Text(t.translate('expiring'))),
                    DropdownMenuItem(
                        value: CalibrationFilterType.expired,
                        child: Text(t.translate('expired'))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(equipmentFiltersProvider.notifier)
                          .setCalibrationFilter(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.mediumGray,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          initialValue: value,
          dropdownColor: _glassInputColor(context),
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: _glassInputColor(context),
          ),
          isExpanded: true,
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // LISTA AGRUPADA
  // ════════════════════════════════════════════════════════════

  Widget _buildGroupedList(
    BuildContext context,
    WidgetRef ref,
    Map<EquipmentType, List<Equipment>> grouped,
    List<CalibrationAlert>? alerts,
    bool canEdit,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final type = grouped.keys.elementAt(index);
        final equipment = grouped[type]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _glassPanelColor(context),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.adaptiveOutline(context)),
                boxShadow: AppColors.glassShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      '${type.label} (${equipment.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cards do equipamento
                  ...equipment.map((eq) {
                    CalibrationAlert? alert;
                    if (alerts != null) {
                      for (final item in alerts) {
                        if (item.equipment.equipmentId == eq.equipmentId) {
                          alert = item;
                          break;
                        }
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: EquipmentCard(
                        equipment: eq,
                        alert: alert,
                        // Botão editar só aparece se tiver permissão
                        onEdit: canEdit
                            ? () => _showEditEquipmentDialog(context, eq)
                            : null,
                        onDelete: canEdit
                            ? () => _confirmAndDeleteEquipment(context, ref, eq)
                            : null,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ════════════════════════════════════════════════════════════

  Widget _buildEmptyState(
      BuildContext context, bool canAdd, TranslationHelper t) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _glassPanelColor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.adaptiveOutline(context)),
          boxShadow: AppColors.glassShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 100,
              color: AppColors.adaptiveMutedText(context),
            ),
            const SizedBox(height: 16),
            Text(
              t.translate('no_equipment_found'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.adaptiveSecondaryText(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (canAdd) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddEquipmentDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(t.translate('add_first_equipment'),
                    style: const TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // DIALOGS
  // ════════════════════════════════════════════════════════════

  void _showAddEquipmentDialog(BuildContext context) {
    showLiquidDialog(
      context: context,
      builder: (context) => const AddEquipmentDialog(),
    );
  }

  void _handleAddEquipmentTap(
    BuildContext context,
    String? projectId,
    PermissionNotifier permissions,
    TranslationHelper t,
  ) {
    if (permissions.isLoading) {
      return;
    }

    if (projectId == null || projectId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('select_project_first'))),
      );
      return;
    }

    if (!permissions.canManageEquipmentAndDocs) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('no_permission'))),
      );
      return;
    }

    _showAddEquipmentDialog(context);
  }

  void _showEditEquipmentDialog(BuildContext context, Equipment equipment) {
    showLiquidDialog(
      context: context,
      builder: (context) => AddEquipmentDialog(initialEquipment: equipment),
    );
  }

  Future<void> _confirmAndDeleteEquipment(
    BuildContext context,
    WidgetRef ref,
    Equipment equipment,
  ) async {
    final t = TranslationHelper.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.translate('delete_equipment')),
          content: Text(
            '${t.translate('delete_equipment_confirm')} "${equipment.model}" (${equipment.serialNumber})?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(t.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
              child: Text(t.translate('delete')),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final actions = ref.read(equipmentActionsProvider);
    final success = await actions.deleteEquipment(equipment.equipmentId);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '✅ ${t.translate('equipment_deleted_success')}'
            : '❌ ${t.translate('equipment_delete_failed')}'),
        backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
      ),
    );
  }
}
