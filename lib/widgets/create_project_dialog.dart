import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme/app_colors.dart';
import '../core/localization/translation_helper.dart';
import '../models/project.dart';
import '../providers/app_providers.dart';
import '../services/project_phase_service.dart';
import '../utils/map_launcher.dart';
import '../utils/app_feedback.dart';

// ════════════════════════════════════════════════════════════════════════════
// 🎨 CREATE PROJECT WIZARD - VERSÃO ATUALIZADA
// ════════════════════════════════════════════════════════════════════════════
//
// ALTERAÇÕES FEITAS:
// ❌ REMOVIDO: Slider "Tower Sections" (vai para criação de turbina)
// ❌ REMOVIDO: Campos de data do Tab 1 (movidos para Tab 2)
// 🆕 ADICIONADO: Campo "Morada" (opcional) no Tab 1
// 🆕 ADICIONADO: Campo "Coordenadas GPS" (opcional) no Tab 1
// ➡️ MOVIDO: "Disponibilidade Estimada da Rede" para Tab 2 (topo)
//
// ════════════════════════════════════════════════════════════════════════════

class CreateProjectWizard extends ConsumerStatefulWidget {
  const CreateProjectWizard({super.key});

  @override
  ConsumerState<CreateProjectWizard> createState() =>
      _CreateProjectWizardState();
}

class _CreateProjectWizardState extends ConsumerState<CreateProjectWizard> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // ══════════════════════════════════════════════════════════════════════════
  // Step 1 - Info básica (ATUALIZADO)
  // ══════════════════════════════════════════════════════════════════════════
  final _nomeController = TextEditingController();
  final _projectIdController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _moradaController = TextEditingController(); // 🆕 NOVO
  final _coordenadasGPSController = TextEditingController(); // 🆕 NOVO
  final _coordenadasGPSEscritorioController = TextEditingController();
  final _projectManagerController = TextEditingController();
  final _siteManagerController = TextEditingController();
  final _turbineTypeController = TextEditingController();
  final _foundationTypeController = TextEditingController();

  // ❌ REMOVIDO: int _towerSections = 4;
  // ❌ REMOVIDO: DateTime? _siteOpeningDate;
  // ❌ REMOVIDO: DateTime? _estimatedHandover;

  // ══════════════════════════════════════════════════════════════════════════
  // Step 2 - Datas das fases (ATUALIZADO)
  // ══════════════════════════════════════════════════════════════════════════
  DateTime? _estimatedGridAvailability; // ➡️ MOVIDO para Tab 2
  final Map<int, DateTime?> _phasesStartDates = {};
  final Map<int, DateTime?> _phasesEndDates = {};
  final Map<int, bool> _phasesNA = {};

  @override
  void dispose() {
    _nomeController.dispose();
    _projectIdController.dispose();
    _localizacaoController.dispose();
    _moradaController.dispose(); // 🆕 NOVO
    _coordenadasGPSController.dispose(); // 🆕 NOVO
    _coordenadasGPSEscritorioController.dispose();
    _projectManagerController.dispose();
    _siteManagerController.dispose();
    _turbineTypeController.dispose();
    _foundationTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);

    return Dialog(
      child: SizedBox(
        width: 900,
        height: 700,
        child: Column(
          children: [
            _buildHeader(t),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(t),
              ),
            ),
            _buildNavigationButtons(t),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TranslationHelper t) {
    final steps = [
      t.translate('project_info'),
      t.translate('project_phases'),
      t.translate('review'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        border: const Border(
          bottom: BorderSide(color: AppColors.borderGray),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.article, color: AppColors.primaryBlue, size: 28),
              const SizedBox(width: 12),
              Text(
                t.translate('create_project_wizard'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${t.translate('step')} ${_currentStep + 1} / 3',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryBlue
                              : AppColors.borderGray,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < 2) const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final isActive = index == _currentStep;
              return Expanded(
                child: Text(
                  steps[index],
                  textAlign: index == 0
                      ? TextAlign.left
                      : index == 2
                          ? TextAlign.right
                          : TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color:
                        isActive ? AppColors.primaryBlue : AppColors.mediumGray,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(TranslationHelper t) {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicInfo(t);
      case 1:
        return _buildStep2Phases(t);
      case 2:
        return _buildStep3Review(t);
      default:
        return const SizedBox.shrink();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📋 TAB 1: INFORMAÇÃO BÁSICA (ATUALIZADO - SEM DATAS E SLIDER)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStep1BasicInfo(TranslationHelper t) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.translate('basic_project_information'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Nome do projeto
          TextFormField(
            controller: _nomeController,
            decoration: InputDecoration(
              labelText: '${t.translate('project_name')} *',
              hintText: t.translate('project_name_hint'),
              border: const OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? t.translate('required_field')
                : null,
          ),
          const SizedBox(height: 16),

          // Project ID
          TextFormField(
            controller: _projectIdController,
            decoration: InputDecoration(
              labelText: '${t.translate('project_id')} *',
              hintText: t.translate('project_id_hint'),
              border: const OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.trim().isEmpty
                ? t.translate('required_field')
                : null,
          ),
          const SizedBox(height: 16),

          // Localização
          TextFormField(
            controller: _localizacaoController,
            decoration: InputDecoration(
              labelText: t.translate('location'),
              hintText: t.translate('location_hint'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // ════════════════════════════════════════════════════════════════
          // 🆕 NOVO: MORADA (opcional)
          // ════════════════════════════════════════════════════════════════
          TextFormField(
            controller: _moradaController,
            decoration: InputDecoration(
              labelText: t.translate('address'),
              hintText: 'Ex: Rua Principal 123, Lisboa',
              border: const OutlineInputBorder(),
              helperText: t.translate('optional'),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          _buildCoordinatesSection(t),
          const SizedBox(height: 16),

          // Gestor do Projeto e Gestor do Local
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _projectManagerController,
                  decoration: InputDecoration(
                    labelText: '${t.translate('project_manager')} *',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? t.translate('required_field')
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _siteManagerController,
                  decoration: InputDecoration(
                    labelText: '${t.translate('site_manager')} *',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? t.translate('required_field')
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tipo de Turbina e Tipo de Fundação
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _turbineTypeController,
                  decoration: InputDecoration(
                    labelText: '${t.translate('turbine_type')} *',
                    hintText: t.translate('turbine_type_hint'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? t.translate('required_field')
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _foundationTypeController,
                  decoration: InputDecoration(
                    labelText: '${t.translate('foundation_type')} *',
                    hintText: t.translate('foundation_type_hint'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? t.translate('required_field')
                      : null,
                ),
              ),
            ],
          ),

          // ════════════════════════════════════════════════════════════════
          // ❌ REMOVIDO: Slider "Tower Sections"
          // ❌ REMOVIDO: Campo "Site Opening Date"
          // ❌ REMOVIDO: Campo "Estimated Grid Availability"
          // ❌ REMOVIDO: Campo "Estimated Handover"
          // ════════════════════════════════════════════════════════════════
        ],
      ),
    );
  }

  Widget _buildCoordinatesSection(TranslationHelper t) {
    final projectCoordinatesLabel = _localizedWizardText(
      t,
      'project_gps_coordinates',
      'Coordenadas GPS do projeto',
      'Project GPS coordinates',
    );
    final officeCoordinatesLabel = _localizedWizardText(
      t,
      'office_gps_coordinates',
      'Coordenadas GPS do escritório',
      'Office GPS coordinates',
    );
    final enterOrPickText = _localizedWizardText(
      t,
      'enter_or_pick_coordinates',
      'Introduza manualmente ou selecione no mapa.',
      'Enter them manually or choose them on the map.',
    );
    final officeOptionalText = _localizedWizardText(
      t,
      'office_coordinates_optional',
      'Opcional. Use este campo quando o escritório/base estiver noutro local.',
      'Optional. Use this field when the office/base is in a different place.',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCoordinateInputCard(
          t: t,
          title: projectCoordinatesLabel,
          controller: _coordenadasGPSController,
          hintText: 'Ex: 38.7223, -9.1393',
          helperText: enterOrPickText,
        ),
        const SizedBox(height: 12),
        _buildCoordinateInputCard(
          t: t,
          title: officeCoordinatesLabel,
          controller: _coordenadasGPSEscritorioController,
          hintText: 'Ex: 41.1579, -8.6291',
          helperText: officeOptionalText,
        ),
      ],
    );
  }

  Widget _buildCoordinateInputCard({
    required TranslationHelper t,
    required String title,
    required TextEditingController controller,
    required String hintText,
    required String helperText,
  }) {
    final parsedCoordinates = MapLauncher.tryParseCoordinates(controller.text);
    final pickOnMapLabel = _localizedWizardText(
      t,
      'pick_on_map',
      'Selecionar no mapa',
      'Pick on map',
    );
    final noSelectionLabel = _localizedWizardText(
      t,
      'map_picker_no_selection',
      'Nenhuma coordenada selecionada.',
      'No coordinates selected.',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.lightGray.withValues(alpha: 0.25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: title,
              hintText: hintText,
              border: const OutlineInputBorder(),
              helperText: helperText,
              suffixIcon: IconButton(
                tooltip: pickOnMapLabel,
                onPressed: () => _openCoordinatePicker(
                  t: t,
                  title: title,
                  controller: controller,
                ),
                icon: const Icon(Icons.map_outlined),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _openCoordinatePicker(
                  t: t,
                  title: title,
                  controller: controller,
                ),
                icon: const Icon(Icons.place_outlined),
                label: Text(pickOnMapLabel),
              ),
              const SizedBox(width: 12),
              if (controller.text.trim().isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    controller.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear),
                  label: Text(t.translate('cancel')),
                ),
              const Spacer(),
              Flexible(
                child: Text(
                  parsedCoordinates?.displayValue ?? noSelectionLabel,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: parsedCoordinates != null
                        ? AppColors.primaryBlue
                        : AppColors.mediumGray,
                    fontWeight: parsedCoordinates != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _localizedWizardText(
    TranslationHelper t,
    String key,
    String fallbackPt,
    String fallbackEn,
  ) {
    final translated = t.translate(key);
    if (translated != key) {
      return translated;
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'pt' ? fallbackPt : fallbackEn;
  }

  Future<void> _openCoordinatePicker({
    required TranslationHelper t,
    required String title,
    required TextEditingController controller,
  }) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ProjectCoordinatePickerDialog(
        title: title,
        subtitle: t.translate('map_picker_subtitle'),
        initialValue: controller.text,
        confirmLabel: t.translate('confirm'),
        cancelLabel: t.translate('cancel'),
      ),
    );

    if (result != null) {
      controller.text = result;
      setState(() {});
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📅 TAB 2: FASES DO PROJETO (ATUALIZADO - COM DISPONIBILIDADE DA REDE)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStep2Phases(TranslationHelper t) {
    const phases = ProjectPhaseService.defaultPhases;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('define_project_phases'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          t.translate('phases_optional_explanation'),
          style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
        ),
        const SizedBox(height: 24),

        // ════════════════════════════════════════════════════════════════════
        // 🆕 ADICIONADO: Disponibilidade Estimada da Rede (TOPO DO TAB 2)
        // ════════════════════════════════════════════════════════════════════
        Card(
          color: AppColors.accentTeal.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: AppColors.accentTeal),
                    const SizedBox(width: 12),
                    Text(
                      t.translate('estimated_grid_availability'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _estimatedGridAvailability ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _estimatedGridAvailability = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.borderGray),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _estimatedGridAvailability != null
                              ? _formatDate(_estimatedGridAvailability!)
                              : t.translate('select_date'),
                          style: TextStyle(
                            color: _estimatedGridAvailability != null
                                ? Colors.black
                                : AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.translate('grid_availability_info'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Divider
        const Divider(),
        const SizedBox(height: 16),

        Text(
          t.translate('project_execution_phases'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.mediumGray,
          ),
        ),
        const SizedBox(height: 16),

        // Fases do projeto
        ...phases.map((phaseTemplate) {
          final ordem = phaseTemplate['ordem'] as int;
          final nomeKey = phaseTemplate['nomeKey'] as String;
          final nome = t.translate(nomeKey);
          final obrigatorio = phaseTemplate['obrigatorio'] as bool;
          final isNA = _phasesNA[ordem] ?? false;

          return _buildPhaseInputCard(
            t,
            ordem,
            nome,
            obrigatorio,
            isNA,
          );
        }),
      ],
    );
  }

  Widget _buildPhaseInputCard(
    TranslationHelper t,
    int ordem,
    String nome,
    bool obrigatorio,
    bool isNA,
  ) {
    final startDate = _phasesStartDates[ordem];
    final endDate = _phasesEndDates[ordem];

    return Card(
      key: ValueKey('phase_card_$ordem'),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$ordem. ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mediumGray,
                  ),
                ),
                Expanded(
                  child: Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!obrigatorio)
                  Chip(
                    label: Text(
                      t.translate('optional'),
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor:
                        AppColors.mediumGray.withValues(alpha: 0.2),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            if (!obrigatorio) ...[
              const SizedBox(height: 12),
              SwitchListTile(
                key: ValueKey('switch_na_$ordem'),
                title: Text(
                  t.translate('not_applicable'),
                  style: const TextStyle(fontSize: 14),
                ),
                value: isNA,
                onChanged: (value) {
                  setState(() {
                    _phasesNA[ordem] = value;
                    if (value) {
                      _phasesStartDates[ordem] = null;
                      _phasesEndDates[ordem] = null;
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
            if (!isNA) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      key: ValueKey('start_date_$ordem'),
                      onTap: () => _selectPhaseDate(context, ordem, true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderGray),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              startDate != null
                                  ? _formatDate(startDate)
                                  : t.translate('start_date'),
                              style: TextStyle(
                                color: startDate != null
                                    ? Colors.black
                                    : AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      key: ValueKey('end_date_$ordem'),
                      onTap: () => _selectPhaseDate(context, ordem, false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderGray),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              endDate != null
                                  ? _formatDate(endDate)
                                  : t.translate('end_date'),
                              style: TextStyle(
                                color: endDate != null
                                    ? Colors.black
                                    : AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📋 TAB 3: REVISÃO (ATUALIZADO COM NOVOS CAMPOS)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStep3Review(TranslationHelper t) {
    const phases = ProjectPhaseService.defaultPhases;
    final phasesCompletas = phases.where((p) {
      final ordem = p['ordem'] as int;
      final isNA = _phasesNA[ordem] ?? false;
      final hasStartDate = _phasesStartDates[ordem] != null;
      final hasEndDate = _phasesEndDates[ordem] != null;

      return isNA || (hasStartDate && hasEndDate);
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('review_and_confirm'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Resumo do projeto
        _buildReviewSection(
          t.translate('project_information'),
          [
            '${t.translate('project_name')}: ${_nomeController.text}',
            '${t.translate('project_id')}: ${_projectIdController.text}',
            '${t.translate('location')}: ${_localizacaoController.text.isEmpty ? "-" : _localizacaoController.text}',
            // 🆕 NOVO
            if (_moradaController.text.isNotEmpty)
              '${t.translate('address')}: ${_moradaController.text}',
            // 🆕 NOVO
            if (_coordenadasGPSController.text.isNotEmpty)
              '${t.translate('gps_coordinates')}: ${_coordenadasGPSController.text}',
            if (_coordenadasGPSEscritorioController.text.isNotEmpty)
              '${t.translate('office_gps_coordinates')}: ${_coordenadasGPSEscritorioController.text}',
            '${t.translate('project_manager')}: ${_projectManagerController.text}',
            '${t.translate('site_manager')}: ${_siteManagerController.text}',
            '${t.translate('turbine_type')}: ${_turbineTypeController.text}',
            '${t.translate('foundation_type')}: ${_foundationTypeController.text}',
            // ❌ REMOVIDO: Tower Sections
          ],
        ),
        const SizedBox(height: 16),

        // Resumo das fases
        _buildReviewSection(
          t.translate('project_phases'),
          [
            // 🆕 ADICIONADO
            if (_estimatedGridAvailability != null)
              '${t.translate('estimated_grid_availability')}: ${_formatDate(_estimatedGridAvailability!)}',
            '${t.translate('phases_defined')}: $phasesCompletas / ${phases.length}',
            '${t.translate('phases_na')}: ${_phasesNA.values.where((v) => v).length}',
          ],
        ),
        const SizedBox(height: 24),

        // Aviso
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accentTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.accentTeal.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.accentTeal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.translate('project_creation_info'),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $item',
                    style: const TextStyle(fontSize: 14),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(TranslationHelper t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderGray),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed:
                  _isLoading ? null : () => setState(() => _currentStep--),
              icon: const Icon(Icons.arrow_back),
              label: Text(t.translate('back')),
            )
          else
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: Text(t.translate('cancel')),
            ),
          if (_currentStep < 2)
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleNext,
              icon: const Icon(Icons.arrow_forward),
              label: Text(t.translate('next')),
            )
          else
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleCreateProject,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(
                _isLoading
                    ? t.translate('creating')
                    : t.translate('create_project'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectPhaseDate(
    BuildContext context,
    int ordem,
    bool isStartDate,
  ) async {
    final initialDate = isStartDate
        ? (_phasesStartDates[ordem] ?? DateTime.now())
        : (_phasesEndDates[ordem] ??
            _phasesStartDates[ordem] ??
            DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _phasesStartDates[ordem] = picked;
          if (_phasesEndDates[ordem] != null &&
              _phasesEndDates[ordem]!.isBefore(picked)) {
            _phasesEndDates[ordem] = null;
          }
        } else {
          _phasesEndDates[ordem] = picked;
        }
      });
    }
  }

  void _handleNext() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() => _currentStep++);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 💾 CRIAR PROJETO (ATUALIZADO COM NOVOS CAMPOS)
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _handleCreateProject() async {
    final t = TranslationHelper.of(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final projectService = ref.read(projectServiceProvider);

      // Criar projeto com NOVOS campos
      final newProject = Project(
        id: '',
        userId: user.uid,
        nome: _nomeController.text.trim(),
        projectId: _projectIdController.text.trim(),
        localizacao: _localizacaoController.text.trim().isEmpty
            ? null
            : _localizacaoController.text.trim(),
        morada: _moradaController.text.trim().isEmpty
            ? null
            : _moradaController.text.trim(),
        coordenadasGPS: _coordenadasGPSController.text.trim().isEmpty
            ? null
            : _coordenadasGPSController.text.trim(),
        coordenadasGPSEscritorio:
            _coordenadasGPSEscritorioController.text.trim().isEmpty
                ? null
                : _coordenadasGPSEscritorioController.text.trim(),
        projectManager: _projectManagerController.text.trim(),
        siteManager: _siteManagerController.text.trim(),
        turbineType: _turbineTypeController.text.trim(),
        foundationType: _foundationTypeController.text.trim(),
        estimatedGridAvailability: _estimatedGridAvailability,
        status: 'Planejado',
        totalTurbinas: 0,
        numeroTurbinas:
            0, // 👈 ADICIONE ESTA LINHA PARA RESOLVER O ERRO DE COMPILAÇÃO
        createdAt: DateTime.now(),
        createdBy: user.uid,
      );

      final projectId = await projectService.createProject(newProject);

      // Criar fases com datas personalizadas
      await _createProjectPhasesWithDates(projectId);

      if (mounted) {
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAppFeedback(
            t.translate('project_created_success'),
            type: AppFeedbackType.success,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        showAppFeedback(
          '${t.translate('error')}: $e',
          type: AppFeedbackType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createProjectPhasesWithDates(String projectId) async {
    final phaseService = ref.read(projectPhaseServiceProvider);

    await phaseService.createPhasesWithCustomDates(
      projectId,
      _phasesStartDates,
      _phasesEndDates,
      _phasesNA,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _ProjectCoordinatePickerDialog extends StatefulWidget {
  const _ProjectCoordinatePickerDialog({
    required this.title,
    required this.subtitle,
    required this.initialValue,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String subtitle;
  final String initialValue;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<_ProjectCoordinatePickerDialog> createState() =>
      _ProjectCoordinatePickerDialogState();
}

class _ProjectCoordinatePickerDialogState
    extends State<_ProjectCoordinatePickerDialog> {
  static const LatLng _fallbackCenter = LatLng(39.6, -8.2);

  late final TextEditingController _coordinatesController;
  late final MapController _mapController;
  LatLng? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _coordinatesController = TextEditingController(text: widget.initialValue);
    _mapController = MapController();

    final initialCoordinates =
        MapLauncher.tryParseCoordinates(widget.initialValue);
    if (initialCoordinates != null) {
      _selectedPoint =
          LatLng(initialCoordinates.latitude, initialCoordinates.longitude);
    }
  }

  @override
  void dispose() {
    _coordinatesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final selectedCoordinates =
        MapLauncher.tryParseCoordinates(_coordinatesController.text);

    return Dialog(
      child: SizedBox(
        width: 980,
        height: 720,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined,
                      color: AppColors.primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(color: AppColors.mediumGray),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _selectedPoint ?? _fallbackCenter,
                            initialZoom: _selectedPoint == null ? 6.6 : 12,
                            onTap: (_, point) => _selectPoint(point),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.asbuilt.app',
                            ),
                            if (_selectedPoint != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _selectedPoint!,
                                    width: 60,
                                    height: 60,
                                    child: const Icon(
                                      Icons.location_on,
                                      size: 40,
                                      color: AppColors.errorRed,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _coordinatesController,
                      onChanged: _handleManualCoordinateChange,
                      decoration: const InputDecoration(
                        labelText: 'Latitude, Longitude',
                        hintText: 'Ex: 38.7223, -9.1393',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedCoordinates?.displayValue ??
                          _coordinatesController.text.trim(),
                      style: TextStyle(
                        color: selectedCoordinates != null
                            ? AppColors.primaryBlue
                            : AppColors.mediumGray,
                        fontWeight: selectedCoordinates != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _coordinatesController.clear();
                      setState(() {
                        _selectedPoint = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: Text(
                      _localizedDialogText(
                        t,
                        'clear_selection',
                        'Limpar seleção',
                        'Clear selection',
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(widget.cancelLabel),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(
                          _coordinatesController.text.trim(),
                        ),
                        icon: const Icon(Icons.check),
                        label: Text(widget.confirmLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedDialogText(
    TranslationHelper t,
    String key,
    String fallbackPt,
    String fallbackEn,
  ) {
    final translated = t.translate(key);
    if (translated != key) {
      return translated;
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'pt' ? fallbackPt : fallbackEn;
  }

  void _selectPoint(LatLng point) {
    setState(() {
      _selectedPoint = point;
      _coordinatesController.text =
          MapLauncher.formatCoordinates(point.latitude, point.longitude);
    });
  }

  void _handleManualCoordinateChange(String value) {
    final parsedCoordinates = MapLauncher.tryParseCoordinates(value);
    if (parsedCoordinates == null) {
      setState(() {});
      return;
    }

    final point =
        LatLng(parsedCoordinates.latitude, parsedCoordinates.longitude);
    setState(() {
      _selectedPoint = point;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(point, 12);
    });
  }
}
