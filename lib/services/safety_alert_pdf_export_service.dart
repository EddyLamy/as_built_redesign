import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/localization/translation_helper.dart';
import '../models/safety_alert.dart';
import 'export_translation_service.dart';
import 'pdf_file_saver.dart';

class SafetyAlertPdfExportService {
  final ExportTranslationService _exportTranslationService =
      ExportTranslationService();
  final TranslationHelper _englishTranslations =
      TranslationHelper(const Locale('en'));

  Future<Uint8List> buildPdf({
    required SafetyAlertRecord alert,
    required TranslationHelper t,
    String projectName = '',
  }) async {
    final translatedAlert = await _translateAlertForExport(alert);
    final translatedProjectName = projectName.trim().isEmpty
        ? ''
        : await _exportTranslationService.translateText(projectName);
    final imageEvidence = await _loadImageEvidence(translatedAlert.evidence);
    final resolutionImageEvidence =
        await _loadImageEvidence(translatedAlert.resolutionEvidence);

    final document = pw.Document(
      title: '${translatedAlert.code} - Safety Alert',
      author: 'As-Built',
      creator: 'As-Built',
      subject: 'Safety Alert',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          _buildHeader(translatedAlert, translatedProjectName),
          pw.SizedBox(height: 16),
          _buildMetaGrid(translatedAlert),
          pw.SizedBox(height: 16),
          _buildSection(
            title: _englishTranslations
                .translate('safety_alert_problem_description'),
            child: pw.Text(
              _safeText(translatedAlert.problemDescription),
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
            ),
          ),
          if (imageEvidence.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _buildImageSection(
              _englishTranslations.translate('safety_alert_photos'),
              imageEvidence,
            ),
          ],
          pw.SizedBox(height: 14),
          _buildSection(
            title: _englishTranslations
                .translate('safety_alert_possible_solution'),
            child: pw.Text(
              _safeText(translatedAlert.proposedSolution),
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
            ),
          ),
          pw.SizedBox(height: 14),
          _buildSection(
            title: _englishTranslations
                .translate('safety_alert_resolucao_efetuada'),
            child: pw.Text(
              _safeText(translatedAlert.resolucaoEfetuada),
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 2),
            ),
          ),
          if (resolutionImageEvidence.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _buildImageSection(
              _englishTranslations.translate('safety_alert_resolution_photos'),
              resolutionImageEvidence,
            ),
          ],
        ],
      ),
    );

    return document.save();
  }

  Future<String?> savePdf({
    required SafetyAlertRecord alert,
    required TranslationHelper t,
    String projectName = '',
  }) async {
    final bytes = await buildPdf(alert: alert, t: t, projectName: projectName);
    return savePdfBytes(bytes: bytes, fileName: _buildFileName(alert));
  }

  Future<void> printPdf({
    required SafetyAlertRecord alert,
    required TranslationHelper t,
    String projectName = '',
  }) async {
    final bytes = await buildPdf(alert: alert, t: t, projectName: projectName);
    await Printing.layoutPdf(
      name: _buildFileName(alert),
      onLayout: (_) async => bytes,
    );
  }

  Future<SafetyAlertRecord> _translateAlertForExport(
    SafetyAlertRecord alert,
  ) async {
    return alert.copyWith(
      destinationTo: await _exportTranslationService.translateText(
        alert.destinationTo,
      ),
      department: await _exportTranslationService.translateText(
        alert.department,
      ),
      problemDescription: await _exportTranslationService.translateText(
        alert.problemDescription,
      ),
      proposedSolution: await _exportTranslationService.translateText(
        alert.proposedSolution,
      ),
      resolucaoEfetuada: await _exportTranslationService.translateText(
        alert.resolucaoEfetuada,
      ),
    );
  }

  pw.Widget _buildHeader(SafetyAlertRecord alert, String projectName) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FAFC'),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _englishTranslations.translate('safety_alerts'),
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#0F172A'),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            alert.code,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1D4ED8'),
            ),
          ),
          if (projectName.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              projectName,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildMetaGrid(SafetyAlertRecord alert) {
    return pw.Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildMetaCard(
          _englishTranslations.translate('safety_alert_category'),
          _englishTranslations.translate(
            'safety_alert_category_${alert.category.value}',
          ),
        ),
        _buildMetaCard(
          _englishTranslations.translate('safety_alert_status'),
          _englishTranslations.translate(
            'safety_alert_status_${alert.status.value}',
          ),
        ),
        _buildMetaCard(
          _englishTranslations.translate('safety_alert_destination_to'),
          alert.destinationTo,
        ),
        _buildMetaCard(
          _englishTranslations.translate('safety_alert_department'),
          alert.department,
        ),
        _buildMetaCard(
          _englishTranslations.translate('safety_alert_created_at'),
          _formatDate(alert.createdAt),
        ),
        _buildMetaCard(
          _englishTranslations.translate('safety_alert_updated_at'),
          _formatDate(alert.updatedAt),
        ),
      ],
    );
  }

  pw.Widget _buildMetaCard(String label, String value) {
    return pw.Container(
      width: 122,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex('#D1D5DB')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _safeText(value),
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSection({required String title, required pw.Widget child}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColor.fromHex('#D1D5DB')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#111827'),
            ),
          ),
          pw.SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  pw.Widget _buildImageSection(String title, List<pw.MemoryImage> images) {
    return _buildSection(
      title: title,
      child: pw.Wrap(
        spacing: 10,
        runSpacing: 10,
        children: images
            .map(
              (image) => pw.Container(
                width: 150,
                height: 110,
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: PdfColor.fromHex('#D1D5DB')),
                ),
                child: pw.ClipRRect(
                  horizontalRadius: 10,
                  verticalRadius: 10,
                  child: pw.Image(image, fit: pw.BoxFit.cover),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<List<pw.MemoryImage>> _loadImageEvidence(
    List<SafetyAlertEvidence> evidence,
  ) async {
    final images = <pw.MemoryImage>[];
    for (final item in evidence) {
      if (!item.contentType.startsWith('image/')) {
        continue;
      }

      try {
        final response = await http.get(Uri.parse(item.url));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          images.add(pw.MemoryImage(response.bodyBytes));
        }
      } catch (_) {
        // Ignore broken image evidence during export.
      }
    }
    return images;
  }

  String _buildFileName(SafetyAlertRecord alert) {
    return '${alert.code.toLowerCase()}_safety_alert.pdf';
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString().padLeft(4, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  String _safeText(String value) {
    return value.trim().isEmpty ? '-' : value.trim();
  }
}
