import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State management initialization wrapper
final class StateInitialize extends StatelessWidget {
  const StateInitialize({required this.child, super.key});
  
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Global BLoC providers will be added here as we create them
    final providers = <BlocProvider<dynamic>>[
      // Example:
      // BlocProvider<AuthCubit>(
      //   create: (context) => serviceLocator<AuthCubit>(),
      // ),
    ];

    if (providers.isEmpty) {
      // Eğer henüz global provider yoksa, gereksiz MultiBlocProvider sarmalamasını kullanmayalım
      return child;
    }

    return MultiBlocProvider(
      providers: providers,
      child: child,
    );
  }
}