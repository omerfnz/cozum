import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../service/storage/storage_service.dart';
import '../init/service_locator.dart';

/// Theme mode enumeration
enum AppThemeMode { 
  light, 
  dark, 
  system;
  
  /// Convert to Flutter's ThemeMode
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
  
  /// Create from string
  static AppThemeMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.system;
    }
  }
  
  /// Convert to string for storage
  String get value {
    switch (this) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }
  
  /// Display name for UI
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light Theme';
      case AppThemeMode.dark:
        return 'Dark Theme';
      case AppThemeMode.system:
        return 'System Default';
    }
  }
  
  /// Icon for UI
  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

/// Theme state
final class ThemeState extends Equatable {
  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.isLoading = false,
  });
  
  final AppThemeMode themeMode;
  final bool isLoading;
  
  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  @override
  List<Object> get props => [themeMode, isLoading];
}

/// Theme cubit for managing app theme
final class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }
  
  final IStorageService _storageService = serviceLocator<IStorageService>();
  static const String _themeKey = 'app_theme_mode';
  
  /// Load saved theme from storage
  Future<void> _loadTheme() async {
    try {
      emit(state.copyWith(isLoading: true));
      
      final savedTheme = await _storageService.read(_themeKey);
      if (savedTheme != null) {
        final themeMode = AppThemeMode.fromString(savedTheme);
        emit(state.copyWith(themeMode: themeMode, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      // Log error but don't crash, use default theme
    }
  }
  
  /// Change theme mode and save to storage
  Future<void> changeTheme(AppThemeMode themeMode) async {
    try {
      emit(state.copyWith(themeMode: themeMode));
      await _storageService.write(_themeKey, themeMode.value);
    } catch (e) {
      // Log error but don't revert UI change
      // The theme change will still work for current session
    }
  }
  
  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == AppThemeMode.light 
      ? AppThemeMode.dark 
      : AppThemeMode.light;
    await changeTheme(newMode);
  }
  
  /// Reset to system default
  Future<void> resetToSystem() async {
    await changeTheme(AppThemeMode.system);
  }
  
  /// Check if current theme is dark
  bool get isDarkMode {
    return state.themeMode == AppThemeMode.dark;
  }
  
  /// Check if current theme is light
  bool get isLightMode {
    return state.themeMode == AppThemeMode.light;
  }
  
  /// Check if using system theme
  bool get isSystemMode {
    return state.themeMode == AppThemeMode.system;
  }
}

/// Theme extensions for quick access
extension ThemeExtensions on BuildContext {
  /// Get current theme cubit
  ThemeCubit get themeCubit => BlocProvider.of<ThemeCubit>(this);
  
  /// Get current theme state
  ThemeState get themeState => themeCubit.state;
  
  /// Quick access to theme mode
  AppThemeMode get appThemeMode => themeState.themeMode;
  
  /// Check if dark mode is active (considering system theme)
  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    switch (appThemeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return brightness == Brightness.dark;
    }
  }
  
  /// Get appropriate color based on current theme
  Color get primaryColor {
    return isDarkMode 
      ? Theme.of(this).colorScheme.primary
      : Theme.of(this).colorScheme.primary;
  }
  
  /// Get surface color based on current theme
  Color get surfaceColor {
    return Theme.of(this).colorScheme.surface;
  }
  
  /// Get text color based on current theme
  Color get textColor {
    return Theme.of(this).colorScheme.onSurface;
  }
}