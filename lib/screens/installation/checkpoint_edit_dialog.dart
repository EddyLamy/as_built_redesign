import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../i18n/installation_translations.dart';
import '../../models/installation/checkpoint_geral.dart';
import '../../models/installation/tipo_fase.dart'; // ✅ Adicionar import
import '../../services/installation/checkpoint_geral_service.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/installation/final_phase_visuals.dart';

class CheckpointEditDialog extends ConsumerStatefulWidget {
  final CheckpointGeral checkpoint;
  final String turbinaId;

  const CheckpointEditDialog({
    super.key,
    required this.checkpoint,
    required this.turbinaId,
  });

  @override
  ConsumerState<CheckpointEditDialog> createState() =>
      _CheckpointEditDialogState();
}

class _CheckpointEditDialogState extends ConsumerState<CheckpointEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _service = CheckpointGeralService();

  // ✅ Mudado para nullable
  DateTime? _dataInicio;
  DateTime? _dataFim;
  final _observacoesController = TextEditingController();
  List<String> _fotos = []; // ✅ Mudado de fotosUrls para fotos
  bool _isNA = false;
  String? _motivoNA;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dataInicio = widget.checkpoint.dataInicio;
    _dataFim = widget.checkpoint.dataFim;
    _observacoesController.text = widget.checkpoint.observacoes ?? '';
    _fotos = List.from(widget.checkpoint.fotos); // ✅ Mudado
    _isNA = widget.checkpoint.isNA;
    _motivoNA = widget.checkpoint.motivoNA;
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  Color _panelSurface(BuildContext context) {
    final isDark = AppColors.isDarkContext(context);
    return AppColors.adaptivePanelSurface(context).withValues(
      alpha: isDark ? 0.86 : 0.92,
    );
  }

  Color _cardSurface(BuildContext context) {
    final isDark = AppColors.isDarkContext(context);
    return AppColors.adaptiveCardSurface(context).withValues(
      alpha: isDark ? 0.82 : 0.96,
    );
  }

  Color _outline(BuildContext context) => AppColors.adaptiveOutline(context);

  Color _primaryText(BuildContext context) =>
      AppColors.adaptivePrimaryText(context);

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeStringProvider); // ✅ String
    final nomeCheckpoint = widget.checkpoint.tipo.getName(locale);
    final visuals = FinalPhaseVisuals.of(widget.checkpoint.tipo);

    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: visuals.accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(visuals.icon, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nomeCheckpoint,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _isNA,
                        onChanged: (v) => setState(() => _isNA = v),
                        title: Text(
                          InstallationTranslations.getString(
                            'naoAplicavel',
                            locale,
                          ),
                        ),
                        activeThumbColor: visuals.accentColor,
                      ),
                      if (!_isNA) ...[
                        const SizedBox(height: 16),
                        _buildDatePicker(
                          locale,
                          _dataInicio,
                          (d) => setState(() {
                            _dataInicio = d;
                            if (_dataFim != null &&
                                _dataFim!.isBefore(_dataInicio!)) {
                              _dataFim = _dataInicio;
                            }
                          }),
                          true,
                        ),
                        _buildDatePicker(
                          locale,
                          _dataFim,
                          (d) => setState(() => _dataFim = d),
                          false,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _observacoesController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: InstallationTranslations.getString(
                              'observations',
                              locale,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ] else
                        TextFormField(
                          initialValue: _motivoNA ?? '',
                          decoration: InputDecoration(
                            labelText: InstallationTranslations.getString(
                              'motivoNA',
                              locale,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (v) => setState(() => _motivoNA = v),
                          validator: (v) => _isNA && (v == null || v.isEmpty)
                              ? InstallationTranslations.getString(
                                  'motivoObrigatorio',
                                  locale,
                                )
                              : null,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _panelSurface(context),
                border: Border(
                  top: BorderSide(
                    color: visuals.accentColor.withValues(alpha: 0.28),
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${InstallationTranslations.getString('progresso', locale)}: ${_calcularProgresso()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _primaryText(context),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: visuals.accentColor,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            InstallationTranslations.getString(
                              'guardar',
                              locale,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    String locale,
    DateTime? data,
    Function(DateTime) onChanged,
    bool isInicio,
  ) {
    final initialDate = data ??
        ((!isInicio && _dataInicio != null) ? _dataInicio! : DateTime.now());

    return ListTile(
      tileColor: _cardSurface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _outline(context)),
      ),
      leading: Icon(Icons.calendar_today,
          color: FinalPhaseVisuals.of(widget.checkpoint.tipo).accentColor),
      title: Text(isInicio
          ? InstallationTranslations.getString('dataInicio', locale)
          : InstallationTranslations.getString('dataFim', locale)),
      subtitle: Text(_formatDate(data)),
      trailing: const Icon(Icons.edit, size: 20),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (d != null) onChanged(d);
      },
    );
  }

  int _calcularProgresso() {
    if (_isNA) return 100;

    var total = 2;
    var preenchidos = 0;

    if (_dataInicio != null) preenchidos++;
    if (_dataFim != null) preenchidos++;

    if (!widget.checkpoint.fotosNA) {
      total += 1;
      if (_fotos.isNotEmpty) preenchidos++;
    }

    if (!widget.checkpoint.observacoesNA) {
      total += 1;
      if (_observacoesController.text.trim().isNotEmpty) preenchidos++;
    }

    if (total == 0) return 0;
    return ((preenchidos / total) * 100).round();
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final checkpointAtualizado = widget.checkpoint.copyWith(
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        fotos: _fotos, // ✅ Mudado
        observacoes: _observacoesController.text.isEmpty
            ? null
            : _observacoesController.text,
        isNA: _isNA,
        motivoNA: _motivoNA,
        updatedAt: DateTime.now(), // ✅ Adicionar
      );

      // ✅ Verificar nome correto do método no service
      await _service.updateCheckpoint(
          widget.checkpoint.id, checkpointAtualizado);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atualizado!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
