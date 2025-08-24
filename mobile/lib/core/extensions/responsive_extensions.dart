import 'package:flutter/material.dart';

/// Responsive tasarım için ekran boyutu uzantıları
extension ResponsiveExtensions on BuildContext {
  /// Ekran genişliği
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Ekran yüksekliği
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Ekran boyutu
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Cihaz pixel oranı
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;
  
  /// Güvenli alan padding'i
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;
  
  /// Klavye yüksekliği
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;
  
  /// Klavye açık mı?
  bool get isKeyboardOpen => keyboardHeight > 0;
  
  /// Telefon mu?
  bool get isMobile => screenWidth < 600;
  
  /// Tablet mi?
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  
  /// Desktop mu?
  bool get isDesktop => screenWidth >= 1200;
  
  /// Küçük ekran mı? (< 360dp)
  bool get isSmallScreen => screenWidth < 360;
  
  /// Orta ekran mı? (360-600dp)
  bool get isMediumScreen => screenWidth >= 360 && screenWidth < 600;
  
  /// Büyük ekran mı? (>= 600dp)
  bool get isLargeScreen => screenWidth >= 600;
  
  /// Dikey yönelim mi?
  bool get isPortrait => screenHeight > screenWidth;
  
  /// Yatay yönelim mi?
  bool get isLandscape => screenWidth > screenHeight;
  
  /// Responsive genişlik (ekran genişliğinin yüzdesi)
  double widthPercent(double percent) => screenWidth * (percent / 100);
  
  /// Responsive yükseklik (ekran yüksekliğinin yüzdesi)
  double heightPercent(double percent) => screenHeight * (percent / 100);
  
  /// Responsive padding
  EdgeInsets get responsivePadding {
    if (isMobile) {
      return const EdgeInsets.all(16);
    } else if (isTablet) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }
  
  /// Responsive margin
  EdgeInsets get responsiveMargin {
    if (isMobile) {
      return const EdgeInsets.all(8);
    } else if (isTablet) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(16);
    }
  }
  
  /// Responsive border radius
  double get responsiveBorderRadius {
    if (isMobile) {
      return 8;
    } else if (isTablet) {
      return 12;
    } else {
      return 16;
    }
  }
  
  /// Responsive font size
  double responsiveFontSize(double baseFontSize) {
    if (isMobile) {
      return baseFontSize;
    } else if (isTablet) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }
  
  /// Responsive icon size
  double responsiveIconSize(double baseIconSize) {
    if (isMobile) {
      return baseIconSize;
    } else if (isTablet) {
      return baseIconSize * 1.2;
    } else {
      return baseIconSize * 1.4;
    }
  }
  
  /// Grid column sayısı (responsive)
  int get responsiveGridColumns {
    if (isMobile) {
      return isPortrait ? 2 : 3;
    } else if (isTablet) {
      return isPortrait ? 3 : 4;
    } else {
      return 5;
    }
  }
  
  /// Liste item yüksekliği (responsive)
  double get responsiveListItemHeight {
    if (isMobile) {
      return 72;
    } else if (isTablet) {
      return 80;
    } else {
      return 88;
    }
  }
  
  /// App bar yüksekliği (responsive)
  double get responsiveAppBarHeight {
    if (isMobile) {
      return kToolbarHeight;
    } else if (isTablet) {
      return kToolbarHeight + 8;
    } else {
      return kToolbarHeight + 16;
    }
  }
  
  /// Bottom navigation bar yüksekliği (responsive)
  double get responsiveBottomNavHeight {
    if (isMobile) {
      return kBottomNavigationBarHeight;
    } else if (isTablet) {
      return kBottomNavigationBarHeight + 8;
    } else {
      return kBottomNavigationBarHeight + 16;
    }
  }
  
  /// Floating action button boyutu (responsive)
  double get responsiveFabSize {
    if (isMobile) {
      return 56;
    } else if (isTablet) {
      return 64;
    } else {
      return 72;
    }
  }
  
  /// Card elevation (responsive)
  double get responsiveCardElevation {
    if (isMobile) {
      return 2;
    } else if (isTablet) {
      return 4;
    } else {
      return 6;
    }
  }
  
  /// Dialog genişliği (responsive)
  double get responsiveDialogWidth {
    if (isMobile) {
      return screenWidth * 0.9;
    } else if (isTablet) {
      return 400;
    } else {
      return 500;
    }
  }
  
  /// Bottom sheet maksimum yüksekliği (responsive)
  double get responsiveBottomSheetMaxHeight {
    return screenHeight * 0.9;
  }
  
  /// Snackbar genişliği (responsive)
  double get responsiveSnackBarWidth {
    if (isMobile) {
      return screenWidth;
    } else {
      return 400;
    }
  }
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  /// Mobile widget builder
  final Widget Function(BuildContext context)? mobile;
  
  /// Tablet widget builder
  final Widget Function(BuildContext context)? tablet;
  
  /// Desktop widget builder
  final Widget Function(BuildContext context)? desktop;
  
  /// Varsayılan widget builder
  final Widget Function(BuildContext context) builder;
  
  /// Responsive widget builder constructor
  const ResponsiveBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    if (context.isMobile && mobile != null) {
      return mobile!(context);
    } else if (context.isTablet && tablet != null) {
      return tablet!(context);
    } else if (context.isDesktop && desktop != null) {
      return desktop!(context);
    }
    
    return builder(context);
  }
}

/// Responsive değer seçici
class ResponsiveValue<T> {
  /// Mobile değer
  final T mobile;
  
  /// Tablet değer
  final T? tablet;
  
  /// Desktop değer
  final T? desktop;
  
  /// Responsive değer constructor
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  /// Mevcut ekran boyutuna göre değer döndür
  T getValue(BuildContext context) {
    if (context.isMobile) {
      return mobile;
    } else if (context.isTablet) {
      return tablet ?? mobile;
    } else {
      return desktop ?? tablet ?? mobile;
    }
  }
}

/// Responsive değer uzantısı
extension ResponsiveValueExtension<T> on ResponsiveValue<T> {
  /// Değeri al
  T of(BuildContext context) => getValue(context);
}