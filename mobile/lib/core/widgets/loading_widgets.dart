import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/extensions.dart';
import 'package:mobile/core/widgets/error_widgets.dart';

/// Global loading widget for full screen loading states
class GlobalLoadingWidget extends StatelessWidget {
  const GlobalLoadingWidget({
    super.key,
    this.message = 'Yükleniyor...',
    this.showMessage = true,
  });

  final String message;
  final bool showMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: context.responsiveIconSize(40),
              height: context.responsiveIconSize(40),
              child: CircularProgressIndicator(
                strokeWidth: context.isMobile ? 3 : 4,
                color: context.primaryColor,
              ),
            ),
            if (showMessage) ...[
              SizedBox(height: context.isMobile ? 16 : 20),
              Text(
                message,
                style: context.bodyMedium?.copyWith(
                  fontSize: context.responsiveFontSize(14),
                  color: context.onSurfaceColor.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact loading widget for smaller spaces
class CompactLoadingWidget extends StatelessWidget {
  const CompactLoadingWidget({
    super.key,
    this.size,
  });

  final double? size;

  @override
  Widget build(BuildContext context) {
    final loadingSize = size ?? context.responsiveIconSize(24);
    
    return Center(
      child: SizedBox(
        width: loadingSize,
        height: loadingSize,
        child: CircularProgressIndicator(
          strokeWidth: context.isMobile ? 2 : 2.5,
          color: context.primaryColor,
        ),
      ),
    );
  }
}

/// Loading overlay for buttons
class ButtonLoadingWidget extends StatelessWidget {
  const ButtonLoadingWidget({
    super.key,
    this.size,
    this.color,
  });

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final loadingSize = size ?? context.responsiveIconSize(16);
    final loadingColor = color ?? context.onPrimaryColor;
    
    return SizedBox(
      width: loadingSize,
      height: loadingSize,
      child: CircularProgressIndicator(
        strokeWidth: context.isMobile ? 2 : 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
      ),
    );
  }
}

/// Loading widget for list items (pagination)
class ListLoadingWidget extends StatelessWidget {
  const ListLoadingWidget({
    super.key,
    this.padding,
  });

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? context.responsivePadding,
      child: Center(
        child: SizedBox(
          width: context.responsiveIconSize(32),
          height: context.responsiveIconSize(32),
          child: CircularProgressIndicator(
            strokeWidth: context.isMobile ? 3 : 3.5,
            color: context.primaryColor,
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading effect for content placeholders
class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: child,
    );
  }
}

/// Loading state mixin for StatefulWidgets
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
        if (loading) _error = null;
      });
    }
  }

  void setError(String? error) {
    if (mounted) {
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  void clearError() {
    if (mounted) {
      setState(() {
        _error = null;
      });
    }
  }

  Widget buildLoadingState() {
    return const GlobalLoadingWidget();
  }

  Widget buildErrorState(VoidCallback onRetry) {
    return GlobalErrorWidget(
      error: _error!,
      onRetry: onRetry,
    );
  }
}