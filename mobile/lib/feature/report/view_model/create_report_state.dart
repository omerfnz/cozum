import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../product/models/report.dart';

abstract class CreateReportState extends Equatable {
  const CreateReportState();
  @override
  List<Object?> get props => [];
}

class CreateReportInitial extends CreateReportState {
  const CreateReportInitial();
}

class CreateReportLoading extends CreateReportState {
  const CreateReportLoading();
}

class CreateReportCategoriesLoaded extends CreateReportState {
  const CreateReportCategoriesLoaded(this.categories, this.selectedCategoryId);
  final List<Category> categories;
  final int? selectedCategoryId;
  
  @override
  List<Object?> get props => [categories, selectedCategoryId];
}

class CreateReportLocationUpdated extends CreateReportState {
  const CreateReportLocationUpdated(this.latitude, this.longitude, this.address);
  final double latitude;
  final double longitude;
  final String? address;
  
  @override
  List<Object?> get props => [latitude, longitude, address];
}

class CreateReportImageSelected extends CreateReportState {
  const CreateReportImageSelected(this.image);
  final XFile image;
  
  @override
  List<Object?> get props => [image];
}

class CreateReportSubmitting extends CreateReportState {
  const CreateReportSubmitting();
}

class CreateReportSuccess extends CreateReportState {
  const CreateReportSuccess(this.report);
  final Report report;
  
  @override
  List<Object?> get props => [report];
}

class CreateReportError extends CreateReportState {
  const CreateReportError(this.message);
  final String message;
  
  @override
  List<Object?> get props => [message];
}