import 'package:equatable/equatable.dart';

import '../../../product/models/report.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categories;
  final String userRole;

  const CategoriesLoaded({
    required this.categories,
    required this.userRole,
  });

  bool get canManage => userRole == 'OPERATOR' || userRole == 'ADMIN';

  @override
  List<Object?> get props => [categories, userRole];
}

class CategoriesError extends CategoriesState {
  final String message;

  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryOperationLoading extends CategoriesState {
  const CategoryOperationLoading();
}

class CategoryOperationSuccess extends CategoriesState {
  final String message;

  const CategoryOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryOperationFailure extends CategoriesState {
  final String message;

  const CategoryOperationFailure(this.message);

  @override
  List<Object?> get props => [message];
}