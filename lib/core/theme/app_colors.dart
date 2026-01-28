import 'package:flutter/material.dart';

/// Professional color palette for As-Built app
/// Inspired by modern industrial dashboards (neutral, clean, professional)
class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep professional blue
  static const Color secondaryBlue =
      Color(0xFF1E40AF); // ← ADICIONADO para gradientes
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF1E40AF);

  // Accent Colors
  static const Color accentTeal = Color(0xFF0891B2); // Modern teal
  static const Color accentTealLight = Color(0xFF06B6D4);
  static const Color accentTealDark = Color(0xFF0E7490);

  // Status Colors
  static const Color successGreen = Color(0xFF059669); // Success/Complete
  static const Color successGreenLight = Color(0xFF10B981);

  static const Color warningOrange = Color(0xFFEA580C); // Warning/In Progress
  static const Color warningOrangeLight = Color(0xFFF97316);

  static const Color errorRed = Color(0xFFDC2626); // Error/Blocked
  static const Color errorRedLight = Color(0xFFEF4444);

  static const Color pendingGray = Color(0xFF6B7280); // Pending/Not Started

  // Neutral Colors
  static const Color darkGray = Color(0xFF1F2937); // Text primary
  static const Color mediumGray = Color(0xFF6B7280); // Text secondary
  static const Color lightGray = Color(0xFF9CA3AF); // Text disabled
  static const Color backgroundGray = Color(0xFFF3F4F6); // Background
  static const Color cardGray = Color(0xFFFFFFFF); // Cards
  static const Color borderGray = Color(0xFFE5E7EB); // Borders

  // 🔔 NOTIFICATION SYSTEM - COR NOVA
  static const Color accentOrange =
      Color(0xFFF39C12); // Cor de destaque para notificações

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentTeal, accentTealDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successGreen, Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Component Status Colors
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

  // Progress Colors (for gradients in progress bars)
  static Color getProgressColor(double progress) {
    if (progress >= 100) return successGreen;
    if (progress >= 75) return successGreenLight;
    if (progress >= 50) return accentTeal;
    if (progress >= 25) return warningOrange;
    return pendingGray;
  }
}
