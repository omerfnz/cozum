// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AdminDashboardView]
class AdminDashboardViewRoute extends PageRouteInfo<void> {
  const AdminDashboardViewRoute({List<PageRouteInfo>? children})
      : super(
          AdminDashboardViewRoute.name,
          initialChildren: children,
        );

  static const String name = 'AdminDashboardViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AdminDashboardView();
    },
  );
}

/// generated route for
/// [CreateReportView]
class CreateReportViewRoute extends PageRouteInfo<void> {
  const CreateReportViewRoute({List<PageRouteInfo>? children})
      : super(
          CreateReportViewRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateReportViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateReportView();
    },
  );
}

/// generated route for
/// [HomeView]
class HomeViewRoute extends PageRouteInfo<void> {
  const HomeViewRoute({List<PageRouteInfo>? children})
      : super(
          HomeViewRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeView();
    },
  );
}

/// generated route for
/// [LoginView]
class LoginViewRoute extends PageRouteInfo<void> {
  const LoginViewRoute({List<PageRouteInfo>? children})
      : super(
          LoginViewRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginView();
    },
  );
}

/// generated route for
/// [ProfileView]
class ProfileViewRoute extends PageRouteInfo<void> {
  const ProfileViewRoute({List<PageRouteInfo>? children})
      : super(
          ProfileViewRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileView();
    },
  );
}

/// generated route for
/// [RegisterView]
class RegisterViewRoute extends PageRouteInfo<void> {
  const RegisterViewRoute({List<PageRouteInfo>? children})
      : super(
          RegisterViewRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegisterViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterView();
    },
  );
}

/// generated route for
/// [ReportDetailView]
class ReportDetailViewRoute extends PageRouteInfo<ReportDetailViewRouteArgs> {
  ReportDetailViewRoute({
    Key? key,
    required String reportId,
    List<PageRouteInfo>? children,
  }) : super(
          ReportDetailViewRoute.name,
          args: ReportDetailViewRouteArgs(
            key: key,
            reportId: reportId,
          ),
          rawPathParams: {'reportId': reportId},
          initialChildren: children,
        );

  static const String name = 'ReportDetailViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ReportDetailViewRouteArgs>(
          orElse: () => ReportDetailViewRouteArgs(
              reportId: pathParams.getString('reportId')));
      return ReportDetailView(
        key: args.key,
        reportId: args.reportId,
      );
    },
  );
}

class ReportDetailViewRouteArgs {
  const ReportDetailViewRouteArgs({
    this.key,
    required this.reportId,
  });

  final Key? key;

  final String reportId;

  @override
  String toString() {
    return 'ReportDetailViewRouteArgs{key: $key, reportId: $reportId}';
  }
}

/// generated route for
/// [SettingsView]
class SettingsViewRoute extends PageRouteInfo<void> {
  const SettingsViewRoute({List<PageRouteInfo>? children})
      : super(
          SettingsViewRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsView();
    },
  );
}

/// generated route for
/// [TasksView]
class TasksViewRoute extends PageRouteInfo<void> {
  const TasksViewRoute({List<PageRouteInfo>? children})
      : super(
          TasksViewRoute.name,
          initialChildren: children,
        );

  static const String name = 'TasksViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TasksView();
    },
  );
}

/// generated route for
/// [TeamsView]
class TeamsViewRoute extends PageRouteInfo<void> {
  const TeamsViewRoute({List<PageRouteInfo>? children})
      : super(
          TeamsViewRoute.name,
          initialChildren: children,
        );

  static const String name = 'TeamsViewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TeamsView();
    },
  );
}
