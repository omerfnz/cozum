import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'map_location_picker_view.dart';

import '../../../product/navigation/app_router.dart';
import '../view_model/create_report_cubit.dart';
import '../view_model/create_report_state.dart';

@RoutePage()
class CreateReportView extends StatelessWidget {
  const CreateReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateReportCubit()..loadCategories(),
      child: const _CreateReportViewBody(),
    );
  }
}

class _CreateReportViewBody extends StatefulWidget {
  const _CreateReportViewBody();

  @override
  State<_CreateReportViewBody> createState() => _CreateReportViewBodyState();
}

class _CreateReportViewBodyState extends State<_CreateReportViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final MapController _previewMapController = MapController();

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
      body: BlocConsumer<CreateReportCubit, CreateReportState>(
        listener: (context, state) {
          if (state is CreateReportLocationUpdated) {
            if (state.address != null) {
              _locationCtrl.text = state.address!;
            }
            // Haritayı güncelle
            try {
              _previewMapController.move(LatLng(state.latitude, state.longitude), 13);
            } catch (_) {}
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Konum alındı: ${state.latitude.toStringAsFixed(5)}, ${state.longitude.toStringAsFixed(5)}'),
              ),
            );
          } else if (state is CreateReportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bildirim oluşturuldu.')),
            );
            // Detay sayfasına geç
            final id = state.report.id;
            if (id != null) {
              context.router.replace(ReportDetailViewRoute(reportId: id.toString()));
            } else {
              context.router.maybePop();
            }
          } else if (state is CreateReportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CreateReportLoading) {
            return const _CreateReportShimmer();
          }
          
          if (state is CreateReportError && state.message.contains('Kategoriler')) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<CreateReportCubit>().loadCategories(),
            );
          }

          final cubit = context.read<CreateReportCubit>();
          final categories = cubit.categories;
          final selectedCategoryId = cubit.selectedCategoryId;
          final image = cubit.selectedImage;
          final latitude = cubit.latitude;
          final longitude = cubit.longitude;
          final isSubmitting = state is CreateReportSubmitting;

          return SafeArea(
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
                        value: selectedCategoryId,
                        items: categories
                            .map((c) => DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            cubit.selectCategory(v);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Fotoğraf', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (image != null)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.file(
                        File(image.path),
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
                          onPressed: () => cubit.pickImageFromCamera(),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text('Kamera'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => cubit.pickImageFromGallery(),
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
                          latitude != null && longitude != null
                              ? 'Lat: ${latitude.toStringAsFixed(5)}, Lng: ${longitude.toStringAsFixed(5)}'
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
                        onTap: () => _selectFromMap(cubit),
                        child: SizedBox(
                          height: 200,
                          child: AbsorbPointer(
                            absorbing: true,
                            child: FlutterMap(
                              mapController: _previewMapController,
                              options: MapOptions(
                                initialCenter: latitude != null && longitude != null
                                    ? LatLng(latitude, longitude)
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
                    onPressed: isSubmitting ? null : () => _submit(cubit),
                    icon: isSubmitting
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
          );
        },
      ),
    );
  }

  Future<void> _selectFromMap(CreateReportCubit cubit) async {
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
          initialLatitude: cubit.latitude,
          initialLongitude: cubit.longitude,
        ),
      ),
    );

    if (result != null) {
      final latitude = result['latitude'] as double?;
      final longitude = result['longitude'] as double?;
      final address = result['address'] as String?;
      
      if (latitude != null && longitude != null) {
        cubit.updateLocation(latitude, longitude, address);
      }
    }
  }

  void _submit(CreateReportCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    
    if (cubit.selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kategori seçiniz.')),
      );
      return;
    }
    
    if (cubit.selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir fotoğraf ekleyiniz.')),
      );
      return;
    }

    cubit.submitReport(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locationCtrl.text.trim().isNotEmpty ? _locationCtrl.text.trim() : null,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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