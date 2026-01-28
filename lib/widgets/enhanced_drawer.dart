import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../screens/auth/login_screen.dart';
import '../../widgets/create_project_dialog.dart';
import '../widgets/generate_report_dialog.dart';

// ============================================================================
// 🏗️ IMPORT DA TELA DE INSTALAÇÃO
// ============================================================================
import '../screens/installation/installation_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';

// ============================================================================
// 🎯 MÓDULOS DO SISTEMA
// ============================================================================
enum AppModule {
  asBuilt,
  installation,
}

// Provider para gerenciar o módulo atual
final currentModuleProvider =
    StateProvider<AppModule>((ref) => AppModule.asBuilt);

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
                Icon(Icons.wind_power, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
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
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(4),
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
                      ref.read(currentModuleProvider.notifier).state =
                          AppModule.asBuilt;
                      Navigator.pop(context);

                      // Navega para Dashboard se não estiver lá
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => DashboardScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: _ModuleButton(
                    label: t.translate('installation'),
                    icon: Icons.construction,
                    isSelected: currentModule == AppModule.installation,
                    onTap: () {
                      ref.read(currentModuleProvider.notifier).state =
                          AppModule.installation;
                      Navigator.pop(context);

                      // ✅ NAVEGA PARA A TELA DE INSTALAÇÃO
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => InstallationScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Divider(),

          // ============================================================================
          // 📱 MENU PRINCIPAL
          // ============================================================================
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Dashboard
                ListTile(
                  leading: Icon(Icons.dashboard, color: AppColors.primaryBlue),
                  title: Text(t.translate('dashboard')),
                  selected: currentModule == AppModule.asBuilt,
                  selectedTileColor: AppColors.primaryBlue.withOpacity(0.1),
                  onTap: () {
                    ref.read(currentModuleProvider.notifier).state =
                        AppModule.asBuilt;
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => DashboardScreen()),
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
                  leading: Icon(Icons.analytics, color: AppColors.mediumGray),
                  title: Text(t.translate('reports')),
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoonDialog(context);
                  },
                ),

                // Equipe
                ListTile(
                  leading: Icon(Icons.group, color: AppColors.mediumGray),
                  title: Text(t.translate('team')),
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoonDialog(context);
                  },
                ),

                Divider(),

                // Configurações
                ListTile(
                  leading: Icon(Icons.settings, color: AppColors.mediumGray),
                  title: Text(t.translate('settings')),
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoonDialog(context);
                  },
                ),

                // Ajuda
                ListTile(
                  leading:
                      Icon(Icons.help_outline, color: AppColors.mediumGray),
                  title: Text(t.translate('help')),
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
              ],
            ),
          ),

          ListTile(
            leading: Icon(Icons.description),
            title: Text('Relatórios'),
            onTap: () {
              Navigator.pop(context); // Fecha drawer

              // Obter projeto selecionado
              final projectId = ref.read(selectedProjectIdProvider);

              if (projectId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Por favor, selecione um projeto primeiro'),
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
          // ============================================================================
          // 🚪 LOGOUT
          // ============================================================================
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.errorRed),
            title: Text(t.translate('logout')),
            onTap: () => _handleLogout(context),
          ),
          SizedBox(height: 8),
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

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryBlue),
            SizedBox(width: 12),
            Text('Em Breve'),
          ],
        ),
        content: Text(
            'Esta funcionalidade está em desenvolvimento e estará disponível em breve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primaryBlue),
            SizedBox(width: 12),
            Text('Ajuda'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Central de Ajuda',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 12),
            _HelpItem(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@asbuilt.com',
            ),
            _HelpItem(
              icon: Icons.phone,
              title: 'Telefone',
              subtitle: '+351 XXX XXX XXX',
            ),
            _HelpItem(
              icon: Icons.book,
              title: 'Documentação',
              subtitle: 'docs.asbuilt.com',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Logout'),
        content: Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: Text('Sair'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
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
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12),
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
            SizedBox(height: 4),
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

// ============================================================================
// ℹ️ ITEM DE AJUDA
// ============================================================================
class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.mediumGray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
