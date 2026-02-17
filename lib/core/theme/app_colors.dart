import 'package:flutter/material.dart';

/// Modern professional color palette for As-Built Wind Energy App
/// Inspired by wind energy industry: ocean blues, emerald greens, amber accents
class AppColors {
  // ══════════════════════════════════════════════════════════════
  // PRIMARY COLORS - Deep Ocean Blues (Professional & Trustworthy)
  // ══════════════════════════════════════════════════════════════
  static const Color primaryBlue = Color(0xFF0F4C81); // Deep ocean blue
  static const Color primaryBlueMedium = Color(0xFF1565C0); // Medium blue
  static const Color primaryBlueLight =
      Color(0xFF1976D2); // Lighter blue for accents
  static const Color primaryBlueDark = Color(0xFF0D3C66); // Dark blue for depth

  // ══════════════════════════════════════════════════════════════
  // SECONDARY COLORS - Emerald Green (Energy & Sustainability)
  // ══════════════════════════════════════════════════════════════
  static const Color emeraldGreen = Color(0xFF059669); // Rich emerald
  static const Color emeraldGreenLight = Color(0xFF10B981); // Light emerald
  static const Color emeraldGreenDark = Color(0xFF047857); // Deep emerald

  // ══════════════════════════════════════════════════════════════
  // ACCENT COLORS - Teal & Cyan (Modern Tech Feel)
  // ══════════════════════════════════════════════════════════════
  static const Color accentTeal = Color(0xFF0891B2); // Modern teal
  static const Color accentTealLight = Color(0xFF06B6D4); // Sky teal
  static const Color accentTealDark = Color(0xFF0E7490); // Deep teal
  static const Color accentCyan =
      Color(0xFF00BCD4); // Bright cyan for highlights

  // ══════════════════════════════════════════════════════════════
  // ACCENT WARM - Amber & Orange (Energy & Alert)
  // ══════════════════════════════════════════════════════════════
  static const Color accentAmber = Color(0xFFFF9800); // Rich amber
  static const Color accentAmberLight = Color(0xFFFFB74D); // Light amber
  static const Color accentAmberDark = Color(0xFFF57C00); // Deep amber
  static const Color accentOrange = Color(0xFFFF6F00); // Vibrant orange

  // ══════════════════════════════════════════════════════════════
  // STATUS COLORS - Enhanced with better contrast
  // ══════════════════════════════════════════════════════════════
  static const Color successGreen = Color(0xFF2E7D32); // Success/Complete
  static const Color successGreenLight = Color(0xFF4CAF50); // Light success

  static const Color warningOrange = Color(0xFFF57C00); // Warning/In Progress
  static const Color warningOrangeLight = Color(0xFFFF9800); // Light warning

  static const Color errorRed = Color(0xFFD32F2F); // Error/Blocked
  static const Color errorRedLight = Color(0xFFE57373); // Light error

  static const Color pendingGray = Color(0xFF757575); // Pending/Not Started
  static const Color infoBlue = Color(0xFF1976D2); // Information

  // ══════════════════════════════════════════════════════════════
  // NEUTRAL COLORS - Professional Gray Scale
  // ══════════════════════════════════════════════════════════════
  static const Color darkGray = Color(0xFF212121); // Text primary (darker)
  static const Color mediumGray = Color(0xFF616161); // Text secondary
  static const Color lightGray = Color(0xFF9E9E9E); // Text disabled
  static const Color backgroundGray = Color(0xFFF5F7FA); // Soft background
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure white cards
  static const Color borderGray = Color(0xFFE0E0E0); // Subtle borders
  static const Color dividerGray = Color(0xFFBDBDBD); // Dividers

  // ══════════════════════════════════════════════════════════════
  // MODERN GRADIENTS - Sophisticated multi-stop gradients
  // ══════════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueMedium, primaryBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0D3C66), Color(0xFF0F4C81), Color(0xFF1565C0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [emeraldGreen, emeraldGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentTeal, accentTealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successGreen, successGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [accentAmber, accentAmberLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [accentOrange, accentAmber, accentAmberLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // Radial gradients for special effects
  static const RadialGradient glowGradient = RadialGradient(
    colors: [Color(0xFF1976D2), Color(0xFF0F4C81), Color(0xFF0D3C66)],
    stops: [0.0, 0.5, 1.0],
  );

  // ══════════════════════════════════════════════════════════════
  // MODERN SHADOWS - Layered shadows for depth
  // ══════════════════════════════════════════════════════════════
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];

  static List<BoxShadow> get strongShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          offset: const Offset(0, 8),
          blurRadius: 24,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primaryBlueLight.withOpacity(0.3),
          offset: const Offset(0, 0),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          offset: const Offset(0, 2),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  // ══════════════════════════════════════════════════════════════
  // UTILITY METHODS - Dynamic colors based on state
  // ══════════════════════════════════════════════════════════════
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'concluído':
      case 'completed':
      case 'comissionada':
        return successGreen;
      case 'em progresso':
      case 'in progress':
      case 'em instalação':
        return warningOrange;
      case 'bloqueado':
      case 'blocked':
        return errorRed;
      case 'pendente':
      case 'pending':
      case 'planejada':
      default:
        return pendingGray;
    }
  }

  static Color getProgressColor(double progress) {
    if (progress >= 100) return successGreen;
    if (progress >= 75) return emeraldGreen;
    if (progress >= 50) return accentTeal;
    if (progress >= 25) return accentAmber;
    return pendingGray;
  }

  static LinearGradient getProgressGradient(double progress) {
    if (progress >= 100) return successGradient;
    if (progress >= 75) return emeraldGradient;
    if (progress >= 50) return accentGradient;
    if (progress >= 25) return warningGradient;
    return const LinearGradient(
      colors: [pendingGray, lightGray],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
