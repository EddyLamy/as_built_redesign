import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/safety_alert.dart';
import '../../providers/auth_providers.dart';
import '../../providers/permission_provider.dart';
import '../../providers/safety_alert_provider.dart';
import '../../utils/app_feedback.dart';

class SafetyAlertDialog extends ConsumerStatefulWidget {
  const SafetyAlertDialog({
    super.key,
    required this.projectId,
    this.alert,
  });

  final String projectId;
  final SafetyAlertRecord? alert;

  @override
  ConsumerState<SafetyAlertDialog> createState() => _SafetyAlertDialogState();
}

class _SafetyAlertDialogState extends ConsumerState<SafetyAlertDialog> {
  static const int _maxPhotos = 3;

  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _problemController = TextEditingController();
  final _solutionController = TextEditingController();
  final _resolucaoEfetuadaController = TextEditingController();
  final List<PlatformFile> _pickedProblemPhotos = [];
  final List<PlatformFile> _pickedResolutionPhotos = [];
  final List<SafetyAlertEvidence> _existingProblemPhotos = [];
  final List<SafetyAlertEvidence> _existingResolutionPhotos = [];
  final List<SafetyAlertEvidence> _removedProblemPhotos = [];
  final List<SafetyAlertEvidence> _removedResolutionPhotos = [];

  SafetyAlertCategory _category = SafetyAlertCategory.nearMiss;
  SafetyAlertStatus _status = SafetyAlertStatus.underStudy;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final alert = widget.alert;
    _destinationController.text = alert?.destinationTo ?? '';
    _departmentController.text = alert?.department ?? '';
    _problemController.text = alert?.problemDescription ?? '';
    _solutionController.text = alert?.proposedSolution ?? '';
    _resolucaoEfetuadaController.text = alert?.resolucaoEfetuada ?? '';
    _existingProblemPhotos
        .addAll(alert?.evidence ?? const <SafetyAlertEvidence>[]);
    _existingResolutionPhotos
        .addAll(alert?.resolutionEvidence ?? const <SafetyAlertEvidence>[]);
    _category = alert?.category ?? SafetyAlertCategory.nearMiss;
    _status = alert?.status ?? SafetyAlertStatus.underStudy;
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _departmentController.dispose();
    _problemController.dispose();
    _solutionController.dispose();
    _resolucaoEfetuadaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final panel = AppColors.adaptivePanelSurface(context);
    final cardSurface = AppColors.adaptiveCardSurface(context);
    final outline = AppColors.adaptiveOutline(context);
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 860),
        child: Container(
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: outline.withValues(alpha: 0.9)),
            boxShadow: AppColors.glassShadow,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 16, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.warningOrange,
                            AppColors.errorRed,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.health_and_safety_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.alert == null
                                ? t.translate('safety_alert_new')
                                : t.translate('edit'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.translate('safety_alert_management'),
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: outline.withValues(alpha: 0.85)),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: InputDecorationTheme(
                      isDense: true,
                      filled: true,
                      fillColor: cardSurface.withValues(
                        alpha: AppColors.isDarkContext(context) ? 0.82 : 0.92,
                      ),
                      labelStyle: TextStyle(color: secondaryText),
                      hintStyle: TextStyle(
                        color: AppColors.adaptiveMutedText(context),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.4,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.errorRed),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.errorRed,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _destinationController,
                                decoration: InputDecoration(
                                  labelText: t
                                      .translate('safety_alert_destination_to'),
                                  prefixIcon:
                                      const Icon(Icons.person_search_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _departmentController,
                                decoration: InputDecoration(
                                  labelText:
                                      t.translate('safety_alert_department'),
                                  prefixIcon:
                                      const Icon(Icons.apartment_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 620;

                            final categoryField =
                                DropdownButtonFormField<SafetyAlertCategory>(
                              initialValue: _category,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText:
                                    '${t.translate('safety_alert_category')} *',
                                prefixIcon: const Icon(Icons.category_outlined),
                              ),
                              items: SafetyAlertCategory.values
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        t.translate(
                                          'safety_alert_category_${item.value}',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _category = value);
                                }
                              },
                            );

                            final statusField =
                                DropdownButtonFormField<SafetyAlertStatus>(
                              initialValue: _status,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText:
                                    '${t.translate('safety_alert_status')} *',
                                prefixIcon: const Icon(Icons.flag_outlined),
                              ),
                              items: SafetyAlertStatus.values
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        t.translate(
                                          'safety_alert_status_${item.value}',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _status = value);
                                }
                              },
                            );

                            if (isNarrow) {
                              return Column(
                                children: [
                                  categoryField,
                                  const SizedBox(height: 12),
                                  statusField,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: categoryField),
                                const SizedBox(width: 12),
                                Expanded(child: statusField),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _problemController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText:
                                '${t.translate('safety_alert_problem_description')} *',
                            alignLabelWithHint: true,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 72),
                              child: Icon(Icons.report_problem_outlined),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return t.translate('required_field');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _solutionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText:
                                t.translate('safety_alert_possible_solution'),
                            alignLabelWithHint: true,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 54),
                              child: Icon(Icons.lightbulb_outline),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _resolucaoEfetuadaController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText:
                                t.translate('safety_alert_resolucao_efetuada'),
                            alignLabelWithHint: true,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 54),
                              child: Icon(Icons.fact_check_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildPhotosSection(
                          context,
                          t,
                          outline,
                          secondaryText,
                          titleKey: 'safety_alert_photos',
                          hintKey: 'safety_alert_photos_hint',
                          icon: Icons.photo_library_outlined,
                          currentPhotos: _existingProblemPhotos,
                          pickedPhotos: _pickedProblemPhotos,
                          onAdd: () => _pickPhotos(isResolutionPhotos: false),
                          onRemoveExisting: _removeExistingProblemPhoto,
                          onRemovePicked: _removePickedProblemPhoto,
                        ),
                        const SizedBox(height: 14),
                        _buildPhotosSection(
                          context,
                          t,
                          outline,
                          secondaryText,
                          titleKey: 'safety_alert_resolution_photos',
                          hintKey: 'safety_alert_resolution_photos_hint',
                          icon: Icons.task_alt_outlined,
                          currentPhotos: _existingResolutionPhotos,
                          pickedPhotos: _pickedResolutionPhotos,
                          onAdd: () => _pickPhotos(isResolutionPhotos: true),
                          onRemoveExisting: _removeExistingResolutionPhoto,
                          onRemovePicked: _removePickedResolutionPhoto,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: outline.withValues(alpha: 0.85)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: Row(
                  children: [
                    TextButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      child: Text(t.translate('cancel')),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(t.translate('save')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosSection(
    BuildContext context,
    TranslationHelper t,
    Color outline,
    Color secondaryText, {
    required String titleKey,
    required String hintKey,
    required IconData icon,
    required List<SafetyAlertEvidence> currentPhotos,
    required List<PlatformFile> pickedPhotos,
    required VoidCallback onAdd,
    required ValueChanged<SafetyAlertEvidence> onRemoveExisting,
    required ValueChanged<int> onRemovePicked,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardSurface(context).withValues(
          alpha: AppColors.isDarkContext(context) ? 0.78 : 0.92,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.infoBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.translate(titleKey),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.adaptivePrimaryText(context),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _canAddMorePhotos(
                  currentPhotos.length,
                  pickedPhotos.length,
                )
                    ? onAdd
                    : null,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(t.translate('safety_alert_add_photos')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t.translate(hintKey),
            style: TextStyle(fontSize: 12, color: secondaryText),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...currentPhotos.map(
                (item) => _PhotoChip(
                  label: item.name,
                  icon: Icons.cloud_done,
                  onRemove: () => onRemoveExisting(item),
                  removeTooltip: t.translate('remove'),
                ),
              ),
              ...pickedPhotos.asMap().entries.map(
                    (entry) => _PhotoChip(
                      label: entry.value.name,
                      icon: Icons.photo,
                      onRemove: () => onRemovePicked(entry.key),
                      removeTooltip: t.translate('remove'),
                    ),
                  ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: outline.withValues(alpha: 0.8)),
                ),
                child: Text(
                  '${currentPhotos.length + pickedPhotos.length} / $_maxPhotos',
                  style: TextStyle(color: secondaryText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canAddMorePhotos(int existingCount, int pendingCount) {
    return existingCount + pendingCount < _maxPhotos;
  }

  Future<void> _pickPhotos({required bool isResolutionPhotos}) async {
    final existingCount = isResolutionPhotos
        ? _existingResolutionPhotos.length
        : _existingProblemPhotos.length;
    final pendingCount = isResolutionPhotos
        ? _pickedResolutionPhotos.length
        : _pickedProblemPhotos.length;
    final remaining = _maxPhotos - existingCount - pendingCount;
    if (remaining <= 0) {
      showAppFeedback(
        TranslationHelper.of(context)
            .translate('safety_alert_max_photos_reached'),
        type: AppFeedbackType.warning,
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
      withData: true,
    );

    if (result == null) {
      return;
    }

    setState(() {
      final targetList =
          isResolutionPhotos ? _pickedResolutionPhotos : _pickedProblemPhotos;
      targetList.addAll(
        result.files.where((file) => file.name.isNotEmpty).take(remaining),
      );
    });
  }

  void _removeExistingProblemPhoto(SafetyAlertEvidence item) {
    setState(() {
      _existingProblemPhotos.removeWhere((photo) => photo.id == item.id);
      _removedProblemPhotos.add(item);
    });
  }

  void _removeExistingResolutionPhoto(SafetyAlertEvidence item) {
    setState(() {
      _existingResolutionPhotos.removeWhere((photo) => photo.id == item.id);
      _removedResolutionPhotos.add(item);
    });
  }

  void _removePickedProblemPhoto(int index) {
    setState(() => _pickedProblemPhotos.removeAt(index));
  }

  void _removePickedResolutionPhoto(int index) {
    setState(() => _pickedResolutionPhotos.removeAt(index));
  }

  Future<void> _save() async {
    final t = TranslationHelper.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = ref.read(safetyAlertServiceProvider);
      final userId = ref.read(currentUserIdProvider) ?? '';
      final appUser = ref.read(currentAppUserProvider).asData?.value;
      final alertId = widget.alert?.alertId ?? service.newAlertId();
      final code =
          widget.alert?.code ?? await service.generateAlertCode(_category);
      final creatorName = appUser?.name.isNotEmpty == true
          ? appUser!.name
          : appUser?.email ?? '';

      final uploadedEvidence = <SafetyAlertEvidence>[..._existingProblemPhotos];
      final uploadedResolutionEvidence = <SafetyAlertEvidence>[
        ..._existingResolutionPhotos,
      ];

      for (final file in _pickedProblemPhotos) {
        uploadedEvidence.add(
          await service.uploadEvidence(
            projectId: widget.projectId,
            alertId: alertId,
            file: file,
            userId: userId,
          ),
        );
      }

      for (final file in _pickedResolutionPhotos) {
        uploadedResolutionEvidence.add(
          await service.uploadEvidence(
            projectId: widget.projectId,
            alertId: alertId,
            file: file,
            userId: userId,
          ),
        );
      }

      final alert = SafetyAlertRecord(
        alertId: alertId,
        code: code,
        projectId: widget.projectId,
        category: _category,
        destinationTo: _destinationController.text.trim(),
        department: _departmentController.text.trim(),
        problemDescription: _problemController.text.trim(),
        proposedSolution: _solutionController.text.trim(),
        resolucaoEfetuada: _resolucaoEfetuadaController.text.trim(),
        status: _status,
        evidence: uploadedEvidence,
        resolutionEvidence: uploadedResolutionEvidence,
        createdBy: widget.alert?.createdBy ?? userId,
        createdByName: widget.alert?.createdByName ?? creatorName,
        createdAt: widget.alert?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.alert == null) {
        await service.createAlert(alert);
      } else {
        await service.updateAlert(alert);
      }

      for (final evidence in [
        ..._removedProblemPhotos,
        ..._removedResolutionPhotos,
      ]) {
        await service.deleteEvidenceFile(evidence);
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      showAppFeedback(
        t.translate(
          widget.alert == null
              ? 'safety_alert_created_success'
              : 'safety_alert_updated_success',
        ),
        type: AppFeedbackType.success,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAppFeedback('$error', type: AppFeedbackType.error);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _PhotoChip extends StatelessWidget {
  const _PhotoChip({
    required this.label,
    required this.icon,
    this.onRemove,
    this.removeTooltip,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onRemove;
  final String? removeTooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.infoBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.adaptivePrimaryText(context),
              ),
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(999),
              child: Tooltip(
                message: removeTooltip,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.errorRed,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
