// lib/widgets/common/permission_guard.dart
//
// Widget que bloqueia conteúdo com base nas permissões do utilizador.
// Usar em qualquer screen para esconder/mostrar botões, secções, etc.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/permission_provider.dart';

// ─── Guard principal ───────────────────────────────────────────────────────────
// Mostra [child] se a condição for verdadeira, senão mostra [fallback] ou nada

class PermissionGuard extends ConsumerWidget {
  final String? projectId;
  final bool Function(PermissionNotifier p) condition;
  final Widget child;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    this.projectId,
    required this.condition,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionProvider(projectId));
    if (condition(permissions)) return child;
    return fallback ?? const SizedBox.shrink();
  }
}

// ─── Guard de Screen completa ──────────────────────────────────────────────────
// Mostra uma tela de "Acesso Negado" se não tiver permissão

class ScreenGuard extends ConsumerWidget {
  final String? projectId;
  final bool Function(PermissionNotifier p) condition;
  final Widget child;
  final String? message;

  const ScreenGuard({
    super.key,
    this.projectId,
    required this.condition,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionProvider(projectId));

    // Ainda a carregar
    final appUserAsync = ref.watch(currentAppUserProvider);
    if (appUserAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (condition(permissions)) return child;

    return Scaffold(
      appBar: AppBar(title: const Text('Acesso Negado')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message ?? 'Não tens permissão para aceder a esta secção.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Contacta o teu Project Manager.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EXEMPLOS DE USO — copia estes padrões para qualquer screen
// ═══════════════════════════════════════════════════════════════════════════════

/*

// ── 1. Esconder um botão ────────────────────────────────────────────────────
// O FAB só aparece se o utilizador puder gerir equipamento

floatingActionButton: PermissionGuard(
  projectId: currentProjectId,
  condition: (p) => p.canManageEquipmentAndDocs,
  child: FloatingActionButton.extended(
    onPressed: _showAddDialog,
    label: const Text('Adicionar'),
    icon: const Icon(Icons.add),
  ),
),


// ── 2. Bloquear uma screen inteira ──────────────────────────────────────────

class EquipmentScreen extends ConsumerWidget {
  final String projectId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenGuard(
      projectId: projectId,
      condition: (p) => p.hasSomeProjectAccess,
      message: 'Precisas de fazer parte deste projeto para ver o equipamento.',
      child: _EquipmentContent(projectId: projectId),
    );
  }
}


// ── 3. Esconder ações de edição num card ─────────────────────────────────────

// No DocumentCard ou EquipmentCard, passa canDelete como:
DocumentCard(
  document: doc,
  canDelete: ref.watch(permissionProvider(projectId)).canManageEquipmentAndDocs,
  onDelete: () => _delete(doc.documentId),
),


// ── 4. Mostrar badge de role na AppBar ──────────────────────────────────────

Consumer(
  builder: (_, ref, __) {
    final perms = ref.watch(permissionProvider(currentProjectId));
    final member = ref.watch(projectMemberProvider(currentProjectId)).asData?.value;
    final role = member?.projectRole.label ?? 
                 perms.appUser?.globalRole.label ?? '';
    return Chip(label: Text(role));
  },
),


// ── 5. Verificar permissão num onPressed ────────────────────────────────────

onPressed: () {
  final perms = ref.read(permissionProvider(projectId));
  if (!perms.canManageTeam) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sem permissão para gerir a equipa')),
    );
    return;
  }
  _showTeamManagement();
},


// ── 6. Verificar no AuthObserver (limpar ao logout) ─────────────────────────
// No teu auth_observer.dart existente, adiciona:

class AppAuthObserver extends NavigatorObserver {
  final Ref ref;
  AppAuthObserver(this.ref);

  void onLogout() {
    ref.invalidate(currentAppUserProvider);
    ref.invalidate(projectMemberProvider);
    ref.invalidate(permissionProvider);
    // ... outros providers
  }
}

*/
