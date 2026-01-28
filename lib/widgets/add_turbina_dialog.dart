import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_providers.dart';
import '../../core/localization/translation_helper.dart';

class AddTurbinaDialog extends ConsumerStatefulWidget {
  final String projectId;

  const AddTurbinaDialog({super.key, required this.projectId});

  @override
  ConsumerState<AddTurbinaDialog> createState() => _AddTurbinaDialogState();
}

class _AddTurbinaDialogState extends ConsumerState<AddTurbinaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _localizacaoController = TextEditingController();

  int? _sequenceNumber;
  int _numberOfMiddleSections = 3; // 🆕 NOVO: Default 3 middle sections
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNextSequence();
  }

  Future<void> _loadNextSequence() async {
    final turbinaService = ref.read(turbinaServiceProvider);
    final nextSeq = await turbinaService.getProximoNumeroSequencia(
      widget.projectId,
    );
    setState(() {
      _sequenceNumber = nextSeq;
      _nomeController.text = 'WTG-${nextSeq.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _localizacaoController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final t = TranslationHelper.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_sequenceNumber == null) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not logged in');

      final turbinaService = ref.read(turbinaServiceProvider);
      final projectService = ref.read(projectServiceProvider);

      // 🆕 Criar turbina com numberOfMiddleSections
      final turbinaId = await turbinaService.createTurbinaComComponentes(
        projectId: widget.projectId,
        nome: _nomeController.text.trim(),
        sequenceNumber: _sequenceNumber!,
        localizacao: _localizacaoController.text.trim().isEmpty
            ? null
            : _localizacaoController.text.trim(),
        userId: user.uid,
        numberOfMiddleSections: _numberOfMiddleSections, // 🆕 PASSAR O VALOR
      );

      // Incrementar contador de turbinas no projeto
      await projectService.incrementTotalTurbinas(widget.projectId);

      if (mounted) {
        Navigator.of(context).pop(turbinaId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${t.translate('turbina_created_success')}: "${_nomeController.text}" ($_numberOfMiddleSections ${t.translate('middle_sections')})!',
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.translate('error')}: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.wind_power, color: AppColors.accentTeal),
          SizedBox(width: 12),
          Text(t.translate('add_turbina_title')),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_sequenceNumber == null)
                CircularProgressIndicator()
              else ...[
                // ════════════════════════════════════════════════════════════
                // Campo: Nome da Turbina
                // ════════════════════════════════════════════════════════════
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: '${t.translate('turbine_name')} *',
                    hintText: t.translate('turbine_name_hint'),
                    prefixIcon: Icon(Icons.wind_power),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? t.translate('required_field')
                      : null,
                ),
                SizedBox(height: 16),

                // ════════════════════════════════════════════════════════════
                // Campo: Sequência (disabled - auto)
                // ════════════════════════════════════════════════════════════
                TextFormField(
                  enabled: false,
                  initialValue: '${t.translate('sequence')}: $_sequenceNumber',
                  decoration: InputDecoration(
                    labelText: t.translate('installation_sequence'),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                ),
                SizedBox(height: 16),

                // ════════════════════════════════════════════════════════════
                // 🆕 NOVO: NUMBER OF MIDDLE SECTIONS
                // ════════════════════════════════════════════════════════════
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.translate('number_of_middle_sections')} *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGray,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderGray),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.layers,
                              color: AppColors.primaryBlue, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _numberOfMiddleSections,
                                isExpanded: true,
                                items: [1, 2, 3, 4, 5, 6].map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(
                                      '$value ${t.translate('middle_section')}${value > 1 ? 's' : ''}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _numberOfMiddleSections = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      t.translate('middle_sections_info'),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mediumGray,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // ════════════════════════════════════════════════════════════
                // Campo: Localização (opcional)
                // ════════════════════════════════════════════════════════════
                TextFormField(
                  controller: _localizacaoController,
                  decoration: InputDecoration(
                    labelText: t.translate('location_optional'),
                    hintText: t.translate('location_hint_turbine'),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                SizedBox(height: 16),

                // ════════════════════════════════════════════════════════════
                // Info: Componentes criados automaticamente
                // ════════════════════════════════════════════════════════════
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accentTeal.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.accentTeal,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.translate('components_auto_created'),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accentTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(t.translate('cancel')),
        ),
        ElevatedButton.icon(
          onPressed:
              _isLoading || _sequenceNumber == null ? null : _handleCreate,
          icon: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Icon(Icons.add),
          label: Text(_isLoading
              ? t.translate('creating')
              : t.translate('create_turbine')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }
}
