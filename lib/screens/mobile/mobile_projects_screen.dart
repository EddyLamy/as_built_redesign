import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import 'mobile_turbines_screen.dart';

/// Tela de seleção de projetos (Mobile)
class MobileProjectsScreen extends ConsumerWidget {
  const MobileProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(userProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projetos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_off,
                    size: 64,
                    color: AppColors.mediumGray,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum projeto disponível',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Contacte o administrador',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.lightGray,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.work,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    project.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.wind_power,
                            size: 16,
                            color: AppColors.mediumGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${project.numeroTurbinas} Turbinas',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.mediumGray,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              project.localizacao ?? 'Sem localização',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.mediumGray,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.mediumGray,
                  ),
                  onTap: () {
                    // Selecionar projeto
                    ref
                        .read(selectedProjectIdProvider.notifier)
                        .setValue(project.id);

                    // Navegar para turbinas
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MobileTurbinesScreen(
                          projectId: project.id,
                          projectName: project.nome,
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
              const Text(
                'Erro ao carregar projetos',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
