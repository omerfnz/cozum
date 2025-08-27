import 'package:auto_route/auto_route.dart';
import '../init/service_locator.dart';
import '../service/auth/auth_service.dart';
import 'app_router.dart';

/// Authentication guard to protect routes that require login
class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    try {
      final authService = serviceLocator<IAuthService>();
      final isLoggedIn = await authService.isLoggedIn();
      
      if (isLoggedIn) {
        // User is authenticated, allow navigation
        resolver.next();
      } else {
        // User is not authenticated, redirect to login
        resolver.redirect(const LoginViewRoute());
      }
    } catch (e) {
      // Error checking authentication, redirect to login for safety
      resolver.redirect(const LoginViewRoute());
    }
  }
}

/// Admin guard to protect admin-only routes
class AdminGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    try {
      final authService = serviceLocator<IAuthService>();
      final isLoggedIn = await authService.isLoggedIn();
      
      if (!isLoggedIn) {
        // User is not authenticated, redirect to login
        resolver.redirect(const LoginViewRoute());
        return;
      }
      
      // Check if user has admin role
      final user = await authService.getCurrentUser();
      if (user.isSuccess && user.data != null) {
        final userRole = user.data!.role;
        if (userRole == 'ADMIN' || userRole == 'OPERATOR') {
          // User has admin/operator role, allow navigation
          resolver.next();
        } else {
          // User doesn't have admin privileges, redirect to home
          resolver.redirect(const HomeViewRoute());
        }
      } else {
        // Error getting user data, redirect to login
        resolver.redirect(const LoginViewRoute());
      }
    } catch (e) {
      // Error checking authorization, redirect to login for safety
      resolver.redirect(const LoginViewRoute());
    }
  }
}

/// Guest guard to prevent authenticated users from accessing auth pages
class GuestGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    try {
      final authService = serviceLocator<IAuthService>();
      final isLoggedIn = await authService.isLoggedIn();
      
      if (!isLoggedIn) {
        // User is not authenticated, allow access to auth pages
        resolver.next();
      } else {
        // User is already authenticated, redirect to home
        resolver.redirect(const HomeViewRoute());
      }
    } catch (e) {
      // Error checking authentication, allow navigation for safety
      resolver.next();
    }
  }
}

/// Navigation helper class for common navigation operations
class NavigationHelper {
  const NavigationHelper._();
  
  /// Navigate to home and clear navigation stack
  static void goToHome(StackRouter router) {
    router.replaceAll([const HomeViewRoute()]);
  }
  
  /// Navigate to login and clear navigation stack
  static void goToLogin(StackRouter router) {
    router.replaceAll([const LoginViewRoute()]);
  }
  
  /// Navigate to splash screen (in-app splash removed; redirect to home instead)
  static void goToSplash(StackRouter router) {
    // Uygulama içi Splash ekranı kaldırıldı; güvenli varsayılan olarak ana ekrana yönlendiriyoruz
    router.replaceAll([const HomeViewRoute()]);
  }
  
  /// Show report detail
  static void showReportDetail(StackRouter router, String reportId) {
    router.push(ReportDetailViewRoute(reportId: reportId));
  }
  
  /// Navigate to create report
  static void goToCreateReport(StackRouter router) {
    router.push(const CreateReportViewRoute());
  }
  
  /// Navigate to profile
  static void goToProfile(StackRouter router) {
    router.push(const ProfileViewRoute());
  }
  
  /// Navigate to settings
  static void goToSettings(StackRouter router) {
    router.push(const SettingsViewRoute());
  }
  
  /// Navigate to admin dashboard (with permission check)
  static void goToAdminDashboard(StackRouter router) {
    router.push(const AdminDashboardViewRoute());
  }
  
  /// Go back to previous screen
  static void goBack(StackRouter router) {
    if (router.canPop()) {
      router.maybePop();
    } else {
      goToHome(router);
    }
  }
  
  /// Pop until specific route
  static void popUntilHome(StackRouter router) {
    router.popUntil((route) => route.settings.name == HomeViewRoute.name);
  }
}