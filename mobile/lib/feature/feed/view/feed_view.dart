import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/models/report.dart';
import '../../../product/navigation/navigation_guard.dart';
import '../../../product/widgets/snackbar.dart';
import '../view_model/feed_cubit.dart';
import '../view_model/feed_state.dart';
import '../widget/feed_card.dart';
import '../widget/feed_shimmer.dart';

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
            itemBuilder: (context, index) => const FeedCardShimmer(),
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
                      child: LoadingMoreShimmer(),
                    );
                  }
                  return const SizedBox(height: 80);
                }
                final r = state.visibleReports[index];
                return FeedCard(
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