import 'package:equatable/equatable.dart';
import 'package:mobile/product/report/model/report_models.dart';

class ReportCreateState extends Equatable {
  const ReportCreateState({
    this.isLoading = false,
    this.error,
    this.categories = const [],
    this.categoriesLoading = false,
    this.selectedCategoryId,
    this.imagePaths = const [],
    this.isSubmitting = false,
    this.submitSuccess = false,
  });

  final bool isLoading;
  final String? error;
  final List<CategoryDto> categories;
  final bool categoriesLoading;
  final int? selectedCategoryId;
  final List<String> imagePaths;
  final bool isSubmitting;
  final bool submitSuccess;

  ReportCreateState copyWith({
    bool? isLoading,
    String? error,
    List<CategoryDto>? categories,
    bool? categoriesLoading,
    int? selectedCategoryId,
    List<String>? imagePaths,
    bool? isSubmitting,
    bool? submitSuccess,
  }) {
    return ReportCreateState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categories: categories ?? this.categories,
      categoriesLoading: categoriesLoading ?? this.categoriesLoading,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      imagePaths: imagePaths ?? this.imagePaths,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        categories,
        categoriesLoading,
        selectedCategoryId,
        imagePaths,
        isSubmitting,
        submitSuccess,
      ];
}