import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tema durumları
enum ThemeMode {
  /// Sistem temasını takip et
  system,
  /// Açık tema
  light,
  /// Koyu tema
  dark,
}

/// Tema durumu
class ThemeState {
  /// Tema modu
  final ThemeMode themeMode;
  
  /// Sistem koyu tema durumu
  final bool isSystemDark;
  
  const ThemeState({
    required this.themeMode,
    required this.isSystemDark,
  });
  
  /// Aktif tema koyu mu?
  bool get isDark {
    switch (themeMode) {
      case ThemeMode.system:
        return isSystemDark;
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
    }
  }
  
  /// Kopya oluştur
  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isSystemDark,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isSystemDark: isSystemDark ?? this.isSystemDark,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeState &&
        other.themeMode == themeMode &&
        other.isSystemDark == isSystemDark;
  }
  
  @override
  int get hashCode => themeMode.hashCode ^ isSystemDark.hashCode;
}

/// Tema yönetimi cubit'i
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';
  final FlutterSecureStorage _storage;
  
  ThemeCubit(this._storage) : super(
    const ThemeState(
      themeMode: ThemeMode.system,
      isSystemDark: false,
    ),
  );
  
  /// Tema durumunu yükle
  Future<void> loadTheme() async {
    try {
      final savedTheme = await _storage.read(key: _themeKey);
      final themeMode = _parseThemeMode(savedTheme);
      
      emit(state.copyWith(themeMode: themeMode));
    } catch (e) {
      // Hata durumunda varsayılan tema kullan
      emit(state.copyWith(themeMode: ThemeMode.system));
    }
  }
  
  /// Sistem tema değişikliğini güncelle
  void updateSystemTheme(bool isDark) {
    emit(state.copyWith(isSystemDark: isDark));
  }
  
  /// Tema modunu değiştir
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      await _storage.write(key: _themeKey, value: themeMode.name);
      emit(state.copyWith(themeMode: themeMode));
    } catch (e) {
      // Hata durumunda sadece emit et, storage'a kaydetme
      emit(state.copyWith(themeMode: themeMode));
    }
  }
  
  /// Açık temaya geç
  Future<void> setLightTheme() => setThemeMode(ThemeMode.light);
  
  /// Koyu temaya geç
  Future<void> setDarkTheme() => setThemeMode(ThemeMode.dark);
  
  /// Sistem temasını takip et
  Future<void> setSystemTheme() => setThemeMode(ThemeMode.system);
  
  /// Tema modunu toggle et (açık/koyu)
  Future<void> toggleTheme() async {
    if (state.themeMode == ThemeMode.system) {
      // Sistem temasındaysa, mevcut sistem durumunun tersine geç
      await setThemeMode(state.isSystemDark ? ThemeMode.light : ThemeMode.dark);
    } else {
      // Manuel temadaysa, tersine çevir
      await setThemeMode(state.isDark ? ThemeMode.light : ThemeMode.dark);
    }
  }
  
  /// String'den tema modunu parse et
  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}