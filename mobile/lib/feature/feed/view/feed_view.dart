import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/report.dart';
import '../../../product/service/network/network_service.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final _net = GetIt.I<INetworkService>();
  final _scroll = ScrollController();

  List<Report> _all = [];
  int _visibleCount = 0;
  static const int _pageSize = 8;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _net.request<List<Report>>(
      path: ApiEndpoints.reports,
      type: RequestType.get,
      parser: (json) {
        final list = (json as List<dynamic>)
            .map((e) => Report.fromJson(e as Map<String, dynamic>))
            .toList();
        // En yeni ilk
        list.sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
        return list;
      },
    );

    if (!mounted) return;
    if (res.isSuccess && res.data != null) {
      setState(() {
        _all = res.data!;
        _visibleCount = min(_pageSize, _all.length);
        _loading = false;
      });
    } else {
      setState(() {
        _error = res.error ?? 'Akış yüklenemedi';
        _loading = false;
      });
    }
  }

  void _onScroll() {
    if (_loadingMore || _loading) return;
    if (!_scroll.hasClients) return;
    final maxScroll = _scroll.position.maxScrollExtent;
    final current = _scroll.position.pixels;
    if (current > maxScroll - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_visibleCount >= _all.length) return;
    setState(() => _loadingMore = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _visibleCount = min(_visibleCount + _pageSize, _all.length);
        _loadingMore = false;
      });
    });
  }

  Future<void> _onRefresh() async {
    await _fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            FilledButton(onPressed: _fetch, child: const Text('Tekrar Dene')),
          ],
        ),
      );
    }

    final visible = _all.take(_visibleCount).toList();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: visible.length + 1,
        itemBuilder: (context, index) {
          if (index == visible.length) {
            if (_visibleCount >= _all.length) {
              return const SizedBox(height: 80);
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final r = visible[index];
          return _FeedCard(report: r);
        },
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final hasImage = report.firstMediaUrl != null && report.firstMediaUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      clipBehavior: Clip.antiAlias,
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
              report.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                _Badge(
                  label: report.status.displayName,
                  color: _colorForStatus(report.status),
                ),
                const SizedBox(width: 8),
                _Badge(
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .3)),
        color: color.withValues(alpha: .08),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}