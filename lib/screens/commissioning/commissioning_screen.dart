import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';

// ============================================================================
// 🔬 COMMISSIONING SCREEN
// ============================================================================
//
// FASES DO COMISSIONAMENTO (10% do progresso total):
// 1. Pre-Commissioning Tests (3 sub-fases)
// 2. Commissioning (3 sub-fases)
// 3. Final Acceptance (2 sub-fases)
//
// Cada sub-fase tem: Data início/fim, Responsável, Observações, Fotos, N/A
//
// ============================================================================

final selectedCommissioningPhaseProvider =
    StateProvider<String>((ref) => 'preCommissioning');

class CommissioningScreen extends ConsumerStatefulWidget {
  final String turbineId;
  final String turbineName;

  const CommissioningScreen({
    super.key,
    required this.turbineId,
    required this.turbineName,
  });

  @override
  ConsumerState<CommissioningScreen> createState() =>
      _CommissioningScreenState();
}

class _CommissioningScreenState extends ConsumerState<CommissioningScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  // ══════════════════════════════════════════════════════════════════════════
  // 📋 DEFINIÇÃO DAS 3 FASES PRINCIPAIS
  // ══════════════════════════════════════════════════════════════════════════
  final List<Map<String, dynamic>> _mainPhases = [
    {
      'id': 'preCommissioning',
      'icon': Icons.science,
      'nameKey': 'pre_commissioning_tests',
      'color': Color(0xFF2196F3),
    },
    {
      'id': 'commissioning',
      'icon': Icons.power_settings_new,
      'nameKey': 'commissioning',
      'color': Color(0xFF4CAF50),
    },
    {
      'id': 'finalAcceptance',
      'icon': Icons.check_circle,
      'nameKey': 'final_acceptance',
      'color': Color(0xFF9C27B0),
    },
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // 📋 SUB-FASES
  // ══════════════════════════════════════════════════════════════════════════
  Map<String, List<Map<String, String>>> _getSubPhases() {
    return {
      'preCommissioning': [
        {'id': 'electricalTests', 'nameKey': 'electrical_tests', 'icon': '⚡'},
        {'id': 'mechanicalTests', 'nameKey': 'mechanical_tests', 'icon': '🔧'},
        {'id': 'safetyTests', 'nameKey': 'safety_tests', 'icon': '🛡️'},
      ],
      'commissioning': [
        {
          'id': 'coldCommissioning',
          'nameKey': 'cold_commissioning',
          'icon': '❄️'
        },
        {
          'id': 'hotCommissioning',
          'nameKey': 'hot_commissioning',
          'icon': '🔥'
        },
        {
          'id': 'performanceTests',
          'nameKey': 'performance_tests',
          'icon': '📊'
        },
      ],
      'finalAcceptance': [
        {
          'id': 'customerAcceptance',
          'nameKey': 'customer_acceptance',
          'icon': '✅'
        },
        {'id': 'handover', 'nameKey': 'handover', 'icon': '🤝'},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final selectedPhase = ref.watch(selectedCommissioningPhaseProvider);

    return Scaffold(
      appBar: AppBar(
        title:
            Text('🔬 ${widget.turbineName} - ${t.translate('commissioning')}'),
      ),
      body: Column(
        children: [
          // Barra de fases principais (3 ícones)
          _buildPhasesBar(selectedPhase, t),

          // Conteúdo: Sub-fases
          Expanded(
            child: _buildSubPhasesContent(selectedPhase, t),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 WIDGET: BARRA DE FASES PRINCIPAIS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPhasesBar(String selectedPhase, TranslationHelper t) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _mainPhases.length,
        itemBuilder: (context, index) {
          final phase = _mainPhases[index];
          final isSelected = selectedPhase == phase['id'];

          return GestureDetector(
            onTap: () {
              ref.read(selectedCommissioningPhaseProvider.notifier).state =
                  phase['id'] as String;
            },
            child: Container(
              width: 120,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? phase['color'] as Color : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? phase['color'] as Color
                      : AppColors.borderGray,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (phase['color'] as Color).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    phase['icon'] as IconData,
                    size: 32,
                    color: isSelected ? Colors.white : phase['color'] as Color,
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      t.translate(phase['nameKey'] as String),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.darkGray,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📝 WIDGET: CONTEÚDO DAS SUB-FASES
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSubPhasesContent(String selectedPhase, TranslationHelper t) {
    final subPhases = _getSubPhases()[selectedPhase] ?? [];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: subPhases.length,
      itemBuilder: (context, index) {
        final subPhase = subPhases[index];
        return _buildSubPhaseCard(subPhase, t);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 WIDGET: CARD DE SUB-FASE (EXPANSÍVEL)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSubPhaseCard(Map<String, String> subPhase, TranslationHelper t) {
    // TODO: Buscar status real do Firebase
    final isCompleted = false; // Mock

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        leading: Text(
          subPhase['icon']!,
          style: TextStyle(fontSize: 28),
        ),
        title: Text(
          t.translate(subPhase['nameKey']!),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: isCompleted
            ? Icon(Icons.check_circle, color: AppColors.successGreen, size: 28)
            : Icon(Icons.radio_button_unchecked,
                color: AppColors.mediumGray, size: 28),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Datas
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: t.translate('startDate'),
                        hint: 'DD/MM/AAAA',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(
                        label: t.translate('endDate'),
                        hint: 'DD/MM/AAAA',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Responsável
                _buildTextField(
                  label: t.translate('responsible'),
                  hint: t.translate('enter_responsible_name'),
                  icon: Icons.person,
                ),
                SizedBox(height: 12),

                // Observações
                _buildTextField(
                  label: t.translate('observations'),
                  hint: t.translate('add_notes_optional'),
                  icon: Icons.notes,
                  maxLines: 4,
                ),
                SizedBox(height: 12),

                // Fotos
                _buildPhotoField(t),
                SizedBox(height: 16),

                // Botões
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Marcar como N/A
                        },
                        icon: Icon(Icons.not_interested),
                        label: Text('N/A'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Salvar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text(t.translate('data_saved_successfully')),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        },
                        icon: Icon(Icons.save),
                        label: Text(t.translate('save')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 COMPONENTES REUTILIZÁVEIS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onTap: () async {
            await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPhotoField(TranslationHelper t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${t.translate('photos')} (${t.translate('optional')})',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: 6),
        InkWell(
          onTap: () async {
            await _imagePicker.pickImage(source: ImageSource.camera);
          },
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.borderGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderGray, width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 40, color: AppColors.mediumGray),
                  SizedBox(height: 8),
                  Text(
                    t.translate('add_photo'),
                    style: TextStyle(color: AppColors.mediumGray),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
