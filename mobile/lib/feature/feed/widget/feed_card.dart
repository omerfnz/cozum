import 'package:flutter/material.dart';

import '../../../product/models/report.dart';
import 'feed_badge.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.report,
    required this.onTap,
    required this.onLongPress,
  });

  final Report report;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final hasImage = report.firstMediaUrl != null && report.firstMediaUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(report.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                report.category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                report.formattedDate,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            if (hasImage)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Ink.image(
                  image: NetworkImage(report.firstMediaUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                report.description ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  FeedBadge(
                    label: report.status.displayName,
                    color: _colorForStatus(report.status),
                  ),
                  const SizedBox(width: 8),
                  FeedBadge(
                    label: report.priority.displayName,
                    color: _colorForPriority(report.priority),
                  ),
                  const Spacer(),
                  Icon(Icons.mode_comment_outlined, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text('${report.commentCount}')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForStatus(ReportStatus s) {
    switch (s) {
      case ReportStatus.beklemede:
        return Colors.orange.shade600;
      case ReportStatus.inceleniyor:
        return Colors.blue.shade600;
      case ReportStatus.cozuldu:
        return Colors.green.shade600;
      case ReportStatus.reddedildi:
        return Colors.red.shade600;
    }
  }

  Color _colorForPriority(ReportPriority p) {
    switch (p) {
      case ReportPriority.dusuk:
        return Colors.grey;
      case ReportPriority.orta:
        return Colors.blueGrey;
      case ReportPriority.yuksek:
        return Colors.deepOrange;
      case ReportPriority.acil:
        return Colors.red;
    }
  }
}