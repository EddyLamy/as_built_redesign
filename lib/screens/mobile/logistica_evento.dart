// screens/mobile/logistica_form_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/localization/translation_helper.dart';

class LogisticaFormScreen extends StatefulWidget {
  final String turbineId;
  const LogisticaFormScreen({super.key, required this.turbineId});

  @override
  State<LogisticaFormScreen> createState() => _LogisticaFormScreenState();
}

class _LogisticaFormScreenState extends State<LogisticaFormScreen> {
  String _tipoSelecionado = 'trabalho';
  DateTime _dataInicio = DateTime.now();
  DateTime _dataFim = DateTime.now().add(const Duration(hours: 1));
  String? _motivoSelecionado;
  final _obsController = TextEditingController();
  final _origemController = TextEditingController();
  final _destinoController = TextEditingController();

  Future<void> _pickDateTime(bool isInicio) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      final finalDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isInicio) {
        _dataInicio = finalDate;
      } else {
        _dataFim = finalDate;
      }
    });
  }

  void _salvar() async {
    await FirebaseFirestore.instance
        .collection('turbinas')
        .doc(widget.turbineId)
        .collection('logistica')
        .add({
      'tipo': _tipoSelecionado,
      'inicio': Timestamp.fromDate(_dataInicio),
      'fim': Timestamp.fromDate(_dataFim),
      'motivo': _motivoSelecionado,
      'origem': _origemController.text,
      'destino': _destinoController.text,
      'observacoes': _obsController.text,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('register_activity'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _tipoSelecionado,
            items: [
              'mobilizacao',
              'trabalho',
              'paragem',
              'transferencia',
              'desmobilizacao'
            ]
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(t.translate(e))))
                .toList(),
            onChanged: (v) => setState(() => _tipoSelecionado = v!),
            decoration:
                InputDecoration(labelText: t.translate('activity_type')),
          ),
          ListTile(
            title: Text(t.translate('start')),
            subtitle: Text(_dataInicio.toString()),
            onTap: () => _pickDateTime(true),
          ),
          ListTile(
            title: Text(t.translate('end')),
            subtitle: Text(_dataFim.toString()),
            onTap: () => _pickDateTime(false),
          ),
          if (_tipoSelecionado == 'paragem')
            DropdownButtonFormField<String>(
              items: ['wind', 'mechanical', 'waiting_components', 'safety']
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(t.translate(e))))
                  .toList(),
              onChanged: (v) => setState(() => _motivoSelecionado = v),
              decoration: InputDecoration(labelText: t.translate('reason')),
            ),
          if (_tipoSelecionado == 'transferencia') ...[
            TextField(
                controller: _origemController,
                decoration:
                    InputDecoration(labelText: t.translate('origin_pad'))),
            TextField(
                controller: _destinoController,
                decoration:
                    InputDecoration(labelText: t.translate('destination_pad'))),
          ],
          TextField(
              controller: _obsController,
              decoration: InputDecoration(labelText: t.translate('notes')),
              maxLines: 3),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _salvar, child: Text(t.translate('save'))),
        ],
      ),
    );
  }
}
