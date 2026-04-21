import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../providers/permission_provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';

part 'commissioning_screen.g.dart';

// ============================================================================
// 🔬 COMMISSIONING SCREEN
// ============================================================================

@riverpod
class SelectedCommissioningPhase extends _$SelectedCommissioningPhase {
  @override
  String build() => 'preCommissioning';

  void setPhase(String phase) => state = phase;
}

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

  final List<Map<String, dynamic>> _mainPhases = [
    {
      'id': 'preCommissioning',
      'icon': Icons.science,
      'nameKey': 'pre_commissioning_tests',
      'color': const Color(0xFF2196F3),
    },
    {
      'id': 'commissioning',
      'icon': Icons.power_settings_new,
      'nameKey': 'commissioning',
      'color': const Color(0xFF4CAF50),
    },
    {
      'id': 'finalAcceptance',
      'icon': Icons.check_circle,
      'nameKey': 'final_acceptance',
      'color': const Color(0xFF9C27B0),
    },
  ];

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

    // Buscar projectId via provider global e verificar permissões
    final projectId = ref.watch(accessibleSelectedProjectIdProvider);
    final permissions = ref.watch(permissionProvider(projectId));
    final canEdit = permissions.canManageInstallation;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: DashboardShortcutTitle(
          child: Text(
            '🔬 ${widget.turbineName} - ${t.translate('commissioning')}',
          ),
        ),
      ),
      body: Column(
        children: [
          _buildPhasesBar(selectedPhase, t),
          Expanded(
            child: _buildSubPhasesContent(selectedPhase, t, canEdit),
          ),
        ],
      ),
    );
  }

  Widget _buildPhasesBar(String selectedPhase, TranslationHelper t) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _mainPhases.length,
        itemBuilder: (context, index) {
          final phase = _mainPhases[index];
          final isSelected = selectedPhase == phase['id'];

          return GestureDetector(
            onTap: () {
              ref
                  .read(selectedCommissioningPhaseProvider.notifier)
                  .setPhase(phase['id'] as String);
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
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
                          color:
                              (phase['color'] as Color).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
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

  Widget _buildSubPhasesContent(
      String selectedPhase, TranslationHelper t, bool canEdit) {
    final subPhases = _getSubPhases()[selectedPhase] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subPhases.length,
      itemBuilder: (context, index) {
        final subPhase = subPhases[index];
        return _buildSubPhaseCard(subPhase, t, canEdit);
      },
    );
  }

  Widget _buildSubPhaseCard(
      Map<String, String> subPhase, TranslationHelper t, bool canEdit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        leading: Text(
          subPhase['icon']!,
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(
          t.translate(subPhase['nameKey']!),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.check_circle_outline,
          color: AppColors.mediumGray,
          size: 24,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
                        enabled: canEdit,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(
                        label: t.translate('endDate'),
                        hint: 'DD/MM/AAAA',
                        enabled: canEdit,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Responsável
                _buildTextField(
                  label: t.translate('responsible'),
                  hint: t.translate('enter_responsible_name'),
                  icon: Icons.person,
                  enabled: canEdit,
                ),
                const SizedBox(height: 12),

                // Observações
                _buildTextField(
                  label: t.translate('observations'),
                  hint: t.translate('add_notes_optional'),
                  icon: Icons.notes,
                  maxLines: 4,
                  enabled: canEdit,
                ),
                const SizedBox(height: 12),

                // Fotos
                _buildPhotoField(t),
                const SizedBox(height: 16),

                // ════════════════════════════════════════════════
                // Botões — só visíveis para quem tem permissão
                // ════════════════════════════════════════════════
                if (canEdit)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Marcar como N/A
                          },
                          icon: const Icon(Icons.not_interested),
                          label: const Text('N/A'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Salvar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    t.translate('data_saved_successfully')),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                          },
                          icon: const Icon(Icons.save),
                          label: Text(t.translate('save')),
                        ),
                      ),
                    ],
                  )
                else
                  // Mensagem subtil para visitors
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.visibility,
                            size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 8),
                        Text(
                          'Modo leitura',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: !enabled,
            fillColor: enabled ? null : Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: !enabled,
            fillColor: enabled ? null : Colors.grey.shade50,
          ),
          onTap: enabled
              ? () async {
                  await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                }
              : null,
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            await _imagePicker.pickImage(source: ImageSource.camera);
          },
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.borderGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderGray, width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt,
                      size: 40, color: AppColors.mediumGray),
                  const SizedBox(height: 8),
                  Text(
                    t.translate('add_photo'),
                    style: const TextStyle(color: AppColors.mediumGray),
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
