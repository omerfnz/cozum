import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/extensions.dart';
import 'package:mobile/core/theme/theme.dart' as core_theme;

/// Ayarlar sayfası
class SettingsView extends StatelessWidget {
  /// Varsayılan kurucu
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        elevation: 0,
      ),
      body: BlocBuilder<core_theme.ThemeCubit, core_theme.ThemeState>(
        builder: (context, themeState) {
          return ListView(
            padding: context.responsivePadding,
            children: [
              // Tema Ayarları Bölümü
              const _SectionHeader(
                title: 'Tema Ayarları',
                icon: Icons.palette_outlined,
              ),
              const SizedBox(height: 8),
              
              // Tema Modu Seçimi
              _ThemeModeCard(
                currentThemeMode: themeState.themeMode,
                onThemeModeChanged: (mode) {
                  context.read<core_theme.ThemeCubit>().setThemeMode(mode);
                },
              ),
              
              const SizedBox(height: 24),
              
              // Görünüm Ayarları Bölümü
              const _SectionHeader(
                title: 'Görünüm Ayarları',
                icon: Icons.visibility_outlined,
              ),
              const SizedBox(height: 8),
              
              // Responsive Bilgileri
              const _ResponsiveInfoCard(),
              
              const SizedBox(height: 24),
              
              // Hakkında Bölümü
              const _SectionHeader(
                title: 'Hakkında',
                icon: Icons.info_outline,
              ),
              const SizedBox(height: 8),
              
              const _AboutCard(),
            ],
          );
        },
      ),
    );
  }
}

/// Bölüm başlığı widget'ı
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  
  const _SectionHeader({
    required this.title,
    required this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: context.responsiveIconSize(20),
          color: context.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.primaryColor,
          ),
        ),
      ],
    );
  }
}

/// Tema modu seçim kartı
class _ThemeModeCard extends StatelessWidget {
  final core_theme.ThemeMode currentThemeMode;
  final ValueChanged<core_theme.ThemeMode> onThemeModeChanged;
  
  const _ThemeModeCard({
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: context.responsiveCardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema Modu',
              style: context.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Açık Tema
            _ThemeModeOption(
              title: 'Açık Tema',
              subtitle: 'Her zaman açık tema kullan',
              icon: Icons.light_mode_outlined,
              isSelected: currentThemeMode == core_theme.ThemeMode.light,
              onTap: () => onThemeModeChanged(core_theme.ThemeMode.light),
            ),
            
            const SizedBox(height: 8),
            
            // Koyu Tema
            _ThemeModeOption(
              title: 'Koyu Tema',
              subtitle: 'Her zaman koyu tema kullan',
              icon: Icons.dark_mode_outlined,
              isSelected: currentThemeMode == core_theme.ThemeMode.dark,
              onTap: () => onThemeModeChanged(core_theme.ThemeMode.dark),
            ),
            
            const SizedBox(height: 8),
            
            // Sistem Teması
            _ThemeModeOption(
              title: 'Sistem Teması',
              subtitle: 'Cihaz ayarlarını takip et',
              icon: Icons.settings_system_daydream_outlined,
              isSelected: currentThemeMode == core_theme.ThemeMode.system,
              onTap: () => onThemeModeChanged(core_theme.ThemeMode.system),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tema modu seçenek widget'ı
class _ThemeModeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _ThemeModeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
          border: Border.all(
            color: isSelected 
                ? context.primaryColor 
                : context.outlineVariantColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? context.primaryColor.withValues(alpha: 0.1) 
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: context.responsiveIconSize(24),
              color: isSelected 
                  ? context.primaryColor 
                  : context.onSurfaceColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? context.primaryColor 
                          : context.onSurfaceColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.bodySmall?.copyWith(
                      color: context.onSurfaceColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: context.responsiveIconSize(20),
                color: context.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}

/// Responsive bilgi kartı
class _ResponsiveInfoCard extends StatelessWidget {
  const _ResponsiveInfoCard();
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: context.responsiveCardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cihaz Bilgileri',
              style: context.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            _InfoRow(
              label: 'Ekran Boyutu',
              value: '${context.screenWidth.toInt()} x ${context.screenHeight.toInt()}',
            ),
            
            _InfoRow(
              label: 'Cihaz Tipi',
              value: context.isMobile 
                  ? 'Mobil' 
                  : context.isTablet 
                      ? 'Tablet' 
                      : 'Desktop',
            ),
            
            _InfoRow(
              label: 'Yönelim',
              value: context.isPortrait ? 'Dikey' : 'Yatay',
            ),
            
            _InfoRow(
              label: 'Pixel Oranı',
              value: context.devicePixelRatio.toStringAsFixed(1),
            ),
            
            _InfoRow(
              label: 'Tema Modu',
              value: Theme.of(context).brightness == Brightness.dark ? 'Koyu' : 'Açık',
            ),
          ],
        ),
      ),
    );
  }
}

/// Bilgi satırı widget'ı
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _InfoRow({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.bodyMedium?.copyWith(
              color: context.onSurfaceColor.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: context.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hakkında kartı
class _AboutCard extends StatelessWidget {
  const _AboutCard();
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: context.responsiveCardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uygulama Bilgileri',
              style: context.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            const _InfoRow(
              label: 'Uygulama Adı',
              value: 'Cozum Var',
            ),
            
            const _InfoRow(
              label: 'Versiyon',
              value: '1.0.0',
            ),
            
            const _InfoRow(
              label: 'Flutter Versiyon',
              value: '3.x.x',
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Bu uygulama modern Flutter mimarisi ile geliştirilmiştir. BLoC pattern, responsive tasarım ve tema sistemi kullanılmıştır.',
              style: context.bodySmall?.copyWith(
                color: context.onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}