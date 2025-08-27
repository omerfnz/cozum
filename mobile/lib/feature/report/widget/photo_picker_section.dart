import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../view_model/create_report_cubit.dart';

class PhotoPickerSection extends StatelessWidget {
  const PhotoPickerSection({
    super.key,
    required this.cubit,
    required this.image,
  });

  final CreateReportCubit cubit;
  final XFile? image;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fotoğraf', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (image != null)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.file(
              File(image!.path),
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
      ],
    );
  }
}