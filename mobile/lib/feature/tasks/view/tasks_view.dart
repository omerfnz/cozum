import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/service/auth/auth_service.dart';
import '../../../product/navigation/navigation_guard.dart';
import '../../../product/service/network/network_service.dart';

@RoutePage()
class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final _net = GetIt.I<INetworkService>();

  bool _loading = true;
  String? _error;
  List<Report> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Görevler backend’de raporlar olarak tutuluyor. Rol/ekip filtreleri query param ile gönderilir.
    final res = await _net.request<List<Report>>(
      path: ApiEndpoints.reports,
      type: RequestType.get,
      queryParameters: await _defaultFilters(),
      parser: (json) {
        if (json is List) {
          return json.map((e) => Report.fromJson(e as Map<String, dynamic>)).toList();
        }
        if (json is Map && json['results'] is List) {
          return (json['results'] as List)
              .map((e) => Report.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <Report>[];
      },
    );

    if (!mounted) return;

    if (res.isSuccess) {
      setState(() {
        _items = res.data ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _error = res.error ?? 'Görevler yüklenemedi';
        _loading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _defaultFilters() async {
    // Rol bazlı filtreler:
    // - EKIP: Sadece kendi takımına atanmış ve açık durumdaki görevler
    // - OPERATOR/ADMIN: Tüm takımlar (team filtresi uygulanmaz), açık durumlar
    try {
      final auth = GetIt.I<IAuthService>();
      final meRes = await auth.getCurrentUser();
      final user = meRes.data; // null olabilir
      final int? teamId = (user?.team?['id'] as num?)?.toInt();
      final String? role = user?.role;

      final Map<String, dynamic> q = {};

      // Yalnızca ekip üyeleri için takım filtresi uygula
      if (role == 'EKIP' && teamId != null) {
        q['assigned_team'] = teamId;
      }

      // Görev listesinde anlamlı durumlar
      q['status'] = [
        ReportStatus.beklemede.value,
        ReportStatus.inceleniyor.value,
      ].join(',');

      return q;
    } catch (_) {
      return {};
    }
  }

  Future<void> _onRefresh() async {
    await _fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _TasksShimmer();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _fetch,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(child: Text('Henüz görev bulunmuyor.'));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final r = _items[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _statusColor(r.status),
                child: Text(r.priority.displayName.substring(0, 1)),
              ),
              title: Text(r.title),
              isThreeLine: true,
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.category.name, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.group_outlined, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        r.assignedTeam?.name ?? 'Takım atanmamış',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _statusLabel(r.status),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
                ],
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => NavigationHelper.showReportDetail(context.router, r.id!.toString()),
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(ReportStatus s) {
    switch (s) {
      case ReportStatus.beklemede:
        return 'Beklemede';
      case ReportStatus.inceleniyor:
        return 'İnceleniyor';
      case ReportStatus.cozuldu:
        return 'Çözüldü';
      case ReportStatus.reddedildi:
        return 'Reddedildi';
    }
  }

  Color _statusColor(ReportStatus s) {
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
}

class _TasksShimmer extends StatelessWidget {
  const _TasksShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: const _TaskSkeletonCard(),
        );
      },
    );
  }
}

class _TaskSkeletonCard extends StatelessWidget {
  const _TaskSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 10,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white),
      ),
    );
  }
}