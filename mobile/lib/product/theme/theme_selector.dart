import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/theme_cubit.dart';
import '../theme/theme_constants.dart';

/// Theme selector widget for choosing app theme
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({
    super.key,
    this.showLabels = true,
    this.isExpanded = false,
  });
  
  final bool showLabels;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        if (isExpanded) {
          return _buildExpandedSelector(context, state);
        } else {
          return _buildCompactSelector(context, state);
        }
      },
    );
  }
  
  Widget _buildExpandedSelector(BuildContext context, ThemeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabels) ...[
          Text(
            'Theme',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
        ],
        ...AppThemeMode.values.map((mode) => _buildThemeOption(context, mode, state)),
      ],
    );
  }
  
  Widget _buildCompactSelector(BuildContext context, ThemeState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabels) ...[
          Text(
            'Theme:',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(width: AppDimensions.sm),
        ],
        SegmentedButton<AppThemeMode>(
          segments: AppThemeMode.values.map((mode) {
            return ButtonSegment<AppThemeMode>(
              value: mode,
              icon: Icon(mode.icon, size: AppDimensions.iconSm),
              label: Text(mode.displayName),
            );
          }).toList(),
          selected: {state.themeMode},
          onSelectionChanged: (Set<AppThemeMode> selection) {
            context.read<ThemeCubit>().changeTheme(selection.first);
          },
          showSelectedIcon: false,
        ),
      ],
    );
  }
  
  Widget _buildThemeOption(BuildContext context, AppThemeMode mode, ThemeState state) {
    final isSelected = state.themeMode == mode;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.xs),
      child: InkWell(
        onTap: () => context.read<ThemeCubit>().changeTheme(mode),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: AppPadding.allMd,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: isSelected 
                ? context.colorScheme.primary 
                : context.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected 
              ? context.colorScheme.primary.withValues(alpha: 0.1) 
              : null,
          ),
          child: Row(
            children: [
              Icon(
                mode.icon,
                color: isSelected 
                  ? context.colorScheme.primary 
                  : context.colorScheme.onSurface,
                size: AppDimensions.iconMd,
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.displayName,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: isSelected 
                          ? context.colorScheme.primary 
                          : context.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    Text(
                      _getThemeDescription(mode),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: context.colorScheme.primary,
                  size: AppDimensions.iconMd,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getThemeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light colors and bright interface';
      case AppThemeMode.dark:
        return 'Dark colors and dim interface';
      case AppThemeMode.system:
        return 'Follows your device\'s theme setting';
    }
  }
}

/// Simple theme toggle button
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({
    super.key,
    this.size = AppDimensions.iconMd,
  });
  
  final double size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return IconButton(
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          icon: AnimatedSwitcher(
            duration: AppDurations.medium,
            child: Icon(
              state.themeMode.icon,
              key: ValueKey(state.themeMode),
              size: size,
            ),
          ),
          tooltip: 'Switch to ${_getNextTheme(state.themeMode).displayName}',
        );
      },
    );
  }
  
  AppThemeMode _getNextTheme(AppThemeMode current) {
    switch (current) {
      case AppThemeMode.light:
        return AppThemeMode.dark;
      case AppThemeMode.dark:
        return AppThemeMode.light;
      case AppThemeMode.system:
        return AppThemeMode.light;
    }
  }
}

/// Theme status indicator
class ThemeStatusIndicator extends StatelessWidget {
  const ThemeStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Container(
          padding: AppPadding.allSm,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            border: Border.all(
              color: context.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                state.themeMode.icon,
                size: AppDimensions.iconSm,
                color: context.colorScheme.primary,
              ),
              const SizedBox(width: AppDimensions.xs),
              Text(
                state.themeMode.displayName,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}