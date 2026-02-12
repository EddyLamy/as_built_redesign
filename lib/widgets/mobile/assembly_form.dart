import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import 'photo_picker_widget.dart';

/// Formulário de Assemblagem (Mobile)
class AssemblyForm extends ConsumerStatefulWidget {
  final String turbinaId;
  final String componentId;

  const AssemblyForm({
    super.key,
    required this.turbinaId,
    required this.componentId,
  });

  @override
  ConsumerState<AssemblyForm> createState() => _AssemblyFormState();
}

class _AssemblyFormState extends ConsumerState<AssemblyForm> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _dataInicio;
  TimeOfDay? _horaInicio;
  DateTime? _dataFim;
  TimeOfDay? _horaFim;
  List<String> _photoUrls = [];

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
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
        final phase = data?['assembly'] as Map<String, dynamic>?;

        if (phase != null) {
          setState(() {
            if (phase['dataInicio'] != null) {
              _dataInicio = (phase['dataInicio'] as Timestamp).toDate();
              _horaInicio = TimeOfDay.fromDateTime(_dataInicio!);
            }

            if (phase['dataFim'] != null) {
              _dataFim = (phase['dataFim'] as Timestamp).toDate();
              _horaFim = TimeOfDay.fromDateTime(_dataFim!);
            }

            _photoUrls = List<String>.from(phase['photos'] ?? []);
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

    if (_dataInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecione a data de início'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dataInicioCompleta = DateTime(
        _dataInicio!.year,
        _dataInicio!.month,
        _dataInicio!.day,
        _horaInicio?.hour ?? 0,
        _horaInicio?.minute ?? 0,
      );

      DateTime? dataFimCompleta;
      if (_dataFim != null) {
        dataFimCompleta = DateTime(
          _dataFim!.year,
          _dataFim!.month,
          _dataFim!.day,
          _horaFim?.hour ?? 0,
          _horaFim?.minute ?? 0,
        );
      }

      await FirebaseFirestore.instance
          .collection('installation_data')
          .doc(widget.turbinaId)
          .collection('components')
          .doc(widget.componentId)
          .set({
        'assembly': {
          'dataInicio': Timestamp.fromDate(dataInicioCompleta),
          if (dataFimCompleta != null)
            'dataFim': Timestamp.fromDate(dataFimCompleta),
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
            ListTile(
              title: const Text('Data Início'),
              subtitle: Text(
                _dataInicio != null
                    ? '${_dataInicio!.day}/${_dataInicio!.month}/${_dataInicio!.year}'
                    : 'Não selecionada',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dataInicio ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _dataInicio = date);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.borderGray),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Hora Início'),
              subtitle: Text(
                _horaInicio != null
                    ? '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}'
                    : 'Não selecionada',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _horaInicio ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _horaInicio = time);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.borderGray),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Data Fim (Opcional)'),
              subtitle: Text(
                _dataFim != null
                    ? '${_dataFim!.day}/${_dataFim!.month}/${_dataFim!.year}'
                    : 'Não selecionada',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dataFim ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _dataFim = date);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.borderGray),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Hora Fim (Opcional)'),
              subtitle: Text(
                _horaFim != null
                    ? '${_horaFim!.hour.toString().padLeft(2, '0')}:${_horaFim!.minute.toString().padLeft(2, '0')}'
                    : 'Não selecionada',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _horaFim ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _horaFim = time);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.borderGray),
              ),
            ),
            const SizedBox(height: 24),
            PhotoPickerWidget(
              photoUrls: _photoUrls,
              onPhotosChanged: (urls) {
                setState(() => _photoUrls = urls);
              },
              turbinaId: widget.turbinaId,
              componentId: widget.componentId,
              phase: 'assembly',
            ),
            const SizedBox(height: 24),
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
