import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
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
    final t = TranslationHelper.of(context);
    final turbinasAsync =
        ref.watch(projectTurbinasByProjectProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: DashboardShortcutTitle(
          child: Text(projectName),
        ),
      ),
      body: turbinasAsync.when(
        data: (turbinas) {
          if (turbinas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wind_power_outlined,
                    size: 64,
                    color: AppColors.mediumGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.translate('no_turbines_found'),
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.invalidate(
                        projectTurbinasByProjectProvider(projectId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(t.translate('try_again')),
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
              final rawStatus = (turbina.status).toString();
              final normalizedStatus = rawStatus.startsWith('status_')
                  ? rawStatus.substring(7)
                  : rawStatus;

              // Status color
              Color statusColor;
              IconData statusIcon;

              switch (normalizedStatus) {
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
                      color: statusColor.withValues(alpha: 0.1),
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
                            t.translateStatus(rawStatus),
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
                    // Navegar para o mesmo ecrã de fases usado no PC
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TurbineInstallationDetailsScreen(
                          turbineId: turbina.id,
                          turbineName: turbina.nome,
                          turbineModel: 'V150',
                          turbineSequence: turbina.sequenceNumber,
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
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: 16),
              Text(
                t.translate('error_loading_turbines'),
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ref.invalidate(
                    projectTurbinasByProjectProvider(projectId),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: Text(t.translate('try_again')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
