import 'dart:ui';

import 'package:flutter/material.dart';

Future<T?> showLiquidDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  bool useSafeArea = true,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, __) {
      Widget child = themes.wrap(Builder(builder: builder));
      if (useSafeArea) {
        child = SafeArea(child: child);
      }

      return _BlurredOverlay(
        barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.14),
        child: child,
      );
    },
    transitionBuilder: (dialogContext, animation, _, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

Future<T?> showLiquidBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool useSafeArea = true,
  bool isDismissible = true,
  ShapeBorder? shape,
  Color? barrierColor,
  Color? backgroundColor,
  RouteSettings? routeSettings,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final resolvedBorderRadius = _resolveBorderRadius(shape);
  final resolvedShape = shape ??
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      );

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (sheetContext, _, __) {
      Widget child = themes.wrap(Builder(builder: builder));

      child = AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: child,
      );

      child = ClipRRect(
        borderRadius: resolvedBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Material(
            color: backgroundColor ??
                Theme.of(sheetContext).dialogTheme.backgroundColor ??
                Theme.of(sheetContext)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.88),
            shape: resolvedShape,
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
      );

      if (useSafeArea) {
        child = SafeArea(top: false, child: child);
      }

      if (!isScrollControlled) {
        child = ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.9,
          ),
          child: child,
        );
      }

      return _BlurredOverlay(
        barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.12),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(widthFactor: 1, child: child),
        ),
      );
    },
    transitionBuilder: (sheetContext, animation, _, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

class _BlurredOverlay extends StatelessWidget {
  const _BlurredOverlay({required this.barrierColor, required this.child});

  final Color barrierColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(color: barrierColor),
            ),
          ),
        ),
        Positioned.fill(
          child: Material(type: MaterialType.transparency, child: child),
        ),
      ],
    );
  }
}

BorderRadius _resolveBorderRadius(ShapeBorder? shape) {
  if (shape is RoundedRectangleBorder) {
    final borderRadius = shape.borderRadius;
    if (borderRadius is BorderRadius) {
      return borderRadius;
    }
  }

  return const BorderRadius.vertical(top: Radius.circular(28));
}
