import 'package:flutter/material.dart';
import '../../../product/models/report.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.canManage,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(category.name.isNotEmpty ? category.name.characters.first : '?'),
        ),
        title: Text(category.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.description != null && category.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  category.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  category.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: category.isActive
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                ),
                const SizedBox(width: 6),
                Text(category.isActive ? 'Aktif' : 'Pasif',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            )
          ],
        ),
        onTap: canManage ? onEdit : null,
        trailing: canManage
            ? PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit?.call();
                  if (v == 'delete') onDelete?.call();
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 8),
                        Text('Sil'),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}