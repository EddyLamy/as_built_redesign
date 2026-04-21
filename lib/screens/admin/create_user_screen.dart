// lib/screens/admin/create_user_screen.dart
// Só acessível a Directors e Site Managers

import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../providers/permission_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../widgets/common/permission_guard.dart';
import '../../widgets/gradient_button.dart';

class CreateUserScreen extends ConsumerWidget {
  const CreateUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenGuard(
      condition: (p) => p.canCreateUsers,
      message: 'Só Directors e Site Managers podem criar utilizadores.',
      child: const _CreateUserContent(),
    );
  }
}

class _CreateUserContent extends ConsumerStatefulWidget {
  const _CreateUserContent();

  @override
  ConsumerState<_CreateUserContent> createState() => _CreateUserContentState();
}

class _CreateUserContentState extends ConsumerState<_CreateUserContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();

  GlobalRole _selectedRole = GlobalRole.user;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // NOTA: Criar utilizador com Firebase Auth sem fazer logout do current user
      // requer Firebase Admin SDK (Cloud Functions).
      //
      // Solução alternativa usada aqui:
      // 1. O admin preenche os dados
      // 2. Guardamos um "pending user" no Firestore
      // 3. O utilizador recebe as credenciais e faz login
      // 4. No primeiro login, o perfil é carregado automaticamente
      //
      // Para implementar criação real via Admin SDK:
      // https://firebase.google.com/docs/auth/admin/manage-users

      final currentUid =
          ref.read(currentAppUserProvider).asData?.value?.uid ?? '';

      // Verificar se email já existe
      final existing =
          await UserService().getUserByEmail(_emailController.text.trim());
      if (existing != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Já existe um utilizador com este email'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Criar entrada no Firestore como "pendente"
      // O uid será gerado quando o utilizador fizer o primeiro login
      // Por agora usamos email como identificador temporário
      final tempUid = 'pending_${DateTime.now().millisecondsSinceEpoch}';

      final newUser = AppUser(
        uid: tempUid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        globalRole: _selectedRole,
        createdAt: DateTime.now(),
        createdBy: currentUid,
      );

      await UserService().saveUserProfile(newUser);

      if (mounted) {
        _showSuccessDialog(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _companyController.clear();
        _phoneController.clear();
        setState(() => _selectedRole = GlobalRole.user);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(
      {required String email, required String password, required String name}) {
    showLiquidDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Utilizador Criado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Partilha estas credenciais com $name:'),
            const SizedBox(height: 12),
            _CredentialRow(label: 'Email', value: email),
            const SizedBox(height: 4),
            _CredentialRow(label: 'Password', value: password),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.amber),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'O utilizador deve alterar a password no primeiro login.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: const DashboardShortcutTitle(
          child: Text('Criar Utilizador'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Dados pessoais ──────────────────────────────────
                  const _SectionHeader(
                      icon: Icons.person, label: 'Dados Pessoais'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Campo obrigatório'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obrigatório';
                      }
                      if (!v.contains('@')) return 'Email inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password Inicial *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      if (v.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      labelText: 'Empresa (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone (opcional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Role Global ──────────────────────────────────────
                  const _SectionHeader(
                      icon: Icons.security, label: 'Role na Aplicação'),
                  const SizedBox(height: 4),
                  Text(
                    'Define o nível de acesso global. Pode ser ajustado por projeto.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),

                  ...GlobalRole.values.map((role) => _GlobalRoleOption(
                        role: role,
                        isSelected: _selectedRole == role,
                        onTap: () => setState(() => _selectedRole = role),
                      )),
                  const SizedBox(height: 32),

                  // ── Botão ────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      label: 'Criar Utilizador',
                      icon: Icons.person_add,
                      onPressed: _createUser,
                      isLoading: _isLoading,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}

class _GlobalRoleOption extends StatelessWidget {
  final GlobalRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _GlobalRoleOption({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  String get _description {
    switch (role) {
      case GlobalRole.director:
        return 'Acesso total a toda a aplicação e todos os projetos';
      case GlobalRole.siteManager:
        return 'Pode criar projetos e gerir utilizadores';
      case GlobalRole.user:
        return 'Acesso apenas aos projetos onde for convidado';
    }
  }

  Color get _color {
    switch (role) {
      case GlobalRole.director:
        return Colors.purple;
      case GlobalRole.siteManager:
        return Colors.blue;
      case GlobalRole.user:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? _color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? _color.withValues(alpha: 0.06) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? _color : Colors.grey,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role.label,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? _color : null)),
                  Text(_description,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;
  const _CredentialRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text('$label:',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
