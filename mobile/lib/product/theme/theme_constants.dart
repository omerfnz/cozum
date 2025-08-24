import 'package:flutter/material.dart';

/// Design system constants
class AppDimensions {
  const AppDimensions._();
  
  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusRound = 999.0;
  
  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;
  
  // Button heights
  static const double buttonSmall = 36.0;
  static const double buttonMedium = 44.0;
  static const double buttonLarge = 52.0;
  
  // Input field heights
  static const double inputSmall = 40.0;
  static const double inputMedium = 48.0;
  static const double inputLarge = 56.0;
  
  // Card elevations
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 12.0;
  
  // Layout breakpoints
  static const double breakpointMobile = 768.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1440.0;
  
  // Maximum content width
  static const double maxContentWidth = 1200.0;
  
  // Minimum touch target size
  static const double minTouchTarget = 44.0;
}

/// Animation durations
class AppDurations {
  const AppDurations._();
  
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 1000);
  
  // Specific animations
  static const Duration pageTransition = medium;
  static const Duration buttonPress = fast;
  static const Duration dialogShow = medium;
  static const Duration snackBar = slow;
  static const Duration shimmer = Duration(milliseconds: 1500);
}

/// Animation curves
class AppCurves {
  const AppCurves._();
  
  static const Curve ease = Curves.ease;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  
  // Custom curves
  static const Curve materialMotion = Curves.easeInOut;
  static const Curve pageTransition = Curves.easeInOut;
}

/// Text styles based on Material 3 typography
class AppTextStyles {
  const AppTextStyles._();
  
  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );
  
  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.29,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );
  
  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.27,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.50,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
  
  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.50,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
}

/// Shadows for Material Design
class AppShadows {
  const AppShadows._();
  
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];
  
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];
  
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];
  
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 10),
      blurRadius: 15,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 6,
    ),
  ];
  
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 20),
      blurRadius: 25,
    ),
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 10),
      blurRadius: 10,
    ),
  ];
}

/// Theme utility extensions
extension ThemeUtils on BuildContext {
  /// Get theme data
  ThemeData get theme => Theme.of(this);
  
  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Get text theme
  TextTheme get textTheme => theme.textTheme;
  
  /// Check if current theme is dark
  bool get isDark => theme.brightness == Brightness.dark;
  
  /// Check if current theme is light
  bool get isLight => theme.brightness == Brightness.light;
  
  /// Get responsive breakpoint
  bool get isMobile => MediaQuery.of(this).size.width < AppDimensions.breakpointMobile;
  bool get isTablet => MediaQuery.of(this).size.width >= AppDimensions.breakpointMobile && 
                      MediaQuery.of(this).size.width < AppDimensions.breakpointTablet;
  bool get isDesktop => MediaQuery.of(this).size.width >= AppDimensions.breakpointTablet;
  
  /// Get safe padding
  EdgeInsets get safePadding => MediaQuery.of(this).padding;
  
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Get keyboard height
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;
  
  /// Check if keyboard is visible
  bool get isKeyboardVisible => keyboardHeight > 0;
}

/// Common edge insets
class AppPadding {
  const AppPadding._();
  
  // All sides
  static const EdgeInsets allXs = EdgeInsets.all(AppDimensions.xs);
  static const EdgeInsets allSm = EdgeInsets.all(AppDimensions.sm);
  static const EdgeInsets allMd = EdgeInsets.all(AppDimensions.md);
  static const EdgeInsets allLg = EdgeInsets.all(AppDimensions.lg);
  static const EdgeInsets allXl = EdgeInsets.all(AppDimensions.xl);
  
  // Symmetric
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: AppDimensions.xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: AppDimensions.sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: AppDimensions.md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: AppDimensions.lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: AppDimensions.xl);
  
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: AppDimensions.xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: AppDimensions.sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: AppDimensions.md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: AppDimensions.lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: AppDimensions.xl);
  
  // Page padding
  static const EdgeInsets page = EdgeInsets.all(AppDimensions.md);
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: AppDimensions.md);
  static const EdgeInsets pageVertical = EdgeInsets.symmetric(vertical: AppDimensions.md);
  
  // Card padding
  static const EdgeInsets card = EdgeInsets.all(AppDimensions.lg);
  static const EdgeInsets cardHorizontal = EdgeInsets.symmetric(horizontal: AppDimensions.lg);
  static const EdgeInsets cardVertical = EdgeInsets.symmetric(vertical: AppDimensions.lg);
}