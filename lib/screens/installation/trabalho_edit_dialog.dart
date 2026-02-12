import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../i18n/installation_translations.dart';
import '../../models/installation/trabalho_ligacao.dart';
import '../../services/installation/trabalho_ligacao_service.dart';
import '../../models/installation/tipo_fase.dart';
import '../../providers/locale_provider.dart';

class TrabalhoEditDialog extends ConsumerStatefulWidget {
  final TrabalhoLigacao trabalho;
  final String turbinaId;

  const TrabalhoEditDialog({
    super.key,
    required this.trabalho,
    required this.turbinaId,
  });

  @override
  ConsumerState<TrabalhoEditDialog> createState() => _TrabalhoEditDialogState();
}

class _TrabalhoEditDialogState extends ConsumerState<TrabalhoEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _service = TrabalhoLigacaoService();

  DateTime? _dataInicio;
  DateTime? _dataFim;
  TipoTrabalhoMecanico? _tipo;
  final _observacoesController = TextEditingController();
  List<String> _fotosUrls = [];
  bool _isNA = false;
  String? _motivoNA;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dataInicio = widget.trabalho.dataInicio;
    _dataFim = widget.trabalho.dataFim;
    _tipo = widget.trabalho.tipo;
    _observacoesController.text = widget.trabalho.observacoes ?? '';
    _fotosUrls = List.from(widget.trabalho.fotos);
    _isNA = widget.trabalho.isNA;
    _motivoNA = widget.trabalho.motivoNA;
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final t = InstallationTranslations.translations[locale]!;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(t),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info do trabalho
                      _buildTrabalhoInfo(t),

                      const SizedBox(height: 16),

                      // Botão N/A
                      _buildNASwitch(t),

                      if (!_isNA) ...[
                        const SizedBox(height: 16),
                        _buildDataFields(t),
                        const SizedBox(height: 16),
                        _buildTipoSelector(t),
                        const SizedBox(height: 16),
                        _buildObservacoesField(t),
                      ] else ...[
                        const SizedBox(height: 16),
                        _buildMotivoNAField(t),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            _buildFooter(t),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orange,
      child: Row(
        children: [
          const Icon(Icons.link, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t['trabalhoMecanico'] ?? 'Trabalho Mecânico',
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
    );
  }

  Widget _buildTrabalhoInfo(Map<String, String> t) {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t['ligacao'] ?? 'Ligação',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.trabalho.componenteA,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.orange),
                Expanded(
                  child: Text(
                    widget.trabalho.componenteB,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNASwitch(Map<String, String> t) {
    return SwitchListTile(
      value: _isNA,
      onChanged: (value) {
        setState(() {
          _isNA = value;
        });
      },
      title: Text(
        t['naoAplicavel'] ?? 'Não Aplicável (N/A)',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      activeThumbColor: Colors.orange,
    );
  }

  Widget _buildDataFields(Map<String, String> t) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today, color: Colors.orange),
          title: Text(t['dataInicio'] ?? 'Data Início'),
          subtitle: Text(_formatDate(_dataInicio)),
          trailing: const Icon(Icons.edit, size: 20),
          onTap: () async {
            final data = await showDatePicker(
              context: context,
              initialDate: _dataInicio ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (data != null) {
              setState(() {
                _dataInicio = data;
                if (_dataFim != null && _dataFim!.isBefore(_dataInicio!)) {
                  _dataFim = _dataInicio;
                }
              });
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.event, color: Colors.orange),
          title: Text(t['dataFim'] ?? 'Data Fim'),
          subtitle: Text(_formatDate(_dataFim)),
          trailing: const Icon(Icons.edit, size: 20),
          onTap: () async {
            final data = await showDatePicker(
              context: context,
              initialDate: _dataFim ?? DateTime.now(),
              firstDate: _dataInicio ?? DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (data != null) {
              setState(() {
                _dataFim = data;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildTipoSelector(Map<String, String> t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t['tipoTrabalho'] ?? 'Tipo de Trabalho',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        RadioListTile<TipoTrabalhoMecanico>(
          value: TipoTrabalhoMecanico.torque,
          groupValue: _tipo,
          onChanged: (value) {
            setState(() {
              _tipo = value;
            });
          },
          title: Text(t['torque'] ?? 'Torque'),
          secondary: const Icon(Icons.build, color: Colors.blue),
        ),
        RadioListTile<TipoTrabalhoMecanico>(
          value: TipoTrabalhoMecanico.tensionamento,
          groupValue: _tipo,
          onChanged: (value) {
            setState(() {
              _tipo = value;
            });
          },
          title: Text(t['tensionamento'] ?? 'Tensionamento'),
          secondary: const Icon(Icons.compress, color: Colors.purple),
        ),
      ],
    );
  }

  Widget _buildObservacoesField(Map<String, String> t) {
    return TextFormField(
      controller: _observacoesController,
      decoration: InputDecoration(
        labelText: t['observacoes'] ?? 'Observações',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.notes),
      ),
      maxLines: 3,
    );
  }

  Widget _buildMotivoNAField(Map<String, String> t) {
    return TextFormField(
      initialValue: _motivoNA ?? '',
      decoration: InputDecoration(
        labelText: t['motivoNA'] ?? 'Motivo N/A',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.info_outline),
      ),
      maxLines: 3,
      onChanged: (value) {
        _motivoNA = value;
      },
      validator: (value) {
        if (_isNA && (value == null || value.isEmpty)) {
          return t['motivoObrigatorio'] ?? 'Motivo obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildFooter(Map<String, String> t) {
    return Container(
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
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t['cancelar'] ?? 'Cancelar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSaving ? null : _guardar,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  int _calcularProgresso() {
    if (_isNA) return 100;

    int total = 3; // dataInicio + dataFim + tipo
    int preenchidos = 2; // datas já preenchidas

    if (_tipo != null) preenchidos++;

    return ((preenchidos / total) * 100).round();
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final trabalhoAtualizado = widget.trabalho.copyWith(
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        tipo: _tipo,
        fotos: _fotosUrls,
        observacoes: _observacoesController.text.isEmpty
            ? null
            : _observacoesController.text,
        isNA: _isNA,
        motivoNA: _motivoNA,
      );

      await _service.updateTrabalho(widget.trabalho.id, trabalhoAtualizado);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trabalho atualizado!'),
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
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
