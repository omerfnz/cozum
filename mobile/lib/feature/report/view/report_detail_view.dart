import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ReportDetailView extends StatelessWidget {
  const ReportDetailView({
    super.key,
    @pathParam required this.reportId,
  });
  
  final String reportId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Report Detail View - Report ID: $reportId'),
      ),
    );
  }
}