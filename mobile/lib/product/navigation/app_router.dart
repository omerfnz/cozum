import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// Import all view files (Splash kaldırıldı)
import '../../feature/auth/view/login_view.dart';
import '../../feature/auth/view/register_view.dart';
import '../../feature/home/view/home_view.dart';
import '../../feature/report/view/report_detail_view.dart';
import '../../feature/report/view/create_report_view.dart';
import '../../feature/profile/view/profile_view.dart';
import '../../feature/profile/view/settings_view.dart';
import '../../feature/profile/view/admin_dashboard_view.dart';
import '../../feature/tasks/view/tasks_view.dart';
import '../../feature/teams/view/teams_view.dart';
import 'navigation_guard.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View,Page,Screen,Dialog,Widget=Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // Home initial (guarded)
    AutoRoute(
      page: HomeViewRoute.page,
      path: '/home',
      initial: true,
      guards: [AuthGuard()],
    ),

    // Auth (guest only)
    AutoRoute(
      page: LoginViewRoute.page,
      path: '/login',
      guards: [GuestGuard()],
    ),
    AutoRoute(
      page: RegisterViewRoute.page,
      path: '/register',
      guards: [GuestGuard()],
    ),

    // Tasks & Teams
    AutoRoute(
      page: TasksViewRoute.page,
      path: '/tasks',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: TeamsViewRoute.page,
      path: '/teams',
      guards: [AuthGuard()],
    ),

    // Reports
    AutoRoute(
      page: ReportDetailViewRoute.page,
      path: '/report/:reportId',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: CreateReportViewRoute.page,
      path: '/create-report',
      guards: [AuthGuard()],
    ),

    // User
    AutoRoute(
      page: ProfileViewRoute.page,
      path: '/profile',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: SettingsViewRoute.page,
      path: '/settings',
      guards: [AuthGuard()],
    ),

    // Admin
    AutoRoute(
      page: AdminDashboardViewRoute.page,
      path: '/admin',
      guards: [AdminGuard()],
    ),

    // Fallback
    RedirectRoute(
      path: '/',
      redirectTo: '/home',
    ),
  ];
}