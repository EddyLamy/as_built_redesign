import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  static const PageTransitionsTheme _smoothPageTransitions =
      PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
    },
  );

  // ══════════════════════════════════════════════════════════════
  // MODERN LIGHT THEME - Material Design 3 with Wind Energy Aesthetics
  // ══════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    final lightSurface = AppColors.glassSurfaceLight;
    final strongLightSurface = AppColors.glassSurfaceStrongLight;
    final lightBorder = AppColors.glassBorderLight;
    final lightMenuSurface = AppColors.menuSurfaceLight;
    final lightMenuBorder = AppColors.menuBorderLight;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: Colors.white,
      canvasColor: lightMenuSurface,
      pageTransitionsTheme: _smoothPageTransitions,
      splashFactory: InkRipple.splashFactory,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primaryBlue,
        primaryContainer: AppColors.primaryBlueLight,
        secondary: AppColors.emeraldGreen,
        secondaryContainer: AppColors.emeraldGreenLight,
        tertiary: AppColors.accentTeal,
        tertiaryContainer: AppColors.accentTealLight,
        error: AppColors.errorRed,
        errorContainer: AppColors.errorRedLight,
        surface: lightSurface,
        surfaceContainerHighest: strongLightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkGray,
        onSurfaceVariant: AppColors.mediumGray,
        outline: lightBorder,
      ),

      // ══════════════════════════════════════════════════════════════
      // APP BAR - Modern gradient with elevated shadow
      // ══════════════════════════════════════════════════════════════
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // ══════════════════════════════════════════════════════════════
      // CARDS - Modern elevated cards with soft shadows
      // ══════════════════════════════════════════════════════════════
      cardTheme: CardThemeData(
        elevation: 7,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: lightBorder, width: 1.2),
        ),
        color: strongLightSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0xFF0F4C81).withValues(alpha: 0.18),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // ══════════════════════════════════════════════════════════════
      // ELEVATED BUTTONS - Gradient backgrounds with shadows
      // ══════════════════════════════════════════════════════════════
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: AppColors.primaryBlue.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 220),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),

      // ══════════════════════════════════════════════════════════════
      // TEXT BUTTONS - Subtle with hover effects
      // ══════════════════════════════════════════════════════════════
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 220),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryBlue.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primaryBlue.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),

      // ══════════════════════════════════════════════════════════════
      // OUTLINED BUTTONS - Modern borders with subtle effects
      // ══════════════════════════════════════════════════════════════
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          side: const BorderSide(color: AppColors.primaryBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 220),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryBlue.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primaryBlue.withValues(alpha: 0.08);
            }
            return null;
          }),
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
        fillColor: strongLightSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: lightBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: lightBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              const BorderSide(color: AppColors.primaryBlue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
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
        backgroundColor: lightSurface,
        selectedColor: AppColors.primaryBlueLight,
        secondarySelectedColor: AppColors.emeraldGreenLight,
        labelStyle: const TextStyle(color: AppColors.darkGray, fontSize: 14),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: lightBorder, width: 1.0),
        ),
      ),

      // ══════════════════════════════════════════════════════════════
      // DIALOG - Modern elevated dialogs
      // ══════════════════════════════════════════════════════════════
      dialogTheme: DialogThemeData(
        backgroundColor: strongLightSurface,
        elevation: 24,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: lightBorder, width: 1.2),
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
      popupMenuTheme: PopupMenuThemeData(
        color: lightMenuSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: lightMenuBorder),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(lightMenuSurface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: lightMenuBorder),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightMenuSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: lightMenuBorder, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: lightMenuBorder, width: 1.2),
          ),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(lightMenuSurface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: lightMenuBorder),
            ),
          ),
        ),
      ),

      // ══════════════════════════════════════════════════════════════
      // LIST TILE - Enhanced spacing
      // ══════════════════════════════════════════════════════════════
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        iconColor: AppColors.primaryBlue,
        textColor: AppColors.darkGray,
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: strongLightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: lightBorder, width: 1.1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.fixed,
        backgroundColor: AppColors.snackbarSurfaceLight,
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.snackbarBorderLight),
        ),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: Colors.white,
        insetPadding: EdgeInsets.zero,
        width: null,
        dismissDirection: DismissDirection.horizontal,
        showCloseIcon: true,
        closeIconColor: Colors.white70,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MODERN DARK THEME - Material Design 3 Dark Mode
  // ══════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    final darkSurface = AppColors.glassSurfaceDark;
    final strongDarkSurface = AppColors.glassSurfaceStrongDark;
    final darkBorder = AppColors.glassBorderDark;
    final darkMenuSurface = AppColors.menuSurfaceDark;
    final darkMenuBorder = AppColors.menuBorderDark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryBlueLight,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: darkMenuSurface,
      pageTransitionsTheme: _smoothPageTransitions,
      splashFactory: InkRipple.splashFactory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlueLight,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.primaryBlueLight,
        primaryContainer: AppColors.primaryBlue,
        secondary: AppColors.emeraldGreenLight,
        secondaryContainer: AppColors.emeraldGreen,
        tertiary: AppColors.accentTealLight,
        tertiaryContainer: AppColors.accentTeal,
        error: AppColors.errorRedLight,
        errorContainer: AppColors.errorRed,
        surface: darkSurface,
        surfaceContainerHighest: strongDarkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFFE1F5FE),
        onSurfaceVariant: const Color(0xFFB0BEC5),
        outline: darkBorder,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFEAF6FF),
        size: 24,
      ),
      primaryIconTheme: const IconThemeData(
        color: Color(0xFFEAF6FF),
        size: 24,
      ),
      cardTheme: CardThemeData(
        elevation: 7,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: darkBorder, width: 1.1),
        ),
        color: strongDarkSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlueLight,
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: AppColors.primaryBlueLight.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 220),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentTealLight,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 220),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accentTealLight.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.accentTealLight.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlueLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          side: const BorderSide(color: AppColors.primaryBlueLight, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 220),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryBlueLight.withValues(alpha: 0.14);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.primaryBlueLight.withValues(alpha: 0.1);
            }
            return null;
          }),
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
        fillColor: strongDarkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: darkBorder, width: 1.1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: darkBorder, width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              const BorderSide(color: AppColors.primaryBlueLight, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              const BorderSide(color: AppColors.errorRedLight, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
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
        hintStyle: const TextStyle(
          color: Color(0xFFCFD8DC),
          fontSize: 15,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF37474F),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        selectedColor: AppColors.primaryBlueLight,
        secondarySelectedColor: AppColors.emeraldGreenLight,
        labelStyle: const TextStyle(color: Color(0xFFE1F5FE), fontSize: 14),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: darkBorder, width: 1.0),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: strongDarkSurface,
        elevation: 24,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: darkBorder, width: 1.1),
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
      popupMenuTheme: PopupMenuThemeData(
        color: darkMenuSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkMenuBorder),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(darkMenuSurface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: darkMenuBorder),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkMenuSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: darkMenuBorder, width: 1.1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: darkMenuBorder, width: 1.1),
          ),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(darkMenuSurface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: darkMenuBorder),
            ),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        iconColor: Color(0xFFEAF6FF),
        textColor: Color(0xFFEAF6FF),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: strongDarkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: darkBorder, width: 1.0),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.fixed,
        backgroundColor: AppColors.snackbarSurfaceDark,
        elevation: 22,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.snackbarBorderDark),
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFFF3F8FC),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: Colors.white,
        insetPadding: EdgeInsets.zero,
        width: null,
        dismissDirection: DismissDirection.horizontal,
        showCloseIcon: true,
        closeIconColor: Color(0xFFD2DEE7),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFEAF6FF)),
        bodyMedium: TextStyle(color: Color(0xFFD2DEE7)),
        bodySmall: TextStyle(color: Color(0xFFC2CFD8)),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Color(0xFFEAF6FF)),
        titleSmall: TextStyle(color: Color(0xFFDCE7EF)),
        labelLarge: TextStyle(color: Color(0xFFEAF6FF)),
        labelMedium: TextStyle(color: Color(0xFFD2DEE7)),
        labelSmall: TextStyle(color: Color(0xFFC2CFD8)),
      ),
    );
  }
}
