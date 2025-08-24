import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Localization initialization wrapper
final class LocalizationInitialize extends StatelessWidget {
  const LocalizationInitialize({required this.child, super.key});
  
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      path: 'asset/translations',
      fallbackLocale: const Locale('tr', 'TR'),
      startLocale: const Locale('tr', 'TR'),
      child: child,
    );
  }
}