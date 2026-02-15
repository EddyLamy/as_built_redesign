import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../screens/auth/login_screen.dart';
import '../../widgets/create_project_dialog.dart';
import '../widgets/generate_report_dialog.dart';
import '../providers/app_providers.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/team/team_management_screen.dart';
import '../screens/help/help_screen.dart';
import '../screens/installation/installation_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/mobile/gruas_gerais_screen.dart';

part 'enhanced_drawer.g.dart';

// ============================================================================
// 🎯 MÓDULOS DO SISTEMA
// ============================================================================
enum AppModule {
  asBuilt,
  installation,
}

// Riverpod 3.x annotation-based provider for current module selection
@riverpod
class CurrentModule extends _$CurrentModule {
  @override
  AppModule build() => AppModule.asBuilt;

  void setModule(AppModule module) => state = module;
}

class EnhancedDrawer extends ConsumerWidget {
  const EnhancedDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);
    print('🔵 TESTE TRADUÇÃO: ${t.translate('installation')}'); // Adicione isto
    final currentModule = ref.watch(currentModuleProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          // ============================================================================
          // 📋 HEADER DO DRAWER
          // ============================================================================
          DrawerHeader(
            decoration: BoxDecoration(gradient: AppColors.primaryGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.wind_power, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'As-Built System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'user@example.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================================
          // 🔄 SELETOR DE MÓDULO
          // ============================================================================
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.borderGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModuleButton(
                    label: t.translate('as_built'),
                    icon: Icons.assignment_turned_in,
                    isSelected: currentModule == AppModule.asBuilt,
                    onTap: () {
                      ref
                          .read(currentModuleProvider.notifier)
                          .setModule(AppModule.asBuilt);
                      Navigator.pop(context);

                      // Navega para Dashboard se não estiver lá
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const DashboardScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _ModuleButton(
                    label: t.translate('installation'),
                    icon: Icons.construction,
                    isSelected: currentModule == AppModule.installation,
                    onTap: () {
                      ref
                          .read(currentModuleProvider.notifier)
                          .setModule(AppModule.installation);
                      Navigator.pop(context);

                      // ✅ NAVEGA PARA A TELA DE INSTALAÇÃO
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InstallationScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // ============================================================================
          // 📱 MENU PRINCIPAL
          // ============================================================================
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Dashboard
                ListTile(
                  leading: Icon(Icons.dashboard, color: AppColors.mediumGray),
                  title: Text(t.translate('dashboard')),
                  selected: currentModule == AppModule.asBuilt,
                  selectedTileColor: AppColors.mediumGray.withOpacity(0.1),
                  onTap: () {
                    ref
                        .read(currentModuleProvider.notifier)
                        .setModule(AppModule.asBuilt);
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const DashboardScreen()),
                      (route) => false,
                    );
                  },
                ),

                // Novo Projeto
                ListTile(
                  leading:
                      Icon(Icons.add_business, color: AppColors.mediumGray),
                  title: Text(t.translate('new_project')),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreateProjectDialog(context);
                  },
                ),

                // Relatórios
                ListTile(
                  leading: Icon(Icons.description, color: AppColors.mediumGray),
                  title: Text(t.translate('reports')),
                  onTap: () {
                    Navigator.pop(context);

                    // Obter projeto selecionado
                    final projectId = ref.read(selectedProjectIdProvider);

                    if (projectId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Por favor, selecione um projeto primeiro'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Obter nome do projeto
                    final projectAsync = ref.read(selectedProjectProvider);

                    projectAsync.whenData((project) {
                      if (project != null) {
                        showDialog(
                          context: context,
                          builder: (_) => GenerateReportDialog(
                            projectId: project.id,
                            projectName: project.nome,
                          ),
                        );
                      }
                    });
                  },
                ),

                // Gruas Gerais
                ListTile(
                  leading: const Icon(Icons.precision_manufacturing,
                      color: AppColors.mediumGray),
                  title: Text(t.translate('general_cranes')),
                  onTap: () {
                    Navigator.pop(context);
                    final projectId = ref.read(selectedProjectIdProvider);
                    final projectAsync = ref.read(selectedProjectProvider);

                    if (projectId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Por favor, selecione um projeto primeiro'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    projectAsync.whenData((project) {
                      if (project != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GruasGeraisScreen(
                              projectId: projectId,
                              projectName: project.nome,
                            ),
                          ),
                        );
                      }
                    });
                  },
                ),

                // ══════════════════════════════════════════════════════════════
                // TEAM
                // ══════════════════════════════════════════════════════════════
                ListTile(
                  leading:
                      const Icon(Icons.groups, color: AppColors.mediumGray),
                  title: Text(t.translate('team')),
                  onTap: () {
                    final selectedProjectId =
                        ref.read(selectedProjectIdProvider);

                    if (selectedProjectId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(t.translate('select_project_first'))),
                      );
                      return;
                    }

                    Navigator.pop(context); // Fechar drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TeamManagementScreen(projectId: selectedProjectId),
                      ),
                    );
                  },
                ),

                // ══════════════════════════════════════════════════════════════
                // SETTINGS
                // ══════════════════════════════════════════════════════════════
                ListTile(
                  leading:
                      const Icon(Icons.settings, color: AppColors.mediumGray),
                  title: Text(t.translate('settings')),
                  onTap: () {
                    Navigator.pop(context); // Fechar drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),

                // ══════════════════════════════════════════════════════════════
                // HELP
                // ══════════════════════════════════════════════════════════════
                ListTile(
                  leading: const Icon(Icons.help_outline,
                      color: AppColors.mediumGray),
                  title: Text(t.translate('help')),
                  onTap: () {
                    Navigator.pop(context); // Fechar drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // ============================================================================
          // 🚪 LOGOUT
          // ============================================================================
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.errorRed),
            title: Text(t.translate('logout')),
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateProjectWizard(),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }
}

// ============================================================================
// 🎨 BOTÃO DE MÓDULO
// ============================================================================
class _ModuleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModuleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.mediumGray,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.mediumGray,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
