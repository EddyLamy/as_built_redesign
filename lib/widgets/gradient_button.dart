import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Botão com gradiente - Design padrão do As-Built
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool isSmall;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.gradient,
    this.width,
    this.padding,
    this.isSmall = false,
    this.isLoading = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = widget.gradient ??
        const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.accentTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final borderRadius = BorderRadius.circular(widget.isSmall ? 8 : 12);
    final shadowOpacity = _isPressed ? 0.2 : (_isHovered ? 0.34 : 0.3);
    final shadowBlur = _isPressed ? 5.0 : (_isHovered ? 10.0 : 8.0);
    final shadowOffset = _isPressed ? const Offset(0, 2) : const Offset(0, 4);

    return AnimatedOpacity(
      opacity: isEnabled ? 1 : 0.65,
      duration: const Duration(milliseconds: 180),
      child: AnimatedScale(
        scale: _isPressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: widget.width,
          decoration: BoxDecoration(
            gradient: effectiveGradient,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: shadowOpacity),
                blurRadius: shadowBlur,
                offset: shadowOffset,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              onHighlightChanged: isEnabled
                  ? (value) => setState(() => _isPressed = value)
                  : null,
              onHover: isEnabled
                  ? (value) => setState(() => _isHovered = value)
                  : null,
              borderRadius: borderRadius,
              splashColor: Colors.white.withValues(alpha: 0.12),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: Padding(
                padding: widget.padding ??
                    EdgeInsets.symmetric(
                      horizontal: widget.isSmall ? 16 : 24,
                      vertical: widget.isSmall ? 10 : 14,
                    ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: widget.isSmall ? 16 : 18,
                        height: widget.isSmall ? 16 : 18,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: widget.isSmall ? 6 : 8),
                    ] else if (widget.icon != null) ...[
                      Icon(widget.icon,
                          color: Colors.white, size: widget.isSmall ? 18 : 20),
                      SizedBox(width: widget.isSmall ? 6 : 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: widget.isSmall ? 13 : 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
