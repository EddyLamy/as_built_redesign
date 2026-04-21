import 'dart:async';

import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/daily_journal_options.dart';
import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project.dart';
import '../../services/daily_journal_service.dart';
import '../../services/team_service.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../widgets/background_watermark.dart';

class DailyJournalShellController extends ChangeNotifier {
  Future<void> Function()? _saveHandler;
  bool _isSaving = false;

  bool get isSaving => _isSaving;

  void bind(Future<void> Function() saveHandler) {
    _saveHandler = saveHandler;
  }

  void updateSaving(bool value) {
    if (_isSaving == value) {
      return;
    }
    _isSaving = value;
    notifyListeners();
  }

  Future<void> save() async {
    final saveHandler = _saveHandler;
    if (saveHandler == null || _isSaving) {
      return;
    }
    await saveHandler();
  }
}

class DailyJournalScreen extends ConsumerStatefulWidget {
  final Project project;
  final bool embeddedInDesktopShell;
  final DailyJournalShellController? shellController;

  const DailyJournalScreen({
    super.key,
    required this.project,
    this.embeddedInDesktopShell = false,
    this.shellController,
  });

  @override
  ConsumerState<DailyJournalScreen> createState() => _DailyJournalScreenState();
}

class _DailyJournalScreenState extends ConsumerState<DailyJournalScreen> {
  static const List<String> _windMeasurementSlots = [
    '8:00',
    '10:00',
    '12:00',
    '14:00',
    '16:00',
    '18:00',
  ];

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _legacyWindPhotosCleanupDone = false;
  bool _showSavedJournals = false;
  String? _expandedSavedJournalDateKey;
  int? _editingSavedEntryIndex;
  Timer? _headerPersistTimer;
  int _reportNo = 1;
  String _filledByName = '';
  final TextEditingController _initialsController = TextEditingController();
  final TextEditingController _installationTeamCountController =
      TextEditingController();
  final TextEditingController _craneCrewCountController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _formSectionKey = GlobalKey();
  final TextEditingController _remarksController = TextEditingController();
  final List<_ProgressEntry> _savedEntries = [];
  final List<_ProgressEntry> _entries = [_ProgressEntry()];
  final List<_PeopleHoursEntry> _peopleHoursEntries = [_PeopleHoursEntry()];
  final List<_WaitingTimeEntry> _waitingTimeEntries = [_WaitingTimeEntry()];
  final List<_WindMeasurementEntry> _windMeasurements = _windMeasurementSlots
      .map((timeLabel) => _WindMeasurementEntry(timeLabel: timeLabel))
      .toList();

  Color _glassPanelColor(BuildContext context) {
    final base = AppColors.adaptivePanelSurface(context);
    return base.withValues(
      alpha: AppColors.isDarkContext(context) ? 0.72 : 0.88,
    );
  }

  Color _glassCardColor(BuildContext context) {
    final base = AppColors.adaptiveCardSurface(context);
    return base.withValues(
      alpha: AppColors.isDarkContext(context) ? 0.66 : 0.84,
    );
  }

  String get _localeCode => Localizations.localeOf(context).languageCode;

  String _locationLabel(String value) =>
      dailyJournalLocationLabelLocalized(value, _localeCode);

  String _categoryLabel(String value) =>
      dailyJournalCategoryLabelLocalized(value, _localeCode);

  String _subCategoryLabel(String value) =>
      dailyJournalSubcategoryLabelLocalized(value, _localeCode);

  String get _currentInitials => _initialsController.text.trim();

  @override
  void initState() {
    super.initState();
    widget.shellController?.bind(_save);
    _loadJournalForDate();
  }

  @override
  void dispose() {
    _headerPersistTimer?.cancel();
    _initialsController.dispose();
    _installationTeamCountController.dispose();
    _craneCrewCountController.dispose();
    _scrollController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<({int installationTeamCount, int craneCrewCount})>
      _loadTeamCountsSnapshot() async {
    final teamService = TeamService();
    final installationTeamCount = await teamService.countPeopleInCategory(
      widget.project.id,
      'turbine_assembly',
    );
    final craneCrewCount = await teamService.countPeopleInCategory(
      widget.project.id,
      'cranes',
    );

    return (
      installationTeamCount: installationTeamCount,
      craneCrewCount: craneCrewCount,
    );
  }

  List<_WindMeasurementEntry> _defaultWindMeasurements() {
    return _windMeasurementSlots
        .map((timeLabel) => _WindMeasurementEntry(timeLabel: timeLabel))
        .toList(growable: false);
  }

  List<_WindMeasurementEntry> _resolveWindMeasurements(dynamic value) {
    final base = _defaultWindMeasurements();
    final rows = value as List<dynamic>? ?? const [];

    for (final row in rows) {
      if (row is! Map) {
        continue;
      }

      final mapped = row.map(
        (key, rowValue) => MapEntry(key.toString(), rowValue),
      );
      final timeLabel = (mapped['timeLabel'] as String?)?.trim() ?? '';
      final match =
          base.where((entry) => entry.timeLabel == timeLabel).firstOrNull;
      if (match != null) continue;
    }

    return base;
  }

  Future<void> _scrollToFormSection() async {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final targetContext = _formSectionKey.currentContext;
      if (targetContext == null) return;

      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    });
  }

  Future<void> _loadJournalForDate() async {
    try {
      final dailyJournalService = ref.read(dailyJournalServiceProvider);

      if (!_legacyWindPhotosCleanupDone) {
        await dailyJournalService.cleanupLegacyWindMeasurementPhotos(
          widget.project.id,
        );
        _legacyWindPhotosCleanupDone = true;
      }

      final firebaseUser = FirebaseAuth.instance.currentUser;
      String createdBy = firebaseUser?.displayName?.trim() ?? '';

      if (firebaseUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        final userData = userDoc.data();
        final firestoreName = (userData?['name'] as String?)?.trim() ?? '';
        if (firestoreName.isNotEmpty) {
          createdBy = firestoreName;
        }
      }

      if (createdBy.isEmpty) {
        createdBy = (firebaseUser?.email ?? 'user').split('@').first;
      }

      final existingJournal = await dailyJournalService.getJournalByDate(
        widget.project.id,
        _selectedDate,
      );

      final previewReportNo = existingJournal == null
          ? await dailyJournalService.peekNextReportNumber(widget.project.id)
          : (existingJournal['reportNo'] as num?)?.toInt() ?? 1;

      final existingRows =
          (existingJournal?['siteWorkProgress'] as List<dynamic>? ?? const [])
              .map((row) => _ProgressEntry.fromMap(row, isPersisted: true))
              .toList();
      final resolvedFilledByName =
          (existingJournal?['filledBy'] as String?)?.trim().isNotEmpty == true
              ? (existingJournal!['filledBy'] as String).trim()
              : createdBy;
      final resolvedInitials =
          (existingJournal?['initials'] as String?)?.trim().isNotEmpty == true
              ? (existingJournal!['initials'] as String).trim()
              : _buildInitials(createdBy, firebaseUser?.email);
      final loadedPeopleHours =
          (existingJournal?['peopleHoursEntries'] as List<dynamic>? ?? const [])
              .map((row) => _PeopleHoursEntry.fromMap(row))
              .toList();
      final loadedWaitingTime =
          (existingJournal?['waitingTimeEntries'] as List<dynamic>? ?? const [])
              .map((row) => _WaitingTimeEntry.fromMap(row))
              .toList();
      final loadedWindMeasurements =
          _resolveWindMeasurements(existingJournal?['windMeasurements']);
      final teamSnapshot = await _loadTeamCountsSnapshot();
      final installationTeamCount =
          (existingJournal?['installationTeamCount'] as num?)?.toInt() ??
              teamSnapshot.installationTeamCount;
      final craneCrewCount =
          (existingJournal?['craneCrewCount'] as num?)?.toInt() ??
              teamSnapshot.craneCrewCount;

      if (!mounted) return;
      setState(() {
        _reportNo = previewReportNo;
        _filledByName = resolvedFilledByName;
        _initialsController.value = TextEditingValue(
          text: resolvedInitials,
          selection: TextSelection.collapsed(offset: resolvedInitials.length),
        );
        _remarksController.text =
            (existingJournal?['remarks'] as String?)?.trim() ?? '';
        _installationTeamCountController.text =
            installationTeamCount > 0 ? installationTeamCount.toString() : '';
        _craneCrewCountController.text =
            craneCrewCount > 0 ? craneCrewCount.toString() : '';
        _peopleHoursEntries
          ..clear()
          ..addAll(loadedPeopleHours.isEmpty
              ? [_PeopleHoursEntry(initials: resolvedInitials)]
              : loadedPeopleHours);
        _waitingTimeEntries
          ..clear()
          ..addAll(loadedWaitingTime.isEmpty
              ? [_WaitingTimeEntry()]
              : loadedWaitingTime);
        _windMeasurements
          ..clear()
          ..addAll(loadedWindMeasurements);
        _savedEntries
          ..clear()
          ..addAll(existingRows);
        _entries
          ..clear()
          ..add(_ProgressEntry());
        _editingSavedEntryIndex = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final t = TranslationHelper.of(context);
      showAppFeedback(
        t.translate('daily_journal_load_error'),
        type: AppFeedbackType.error,
      );
    }
  }

  void _scheduleHeaderPersist() {
    _headerPersistTimer?.cancel();
    _headerPersistTimer = Timer(
      const Duration(milliseconds: 450),
      _persistHeaderChangesIfJournalExists,
    );
  }

  Future<void> _persistHeaderChangesIfJournalExists() async {
    final initials = _currentInitials;
    final service = ref.read(dailyJournalServiceProvider);
    final existingJournal = await service.getJournalByDate(
      widget.project.id,
      _selectedDate,
    );

    if (!mounted || existingJournal == null) {
      return;
    }

    final payload = <String, dynamic>{
      ...existingJournal,
      'projectId': widget.project.id,
      'projectNo': widget.project.projectId,
      'projectName': widget.project.nome,
      'journalDate': existingJournal['journalDate'] is Timestamp
          ? existingJournal['journalDate']
          : Timestamp.fromDate(_selectedDate),
      'weekOfYear': _isoWeekNumber(_selectedDate),
      'filledBy': _filledByName,
      'initials': initials,
      'documentNo':
          existingJournal['documentNo'] ?? dailyJournalTemplateDocumentNo,
      'documentReference':
          existingJournal['documentReference'] ?? dailyJournalTemplateReference,
      'documentCreatedBy':
          existingJournal['documentCreatedBy'] ?? dailyJournalTemplateCreatedBy,
      'documentApprovedBy': existingJournal['documentApprovedBy'] ??
          dailyJournalTemplateApprovedBy,
      'documentDate':
          existingJournal['documentDate'] ?? dailyJournalTemplateDate,
      'installationTeamCount':
          int.tryParse(_installationTeamCountController.text.trim()) ??
              ((existingJournal['installationTeamCount'] as num?)?.toInt() ??
                  0),
      'craneCrewCount': int.tryParse(_craneCrewCountController.text.trim()) ??
          ((existingJournal['craneCrewCount'] as num?)?.toInt() ?? 0),
      'peopleHoursEntries':
          existingJournal['peopleHoursEntries'] ?? const <dynamic>[],
      'waitingTimeEntries':
          existingJournal['waitingTimeEntries'] ?? const <dynamic>[],
      'windMeasurements':
          existingJournal['windMeasurements'] ?? const <dynamic>[],
      'remarks': _remarksController.text.trim().isNotEmpty
          ? _remarksController.text.trim()
          : (existingJournal['remarks'] as String?)?.trim() ?? '',
      'siteWorkProgress':
          existingJournal['siteWorkProgress'] ?? const <dynamic>[],
    };

    try {
      await service.createJournal(
        projectId: widget.project.id,
        data: payload,
      );
    } catch (_) {
      // Ignore background header sync failures; explicit save still handles errors.
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _isLoading = true;
    });
    await _loadJournalForDate();
  }

  Future<void> _editSavedJournal(Map<String, dynamic> journal) async {
    final journalDate = (journal['journalDate'] as Timestamp?)?.toDate();
    if (journalDate == null) {
      return;
    }
    final normalizedDate =
        DateTime(journalDate.year, journalDate.month, journalDate.day);
    final journalDateKey = _journalDateKey(normalizedDate);
    final wasSameDay = _isSameDay(_selectedDate, normalizedDate);

    setState(() {
      _selectedDate = normalizedDate;
      _expandedSavedJournalDateKey =
          _expandedSavedJournalDateKey == journalDateKey
              ? null
              : journalDateKey;
    });

    if (_savedEntries.isEmpty || !wasSameDay) {
      setState(() => _isLoading = true);
      await _loadJournalForDate();
    }
  }

  Future<void> _editSavedEntry(int index) async {
    if (index < 0 || index >= _savedEntries.length) {
      return;
    }

    setState(() {
      _entries
        ..clear()
        ..add(_savedEntries[index]
            .copyWith(isPersisted: false, isExpanded: true));
      _editingSavedEntryIndex = index;
      _showSavedJournals = false;
    });

    await _scrollToFormSection();
  }

  Future<void> _deleteSavedEntry(int index) async {
    final t = TranslationHelper.of(context);
    if (index < 0 || index >= _savedEntries.length) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(t.translate('delete')),
            content: Text(t.translate('delete_daily_journal_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(t.translate('cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(t.translate('delete')),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    final updatedRows = List<_ProgressEntry>.from(_savedEntries)
      ..removeAt(index);
    final validPeopleHoursEntries =
        _peopleHoursEntries.where((entry) => entry.hasData).toList();
    final validWaitingTimeEntries =
        _waitingTimeEntries.where((entry) => entry.hasData).toList();

    try {
      if (updatedRows.isEmpty) {
        await ref.read(dailyJournalServiceProvider).deleteJournalByDate(
              widget.project.id,
              _selectedDate,
            );
      } else {
        await ref.read(dailyJournalServiceProvider).createJournal(
          projectId: widget.project.id,
          data: {
            'projectId': widget.project.id,
            'projectNo': widget.project.projectId,
            'projectName': widget.project.nome,
            'journalDate': Timestamp.fromDate(_selectedDate),
            'weekOfYear': _isoWeekNumber(_selectedDate),
            'filledBy': _filledByName,
            'initials': _currentInitials,
            'documentNo': dailyJournalTemplateDocumentNo,
            'documentReference': dailyJournalTemplateReference,
            'documentCreatedBy': dailyJournalTemplateCreatedBy,
            'documentApprovedBy': dailyJournalTemplateApprovedBy,
            'documentDate': dailyJournalTemplateDate,
            'installationTeamCount':
                int.tryParse(_installationTeamCountController.text.trim()) ?? 0,
            'craneCrewCount':
                int.tryParse(_craneCrewCountController.text.trim()) ?? 0,
            'peopleHoursEntries':
                validPeopleHoursEntries.map((entry) => entry.toMap()).toList(),
            'waitingTimeEntries':
                validWaitingTimeEntries.map((entry) => entry.toMap()).toList(),
            'windMeasurements':
                _windMeasurements.map((entry) => entry.toMap()).toList(),
            'remarks': _remarksController.text.trim(),
            'siteWorkProgress':
                updatedRows.map((entry) => entry.toMap()).toList(),
          },
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = true);
      await _loadJournalForDate();
      if (!mounted) return;
      showAppFeedback(
        t.translate('daily_journal_deleted'),
        type: AppFeedbackType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppFeedback(
        '${t.translate('error')}: $e',
        type: AppFeedbackType.error,
      );
    }
  }

  Future<void> _deleteSavedJournal(Map<String, dynamic> journal) async {
    final t = TranslationHelper.of(context);
    final journalDate = (journal['journalDate'] as Timestamp?)?.toDate();
    if (journalDate == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(t.translate('delete')),
            content: Text(t.translate('delete_daily_journal_confirm')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(t.translate('cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(t.translate('delete')),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) {
      return;
    }

    try {
      final deletedCount =
          await ref.read(dailyJournalServiceProvider).deleteJournalByDate(
                widget.project.id,
                journalDate,
              );

      if (deletedCount == 0) {
        if (!mounted) return;
        showAppFeedback(
          t.translate('daily_journal_not_found'),
          type: AppFeedbackType.error,
        );
        return;
      }

      if (!mounted) return;

      final selectedDateKey = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      final deletedDateKey = DateTime(
        journalDate.year,
        journalDate.month,
        journalDate.day,
      );

      if (selectedDateKey == deletedDateKey) {
        setState(() => _isLoading = true);
        await _loadJournalForDate();
      }

      if (!mounted) return;
      showAppFeedback(
        t.translate('daily_journal_deleted'),
        type: AppFeedbackType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppFeedback(
        '${t.translate('error')}: $e',
        type: AppFeedbackType.error,
      );
    }
  }

  Future<void> _save() async {
    final t = TranslationHelper.of(context);
    final validWorkingRows = _entries.where((entry) => entry.hasData).toList();
    final validPeopleHoursEntries =
        _peopleHoursEntries.where((entry) => entry.hasData).toList();
    final validWaitingTimeEntries =
        _waitingTimeEntries.where((entry) => entry.hasData).toList();
    final mergedRows = _savedEntries.map((entry) => entry.copyWith()).toList();

    if (_editingSavedEntryIndex != null) {
      if (validWorkingRows.isNotEmpty &&
          _editingSavedEntryIndex! < mergedRows.length) {
        mergedRows[_editingSavedEntryIndex!] =
            validWorkingRows.first.copyWith();
      }
      if (validWorkingRows.length > 1) {
        mergedRows.addAll(
          validWorkingRows.skip(1).map((entry) => entry.copyWith()),
        );
      }
    } else {
      mergedRows.addAll(validWorkingRows.map((entry) => entry.copyWith()));
    }

    if (mergedRows.isEmpty) {
      showAppFeedback(
        t.translate('daily_journal_no_rows'),
        type: AppFeedbackType.error,
      );
      return;
    }

    setState(() => _isSaving = true);
    widget.shellController?.updateSaving(_isSaving);
    showLiquidDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dailyJournalService = ref.read(dailyJournalServiceProvider);
      final assignedReportNo = await dailyJournalService.createJournal(
        projectId: widget.project.id,
        data: {
          'projectId': widget.project.id,
          'projectNo': widget.project.projectId,
          'projectName': widget.project.nome,
          'journalDate': Timestamp.fromDate(_selectedDate),
          'weekOfYear': _isoWeekNumber(_selectedDate),
          'filledBy': _filledByName,
          'initials': _currentInitials,
          'documentNo': dailyJournalTemplateDocumentNo,
          'documentReference': dailyJournalTemplateReference,
          'documentCreatedBy': dailyJournalTemplateCreatedBy,
          'documentApprovedBy': dailyJournalTemplateApprovedBy,
          'documentDate': dailyJournalTemplateDate,
          'installationTeamCount':
              int.tryParse(_installationTeamCountController.text.trim()) ?? 0,
          'craneCrewCount':
              int.tryParse(_craneCrewCountController.text.trim()) ?? 0,
          'peopleHoursEntries':
              validPeopleHoursEntries.map((entry) => entry.toMap()).toList(),
          'waitingTimeEntries':
              validWaitingTimeEntries.map((entry) => entry.toMap()).toList(),
          'windMeasurements':
              _windMeasurements.map((entry) => entry.toMap()).toList(),
          'remarks': _remarksController.text.trim(),
          'siteWorkProgress': mergedRows.map((entry) => entry.toMap()).toList(),
        },
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => _isLoading = true);
      await _loadJournalForDate();
      if (!mounted) return;
      showAppFeedback(
        '${t.translate('daily_journal_saved')} (#$assignedReportNo)',
        type: AppFeedbackType.success,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showAppFeedback(
        '${t.translate('error')}: $e',
        type: AppFeedbackType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
      widget.shellController?.updateSaving(_isSaving);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final recentJournalsAsync =
        ref.watch(recentDailyJournalsProvider(widget.project.id));

    widget.shellController?.bind(_save);
    widget.shellController?.updateSaving(_isSaving);

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
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1460),
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    children: [
                      _buildIntroCard(t),
                      const SizedBox(height: 16),
                      _buildDocumentControlCard(t),
                      const SizedBox(height: 16),
                      _buildHeaderCard(t),
                      const SizedBox(height: 16),
                      _buildTeamCountsCard(t),
                      const SizedBox(height: 16),
                      _buildSavedJournalsSection(t, recentJournalsAsync),
                      const SizedBox(height: 16),
                      _buildProgressCard(t),
                      const SizedBox(height: 16),
                      _buildRemarksCard(t),
                      const SizedBox(height: 16),
                      _buildPeopleHoursCard(t),
                      const SizedBox(height: 16),
                      _buildWaitingTimeCard(t),
                      const SizedBox(height: 16),
                      _buildWindMeasurementsCard(t),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
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
                          label: Text(t.translate('save_daily_journal')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );

    if (widget.embeddedInDesktopShell) {
      return screenBody;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: DashboardShortcutTitle(
          child: Row(
            children: [
              const Icon(Icons.menu_book_outlined, color: Colors.white),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.translate('daily_journal')),
                  Text(
                    widget.project.nome,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _save,
            tooltip: t.translate('save_daily_journal'),
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: screenBody,
    );
  }

  Widget _buildSavedJournalsSection(
    TranslationHelper t,
    AsyncValue<List<Map<String, dynamic>>> recentJournalsAsync,
  ) {
    final title = '${t.translate('daily_journal')} - Guardados';

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _showSavedJournals = !_showSavedJournals),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _glassPanelColor(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.adaptiveOutline(context)),
              boxShadow: AppColors.glassShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  _showSavedJournals
                      ? Icons.expand_less_outlined
                      : Icons.expand_more_outlined,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
        if (_showSavedJournals) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _glassPanelColor(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.adaptiveOutline(context)),
              boxShadow: AppColors.glassShadow,
            ),
            child: recentJournalsAsync.when(
              data: (journals) {
                if (journals.isEmpty) {
                  return const Text(
                      'Ainda não existem Daily Journals guardados.');
                }

                return Column(
                  children: journals.map((journal) {
                    final journalDate =
                        (journal['journalDate'] as Timestamp?)?.toDate();
                    final journalDateKey = journalDate == null
                        ? null
                        : _journalDateKey(journalDate);
                    final rows =
                        (journal['siteWorkProgress'] as List<dynamic>? ??
                                const [])
                            .length;
                    final lineLabel = rows == 1 ? '1 linha' : '$rows linhas';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _SavedJournalActionCard(
                                  label:
                                      '#${(journal['reportNo'] as num?)?.toInt() ?? rows}  ${journalDate == null ? '' : _formatDate(journalDate)}',
                                  trailingLabel: lineLabel,
                                  tooltip: t.translate('edit'),
                                  icon: Icons.edit_outlined,
                                  onTap: () => _editSavedJournal(journal),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _SavedJournalIconAction(
                                tooltip: t.translate('delete'),
                                icon: Icons.delete_outline,
                                color: AppColors.errorRed,
                                onTap: () => _deleteSavedJournal(journal),
                              ),
                            ],
                          ),
                          if (journalDateKey != null &&
                              _expandedSavedJournalDateKey == journalDateKey)
                            ...((journal['siteWorkProgress']
                                        as List<dynamic>? ??
                                    const [])
                                .asMap()
                                .entries
                                .map((savedRow) => _buildSavedJournalLineItem(
                                      t,
                                      savedRow.key,
                                      _ProgressEntry.fromMap(
                                        savedRow.value,
                                        isPersisted: true,
                                      ),
                                    ))),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text('${t.translate('error')}: $error'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIntroCard(TranslationHelper t) {
    final outline = AppColors.adaptiveOutline(context);
    final panel = _glassPanelColor(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: outline),
        boxShadow: AppColors.glassShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.22),
              ),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              t.translate('daily_journal_intro'),
              style: TextStyle(
                color: AppColors.adaptivePrimaryText(context),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentControlCard(TranslationHelper t) {
    return _SectionCard(
      title: t.translate('document_control'),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: const [
          _InfoField(
              label: 'Document No.',
              value: dailyJournalTemplateDocumentNo,
              color: AppColors.primaryBlue),
          _InfoField(
              label: 'Ref.',
              value: dailyJournalTemplateReference,
              color: AppColors.infoBlue),
          _InfoField(
              label: 'Created by',
              value: dailyJournalTemplateCreatedBy,
              color: AppColors.accentTeal),
          _InfoField(
              label: 'Approved by',
              value: dailyJournalTemplateApprovedBy,
              color: AppColors.warningOrange),
          _InfoField(
              label: 'Date',
              value: dailyJournalTemplateDate,
              color: AppColors.errorRed),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(TranslationHelper t) {
    return _SectionCard(
      title: t.translate('daily_journal'),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoField(
                label: t.translate('project_id'),
                value: widget.project.projectId,
                color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            _InfoField(
                label: t.translate('project_name'),
                value: widget.project.nome,
                color: AppColors.infoBlue),
            const SizedBox(width: 12),
            _InfoField(
                label: t.translate('report_no'),
                value: _reportNo.toString(),
                color: AppColors.accentTeal),
            const SizedBox(width: 12),
            _InfoField(
                label: t.translate('week'),
                value: _isoWeekNumber(_selectedDate).toString(),
                color: AppColors.warningOrange),
            const SizedBox(width: 12),
            _DateField(
              label: t.translate('report_date'),
              value: _formatDate(_selectedDate),
              onTap: _pickDate,
              color: AppColors.errorRed,
            ),
            const SizedBox(width: 12),
            _EditableInfoField(
              label: t.translate('initials'),
              controller: _initialsController,
              color: AppColors.mediumGray,
              onChanged: (value) {
                _scheduleHeaderPersist();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCountsCard(TranslationHelper t) {
    return _SectionCard(
      title: t.translate('daily_journal_site_team'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _CountField(
                controller: _installationTeamCountController,
                label: t.translate('installation_team_count'),
                color: AppColors.primaryBlue,
              ),
              _CountField(
                controller: _craneCrewCountController,
                label: t.translate('crane_crew_count'),
                color: AppColors.accentTeal,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            t.translate('team_count_helper'),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.adaptiveSecondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(TranslationHelper t) {
    return _SectionCard(
      key: _formSectionKey,
      title: t.translate('site_work_progress'),
      action: TextButton.icon(
        onPressed: () => setState(() => _entries.add(_ProgressEntry())),
        icon: const Icon(Icons.add),
        label: Text(t.translate('add_row')),
      ),
      child: Column(
        children: [
          for (var index = 0; index < _entries.length; index++)
            _buildEntryRow(t, index, _entries[index]),
        ],
      ),
    );
  }

  Widget _buildEntryRow(
    TranslationHelper t,
    int index,
    _ProgressEntry entry,
  ) {
    final subCategories = entry.category == null
        ? const <String>[]
        : dailyJournalCategories[entry.category] ?? const <String>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: _glassCardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.24),
                  ),
                ),
                child: const Text(
                  'Linha',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '#${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.adaptivePrimaryText(context),
                ),
              ),
              const Spacer(),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.16),
                  ),
                ),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints.tightFor(width: 34, height: 34),
                  padding: EdgeInsets.zero,
                  onPressed: _entries.length == 1
                      ? null
                      : () => setState(() => _entries.removeAt(index)),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 980) {
                return Row(
                  children: [
                    Expanded(
                      child: _DropdownField(
                        label: t.translate('location'),
                        value: entry.location,
                        items: dailyJournalLocations,
                        itemLabel: _locationLabel,
                        onChanged: (value) =>
                            setState(() => entry.location = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DropdownField(
                        label: t.translate('component_category'),
                        value: entry.category,
                        items:
                            dailyJournalCategories.keys.toList(growable: false),
                        itemLabel: _categoryLabel,
                        onChanged: (value) {
                          setState(() {
                            entry.category = value;
                            entry.subCategory = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DropdownField(
                        label: t.translate('sub_category'),
                        value: entry.subCategory,
                        items: subCategories,
                        itemLabel: _subCategoryLabel,
                        onChanged: (value) =>
                            setState(() => entry.subCategory = value),
                      ),
                    ),
                  ],
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DropdownField(
                    label: t.translate('location'),
                    value: entry.location,
                    items: dailyJournalLocations,
                    itemLabel: _locationLabel,
                    onChanged: (value) =>
                        setState(() => entry.location = value),
                  ),
                  _DropdownField(
                    label: t.translate('component_category'),
                    value: entry.category,
                    items: dailyJournalCategories.keys.toList(growable: false),
                    itemLabel: _categoryLabel,
                    onChanged: (value) {
                      setState(() {
                        entry.category = value;
                        entry.subCategory = null;
                      });
                    },
                  ),
                  _DropdownField(
                    label: t.translate('sub_category'),
                    value: entry.subCategory,
                    items: subCategories,
                    itemLabel: _subCategoryLabel,
                    onChanged: (value) =>
                        setState(() => entry.subCategory = value),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: entry.notes,
            minLines: 1,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: t.translate('notes'),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (value) => entry.notes = value,
          ),
        ],
      ),
    );
  }

  Widget _buildSavedJournalLineItem(
    TranslationHelper t,
    int index,
    _ProgressEntry entry,
  ) {
    final summaryParts = <String>[
      if ((entry.location ?? '').trim().isNotEmpty)
        _locationLabel(entry.location!.trim()),
      if ((entry.category ?? '').trim().isNotEmpty)
        _categoryLabel(entry.category!.trim()),
      if ((entry.subCategory ?? '').trim().isNotEmpty)
        _subCategoryLabel(entry.subCategory!.trim()),
    ];
    final notes = entry.notes.trim();

    return Container(
      margin: const EdgeInsets.only(top: 8, left: 12, right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _glassCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summaryParts.isEmpty ? '-' : summaryParts.join('  •  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.adaptivePrimaryText(context),
                  ),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.adaptiveSecondaryText(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: t.translate('edit'),
            onPressed: () => _editSavedEntry(index),
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.primaryBlue,
          ),
          IconButton(
            tooltip: t.translate('delete'),
            onPressed: () => _deleteSavedEntry(index),
            icon: const Icon(Icons.delete_outline),
            color: AppColors.errorRed,
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksCard(TranslationHelper t) {
    return _SectionCard(
      title: t.translate('erection_daily_remarks'),
      child: TextField(
        controller: _remarksController,
        minLines: 2,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: t.translate('notes'),
          alignLabelWithHint: true,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPeopleHoursCard(TranslationHelper t) {
    return _SectionCard(
      title: t.translate('daily_journal_people_hours'),
      action: TextButton.icon(
        onPressed: () => setState(() => _peopleHoursEntries.add(
              _PeopleHoursEntry(travellingTime: '0:00'),
            )),
        icon: const Icon(Icons.add),
        label: Text(t.translate('add_row')),
      ),
      child: Column(
        children: [
          for (var index = 0; index < _peopleHoursEntries.length; index++)
            _buildPeopleHoursRow(t, index, _peopleHoursEntries[index]),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.accentTeal.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                '${t.translate('total')}: ${_calculateTotalPeopleManhours()}',
                style: const TextStyle(
                  color: AppColors.accentTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingTimeCard(TranslationHelper t) {
    return _SectionCard(
      title: t.translate('daily_journal_waiting_time'),
      action: TextButton.icon(
        onPressed: () =>
            setState(() => _waitingTimeEntries.add(_WaitingTimeEntry())),
        icon: const Icon(Icons.add),
        label: Text(t.translate('add_row')),
      ),
      child: Column(
        children: [
          for (var index = 0; index < _waitingTimeEntries.length; index++)
            _buildWaitingTimeRow(t, index, _waitingTimeEntries[index]),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.warningOrange.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                '${t.translate('total')}: ${_calculateTotalWaitingManhours()}',
                style: const TextStyle(
                  color: AppColors.warningOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingTimeRow(
    TranslationHelper t,
    int index,
    _WaitingTimeEntry entry,
  ) {
    return Container(
      key: ObjectKey(entry),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: _glassCardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '#${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.adaptivePrimaryText(context),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warningOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.warningOrange.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  _calculateWaitingManhours(entry),
                  style: const TextStyle(
                    color: AppColors.warningOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.16),
                  ),
                ),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints.tightFor(width: 34, height: 34),
                  padding: EdgeInsets.zero,
                  onPressed: _waitingTimeEntries.length == 1
                      ? null
                      : () =>
                          setState(() => _waitingTimeEntries.removeAt(index)),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TimeTextField(
                label: t.translate('responsible'),
                value: entry.responsible,
                minWidth: 140,
                maxWidth: 190,
                onChanged: (value) => setState(() => entry.responsible = value),
              ),
              _TimeTextField(
                label: t.translate('company'),
                value: entry.company,
                minWidth: 140,
                maxWidth: 180,
                onChanged: (value) => setState(() => entry.company = value),
              ),
              _TimeTextField(
                label: t.translate('people'),
                value: entry.people,
                minWidth: 110,
                maxWidth: 130,
                onChanged: (value) => setState(() => entry.people = value),
              ),
              _TimeTextField(
                label: t.translate('total_hours'),
                value: entry.totalHours,
                isTimeField: true,
                minWidth: 130,
                maxWidth: 150,
                onChanged: (value) => setState(() => entry.totalHours = value),
              ),
              _TimeTextField(
                label: t.translate('description'),
                value: entry.description,
                minWidth: 260,
                maxWidth: 420,
                onChanged: (value) => setState(() => entry.description = value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWindMeasurementsCard(TranslationHelper t) {
    return _SectionCard(
      title: t.translate('daily_journal_wind_measurements'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.translate('wind_photo_helper'),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.adaptiveSecondaryText(context),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth >= 1180;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final entry in _windMeasurements)
                    SizedBox(
                      width: compact ? (constraints.maxWidth - 24) / 3 : 320,
                      child: _buildWindMeasurementTile(t, entry),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWindMeasurementTile(
    TranslationHelper t,
    _WindMeasurementEntry entry,
  ) {
    final infoPanelColor = AppColors.isDarkContext(context)
        ? AppColors.adaptivePanelSurface(context).withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _glassCardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  entry.timeLabel,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: infoPanelColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.adaptiveOutline(context),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.translate('manual_excel_photo_note'),
                  style: TextStyle(
                    color: AppColors.adaptivePrimaryText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.translate('manual_excel_photo_note_detail'),
                  style: TextStyle(
                    color: AppColors.adaptiveSecondaryText(context),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleHoursRow(
    TranslationHelper t,
    int index,
    _PeopleHoursEntry entry,
  ) {
    return Container(
      key: ObjectKey(entry),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: _glassCardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '#${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.adaptivePrimaryText(context),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warningOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.warningOrange.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  _calculatePeopleManhours(entry),
                  style: const TextStyle(
                    color: AppColors.warningOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.16),
                  ),
                ),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints.tightFor(width: 34, height: 34),
                  padding: EdgeInsets.zero,
                  onPressed: _peopleHoursEntries.length == 1
                      ? null
                      : () =>
                          setState(() => _peopleHoursEntries.removeAt(index)),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.errorRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth >= 980;
              final fields = [
                _TimeTextField(
                  label: t.translate('initials'),
                  value: entry.initials,
                  onChanged: (value) => setState(() => entry.initials = value),
                ),
                _TimeTextField(
                  label: t.translate('horaInicio'),
                  value: entry.startTime,
                  isTimeField: true,
                  onChanged: (value) => setState(() => entry.startTime = value),
                ),
                _TimeTextField(
                  label: t.translate('horaFim'),
                  value: entry.finishTime,
                  isTimeField: true,
                  onChanged: (value) =>
                      setState(() => entry.finishTime = value),
                ),
                _TimeTextField(
                  label: t.translate('travelling_time'),
                  value: entry.travellingTime,
                  isTimeField: true,
                  onChanged: (value) =>
                      setState(() => entry.travellingTime = value),
                ),
              ];

              if (compact) {
                return Row(
                  children: [
                    for (var fieldIndex = 0;
                        fieldIndex < fields.length;
                        fieldIndex++) ...[
                      Expanded(child: fields[fieldIndex]),
                      if (fieldIndex < fields.length - 1)
                        const SizedBox(width: 8),
                    ],
                  ],
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fields,
              );
            },
          ),
        ],
      ),
    );
  }

  int? _parseTimeToMinutes(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final hours = int.tryParse(match.group(1)!);
    final minutes = int.tryParse(match.group(2)!);
    if (hours == null || minutes == null || minutes < 0 || minutes > 59) {
      return null;
    }

    return (hours * 60) + minutes;
  }

  String _formatMinutes(int minutes) {
    final safeMinutes = minutes < 0 ? 0 : minutes;
    final hours = safeMinutes ~/ 60;
    final remainingMinutes = safeMinutes % 60;
    return '$hours:${remainingMinutes.toString().padLeft(2, '0')}';
  }

  String _calculatePeopleManhours(_PeopleHoursEntry entry) {
    final startMinutes = _parseTimeToMinutes(entry.startTime);
    final finishMinutes = _parseTimeToMinutes(entry.finishTime);
    final travellingMinutes = _parseTimeToMinutes(entry.travellingTime) ?? 0;

    if (startMinutes == null || finishMinutes == null) {
      return '0:00';
    }

    final manhours = finishMinutes - startMinutes - travellingMinutes;
    return _formatMinutes(manhours);
  }

  String _calculateTotalPeopleManhours() {
    var totalMinutes = 0;
    for (final entry in _peopleHoursEntries) {
      final startMinutes = _parseTimeToMinutes(entry.startTime);
      final finishMinutes = _parseTimeToMinutes(entry.finishTime);
      final travellingMinutes = _parseTimeToMinutes(entry.travellingTime) ?? 0;

      if (startMinutes == null || finishMinutes == null) {
        continue;
      }

      totalMinutes += finishMinutes - startMinutes - travellingMinutes;
    }

    return _formatMinutes(totalMinutes);
  }

  String _calculateWaitingManhours(_WaitingTimeEntry entry) {
    final peopleCount = int.tryParse(entry.people.trim()) ?? 0;
    final totalMinutes = _parseTimeToMinutes(entry.totalHours) ?? 0;
    return _formatMinutes(totalMinutes * peopleCount);
  }

  String _calculateTotalWaitingManhours() {
    var totalMinutes = 0;
    for (final entry in _waitingTimeEntries) {
      final peopleCount = int.tryParse(entry.people.trim()) ?? 0;
      final totalEntryMinutes = _parseTimeToMinutes(entry.totalHours) ?? 0;
      totalMinutes += totalEntryMinutes * peopleCount;
    }

    return _formatMinutes(totalMinutes);
  }

  String _buildInitials(String? name, String? email) {
    final normalized = (name ?? '').trim();
    if (normalized.isNotEmpty) {
      final parts = normalized
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) {
        return parts.take(3).map((part) => part[0]).join().toLowerCase();
      }
    }
    final fallback = (email ?? 'user').split('@').first;
    return fallback.substring(0, fallback.length.clamp(1, 4)).toLowerCase();
  }

  int _isoWeekNumber(DateTime date) {
    final thursday =
        date.add(Duration(days: 4 - (date.weekday == 7 ? 7 : date.weekday)));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final firstWeekStart =
        firstThursday.subtract(Duration(days: firstThursday.weekday - 1));
    return ((thursday.difference(firstWeekStart).inDays) / 7).floor() + 1;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _journalDateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class _ProgressEntry {
  String? location;
  String? category;
  String? subCategory;
  String notes = '';
  bool isPersisted;
  bool isExpanded;

  _ProgressEntry({
    this.isPersisted = false,
    this.isExpanded = true,
  });

  factory _ProgressEntry.fromMap(
    dynamic value, {
    bool isPersisted = false,
  }) {
    final map = value is Map ? value : const <String, dynamic>{};
    final entry = _ProgressEntry(
      isPersisted: isPersisted,
      isExpanded: !isPersisted,
    );
    entry.location = map['location']?.toString();
    entry.category = map['category']?.toString();
    final rawSubCategory = map['subCategory']?.toString();
    entry.subCategory = rawSubCategory == null || rawSubCategory.isEmpty
        ? null
        : rawSubCategory;
    entry.notes = map['notes']?.toString() ?? '';
    return entry;
  }

  bool get hasData {
    return (location?.isNotEmpty == true) ||
        (category?.isNotEmpty == true) ||
        (subCategory?.isNotEmpty == true) ||
        notes.trim().isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'category': category,
      'subCategory': subCategory,
      'notes': notes.trim(),
    };
  }

  _ProgressEntry copyWith({
    String? location,
    String? category,
    String? subCategory,
    String? notes,
    bool? isPersisted,
    bool? isExpanded,
  }) {
    final entry = _ProgressEntry(
      isPersisted: isPersisted ?? this.isPersisted,
      isExpanded: isExpanded ?? this.isExpanded,
    );
    entry.location = location ?? this.location;
    entry.category = category ?? this.category;
    entry.subCategory = subCategory ?? this.subCategory;
    entry.notes = notes ?? this.notes;
    return entry;
  }
}

class _PeopleHoursEntry {
  String initials;
  String startTime;
  String finishTime;
  String travellingTime;

  _PeopleHoursEntry({
    this.initials = '',
    this.startTime = '',
    this.finishTime = '',
    this.travellingTime = '0:00',
  });

  factory _PeopleHoursEntry.fromMap(dynamic value) {
    final map = value is Map ? value : const <String, dynamic>{};
    return _PeopleHoursEntry(
      initials: map['initials']?.toString() ?? '',
      startTime: map['startTime']?.toString() ?? '',
      finishTime: map['finishTime']?.toString() ?? '',
      travellingTime: map['travellingTime']?.toString() ?? '0:00',
    );
  }

  bool get hasData {
    return initials.trim().isNotEmpty ||
        startTime.trim().isNotEmpty ||
        finishTime.trim().isNotEmpty ||
        travellingTime.trim().isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'initials': initials.trim(),
      'startTime': startTime.trim(),
      'finishTime': finishTime.trim(),
      'travellingTime': travellingTime.trim(),
    };
  }
}

class _WaitingTimeEntry {
  String responsible;
  String company;
  String people;
  String totalHours;
  String description;

  _WaitingTimeEntry({
    this.responsible = '',
    this.company = '',
    this.people = '',
    this.totalHours = '',
    this.description = '',
  });

  factory _WaitingTimeEntry.fromMap(dynamic value) {
    final map = value is Map ? value : const <String, dynamic>{};
    return _WaitingTimeEntry(
      responsible: map['responsible']?.toString() ?? '',
      company: map['company']?.toString() ?? '',
      people: map['people']?.toString() ?? '',
      totalHours: map['totalHours']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }

  bool get hasData {
    return responsible.trim().isNotEmpty ||
        company.trim().isNotEmpty ||
        people.trim().isNotEmpty ||
        totalHours.trim().isNotEmpty ||
        description.trim().isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'responsible': responsible.trim(),
      'company': company.trim(),
      'people': people.trim(),
      'totalHours': totalHours.trim(),
      'description': description.trim(),
    };
  }
}

class _WindMeasurementEntry {
  final String timeLabel;

  const _WindMeasurementEntry({required this.timeLabel});

  Map<String, dynamic> toMap() {
    return {
      'timeLabel': timeLabel,
    };
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const _SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final panel = AppColors.adaptivePanelSurface(context).withValues(
      alpha: AppColors.isDarkContext(context) ? 0.72 : 0.88,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.adaptiveOutline(context)),
        boxShadow: AppColors.glassShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoField({
    required this.label,
    required this.value,
    this.color = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: color)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.adaptivePrimaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color color;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.color = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 220),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: color)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.adaptivePrimaryText(context),
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today_outlined, size: 18, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableInfoField extends StatelessWidget {
  const _EditableInfoField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.color = AppColors.primaryBlue,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fillColor = AppColors.isDarkContext(context)
        ? AppColors.adaptivePanelSurface(context).withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.86);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 180),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: color)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              onChanged: onChanged,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                LengthLimitingTextInputFormatter(8),
              ],
              maxLines: 1,
              minLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.adaptivePrimaryText(context),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: fillColor,
                hintText: '',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.adaptiveOutline(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String Function(String value) itemLabel;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = AppColors.isDarkContext(context)
        ? AppColors.adaptivePanelSurface(context).withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.86);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 210),
      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : null,
        isExpanded: true,
        dropdownColor: fillColor,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          filled: true,
          fillColor: fillColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.adaptiveOutline(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primaryBlue, width: 1.2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  itemLabel(item),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _SavedJournalActionCard extends StatelessWidget {
  const _SavedJournalActionCard({
    required this.label,
    required this.trailingLabel,
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String trailingLabel;
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.adaptivePrimaryText(context),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.accentTeal.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  trailingLabel,
                  style: const TextStyle(
                    color: AppColors.accentTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountField extends StatelessWidget {
  const _CountField({
    required this.controller,
    required this.label,
    required this.color,
  });

  final TextEditingController controller;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          filled: true,
          fillColor: color.withValues(alpha: 0.08),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 1.2),
          ),
          prefixIcon: Icon(Icons.groups_2_outlined, color: color, size: 18),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

class _TimeTextField extends StatelessWidget {
  const _TimeTextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.minWidth = 160,
    this.maxWidth = 220,
    this.isTimeField = false,
  });

  final String label;
  final String value;
  final double minWidth;
  final double maxWidth;
  final bool isTimeField;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final fillColor = AppColors.isDarkContext(context)
        ? AppColors.adaptivePanelSurface(context).withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.86);

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
      child: TextFormField(
        initialValue: value,
        keyboardType: isTimeField ? TextInputType.number : TextInputType.text,
        inputFormatters: isTimeField ? const [_HourTextInputFormatter()] : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: isTimeField ? '00:00' : null,
          isDense: true,
          filled: true,
          fillColor: fillColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.adaptiveOutline(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primaryBlue, width: 1.2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _HourTextInputFormatter extends TextInputFormatter {
  const _HourTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final truncated = digits.length > 4 ? digits.substring(0, 4) : digits;
    final formatted = truncated.length <= 2
        ? truncated
        : '${truncated.substring(0, 2)}:${truncated.substring(2)}';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _SavedJournalIconAction extends StatelessWidget {
  const _SavedJournalIconAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
