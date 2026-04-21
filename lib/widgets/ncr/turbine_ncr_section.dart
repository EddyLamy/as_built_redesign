import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ncr.dart';
import '../../providers/ncr_provider.dart';
import '../../providers/permission_provider.dart';
import '../../screens/ncr/ncr_dialog.dart';
import '../../utils/app_feedback.dart';
import 'ncr_card.dart';

class TurbineNcrSection extends ConsumerStatefulWidget {
  const TurbineNcrSection({
    super.key,
    required this.projectId,
    required this.turbinaId,
    required this.turbinaNome,
  });

  final String projectId;
  final String turbinaId;
  final String turbinaNome;

  @override
  ConsumerState<TurbineNcrSection> createState() => _TurbineNcrSectionState();
}

class _TurbineNcrSectionState extends ConsumerState<TurbineNcrSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final ncrsAsync = ref.watch(turbineNcrsProvider(widget.turbinaId));
    final permissions = ref.watch(permissionProvider(widget.projectId));
    final panel = AppColors.adaptivePanelSurface(context);
    final outline = AppColors.adaptiveOutline(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final cardSurface = AppColors.adaptiveCardSurface(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outline),
        boxShadow: AppColors.glassShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ncrsAsync.when(
            data: (ncrs) {
              final openCount = ncrs.where((item) => !item.isClosed).length;
              final criticalCount = ncrs
                  .where((item) => item.severity == NcrSeverity.critical)
                  .length;
              final overdueCount = ncrs.where((item) => item.isOverdue).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.warningOrange,
                                        AppColors.errorRed
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.rule_folder_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      t.translate('ncrs'),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      widget.turbinaNome,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _StatChip(
                                            label: t.translate('ncr_total'),
                                            value: ncrs.length,
                                            color: AppColors.primaryBlue,
                                          ),
                                          const SizedBox(width: 10),
                                          _StatChip(
                                            label:
                                                t.translate('ncr_open_count'),
                                            value: openCount,
                                            color: AppColors.infoBlue,
                                          ),
                                          const SizedBox(width: 10),
                                          _StatChip(
                                            label: t.translate(
                                                'ncr_critical_count'),
                                            value: criticalCount,
                                            color: AppColors.errorRed,
                                          ),
                                          const SizedBox(width: 10),
                                          _StatChip(
                                            label: t
                                                .translate('ncr_overdue_count'),
                                            value: overdueCount,
                                            color: AppColors.warningOrange,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (permissions.canManageEquipmentAndDocs)
                                ElevatedButton.icon(
                                  onPressed: () => _openDialog(context),
                                  icon: const Icon(Icons.add),
                                  label: Text(t.translate('add')),
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                _isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: secondaryText,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isExpanded) const SizedBox(height: 14),
                  if (_isExpanded && ncrs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: cardSurface.withValues(
                          alpha: AppColors.isDarkContext(context) ? 0.84 : 0.8,
                        ),
                        border: Border.all(color: outline),
                        boxShadow: AppColors.glassShadow,
                      ),
                      child: Text(
                        t.translate('ncr_empty_turbine'),
                        style: TextStyle(color: secondaryText),
                      ),
                    )
                  else if (_isExpanded)
                    Column(
                      children: ncrs
                          .map(
                            (ncr) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: NcrCard(
                                ncr: ncr,
                                compact: true,
                                onTap: permissions.canManageEquipmentAndDocs
                                    ? () => _openDialog(context, ncr: ncr)
                                    : () {},
                                onDelete: permissions.canManageEquipmentAndDocs
                                    ? () => _confirmDelete(context, ref, ncr, t)
                                    : null,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('${t.translate('error')}: $error'),
          ),
        ],
      ),
    );
  }

  void _openDialog(BuildContext context, {NcrRecord? ncr}) {
    showLiquidDialog(
      context: context,
      builder: (_) => NcrDialog(
        projectId: widget.projectId,
        ncr: ncr,
        lockedTurbinaId: widget.turbinaId,
        lockedTurbinaName: widget.turbinaNome,
      ),
    );
  }

  Future<void> _confirmDelete(
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
      if (context.mounted) {
        showAppFeedback(
          t.translate('ncr_deleted_success'),
          type: AppFeedbackType.success,
        );
      }
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
