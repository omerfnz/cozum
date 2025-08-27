import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class MapLocationPickerView extends StatefulWidget {
  const MapLocationPickerView({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<MapLocationPickerView> createState() => _MapLocationPickerViewState();
}

class _MapLocationPickerViewState extends State<MapLocationPickerView> {
  final MapController _mapController = MapController();
  late LatLng _selectedLocation;
  String? _address;
  bool _loadingAddress = false;
  bool _loadingCurrentLocation = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Başlangıç koordinatları veya İstanbul varsayılanı
    _selectedLocation = LatLng(
      widget.initialLatitude ?? 41.015137,
      widget.initialLongitude ?? 28.979530,
    );
    _loadAddress();
    // Otomatik olarak mevcut konuma git
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _loadAddressWithDebounce() {
    print('⏰ Debounce başlatıldı');
    // Önceki timer'ı iptal et
    _debounceTimer?.cancel();
    print('⏰ Önceki timer iptal edildi');
    
    // Yeni timer başlat (1.5 saniye gecikme)
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      print('⏰ Timer tetiklendi, _loadAddress çağrılıyor');
      _loadAddress();
    });
    print('⏰ Yeni timer başlatıldı (1.5s)');
  }

  Future<void> _loadAddress() async {
    if (!mounted) return;
    
    print('🗺️ _loadAddress başlatıldı: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}');
    setState(() => _loadingAddress = true);
    
    try {
      final dio = Dio(
        BaseOptions(
          headers: {
            'User-Agent': 'cozum-mobile/1.0 (+https://example.com)'
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      
      print('🌐 API çağrısı yapılıyor...');
      final res = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': _selectedLocation.latitude,
          'lon': _selectedLocation.longitude,
        },
      );
      
      print('📡 API yanıtı alındı: ${res.statusCode}');
      
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map;
        final displayName = data['display_name'] as String?;
        print('📍 Adres bulundu: $displayName');
        
        if (displayName != null && mounted) {
          setState(() {
            _address = displayName;
            _loadingAddress = false;
          });
          print('✅ Adres güncellendi');
        } else {
          print('❌ Display name null');
          if (mounted) {
            setState(() {
              _address = 'Adres bulunamadı';
              _loadingAddress = false;
            });
          }
        }
      } else {
        print('❌ API yanıtı başarısız: ${res.statusCode}');
        if (mounted) {
          setState(() {
            _address = 'Adres alınamadı (${res.statusCode})';
            _loadingAddress = false;
          });
        }
      }
    } catch (e) {
      print('💥 API hatası: $e');
      if (mounted) {
        String errorMessage = 'Adres alınamadı';
        if (e.toString().contains('connection timeout')) {
          errorMessage = 'İnternet bağlantısı yavaş, tekrar deneyin';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = 'İnternet bağlantısı yok';
        }
        setState(() {
          _address = errorMessage;
          _loadingAddress = false;
        });
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    print('👆 Harita tıklandı: $point');
    // Harita merkezini tıklanan noktaya taşı
    _mapController.move(point, _mapController.camera.zoom);
    setState(() => _selectedLocation = point);
    print('👆 Konum güncellendi: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}');
    _loadAddressWithDebounce();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _loadingCurrentLocation = true);
    
    try {
      // Konum servisinin açık olup olmadığını kontrol et
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konum servisi kapalı. Lütfen etkinleştirin.')),
          );
        }
        return;
      }

      // İzin kontrolü
      var permission = await Permission.locationWhenInUse.status;
      if (!permission.isGranted) {
        permission = await Permission.locationWhenInUse.request();
        if (!permission.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Konum izni gerekli')),
            );
          }
          return;
        }
      }

      // Mevcut konumu al
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      final currentLocation = LatLng(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _selectedLocation = currentLocation;
        });
        
        // Haritayı mevcut konuma taşı
        _mapController.move(currentLocation, 15);
        
        // Adresi yükle
        _loadAddress();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konum alınamadı: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingCurrentLocation = false);
      }
    }
  }

  void _confirmLocation() {
    Navigator.of(context).pop({
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'address': _address,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Seçin'),
        actions: [
          if (_loadingCurrentLocation)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              tooltip: 'Mevcut Konuma Git',
            ),
          TextButton(
            onPressed: _confirmLocation,
            child: const Text('Seç'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Seçili konum bilgisi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seçili Konum:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                  'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                if (_loadingAddress)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Adres yükleniyor...'),
                    ],
                  )
                else if (_address != null)
                  Text(
                    _address!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
          
          // Harita
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 15,
                    onTap: _onMapTap,
                    onPositionChanged: (position, hasGesture) {
                      print('🗺️ onPositionChanged: hasGesture=$hasGesture, center=${position.center}');
                      if (hasGesture) {
                        // Harita hareket ettirildiğinde merkez konumu güncelle
                        setState(() {
                          _selectedLocation = position.center;
                        });
                        print('🗺️ Konum güncellendi: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}');
                        // Adresi debounce ile güncelle
                        _loadAddressWithDebounce();
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'cozum.mobile',
                    ),
                  ],
                ),
                // Merkez marker (sabit)
                const Center(
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 50,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                // Konum yükleme göstergesi
                if (_loadingCurrentLocation)
                  Container(
                    color: Colors.black12,
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text('Konum alınıyor...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Alt buton alanı
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _confirmLocation,
                  icon: const Icon(Icons.check),
                  label: const Text('Bu Konumu Seç'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}