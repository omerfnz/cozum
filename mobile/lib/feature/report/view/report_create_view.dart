import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:logger/logger.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/report/model/report_models.dart';
import 'package:mobile/product/report/report_repository.dart';
import 'package:oktoast/oktoast.dart';

class ReportCreateView extends StatefulWidget {
  const ReportCreateView({super.key});

  @override
  State<ReportCreateView> createState() => _ReportCreateViewState();
}

class _ReportCreateViewState extends State<ReportCreateView> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  List<CategoryDto> _categories = const [];
  int? _selectedCategoryId;
  bool _catLoading = true;

  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _catLoading = true;
    });
    try {
      final repo = di<ReportRepository>();
      final list = await repo.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = list;
        if (_categories.isNotEmpty) {
          _selectedCategoryId ??= _categories.first.id;
        }
      });
      di<Logger>().i('[Create] Kategori sayısı: ${list.length}');
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Kategoriler alınamadı: $e');
      showToast('Kategoriler alınamadı');
      di<Logger>().e('[Create] Kategori hatası: $e');
    } finally {
      if (mounted) setState(() => _catLoading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (x != null) {
      setState(() => _imagePath = x.path);
      showToast('Kamera: görsel yakalandı');
    }
  }

  Future<void> _openMapPicker() async {
    final initialLat = double.tryParse(_latCtrl.text.trim());
    final initialLon = double.tryParse(_lngCtrl.text.trim());
    final picked = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(
        builder: (_) => _MapPickerPage(initialLat: initialLat, initialLon: initialLon),
      ),
    );
    if (picked != null) {
      _latCtrl.text = picked.lat.toStringAsFixed(6);
      _lngCtrl.text = picked.lon.toStringAsFixed(6);
      if (picked.address != null && picked.address!.isNotEmpty) {
        _locationCtrl.text = picked.address!;
      }
      setState(() {});
    }
  }

  Future<void> _onSubmit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;
    if (_selectedCategoryId == null) {
      setState(() => _error = 'Lütfen bir kategori seçin.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = di<ReportRepository>();
      final lat = double.tryParse(_latCtrl.text.trim());
      final lng = double.tryParse(_lngCtrl.text.trim());
      di<Logger>().i('[Create] Gönderim başlıyor: title="${_titleCtrl.text.trim()}" cat=$_selectedCategoryId img=${_imagePath != null}');
      final id = await repo.createReport(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        categoryId: _selectedCategoryId!,
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        latitude: lat,
        longitude: lng,
        imagePaths: _imagePath == null ? const [] : <String>[_imagePath!],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bildirim oluşturuldu (ID: $id)')),
      );
      showToast('Bildirim oluşturuldu');
      di<Logger>().i('[Create] Başarılı: id=$id');
      Navigator.of(context).pop(true);
    } on Exception catch (e) {
      setState(() => _error = e.toString());
      showToast('Gönderim başarısız');
      di<Logger>().e('[Create] Hata: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      appBar: AppBar(title: const Text('Yeni Bildirim')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!)),
                    ],
                  ),
                ),
              ],
              TextFormField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  hintText: 'Kısa bir başlık',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Başlık zorunlu';
                  if (v.trim().length < 3) return 'En az 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'İsteğe bağlı açıklama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (_catLoading)
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
              else
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  labelText: 'Konum (isteğe bağlı)',
                  hintText: 'Örn. Beşiktaş, İstanbul',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: 'Haritadan seç',
                    onPressed: _loading ? null : _openMapPicker,
                    icon: const Icon(Icons.map_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Enlem (isteğe bağlı)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(
                        labelText: 'Boylam (isteğe bağlı)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Görsel (opsiyonel)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: () => setState(() => _imagePath = null),
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Görsel seçilmedi',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _pickFromCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Kamera ile çek'),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loading ? null : _onSubmit,
                icon: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_loading ? 'Gönderiliyor...' : 'Bildirimi oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PickedLocation {
  const PickedLocation({required this.lat, required this.lon, this.address});
  final double lat;
  final double lon;
  final String? address;
}

class _MapPickerPage extends StatefulWidget {
  const _MapPickerPage({this.initialLat, this.initialLon});
  final double? initialLat;
  final double? initialLon;

  @override
  State<_MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<_MapPickerPage> {
  latlng.LatLng? _selected;
  String? _resolvedAddress;
  bool _resolving = false;

  late final MapController _mapController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLat != null && widget.initialLon != null) {
      _selected = latlng.LatLng(widget.initialLat!, widget.initialLon!);
      final s = _selected;
      if (s != null) {
        _reverseGeocode(s);
      }
    }
    // Başlangıç merkezini belirle (varsayılan İstanbul) ve adresi çöz
    _selected ??= latlng.LatLng(widget.initialLat ?? 41.015137, widget.initialLon ?? 28.979530);
    if (widget.initialLat == null || widget.initialLon == null) {
      final s = _selected;
      if (s != null) {
        _reverseGeocode(s);
      }
    }
    _initLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      final here = latlng.LatLng(pos.latitude, pos.longitude);
      // Sadece harita merkezini güncelle; kullanıcı dokunmadan seçim yapma
      _mapController.move(here, 15);
    } catch (e) {
      di<Logger>().w('[MapPicker] location init failed: $e');
    }
  }

  Future<void> _reverseGeocode(latlng.LatLng point) async {
    setState(() {
      _resolving = true;
      _resolvedAddress = null;
    });
    try {
      final dio = di<Dio>();
      final resp = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': point.latitude.toString(),
          'lon': point.longitude.toString(),
          'format': 'json',
          'addressdetails': '1',
        },
        options: Options(headers: {
          'User-Agent': 'cozum-mobile/1.0',
          'Accept-Language': 'tr',
        }),
      );
      final data = resp.data as Map<String, dynamic>;
      final display = (data['display_name'] as String?) ?? '';
      setState(() => _resolvedAddress = display);
    } catch (e) {
      di<Logger>().w('[MapPicker] reverse geocode failed: $e');
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final latlng.LatLng center = _selected ?? latlng.LatLng(widget.initialLat ?? 41.015137, widget.initialLon ?? 28.979530);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Seç'),
        actions: [
          IconButton(
            onPressed: _selected == null
                ? null
                : () {
                    final s = _selected;
                    if (s == null) return;
                    Navigator.of(context).pop(
                      PickedLocation(
                        lat: s.latitude,
                        lon: s.longitude,
                        address: _resolvedAddress,
                      ),
                    );
                  },
            icon: const Icon(Icons.check),
            tooltip: 'Seçimi onayla',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              onPositionChanged: (camera, hasGesture) {
                final c = camera.center;
                if (c == null) return;
                setState(() => _selected = latlng.LatLng(c.latitude, c.longitude));
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 700), () {
                  if (!mounted) return;
                  final s = _selected;
                  if (s == null) return;
                  _reverseGeocode(s);
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mobile',
              ),
            ],
          ),
          // Ekranın ortasında sabit marker (crosshair)
          const IgnorePointer(
            ignoring: true,
            child: Center(
              child: Icon(Icons.location_on, color: Colors.red, size: 36),
            ),
          ),
          if (_selected != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seçilen Konum', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text('Lat: ${center.latitude.toStringAsFixed(6)}  Lon: ${center.longitude.toStringAsFixed(6)}'),
                      const SizedBox(height: 6),
                      if (_resolving) const LinearProgressIndicator(minHeight: 2),
                      if (_resolvedAddress != null) Text(_resolvedAddress!),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}