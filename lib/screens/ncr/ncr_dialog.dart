import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ncr.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_providers.dart';
import '../../providers/ncr_provider.dart';
import '../../providers/permission_provider.dart';
import '../../utils/app_feedback.dart';

class NcrDialog extends ConsumerStatefulWidget {
  const NcrDialog({
    super.key,
    required this.projectId,
    this.ncr,
    this.lockedTurbinaId,
    this.lockedTurbinaName,
  });

  final String projectId;
  final NcrRecord? ncr;
  final String? lockedTurbinaId;
  final String? lockedTurbinaName;

  @override
  ConsumerState<NcrDialog> createState() => _NcrDialogState();
}

class _NcrDialogState extends ConsumerState<NcrDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _statusNoteController = TextEditingController();
  final _closureNoteController = TextEditingController();

  NcrCategory _category = NcrCategory.quality;
  NcrSeverity _severity = NcrSeverity.medium;
  NcrStatus _status = NcrStatus.open;
  late NcrStatus _initialStatus;
  DateTime? _dueDate;
  String? _selectedTurbinaId;
  String? _selectedTurbinaName;
  String? _selectedAssignedToUid;
  String? _selectedAssignedToName;
  final List<PlatformFile> _pickedFiles = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final ncr = widget.ncr;
    _titleController.text = ncr?.title ?? '';
    _descriptionController.text = ncr?.description ?? '';
    _tagsController.text = ncr?.tags.join(', ') ?? '';
    _category = ncr?.category ?? NcrCategory.quality;
    _severity = ncr?.severity ?? NcrSeverity.medium;
    _status = ncr?.status ?? NcrStatus.open;
    _initialStatus = _status;
    _dueDate = ncr?.dueDate;
    _selectedTurbinaId = widget.lockedTurbinaId ?? ncr?.turbinaId;
    _selectedTurbinaName = widget.lockedTurbinaName ?? ncr?.turbinaNome;
    _selectedAssignedToUid =
        ncr?.assignedToUid.isNotEmpty == true ? ncr?.assignedToUid : null;
    _selectedAssignedToName =
        ncr?.assignedTo.isNotEmpty == true ? ncr?.assignedTo : null;
    _closureNoteController.text = ncr?.closureNote ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _statusNoteController.dispose();
    _closureNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final turbinasAsync = ref.watch(
      projectTurbinasByProjectProvider(widget.projectId),
    );
    final membersAsync =
        ref.watch(projectMembersListProvider(widget.projectId));
    final currentUser = ref.watch(currentAppUserProvider).asData?.value;
    final panel = AppColors.adaptivePanelSurface(context);
    final cardSurface = AppColors.adaptiveCardSurface(context);
    final outline = AppColors.adaptiveOutline(context);
    final primaryText = AppColors.adaptivePrimaryText(context);
    final secondaryText = AppColors.adaptiveSecondaryText(context);
    final needsClosureInfo =
        _status == NcrStatus.resolved || _status == NcrStatus.closed;
    final statusChanged = widget.ncr != null && _status != _initialStatus;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 820),
        child: Container(
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: outline.withValues(alpha: 0.9)),
            boxShadow: AppColors.glassShadow,
            image: DecorationImage(
              image: const AssetImage('NCR.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                _dialogImageTint(context),
                _dialogImageBlendMode(context),
              ),
            ),
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
                          colors: [AppColors.warningOrange, AppColors.errorRed],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.rule_folder_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.ncr == null
                                ? t.translate('ncr_new')
                                : t.translate('edit'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.translate('ncr_management'),
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
                      prefixIconColor: secondaryText,
                      suffixIconColor: secondaryText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: outline),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: outline.withValues(alpha: 0.7),
                        ),
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
                        borderSide: const BorderSide(
                          color: AppColors.errorRed,
                        ),
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
                              flex: 3,
                              child: TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: '${t.translate('title')} *',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.title),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return t.translate('required_field');
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: turbinasAsync.when(
                                data: (turbinas) {
                                  final locked = widget.lockedTurbinaId != null;
                                  if (locked) {
                                    return TextFormField(
                                      initialValue: widget.lockedTurbinaName,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        labelText:
                                            '${t.translate('ncr_linked_turbine')} *',
                                        border: const OutlineInputBorder(),
                                        prefixIcon: const Icon(
                                            Icons.wind_power_outlined),
                                      ),
                                    );
                                  }

                                  return DropdownButtonFormField<String>(
                                    initialValue: _selectedTurbinaId,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText:
                                          '${t.translate('ncr_linked_turbine')} *',
                                      border: const OutlineInputBorder(),
                                      prefixIcon:
                                          const Icon(Icons.wind_power_outlined),
                                    ),
                                    items: turbinas
                                        .map(
                                          (turbina) => DropdownMenuItem(
                                            value: turbina.id,
                                            child: _buildDropdownLabel(
                                              turbina.nome,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      dynamic selected;
                                      for (final turbina in turbinas) {
                                        if (turbina.id == value) {
                                          selected = turbina;
                                          break;
                                        }
                                      }
                                      setState(() {
                                        _selectedTurbinaId = value;
                                        _selectedTurbinaName = selected?.nome;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return t.translate('required_field');
                                      }
                                      return null;
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(18),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (error, _) => Text(
                                  '${t.translate('error')}: $error',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<NcrCategory>(
                                initialValue: _category,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: t.translate('ncr_category'),
                                  border: const OutlineInputBorder(),
                                  prefixIcon:
                                      const Icon(Icons.category_outlined),
                                ),
                                items: NcrCategory.values
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: _buildDropdownLabel(
                                          t.translate(
                                            'ncr_category_${value.value}',
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _category = value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: DropdownButtonFormField<NcrSeverity>(
                                initialValue: _severity,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: t.translate('ncr_severity'),
                                  border: const OutlineInputBorder(),
                                  prefixIcon:
                                      const Icon(Icons.priority_high_outlined),
                                ),
                                items: NcrSeverity.values
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: _buildDropdownLabel(
                                          t.translate(
                                            'ncr_severity_${value.value}',
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _severity = value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: DropdownButtonFormField<NcrStatus>(
                                initialValue: _status,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: t.translate('status'),
                                  border: const OutlineInputBorder(),
                                  prefixIcon:
                                      const Icon(Icons.track_changes_outlined),
                                ),
                                items: NcrStatus.values
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: _buildDropdownLabel(
                                          t.translate(
                                            'ncr_status_${value.value}',
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _status = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _pickDueDate,
                                borderRadius: BorderRadius.circular(12),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText:
                                        '${t.translate('ncr_due_date')} *',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(
                                        Icons.calendar_today_outlined),
                                    errorText: _dueDate == null
                                        ? t.translate('required_field')
                                        : null,
                                  ),
                                  child: Text(
                                    _dueDate == null
                                        ? '--/--/----'
                                        : _formatDate(_dueDate!),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: membersAsync.when(
                                data: (members) {
                                  final options = <_AssignableOption>[];
                                  final seenIds = <String>{};

                                  if (currentUser != null) {
                                    options.add(
                                      _AssignableOption(
                                        uid: currentUser.uid,
                                        label: currentUser.name,
                                        subtitle: currentUser.email,
                                      ),
                                    );
                                    seenIds.add(currentUser.uid);
                                  }

                                  for (final member in members) {
                                    if (seenIds.add(member.uid)) {
                                      options.add(
                                        _AssignableOption(
                                          uid: member.uid,
                                          label: member.name,
                                          subtitle: member.email,
                                        ),
                                      );
                                    }
                                  }

                                  if (_selectedAssignedToUid != null &&
                                      _selectedAssignedToName != null &&
                                      !options.any(
                                        (item) =>
                                            item.uid == _selectedAssignedToUid,
                                      )) {
                                    options.add(
                                      _AssignableOption(
                                        uid: _selectedAssignedToUid!,
                                        label: _selectedAssignedToName!,
                                      ),
                                    );
                                  }

                                  return DropdownButtonFormField<String>(
                                    initialValue: _selectedAssignedToUid,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: t.translate('ncr_assigned_to'),
                                      border: const OutlineInputBorder(),
                                      prefixIcon: const Icon(
                                        Icons.person_outline_rounded,
                                      ),
                                    ),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: '',
                                        child: _buildDropdownLabel(
                                          t.translate('ncr_unassigned'),
                                        ),
                                      ),
                                      ...options.map(
                                        (option) => DropdownMenuItem<String>(
                                          value: option.uid,
                                          child: _buildDropdownLabel(
                                            option.displayLabel,
                                          ),
                                        ),
                                      ),
                                    ],
                                    selectedItemBuilder: (context) => [
                                      _buildDropdownLabel(
                                        t.translate('ncr_unassigned'),
                                      ),
                                      ...options.map(
                                        (option) => _buildDropdownLabel(
                                          option.displayLabel,
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null || value.isEmpty) {
                                        setState(() {
                                          _selectedAssignedToUid = null;
                                          _selectedAssignedToName = null;
                                        });
                                        return;
                                      }

                                      final selected = options.firstWhere(
                                        (item) => item.uid == value,
                                      );
                                      setState(() {
                                        _selectedAssignedToUid = selected.uid;
                                        _selectedAssignedToName =
                                            selected.label;
                                      });
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(18),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (_, __) => TextFormField(
                                  initialValue: _selectedAssignedToName ?? '',
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: t.translate('ncr_assigned_to'),
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(
                                      Icons.person_outline_rounded,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: '${t.translate('ncr_description')} *',
                            alignLabelWithHint: true,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 72),
                              child: Icon(Icons.subject_outlined),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return t.translate('required_field');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (statusChanged || widget.ncr == null)
                          TextFormField(
                            controller: _statusNoteController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: widget.ncr == null
                                  ? t.translate('ncr_initial_note')
                                  : t.translate('ncr_status_change_note'),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 18),
                                child: Icon(Icons.history_toggle_off_outlined),
                              ),
                            ),
                          ),
                        if (statusChanged || widget.ncr == null)
                          const SizedBox(height: 12),
                        if (needsClosureInfo)
                          TextFormField(
                            controller: _closureNoteController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: '${t.translate('ncr_closure_note')} *',
                              border: const OutlineInputBorder(),
                              alignLabelWithHint: true,
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 34),
                                child: Icon(Icons.fact_check_outlined),
                              ),
                            ),
                            validator: (value) {
                              if (!needsClosureInfo) return null;
                              if (value == null || value.trim().isEmpty) {
                                return t.translate('required_field');
                              }
                              return null;
                            },
                          ),
                        if (needsClosureInfo) const SizedBox(height: 12),
                        TextFormField(
                          controller: _tagsController,
                          decoration: InputDecoration(
                            labelText: t.translate('tags_comma_separated'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.sell_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildEvidenceSection(t),
                        if (widget.ncr != null) ...[
                          const SizedBox(height: 16),
                          _buildHistorySection(t),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: outline.withValues(alpha: 0.85)),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      child: Text(t.translate('cancel')),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        widget.ncr == null
                            ? t.translate('create')
                            : t.translate('save'),
                      ),
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

  Widget _buildEvidenceSection(TranslationHelper t) {
    final existing = widget.ncr?.evidence ?? const <NcrEvidence>[];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardSurface(context).withValues(
          alpha: AppColors.isDarkContext(context) ? 0.84 : 0.78,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
        boxShadow: AppColors.glassShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_file, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                t.translate('ncr_evidence'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(t.translate('ncr_add_evidence')),
              ),
            ],
          ),
          if (existing.isEmpty && _pickedFiles.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                t.translate('ncr_no_evidence'),
                style: TextStyle(
                  color: AppColors.adaptiveSecondaryText(context),
                ),
              ),
            ),
          if (existing.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: existing
                  .map(
                    (item) => Chip(
                      backgroundColor: AppColors.adaptivePanelSurface(context),
                      side: BorderSide(
                        color: AppColors.adaptiveOutline(context),
                      ),
                      avatar: const Icon(Icons.description_outlined, size: 16),
                      label: Text(item.name),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (_pickedFiles.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _pickedFiles
                  .map(
                    (item) => InputChip(
                      backgroundColor: AppColors.adaptivePanelSurface(context),
                      side: BorderSide(
                        color: AppColors.adaptiveOutline(context),
                      ),
                      avatar: const Icon(Icons.file_present_outlined, size: 16),
                      label: Text(item.name),
                      onDeleted: () {
                        setState(() => _pickedFiles.remove(item));
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistorySection(TranslationHelper t) {
    final history = [...?widget.ncr?.statusHistory]
      ..sort((a, b) => b.changedAt.compareTo(a.changedAt));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardSurface(context).withValues(
          alpha: AppColors.isDarkContext(context) ? 0.84 : 0.78,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
        boxShadow: AppColors.glassShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: AppColors.infoBlue),
              const SizedBox(width: 8),
              Text(
                t.translate('ncr_status_history'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (history.isEmpty)
            Text(
              t.translate('ncr_no_history'),
              style: TextStyle(
                color: AppColors.adaptiveSecondaryText(context),
              ),
            )
          else
            Column(
              children: history
                  .map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            AppColors.adaptivePanelSurface(context).withValues(
                          alpha: AppColors.isDarkContext(context) ? 0.88 : 0.82,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.adaptiveOutline(context),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${t.translate('ncr_status_${item.fromStatus.value}')} → ${t.translate('ncr_status_${item.toStatus.value}')}',
                                  style: TextStyle(
                                    color:
                                        AppColors.adaptivePrimaryText(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                _formatDateTime(item.changedAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.adaptiveSecondaryText(
                                    context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.changedByName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.infoBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (item.note.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              t.translateValueOrKey(item.note),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.adaptiveSecondaryText(
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'png',
        'jpg',
        'jpeg',
        'doc',
        'docx',
        'xls',
        'xlsx'
      ],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _pickedFiles.addAll(result.files.where((file) => file.name.isNotEmpty));
      });
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    final t = TranslationHelper.of(context);
    if (!_formKey.currentState!.validate() || _dueDate == null) {
      setState(() {});
      return;
    }

    final turbinaId = _selectedTurbinaId ?? widget.lockedTurbinaId;
    final turbinaName = _selectedTurbinaName ?? widget.lockedTurbinaName;
    if (turbinaId == null || turbinaId.isEmpty || turbinaName == null) {
      return;
    }

    final statusChanged = widget.ncr != null && _status != _initialStatus;
    final needsClosureInfo =
        _status == NcrStatus.resolved || _status == NcrStatus.closed;
    if (statusChanged && _statusNoteController.text.trim().isEmpty) {
      showAppFeedback(
        t.translate('ncr_status_note_required'),
        type: AppFeedbackType.warning,
      );
      return;
    }
    if (needsClosureInfo && _closureNoteController.text.trim().isEmpty) {
      showAppFeedback(
        t.translate('ncr_closure_note_required'),
        type: AppFeedbackType.warning,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = ref.read(ncrServiceProvider);
      final userId = ref.read(currentUserIdProvider) ?? '';
      final appUser = ref.read(currentAppUserProvider).asData?.value;
      final ncrId = widget.ncr?.ncrId ?? service.newNcrId();
      final code =
          widget.ncr?.code ?? await service.generateNcrCode(widget.projectId);
      final changedByName = appUser?.name.isNotEmpty == true
          ? appUser!.name
          : appUser?.email ?? '';

      final uploadedEvidence = <NcrEvidence>[...?widget.ncr?.evidence];
      for (final file in _pickedFiles) {
        final evidence = await service.uploadEvidence(
          projectId: widget.projectId,
          ncrId: ncrId,
          file: file,
          userId: userId,
        );
        uploadedEvidence.add(evidence);
      }

      final now = DateTime.now();
      final status = _status;
      final existingHistory = [...?widget.ncr?.statusHistory];
      if (widget.ncr == null) {
        existingHistory.add(
          NcrStatusChange(
            id: 'created-$ncrId',
            fromStatus: status,
            toStatus: status,
            note: _statusNoteController.text.trim().isEmpty
                ? t.translate('ncr_created_history_note')
                : _statusNoteController.text.trim(),
            changedBy: userId,
            changedByName: changedByName,
            changedAt: now,
          ),
        );
      } else if (statusChanged) {
        existingHistory.add(
          NcrStatusChange(
            id: 'status-${now.millisecondsSinceEpoch}',
            fromStatus: _initialStatus,
            toStatus: status,
            note: _statusNoteController.text.trim(),
            changedBy: userId,
            changedByName: changedByName,
            changedAt: now,
          ),
        );
      }

      final shouldClose =
          status == NcrStatus.closed || status == NcrStatus.resolved;
      final updatedNcr = NcrRecord(
        ncrId: ncrId,
        code: code,
        projectId: widget.projectId,
        turbinaId: turbinaId,
        turbinaNome: turbinaName,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        severity: _severity,
        status: status,
        dueDate: _dueDate!,
        assignedToUid: _selectedAssignedToUid ?? '',
        assignedTo: _selectedAssignedToName ?? '',
        tags: _tagsController.text
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(),
        evidence: uploadedEvidence,
        statusHistory: existingHistory,
        closureNote: shouldClose ? _closureNoteController.text.trim() : '',
        createdBy: widget.ncr?.createdBy ?? userId,
        createdByName: widget.ncr?.createdByName ?? changedByName,
        createdAt: widget.ncr?.createdAt ?? now,
        updatedAt: now,
        closedAt: shouldClose ? (widget.ncr?.closedAt ?? now) : null,
        closedBy: shouldClose ? userId : '',
        closedByName: shouldClose ? changedByName : '',
      );

      if (widget.ncr == null) {
        await service.createNcr(updatedNcr);
      } else {
        await service.updateNcr(updatedNcr);
      }

      if (mounted) {
        final successMessage = widget.ncr == null
            ? t.translate('ncr_created_success')
            : t.translate('ncr_updated_success');
        Navigator.pop(context);
        showAppFeedback(
          successMessage,
          type: AppFeedbackType.success,
        );
      }
    } catch (error) {
      if (mounted) {
        showAppFeedback(
          '${t.translate('error')}: $error',
          type: AppFeedbackType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _dialogImageTint(BuildContext context) {
    if (AppColors.isDarkContext(context)) {
      return const Color(0xFF081521).withValues(alpha: 0.78);
    }
    return AppColors.adaptivePanelSurface(context).withValues(alpha: 0.9);
  }

  BlendMode _dialogImageBlendMode(BuildContext context) {
    return AppColors.isDarkContext(context)
        ? BlendMode.darken
        : BlendMode.lighten;
  }

  Widget _buildDropdownLabel(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }
}

class _AssignableOption {
  const _AssignableOption({
    required this.uid,
    required this.label,
    this.subtitle = '',
  });

  final String uid;
  final String label;
  final String subtitle;

  String get displayLabel =>
      subtitle.trim().isEmpty ? label : '$label • $subtitle';
}
