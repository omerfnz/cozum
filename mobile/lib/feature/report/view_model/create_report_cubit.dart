import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/service/network/network_service.dart';
import 'create_report_state.dart';

class CreateReportCubit extends Cubit<CreateReportState> {
  CreateReportCubit() : super(const CreateReportInitial());

  final _net = GetIt.I<INetworkService>();

  List<Category> _categories = [];
  int? _selectedCategoryId;
  double? _latitude;
  double? _longitude;
  XFile? _image;

  Future<void> loadCategories() async {
    await fetchCategories();
  }

  Future<void> fetchCategories() async {
    emit(const CreateReportLoading());

    final res = await _net.request<List<Category>>(
      path: ApiEndpoints.categories,
      type: RequestType.get,
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

    if (res.isSuccess) {
      _categories = res.data ?? [];
      _selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
      emit(CreateReportCategoriesLoaded(_categories, _selectedCategoryId));
    } else {
      emit(CreateReportError(res.error ?? 'Kategoriler yüklenemedi'));
    }
  }

  void selectCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    emit(CreateReportCategoriesLoaded(_categories, _selectedCategoryId));
  }

  Future<bool> ensureLocationPermission() async {
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(const CreateReportError('Konum servisi kapalı. Lütfen etkinleştirin.'));
      return false;
    }

    var status = await ph.Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    status = await ph.Permission.locationWhenInUse.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      emit(const CreateReportError('Konum izni kalıcı olarak reddedildi. Ayarlardan izin veriniz.'));
      return false;
    }

    return false;
  }

  Future<bool> ensureCameraPermission() async {
    var status = await ph.Permission.camera.status;
    if (status.isGranted) return true;

    status = await ph.Permission.camera.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      emit(const CreateReportError('Kamera izni kalıcı olarak reddedildi. Ayarlardan izin veriniz.'));
    }
    return false;
  }

  Future<bool> ensurePhotosPermissionIfNeeded() async {
    if (Platform.isIOS) {
      var status = await ph.Permission.photos.status;
      if (status.isGranted) return true;
      status = await ph.Permission.photos.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied) {
        emit(const CreateReportError('Fotoğraflara erişim izni kalıcı olarak reddedildi. Ayarlardan izin veriniz.'));
      }
      return false;
    }
    return true;
  }

  Future<void> useCurrentLocation() async {
    final ok = await ensureLocationPermission();
    if (!ok) return;

    try {
      // Timeout ve daha düşük hassasiyet ile konum al
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Konum alma işlemi zaman aşımına uğradı');
        },
      );
      
      _latitude = position.latitude;
      _longitude = position.longitude;
      
      await _fillAddressFromCoordinates();
      emit(CreateReportLocationUpdated(_latitude!, _longitude!, await _getAddressFromCoordinates()));
    } catch (e) {
      String errorMessage = 'Konum alınamadı';
      if (e.toString().contains('timeout') || e.toString().contains('zaman aşımı')) {
        errorMessage = 'Konum alma işlemi zaman aşımına uğradı. Tekrar deneyin.';
      } else if (e.toString().contains('LocationServiceDisabledException')) {
        errorMessage = 'Konum servisi kapalı. Lütfen etkinleştirin.';
      } else if (e.toString().contains('PermissionDeniedException')) {
        errorMessage = 'Konum izni reddedildi.';
      }
      emit(CreateReportError(errorMessage));
    }
  }

  void setLocationFromMap(double latitude, double longitude, String? address) {
    _latitude = latitude;
    _longitude = longitude;
    emit(CreateReportLocationUpdated(latitude, longitude, address));
  }

  void updateLocation(double latitude, double longitude, String? address) {
    setLocationFromMap(latitude, longitude, address);
  }

  Future<String?> _getAddressFromCoordinates() async {
    if (_latitude == null || _longitude == null) return null;
    try {
      final dio = Dio(
        BaseOptions(
          headers: {
            'User-Agent': 'cozum-mobile/1.0 (+https://example.com)'
          },
        ),
      );
      final res = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': _latitude,
          'lon': _longitude,
        },
      );
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map;
        return data['display_name'] as String?;
      }
    } catch (_) {
      // Sessizce geç
    }
    return null;
  }

  Future<void> _fillAddressFromCoordinates() async {
    final address = await _getAddressFromCoordinates();
    if (address != null) {
      emit(CreateReportLocationUpdated(_latitude!, _longitude!, address));
    }
  }

  Future<void> pickImageFromCamera() async {
    await pickFromCamera();
  }

  Future<void> pickFromCamera() async {
    final ok = await ensureCameraPermission();
    if (!ok) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file != null) {
      _image = file;
      emit(CreateReportImageSelected(file));
    }
  }

  Future<void> pickImageFromGallery() async {
    await pickFromGallery();
  }

  Future<void> pickFromGallery() async {
    final ok = await ensurePhotosPermissionIfNeeded();
    if (!ok) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      _image = file;
      emit(CreateReportImageSelected(file));
    }
  }

  Future<void> submitReport({
    required String title,
    required String description,
    String? location,
  }) async {
    if (_selectedCategoryId == null) {
      emit(const CreateReportError('Lütfen bir kategori seçiniz.'));
      return;
    }
    if (_image == null) {
      emit(const CreateReportError('Lütfen en az bir fotoğraf ekleyiniz.'));
      return;
    }

    emit(const CreateReportSubmitting());

    try {
      final form = FormData.fromMap({
        'title': title.trim(),
        'description': description.trim(),
        'category': _selectedCategoryId,
        if (location != null && location.trim().isNotEmpty) 'location': location.trim(),
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
      });

      final file = await MultipartFile.fromFile(
        _image!.path,
        filename: _image!.name,
      );
      form.files.add(MapEntry('media_files', file));

      final res = await _net.uploadFile<Report>(
        path: ApiEndpoints.reports,
        formData: form,
        parser: (json) => Report.fromJson(json as Map<String, dynamic>),
      );

      if (res.isSuccess && res.data != null) {
        emit(CreateReportSuccess(res.data!));
      } else {
        emit(CreateReportError(res.error ?? 'Bildirim oluşturulamadı'));
      }
    } catch (e) {
      emit(CreateReportError('Hata: $e'));
    }
  }

  // Getters
  List<Category> get categories => _categories;
  int? get selectedCategoryId => _selectedCategoryId;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  XFile? get image => _image;
  XFile? get selectedImage => _image;
}