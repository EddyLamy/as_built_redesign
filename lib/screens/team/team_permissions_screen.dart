// lib/screens/team/team_permissions_screen.dart

import 'package:flutter/material.dart';
import 'package:as_built/widgets/liquid_glass_overlays.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../models/app_user.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_providers.dart';
import '../../providers/permission_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/gradient_button.dart';

Color _menuSurfaceColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? const Color(0xFF183046)
      : Colors.white.withValues(alpha: 0.98);
}

Color _menuBorderColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? Colors.white.withValues(alpha: 0.18)
      : const Color(0xFFD5DFEA);
}

class TeamPermissionsScreen extends ConsumerWidget {
  final String projectId;
  final String projectName;

  const TeamPermissionsScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);
    final membersAsync = ref.watch(projectMembersListProvider(projectId));
    final permissions = ref.watch(permissionProvider(projectId));
    final currentUserId = ref.watch(currentUserIdProvider);
    final projects = ref.watch(userProjectsProvider).asData?.value ?? const [];

    String? projectOwnerId;
    for (final project in projects) {
      if (project.id == projectId) {
        projectOwnerId =
            project.userId.isNotEmpty ? project.userId : project.createdBy;
        break;
      }
    }

    final isProjectOwner =
        currentUserId != null && projectOwnerId == currentUserId;
    final canManageTeam = permissions.canManageTeam ||
        permissions.isGlobalAdmin ||
        isProjectOwner;

    return Scaffold(
      body: Column(
        children: [
          // ── Info sobre roles ─────────────────────────────────────────────
          _RolesInfoCard(),

          // ── Lista de membros ─────────────────────────────────────────────
          Expanded(
            child: membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('${t.translate('error')}: $e')),
              data: (members) {
                if (members.isEmpty) {
                  return _EmptyMembers(
                    canAdd: canManageTeam,
                    onAdd: () => _showAddMemberDialog(context, ref),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _MemberPermissionCard(
                    member: members[i],
                    projectId: projectId,
                    canEdit: canManageTeam,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // FAB só para quem pode gerir equipa
      floatingActionButton: canManageTeam
          ? Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _showAddMemberDialog(context, ref),
                icon: const Icon(Icons.person_add),
                label: Text(t.translate('add_member')),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            )
          : null,
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref) {
    showLiquidDialog(
      context: context,
      builder: (_) => _AddMemberDialog(projectId: projectId),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARD DE INFO DOS ROLES
// ═══════════════════════════════════════════════════════════════════════════════

class _RolesInfoCard extends StatefulWidget {
  @override
  State<_RolesInfoCard> createState() => _RolesInfoCardState();
}

class _RolesInfoCardState extends State<_RolesInfoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: AppColors.primaryBlue.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          ListTile(
            leading:
                const Icon(Icons.info_outline, color: AppColors.primaryBlue),
            title: Text(
              t.translate('roles_info_title'),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            trailing: Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.primaryBlue,
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  _RoleInfoRow(
                    role: ProjectRole.projectManager,
                    description: t.translate('role_pm_desc'),
                  ),
                  const SizedBox(height: 8),
                  _RoleInfoRow(
                    role: ProjectRole.siteSupervisor,
                    description: t.translate('role_ss_desc'),
                  ),
                  const SizedBox(height: 8),
                  _RoleInfoRow(
                    role: ProjectRole.visitor,
                    description: t.translate('role_visitor_desc'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoleInfoRow extends StatelessWidget {
  final ProjectRole role;
  final String description;
  const _RoleInfoRow({required this.role, required this.description});

  Color get _color {
    switch (role) {
      case ProjectRole.projectManager:
        return Colors.blue;
      case ProjectRole.siteSupervisor:
        return AppColors.warningOrange;
      case ProjectRole.visitor:
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
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            role.label,
            style: TextStyle(
                fontSize: 11, color: _color, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(description, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARD DE MEMBRO
// ═══════════════════════════════════════════════════════════════════════════════

class _MemberPermissionCard extends ConsumerWidget {
  final ProjectMember member;
  final String projectId;
  final bool canEdit;

  const _MemberPermissionCard({
    required this.member,
    required this.projectId,
    required this.canEdit,
  });

  Color get _roleColor {
    switch (member.projectRole) {
      case ProjectRole.projectManager:
        return Colors.blue;
      case ProjectRole.siteSupervisor:
        return AppColors.warningOrange;
      case ProjectRole.visitor:
        return AppColors.mediumGray;
    }
  }

  String get _roleIcon {
    switch (member.projectRole) {
      case ProjectRole.projectManager:
        return '👷';
      case ProjectRole.siteSupervisor:
        return '🦺';
      case ProjectRole.visitor:
        return '👁️';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: _roleColor.withValues(alpha: 0.15),
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style:
                    TextStyle(color: _roleColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(member.email,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  if (member.company != null)
                    Text(member.company!,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                  const SizedBox(height: 6),
                  // Badges de role + relatórios
                  Wrap(
                    spacing: 6,
                    children: [
                      _Badge(
                        label: '$_roleIcon  ${member.projectRole.label}',
                        color: _roleColor,
                      ),
                      if (member.canGenerateReports)
                        _Badge(
                          label: '📊  ${t.translate('reports')}',
                          color: AppColors.successGreen,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Ações (só para quem pode editar)
            if (canEdit)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: _menuSurfaceColor(context),
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: _menuBorderColor(context)),
                ),
                onSelected: (action) => _handleAction(context, ref, action),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      const Icon(Icons.edit_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(t.translate('edit_permissions')),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(children: [
                      const Icon(Icons.person_remove,
                          size: 18, color: AppColors.errorRed),
                      const SizedBox(width: 8),
                      Text(t.translate('remove_from_project'),
                          style: const TextStyle(color: AppColors.errorRed)),
                    ]),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) async {
    final t = TranslationHelper.of(context);
    if (action == 'edit') {
      showLiquidDialog(
        context: context,
        builder: (_) => _EditPermissionsDialog(
          member: member,
          projectId: projectId,
        ),
      );
    } else if (action == 'remove') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed),
            const SizedBox(width: 8),
            Text(t.translate('remove_member')),
          ]),
          content:
              Text('${t.translate('remove_member_confirm')} ${member.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
              child: Text(t.translate('remove')),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        try {
          await UserService().removeMemberFromProject(
            projectId: projectId,
            uid: member.uid,
          );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${t.translate('error')}: $e'),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        }
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIALOG: ADICIONAR MEMBRO AO PROJETO
// ═══════════════════════════════════════════════════════════════════════════════

class _AddMemberDialog extends ConsumerStatefulWidget {
  final String projectId;
  const _AddMemberDialog({required this.projectId});

  @override
  ConsumerState<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<_AddMemberDialog> {
  AppUser? _selectedUser;
  ProjectRole _selectedRole = ProjectRole.siteSupervisor;
  bool _canGenerateReports = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final allUsersAsync = ref.watch(allUsersProvider);
    final existingUids = ref
            .watch(projectMembersListProvider(widget.projectId))
            .asData
            ?.value
            .map((m) => m.uid)
            .toSet() ??
        {};

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.person_add, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(t.translate('add_member'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Selecionar utilizador
              Text(t.translate('select_user'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              allUsersAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('${t.translate('error')}: $e'),
                data: (users) {
                  final available = users
                      .where((u) => u.isActive && !existingUids.contains(u.uid))
                      .toList();

                  if (available.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.translate('no_users_available'),
                        style: const TextStyle(
                            color: AppColors.mediumGray,
                            fontStyle: FontStyle.italic),
                      ),
                    );
                  }

                  return Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: _menuSurfaceColor(context),
                    ),
                    child: DropdownButtonFormField<AppUser>(
                      initialValue: _selectedUser,
                      hint: Text(t.translate('select_user_hint')),
                      isExpanded: true,
                      dropdownColor: _menuSurfaceColor(context),
                      borderRadius: BorderRadius.circular(18),
                      menuMaxHeight: 340,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                        isDense: true,
                        fillColor: _menuSurfaceColor(context),
                        filled: true,
                      ),
                      items: available.map((u) {
                        return DropdownMenuItem(
                          value: u,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(u.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              Text(
                                '${u.email}${u.company != null ? ' · ${u.company}' : ''}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (u) => setState(() => _selectedUser = u),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Role no projeto
              Text(t.translate('project_role'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              ...ProjectRole.values.map((role) => _RoleOptionTile(
                    role: role,
                    isSelected: _selectedRole == role,
                    onTap: () => setState(() => _selectedRole = role),
                  )),
              const SizedBox(height: 12),

              // Relatórios
              SwitchListTile(
                title: Text(t.translate('can_generate_reports')),
                subtitle: Text(t.translate('can_generate_reports_desc'),
                    style: const TextStyle(fontSize: 11)),
                value: _canGenerateReports,
                onChanged: (v) => setState(() => _canGenerateReports = v),
                activeThumbColor: AppColors.primaryBlue,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

              const Spacer(),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.translate('cancel')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed:
                        _selectedUser == null || _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check),
                    label: Text(t.translate('add')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final t = TranslationHelper.of(context);
    if (_selectedUser == null) return;
    setState(() => _isLoading = true);
    try {
      final currentUid =
          ref.read(currentAppUserProvider).asData?.value?.uid ?? '';
      final member = ProjectMember(
        uid: _selectedUser!.uid,
        name: _selectedUser!.name,
        email: _selectedUser!.email,
        company: _selectedUser!.company,
        projectRole: _selectedRole,
        canGenerateReports: _canGenerateReports,
        addedBy: currentUid,
        addedAt: DateTime.now(),
      );
      await UserService().addMemberToProject(
        projectId: widget.projectId,
        member: member,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${t.translate('member_added_to_project')}: ${_selectedUser!.name}',
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${t.translate('error')}: $e'),
              backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DIALOG: EDITAR PERMISSÕES DE MEMBRO
// ═══════════════════════════════════════════════════════════════════════════════

class _EditPermissionsDialog extends StatefulWidget {
  final ProjectMember member;
  final String projectId;

  const _EditPermissionsDialog({
    required this.member,
    required this.projectId,
  });

  @override
  State<_EditPermissionsDialog> createState() => _EditPermissionsDialogState();
}

class _EditPermissionsDialogState extends State<_EditPermissionsDialog> {
  late ProjectRole _selectedRole;
  late bool _canGenerateReports;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.member.projectRole;
    _canGenerateReports = widget.member.canGenerateReports;
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.edit, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(t.translate('edit_permissions'),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Info do utilizador
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: Text(
                    widget.member.name.isNotEmpty
                        ? widget.member.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(widget.member.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(widget.member.email),
              ),
              const Divider(height: 16),

              // Role
              Text(t.translate('project_role'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              ...ProjectRole.values.map((role) => _RoleOptionTile(
                    role: role,
                    isSelected: _selectedRole == role,
                    onTap: () => setState(() => _selectedRole = role),
                  )),
              const SizedBox(height: 12),

              // Relatórios
              SwitchListTile(
                title: Text(t.translate('can_generate_reports')),
                value: _canGenerateReports,
                onChanged: (v) => setState(() => _canGenerateReports = v),
                activeThumbColor: AppColors.primaryBlue,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

              const Spacer(),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.translate('cancel')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save),
                    label: Text(t.translate('save')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final t = TranslationHelper.of(context);
    setState(() => _isLoading = true);
    try {
      await UserService().updateMemberRole(
        projectId: widget.projectId,
        uid: widget.member.uid,
        newRole: _selectedRole,
        canGenerateReports: _canGenerateReports,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${t.translate('error')}: $e'),
              backgroundColor: AppColors.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════════

class _RoleOptionTile extends StatelessWidget {
  final ProjectRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOptionTile({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  Color get _color {
    switch (role) {
      case ProjectRole.projectManager:
        return Colors.blue;
      case ProjectRole.siteSupervisor:
        return AppColors.warningOrange;
      case ProjectRole.visitor:
        return AppColors.mediumGray;
    }
  }

  String get _description {
    switch (role) {
      case ProjectRole.projectManager:
        return 'CRUD completo + gerir equipa e permissões';
      case ProjectRole.siteSupervisor:
        return 'CRUD em instalação, equipamento e documentação';
      case ProjectRole.visitor:
        return 'Só leitura + geração de relatórios';
    }
  }

  String get _icon {
    switch (role) {
      case ProjectRole.projectManager:
        return '👷';
      case ProjectRole.siteSupervisor:
        return '🦺';
      case ProjectRole.visitor:
        return '👁️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
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
            Text('$_icon  ', style: const TextStyle(fontSize: 16)),
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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyMembers extends StatelessWidget {
  final bool canAdd;
  final VoidCallback onAdd;
  const _EmptyMembers({required this.canAdd, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(t.translate('no_members_yet'),
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(t.translate('no_members_desc'),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          if (canAdd) ...[
            const SizedBox(height: 16),
            GradientButton(
              label: t.translate('add_first_member'),
              icon: Icons.person_add,
              onPressed: onAdd,
            ),
          ],
        ],
      ),
    );
  }
}
