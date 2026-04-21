// lib/screens/admin/user_management_screen.dart
// Só acessível a Directors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../providers/permission_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../widgets/background_watermark.dart';
import '../../widgets/common/permission_guard.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({
    super.key,
    this.embeddedInDesktopShell = false,
  });

  final bool embeddedInDesktopShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenGuard(
      condition: (p) => p.isDirector,
      message: 'Só Directors podem gerir utilizadores globais.',
      child: _UserManagementContent(
        embeddedInDesktopShell: embeddedInDesktopShell,
      ),
    );
  }
}

class _UserManagementContent extends ConsumerWidget {
  const _UserManagementContent({
    this.embeddedInDesktopShell = false,
  });

  final bool embeddedInDesktopShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final currentUser = ref.watch(currentAppUserProvider).asData?.value;

    final screenBody = Stack(
      children: [
        const BackgroundWatermark(
          size: 560,
          opacity: 0.03,
          alignment: Alignment.bottomRight,
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                color: AppColors.primaryBlue.withValues(alpha: 0.07),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.primaryBlue, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Roles globais',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _RoleLegendRow(
                        role: GlobalRole.director,
                        description:
                            'Acesso total — gere utilizadores, todos os projetos e configurações',
                      ),
                      const SizedBox(height: 6),
                      _RoleLegendRow(
                        role: GlobalRole.siteManager,
                        description:
                            'Gere projetos e equipas — não pode alterar roles globais',
                      ),
                      const SizedBox(height: 6),
                      _RoleLegendRow(
                        role: GlobalRole.user,
                        description:
                            'Acesso base — só vê projetos onde foi adicionado como membro',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erro: $e')),
                data: (users) {
                  if (users.isEmpty) {
                    return const Center(child: Text('Sem utilizadores.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final isCurrentUser = currentUser?.uid == user.uid;
                      return _UserCard(
                        user: user,
                        isSelf: isCurrentUser,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );

    if (embeddedInDesktopShell) {
      return screenBody;
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: DashboardShortcutTitle(
          child: Row(
            children: [
              const Icon(Icons.manage_accounts, color: Colors.white),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gestão de Utilizadores'),
                  Text(
                    'Roles e acessos globais',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: screenBody,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CARD DE UTILIZADOR
// ══════════════════════════════════════════════════════════════════════════════

class _UserCard extends ConsumerStatefulWidget {
  final AppUser user;
  final bool isSelf;

  const _UserCard({required this.user, required this.isSelf});

  @override
  ConsumerState<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<_UserCard> {
  bool _isLoading = false;

  Color get _roleColor {
    switch (widget.user.globalRole) {
      case GlobalRole.director:
        return Colors.indigo;
      case GlobalRole.siteManager:
        return AppColors.warningOrange;
      case GlobalRole.user:
        return AppColors.mediumGray;
    }
  }

  String get _initial {
    final cleaned = widget.user.name.replaceAll(RegExp(r'^\d+'), '').trim();
    return (cleaned.isNotEmpty ? cleaned : widget.user.name)[0].toUpperCase();
  }

  Future<void> _updateRole(GlobalRole newRole) async {
    if (newRole == widget.user.globalRole) return;
    setState(() => _isLoading = true);
    try {
      await UserService().updateUser(widget.user.copyWith(globalRole: newRole));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.user.name} → ${newRole.label}'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleActive() async {
    setState(() => _isLoading = true);
    try {
      if (widget.user.isActive) {
        await UserService().deactivateUser(widget.user.uid);
      } else {
        await UserService().reactivateUser(widget.user.uid);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: $e'), backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInactive = !widget.user.isActive;

    return Card(
      elevation: isInactive ? 0 : 1,
      color: isInactive ? Colors.grey[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isInactive ? BorderSide(color: Colors.grey[200]!) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ── Avatar ────────────────────────────────────────────────────
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isInactive
                      ? Colors.grey[200]
                      : _roleColor.withValues(alpha: 0.15),
                  child: Text(
                    _initial,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isInactive ? Colors.grey[400] : _roleColor,
                    ),
                  ),
                ),
                if (widget.isSelf)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Info ──────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.user.name + (widget.isSelf ? ' (eu)' : ''),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isInactive
                                ? AppColors.mediumGray
                                : AppColors.darkGray,
                          ),
                        ),
                      ),
                      if (isInactive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Inativo',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.mediumGray),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mediumGray),
                  ),
                  if (widget.user.company?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.business,
                            size: 11, color: AppColors.mediumGray),
                        const SizedBox(width: 4),
                        Text(
                          widget.user.company!,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.mediumGray),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Controlos ─────────────────────────────────────────────────
            if (_isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Dropdown de role — desactivado para o próprio utilizador
                  // (para não se auto-rebaixar acidentalmente)
                  widget.isSelf
                      ? _RoleChip(role: widget.user.globalRole)
                      : _RoleDropdown(
                          currentRole: widget.user.globalRole,
                          onChanged: _updateRole,
                          enabled: !isInactive,
                        ),

                  const SizedBox(height: 6),

                  // Toggle ativo/inativo — não se pode desativar a si próprio
                  if (!widget.isSelf)
                    GestureDetector(
                      onTap: _toggleActive,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isInactive
                                ? Icons.toggle_off_outlined
                                : Icons.toggle_on,
                            size: 18,
                            color: isInactive
                                ? AppColors.mediumGray
                                : AppColors.successGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isInactive ? 'Ativar' : 'Ativo',
                            style: TextStyle(
                              fontSize: 11,
                              color: isInactive
                                  ? AppColors.mediumGray
                                  : AppColors.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DROPDOWN DE ROLE
// ══════════════════════════════════════════════════════════════════════════════

class _RoleDropdown extends StatelessWidget {
  final GlobalRole currentRole;
  final ValueChanged<GlobalRole> onChanged;
  final bool enabled;

  const _RoleDropdown({
    required this.currentRole,
    required this.onChanged,
    this.enabled = true,
  });

  Color _colorFor(GlobalRole r) {
    switch (r) {
      case GlobalRole.director:
        return Colors.indigo;
      case GlobalRole.siteManager:
        return AppColors.warningOrange;
      case GlobalRole.user:
        return AppColors.mediumGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: enabled
            ? _colorFor(currentRole).withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: enabled
              ? _colorFor(currentRole).withValues(alpha: 0.4)
              : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GlobalRole>(
          value: currentRole,
          isDense: true,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: enabled ? _colorFor(currentRole) : AppColors.mediumGray,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            size: 16,
            color: enabled ? _colorFor(currentRole) : AppColors.mediumGray,
          ),
          onChanged: enabled ? (v) => v != null ? onChanged(v) : null : null,
          items: GlobalRole.values.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _colorFor(role),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(role.label,
                      style: TextStyle(
                          fontSize: 12,
                          color: _colorFor(role),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Chip estático (para o próprio utilizador) ──────────────────────────────

class _RoleChip extends StatelessWidget {
  final GlobalRole role;
  const _RoleChip({required this.role});

  Color get _color {
    switch (role) {
      case GlobalRole.director:
        return Colors.indigo;
      case GlobalRole.siteManager:
        return AppColors.warningOrange;
      case GlobalRole.user:
        return AppColors.mediumGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        role.label,
        style:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _color),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LEGENDA DE ROLES
// ══════════════════════════════════════════════════════════════════════════════

class _RoleLegendRow extends StatelessWidget {
  final GlobalRole role;
  final String description;
  const _RoleLegendRow({required this.role, required this.description});

  Color get _color {
    switch (role) {
      case GlobalRole.director:
        return Colors.indigo;
      case GlobalRole.siteManager:
        return AppColors.warningOrange;
      case GlobalRole.user:
        return AppColors.mediumGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            role.label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: _color),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(fontSize: 12, color: AppColors.mediumGray),
          ),
        ),
      ],
    );
  }
}
