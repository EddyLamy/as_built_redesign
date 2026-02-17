import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../core/localization/translation_helper.dart';
import '../models/notification.dart';
import '../models/notification_settings.dart';
import '../models/project_phase.dart';
import '../providers/app_providers.dart';
import 'edit_phase_dialog.dart';
import '../screens/settings/notification_settings_screen.dart';
import 'dart:ui';

/// Painel Lateral de Notificações - Visual Modernizado
class NotificationsPanel extends ConsumerStatefulWidget {
  const NotificationsPanel({super.key});

  @override
  ConsumerState<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends ConsumerState<NotificationsPanel>
    with SingleTickerProviderStateMixin {
  String _filterPriority = 'all'; // all, critical, warning, info
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.defaultCurve,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final counts = ref.watch(notificationCountByPriorityProvider);

    // Extrair settings do AsyncValue
    final settings = settingsAsync.maybeWhen(
      data: (s) => s,
      orElse: () => NotificationSettings(),
    );

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value * 400, 0),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(20)),
              boxShadow: AppColors.strongShadow,
            ),
            child: Column(
              children: [
                // Header
                _buildHeader(t, settings, counts),

                // Filtros
                _buildFilters(t, counts),

                // Lista de notificações
                Expanded(
                  child: notificationsAsync.when(
                    data: (notifications) =>
                        _buildNotificationsList(t, notifications),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('${t.translate('error')}: $error'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    TranslationHelper t,
    NotificationSettings settings,
    Map<NotificationPriority, int> counts,
  ) {
    final totalCount = counts.values.fold<int>(0, (sum, count) => sum + count);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.primaryBlueLight.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.borderGray, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.softShadow,
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.translate('notifications'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),

              // Botão de configurações
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: t.translate('settings'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),

              // Botão de fechar
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: t.translate('close'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$totalCount ${t.translate('active_alerts')}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),

          // Toggle global rápido
          if (!settings.enabled)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accentOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_off,
                      color: AppColors.accentOrange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.translate('notifications_disabled'),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Toggle enabled and save
                      final currentSettings = await NotificationSettings.load();
                      final newSettings = currentSettings.copyWith(
                        enabled: !currentSettings.enabled,
                      );
                      await newSettings.save();
                    },
                    child: Text(t.translate('enable')),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters(
    TranslationHelper t,
    Map<NotificationPriority, int> counts,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderGray),
        ),
      ),
      child: Row(
        children: [
          _buildFilterChip(
            t.translate('all'),
            'all',
            counts.values.fold<int>(0, (sum, count) => sum + count),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            t.translate('critical'),
            'critical',
            counts[NotificationPriority.critical] ?? 0,
            color: AppColors.errorRed,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            t.translate('warning'),
            'warning',
            counts[NotificationPriority.warning] ?? 0,
            color: AppColors.accentOrange,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            t.translate('info'),
            'info',
            counts[NotificationPriority.info] ?? 0,
            color: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter, int count,
      {Color? color}) {
    final isSelected = _filterPriority == filter;

    return InkWell(
      onTap: () => setState(() => _filterPriority = filter),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primaryBlue).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.primaryBlue)
                : AppColors.borderGray,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (color ?? AppColors.primaryBlue)
                    : AppColors.mediumGray,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color ?? AppColors.mediumGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
    TranslationHelper t,
    List<AppNotification> allNotifications,
  ) {
    // Filtrar por prioridade
    final filtered = _filterPriority == 'all'
        ? allNotifications
        : allNotifications.where((n) {
            switch (_filterPriority) {
              case 'critical':
                return n.priority == NotificationPriority.critical;
              case 'warning':
                return n.priority == NotificationPriority.warning;
              case 'info':
                return n.priority == NotificationPriority.info;
              default:
                return true;
            }
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.successGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              t.translate('no_notifications'),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(t, filtered[index]);
      },
    );
  }

  Widget _buildNotificationCard(
    TranslationHelper t,
    AppNotification notification,
  ) {
    Color priorityColor;
    switch (notification.priority) {
      case NotificationPriority.critical:
        priorityColor = AppColors.errorRed;
        break;
      case NotificationPriority.warning:
        priorityColor = AppColors.accentOrange;
        break;
      case NotificationPriority.info:
        priorityColor = AppColors.primaryBlue;
        break;
    }

    // ✅ FIX: Traduzir título e descrição
    String displayTitle = notification.title;
    String displayDescription = notification.description;

    // Traduzir título se for uma key
    if (displayTitle.startsWith('phase_')) {
      displayTitle = t.translate(displayTitle);

      // Substituir placeholders com dados do metadata
      if (notification.metadata?['daysOverdue'] != null) {
        final days = notification.metadata!['daysOverdue'];
        displayTitle = displayTitle.replaceAll('{days}', days.toString());
      }
      if (notification.metadata?['daysUntilDue'] != null) {
        final days = notification.metadata!['daysUntilDue'];
        displayTitle = displayTitle.replaceAll('{days}', days.toString());
      }
    }

    // Traduzir descrição se for uma key
    if (displayDescription.startsWith('phase_')) {
      displayDescription = t.translate(displayDescription);

      // Substituir placeholders
      if (notification.metadata?['phaseName'] != null) {
        final phaseName = notification.metadata!['phaseName'] as String;
        String translatedPhaseName;
        if (phaseName.startsWith('phase_')) {
          translatedPhaseName = t.translate(phaseName);
        } else {
          translatedPhaseName = phaseName;
        }
        displayDescription =
            displayDescription.replaceAll('{phase}', translatedPhaseName);
      }
      if (notification.metadata?['daysOverdue'] != null) {
        final days = notification.metadata!['daysOverdue'];
        displayDescription =
            displayDescription.replaceAll('{days}', days.toString());
      }
      if (notification.metadata?['daysUntilDue'] != null) {
        final days = notification.metadata!['daysUntilDue'];
        displayDescription =
            displayDescription.replaceAll('{days}', days.toString());
      }
      if (notification.metadata?['daysSinceStart'] != null) {
        final days = notification.metadata!['daysSinceStart'];
        displayDescription =
            displayDescription.replaceAll('{days}', days.toString());
      }
      if (notification.metadata?['dueDate'] != null) {
        final date = DateTime.parse(notification.metadata!['dueDate']);
        displayDescription =
            displayDescription.replaceAll('{date}', _formatDate(date));
      }
      if (notification.metadata?['startDate'] != null) {
        final date = DateTime.parse(notification.metadata!['startDate']);
        displayDescription =
            displayDescription.replaceAll('{date}', _formatDate(date));
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: priorityColor,
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      notification.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        displayTitle, // ✅ Usa título traduzido
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Menu de ações
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18),
                      onSelected: (value) => _handleAction(value, notification),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'dismiss',
                          child: Row(
                            children: [
                              const Icon(Icons.close, size: 18),
                              const SizedBox(width: 8),
                              Text(t.translate('dismiss')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'mute_7',
                          child: Row(
                            children: [
                              const Icon(Icons.snooze, size: 18),
                              const SizedBox(width: 8),
                              Text(t.translate('mute_7_days')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'mute_30',
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_off, size: 18),
                              const SizedBox(width: 8),
                              Text(t.translate('mute_30_days')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Projeto
                const SizedBox(height: 4),
                Text(
                  notification.projectName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Descrição (traduzida)
                const SizedBox(height: 8),
                Text(
                  displayDescription,
                  style: const TextStyle(fontSize: 13),
                ),

                // Footer (tempo)
                const SizedBox(height: 8),
                Text(
                  _formatTimeAgo(notification.createdAt, t),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ FIX: Navegação ao clicar no alerta
  void _handleNotificationTap(AppNotification notification) async {
    // Navegar baseado no tipo
    switch (notification.type) {
      case NotificationType.phaseOverdue:
      case NotificationType.phaseApproaching:
      case NotificationType.phaseNotStarted:
      case NotificationType.phaseNoEndDate:
        // ✅ Obter a fase específica e abrir diálogo de edição
        final phaseId = notification.metadata?['phaseId'] as String?;
        if (phaseId != null) {
          try {
            // Buscar fase diretamente do Firestore
            final doc = await FirebaseFirestore.instance
                .collection('projects')
                .doc(notification.projectId)
                .collection('phases')
                .doc(phaseId)
                .get();

            if (doc.exists && context.mounted) {
              final phase = ProjectPhase.fromFirestore(doc);

              // Abrir diálogo de edição diretamente (SEM fechar painel)
              await showDialog(
                context: context,
                builder: (_) => EditPhaseDialog(
                  projectId: notification.projectId,
                  phase: phase,
                ),
              );

              // ✅ Forçar refresh do provider após fechar o diálogo
              if (context.mounted) {
                ref.invalidate(notificationsProvider);
                // Força um rebuild do widget
                setState(() {});
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao carregar fase: $e'),
                  backgroundColor: AppColors.errorRed,
                ),
              );
            }
          }
        }
        break;

      case NotificationType.componentStalled:
      case NotificationType.componentMissingData:
      case NotificationType.componentReplaced:
      case NotificationType.turbineLowProgress:
        // TODO: Navegar para turbina/componente específico
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navegar para ${notification.projectName}'),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
    }
  }

  Future<void> _handleAction(
      String action, AppNotification notification) async {
    final currentSettings = await NotificationSettings.load();

    switch (action) {
      case 'dismiss':
        final newSettings = currentSettings.dismissAlert(notification.id);
        await newSettings.save();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                TranslationHelper.of(context).translate('alert_dismissed')),
            duration: const Duration(seconds: 2),
          ),
        );
        break;

      case 'mute_7':
        {
          final newSettings =
              currentSettings.muteProject(notification.projectId, 7);
          await newSettings.save();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(TranslationHelper.of(context)
                  .translate('project_muted_7_days')),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;

      case 'mute_30':
        {
          final newSettings =
              currentSettings.muteProject(notification.projectId, 30);
          await newSettings.save();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(TranslationHelper.of(context)
                  .translate('project_muted_30_days')),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
    }
  }

  String _formatTimeAgo(DateTime date, TranslationHelper t) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${t.translate('days_ago')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${t.translate('hours_ago')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${t.translate('minutes_ago')}';
    } else {
      return t.translate('just_now');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
