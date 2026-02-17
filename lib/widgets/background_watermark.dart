import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Background watermark widget with large wind_power icon in light gray
/// Use as a Stack background to add subtle branding to screens
class BackgroundWatermark extends StatelessWidget {
  final double size;
  final Color? color;
  final double opacity;
  final Alignment alignment;

  const BackgroundWatermark({
    super.key,
    this.size = 400,
    this.color,
    this.opacity = 0.05,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Icon(
          Icons.wind_power,
          size: size,
          color: (color ?? const Color.fromARGB(255, 11, 11, 11))
              .withOpacity(opacity),
        ),
      ),
    );
  }
}
