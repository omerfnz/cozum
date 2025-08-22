import 'package:flutter/material.dart';

class ReportCreateView extends StatelessWidget {
  const ReportCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Bildirim')),
      body: const Center(
        child: Text('Rapor oluşturma ekranı yakında eklenecek.'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Placeholder: başarıyla oluşturulmuş gibi davranıp geri dön
          Navigator.of(context).pop(true);
        },
        icon: const Icon(Icons.check),
        label: const Text('Tamam'),
      ),
    );
  }
}