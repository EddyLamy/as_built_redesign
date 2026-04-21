import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../main.dart' show navigatorKey, scaffoldMessengerKey;

enum AppFeedbackType {
  success,
  error,
  warning,
  info,
}

void showAppFeedback(
  String message, {
  AppFeedbackType type = AppFeedbackType.info,
  Duration duration = const Duration(seconds: 5),
}) {
  final fallbackContext =
      navigatorKey.currentContext ?? scaffoldMessengerKey.currentContext;
  final overlayState = navigatorKey.currentState?.overlay ??
      (fallbackContext != null
          ? Overlay.maybeOf(fallbackContext, rootOverlay: true)
          : null);
  if (overlayState == null || fallbackContext == null) {
    return;
  }

  _activeFeedbackTimer?.cancel();
  _activeFeedbackEntry?.remove();

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _AppFeedbackOverlay(
      message: message,
      type: type,
      onClose: () {
        _activeFeedbackTimer?.cancel();
        _activeFeedbackTimer = null;
        if (_activeFeedbackEntry == entry) {
          _activeFeedbackEntry = null;
        }
        entry.remove();
      },
    ),
  );

  _activeFeedbackEntry = entry;
  overlayState.insert(entry);
  _activeFeedbackTimer = Timer(duration, () {
    if (_activeFeedbackEntry == entry) {
      _activeFeedbackEntry = null;
    }
    entry.remove();
  });
}

OverlayEntry? _activeFeedbackEntry;
Timer? _activeFeedbackTimer;

class _AppFeedbackOverlay extends StatefulWidget {
  const _AppFeedbackOverlay({
    required this.message,
    required this.type,
    required this.onClose,
  });

  final String message;
  final AppFeedbackType type;
  final VoidCallback onClose;

  @override
  State<_AppFeedbackOverlay> createState() => _AppFeedbackOverlayState();
}

class _AppFeedbackOverlayState extends State<_AppFeedbackOverlay> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = _AppFeedbackStyle.fromType(widget.type, context);

    return IgnorePointer(
      ignoring: false,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              offset: _visible ? Offset.zero : const Offset(0.18, 0.35),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _visible ? 1 : 0,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 320,
                      maxWidth: 460,
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                    decoration: BoxDecoration(
                      color: style.backgroundColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: style.borderColor),
                      boxShadow: AppColors.glassShadow,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Icon(style.icon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onClose,
                          splashRadius: 18,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.white.withValues(alpha: 0.88),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppFeedbackStyle {
  const _AppFeedbackStyle({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;

  factory _AppFeedbackStyle.fromType(
      AppFeedbackType type, BuildContext context) {
    final isDark = AppColors.isDarkContext(context);

    switch (type) {
      case AppFeedbackType.success:
        return _AppFeedbackStyle(
          icon: Icons.check_circle_outline,
          backgroundColor:
              isDark ? const Color(0xFF1F5A35) : AppColors.successGreen,
          borderColor: Colors.white.withValues(alpha: isDark ? 0.12 : 0.18),
        );
      case AppFeedbackType.error:
        return _AppFeedbackStyle(
          icon: Icons.error_outline,
          backgroundColor:
              isDark ? const Color(0xFF7A2626) : AppColors.errorRed,
          borderColor: Colors.white.withValues(alpha: isDark ? 0.1 : 0.16),
        );
      case AppFeedbackType.warning:
        return _AppFeedbackStyle(
          icon: Icons.warning_amber_rounded,
          backgroundColor:
              isDark ? const Color(0xFF8B4D10) : AppColors.warningOrange,
          borderColor: Colors.white.withValues(alpha: isDark ? 0.1 : 0.16),
        );
      case AppFeedbackType.info:
        return _AppFeedbackStyle(
          icon: Icons.info_outline,
          backgroundColor:
              isDark ? const Color(0xFF14395C) : AppColors.primaryBlue,
          borderColor: Colors.white.withValues(alpha: isDark ? 0.1 : 0.16),
        );
    }
  }
}
