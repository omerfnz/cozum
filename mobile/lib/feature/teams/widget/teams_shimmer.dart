import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TeamsShimmer extends StatelessWidget {
  const TeamsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.white),
              title: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}