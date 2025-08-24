import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:logger/logger.dart';
import 'package:mobile/core/widgets/widgets.dart';
import 'package:mobile/feature/report/cubit/report_create_cubit.dart';
import 'package:mobile/feature/report/cubit/report_create_state.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/report/report_repository.dart';
import 'package:oktoast/oktoast.dart';

class ReportCreateView extends StatelessWidget {
  const ReportCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportCreateCubit(di<ReportRepository>())..loadCategories(),
      child: const _ReportCreateViewBody(),
    );
  }
}

class _ReportCreateViewBody extends StatefulWidget {
  const _ReportCreateViewBody();

  @override
  State<_ReportCreateViewBody> createState() => _ReportCreateViewBodyState();
}

class _ReportCreateViewBodyState extends State<_ReportCreateViewBody> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kategorileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportCreateCubit>().loadCategories();
    });
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
    context.read<ReportCreateCubit>().pickImageFromCamera();
  }

  Future<void> _pickFromGallery() async {
    context.read<ReportCreateCubit>().pickImageFromGallery();
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

    double? lat;
    double? lng;
    final latText = _latCtrl.text.trim().replaceAll(',', '.');
    final lngText = _lngCtrl.text.trim().replaceAll(',', '.');
    if (latText.isNotEmpty) {
      final v = double.tryParse(latText);
      if (v == null || v < -90 || v > 90) {
        context.read<ReportCreateCubit>().setError(
          'Lütfen geçerli bir enlem değeri girin (-90 ile 90 arası).',
        );
        return;
      }
      lat = v;
    }
    if (lngText.isNotEmpty) {
      final v = double.tryParse(lngText);
      if (v == null || v < -180 || v > 180) {
        context.read<ReportCreateCubit>().setError(
          'Lütfen geçerli bir boylam değeri girin (-180 ile 180 arası).',
        );
        return;
      }
      lng = v;
    }

    await context.read<ReportCreateCubit>().createReport(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      latitude: lat ?? 0.0,
      longitude: lng ?? 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportCreateCubit, ReportCreateState>(
      listener: (context, state) {
        if (state.submitSuccess) {
          ErrorSnackBar.showSuccess(
            context,
            'Rapor oluşturuldu!',
          );
          showToast('Bildirim oluşturuldu');
          Navigator.of(context).pop(true);
        }
        if (state.error != null) {
          showToast('Hata: ${state.error}');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Yeni Bildirim')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: BlocBuilder<ReportCreateCubit, ReportCreateState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (state.error != null) ...[
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
                            Expanded(child: Text(state.error!)),
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
                     if (state.categoriesLoading)
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
                             value: state.selectedCategoryId,
                             items: state.categories
                                 .map((c) => DropdownMenuItem<int>(
                                       value: c.id,
                                       child: Text(c.name),
                                     ))
                                 .toList(),
                             onChanged: (v) {
                               if (v != null) {
                                 context.read<ReportCreateCubit>().selectCategory(v);
                               }
                             },
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
                           onPressed: state.isSubmitting ? null : _openMapPicker,
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
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]'))],
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
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]'))],
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
                     if (state.imagePaths.isNotEmpty)
                       GridView.builder(
                         shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                           crossAxisCount: 3,
                           crossAxisSpacing: 8,
                           mainAxisSpacing: 8,
                           childAspectRatio: 1,
                         ),
                         itemCount: state.imagePaths.length,
                         itemBuilder: (context, index) {
                           final path = state.imagePaths[index];
                           return Stack(
                             fit: StackFit.expand,
                             children: [
                               ClipRRect(
                                 borderRadius: BorderRadius.circular(12),
                                 child: Image.file(File(path), fit: BoxFit.cover),
                               ),
                               Positioned(
                                 top: 6,
                                 right: 6,
                                 child: Material(
                                   color: Colors.black54,
                                   borderRadius: BorderRadius.circular(20),
                                   child: InkWell(
                                     onTap: () => context.read<ReportCreateCubit>().removeImage(index),
                                     borderRadius: BorderRadius.circular(20),
                                     child: const Padding(
                                       padding: EdgeInsets.all(6.0),
                                       child: Icon(Icons.close, color: Colors.white, size: 18),
                                     ),
                                   ),
                                 ),
                               ),
                             ],
                           );
                         },
                       )
                     else
                       Container(
                         height: 120,
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
                     Row(
                       children: [
                         Expanded(
                           child: OutlinedButton.icon(
                             onPressed: state.isSubmitting ? null : _pickFromCamera,
                             icon: const Icon(Icons.photo_camera_outlined),
                             label: const Text('Kamera ile çek'),
                           ),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: OutlinedButton.icon(
                             onPressed: state.isSubmitting ? null : _pickFromGallery,
                             icon: const Icon(Icons.photo_library_outlined),
                             label: const Text('Galeriden seç'),
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 24),
                     FilledButton.icon(
                       onPressed: state.isSubmitting ? null : _onSubmit,
                       icon: state.isSubmitting
                           ? const SizedBox(
                               height: 18,
                               width: 18,
                               child: ButtonLoadingWidget(),
                             )
                           : const Icon(Icons.send_outlined),
                       label: Text(state.isSubmitting ? 'Gönderiliyor...' : 'Bildirimi oluştur'),
                     ),
                   ],
                 );
               },
             ),
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