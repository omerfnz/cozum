import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/service/auth/auth_service.dart';
import '../../../product/service/network/network_service.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(const CategoriesInitial());

  final INetworkService _networkService = GetIt.I<INetworkService>();
  final IAuthService _authService = GetIt.I<IAuthService>();

  Future<void> loadCategories() async {
    emit(const CategoriesLoading());

    try {
      // Load user role
      String userRole = 'VATANDAS';
      try {
        final userResult = await _authService.getCurrentUser();
        userRole = userResult.data?.role ?? 'VATANDAS';
      } catch (_) {
        // Ignore role loading error, use default
      }

      // Load categories
      final result = await _networkService.request<List<Category>>(
        path: ApiEndpoints.categories,
        type: RequestType.get,
        useCache: true,
        cacheExpiry: const Duration(hours: 1),
        parser: (json) {
          if (json is List) {
            return json
                .map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          if (json is Map && json['results'] is List) {
            return (json['results'] as List)
                .map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          return <Category>[];
        },
      );

      if (result.isSuccess) {
        emit(CategoriesLoaded(
          categories: result.data ?? [],
          userRole: userRole,
        ));
      } else {
        emit(CategoriesError(result.error ?? 'Kategoriler yüklenemedi'));
      }
    } catch (e) {
      emit(CategoriesError('Bir hata oluştu: $e'));
    }
  }

  Future<void> createCategory({
    required String name,
    String? description,
    bool isActive = true,
  }) async {
    emit(const CategoryOperationLoading());

    try {
      final body = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
        'is_active': isActive,
      };

      final result = await _networkService.request<Category>(
        path: ApiEndpoints.categories,
        type: RequestType.post,
        data: body,
        parser: (json) => Category.fromJson(json as Map<String, dynamic>),
      );

      if (result.isSuccess) {
        emit(const CategoryOperationSuccess('Kategori oluşturuldu'));
        // Reload categories to get updated list
        await loadCategories();
      } else {
        emit(CategoryOperationFailure(result.error ?? 'Kategori oluşturulamadı'));
      }
    } catch (e) {
      emit(CategoryOperationFailure('Bir hata oluştu: $e'));
    }
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    String? description,
    bool isActive = true,
  }) async {
    emit(const CategoryOperationLoading());

    try {
      final body = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
        'is_active': isActive,
      };

      final result = await _networkService.request<Category>(
        path: ApiEndpoints.categoryById(categoryId),
        type: RequestType.patch,
        data: body,
        parser: (json) => Category.fromJson(json as Map<String, dynamic>),
      );

      if (result.isSuccess) {
        emit(const CategoryOperationSuccess('Kategori güncellendi'));
        // Reload categories to get updated list
        await loadCategories();
      } else {
        emit(CategoryOperationFailure(result.error ?? 'Kategori güncellenemedi'));
      }
    } catch (e) {
      emit(CategoryOperationFailure('Bir hata oluştu: $e'));
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    emit(const CategoryOperationLoading());

    try {
      final result = await _networkService.request<dynamic>(
        path: ApiEndpoints.categoryById(categoryId),
        type: RequestType.delete,
      );

      if (result.isSuccess) {
        emit(const CategoryOperationSuccess('Kategori silindi'));
        // Reload categories to get updated list
        await loadCategories();
      } else {
        emit(CategoryOperationFailure(result.error ?? 'Kategori silinemedi'));
      }
    } catch (e) {
      emit(CategoryOperationFailure('Bir hata oluştu: $e'));
    }
  }

  String? validateCategoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ad zorunludur';
    }
    return null;
  }
}