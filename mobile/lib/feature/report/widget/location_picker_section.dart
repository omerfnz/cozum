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
              onTap: onSelectFromMap,
              child: SizedBox(
                height: 200,
                child: AbsorbPointer(
                  absorbing: true,
                  child: FlutterMap(
                    mapController: previewMapController,
                    options: MapOptions(
                      initialCenter: latitude != null && longitude != null
                          ? LatLng(latitude!, longitude!)
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