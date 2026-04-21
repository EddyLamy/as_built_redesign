import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class LiquidGlassShell extends StatelessWidget {
  const LiquidGlassShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? null : Colors.white,
              gradient: isDark ? AppColors.liquidGlassBackgroundDark : null,
            ),
          ),
        ),
        _Orb(
          alignment: const Alignment(-1.15, -0.95),
          size: 280,
          color: AppColors.glassBlue.withValues(alpha: isDark ? 0.18 : 0.05),
        ),
        _Orb(
          alignment: const Alignment(1.05, -0.55),
          size: 240,
          color: AppColors.glassMint.withValues(alpha: isDark ? 0.14 : 0.04),
        ),
        _Orb(
          alignment: const Alignment(0.7, 1.0),
          size: 360,
          color: AppColors.glassRose.withValues(alpha: isDark ? 0.1 : 0.035),
        ),
        _Orb(
          alignment: const Alignment(-0.15, 0.15),
          size: 520,
          color: AppColors.glassBlue.withValues(alpha: isDark ? 0.08 : 0.025),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFC9D6E2)
                          .withValues(alpha: isDark ? 0.04 : 0.05),
                      const Color(0xFFD6E0EA)
                          .withValues(alpha: isDark ? 0.02 : 0.025),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.02 : 0.06),
                    Colors.transparent,
                    const Color(0xFF90A4AE)
                        .withValues(alpha: isDark ? 0.06 : 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.42, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.04),
                ),
                gradient: RadialGradient(
                  center: const Alignment(-0.85, -0.9),
                  radius: 1.4,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.06 : 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.62],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
