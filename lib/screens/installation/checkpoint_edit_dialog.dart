import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../i18n/installation_translations.dart';
import '../../models/installation/checkpoint_geral.dart';
import '../../models/installation/tipo_fase.dart'; // ✅ Adicionar import
import '../../services/installation/checkpoint_geral_service.dart';
import '../../providers/locale_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeStringProvider); // ✅ String
    final t = InstallationTranslations.translations[locale]!;
    final nomeCheckpoint = _getNomeCheckpoint(widget.checkpoint.tipo, t);

    return Dialog(
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
              color: Colors.green,
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
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
                        title: Text(t['naoAplicavel'] ?? 'Não Aplicável'),
                        activeThumbColor: Colors.green,
                      ),
                      if (!_isNA) ...[
                        const SizedBox(height: 16),
                        _buildDatePicker(
                          t,
                          _dataInicio ?? DateTime.now(), // ✅ Handle null
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
                          t,
                          _dataFim ??
                              _dataInicio ??
                              DateTime.now(), // ✅ Handle null
                          (d) => setState(() => _dataFim = d),
                          false,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _observacoesController,
                          decoration: InputDecoration(
                            labelText: t['observacoes'],
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ] else
                        TextFormField(
                          initialValue: _motivoNA ?? '',
                          decoration: InputDecoration(
                            labelText: t['motivoNA'],
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (v) => _motivoNA = v,
                          validator: (v) => _isNA && (v == null || v.isEmpty)
                              ? t['motivoObrigatorio']
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
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${t['progresso']}: ${_calcularProgresso()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t['guardar'] ?? 'Guardar'),
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
    Map<String, String> t,
    DateTime data,
    Function(DateTime) onChanged,
    bool isInicio,
  ) {
    return ListTile(
      leading: const Icon(Icons.calendar_today, color: Colors.green),
      title: Text(isInicio
          ? (t['dataInicio'] ?? 'Data Início')
          : (t['dataFim'] ?? 'Data Fim')),
      subtitle: Text(_formatDate(data)),
      trailing: const Icon(Icons.edit, size: 20),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: data,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (d != null) onChanged(d);
      },
    );
  }

  // ✅ Mudado de TipoCheckpoint para TipoFase
  String _getNomeCheckpoint(TipoFase tipo, Map<String, String> t) {
    switch (tipo) {
      case TipoFase.eletricos:
        return t['checkpointEletricos'] ?? 'Checkpoint Elétricos';
      case TipoFase.mecanicosGerais:
        return t['checkpointMecanicos'] ?? 'Checkpoint Mecânicos';
      case TipoFase.finish:
        return 'Finish';
      case TipoFase.inspecaoSupervisor:
        return t['inspecaoSupervisor'] ?? 'Inspeção Supervisor';
      case TipoFase.punchlist:
        return 'Punch-List';
      case TipoFase.inspecaoCliente:
        return t['inspecaoCliente'] ?? 'Inspeção Cliente';
      case TipoFase.punchlistCliente:
        return 'Punch-List Cliente';
      default:
        return tipo.name;
    }
  }

  int _calcularProgresso() => _isNA ? 100 : 100; // Simplificado

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
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
