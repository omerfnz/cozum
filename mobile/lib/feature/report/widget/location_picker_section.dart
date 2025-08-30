import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../view_model/create_report_cubit.dart';

class LocationPickerSection extends StatelessWidget {
  const LocationPickerSection({
    super.key,
    required this.cubit,
    required this.latitude,
    required this.longitude,
    required this.locationController,
    required this.previewMapController,
    required this.onSelectFromMap,
  });

  final CreateReportCubit cubit;
  final double? latitude;
  final double? longitude;
  final TextEditingController locationController;
  final MapController previewMapController;
  final VoidCallback onSelectFromMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Konum (opsiyonel)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                latitude != null && longitude != null
                    ? 'Lat: ${latitude!.toStringAsFixed(5)}, Lng: ${longitude!.toStringAsFixed(5)}'
                    : 'Konum seçilmedi',
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Mevcut konumunuzu alır. Aşağıdaki haritaya dokunarak noktayı değiştirebilirsiniz.',
              child: OutlinedButton.icon(
                onPressed: () => cubit.useCurrentLocation(),
                icon: const Icon(Icons.my_location),
                label: const Text('Mevcut Konumu Al'),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Haritadan konum seçmek için aşağıdaki haritaya dokunun veya "Haritadan Seç" butonuna tıklayın',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSelectFromMap,
                icon: const Icon(Icons.map),
                label: const Text('Haritadan Seç'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (latitude != null && longitude != null)
          Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 150,
                child: Stack(
                  children: [
                    AbsorbPointer(
                      absorbing: true,
                      child: FlutterMap(
                        mapController: previewMapController,
                        options: MapOptions(
                          initialCenter: LatLng(latitude!, longitude!),
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                            subdomains: const ['a', 'b', 'c', 'd'],
                            userAgentPackageName: 'cozum.mobile',
                            maxZoom: 19,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.location_pin,
                        color: Theme.of(context).colorScheme.error,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        TextFormField(
          controller: locationController,
          decoration: const InputDecoration(
            labelText: 'Adres/konum açıklaması (opsiyonel)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}