// lib/widgets/documentation/document_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/documentation.dart';
import '../../core/theme/app_colors.dart';
// ignore: unused_import
// (flutter_riverpod não é necessário neste widget)

class DocumentCard extends StatefulWidget {
  final Documentation document;
  final bool canDelete;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {
  bool _expanded = false;

  // ─── Cor por categoria ─────────────────────────────────────────────────────

  Color get _categoryColor {
    switch (widget.document.category) {
      case DocumentCategory.relatorios:
        return AppColors.primaryBlue;
      case DocumentCategory.procedimentos:
        return AppColors.accentTealDark;
      case DocumentCategory.certificados:
        return AppColors.accentAmberDark;
      case DocumentCategory.reportsDanos:
        return AppColors.errorRed;
      case DocumentCategory.desenhosTecnicos:
        return AppColors.accentTeal;
      case DocumentCategory.manuais:
        return AppColors.successGreen;
      case DocumentCategory.outro:
        return AppColors.mediumGray;
    }
  }

  // ─── Ícone da extensão ─────────────────────────────────────────────────────

  IconData get _fileIcon {
    switch (widget.document.fileExtension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      case 'dwg':
      case 'dxf':
        return Icons.architecture;
      default:
        return Icons.insert_drive_file;
    }
  }

  // ─── Abrir ficheiro ────────────────────────────────────────────────────────

  Future<void> _openFile() async {
    final path = widget.document.filePath;
    if (path.isEmpty) return;

    // Verificar se existe
    final exists = File(path).existsSync();
    if (!exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Ficheiro não encontrado: ${widget.document.fileName}'),
            backgroundColor: AppColors.warningOrange,
          ),
        );
      }
      return;
    }

    final uri = Uri.file(path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o ficheiro')),
        );
      }
    }
  }

  // ─── Confirmar eliminação ──────────────────────────────────────────────────

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Documento'),
        content: Text(
            'Tens a certeza que queres eliminar "${widget.document.title}"?\n\nO ficheiro no disco NÃO será eliminado.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('Eliminar Registo'),
          ),
        ],
      ),
    );
    if (confirmed == true) widget.onDelete?.call();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final fileOk = doc.fileExists ?? true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          // ── Header (sempre visível) ──────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícone categoria
                  Stack(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(doc.category.icon,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      // Badge de ficheiro em falta
                      if (!fileOk)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.warningOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning,
                                size: 10, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Título, categoria, tags
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título + ID
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                doc.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              doc.documentId,
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.lightGray),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Categoria + extensão
                        Row(
                          children: [
                            _CategoryChip(
                                label: doc.category.label,
                                color: _categoryColor),
                            const SizedBox(width: 6),
                            if (doc.fileExtension.isNotEmpty)
                              _ExtensionChip(
                                  ext: doc.fileExtension.toUpperCase()),
                            if (!fileOk) ...[
                              const SizedBox(width: 6),
                              const _WarningChip(label: 'Ficheiro em falta'),
                            ],
                          ],
                        ),

                        // Tags
                        if (doc.tags.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            children: doc.tags
                                .take(5)
                                .map((t) => _TagChip(label: t))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Data + expand icon
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        doc.documentDate,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.mediumGray),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppColors.mediumGray,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Painel expansível ──────────────────────────────────────────────
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ficheiro
                  _DetailRow(
                    icon: _fileIcon,
                    label: 'Ficheiro',
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            doc.fileName,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (fileOk)
                          InkWell(
                            onTap: _openFile,
                            child: const Text(
                              'Abrir',
                              style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline),
                            ),
                          )
                        else
                          const Text('Não encontrado',
                              style: TextStyle(
                                  color: AppColors.warningOrange,
                                  fontSize: 12)),
                      ],
                    ),
                  ),

                  // Descrição
                  if (doc.description != null &&
                      doc.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _DetailRow(
                      icon: Icons.notes,
                      label: 'Descrição',
                      child: Text(doc.description!,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],

                  // Subcategoria
                  if (doc.subcategory != null &&
                      doc.subcategory!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _DetailRow(
                      icon: Icons.subdirectory_arrow_right,
                      label: 'Subcategoria',
                      child: Text(doc.subcategory!,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],

                  // Data de registo
                  const SizedBox(height: 6),
                  _DetailRow(
                    icon: Icons.event_available,
                    label: 'Registado',
                    child: Text(doc.registeredDate,
                        style: const TextStyle(fontSize: 12)),
                  ),

                  // Relações
                  if (doc.relatedTo != null) ...[
                    if (doc.relatedTo!.turbines.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _DetailRow(
                        icon: Icons.wind_power,
                        label: 'Turbinas',
                        child: Text(doc.relatedTo!.turbines.join(', '),
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                    if (doc.relatedTo!.phases.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _DetailRow(
                        icon: Icons.timeline,
                        label: 'Fases',
                        child: Text(doc.relatedTo!.phases.join(', '),
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                    if (doc.relatedTo!.connections.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _DetailRow(
                        icon: Icons.cable,
                        label: 'Conexões',
                        child: Text(doc.relatedTo!.connections.join(', '),
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ],

                  // Path (colapsado)
                  const SizedBox(height: 6),
                  _DetailRow(
                    icon: Icons.folder,
                    label: 'Caminho',
                    child: Text(
                      doc.filePath,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.mediumGray),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Ações
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (fileOk)
                        OutlinedButton.icon(
                          onPressed: _openFile,
                          icon: const Icon(Icons.open_in_new, size: 15),
                          label: const Text('Abrir Ficheiro'),
                          style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6)),
                        ),
                      const Spacer(),
                      if (widget.canDelete)
                        TextButton.icon(
                          onPressed: _confirmDelete,
                          icon: const Icon(Icons.delete_outline,
                              size: 15, color: AppColors.errorRed),
                          label: const Text('Eliminar',
                              style: TextStyle(color: AppColors.errorRed)),
                          style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _ExtensionChip extends StatelessWidget {
  final String ext;
  const _ExtensionChip({required this.ext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(ext,
          style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.mediumGray)),
    );
  }
}

class _WarningChip extends StatelessWidget {
  final String label;
  const _WarningChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 9,
              color: AppColors.warningOrange,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Text('#$label',
          style: const TextStyle(fontSize: 10, color: AppColors.mediumGray)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.lightGray),
        const SizedBox(width: 6),
        SizedBox(
          width: 72,
          child: Text('$label:',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mediumGray,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(child: child),
      ],
    );
  }
}
