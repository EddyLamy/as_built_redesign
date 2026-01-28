import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/localization/translation_helper.dart';
import '../services/report_service.dart';

/// Dialog para gerar relatórios
/// Permite selecionar formato (Excel/PDF) e fases para incluir
class GenerateReportDialog extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const GenerateReportDialog({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  ConsumerState<GenerateReportDialog> createState() =>
      _GenerateReportDialogState();
}

class _GenerateReportDialogState extends ConsumerState<GenerateReportDialog> {
  // Formato selecionado
  String _selectedFormat = 'excel'; // 'excel' ou 'pdf'

  // Fases selecionadas
  final Map<String, bool> _selectedPhases = {
    'recepcao': false,
    'preparacao': false,
    'preAssemblagem': false,
    'assemblagem': false,
    'torqueTensionamento': false,
    'fasesFinais': false,
  };

  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final allSelected = _selectedPhases.values.every((v) => v);
    final noneSelected = _selectedPhases.values.every((v) => !v);

    return Dialog(
      child: Container(
        width: 500,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════════
            // HEADER
            // ═══════════════════════════════════════════════════════════
            Row(
              children: [
                Icon(Icons.description, color: AppColors.primaryBlue, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.translate('generate_report'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.projectName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════
            // SELEÇÃO DE FORMATO
            // ═══════════════════════════════════════════════════════════
            Text(
              t.translate('report_format'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildFormatOption(
                    'excel',
                    Icons.table_chart,
                    'Excel (.xlsx)',
                    AppColors.successGreen,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildFormatOption(
                    'pdf',
                    Icons.picture_as_pdf,
                    'PDF',
                    AppColors.errorRed,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════
            // SELEÇÃO DE FASES
            // ═══════════════════════════════════════════════════════════
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.translate('select_phases'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedPhases.updateAll((key, value) => true);
                        });
                      },
                      child: Text(
                        t.translate('select_all'),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedPhases.updateAll((key, value) => false);
                        });
                      },
                      child: Text(
                        t.translate('clear_all'),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderGray),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildPhaseCheckbox(
                    'recepcao',
                    '📦 ${t.translate('reception')}',
                  ),
                  Divider(height: 1),
                  _buildPhaseCheckbox(
                    'preparacao',
                    '📋 ${t.translate('preparation')}',
                  ),
                  Divider(height: 1),
                  _buildPhaseCheckbox(
                    'preAssemblagem',
                    '🔧 ${t.translate('pre_assembly')}',
                  ),
                  Divider(height: 1),
                  _buildPhaseCheckbox(
                    'assemblagem',
                    '🏗️ ${t.translate('assembly')}',
                  ),
                  Divider(height: 1),
                  _buildPhaseCheckbox(
                    'torqueTensionamento',
                    '🔩 ${t.translate('torqueTensioning')}',
                  ),
                  Divider(height: 1),
                  _buildPhaseCheckbox(
                    'fasesFinais',
                    '✅ ${t.translate('final_phases')}',
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════
            // INFO MESSAGE
            // ═══════════════════════════════════════════════════════════
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.primaryBlue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.translate('report_email_info'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════
            // ACTIONS
            // ═══════════════════════════════════════════════════════════
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isGenerating ? null : () => Navigator.pop(context),
                  child: Text(t.translate('cancel')),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed:
                      noneSelected || _isGenerating ? null : _generateReport,
                  icon: _isGenerating
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.send),
                  label: Text(
                    _isGenerating
                        ? t.translate('generating')
                        : t.translate('generate_and_send'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: OPÇÃO DE FORMATO
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildFormatOption(
    String format,
    IconData icon,
    String label,
    Color color,
  ) {
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFormat = format;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppColors.borderGray,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.mediumGray,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WIDGET: CHECKBOX DE FASE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildPhaseCheckbox(String phaseKey, String label) {
    return CheckboxListTile(
      title: Text(
        label,
        style: TextStyle(fontSize: 14),
      ),
      value: _selectedPhases[phaseKey],
      onChanged: (value) {
        setState(() {
          _selectedPhases[phaseKey] = value ?? false;
        });
      },
      activeColor: AppColors.primaryBlue,
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MÉTODO: GERAR RELATÓRIO
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    try {
      final reportService = ref.read(reportServiceProvider);

      // Obter fases selecionadas
      final selectedPhasesList = _selectedPhases.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Gerar relatório
      await reportService.generateAndSendReport(
        projectId: widget.projectId,
        projectName: widget.projectName,
        format: _selectedFormat,
        selectedPhases: selectedPhasesList,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              TranslationHelper.of(context).translate('report_sent_success'),
            ),
            backgroundColor: AppColors.successGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${TranslationHelper.of(context).translate('error')}: $e'),
            backgroundColor: AppColors.errorRed,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
