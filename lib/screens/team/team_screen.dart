// lib/screens/team/team_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/translation_helper.dart';
import '../../widgets/app_bar_dashboard_shortcut.dart';
import '../../widgets/background_watermark.dart';
import 'team_management_screen.dart';
import 'team_permissions_screen.dart';

class TeamScreen extends ConsumerWidget {
  final String projectId;
  final String projectName;
  final bool embeddedInDesktopShell;

  const TeamScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    this.embeddedInDesktopShell = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TranslationHelper.of(context);
    final tabBar = TabBar(
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
      tabs: [
        Tab(
          icon: const Icon(Icons.groups_outlined, size: 20),
          text: t.translate('companies'),
        ),
        Tab(
          icon: const Icon(Icons.security_outlined, size: 20),
          text: t.translate('permissions'),
        ),
      ],
    );
    final tabView = TabBarView(
      children: [
        TeamManagementScreen(projectId: projectId),
        TeamPermissionsScreen(
          projectId: projectId,
          projectName: projectName,
        ),
      ],
    );

    return DefaultTabController(
      length: 2,
      child: embeddedInDesktopShell
          ? Stack(
              children: [
                const BackgroundWatermark(
                  size: 560,
                  opacity: 0.03,
                  alignment: Alignment.centerRight,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: tabBar,
                      ),
                    ),
                    Expanded(child: tabView),
                  ],
                ),
              ],
            )
          : Scaffold(
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
                title: DashboardShortcutTitle(
                  child: Row(
                    children: [
                      const Icon(Icons.groups, color: Colors.white),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.translate('team')),
                          Text(
                            projectName,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                bottom: tabBar,
              ),
              body: tabView,
            ),
    );
  }
}
