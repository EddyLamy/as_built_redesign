import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/localization/translation_helper.dart';
import '../services/report_service.dart';
import '../providers/locale_provider.dart';

/// Dialog para gerar relatórios - VERSÃO COM GRUAS
/// Inclui relatórios de Gruas de Pads e Gruas Gerais
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
  bool _isCompleteReport = false;
  final Map<String, bool> _selectedPhases = {
    'recepcao': false,
    'preparacao': false,
    'preAssemblagem': false,
    'assemblagem': false,
    'torqueTensionamento': false,
    'fasesFinais': false,
    'gruasPads': false, // 🆕 GRUAS DE PADS
    'gruasGerais': false, // 🆕 GRUAS GERAIS
  };
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final noneSelected = _selectedPhases.values.every((v) => !v);

    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.85;

    return Dialog(
      child: Container(
        width: 500,
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.description,
                      color: AppColors.primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.translate('generate_report'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.projectName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // CONTEÚDO SCROLLABLE
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OPCAO DE RELATORIO COMPLETO
                    CheckboxListTile(
                      title: Text(
                        t.translate('report_complete'),
                        style: const TextStyle(fontSize: 14),
                      ),
                      value: _isCompleteReport,
                      onChanged: (value) =>
                          setState(() => _isCompleteReport = value ?? false),
                      activeColor: AppColors.primaryBlue,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 12),

                    // SELEÇÃO DE FASES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.translate('select_phases'),
                          style: const TextStyle(
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
                                  _selectedPhases
                                      .updateAll((key, value) => true);
                                });
                              },
                              child: Text(
                                t.translate('select_all'),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPhases
                                      .updateAll((key, value) => false);
                                });
                              },
                              child: Text(
                                t.translate('clear_all'),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderGray),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // ══════════════════════════════════════════════
                          // FASES DE INSTALAÇÃO
                          // ══════════════════════════════════════════════
                          _buildPhaseCheckbox(
                            'recepcao',
                            Icons.inventory_2_outlined,
                            t.translate('reception'),
                          ),
                          const Divider(height: 1),
                          _buildPhaseCheckbox(
                            'preparacao',
                            Icons.handyman_outlined,
                            t.translate('preparation'),
                          ),
                          const Divider(height: 1),
                          _buildPhaseCheckbox(
                            'preAssemblagem',
                            Icons.build_outlined,
                            t.translate('pre_assembly'),
                          ),
                          const Divider(height: 1),
                          _buildPhaseCheckbox(
                            'assemblagem',
                            Icons.construction_outlined,
                            t.translate('assembly'),
                          ),
                          const Divider(height: 1),
                          _buildPhaseCheckbox(
                            'torqueTensionamento',
                            Icons.bolt_outlined,
                            t.translate('torqueTensioning'),
                          ),
                          const Divider(height: 1),
                          _buildPhaseCheckbox(
                            'fasesFinais',
                            Icons.task_alt_outlined,
                            t.translate('final_phases'),
                          ),

                          // ══════════════════════════════════════════════
                          // 🆕 SEPARADOR VISUAL
                          // ══════════════════════════════════════════════
                          Container(
                            height: 8,
                            color: AppColors.borderGray.withOpacity(0.3),
                          ),

                          // ══════════════════════════════════════════════
                          // 🆕 GRUAS
                          // ══════════════════════════════════════════════
                          _buildPhaseCheckbox(
                            'gruasPads',
                            Icons.precision_manufacturing_outlined,
                            t.translate('cranes_pads_report'),
                          ),
                          const Divider(height: 1),
                          _buildPhaseCheckbox(
                            'gruasGerais',
                            Icons.local_shipping_outlined,
                            t.translate('cranes_general_report'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // INFO MESSAGE
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.primaryBlue, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'O relatório será gerado e aberto automaticamente',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // ACTIONS
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isGenerating ? null : () => Navigator.pop(context),
                    child: Text(t.translate('cancel')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed:
                        noneSelected || _isGenerating ? null : _generateReport,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isGenerating
                          ? t.translate('generating')
                          : t.translate('generate_and_send'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCheckbox(String phaseKey, IconData icon, String label) {
    return CheckboxListTile(
      title: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.darkGray),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
      value: _selectedPhases[phaseKey],
      onChanged: (value) =>
          setState(() => _selectedPhases[phaseKey] = value ?? false),
      activeColor: AppColors.primaryBlue,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    try {
      final reportService = ref.read(reportServiceProvider);
      final selectedPhasesList = _selectedPhases.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      await reportService.generateAndSendReport(
        projectId: widget.projectId,
        projectName: widget.projectName,
        completeReport: _isCompleteReport,
        selectedPhases: selectedPhasesList,
        language: ref.read(localeStringProvider),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório gerado com sucesso!'),
            backgroundColor: AppColors.successGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}
