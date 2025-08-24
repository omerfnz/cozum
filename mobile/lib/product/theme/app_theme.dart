import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application color schemes
class AppColors {
  const AppColors._();
  
  // Primary colors for the app (Çözüm Var brand)
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  
  // Secondary colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF018786);
  
  // Error colors
  static const Color error = Color(0xFFB00020);
  static const Color errorDark = Color(0xFFCF6679);
  
  // Success colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF2E7D32);
  
  // Warning colors
  static const Color warning = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFF57C00);
  
  // Info colors
  static const Color info = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF1976D2);
  
  // Surface colors
  static const Color surfaceLight = Color(0xFFFFFBFE);
  static const Color surfaceDark = Color(0xFF1C1B1F);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFFFFBFE);
  static const Color backgroundDark = Color(0xFF1C1B1F);
  
  // Text colors
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
}

/// Light theme configuration
class AppLightTheme {
  AppLightTheme._();
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surfaceLight,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: _buildAppBarTheme(Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.light),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
      textButtonTheme: _buildTextButtonTheme(Brightness.light),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
      cardTheme: _buildCardTheme(Brightness.light),
      bottomNavigationBarTheme: _buildBottomNavTheme(Brightness.light),
      navigationRailTheme: _buildNavigationRailTheme(Brightness.light),
      dialogTheme: _buildDialogTheme(Brightness.light),
      snackBarTheme: _buildSnackBarTheme(Brightness.light),
      floatingActionButtonTheme: _buildFABTheme(Brightness.light),
    );
  }
}

/// Dark theme configuration
class AppDarkTheme {
  AppDarkTheme._();
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondary,
        error: AppColors.errorDark,
        surface: AppColors.surfaceDark,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: _buildAppBarTheme(Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.dark),
      textButtonTheme: _buildTextButtonTheme(Brightness.dark),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
      cardTheme: _buildCardTheme(Brightness.dark),
      bottomNavigationBarTheme: _buildBottomNavTheme(Brightness.dark),
      navigationRailTheme: _buildNavigationRailTheme(Brightness.dark),
      dialogTheme: _buildDialogTheme(Brightness.dark),
      snackBarTheme: _buildSnackBarTheme(Brightness.dark),
      floatingActionButtonTheme: _buildFABTheme(Brightness.dark),
    );
  }
}

// Helper methods for building theme components
TextTheme _buildTextTheme(Brightness brightness) {
  final baseTextTheme = GoogleFonts.interTextTheme();
  final color = brightness == Brightness.light 
    ? AppColors.onSurfaceLight 
    : AppColors.onSurfaceDark;
    
  return baseTextTheme.copyWith(
    displayLarge: baseTextTheme.displayLarge?.copyWith(color: color),
    displayMedium: baseTextTheme.displayMedium?.copyWith(color: color),
    displaySmall: baseTextTheme.displaySmall?.copyWith(color: color),
    headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: color),
    headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: color),
    headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: color),
    titleLarge: baseTextTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
    titleMedium: baseTextTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w500),
    titleSmall: baseTextTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w500),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: color),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: color),
    bodySmall: baseTextTheme.bodySmall?.copyWith(color: color),
    labelLarge: baseTextTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w500),
    labelMedium: baseTextTheme.labelMedium?.copyWith(color: color),
    labelSmall: baseTextTheme.labelSmall?.copyWith(color: color),
  );
}

AppBarTheme _buildAppBarTheme(Brightness brightness) {
  return AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: brightness == Brightness.light 
      ? AppColors.surfaceLight 
      : AppColors.surfaceDark,
    foregroundColor: brightness == Brightness.light 
      ? AppColors.onSurfaceLight 
      : AppColors.onSurfaceDark,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: brightness == Brightness.light 
        ? AppColors.onSurfaceLight 
        : AppColors.onSurfaceDark,
    ),
  );
}

ElevatedButtonThemeData _buildElevatedButtonTheme(Brightness brightness) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

OutlinedButtonThemeData _buildOutlinedButtonTheme(Brightness brightness) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(
        color: brightness == Brightness.light 
          ? AppColors.primaryBlue 
          : AppColors.primaryLight,
        width: 1.5,
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

TextButtonThemeData _buildTextButtonTheme(Brightness brightness) {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

InputDecorationTheme _buildInputDecorationTheme(Brightness brightness) {
  return InputDecorationTheme(
    filled: true,
    fillColor: brightness == Brightness.light 
      ? AppColors.surfaceLight 
      : AppColors.surfaceDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: brightness == Brightness.light 
          ? Colors.grey.shade300 
          : Colors.grey.shade700,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: brightness == Brightness.light 
          ? Colors.grey.shade300 
          : Colors.grey.shade700,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: brightness == Brightness.light 
          ? AppColors.primaryBlue 
          : AppColors.primaryLight,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: brightness == Brightness.light 
          ? AppColors.error 
          : AppColors.errorDark,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    labelStyle: GoogleFonts.inter(
      color: brightness == Brightness.light 
        ? Colors.grey.shade600 
        : Colors.grey.shade400,
    ),
    hintStyle: GoogleFonts.inter(
      color: brightness == Brightness.light 
        ? Colors.grey.shade500 
        : Colors.grey.shade500,
    ),
  );
}

CardThemeData _buildCardTheme(Brightness brightness) {
  return CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: brightness == Brightness.light 
      ? AppColors.surfaceLight 
      : AppColors.surfaceDark,
  );
}

BottomNavigationBarThemeData _buildBottomNavTheme(Brightness brightness) {
  return BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    backgroundColor: brightness == Brightness.light 
      ? AppColors.surfaceLight 
      : AppColors.surfaceDark,
    selectedItemColor: brightness == Brightness.light 
      ? AppColors.primaryBlue 
      : AppColors.primaryLight,
    unselectedItemColor: brightness == Brightness.light 
      ? Colors.grey.shade600 
      : Colors.grey.shade400,
    selectedLabelStyle: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    unselectedLabelStyle: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  );
}

NavigationRailThemeData _buildNavigationRailTheme(Brightness brightness) {
  return NavigationRailThemeData(
    backgroundColor: brightness == Brightness.light 
      ? AppColors.surfaceLight 
      : AppColors.surfaceDark,
    selectedIconTheme: IconThemeData(
      color: brightness == Brightness.light 
        ? AppColors.primaryBlue 
        : AppColors.primaryLight,
    ),
    unselectedIconTheme: IconThemeData(
      color: brightness == Brightness.light 
        ? Colors.grey.shade600 
        : Colors.grey.shade400,
    ),
    selectedLabelTextStyle: GoogleFonts.inter(
      color: brightness == Brightness.light 
        ? AppColors.primaryBlue 
        : AppColors.primaryLight,
      fontWeight: FontWeight.w500,
    ),
    unselectedLabelTextStyle: GoogleFonts.inter(
      color: brightness == Brightness.light 
        ? Colors.grey.shade600 
        : Colors.grey.shade400,
    ),
  );
}

DialogThemeData _buildDialogTheme(Brightness brightness) {
  return DialogThemeData(
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    backgroundColor: brightness == Brightness.light 
      ? AppColors.surfaceLight 
      : AppColors.surfaceDark,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: brightness == Brightness.light 
        ? AppColors.onSurfaceLight 
        : AppColors.onSurfaceDark,
    ),
    contentTextStyle: GoogleFonts.inter(
      fontSize: 16,
      color: brightness == Brightness.light 
        ? AppColors.onSurfaceLight 
        : AppColors.onSurfaceDark,
    ),
  );
}

SnackBarThemeData _buildSnackBarTheme(Brightness brightness) {
  return SnackBarThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
    backgroundColor: brightness == Brightness.light 
      ? AppColors.onSurfaceLight 
      : AppColors.onSurfaceDark,
    contentTextStyle: GoogleFonts.inter(
      color: brightness == Brightness.light 
        ? AppColors.surfaceLight 
        : AppColors.surfaceDark,
      fontWeight: FontWeight.w500,
    ),
  );
}

FloatingActionButtonThemeData _buildFABTheme(Brightness brightness) {
  return FloatingActionButtonThemeData(
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    backgroundColor: brightness == Brightness.light 
      ? AppColors.primaryBlue 
      : AppColors.primaryLight,
    foregroundColor: brightness == Brightness.light 
      ? AppColors.onPrimaryLight 
      : AppColors.onPrimaryDark,
  );
}