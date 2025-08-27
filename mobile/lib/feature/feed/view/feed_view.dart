import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../product/models/report.dart';
import '../../../product/navigation/navigation_guard.dart';
import '../../../product/theme/theme_constants.dart';
import '../../../product/widgets/snackbar.dart';
import '../view_model/feed_cubit.dart';
import '../view_model/feed_state.dart';

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedCubit()..loadUserAndFetch(),
      child: const _FeedViewBody(),
    );
  }
}

class _FeedViewBody extends StatefulWidget {
  const _FeedViewBody();

  @override
  State<_FeedViewBody> createState() => _FeedViewBodyState();
}

class _FeedViewBodyState extends State<_FeedViewBody> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final cubit = context.read<FeedCubit>();
    if (!_scroll.hasClients) return;
    final maxScroll = _scroll.position.maxScrollExtent;
    final current = _scroll.position.pixels;
    if (current > maxScroll - 200) {
      cubit.loadMoreReports();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<FeedCubit>().loadUserAndFetch();
  }

  Future<void> _deleteReport(Report report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirimi Sil'),
        content: const Text('Bu bildirimi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<FeedCubit>().deleteReport(report);
    }
  }

  void _showReportActions(Report report) {
    final cubit = context.read<FeedCubit>();
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
                _openDetail(report);
              },
            ),
            if (cubit.canDeleteReport(report))
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Sil', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteReport(report);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Report report) {
    final id = report.id;
    if (id == null) {
      context.showSnack('Rapor ID bulunamadı');
      return;
    }
    NavigationHelper.showReportDetail(context.router, id.toString());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedCubit, FeedState>(
      listener: (context, state) {
        if (state is FeedReportDeleted) {
          context.showSnack('Bildirim başarıyla silindi');
        } else if (state is FeedError) {
          context.showSnack('Hata: ${state.message}');
        }
      },
      builder: (context, state) {
        if (state is FeedLoading) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 0),
            itemBuilder: (context, index) => const _FeedCardShimmer(),
          );
        }
        
        if (state is FeedError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => context.read<FeedCubit>().loadUserAndFetch(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }
        
        if (state is FeedLoaded) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.visibleReports.length + 1,
              itemBuilder: (context, index) {
                if (index == state.visibleReports.length) {
                  if (state.hasMoreToLoad) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: _LoadingMoreShimmer(),
                    );
                  }
                  return const SizedBox(height: 80);
                }
                final r = state.visibleReports[index];
                return _FeedCard(
                  report: r,
                  onTap: () => _openDetail(r),
                  onLongPress: () => _showReportActions(r),
                );
              },
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({
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

class _FeedCardShimmer extends StatelessWidget {
  const _FeedCardShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        period: AppDurations.shimmer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ListTile skeleton
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, width: double.infinity, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 120, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(height: 12, width: 60, color: Colors.white),
                ],
              ),
            ),
            // Image skeleton
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(color: Colors.white),
            ),
            // Description skeleton
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 6),
                  _SkeletonLine(widthFactor: 1.0),
                  SizedBox(height: 8),
                  _SkeletonLine(widthFactor: 0.9),
                  SizedBox(height: 8),
                  _SkeletonLine(widthFactor: 0.7),
                ],
              ),
            ),
            // Footer skeleton
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: const [
                  _SkeletonChip(width: 80),
                  SizedBox(width: 8),
                  _SkeletonChip(width: 70),
                  Spacer(),
                  _SkeletonLine(width: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({this.widthFactor, this.width});
  final double? widthFactor;
  final double? width;
  @override
  Widget build(BuildContext context) {
    final line = Container(height: 12, color: Colors.white);
    if (width != null) {
      return SizedBox(width: width, child: line);
    }
    if (widthFactor != null) {
      return FractionallySizedBox(widthFactor: widthFactor!, child: line);
    }
    return line;
  }
}

class _SkeletonChip extends StatelessWidget {
  const _SkeletonChip({required this.width});
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _LoadingMoreShimmer extends StatelessWidget {
  const _LoadingMoreShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: AppDurations.shimmer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 8, width: 60, color: Colors.white),
          const SizedBox(width: 12),
          Container(height: 8, width: 60, color: Colors.white),
          const SizedBox(width: 12),
          Container(height: 8, width: 60, color: Colors.white),
        ],
      ),
    );
  }
}