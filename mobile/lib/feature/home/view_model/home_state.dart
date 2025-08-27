import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final String userRole;
  final int currentTabIndex;

  const HomeLoaded({
    required this.userRole,
    required this.currentTabIndex,
  });

  @override
  List<Object?> get props => [userRole, currentTabIndex];

  HomeLoaded copyWith({
    String? userRole,
    int? currentTabIndex,
  }) {
    return HomeLoaded(
      userRole: userRole ?? this.userRole,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeLogoutLoading extends HomeState {
  const HomeLogoutLoading();
}

class HomeLogoutSuccess extends HomeState {
  const HomeLogoutSuccess();
}

class HomeLogoutFailure extends HomeState {
  final String message;

  const HomeLogoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}