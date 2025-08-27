import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';

import '../../../product/service/auth/auth_service.dart' as auth;
import '../../../product/navigation/navigation_guard.dart';
import '../../../product/service/network/network_service.dart';
import '../../../product/widgets/snackbar.dart';

@RoutePage()
class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final _net = GetIt.I<INetworkService>();
  final _auth = GetIt.I<auth.IAuthService>();

  bool _loading = true;
  String? _error;
  List<Report> _items = [];
  auth.User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    try {
      final userRes = await _auth.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = userRes.data;
        });
      }
    } catch (_) {
      // Kullanıcı bilgisi yüklenemedi, devam et
    }
    await _fetch();
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
    // Backend'deki scope parametresi ile rol bazlı filtreleme:
    // - VATANDAS: scope=mine (kendi bildirimleri)
    // - EKIP: scope=assigned (takımına atananlar)
    // - OPERATOR/ADMIN: scope=all (tüm görevler)
    // tasks_only=true: Sadece atanmış bildirimleri göster (görev sayfası için)
    try {
      final authService = GetIt.I<auth.IAuthService>();
      final meRes = await authService.getCurrentUser();
      final user = meRes.data;
      final String? role = user?.role;

      final Map<String, dynamic> q = {
        'tasks_only': 'true', // Görev sayfası için sadece atanmış bildirimleri getir
      };

      // Rol bazlı scope parametresi
      switch (role) {
        case 'VATANDAS':
          q['scope'] = 'mine';
          break;
        case 'EKIP':
          q['scope'] = 'assigned';
          break;
        case 'OPERATOR':
        case 'ADMIN':
          q['scope'] = 'all';
          break;
        default:
          q['scope'] = 'mine'; // Güvenlik için varsayılan
      }

      return q;
    } catch (_) {
      return {
        'scope': 'mine', // Hata durumunda güvenli varsayılan
        'tasks_only': 'true',
      };
    }
  }

  Future<void> _onRefresh() async {
    await _loadUserAndFetch();
  }

  bool _canDeleteTask(Report report) {
    final role = _currentUser?.role;
    // OPERATOR/ADMIN tüm görevleri silebilir
    if (role == 'OPERATOR' || role == 'ADMIN') {
      return true;
    }
    // VATANDAS sadece kendi raporlarını silebilir
    if (role == 'VATANDAS' && report.reporter.id == _currentUser?.id) {
      return true;
    }
    return false;
  }

  bool _canManageTask(Report report) {
    final role = _currentUser?.role;
    // OPERATOR/ADMIN tüm görevleri yönetebilir
    if (role == 'OPERATOR' || role == 'ADMIN') {
      return true;
    }
    // EKIP sadece kendi takımına atananları yönetebilir
    if (role == 'EKIP' && report.assignedTeam?.id == _currentUser?.team?['id']) {
      return true;
    }
    return false;
  }

  Future<void> _deleteTask(Report report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: Text('"${report.title}" görevini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final res = await _net.request(
      path: '${ApiEndpoints.reports}/${report.id}/',
      type: RequestType.delete,
    );

    if (!mounted) return;

    if (res.isSuccess) {
      context.showSnack('Görev başarıyla silindi', type: SnackbarType.success);
      await _fetch();
    } else {
      context.showSnack(res.error ?? 'Görev silinemedi', type: SnackbarType.error);
    }
  }

  Future<void> _updateTaskStatus(Report report, ReportStatus newStatus) async {
    final res = await _net.request(
      path: '${ApiEndpoints.reports}/${report.id}/',
      type: RequestType.patch,
      data: {'status': newStatus.value},
    );

    if (!mounted) return;

    if (res.isSuccess) {
      context.showSnack('Görev durumu güncellendi', type: SnackbarType.success);
      await _fetch();
    } else {
      context.showSnack(res.error ?? 'Durum güncellenemedi', type: SnackbarType.error);
    }
  }

  void _showTaskActions(Report report) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Detayları Görüntüle'),
              onTap: () {
                Navigator.of(context).pop();
                NavigationHelper.showReportDetail(context.router, report.id!.toString());
              },
            ),
            if (_canManageTask(report)) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Durumu Değiştir'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showStatusUpdateDialog(report);
                },
              ),
            ],
            if (_canDeleteTask(report))
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Sil', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteTask(report);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durum Güncelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReportStatus.values.map((status) {
            return RadioListTile<ReportStatus>(
              title: Text(_statusLabel(status)),
              value: status,
              groupValue: report.status,
              onChanged: (value) {
                if (value != null) {
                  Navigator.of(context).pop();
                  _updateTaskStatus(report, value);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
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
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      NavigationHelper.showReportDetail(context.router, r.id!.toString());
                      break;
                    case 'actions':
                      _showTaskActions(r);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      leading: Icon(Icons.visibility),
                      title: Text('Detayları Görüntüle'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (_canManageTask(r) || _canDeleteTask(r))
                    const PopupMenuItem(
                      value: 'actions',
                      child: ListTile(
                        leading: Icon(Icons.more_horiz),
                        title: Text('Diğer İşlemler'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
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