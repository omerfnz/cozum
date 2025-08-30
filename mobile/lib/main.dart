import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'product/init/application_initialize.dart';
import 'product/init/localization_initialize.dart';
import 'product/init/state_initialize.dart';
import 'product/navigation/app_router.dart';
import 'product/init/service_locator.dart';
import 'product/theme/theme_cubit.dart';
import 'product/theme/app_theme.dart';
import 'product/widgets/connectivity_banner.dart';

Future<void> main() async {
  await ApplicationInitialize().make();
  
  runApp(
    LocalizationInitialize(
      child: const StateInitialize(
        child: _MyApp(),
      ),
    ),
  );
}

final class _MyApp extends StatelessWidget {
  const _MyApp();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => serviceLocator<ThemeCubit>()),
        BlocProvider(create: (context) => ConnectivityCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final appRouter = serviceLocator<AppRouter>();
          
          return MaterialApp.router(
            title: 'Çözüm Var',
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter.config(),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            themeMode: themeState.themeMode.themeMode,
            theme: AppLightTheme.theme,
            darkTheme: AppDarkTheme.theme,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
                  ),
                ),
                child: Stack(
                  children: [
                    child ?? const SizedBox.shrink(),
                    ConnectivityBanner(child: const SizedBox.shrink()),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
