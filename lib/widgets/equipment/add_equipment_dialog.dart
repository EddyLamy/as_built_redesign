// ══════════════════════════════════════════════════════════════
// ADD EQUIPMENT DIALOG
// lib/widgets/equipment/add_equipment_dialog.dart
// ══════════════════════════════════════════════════════════════
// ignore_for_file: deprecated_member_use, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/equipment.dart';
import '../../providers/equipment_provider.dart';
import '../../providers/auth_providers.dart';
import '../../providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../gradient_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEquipmentDialog extends ConsumerStatefulWidget {
  final Equipment? initialEquipment;

  const AddEquipmentDialog({super.key, this.initialEquipment});

  @override
  ConsumerState<AddEquipmentDialog> createState() => _AddEquipmentDialogState();
}

class _AddEquipmentDialogState extends ConsumerState<AddEquipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form fields
  EquipmentType _type = EquipmentType.chaveTorque;
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _calibrationDateController = TextEditingController();
  final _calibrationExpiryController = TextEditingController();
  final _certificateNumberController = TextEditingController();
  final _locationController = TextEditingController(text: 'Armazém A');
  final _notesController = TextEditingController();

  String? _certificatePath;
  EquipmentCondition _condition = EquipmentCondition.bom;

  bool get _isEditMode => widget.initialEquipment != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final equipment = widget.initialEquipment;
    if (equipment == null) return;

    _type = equipment.type;
    _manufacturerController.text = equipment.manufacturer;
    _modelController.text = equipment.model;
    _serialNumberController.text = equipment.serialNumber;
    _descriptionController.text = equipment.description ?? '';
    _calibrationDateController.text = equipment.calibration.lastDate;
    _calibrationExpiryController.text = equipment.calibration.expiryDate;
    _certificateNumberController.text = equipment.calibration.certificateNumber;
    _certificatePath = equipment.calibration.certificatePath.isEmpty
        ? null
        : equipment.calibration.certificatePath;
    _locationController.text = equipment.currentLocation;
    _condition = equipment.condition;
    _notesController.text = equipment.notes ?? '';
  }

  @override
  void dispose() {
    _manufacturerController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _descriptionController.dispose();
    _calibrationDateController.dispose();
    _calibrationExpiryController.dispose();
    _certificateNumberController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          children: [
            // ══════════════════════════════════════════════════════
            // HEADER COM GRADIENTE
            // ══════════════════════════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isEditMode
                        ? Icons.edit_outlined
                        : Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEditMode
                          ? 'Editar Equipamento'
                          : 'Adicionar Equipamento',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // ══════════════════════════════════════════════════════
            // FORM
            // ══════════════════════════════════════════════════════
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tipo
                      const Text(
                        'Tipo de Equipamento *',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<EquipmentType>(
                        initialValue: _type,
                        items: EquipmentType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _type = value);
                          }
                        },
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      // Fabricante
                      const Text(
                        'Fabricante *',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _manufacturerController,
                        decoration: _inputDecoration(hint: 'Ex: Hytorc'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Modelo
                      const Text(
                        'Modelo *',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _modelController,
                        decoration: _inputDecoration(hint: 'Ex: AVANTI-5'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Nº Série
                      const Text(
                        'Nº de Série *',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _serialNumberController,
                        decoration: _inputDecoration(hint: 'Ex: HYT-2024-001'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Descrição
                      const Text(
                        'Descrição',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration(
                          hint: 'Informações adicionais...',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // CALIBRAÇÃO
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        '📅 CALIBRAÇÃO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Datas
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Data Calibração *',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _calibrationDateController,
                                  decoration:
                                      _inputDecoration(hint: 'DD/MM/YYYY'),
                                  readOnly: true,
                                  onTap: () => _selectDate(
                                      context, _calibrationDateController),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Obrigatório';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Data Validade *',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _calibrationExpiryController,
                                  decoration:
                                      _inputDecoration(hint: 'DD/MM/YYYY'),
                                  readOnly: true,
                                  onTap: () => _selectDate(
                                      context, _calibrationExpiryController),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Obrigatório';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nº Certificado
                      const Text(
                        'Nº do Certificado (opcional)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _certificateNumberController,
                        decoration: _inputDecoration(hint: 'Ex: CERT-2024-123'),
                      ),
                      const SizedBox(height: 16),

                      // Ficheiro Certificado
                      const Text(
                        'Certificado (PDF) (opcional)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.borderGray),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _certificatePath ??
                                    'Nenhum ficheiro selecionado',
                                style: TextStyle(
                                  color: _certificatePath != null
                                      ? AppColors.darkGray
                                      : AppColors.mediumGray,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GradientButton(
                            label: 'Escolher',
                            icon: Icons.folder_open,
                            onPressed: _pickCertificate,
                            isSmall: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // OUTROS
                      const Divider(),
                      const SizedBox(height: 16),

                      // Localização
                      const Text(
                        'Localização Atual',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _locationController,
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      // Condição
                      const Text(
                        'Condição',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<EquipmentCondition>(
                        initialValue: _condition,
                        items: EquipmentCondition.values.map((cond) {
                          return DropdownMenuItem(
                            value: cond,
                            child: Text(cond.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _condition = value);
                          }
                        },
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      // Observações
                      const Text(
                        'Observações',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration:
                            _inputDecoration(hint: 'Notas adicionais...'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ══════════════════════════════════════════════════════
            // FOOTER
            // ══════════════════════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundGray,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    label: _isLoading
                        ? 'A guardar...'
                        : (_isEditMode ? 'Guardar Alterações' : 'Guardar'),
                    icon: _isLoading ? null : Icons.save,
                    onPressed: _isLoading ? null : _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // MÉTODOS
  // ════════════════════════════════════════════════════════════

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      controller.text = '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    }
  }

  Future<void> _pickCertificate() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _certificatePath = result.files.single.path!;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao escolher ficheiro: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    // ════════════════════════════════════════════════════════════
    // DEBUG - ADICIONAR ISTO NO INÍCIO
    // ════════════════════════════════════════════════════════════
    debugPrint('🔍 DEBUG: Iniciando _submit()');

    final firebaseUser = FirebaseAuth.instance.currentUser;
    debugPrint('🔍 DEBUG: FirebaseAuth.instance.currentUser = $firebaseUser');
    debugPrint('🔍 DEBUG: User UID = ${firebaseUser?.uid}');
    debugPrint('🔍 DEBUG: User Email = ${firebaseUser?.email}');

    if (firebaseUser == null) {
      debugPrint('❌ DEBUG: User é NULL!');
    } else {
      debugPrint('✅ DEBUG: User está autenticado!');
    }
    // ════════════════════════════════════════════════════════════

    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ DEBUG: Validação do formulário falhou!');
      return;
    }

    debugPrint('✅ DEBUG: Validação do formulário passou!');

    debugPrint(
        'ℹ️ DEBUG: Certificado é opcional. Valor atual: $_certificatePath');

    setState(() => _isLoading = true);
    debugPrint('🔄 DEBUG: _isLoading definido como true');

    try {
      // Usar currentUserProvider em vez de authProvider.value
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception(
            'Utilizador não autenticado. Por favor, faça login novamente.');
      }

      final selectedProjectId = ref.read(selectedProjectIdProvider);
      if (selectedProjectId == null || selectedProjectId.isEmpty) {
        throw Exception('Selecione um projeto antes de gerir equipamentos.');
      }

      final existingEquipment = widget.initialEquipment;
      final equipmentId = existingEquipment?.equipmentId ??
          'EQ${DateTime.now().millisecondsSinceEpoch}';

      final equipment = Equipment(
        equipmentId: equipmentId,
        projectId: existingEquipment?.projectId ?? selectedProjectId,
        type: _type,
        manufacturer: _manufacturerController.text,
        model: _modelController.text,
        serialNumber: _serialNumberController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        calibration: CalibrationData(
          lastDate: _calibrationDateController.text,
          expiryDate: _calibrationExpiryController.text,
          certificateNumber: _certificateNumberController.text,
          certificatePath: _certificatePath ?? '',
        ),
        status: existingEquipment?.status ?? EquipmentStatus.disponivel,
        currentProject: existingEquipment?.currentProject,
        currentProjectName: existingEquipment?.currentProjectName,
        currentLocation: _locationController.text,
        condition: _condition,
        usageHistory: existingEquipment?.usageHistory ?? [],
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdBy: existingEquipment?.createdBy ?? user.uid,
        createdAt: existingEquipment?.createdAt ?? DateTime.now(),
        updatedBy: existingEquipment != null ? user.uid : null,
        updatedAt: existingEquipment != null ? DateTime.now() : null,
      );

      final actions = ref.read(equipmentActionsProvider);
      final success = _isEditMode
          ? await actions.updateEquipment(equipment)
          : await actions.addEquipment(equipment);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditMode
                  ? '✅ Equipamento atualizado com sucesso!'
                  : '✅ Equipamento adicionado com sucesso!'),
            ),
          );
          Navigator.pop(context);
        } else {
          throw Exception(_isEditMode
              ? 'Falha ao atualizar equipamento'
              : 'Falha ao adicionar equipamento');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
