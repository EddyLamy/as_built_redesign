import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../core/localization/translation_helper.dart';
import '../main.dart' show navigatorKey;
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/mobile/mobile_projects_screen.dart';

class DashboardShortcutTitle extends StatelessWidget {
  const DashboardShortcutTitle({
    super.key,
    required this.child,
    this.highlighted = false,
  });

  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);

    return Row(
      children: [
        Tooltip(
          message: t.translate('dashboard'),
          child: Container(
            decoration: highlighted
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  )
                : null,
            child: IconButton(
              icon: const Icon(Icons.dashboard_rounded, color: Colors.white),
              onPressed: () => navigateToDashboardHome(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: IconTheme(
            data: const IconThemeData(color: Colors.white),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.white),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

void navigateToDashboardHome(BuildContext context) {
  final route = MaterialPageRoute<void>(
    builder: (_) => _isMobilePlatform
        ? const MobileProjectsScreen()
        : const DashboardScreen(),
  );

  final navigator = navigatorKey.currentState;
  if (navigator != null) {
    navigator.pushAndRemoveUntil(route, (existingRoute) => false);
    return;
  }

  Navigator.of(context, rootNavigator: true)
      .pushAndRemoveUntil(route, (existingRoute) => false);
}

bool get _isMobilePlatform {
  if (kIsWeb) {
    return false;
  }

  return Platform.isAndroid || Platform.isIOS;
}
