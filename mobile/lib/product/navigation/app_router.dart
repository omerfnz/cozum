import 'package:auto_route/auto_route.dart';
import 'package:mobile/feature/auth/view/login_view.dart';
import 'package:mobile/feature/auth/view/register_view.dart';
import 'package:mobile/feature/home/view/home_view.dart';
import 'package:mobile/feature/splash/view/splash_view.dart';

part 'app_router.gr.dart';

/// Uygulama yönlendirme yapılandırması
@AutoRouterConfig(replaceInRouteName: 'View,Route')
final class AppRouter extends RootStackRouter {
  /// Uygulamanın tüm rotaları
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, path: '/', initial: true),
        AutoRoute(page: LoginRoute.page, path: '/auth/login'),
        AutoRoute(page: RegisterRoute.page, path: '/auth/register'),
        AutoRoute(page: HomeRoute.page, path: '/home'),
      ];
}
