import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/service/network/network_service.dart';
import '../../../product/theme/theme_constants.dart';
import '../../../product/service/auth/auth_service.dart';
import '../../../product/models/user.dart' show Team; // Team modelini kullanmak için

@RoutePage()
class ReportDetailView extends StatefulWidget {
  const ReportDetailView({
    super.key,
    @pathParam required this.reportId,
  });

  final String reportId;

  @override
  State<ReportDetailView> createState() => _ReportDetailViewState();
}

class _ReportDetailViewState extends State<ReportDetailView> {
  final _net = GetIt.I<INetworkService>();

  Report? _report;
  List<Comment> _comments = const [];
  bool _loadingReport = true;
  bool _loadingComments = true;
  bool _sending = false;
  String? _error;
  final _commentCtrl = TextEditingController();

  String? _myRole; // Mevcut kullanıcının rolü (UI yetkileri için)

  int? get _reportIdInt => int.tryParse(widget.reportId);

  @override
  void initState() {
    super.initState();
    if (_reportIdInt == null) {
      _error = 'Geçersiz rapor ID';
      _loadingReport = false;
      _loadingComments = false;
    } else {
      _fetchAll();
      _loadMe();
    }
  }

  Future<void> _loadMe() async {
    try {
      final auth = GetIt.I<IAuthService>();
      final meRes = await auth.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _myRole = meRes.data?.role;
      });
    } catch (_) {
      // rol alınamazsa, UI gizlenecek
    }
  }

  Future<void> _fetchAll() async {
    await Future.wait([_fetchReport(), _fetchComments()]);
  }

  Future<void> _fetchReport() async {
    setState(() {
      _loadingReport = true;
      _error = null;
    });
    final id = _reportIdInt!;
    final res = await _net.request<Report>(
      path: ApiEndpoints.reportById(id),
      type: RequestType.get,
      parser: (json) => Report.fromJson(json as Map<String, dynamic>),
    );
    if (!mounted) return;
    if (res.isSuccess && res.data != null) {
      setState(() {
        _report = res.data;
        _loadingReport = false;
      });
    } else {
      setState(() {
        _error = res.error ?? 'Rapor detayı yüklenemedi';
        _loadingReport = false;
      });
    }
  }

  Future<void> _fetchComments() async {
    setState(() => _loadingComments = true);
    final id = _reportIdInt!;
    final res = await _net.request<List<Comment>>(
      path: ApiEndpoints.reportComments(id),
      type: RequestType.get,
      parser: (json) {
        final list = (json as List<dynamic>)
            .map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList();
        // En eski ilk (kronolojik)
        list.sort((a, b) => (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        return list;
      },
    );
    if (!mounted) return;
    if (res.isSuccess && res.data != null) {
      setState(() {
        _comments = res.data!;
        _loadingComments = false;
      });
    } else {
      setState(() {
        _loadingComments = false;
      });
    }
  }

  Future<void> _addComment() async {
    final content = _commentCtrl.text.trim();
    if (content.isEmpty || _sending || _reportIdInt == null) return;
    setState(() => _sending = true);
    final id = _reportIdInt!;
    final res = await _net.request<Comment>(
      path: ApiEndpoints.reportComments(id),
      type: RequestType.post,
      data: {
        'content': content,
      },
      parser: (json) => Comment.fromJson(json as Map<String, dynamic>),
    );
    if (!mounted) return;
    if (res.isSuccess && res.data != null) {
      setState(() {
        _comments = List.of(_comments)..add(res.data!);
        _commentCtrl.clear();
        _sending = false;
      });
      // Yorum sayısını güncelle
      setState(() {
        if (_report != null) {
          _report = _report!.copyWith(commentCountApi: (_report!.commentCountApi ?? _report!.comments?.length ?? 0) + 1);
        }
      });
    } else {
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'Yorum eklenemedi')),
      );
    }
  }

  // Operatör/Admin eylemleri: durum ve atama güncelleme
  bool get _canManage => _myRole == 'OPERATOR' || _myRole == 'ADMIN';

  Future<List<Team>> _getTeams() async {
    final res = await _net.request<List<Team>>(
      path: ApiEndpoints.teams,
      type: RequestType.get,
      parser: (json) => (json as List<dynamic>)
          .map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return res.data ?? <Team>[];
  }

  Future<void> _openUpdateSheet() async {
    final report = _report;
    if (report == null || !_canManage) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        ReportStatus selectedStatus = report.status;
        int? selectedTeamId = report.assignedTeam?.id;
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> onSave() async {
              if (saving) return;
              setModalState(() => saving = true);
              final ok = await _updateReport(status: selectedStatus, teamId: selectedTeamId);
              if (!mounted) return;
              try {
                setModalState(() => saving = false);
              } catch (_) {/* sheet kapanmış olabilir */}
              if (ok) {
                // State'in context'i ile guard edildi
                if (Navigator.of(this.context).canPop()) {
                  Navigator.of(this.context).pop();
                }
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Rapor güncellendi')),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Durum ve Atama', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),

                  // Durum seçimi
                  Text('Durum', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<ReportStatus>(
                    value: selectedStatus,
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    items: ReportStatus.values
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.displayName),
                            ))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedStatus = v ?? selectedStatus),
                  ),
                  const SizedBox(height: 12),

                  // Atanan takım seçimi
                  Text('Atanan Takım', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  FutureBuilder<List<Team>>(
                    future: _getTeams(),
                    builder: (context, snapshot) {
                      final loading = snapshot.connectionState == ConnectionState.waiting;
                      final teams = snapshot.data ?? const <Team>[];
                      return DropdownButtonFormField<int?>(
                        value: selectedTeamId,
                        isExpanded: true,
                        decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('— Atama Yok —'),
                          ),
                          ...teams.map((t) => DropdownMenuItem<int?>(
                                value: t.id,
                                child: Text(t.name),
                              )),
                        ],
                        onChanged: loading ? null : (v) => setModalState(() => selectedTeamId = v),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: saving ? null : () => Navigator.of(context).maybePop(),
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: saving ? null : onSave,
                          icon: saving
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.save_outlined),
                          label: const Text('Kaydet'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _updateReport({required ReportStatus status, int? teamId}) async {
    final id = _reportIdInt;
    if (id == null) return false;
    final res = await _net.request<Map<String, dynamic>>(
      path: ApiEndpoints.reportById(id),
      type: RequestType.patch,
      data: {
        'status': status.value,
        'assigned_team': teamId,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    if (!mounted) return false;

    if (res.isSuccess) {
      // Güncel veriyi tekrar çek
      await _fetchReport();
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'Güncelleme başarısız')),
      );
      return false;
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    return Scaffold(
      appBar: AppBar(
        title: Text(report?.title ?? 'Bildirim Detayı'),
        actions: [
          if (report != null && _canManage)
            IconButton(
              tooltip: 'Atama/Durum',
              onPressed: _openUpdateSheet,
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: _error != null
          ? _ErrorView(message: _error!, onRetry: _fetchAll)
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  if (_loadingReport) const _DetailShimmer() else if (report != null) _DetailHeader(report),
                  const Divider(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.mode_comment_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text('Yorumlar (${report?.commentCount ?? _comments.length})', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_loadingComments)
                    const _CommentsShimmer()
                  else if (_comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Henüz yorum yok. İlk yorumu siz yazın!'),
                    )
                  else
                    ..._comments.map((c) => _CommentTile(comment: c)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Yorum yazın...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _sending ? null : _addComment,
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: const Text('Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader(this.report);

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
              _Badge(label: report.category.name, color: Colors.indigo.shade600),
              const SizedBox(width: 8),
              _Badge(label: report.status.displayName, color: _colorForStatus(report.status)),
              const SizedBox(width: 8),
              _Badge(label: report.priority.displayName, color: _colorForPriority(report.priority)),
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

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

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

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

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

class _CommentsShimmer extends StatelessWidget {
  const _CommentsShimmer();

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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

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

String _formatDate(DateTime date) {
  return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}