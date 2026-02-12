import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';

class LogisticaFormScreen extends StatefulWidget {
  final String turbineId;
  final String turbineName;
  final Map<String, dynamic>? initialData;
  final String? docId;

  const LogisticaFormScreen({
    super.key,
    required this.turbineId,
    required this.turbineName,
    this.initialData,
    this.docId,
  });

  @override
  State<LogisticaFormScreen> createState() => _LogisticaFormScreenState();
}

class _LogisticaFormScreenState extends State<LogisticaFormScreen> {
  String _tipo = 'trabalho';
  DateTime _inicio = DateTime.now();
  DateTime _fim = DateTime.now().add(const Duration(hours: 2));
  String? _motivo;
  final _origemController = TextEditingController();
  final _destinoController = TextEditingController();
  final _obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _tipo = widget.initialData!['tipo'] ?? 'trabalho';
      _inicio = (widget.initialData!['inicio'] as Timestamp).toDate();
      _fim = (widget.initialData!['fim'] as Timestamp).toDate();
      _motivo = widget.initialData!['motivo'];
      _origemController.text = widget.initialData!['origem'] ?? '';
      _destinoController.text = widget.initialData!['destino'] ?? '';
      _obsController.text = widget.initialData!['observacoes'] ?? '';
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _inicio : _fim,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _inicio : _fim),
    );
    if (time == null) return;

    setState(() {
      final dt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        _inicio = dt;
      } else {
        _fim = dt;
      }
    });
  }

  void _save() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final Map<String, dynamic> data = {
        'tipo': _tipo,
        'inicio': Timestamp.fromDate(_inicio),
        'fim': Timestamp.fromDate(_fim),
        'motivo': _motivo,
        'origem': _origemController.text,
        'destino': _destinoController.text,
        'observacoes': _obsController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final collection = FirebaseFirestore.instance
          .collection('turbinas')
          .doc(widget.turbineId)
          .collection('logistica_gruas');

      if (widget.docId != null) {
        await collection.doc(widget.docId).update(data);
      } else {
        await collection.add(data);
      }

      if (mounted) {
        Navigator.pop(context); // Fecha o loading
        Navigator.pop(context); // Volta para a lista
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.docId != null
                ? "Registo atualizado"
                : "Registo guardado"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId != null
            ? '${t.translate('edit')} - ${widget.turbineName}'
            : '${t.translate('logistics_crane')} - ${widget.turbineName}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _tipo,
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
            onChanged: (v) => setState(() => _tipo = v!),
            decoration:
                InputDecoration(labelText: t.translate('activity_type')),
          ),
          const SizedBox(height: 16),
          _buildDateTimePicker(
              t.translate('start'), _inicio, () => _pickDateTime(true)),
          const SizedBox(height: 8),
          _buildDateTimePicker(
              t.translate('end'), _fim, () => _pickDateTime(false)),
          if (_tipo == 'paragem') ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _motivo, // Garante que o valor selecionado aparece
              items: ['wind', 'mechanical', 'waiting_components', 'safety']
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(t.translate(e))))
                  .toList(),
              onChanged: (v) => setState(() => _motivo = v),
              decoration: InputDecoration(labelText: t.translate('reason')),
            ),
          ],
          if (_tipo == 'transferencia') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _origemController,
              decoration: InputDecoration(labelText: t.translate('origin_pad')),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _destinoController,
              decoration:
                  InputDecoration(labelText: t.translate('destination_pad')),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _obsController,
            decoration: InputDecoration(labelText: t.translate('notes')),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _save,
              child: Text(t.translate('save'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker(
      String label, DateTime value, VoidCallback onTap) {
    return ListTile(
      tileColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title:
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(
        "${value.day}/${value.month}/${value.year}  ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}",
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      trailing: const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
      onTap: onTap,
    );
  }
}
