import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Icon with gradient effect
/// Uses ShaderMask to apply gradient colors to any icon
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.gradient,
    this.shadows,
  });

  /// Create a gradient icon with primary blue-to-teal gradient (like FAB button)
  factory GradientIcon.primary({
    required IconData icon,
    double size = 24,
    List<BoxShadow>? shadows,
  }) {
    return GradientIcon(
      icon: icon,
      size: size,
      gradient: const LinearGradient(
        colors: [
          AppColors.primaryBlue,
          Color(0xFF00BCD4), // Turquesa
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadows: shadows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppColors.primaryGradient;

    Widget iconWidget = ShaderMask(
      shaderCallback: (bounds) => effectiveGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );

    // Add shadow effect if provided
    if (shadows != null && shadows!.isNotEmpty) {
      return Stack(
        children: [
          // Shadow layers
          for (final shadow in shadows!)
            Transform.translate(
              offset: shadow.offset,
              child: Icon(
                icon,
                size: size,
                color: shadow.color,
              ),
            ),
          // Main icon with gradient
          iconWidget,
        ],
      );
    }

    return iconWidget;
  }
}
