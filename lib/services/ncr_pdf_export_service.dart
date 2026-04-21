import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/localization/translation_helper.dart';
import '../models/ncr.dart';
import 'export_translation_service.dart';
import 'pdf_file_saver.dart';

class NcrPdfExportService {
  static const double _imageEvidenceCardWidth = 245;
  static const double _imageEvidenceInnerWidth = 229;
  static const double _imageEvidenceHeight = 150;
  static const String _templateBackgroundAssetPath =
      'assets/ncr_pdf_template.png';
  final ExportTranslationService _exportTranslationService =
      ExportTranslationService();
  final TranslationHelper _englishTranslations =
      TranslationHelper(const Locale('en'));

  Future<Uint8List> buildPdf({
    required NcrRecord ncr,
    required TranslationHelper t,
    String projectName = '',
  }) async {
    final translatedNcr = await _translateNcrForExport(ncr);
    final translatedProjectName = projectName.trim().isEmpty
        ? ''
        : await _exportTranslationService.translateText(projectName);
    final document = pw.Document(
      title: '${translatedNcr.code} - ${translatedNcr.title}',
      author: 'As-Built',
      creator: 'As-Built',
      subject: 'NCR',
    );

    final imageEvidence = await _loadImageEvidence(translatedNcr.evidence);
    final templateBackground = await _loadTemplateBackground();
    final otherEvidence =
        translatedNcr.evidence.where((item) => !_isImageEvidence(item));

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          buildBackground: (context) => _buildTemplateBackground(
            templateBackground,
          ),
        ),
        header: (context) => templateBackground != null
            ? pw.SizedBox(height: 92)
            : pw.SizedBox.shrink(),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildHeader(
              translatedNcr, _englishTranslations, translatedProjectName),
          pw.SizedBox(height: 18),
          _buildSummaryGrid(translatedNcr, _englishTranslations),
          pw.SizedBox(height: 18),
          _buildSection(
            title: _englishTranslations.translate('ncr_description'),
            child: pw.Text(
              _safeText(translatedNcr.description),
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
            ),
          ),
          if (translatedNcr.tags.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _buildTagsSection(translatedNcr),
          ],
          if (translatedNcr.closureNote.trim().isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _buildSection(
              title: _englishTranslations.translate('ncr_closure_note'),
              child: pw.Text(
                _safeText(translatedNcr.closureNote),
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
              ),
            ),
          ],
          pw.SizedBox(height: 14),
          _buildHistorySection(translatedNcr, _englishTranslations),
          pw.SizedBox(height: 14),
          _buildEvidenceSection(
            imageEvidence,
            otherEvidence.toList(),
            _englishTranslations,
          ),
        ],
      ),
    );

    return document.save();
  }

  Future<NcrRecord> _translateNcrForExport(NcrRecord ncr) async {
    final translatedTags = await _exportTranslationService.translateListItems(
      ncr.tags,
    );

    final translatedHistory = await Future.wait(
      ncr.statusHistory.map((item) async => NcrStatusChange(
            id: item.id,
            fromStatus: item.fromStatus,
            toStatus: item.toStatus,
            note: await _exportTranslationService.translateText(item.note),
            changedBy: item.changedBy,
            changedByName: item.changedByName,
            changedAt: item.changedAt,
          )),
    );

    return ncr.copyWith(
      title: await _exportTranslationService.translateText(ncr.title),
      description: await _exportTranslationService.translateText(
        ncr.description,
      ),
      closureNote: await _exportTranslationService.translateText(
        ncr.closureNote,
      ),
      tags: translatedTags,
      statusHistory: translatedHistory,
    );
  }

  pw.Widget _buildTemplateBackground(pw.MemoryImage? templateBackground) {
    if (templateBackground == null) {
      return pw.SizedBox.expand(child: pw.Container(color: PdfColors.white));
    }

    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Image(
        templateBackground,
        fit: pw.BoxFit.cover,
      ),
    );
  }

  Future<String?> savePdf({
    required NcrRecord ncr,
    required TranslationHelper t,
    String projectName = '',
  }) async {
    final bytes = await buildPdf(ncr: ncr, t: t, projectName: projectName);
    return savePdfBytes(bytes: bytes, fileName: _buildFileName(ncr));
  }

  Future<void> printPdf({
    required NcrRecord ncr,
    required TranslationHelper t,
    String projectName = '',
  }) async {
    final bytes = await buildPdf(ncr: ncr, t: t, projectName: projectName);
    await Printing.layoutPdf(
      name: _buildFileName(ncr),
      onLayout: (_) async => bytes,
    );
  }

  pw.Widget _buildHeader(
    NcrRecord ncr,
    TranslationHelper t,
    String projectName,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor(1, 1, 1, 0.96),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: PdfColor.fromHex('#D1D5DB')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      ncr.code,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#111827'),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _safeText(ncr.title),
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1F2937'),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                width: 170,
                padding: const pw.EdgeInsets.only(left: 12),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(color: PdfColor.fromHex('#D1D5DB')),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildCompactMeta(
                      t.translate('ncr_current_status'),
                      t.translate('ncr_status_${ncr.status.value}'),
                    ),
                    pw.SizedBox(height: 6),
                    _buildCompactMeta(
                      t.translate('ncr_category'),
                      t.translate('ncr_category_${ncr.category.value}'),
                    ),
                    pw.SizedBox(height: 6),
                    _buildCompactMeta(
                      t.translate('ncr_severity'),
                      t.translate('ncr_severity_${ncr.severity.value}'),
                      valueColor: _severityColor(ncr.severity),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Container(height: 1, color: PdfColor.fromHex('#D1D5DB')),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _buildHeaderMeta(
                t.translate('project'),
                projectName.trim().isEmpty ? '-' : projectName.trim(),
              ),
              _buildHeaderMeta(
                t.translate('ncr_linked_turbine'),
                ncr.turbinaNome,
              ),
              _buildHeaderMeta(
                t.translate('ncr_due_date'),
                _formatDate(ncr.dueDate),
              ),
              _buildHeaderMeta(
                t.translate('ncr_generated_at'),
                _formatDateTime(DateTime.now()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildHeaderMeta(String label, String value) {
    return pw.Container(
      width: 240,
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromHex('#D1D5DB')),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromHex('#64748B'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _safeText(value),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#111827'),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCompactMeta(
    String label,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 7,
            color: PdfColor.fromHex('#6B7280'),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          _safeText(value),
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: valueColor ?? PdfColor.fromHex('#111827'),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryGrid(NcrRecord ncr, TranslationHelper t) {
    final rows = <List<MapEntry<String, String>>?>[
      [
        MapEntry(
          t.translate('ncr_assigned_to'),
          ncr.assignedTo.trim().isEmpty
              ? t.translate('ncr_unassigned')
              : ncr.assignedTo.trim(),
        ),
        MapEntry(t.translate('created'), _formatDateTime(ncr.createdAt)),
      ],
      [
        MapEntry(t.translate('ncr_updated_at'), _formatDateTime(ncr.updatedAt)),
        MapEntry(
          t.translate('ncr_closed_by'),
          ncr.closedByName.trim().isEmpty ? '-' : ncr.closedByName.trim(),
        ),
      ],
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(t.translate('details')),
        pw.SizedBox(height: 8),
        pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColor(1, 1, 1, 0.96),
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(color: PdfColor.fromHex('#D1D5DB')),
          ),
          child: pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(),
              1: pw.FlexColumnWidth(),
            },
            border: pw.TableBorder(
              horizontalInside:
                  pw.BorderSide(color: PdfColor.fromHex('#E5E7EB')),
              verticalInside: pw.BorderSide(color: PdfColor.fromHex('#E5E7EB')),
            ),
            children: rows
                .map(
                  (row) => pw.TableRow(
                    children: row!
                        .map(
                          (item) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 9,
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  item.key.toUpperCase(),
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    color: PdfColor.fromHex('#6B7280'),
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  _safeText(item.value),
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#111827'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTagsSection(NcrRecord ncr) {
    return _buildSection(
      title: 'Tags',
      child: pw.Text(
        ncr.tags.map((tag) => '#${_safeText(tag)}').join('   '),
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColor.fromHex('#334155'),
          lineSpacing: 2,
        ),
      ),
    );
  }

  pw.Widget _buildHistorySection(NcrRecord ncr, TranslationHelper t) {
    return _buildSection(
      title: t.translate('ncr_status_timeline'),
      child: ncr.statusHistory.isEmpty
          ? pw.Text(
              t.translate('ncr_no_history'),
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromHex('#64748B'),
              ),
            )
          : pw.Column(
              children: ncr.statusHistory
                  .map(
                    (item) => pw.Container(
                      width: double.infinity,
                      margin: const pw.EdgeInsets.only(bottom: 10),
                      padding: const pw.EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 10,
                        bottom: 10,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColor(1, 1, 1, 0.96),
                        borderRadius: pw.BorderRadius.circular(12),
                        border:
                            pw.Border.all(color: PdfColor.fromHex('#D1D5DB')),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '${t.translate('ncr_status_${item.fromStatus.value}')} -> ${t.translate('ncr_status_${item.toStatus.value}')}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#0F172A'),
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            '${_formatDateTime(item.changedAt)} · ${item.changedByName.trim().isEmpty ? item.changedBy.trim() : item.changedByName.trim()}',
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColor.fromHex('#64748B'),
                            ),
                          ),
                          if (item.note.trim().isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Container(
                              height: 1,
                              color: PdfColor.fromHex('#E5E7EB'),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              _safeText(item.note),
                              style: const pw.TextStyle(
                                fontSize: 10,
                                lineSpacing: 2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  pw.Widget _buildEvidenceSection(
    List<_ImageEvidenceEntry> imageEvidence,
    List<NcrEvidence> attachments,
    TranslationHelper t,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSection(
          title: t.translate('ncr_evidence_images'),
          child: imageEvidence.isEmpty
              ? pw.Text(
                  t.translate('ncr_no_images'),
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColor.fromHex('#64748B'),
                  ),
                )
              : pw.Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: imageEvidence
                      .map(
                        (item) => pw.Container(
                          width: _imageEvidenceCardWidth,
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            color: PdfColor(1, 1, 1, 0.96),
                            borderRadius: pw.BorderRadius.circular(12),
                            border: pw.Border.all(
                                color: PdfColor.fromHex('#D1D5DB')),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.ClipRRect(
                                horizontalRadius: 8,
                                verticalRadius: 8,
                                child: pw.SizedBox(
                                  width: _imageEvidenceInnerWidth,
                                  height: _imageEvidenceHeight,
                                  child: pw.Image(
                                    item.image,
                                    fit: pw.BoxFit.cover,
                                  ),
                                ),
                              ),
                              pw.SizedBox(height: 6),
                              pw.Text(
                                _safeText(item.evidence.name),
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                '${_formatDateTime(item.evidence.uploadedAt)} · ${_safeText(item.evidence.uploadedBy)}',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColor.fromHex('#64748B'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
        pw.SizedBox(height: 14),
        _buildSection(
          title: t.translate('ncr_attachments'),
          child: attachments.isEmpty
              ? pw.Text(
                  t.translate('ncr_no_attachments'),
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColor.fromHex('#64748B'),
                  ),
                )
              : pw.Column(
                  children: attachments
                      .map(
                        (item) => pw.Container(
                          width: double.infinity,
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            color: PdfColor(1, 1, 1, 0.96),
                            borderRadius: pw.BorderRadius.circular(10),
                            border: pw.Border.all(
                              color: PdfColor.fromHex('#D1D5DB'),
                            ),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  _safeText(item.name),
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.SizedBox(width: 10),
                              pw.Text(
                                _safeText(item.contentType),
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColor.fromHex('#64748B'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    );
  }

  pw.Widget _buildSection({required String title, required pw.Widget child}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: PdfColor(1, 1, 1, 0.96),
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(color: PdfColor.fromHex('#D1D5DB')),
          ),
          child: child,
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title.toUpperCase(),
      style: pw.TextStyle(
        fontSize: 11,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#0F172A'),
        letterSpacing: 0.8,
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    final pageLabel = '${context.pageNumber}/${context.pagesCount}';

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: pw.BoxDecoration(
          color: PdfColor(1, 1, 1, 0.96),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          pageLabel,
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColor.fromHex('#111827'),
          ),
        ),
      ),
    );
  }

  PdfColor _severityColor(NcrSeverity severity) {
    switch (severity) {
      case NcrSeverity.low:
        return PdfColor.fromHex('#16A34A');
      case NcrSeverity.medium:
        return PdfColor.fromHex('#A16207');
      case NcrSeverity.high:
        return PdfColor.fromHex('#EA580C');
      case NcrSeverity.critical:
        return PdfColor.fromHex('#DC2626');
    }
  }

  Future<List<_ImageEvidenceEntry>> _loadImageEvidence(
    List<NcrEvidence> evidence,
  ) async {
    final entries = <_ImageEvidenceEntry>[];

    for (final item in evidence) {
      if (!_isImageEvidence(item)) {
        continue;
      }

      try {
        final image = await networkImage(item.url);
        entries.add(_ImageEvidenceEntry(evidence: item, image: image));
      } catch (_) {
        if (kDebugMode) {
          debugPrint('Failed to load NCR image evidence: ${item.name}');
        }
      }
    }

    return entries;
  }

  Future<pw.MemoryImage?> _loadTemplateBackground() async {
    try {
      final byteData = await rootBundle.load(_templateBackgroundAssetPath);
      return pw.MemoryImage(byteData.buffer.asUint8List());
    } catch (_) {
      if (kDebugMode) {
        debugPrint('Failed to load NCR template background asset.');
      }
      return null;
    }
  }

  bool _isImageEvidence(NcrEvidence evidence) {
    final contentType = evidence.contentType.toLowerCase();
    if (contentType.startsWith('image/')) {
      return true;
    }

    final name = evidence.name.toLowerCase();
    return name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.webp');
  }

  String _buildFileName(NcrRecord ncr) {
    final safeCode = ncr.code.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return '${safeCode}_NCR.pdf';
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  String _formatDateTime(DateTime value) {
    final date = _formatDate(value);
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$date $hour:$minute';
  }

  String _safeText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '-' : trimmed;
  }
}

class _ImageEvidenceEntry {
  const _ImageEvidenceEntry({required this.evidence, required this.image});

  final NcrEvidence evidence;
  final pw.ImageProvider image;
}
