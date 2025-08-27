import 'package:flutter/material.dart';

import '../../../product/models/report.dart';

class ReportDetailHeader extends StatelessWidget {
  const ReportDetailHeader(this.report, {super.key});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final hasImage = report.firstMediaUrl != null && report.firstMediaUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            report.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ReportBadge(label: report.category.name, color: Colors.indigo.shade600),
              const SizedBox(width: 8),
              ReportBadge(label: report.status.displayName, color: _colorForStatus(report.status)),
              const SizedBox(width: 8),
              ReportBadge(label: report.priority.displayName, color: _colorForPriority(report.priority)),
              const Spacer(),
              Text(report.formattedDate, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (hasImage)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Ink.image(
              image: NetworkImage(report.firstMediaUrl!),
              fit: BoxFit.cover,
            ),
          ),
        if (report.description != null && report.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(report.description!),
          ),
        if (report.location != null && report.location!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(report.location!)),
              ],
            ),
          ),
      ],
    );
  }
}

class ReportBadge extends StatelessWidget {
  const ReportBadge({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
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
      return Colors.grey.shade700;
    case ReportPriority.orta:
      return Colors.teal.shade700;
    case ReportPriority.yuksek:
      return Colors.deepOrange.shade700;
    case ReportPriority.acil:
      return Colors.red.shade700;
  }
}