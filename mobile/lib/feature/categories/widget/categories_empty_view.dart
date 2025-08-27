import 'package:flutter/material.dart';

class CategoriesEmptyView extends StatelessWidget {
  final bool canManage;
  final VoidCallback? onCreateNew;

  const CategoriesEmptyView({
    super.key,
    required this.canManage,
    this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Henüz kategori bulunmuyor.'),
          if (canManage) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onCreateNew,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Kategori'),
            ),
          ]
        ],
      ),
    );
  }
}