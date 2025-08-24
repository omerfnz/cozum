import 'package:equatable/equatable.dart';
import 'package:mobile/product/report/model/report_models.dart';

class UsersState extends Equatable {
  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  final List<UserDto> users;
  final bool isLoading;
  final String? error;

  bool get isEmpty => users.isEmpty;
  bool get hasError => error != null;

  UsersState copyWith({
    List<UserDto>? users,
    bool? isLoading,
    String? error,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [users, isLoading, error];
}