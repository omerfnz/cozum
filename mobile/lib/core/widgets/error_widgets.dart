import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/extensions.dart';

/// Global error widget for displaying errors with retry functionality
class GlobalErrorWidget extends StatelessWidget {
  const GlobalErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
    this.title = 'Bir hata oluştu',
    this.iconSize,
  });

  final String error;
  final VoidCallback onRetry;
  final String title;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final errorIconSize = iconSize ?? context.responsiveIconSize(64);
    
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: errorIconSize,
              color: context.errorColor,
            ),
            SizedBox(height: context.isMobile ? 16 : 20),
            Text(
              title,
              style: context.headlineSmall?.copyWith(
                fontSize: context.responsiveFontSize(20),
                fontWeight: FontWeight.w600,
                color: context.onSurfaceColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.isMobile ? 8 : 12),
            Text(
              error,
              style: context.bodyMedium?.copyWith(
                fontSize: context.responsiveFontSize(14),
                color: context.onSurfaceColor.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.isMobile ? 24 : 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh,
                size: context.responsiveIconSize(18),
              ),
              label: Text(
                'Tekrar Dene',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(14),
                ),
              ),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: context.isMobile ? 24 : 32,
                  vertical: context.isMobile ? 12 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact error widget for smaller spaces
class CompactErrorWidget extends StatelessWidget {
  const CompactErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.responsiveMargin,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: context.responsiveIconSize(48),
              color: context.errorColor,
            ),
            SizedBox(height: context.isMobile ? 12 : 16),
            Text(
              'Bir hata oluştu',
              style: context.titleSmall?.copyWith(
                fontSize: context.responsiveFontSize(16),
                fontWeight: FontWeight.w600,
                color: context.onSurfaceColor,
              ),
            ),
            SizedBox(height: context.isMobile ? 4 : 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.bodySmall?.copyWith(
                fontSize: context.responsiveFontSize(12),
                color: context.onSurfaceColor.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: context.isMobile ? 12 : 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh,
                size: context.responsiveIconSize(16),
              ),
              label: Text(
                'Tekrar dene',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(12),
                ),
              ),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: context.isMobile ? 16 : 20,
                  vertical: context.isMobile ? 8 : 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error snackbar helper
class ErrorSnackBar {
  static void show(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String actionLabel = 'Tamam',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: context.responsiveFontSize(14),
            color: context.onErrorColor,
          ),
        ),
        backgroundColor: context.errorColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(context.isMobile ? 16 : 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
        ),
        action: onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: context.onErrorColor,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
  
  /// Success snackbar
  static void showSuccess(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String actionLabel = 'Tamam',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: context.responsiveFontSize(14),
            color: Colors.white,
          ),
        ),
        backgroundColor: context.successColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(context.isMobile ? 16 : 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
        ),
        action: onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
  
  /// Warning snackbar
  static void showWarning(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String actionLabel = 'Tamam',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: context.responsiveFontSize(14),
            color: Colors.white,
          ),
        ),
        backgroundColor: context.warningColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(context.isMobile ? 16 : 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
        ),
        action: onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
  
  /// Info snackbar
  static void showInfo(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String actionLabel = 'Tamam',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: context.responsiveFontSize(14),
            color: Colors.white,
          ),
        ),
        backgroundColor: context.infoColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(context.isMobile ? 16 : 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
        ),
        action: onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}

/// Network error widget with specific messaging
class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({
    super.key,
    required this.onRetry,
    this.message = 'İnternet bağlantınızı kontrol edin',
  });

  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              size: context.responsiveIconSize(64),
              color: context.errorColor,
            ),
            SizedBox(height: context.isMobile ? 16 : 20),
            Text(
              'Bağlantı Hatası',
              style: context.headlineSmall?.copyWith(
                fontSize: context.responsiveFontSize(20),
                fontWeight: FontWeight.w600,
                color: context.onSurfaceColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.isMobile ? 8 : 12),
            Text(
              message,
              style: context.bodyMedium?.copyWith(
                fontSize: context.responsiveFontSize(14),
                color: context.onSurfaceColor.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.isMobile ? 24 : 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh,
                size: context.responsiveIconSize(18),
              ),
              label: Text(
                'Tekrar Dene',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(14),
                ),
              ),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: context.isMobile ? 24 : 32,
                  vertical: context.isMobile ? 12 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.title = 'Veri bulunamadı',
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  final String message;
  final String title;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: context.responsiveIconSize(80),
              color: context.onSurfaceColor.withValues(alpha: 0.4),
            ),
            SizedBox(height: context.isMobile ? 16 : 20),
            Text(
              title,
              style: context.headlineSmall?.copyWith(
                fontSize: context.responsiveFontSize(18),
                fontWeight: FontWeight.w600,
                color: context.onSurfaceColor.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.isMobile ? 8 : 12),
            Text(
              message,
              style: context.bodyMedium?.copyWith(
                fontSize: context.responsiveFontSize(14),
                color: context.onSurfaceColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: context.isMobile ? 24 : 32),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isMobile ? 24 : 32,
                    vertical: context.isMobile ? 12 : 16,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}