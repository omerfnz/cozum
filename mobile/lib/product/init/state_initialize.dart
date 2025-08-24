import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State management initialization wrapper
final class StateInitialize extends StatelessWidget {
  const StateInitialize({required this.child, super.key});
  
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global BLoC providers will be added here as we create them
        // Example:
        // BlocProvider<AuthCubit>(
        //   create: (context) => serviceLocator<AuthCubit>(),
        // ),
      ],
      child: child,
    );
  }
}