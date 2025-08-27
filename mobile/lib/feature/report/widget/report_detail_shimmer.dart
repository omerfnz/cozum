import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../product/theme/theme_constants.dart';

class ReportDetailShimmer extends StatelessWidget {
  const ReportDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            period: AppDurations.shimmer,
            child: Container(height: 24, width: 220, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            period: AppDurations.shimmer,
            child: Row(
              children: [
                Container(height: 24, width: 80, color: Colors.white),
                const SizedBox(width: 8),
                Container(height: 24, width: 100, color: Colors.white),
                const SizedBox(width: 8),
                Container(height: 24, width: 80, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            period: AppDurations.shimmer,
            child: Container(height: 180, width: double.infinity, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            period: AppDurations.shimmer,
            child: Column(
              children: [
                Container(height: 12, width: double.infinity, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 12, width: double.infinity, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 12, width: 180, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentsShimmer extends StatelessWidget {
  const CommentsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          period: AppDurations.shimmer,
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.white),
            title: Container(height: 12, width: 120, color: Colors.white),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Container(height: 10, width: double.infinity, color: Colors.white),
                const SizedBox(height: 6),
                Container(height: 10, width: 200, color: Colors.white),
              ],
            ),
          ),
        );
      },
    );
  }
}