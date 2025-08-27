import 'package:flutter/material.dart';

import '../../../product/models/report.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({required this.comment, super.key});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(comment.user.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comment.createdAt != null)
            Text(
              _formatDate(comment.createdAt!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 4),
          Text(comment.content),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}