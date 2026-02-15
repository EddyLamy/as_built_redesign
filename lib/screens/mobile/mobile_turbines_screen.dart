import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../installation/turbine_installation_details_screen.dart';

/// Tela de seleção de turbinas (Mobile)
/// ATUALIZADA: Navega diretamente para o ecrã de instalação com fases
class MobileTurbinesScreen extends ConsumerWidget {
  final String projectId;
  final String projectName;

  const MobileTurbinesScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turbinasAsync = ref.watch(projectTurbinasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(projectName),
      ),
      body: turbinasAsync.when(
        data: (turbinas) {
          if (turbinas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wind_power_outlined,
                    size: 64,
                    color: AppColors.mediumGray,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma turbina disponível',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: turbinas.length,
            itemBuilder: (context, index) {
              final turbina = turbinas[index];

              // Status color
              Color statusColor;
              IconData statusIcon;

              switch (turbina.status) {
                case 'Planejada':
                  statusColor = AppColors.mediumGray;
                  statusIcon = Icons.schedule;
                  break;
                case 'Em Instalação':
                  statusColor = AppColors.warningOrange;
                  statusIcon = Icons.construction;
                  break;
                case 'Instalada':
                  statusColor = AppColors.successGreen;
                  statusIcon = Icons.check_circle;
                  break;
                case 'Comissionada':
                  statusColor = AppColors.primaryBlue;
                  statusIcon = Icons.verified;
                  break;
                default:
                  statusColor = AppColors.mediumGray;
                  statusIcon = Icons.help_outline;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),

                  // Icon
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.wind_power,
                      color: statusColor,
                      size: 28,
                    ),
                  ),

                  // Title e Subtitle
                  title: Text(
                    turbina.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Status
                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            turbina.status,
                            style: TextStyle(
                              fontSize: 14,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Progresso',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                              Text(
                                '${turbina.progresso.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGray,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: turbina.progresso / 100,
                              backgroundColor: AppColors.borderGray,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                statusColor,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Arrow
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.mediumGray,
                  ),

                  onTap: () {
                    // ════════════════════════════════════════════════════════
                    // ✅ CORRIGIDO: NAVEGAR PARA ECRÃ DE INSTALAÇÃO COM FASES
                    // ════════════════════════════════════════════════════════

                    // Selecionar turbina
                    ref
                        .read(selectedTurbinaIdProvider.notifier)
                        .setValue(turbina.id);

                    // Navegar para o ecrã de instalação (IGUAL AO PC)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TurbineInstallationDetailsScreen(
                          turbineId: turbina.id,
                          turbineName: turbina.nome,
                          turbineModel:
                              'V150', // ⚠️ TODO: Buscar do Firebase se necessário
                          turbineSequence:
                              index + 1, // Sequência baseada na posição
                          numberOfMiddleSections:
                              turbina.numberOfMiddleSections,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorRed,
              ),
              SizedBox(height: 16),
              Text(
                'Erro ao carregar turbinas',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.errorRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
