import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SnackbarType { success, error, warning, info }

extension SnackbarX on BuildContext {
  void showSnack(
    String message, {
    SnackbarType type = SnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(this);

    Color background;
    Color foreground;

    switch (type) {
      case SnackbarType.success:
        background = theme.brightness == Brightness.light
            ? AppColors.success
            : AppColors.successDark;
        foreground = theme.colorScheme.onPrimary;
        break;
      case SnackbarType.error:
        background = theme.brightness == Brightness.light
            ? AppColors.error
            : AppColors.errorDark;
        foreground = theme.colorScheme.onPrimary;
        break;
      case SnackbarType.warning:
        background = theme.brightness == Brightness.light
            ? AppColors.warning
            : AppColors.warningDark;
        foreground = theme.colorScheme.onPrimary;
        break;
      case SnackbarType.info:
        background = theme.brightness == Brightness.light
            ? AppColors.info
            : AppColors.infoDark;
        foreground = theme.colorScheme.onPrimary;
        break;
    }

    final snackBar = SnackBar(
      content: Text(
        message,
        style: theme.snackBarTheme.contentTextStyle?.copyWith(color: foreground) ??
            TextStyle(color: foreground, fontWeight: FontWeight.w600),
      ),
      backgroundColor: background,
      behavior: theme.snackBarTheme.behavior,
      shape: theme.snackBarTheme.shape,
      duration: duration,
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(label: actionLabel, onPressed: onAction, textColor: foreground)
          : null,
    );

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}