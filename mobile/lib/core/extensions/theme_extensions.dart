import 'package:flutter/material.dart';

/// Tema uzantıları
extension ThemeExtensions on BuildContext {
  /// Mevcut tema
  ThemeData get theme => Theme.of(this);
  
  /// Renk şeması
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Text tema
  TextTheme get textTheme => theme.textTheme;
  
  /// Koyu tema mı?
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  /// Açık tema mı?
  bool get isLightMode => theme.brightness == Brightness.light;
  
  /// Primary renk
  Color get primaryColor => colorScheme.primary;
  
  /// Secondary renk
  Color get secondaryColor => colorScheme.secondary;
  
  /// Surface renk
  Color get surfaceColor => colorScheme.surface;
  
  /// Background renk
  Color get backgroundColor => colorScheme.surface;
  
  /// Error renk
  Color get errorColor => colorScheme.error;
  
  /// On primary renk
  Color get onPrimaryColor => colorScheme.onPrimary;
  
  /// On secondary renk
  Color get onSecondaryColor => colorScheme.onSecondary;
  
  /// On surface renk
  Color get onSurfaceColor => colorScheme.onSurface;
  
  /// On background renk
  Color get onBackgroundColor => colorScheme.onSurface;
  
  /// On error renk
  Color get onErrorColor => colorScheme.onError;
  
  /// Outline renk
  Color get outlineColor => colorScheme.outline;
  
  /// Outline variant renk
  Color get outlineVariantColor => colorScheme.outlineVariant;
  
  /// Shadow renk
  Color get shadowColor => colorScheme.shadow;
  
  /// Surface tint renk
  Color get surfaceTintColor => colorScheme.surfaceTint;
  
  /// Inverse surface renk
  Color get inverseSurfaceColor => colorScheme.inverseSurface;
  
  /// Inverse on surface renk
  Color get inverseOnSurfaceColor => colorScheme.onInverseSurface;
  
  /// Inverse primary renk
  Color get inversePrimaryColor => colorScheme.inversePrimary;
  
  /// Primary container renk
  Color get primaryContainerColor => colorScheme.primaryContainer;
  
  /// On primary container renk
  Color get onPrimaryContainerColor => colorScheme.onPrimaryContainer;
  
  /// Secondary container renk
  Color get secondaryContainerColor => colorScheme.secondaryContainer;
  
  /// On secondary container renk
  Color get onSecondaryContainerColor => colorScheme.onSecondaryContainer;
  
  /// Tertiary renk
  Color get tertiaryColor => colorScheme.tertiary;
  
  /// On tertiary renk
  Color get onTertiaryColor => colorScheme.onTertiary;
  
  /// Tertiary container renk
  Color get tertiaryContainerColor => colorScheme.tertiaryContainer;
  
  /// On tertiary container renk
  Color get onTertiaryContainerColor => colorScheme.onTertiaryContainer;
  
  /// Error container renk
  Color get errorContainerColor => colorScheme.errorContainer;
  
  /// On error container renk
  Color get onErrorContainerColor => colorScheme.onErrorContainer;
  
  /// Surface variant renk
  Color get surfaceVariantColor => colorScheme.surfaceContainerHighest;
  
  /// On surface variant renk
  Color get onSurfaceVariantColor => colorScheme.onSurfaceVariant;
  
  /// Scrim renk
  Color get scrimColor => colorScheme.scrim;
  
  // Text stilleri
  
  /// Display large text style
  TextStyle? get displayLarge => textTheme.displayLarge;
  
  /// Display medium text style
  TextStyle? get displayMedium => textTheme.displayMedium;
  
  /// Display small text style
  TextStyle? get displaySmall => textTheme.displaySmall;
  
  /// Headline large text style
  TextStyle? get headlineLarge => textTheme.headlineLarge;
  
  /// Headline medium text style
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  
  /// Headline small text style
  TextStyle? get headlineSmall => textTheme.headlineSmall;
  
  /// Title large text style
  TextStyle? get titleLarge => textTheme.titleLarge;
  
  /// Title medium text style
  TextStyle? get titleMedium => textTheme.titleMedium;
  
  /// Title small text style
  TextStyle? get titleSmall => textTheme.titleSmall;
  
  /// Body large text style
  TextStyle? get bodyLarge => textTheme.bodyLarge;
  
  /// Body medium text style
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  
  /// Body small text style
  TextStyle? get bodySmall => textTheme.bodySmall;
  
  /// Label large text style
  TextStyle? get labelLarge => textTheme.labelLarge;
  
  /// Label medium text style
  TextStyle? get labelMedium => textTheme.labelMedium;
  
  /// Label small text style
  TextStyle? get labelSmall => textTheme.labelSmall;
  
  // Özel renk yardımcıları
  
  /// Başarı rengi
  Color get successColor => isDarkMode 
      ? const Color(0xFF4CAF50) 
      : const Color(0xFF2E7D32);
  
  /// Uyarı rengi
  Color get warningColor => isDarkMode 
      ? const Color(0xFFFF9800) 
      : const Color(0xFFE65100);
  
  /// Bilgi rengi
  Color get infoColor => isDarkMode 
      ? const Color(0xFF2196F3) 
      : const Color(0xFF1565C0);
  
  /// Disabled renk
  Color get disabledColor => onSurfaceColor.withValues(alpha: 0.38);
  
  /// Hint renk
  Color get hintColor => onSurfaceColor.withValues(alpha: 0.6);
  
  /// Divider renk
  Color get dividerColor => outlineVariantColor;
  
  /// Focus renk
  Color get focusColor => primaryColor.withValues(alpha: 0.12);
  
  /// Hover renk
  Color get hoverColor => onSurfaceColor.withValues(alpha: 0.04);
  
  /// Splash renk
  Color get splashColor => onSurfaceColor.withValues(alpha: 0.12);
  
  /// Highlight renk
  Color get highlightColor => onSurfaceColor.withValues(alpha: 0.12);
  
  // Özel text style yardımcıları
  
  /// Başlık text style
  TextStyle get titleStyle => titleLarge?.copyWith(
    fontWeight: FontWeight.w600,
    color: onSurfaceColor,
  ) ?? const TextStyle();
  
  /// Alt başlık text style
  TextStyle get subtitleStyle => titleMedium?.copyWith(
    fontWeight: FontWeight.w500,
    color: onSurfaceColor.withValues(alpha: 0.8),
  ) ?? const TextStyle();
  
  /// Caption text style
  TextStyle get captionStyle => bodySmall?.copyWith(
    color: onSurfaceColor.withValues(alpha: 0.6),
  ) ?? const TextStyle();
  
  /// Button text style
  TextStyle get buttonStyle => labelLarge?.copyWith(
    fontWeight: FontWeight.w500,
  ) ?? const TextStyle();
  
  /// Link text style
  TextStyle get linkStyle => bodyMedium?.copyWith(
    color: primaryColor,
    decoration: TextDecoration.underline,
  ) ?? const TextStyle();
  
  /// Error text style
  TextStyle get errorStyle => bodySmall?.copyWith(
    color: errorColor,
  ) ?? const TextStyle();
  
  /// Success text style
  TextStyle get successStyle => bodySmall?.copyWith(
    color: successColor,
  ) ?? const TextStyle();
  
  /// Warning text style
  TextStyle get warningStyle => bodySmall?.copyWith(
    color: warningColor,
  ) ?? const TextStyle();
  
  /// Info text style
  TextStyle get infoStyle => bodySmall?.copyWith(
    color: infoColor,
  ) ?? const TextStyle();
}

/// Renk uzantıları
extension ColorExtensions on Color {
  /// Rengi daha açık yap
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Rengi daha koyu yap
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Rengin hex değeri
  String get hexValue {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
  
  /// Rengin luminance değeri
  double get luminance => computeLuminance();
  
  /// Renk açık mı?
  bool get isLight => luminance > 0.5;
  
  /// Renk koyu mu?
  bool get isDark => luminance <= 0.5;
  
  /// Kontrast rengi (siyah veya beyaz)
  Color get contrastColor => isLight ? Colors.black : Colors.white;
  
  /// Material renk
  MaterialColor get materialColor {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = (this.r * 255.0).round() & 0xff;
    final g = (this.g * 255.0).round() & 0xff;
    final b = (this.b * 255.0).round() & 0xff;
    
    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(toARGB32(), swatch);
  }
}