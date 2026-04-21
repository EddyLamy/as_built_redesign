// lib/widgets/documentation/add_document_dialog.dart
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../models/documentation.dart';
import '../../providers/auth_providers.dart';
import '../../providers/documentation_provider.dart';
import '../../core/localization/translation_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/app_feedback.dart';

class AddDocumentDialog extends ConsumerStatefulWidget {
  final String projectId;

  const AddDocumentDialog({super.key, required this.projectId});

  @override
  ConsumerState<AddDocumentDialog> createState() => _AddDocumentDialogState();
}

class _AddDocumentDialogState extends ConsumerState<AddDocumentDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _tagsController = TextEditingController();
  final _turbinesController = TextEditingController();
  final _documentDateController = TextEditingController();

  DocumentCategory _selectedCategory = DocumentCategory.relatorios;
  String? _selectedFilePath;
  String? _selectedFileName;
  String? _selectedFileExtension;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subcategoryController.dispose();
    _tagsController.dispose();
    _turbinesController.dispose();
    _documentDateController.dispose();
    super.dispose();
  }

  // ─── Selecionar ficheiro ───────────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'png',
        'jpg',
        'jpeg',
        'dwg',
        'dxf',
        'txt'
      ],
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      setState(() {
        _selectedFilePath = path;
        _selectedFileName = result.files.single.name;
        _selectedFileExtension =
            p.extension(path).replaceFirst('.', '').toLowerCase();
      });
    }
  }

  // ─── Selecionar data ───────────────────────────────────────────────────────

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _documentDateController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  String _todayFormatted() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  // ─── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final t = TranslationHelper.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFilePath == null) {
      showAppFeedback(
        t.translate('please_select_file'),
        type: AppFeedbackType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(documentationServiceProvider);
      final userId = ref.read(currentUserIdProvider) ?? '';
      final docId = await service.generateDocumentId();

      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final turbines = _turbinesController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // Verificar se o ficheiro existe no disco
      final fileExists = File(_selectedFilePath!).existsSync();

      final document = Documentation(
        documentId: docId,
        projectId: widget.projectId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        subcategory: _subcategoryController.text.trim().isEmpty
            ? null
            : _subcategoryController.text.trim(),
        tags: tags,
        filePath: _selectedFilePath!,
        fileName: _selectedFileName!,
        fileExtension: _selectedFileExtension ?? '',
        fileExists: fileExists,
        lastChecked: DateTime.now(),
        documentDate: _documentDateController.text.trim(),
        registeredDate: _todayFormatted(),
        relatedTo: DocumentRelations(turbines: turbines),
        createdBy: userId,
        createdAt: DateTime.now(),
      );

      await service.addDocument(document);

      if (mounted) {
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showAppFeedback(
            '${t.translate('document_added_success')}: $docId',
            type: AppFeedbackType.success,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        showAppFeedback(
          '${t.translate('error')}: $e',
          type: AppFeedbackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.upload_file, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(t.translate('add_document'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Título ──────────────────────────────────────────
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: '${t.translate('title')} *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.title),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? t.translate('required_field')
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // ── Categoria ────────────────────────────────────────
                        DropdownButtonFormField<DocumentCategory>(
                          initialValue: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: '${t.translate('component_category')} *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.category),
                          ),
                          items: DocumentCategory.values.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text('${cat.icon}  ${cat.label}'),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                        ),
                        const SizedBox(height: 12),

                        // ── Subcategoria (opcional) ───────────────────────────
                        TextFormField(
                          controller: _subcategoryController,
                          decoration: InputDecoration(
                            labelText: t.translate('subcategory_optional'),
                            border: const OutlineInputBorder(),
                            prefixIcon:
                                const Icon(Icons.subdirectory_arrow_right),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Data do documento ────────────────────────────────
                        TextFormField(
                          controller: _documentDateController,
                          readOnly: true,
                          onTap: _selectDate,
                          decoration: InputDecoration(
                            labelText: '${t.translate('document_date')} *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.calendar_today),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.date_range),
                              onPressed: _selectDate,
                            ),
                            hintText: 'DD/MM/AAAA',
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? t.translate('required_field')
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // ── Tags ─────────────────────────────────────────────
                        TextFormField(
                          controller: _tagsController,
                          decoration: InputDecoration(
                            labelText: t.translate('tags_comma_separated'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.label),
                            hintText: t.translate('tags_hint'),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Turbinas relacionadas ────────────────────────────
                        TextFormField(
                          controller: _turbinesController,
                          decoration: InputDecoration(
                            labelText:
                                t.translate('related_turbines_comma_separated'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.wind_power),
                            hintText: t.translate('related_turbines_hint'),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Seletor de ficheiro ──────────────────────────────
                        GestureDetector(
                          onTap: _pickFile,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedFileName != null
                                    ? AppColors.successGreen
                                    : AppColors.borderGray,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedFileName != null
                                      ? Icons.check_circle
                                      : Icons.attach_file,
                                  color: _selectedFileName != null
                                      ? AppColors.successGreen
                                      : AppColors.mediumGray,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedFileName ??
                                            '${t.translate('select_file')} *',
                                        style: TextStyle(
                                          color: _selectedFileName != null
                                              ? AppColors.darkGray
                                              : AppColors.mediumGray,
                                          fontWeight: _selectedFileName != null
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (_selectedFileExtension != null)
                                        Text(
                                          '.${_selectedFileExtension!.toUpperCase()}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.mediumGray),
                                        ),
                                    ],
                                  ),
                                ),
                                if (_selectedFileName != null)
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.clear,
                                        size: 18, color: AppColors.mediumGray),
                                    onPressed: () => setState(() {
                                      _selectedFilePath = null;
                                      _selectedFileName = null;
                                      _selectedFileExtension = null;
                                    }),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── Descrição ────────────────────────────────────────
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: t.translate('description_optional'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.notes),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(t.translate('cancel')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(t.translate('save')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
