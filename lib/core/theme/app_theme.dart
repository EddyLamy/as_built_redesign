import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  // ══════════════════════════════════════════════════════════════
  // MODERN LIGHT THEME - Material Design 3 with Wind Energy Aesthetics
  // ══════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.backgroundGray,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        primaryContainer: AppColors.primaryBlueLight,
        secondary: AppColors.emeraldGreen,
        secondaryContainer: AppColors.emeraldGreenLight,
        tertiary: AppColors.accentTeal,
        tertiaryContainer: AppColors.accentTealLight,
        error: AppColors.errorRed,
        errorContainer: AppColors.errorRedLight,
        surface: AppColors.cardBackground,
        surfaceContainerHighest: AppColors.backgroundGray,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkGray,
        onSurfaceVariant: AppColors.mediumGray,
        outline: AppColors.borderGray,
      ),

      // ══════════════════════════════════════════════════════════════
      // APP BAR - Modern gradient with elevated shadow
      // ══════════════════════════════════════════════════════════════
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        shadowColor: Colors.black.withOpacity(0.3),
      ),

      // ══════════════════════════════════════════════════════════════
      // CARDS - Modern elevated cards with soft shadows
      // ══════════════════════════════════════════════════════════════
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.cardBackground,
        shadowColor: Colors.black.withOpacity(0.1),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ══════════════════════════════════════════════════════════════
      // ELEVATED BUTTONS - Gradient backgrounds with shadows
      // ══════════════════════════════════════════════════════════════
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primaryBlue.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ══════════════════════════════════════════════════════════════
      // TEXT BUTTONS - Subtle with hover effects
      // ══════════════════════════════════════════════════════════════
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
      ),

      // ══════════════════════════════════════════════════════════════
      // OUTLINED BUTTONS - Modern borders with subtle effects
      // ══════════════════════════════════════════════════════════════
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: AppColors.primaryBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ══════════════════════════════════════════════════════════════
      // FLOATING ACTION BUTTON - Gradient with elevation
      // ══════════════════════════════════════════════════════════════
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentAmber,
        foregroundColor: Colors.white,
        elevation: 6,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ══════════════════════════════════════════════════════════════
      // INPUT DECORATION - Modern with smooth animations
      // ══════════════════════════════════════════════════════════════
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide:
              const BorderSide(color: AppColors.primaryBlue, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2.5),
        ),
        labelStyle: const TextStyle(
          color: AppColors.mediumGray,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ══════════════════════════════════════════════════════════════
      // DIVIDER - Subtle separation
      // ══════════════════════════════════════════════════════════════
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerGray,
        thickness: 1,
        space: 1,
      ),

      // ══════════════════════════════════════════════════════════════
      // CHIP - Modern pill shapes
      // ══════════════════════════════════════════════════════════════
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundGray,
        selectedColor: AppColors.primaryBlueLight,
        secondarySelectedColor: AppColors.emeraldGreenLight,
        labelStyle: const TextStyle(color: AppColors.darkGray, fontSize: 14),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ══════════════════════════════════════════════════════════════
      // DIALOG - Modern elevated dialogs
      // ══════════════════════════════════════════════════════════════
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.darkGray,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.mediumGray,
          fontSize: 16,
          height: 1.5,
        ),
      ),

      // ══════════════════════════════════════════════════════════════
      // LIST TILE - Enhanced spacing
      // ══════════════════════════════════════════════════════════════
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: AppColors.primaryBlue,
        textColor: AppColors.darkGray,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MODERN DARK THEME - Material Design 3 Dark Mode
  // ══════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryBlueLight,
      scaffoldBackgroundColor: const Color(0xFF0A1929), // Deep dark blue

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlueLight,
        primaryContainer: AppColors.primaryBlue,
        secondary: AppColors.emeraldGreenLight,
        secondaryContainer: AppColors.emeraldGreen,
        tertiary: AppColors.accentTealLight,
        tertiaryContainer: AppColors.accentTeal,
        error: AppColors.errorRedLight,
        errorContainer: AppColors.errorRed,
        surface: Color(0xFF1A2633), // Dark surface
        surfaceContainerHighest: Color(0xFF243542),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFE1F5FE),
        onSurfaceVariant: Color(0xFFB0BEC5),
        outline: Color(0xFF455A64),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A2633),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF1A2633),
        shadowColor: Colors.black.withOpacity(0.3),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlueLight,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primaryBlueLight.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentTealLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlueLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: AppColors.primaryBlueLight, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentAmberLight,
        foregroundColor: Colors.black87,
        elevation: 6,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F1C2A),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF37474F), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF37474F), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryBlueLight, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.errorRedLight, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.errorRedLight, width: 2.5),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFFB0BEC5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.accentTealLight,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF37474F),
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF243542),
        selectedColor: AppColors.primaryBlueLight,
        secondarySelectedColor: AppColors.emeraldGreenLight,
        labelStyle: const TextStyle(color: Color(0xFFE1F5FE), fontSize: 14),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A2633),
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFFB0BEC5),
          fontSize: 16,
          height: 1.5,
        ),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: AppColors.accentTealLight,
        textColor: Color(0xFFE1F5FE),
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFE1F5FE)),
        bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
        titleLarge: TextStyle(color: Colors.white),
      ),
    );
  }
}
