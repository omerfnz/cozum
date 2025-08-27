import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../product/navigation/app_router.dart';
import '../view_model/create_report_cubit.dart';
import '../view_model/create_report_state.dart';
import '../widget/create_report_shimmer.dart';
import '../widget/create_report_error_view.dart';
import '../widget/photo_picker_section.dart';
import '../widget/location_picker_section.dart';
import 'map_location_picker_view.dart';

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
            return const CreateReportShimmer();
          }
          
          if (state is CreateReportError && state.message.contains('Kategoriler')) {
            return CreateReportErrorView(
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
                  PhotoPickerSection(
                    cubit: cubit,
                    image: image,
                  ),
                  const SizedBox(height: 16),
                  LocationPickerSection(
                    cubit: cubit,
                    latitude: latitude,
                    longitude: longitude,
                    locationController: _locationCtrl,
                    previewMapController: _previewMapController,
                    onSelectFromMap: () => _selectFromMap(cubit),
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