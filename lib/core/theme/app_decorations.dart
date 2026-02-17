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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray, width: 1),
        boxShadow: AppColors.softShadow,
      );

  /// Elevated card with stronger shadow
  static BoxDecoration get cardElevated => BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.strongShadow,
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
        color: (tint ?? Colors.white).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Frosted glass effect with backdrop blur (use with BackdropFilter)
  static BoxDecoration get frostedGlass => BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1.5,
        ),
      );

  /// Subtle background container
  static BoxDecoration get containerSubtle => BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray.withOpacity(0.5)),
      );

  /// Status badge container
  static BoxDecoration statusBadge(Color color) => BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
      fillColor: enabled ? Colors.white : AppColors.backgroundGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGray, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderGray, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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
              AppColors.primaryBlue.withOpacity(0.3),
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
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isHovered ? AppColors.mediumShadow : AppColors.softShadow,
        border: Border.all(
          color: isHovered
              ? AppColors.primaryBlue.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
      );

  // ══════════════════════════════════════════════════════════════
  // SHIMMER LOADING - Skeleton screens
  // ══════════════════════════════════════════════════════════════

  static BoxDecoration get shimmer => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundGray,
            AppColors.backgroundGray.withOpacity(0.5),
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
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
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
            color: (color ?? AppColors.accentAmber).withOpacity(0.5),
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
            color: AppColors.errorRed.withOpacity(0.3),
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
