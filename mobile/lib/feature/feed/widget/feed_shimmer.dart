import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../product/theme/theme_constants.dart';

class FeedCardShimmer extends StatelessWidget {
  const FeedCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        period: AppDurations.shimmer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ListTile skeleton
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, width: double.infinity, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 120, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(height: 12, width: 60, color: Colors.white),
                ],
              ),
            ),
            // Image skeleton
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: Colors.white),
            ),
            // Description skeleton
            Padding(
              padding: const EdgeInsets.all(12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6),
                  SkeletonLine(widthFactor: 1.0),
                  SizedBox(height: 8),
                  SkeletonLine(widthFactor: 0.9),
                  SizedBox(height: 8),
                  SkeletonLine(widthFactor: 0.7),
                ],
              ),
            ),
            // Footer skeleton
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  SkeletonChip(width: 80),
                  SizedBox(width: 8),
                  SkeletonChip(width: 70),
                  Spacer(),
                  SkeletonLine(width: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.widthFactor, this.width});

  final double? widthFactor;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final line = Container(height: 12, color: Colors.white);
    if (width != null) {
      return SizedBox(width: width, child: line);
    }
    if (widthFactor != null) {
      return FractionallySizedBox(widthFactor: widthFactor!, child: line);
    }
    return line;
  }
}

class SkeletonChip extends StatelessWidget {
  const SkeletonChip({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class LoadingMoreShimmer extends StatelessWidget {
  const LoadingMoreShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: AppDurations.shimmer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 8, width: 60, color: Colors.white),
          const SizedBox(width: 12),
          Container(height: 8, width: 60, color: Colors.white),
          const SizedBox(width: 12),
          Container(height: 8, width: 60, color: Colors.white),
        ],
      ),
    );
  }
}