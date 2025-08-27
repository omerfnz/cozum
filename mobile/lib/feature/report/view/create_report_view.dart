import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shimmer/shimmer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_location_picker_view.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/service/network/network_service.dart';
import '../../../product/navigation/app_router.dart';

@RoutePage()
class CreateReportView extends StatefulWidget {
  const CreateReportView({super.key});

  @override
  State<CreateReportView> createState() => _CreateReportViewState();
}


class _CreateReportViewState extends State<CreateReportView> {
  final _net = GetIt.I<INetworkService>();
  final _formKey = GlobalKey<FormState>();

  bool _loadingCats = true;
  String? _loadError;
  List<Category> _categories = [];
  int? _selectedCategoryId;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  double? _latitude;
  double? _longitude;
  final MapController _previewMapController = MapController();

  XFile? _image;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loadingCats = true;
      _loadError = null;
    });

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

    if (!mounted) return;

    if (res.isSuccess) {
      setState(() {
        _categories = res.data ?? [];
        _selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
        _loadingCats = false;
      });
    } else {
      setState(() {
        _loadError = res.error ?? 'Kategoriler yüklenemedi';
        _loadingCats = false;
      });
    }
  }

  Future<bool> _ensureLocationPermission() async {
    // Önce servis açık mı kontrol edelim
    final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum servisi kapalı. Lütfen etkinleştirin.')),
        );
      }
      return false;
    }

    // permission_handler ile kontrol
    var status = await ph.Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    status = await ph.Permission.locationWhenInUse.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Konum izni kalıcı olarak reddedildi. Ayarlardan izin veriniz.'),
            action: SnackBarAction(
              label: 'Aç',
              onPressed: () => ph.openAppSettings(),
            ),
          ),
        );
      }
      return false;
    }

    return false;
  }

  Future<bool> _ensureCameraPermission() async {
    var status = await ph.Permission.camera.status;
    if (status.isGranted) return true;

    status = await ph.Permission.camera.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kamera izni kalıcı olarak reddedildi. Ayarlardan izin veriniz.'),
          action: SnackBarAction(
            label: 'Aç',
            onPressed: () => ph.openAppSettings(),
          ),
        ),
      );
    }
    return false;
  }

  Future<bool> _ensurePhotosPermissionIfNeeded() async {
    // iOS için fotoğraf izni
    if (Platform.isIOS) {
      var status = await ph.Permission.photos.status;
      if (status.isGranted) return true;
      status = await ph.Permission.photos.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Fotoğraflara erişim izni kalıcı olarak reddedildi. Ayarlardan izin veriniz.'),
            action: SnackBarAction(
              label: 'Aç',
              onPressed: () => ph.openAppSettings(),
            ),
          ),
        );
      }
      return false;
    }
    // Android 13+ için READ_MEDIA_IMAGES otomatik yönetilir, genelde gerekmez.
    return true;
  }

  Future<void> _useCurrentLocation() async {
    final ok = await _ensureLocationPermission();
    if (!ok) return;

    try {
      final position = await geo.Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      // Koordinatlar alındıktan sonra adresi otomatik doldur
      await _fillAddressFromCoordinates();
      // Küçük haritayı mevcut konuma kaydır
      if (_latitude != null && _longitude != null) {
        try {
          _previewMapController.move(LatLng(_latitude!, _longitude!), 13);
        } catch (_) {}
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konum alındı: ${_latitude?.toStringAsFixed(5)}, ${_longitude?.toStringAsFixed(5)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konum alınamadı: $e')),
        );
      }
    }
  }

  Future<void> _selectFromMap() async {
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: MapLocationPickerView(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result['latitude'] as double?;
        _longitude = result['longitude'] as double?;
      });
      final address = result['address'] as String?;
      if (address != null) {
        setState(() => _locationCtrl.text = address);
      } else {
        await _fillAddressFromCoordinates();
      }
      // Küçük haritayı seçilen konuma taşı
      if (_latitude != null && _longitude != null) {
        try {
          _previewMapController.move(LatLng(_latitude!, _longitude!), 13);
        } catch (_) {}
      }
    }
  }

  Future<void> _fillAddressFromCoordinates() async {
    if (_latitude == null || _longitude == null) return;
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
        final displayName = data['display_name'] as String?;
        if (displayName != null && mounted) {
          setState(() {
            _locationCtrl.text = displayName;
          });
        }
      }
    } catch (_) {
      // Sessizce geç, adres doldurma isteğe bağlı
    }
  }

  Future<void> _pickFromCamera() async {
    final ok = await _ensureCameraPermission();
    if (!ok) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (file != null) {
      setState(() => _image = file);
    }
  }

  Future<void> _pickFromGallery() async {
    final ok = await _ensurePhotosPermissionIfNeeded();
    if (!ok) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() => _image = file);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kategori seçiniz.')),
      );
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir fotoğraf ekleyiniz.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final form = FormData.fromMap({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _selectedCategoryId,
        if (_locationCtrl.text.trim().isNotEmpty) 'location': _locationCtrl.text.trim(),
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
        onSendProgress: (sent, total) {
          // Opsiyonel: ilerleme gösterebilirsiniz
        },
      );

      if (!mounted) return;

      if (res.isSuccess && res.data != null) {
        final created = res.data!;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bildirim oluşturuldu.')),
        );
        // Detay sayfasına geç
        final id = created.id;
        if (id != null) {
          context.router.replace(ReportDetailViewRoute(reportId: id.toString()));
        } else {
          context.router.maybePop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.error ?? 'Bildirim oluşturulamadı')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Oluştur'),
      ),
      body: _loadingCats
          ? const _CreateReportShimmer()
          : _loadError != null
              ? _ErrorView(message: _loadError!, onRetry: _fetchCategories)
              : SafeArea(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        TextFormField(
                          controller: _titleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Başlık',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Başlık gereklidir'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Açıklama',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Açıklama gereklidir'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedCategoryId,
                              items: _categories
                                  .map((c) => DropdownMenuItem<int>(
                                        value: c.id,
                                        child: Text(c.name),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedCategoryId = v),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Fotoğraf', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (_image != null)
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.file(
                              File(_image!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('Henüz fotoğraf seçilmedi'),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickFromCamera,
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: const Text('Kamera'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickFromGallery,
                                icon: const Icon(Icons.photo_library_outlined),
                                label: const Text('Galeri'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Konum (opsiyonel)', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _latitude != null && _longitude != null
                                    ? 'Lat: ${_latitude!.toStringAsFixed(5)}, Lng: ${_longitude!.toStringAsFixed(5)}'
                                    : 'Konum seçilmedi',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              message: 'Mevcut konumunuzu alır. Aşağıdaki haritaya dokunarak noktayı değiştirebilirsiniz.',
                              child: OutlinedButton.icon(
                                onPressed: _useCurrentLocation,
                                icon: const Icon(Icons.my_location),
                                label: const Text('Mevcut Konumu Al'),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Haritadan konum seçmek için aşağıdaki haritaya dokunun',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: Colors.transparent,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: _selectFromMap,
                              child: SizedBox(
                              height: 200,
                              child: AbsorbPointer(
                                absorbing: true,
                                child: FlutterMap(
                                  mapController: _previewMapController,
                                  options: MapOptions(
                                    initialCenter: _latitude != null && _longitude != null
                                        ? LatLng(_latitude!, _longitude!)
                                        : LatLng(41.015137, 28.979530),
                                    initialZoom: 13,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      subdomains: ['a', 'b', 'c'],
                                      userAgentPackageName: 'cozum.mobile',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _locationCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Adres/konum açıklaması (opsiyonel)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _submitting ? null : _submit,
                          icon: _submitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_rounded),
                          label: const Text('Gönder'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateReportShimmer extends StatelessWidget {
  const _CreateReportShimmer();

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade300;
    final highlight = Colors.grey.shade100;

    Widget box({double height = 16, double width = double.infinity, BorderRadius? radius}) {
      return Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: base,
            borderRadius: radius ?? BorderRadius.circular(8),
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Başlık alanı
          box(height: 56),
          const SizedBox(height: 12),
          // Açıklama alanı (çok satırlı)
          box(height: 100),
          const SizedBox(height: 12),
          // Kategori dropdown
          box(height: 56),
          const SizedBox(height: 16),
          // Fotoğraf başlığı
          box(height: 20, width: 120, radius: BorderRadius.circular(4)),
          const SizedBox(height: 8),
          // Görsel placeholder
          box(height: 180),
          const SizedBox(height: 8),
          // Kamera / Galeri butonları
          Row(
            children: [
              Expanded(child: box(height: 44)),
              const SizedBox(width: 8),
              Expanded(child: box(height: 44)),
            ],
          ),
          const SizedBox(height: 16),
          // Konum başlığı
          box(height: 20, width: 160, radius: BorderRadius.circular(4)),
          const SizedBox(height: 8),
          // Koordinat satırı + Konumu Kullan butonu
          Row(
            children: [
              Expanded(child: box(height: 20)),
              const SizedBox(width: 8),
              box(height: 36, width: 140),
            ],
          ),
          const SizedBox(height: 8),
          // Harita placeholder
          box(height: 200),
          const SizedBox(height: 8),
          // Adres/konum açıklaması
          box(height: 56),
          const SizedBox(height: 24),
          // Gönder butonu
          box(height: 48),
        ],
      ),
    );
  }
}