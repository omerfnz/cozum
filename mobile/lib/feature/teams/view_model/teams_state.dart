import 'package:equatable/equatable.dart';

import '../../../product/models/user.dart' show Team;

abstract class TeamsState extends Equatable {
  const TeamsState();

  @override
  List<Object?> get props => [];
}

class TeamsInitial extends TeamsState {
  const TeamsInitial();
}

class TeamsLoading extends TeamsState {
  const TeamsLoading();
}

class TeamsLoaded extends TeamsState {
  final List<Team> teams;
  final String userRole;

  const TeamsLoaded({
    required this.teams,
    required this.userRole,
  });

  @override
  List<Object?> get props => [teams, userRole];

  TeamsLoaded copyWith({
    List<Team>? teams,
    String? userRole,
  }) {
    return TeamsLoaded(
      teams: teams ?? this.teams,
      userRole: userRole ?? this.userRole,
    );
  }
}

class TeamsError extends TeamsState {
  final String message;

  const TeamsError(this.message);

  @override
  List<Object?> get props => [message];
}

class TeamOperationLoading extends TeamsState {
  const TeamOperationLoading();
}

class TeamOperationSuccess extends TeamsState {
  final String message;

  const TeamOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TeamOperationFailure extends TeamsState {
  final String message;

  const TeamOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TeamValidationError extends TeamsState {
  final String? nameError;

  const TeamValidationError({
    this.nameError,
  });

  @override
  List<Object?> get props => [nameError];
}