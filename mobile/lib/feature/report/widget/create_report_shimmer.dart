import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CreateReportShimmer extends StatelessWidget {
  const CreateReportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

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