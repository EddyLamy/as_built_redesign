import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../mobile/photo_picker_widget.dart';

/// Formulário de Receção (Mobile)
class ReceptionForm extends ConsumerStatefulWidget {
  final String turbinaId;
  final String componentId;

  const ReceptionForm({
    super.key,
    required this.turbinaId,
    required this.componentId,
  });

  @override
  ConsumerState<ReceptionForm> createState() => _ReceptionFormState();
}

class _ReceptionFormState extends ConsumerState<ReceptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _vuiController = TextEditingController();
  final _serialController = TextEditingController();
  final _itemController = TextEditingController();

  DateTime? _dataDescarga;
  TimeOfDay? _horaDescarga;
  List<String> _photoUrls = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _vuiController.dispose();
    _serialController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('installation_data')
          .doc(widget.turbinaId)
          .collection('components')
          .doc(widget.componentId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final reception = data?['reception'] as Map<String, dynamic>?;

        if (reception != null) {
          setState(() {
            _vuiController.text = reception['vui'] ?? '';
            _serialController.text = reception['serialNumber'] ?? '';
            _itemController.text = reception['itemNumber'] ?? '';

            if (reception['dataInicio'] != null) {
              _dataDescarga = (reception['dataInicio'] as Timestamp).toDate();
              _horaDescarga = TimeOfDay.fromDateTime(_dataDescarga!);
            }

            _photoUrls = List<String>.from(reception['photos'] ?? []);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataDescarga == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecione a data de descarga'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Combinar data e hora
      final dataCompleta = DateTime(
        _dataDescarga!.year,
        _dataDescarga!.month,
        _dataDescarga!.day,
        _horaDescarga?.hour ?? 0,
        _horaDescarga?.minute ?? 0,
      );

      await FirebaseFirestore.instance
          .collection('installation_data')
          .doc(widget.turbinaId)
          .collection('components')
          .doc(widget.componentId)
          .set({
        'reception': {
          'vui': _vuiController.text.trim(),
          'serialNumber': _serialController.text.trim(),
          'itemNumber': _itemController.text.trim(),
          'dataInicio': Timestamp.fromDate(dataCompleta),
          'photos': _photoUrls,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados salvos com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // VUI
            TextFormField(
              controller: _vuiController,
              decoration: const InputDecoration(
                labelText: 'VUI',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),

            // Serial Number
            TextFormField(
              controller: _serialController,
              decoration: const InputDecoration(
                labelText: 'Serial Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),

            // Item Number
            TextFormField(
              controller: _itemController,
              decoration: const InputDecoration(
                labelText: 'Item Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),

            // Data Descarga
            ListTile(
              title: const Text('Data Descarga'),
              subtitle: Text(
                _dataDescarga != null
                    ? '${_dataDescarga!.day}/${_dataDescarga!.month}/${_dataDescarga!.year}'
                    : 'Não selecionada',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dataDescarga ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _dataDescarga = date);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.borderGray),
              ),
            ),
            const SizedBox(height: 16),

            // Hora Descarga
            ListTile(
              title: const Text('Hora Descarga'),
              subtitle: Text(
                _horaDescarga != null
                    ? '${_horaDescarga!.hour.toString().padLeft(2, '0')}:${_horaDescarga!.minute.toString().padLeft(2, '0')}'
                    : 'Não selecionada',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _horaDescarga ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _horaDescarga = time);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.borderGray),
              ),
            ),
            const SizedBox(height: 24),

            // Photo Picker
            PhotoPickerWidget(
              photoUrls: _photoUrls,
              onPhotosChanged: (urls) {
                setState(() => _photoUrls = urls);
              },
              turbinaId: widget.turbinaId,
              componentId: widget.componentId,
              phase: 'reception',
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'GUARDAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
