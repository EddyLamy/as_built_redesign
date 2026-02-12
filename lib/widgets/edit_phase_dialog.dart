import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/localization/translation_helper.dart';
import '../models/project_phase.dart';
import '../providers/app_providers.dart';

class EditPhaseDialog extends ConsumerStatefulWidget {
  final String projectId;
  final ProjectPhase phase;

  const EditPhaseDialog({
    super.key,
    required this.projectId,
    required this.phase,
  });

  @override
  ConsumerState<EditPhaseDialog> createState() => _EditPhaseDialogState();
}

class _EditPhaseDialogState extends ConsumerState<EditPhaseDialog> {
  DateTime? _dataInicio;
  DateTime? _dataFim;
  bool _aplicavel = true;
  final _observacoesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dataInicio = widget.phase.dataInicio;
    _dataFim = widget.phase.dataFim;
    _aplicavel = widget.phase.aplicavel;
    _observacoesController.text = widget.phase.observacoes ?? '';
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final isNA = !_aplicavel;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.translate(widget.phase.nomeKey ?? widget.phase.nome),
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  '${t.translate('phase')} ${widget.phase.ordem}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle N/A (só se não for obrigatório)
              if (!widget.phase.obrigatorio) ...[
                Card(
                  color: isNA
                      ? AppColors.mediumGray.withOpacity(0.1)
                      : AppColors.primaryBlue.withOpacity(0.05),
                  child: SwitchListTile(
                    title: Text(
                      t.translate('not_applicable'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      isNA
                          ? t.translate('phase_marked_na')
                          : t.translate('mark_phase_na_if_not_needed'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: isNA,
                    onChanged: (value) {
                      setState(() {
                        _aplicavel = !value;
                        if (value) {
                          // Marcar N/A limpa as datas
                          _dataInicio = null;
                          _dataFim = null;
                        }
                      });
                    },
                    activeThumbColor: AppColors.mediumGray,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Campos de data (disabled se N/A)
              Opacity(
                opacity: isNA ? 0.5 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data Início
                    Text(
                      '${t.translate('start_date')} *',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: isNA ? null : () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isNA
                                ? AppColors.borderGray
                                : AppColors.primaryBlue,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: isNA
                                  ? AppColors.mediumGray
                                  : AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _dataInicio != null
                                  ? _formatDate(_dataInicio!)
                                  : t.translate('select_date'),
                              style: TextStyle(
                                color: _dataInicio != null
                                    ? Colors.black
                                    : AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Data Fim
                    Text(
                      '${t.translate('end_date')} *',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: isNA ? null : () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isNA
                                ? AppColors.borderGray
                                : AppColors.primaryBlue,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: isNA
                                  ? AppColors.mediumGray
                                  : AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _dataFim != null
                                  ? _formatDate(_dataFim!)
                                  : t.translate('select_date'),
                              style: TextStyle(
                                color: _dataFim != null
                                    ? Colors.black
                                    : AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Observações
              Text(
                t.translate('notes'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _observacoesController,
                decoration: InputDecoration(
                  hintText: t.translate('add_notes_optional'),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(t.translate('cancel')),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(t.translate('save')),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? (_dataInicio ?? DateTime.now())
        : (_dataFim ?? _dataInicio ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _dataInicio = picked;
          // Se data fim for anterior à início, ajustar
          if (_dataFim != null && _dataFim!.isBefore(picked)) {
            _dataFim = null;
          }
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    final t = TranslationHelper.of(context);

    // Validação: se aplicável, precisa das 2 datas
    if (_aplicavel && _dataInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate('phase_dates_required')),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phaseService = ref.read(projectPhaseServiceProvider);

      await phaseService.updatePhase(
        widget.projectId,
        widget.phase.id,
        {
          'dataInicio': _dataInicio,
          'dataFim': _dataFim,
          'aplicavel': _aplicavel,
          'observacoes': _observacoesController.text.trim().isEmpty
              ? null
              : _observacoesController.text.trim(),
        },
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('phase_updated_success')),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.translate('error')}: $e'),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
