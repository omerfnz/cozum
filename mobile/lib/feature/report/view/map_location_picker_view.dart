import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  void initState() {
    super.initState();
    // Başlangıç koordinatları veya İstanbul varsayılanı
    _selectedLocation = LatLng(
      widget.initialLatitude ?? 41.015137,
      widget.initialLongitude ?? 28.979530,
    );
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    setState(() => _loadingAddress = true);
    
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
          'lat': _selectedLocation.latitude,
          'lon': _selectedLocation.longitude,
        },
      );
      
      if (res.statusCode == 200 && res.data is Map) {
        final data = res.data as Map;
        final displayName = data['display_name'] as String?;
        if (displayName != null && mounted) {
          setState(() => _address = displayName);
        }
      }
    } catch (_) {
      // Hata durumunda sessizce geç
      if (mounted) {
        setState(() => _address = 'Adres alınamadı');
      }
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() => _selectedLocation = point);
    _loadAddress();
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
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 15,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'cozum.mobile',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
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