import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../i18n/installation_translations.dart';
import '../../models/installation/trabalho_drivetrain.dart';
import '../../services/installation/trabalho_drivetrain_service.dart';
import '../../providers/locale_provider.dart';

class DriveTrainEditDialog extends ConsumerStatefulWidget {
  final TrabalhoDriveTrain trabalho;
  final String turbinaId;

  const DriveTrainEditDialog({
    super.key,
    required this.trabalho,
    required this.turbinaId,
  });

  @override
  ConsumerState<DriveTrainEditDialog> createState() =>
      _DriveTrainEditDialogState();
}

class _DriveTrainEditDialogState extends ConsumerState<DriveTrainEditDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _service = TrabalhoDriveTrainService();
  late TabController _tabController;

  // Shared dates - USAR AS MESMAS PARA AMBOS
  DateTime? _dataInicio;
  DateTime? _dataFim;

  // Torque
  final _observacoesTorqueController = TextEditingController();
  List<String> _fotosTorque = [];
  bool _torqueNA = false;
  String? _motivoNATorque;

  // Tensionamento
  final _observacoesTensionamentoController = TextEditingController();
  List<String> _fotosTensionamento = [];
  bool _tensionamentoNA = false;
  String? _motivoNATensionamento;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Inicializar dados compartilhados
    _dataInicio = widget.trabalho.dataInicio;
    _dataFim = widget.trabalho.dataFim;

    // Inicializar Torque
    _observacoesTorqueController.text = widget.trabalho.observacoesTorque ?? '';
    _fotosTorque = List.from(widget.trabalho.fotosTorque);
    _torqueNA = widget.trabalho.torqueNA;
    // ✅ REMOVER esta linha - campo não existe no modelo
    // _motivoNATorque = widget.trabalho.motivoNATorque;

    // Inicializar Tensionamento
    _observacoesTensionamentoController.text =
        widget.trabalho.observacoesTensionamento ?? '';
    _fotosTensionamento = List.from(widget.trabalho.fotosTensionamento);
    _tensionamentoNA = widget.trabalho.tensionamentoNA;
    // ✅ REMOVER esta linha - campo não existe no modelo
    // _motivoNATensionamento = widget.trabalho.motivoNATensionamento;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _observacoesTorqueController.dispose();
    _observacoesTensionamentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final t = InstallationTranslations.translations[locale]!;

    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            _buildHeader(t),
            _buildTabs(t),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTorqueTab(t),
                  _buildTensionamentoTab(t),
                ],
              ),
            ),
            _buildFooter(t),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.purple,
      child: Row(
        children: [
          Icon(Icons.settings, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Drive Train',
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

  Widget _buildTabs(Map<String, String> t) {
    return Container(
      color: Colors.purple,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          Tab(icon: Icon(Icons.build), text: t['torque'] ?? 'Torque'),
          Tab(
            icon: Icon(Icons.compress),
            text: t['tensionamento'] ?? 'Tensionamento',
          ),
        ],
      ),
    );
  }

  Widget _buildTorqueTab(Map<String, String> t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SwitchListTile(
              value: _torqueNA,
              onChanged: (v) => setState(() => _torqueNA = v),
              title: Text(t['naoAplicavel'] ?? 'Não Aplicável'),
              activeThumbColor: Colors.purple,
            ),
            // ✅ ADICIONAR const SizedBox antes do if
            const SizedBox(height: 16),
            if (!_torqueNA) ...[
              _buildDatePicker(
                t,
                _dataInicio ?? DateTime.now(),
                (d) => setState(() {
                  _dataInicio = d;
                  if (_dataFim != null && _dataFim!.isBefore(_dataInicio!)) {
                    _dataFim = _dataInicio;
                  }
                }),
                true,
              ),
              _buildDatePicker(
                t,
                _dataFim ?? _dataInicio ?? DateTime.now(),
                (d) => setState(() => _dataFim = d),
                false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacoesTorqueController,
                decoration: InputDecoration(
                  labelText: t['observacoes'],
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ] else
              TextFormField(
                initialValue: _motivoNATorque ?? '',
                decoration: InputDecoration(
                  labelText: t['motivoNA'],
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _motivoNATorque = v,
                validator: (v) => _torqueNA && (v == null || v.isEmpty)
                    ? t['motivoObrigatorio']
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTensionamentoTab(Map<String, String> t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SwitchListTile(
            value: _tensionamentoNA,
            onChanged: (v) => setState(() => _tensionamentoNA = v),
            title: Text(t['naoAplicavel'] ?? 'Não Aplicável'),
            activeThumbColor: Colors.purple,
          ),
          // ✅ ADICIONAR const SizedBox antes do if
          const SizedBox(height: 16),
          if (!_tensionamentoNA) ...[
            _buildDatePicker(
              t,
              _dataInicio ?? DateTime.now(),
              (d) => setState(() {
                _dataInicio = d;
                if (_dataFim != null && _dataFim!.isBefore(_dataInicio!)) {
                  _dataFim = _dataInicio;
                }
              }),
              true,
            ),
            _buildDatePicker(
              t,
              _dataFim ?? _dataInicio ?? DateTime.now(),
              (d) => setState(() => _dataFim = d),
              false,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacoesTensionamentoController,
              decoration: InputDecoration(
                labelText: t['observacoes'],
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ] else
            TextFormField(
              initialValue: _motivoNATensionamento ?? '',
              decoration: InputDecoration(
                labelText: t['motivoNA'],
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _motivoNATensionamento = v,
              validator: (v) => _tensionamentoNA && (v == null || v.isEmpty)
                  ? t['motivoObrigatorio']
                  : null,
            ),
        ],
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
      leading: Icon(Icons.calendar_today, color: Colors.purple),
      title: Text(isInicio
          ? (t['dataInicio'] ?? 'Data Início')
          : (t['dataFim'] ?? 'Data Fim')),
      subtitle: Text(_formatDate(data)),
      trailing: Icon(Icons.edit, size: 20),
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
          ElevatedButton(
            onPressed: _isSaving ? null : _guardar,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(t['guardar'] ?? 'Guardar'),
          ),
        ],
      ),
    );
  }

  int _calcularProgresso() {
    int progressoTorque = _torqueNA ? 100 : 100;
    int progressoTensionamento = _tensionamentoNA ? 100 : 100;
    return ((progressoTorque + progressoTensionamento) / 2).round();
  }

  void _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final trabalhoAtualizado = widget.trabalho.copyWith(
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        observacoesTorque: _observacoesTorqueController.text.isEmpty
            ? null
            : _observacoesTorqueController.text,
        fotosTorque: _fotosTorque,
        torqueNA: _torqueNA,
        observacoesTensionamento:
            _observacoesTensionamentoController.text.isEmpty
                ? null
                : _observacoesTensionamentoController.text,
        fotosTensionamento: _fotosTensionamento,
        tensionamentoNA: _tensionamentoNA,
      );

      await _service.updateTrabalho(
        widget.trabalho.id,
        trabalhoAtualizado,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
