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
  static const Color sidebarDark = Color(0xFF111827); // Dark sidebar background
  static const Color backgroundGray =
      Color(0xFFF2F3FC); // Soft lavender background
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure white cards
  static const Color borderGray = Color(0xFFE0E0E0); // Subtle borders
  static const Color dividerGray = Color(0xFFBDBDBD); // Dividers

  // Liquid glass palette
  static const Color glassCanvas = Color(0xFFC3CEDA);
  static const Color glassCanvasDark = Color(0xFF061521);
  static const Color glassBlue = Color(0xFF7DD3FC);
  static const Color glassMint = Color(0xFF6EE7B7);
  static const Color glassRose = Color(0xFFF9A8D4);

  static bool isDarkContext(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color adaptivePrimaryText(BuildContext context) =>
      isDarkContext(context) ? const Color(0xFFEAF6FF) : darkGray;

  static Color adaptiveSecondaryText(BuildContext context) =>
      isDarkContext(context) ? const Color(0xFFD2DEE7) : mediumGray;

  static Color adaptiveMutedText(BuildContext context) =>
      isDarkContext(context) ? const Color(0xFFC2CFD8) : lightGray;

  static Color adaptiveCardSurface(BuildContext context) =>
      isDarkContext(context) ? glassSurfaceDark : glassSurfaceStrongLight;

  static Color adaptivePanelSurface(BuildContext context) =>
      isDarkContext(context) ? glassSurfaceStrongDark : glassSurfaceStrongLight;

  static Color adaptiveOutline(BuildContext context) =>
      isDarkContext(context) ? const Color(0xFF758392) : borderGray;

  static Color adaptiveProgressTrack(BuildContext context) =>
      isDarkContext(context) ? Colors.white.withValues(alpha: 0.14) : lightGray;

  static Color get glassSurfaceLight =>
      const Color(0xFFD9E2EB).withValues(alpha: 0.56);
  static Color get glassSurfaceStrongLight =>
      const Color(0xFFE2E9F0).withValues(alpha: 0.68);
  static Color get glassSurfaceDark =>
      const Color(0xFF10283B).withValues(alpha: 0.54);
  static Color get glassSurfaceStrongDark =>
      const Color(0xFF16344B).withValues(alpha: 0.66);
  static Color get glassBorderLight =>
      const Color(0xFFF8FBFF).withValues(alpha: 0.62);
  static Color get glassBorderDark => Colors.white.withValues(alpha: 0.22);
  static Color get glassHighlight =>
      const Color(0xFFFFFFFF).withValues(alpha: 0.24);

  static Color get menuSurfaceLight => Colors.white.withValues(alpha: 0.98);
  static Color get menuSurfaceDark => const Color(0xFF183046);
  static Color get menuBorderLight => const Color(0xFFD5DFEA);
  static Color get menuBorderDark => Colors.white.withValues(alpha: 0.18);

  static Color get snackbarSurfaceLight => const Color(0xFF173C63);
  static Color get snackbarSurfaceDark => const Color(0xFF0D1F30);
  static Color get snackbarBorderLight => Colors.white.withValues(alpha: 0.14);
  static Color get snackbarBorderDark => Colors.white.withValues(alpha: 0.12);

  static LinearGradient get liquidGlassBackground => LinearGradient(
        colors: [
          glassCanvas,
          const Color(0xFFB6C3D0),
          const Color(0xFFCAD5E0),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.55, 1.0],
      );

  static LinearGradient get liquidGlassBackgroundDark => LinearGradient(
        colors: [
          glassCanvasDark,
          const Color(0xFF0C2234),
          const Color(0xFF14324A),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.5, 1.0],
      );

  // ══════════════════════════════════════════════════════════════
  // MODERN GRADIENTS - Sophisticated multi-stop gradients
  // ══════════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
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
          color: Colors.black.withValues(alpha: 0.08),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];

  static List<BoxShadow> get strongShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          offset: const Offset(0, 8),
          blurRadius: 24,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primaryBlueLight.withValues(alpha: 0.3),
          offset: const Offset(0, 0),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          offset: const Offset(0, 2),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get glassShadow => [
        BoxShadow(
          color: const Color(0xFF0F4C81).withValues(alpha: 0.12),
          offset: const Offset(0, 16),
          blurRadius: 42,
          spreadRadius: -18,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.25),
          offset: const Offset(-6, -6),
          blurRadius: 18,
          spreadRadius: -14,
        ),
      ];

  // ══════════════════════════════════════════════════════════════
  // UTILITY METHODS - Dynamic colors based on state
  // ══════════════════════════════════════════════════════════════
  static Color getStatusColor(String status) {
    final normalizedStatus =
        status.startsWith('status_') ? status.substring(7).trim() : status;

    switch (normalizedStatus.toLowerCase()) {
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
