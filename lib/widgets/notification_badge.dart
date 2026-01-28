import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_providers.dart';

/// Badge de Notificações para o AppBar
class NotificationBadge extends ConsumerWidget {
  final VoidCallback onTap;

  const NotificationBadge({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notificationCount = ref.watch(notificationCountProvider);
    final hasCritical = ref.watch(hasCriticalAlertsProvider);

    // Se desativado nas configurações, não mostrar badge
    if (!settings.showBadge || !settings.enabled) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Ícone do sino
            Icon(
              notificationCount > 0
                  ? Icons.notifications_active
                  : Icons.notifications_outlined,
              color: Colors
                  .white, // ✅ Sempre branco para contrastar com AppBar azul
              size: 24,
            ),

            // Badge com número
            if (notificationCount > 0)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: hasCritical
                        ? AppColors.errorRed
                        : AppColors.accentOrange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      notificationCount > 99 ? '99+' : '$notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
