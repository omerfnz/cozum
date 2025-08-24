import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// Import all view files
import '../../feature/splash/view/splash_view.dart';
import '../../feature/auth/view/login_view.dart';
import '../../feature/auth/view/register_view.dart';
import '../../feature/home/view/home_view.dart';
import '../../feature/report/view/report_detail_view.dart';
import '../../feature/report/view/create_report_view.dart';
import '../../feature/profile/view/profile_view.dart';
import '../../feature/profile/view/settings_view.dart';
import '../../feature/profile/view/admin_dashboard_view.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View,Page,Screen,Dialog,Widget=Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Splash Route - Initial route
    AutoRoute(
      page: SplashViewRoute.page,
      path: '/splash',
      initial: true,
    ),
    
    // Authentication Routes
    AutoRoute(
      page: LoginViewRoute.page,
      path: '/login',
    ),
    AutoRoute(
      page: RegisterViewRoute.page,
      path: '/register',
    ),
    
    // Main App Routes
    AutoRoute(
      page: HomeViewRoute.page,
      path: '/home',
    ),
    
    // Report Routes
    AutoRoute(
      page: ReportDetailViewRoute.page,
      path: '/report/:reportId',
    ),
    AutoRoute(
      page: CreateReportViewRoute.page,
      path: '/create-report',
    ),
    
    // User Routes
    AutoRoute(
      page: ProfileViewRoute.page,
      path: '/profile',
    ),
    AutoRoute(
      page: SettingsViewRoute.page,
      path: '/settings',
    ),
    
    // Admin Routes
    AutoRoute(
      page: AdminDashboardViewRoute.page,
      path: '/admin',
    ),
    
    // Fallback route
    RedirectRoute(
      path: '/',
      redirectTo: '/splash',
    ),
  ];
}