import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mobile/feature/report/cubit/report_create_state.dart';

import 'package:mobile/product/report/report_repository.dart';

class ReportCreateCubit extends Cubit<ReportCreateState> {
  ReportCreateCubit(this._reportRepository) : super(const ReportCreateState());

  final ReportRepository _reportRepository;
  final ImagePicker _picker = ImagePicker();

  Future<void> loadCategories() async {
    emit(state.copyWith(categoriesLoading: true, error: null));
    try {
      final categories = await _reportRepository.fetchCategories();
      emit(state.copyWith(
        categories: categories,
        categoriesLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        categoriesLoading: false,
        error: 'Kategoriler yüklenirken hata oluştu: ${e.toString()}',
      ));
    }
  }

  void selectCategory(int categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final updatedPaths = List<String>.from(state.imagePaths)..add(image.path);
        emit(state.copyWith(imagePaths: updatedPaths));
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Kamera açılırken hata oluştu: ${e.toString()}',
      ));
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final updatedPaths = List<String>.from(state.imagePaths)..add(image.path);
        emit(state.copyWith(imagePaths: updatedPaths));
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Galeri açılırken hata oluştu: ${e.toString()}',
      ));
    }
  }

  void removeImage(int index) {
    final updatedPaths = List<String>.from(state.imagePaths)..removeAt(index);
    emit(state.copyWith(imagePaths: updatedPaths));
  }

  Future<void> createReport({
    required String title,
    String? description,
    String? location,
    required double latitude,
    required double longitude,
  }) async {
    if (state.selectedCategoryId == null) {
      emit(state.copyWith(error: 'Lütfen bir kategori seçin'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await _reportRepository.createReport(
        title: title,
        description: description,
        categoryId: state.selectedCategoryId!,
        location: location,
        latitude: latitude,
        longitude: longitude,
        imagePaths: state.imagePaths,
      );
      emit(state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: 'Rapor oluşturulurken hata oluştu: ${e.toString()}',
      ));
    }
  }

  void setError(String error) {
    emit(state.copyWith(error: error));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void resetForm() {
    emit(const ReportCreateState());
  }
}