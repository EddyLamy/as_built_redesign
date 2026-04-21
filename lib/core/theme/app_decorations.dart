import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Modern decoration utilities for consistent visual styling across the app
/// Use these pre-built decorations to maintain visual consistency
class AppDecorations {
  // ══════════════════════════════════════════════════════════════
  // CARD DECORATIONS - Modern cards with gradients and shadows
  // ══════════════════════════════════════════════════════════════

  /// Standard card decoration with soft shadow
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.glassSurfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorderLight, width: 1.2),
        boxShadow: AppColors.glassShadow,
      );

  /// Card with gradient background
  static BoxDecoration get cardGradient => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.mediumShadow,
      );

  /// Card with emerald gradient
  static BoxDecoration get cardEmerald => BoxDecoration(
        gradient: AppColors.emeraldGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.mediumShadow,
      );

  /// Card with accent teal gradient
  static BoxDecoration get cardAccent => BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.mediumShadow,
      );

  /// Card with warning gradient
  static BoxDecoration get cardWarning => BoxDecoration(
        gradient: AppColors.warningGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.mediumShadow,
      );

  /// Card with subtle border
  static BoxDecoration get cardBordered => BoxDecoration(
        color: AppColors.glassSurfaceStrongLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorderLight, width: 1.2),
        boxShadow: AppColors.glassShadow,
      );

  /// Elevated card with stronger shadow
  static BoxDecoration get cardElevated => BoxDecoration(
        color: AppColors.glassSurfaceStrongLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorderLight, width: 1.3),
        boxShadow: AppColors.glassShadow,
      );

  // ══════════════════════════════════════════════════════════════
  // BUTTON DECORATIONS - Modern gradient buttons
  // ══════════════════════════════════════════════════════════════

  static BoxDecoration get buttonPrimary => BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.mediumShadow,
      );

  static BoxDecoration get buttonEmerald => BoxDecoration(
        gradient: AppColors.emeraldGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.mediumShadow,
      );

  static BoxDecoration get buttonAccent => BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.mediumShadow,
      );

  static BoxDecoration get buttonWarning => BoxDecoration(
        gradient: AppColors.warningGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.mediumShadow,
      );

  // ══════════════════════════════════════════════════════════════
  // CONTAINER DECORATIONS - General purpose containers
  // ══════════════════════════════════════════════════════════════

  /// Glassmorphism effect (for overlays)
  static BoxDecoration glass({Color? tint}) => BoxDecoration(
        color: (tint ?? const Color(0xFFE8EFF6)).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: AppColors.glassShadow,
      );

  /// Frosted glass effect with backdrop blur (use with BackdropFilter)
  static BoxDecoration get frostedGlass => BoxDecoration(
        color: const Color(0xFFE6EEF6).withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: AppColors.glassShadow,
      );

  /// Subtle background container
  static BoxDecoration get containerSubtle => BoxDecoration(
        color: AppColors.glassSurfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorderLight, width: 1.1),
        boxShadow: AppColors.glassShadow,
      );

  /// Status badge container
  static BoxDecoration statusBadge(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      );

  // ══════════════════════════════════════════════════════════════
  // APPBAR DECORATIONS - Gradient headers
  // ══════════════════════════════════════════════════════════════

  static BoxDecoration get appBarGradient => BoxDecoration(
        gradient: AppColors.oceanGradient,
        boxShadow: AppColors.mediumShadow,
      );

  // ══════════════════════════════════════════════════════════════
  // INPUT DECORATIONS - Modern form fields
  // ══════════════════════════════════════════════════════════════

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon:
          icon != null ? Icon(icon, color: AppColors.primaryBlue) : null,
      suffixIcon: suffixIcon,
      enabled: enabled,
      filled: true,
      fillColor: enabled
          ? AppColors.glassSurfaceStrongLight
          : AppColors.glassSurfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.glassBorderLight, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.glassBorderLight, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // DIVIDERS - Visual separators
  // ══════════════════════════════════════════════════════════════

  /// Standard divider
  static Widget get divider => const Divider(
        color: AppColors.dividerGray,
        height: 1,
        thickness: 1,
      );

  /// Gradient divider
  static Widget get dividerGradient => Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.primaryBlue.withValues(alpha: 0.3),
              Colors.transparent,
            ],
          ),
        ),
      );

  // ══════════════════════════════════════════════════════════════
  // ANIMATED DECORATIONS - Hover and press effects
  // ══════════════════════════════════════════════════════════════

  /// Decoration that changes on hover/press
  static BoxDecoration cardHoverable({bool isHovered = false}) => BoxDecoration(
        color: AppColors.glassSurfaceStrongLight,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.glassShadow,
        border: Border.all(
          color: isHovered
              ? AppColors.primaryBlue.withValues(alpha: 0.34)
              : AppColors.glassBorderLight,
          width: 1.2,
        ),
      );

  // ══════════════════════════════════════════════════════════════
  // SHIMMER LOADING - Skeleton screens
  // ══════════════════════════════════════════════════════════════

  static BoxDecoration get shimmer => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundGray,
            AppColors.backgroundGray.withValues(alpha: 0.5),
            AppColors.backgroundGray,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      );

  // ══════════════════════════════════════════════════════════════
  // PROGRESS INDICATORS - Dynamic decorations based on progress
  // ══════════════════════════════════════════════════════════════

  static BoxDecoration progressContainer(double progress) => BoxDecoration(
        gradient: AppColors.getProgressGradient(progress),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.softShadow,
      );

  static BoxDecoration statusContainer(String status) {
    final color = AppColors.getStatusColor(status);
    return BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // CUSTOM SHAPES - Special decorations
  // ══════════════════════════════════════════════════════════════

  /// Circular avatar with gradient
  static BoxDecoration get avatarGradient => BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: AppColors.glowShadow,
      );

  /// Badge with glow effect
  static BoxDecoration badgeGlow({Color? color}) => BoxDecoration(
        shape: BoxShape.circle,
        color: color ?? AppColors.accentAmber,
        boxShadow: [
          BoxShadow(
            color: (color ?? AppColors.accentAmber).withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      );

  /// Notification dot
  static BoxDecoration get notificationDot => BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.errorRed,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.errorRed.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      );
}

/// Animation durations for consistent timing
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
}
