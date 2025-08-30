import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../service/connectivity/connectivity_service.dart';

/// Connectivity status cubit
class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  ConnectivityCubit() : super(ConnectivityStatus.unknown) {
    _initialize();
  }
  
  final IConnectivityService _connectivityService = GetIt.I<IConnectivityService>();
  
  void _initialize() {
    // Set initial status
    emit(_connectivityService.currentStatus);
    
    // Listen to status changes
    _connectivityService.statusStream.listen((status) {
      emit(status);
    });
  }
  
  /// Force connectivity check
  Future<void> checkConnectivity() async {
    if (_connectivityService is ConnectivityService) {
      await (_connectivityService as ConnectivityService).forceCheck();
    }
  }
}

/// Connectivity banner widget that shows connection status
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({
    super.key,
    required this.child,
    this.showWhenConnected = false,
  });
  
  final Widget child;
  final bool showWhenConnected;
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConnectivityCubit(),
      child: BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
        builder: (context, status) {
          return Column(
            children: [
              if (_shouldShowBanner(status))
                _ConnectivityStatusBar(
                  status: status,
                  onRetry: () => context.read<ConnectivityCubit>().checkConnectivity(),
                ),
              Expanded(child: child),
            ],
          );
        },
      ),
    );
  }
  
  bool _shouldShowBanner(ConnectivityStatus status) {
    switch (status) {
      case ConnectivityStatus.connected:
        return showWhenConnected;
      case ConnectivityStatus.disconnected:
      case ConnectivityStatus.unknown:
        return true;
    }
  }
}

/// Internal connectivity status bar
class _ConnectivityStatusBar extends StatelessWidget {
  const _ConnectivityStatusBar({
    required this.status,
    required this.onRetry,
  });
  
  final ConnectivityStatus status;
  final VoidCallback onRetry;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String message;
    bool showRetryButton = false;
    
    switch (status) {
      case ConnectivityStatus.connected:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.wifi;
        message = 'Bağlantı kuruldu';
        break;
      case ConnectivityStatus.disconnected:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.wifi_off;
        message = 'İnternet bağlantısı yok - Önbellek verileri gösteriliyor';
        showRetryButton = true;
        break;
      case ConnectivityStatus.unknown:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.help_outline;
        message = 'Bağlantı durumu kontrol ediliyor...';
        showRetryButton = true;
        break;
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showRetryButton) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Tekrar Dene',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

/// Connectivity indicator widget for showing connection status in app bar
class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConnectivityCubit(),
      child: BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
        builder: (context, status) {
          if (status == ConnectivityStatus.connected) {
            return const SizedBox.shrink();
          }
          
          IconData icon;
          Color color;
          
          switch (status) {
            case ConnectivityStatus.disconnected:
              icon = Icons.wifi_off;
              color = Colors.red;
              break;
            case ConnectivityStatus.unknown:
              icon = Icons.help_outline;
              color = Colors.orange;
              break;
            case ConnectivityStatus.connected:
              icon = Icons.wifi;
              color = Colors.green;
              break;
          }
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          );
        },
      ),
    );
  }
}