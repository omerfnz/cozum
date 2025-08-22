import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/feature/home/cubit/home_feed_cubit.dart';
import 'package:mobile/feature/report/view/report_create_view.dart';
import 'package:mobile/feature/report/view/report_detail_view.dart';
import 'package:mobile/product/auth/token_storage.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/navigation/app_router.dart';
import 'package:mobile/product/report/model/report_models.dart';
import 'package:mobile/product/report/report_repository.dart';

/// Ana ekran görünümü
@RoutePage()
final class HomeView extends StatefulWidget {
  /// Varsayılan kurucu
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

final class _HomeViewState extends State<HomeView> {
  late final HomeFeedCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = HomeFeedCubit(di<ReportRepository>())..fetch();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      {'label': 'Tümü', 'value': 'all', 'icon': Icons.public},
      {'label': 'Benim', 'value': 'mine', 'icon': Icons.person_outline},
      {'label': 'Atanan', 'value': 'assigned', 'icon': Icons.groups_2_outlined},
    ];

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Çözüm Var'),
          actions: [
            IconButton(
              tooltip: 'Yeni',
              onPressed: () async {
                final navigator = Navigator.of(context);
                final created = await navigator.push<bool>(
                  MaterialPageRoute(builder: (_) => const ReportCreateView()),
                );
                if (created == true) {
                  if (!context.mounted) return;
                  await _cubit.refresh();
                }
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
            IconButton(
              tooltip: 'Çıkış',
              onPressed: () async {
                final router = context.router;
                await di<TokenStorage>().clear();
                if (!context.mounted) return;
                await router.replaceAll([const LoginRoute()]);
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _ScopeTabs(tabs: tabs),
              const Divider(height: 1),
              Expanded(
                child: BlocConsumer<HomeFeedCubit, HomeFeedState>(
                  listener: (context, state) {
                    if (state.error != null && state.items.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Yüklenirken hata: ${state.error}')),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.isLoading && state.items.isEmpty) {
                      return const _FeedSkeleton();
                    }
                    if (state.error != null && state.items.isEmpty) {
                      return _ErrorView(message: state.error!, onRetry: _cubit.fetch);
                    }
                    if (state.items.isEmpty) {
                      return const _EmptyView();
                    }
                    return RefreshIndicator(
                      onRefresh: _cubit.refresh,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (sn) {
                          if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 200) {
                            _cubit.fetchNext();
                          }
                          return false;
                        },
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
                              return const _BottomLoader();
                            }
                            final item = state.items[index];
                            return _FeedCard(item: item);
                          },
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScopeTabs extends StatelessWidget {
  const _ScopeTabs({required this.tabs});

  final List<Map<String, Object>> tabs;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeFeedCubit, HomeFeedState>(
      builder: (context, state) {
        return SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final tab = tabs[index];
              final label = tab['label']! as String;
              final value = tab['value']! as String;
              final icon = tab['icon']! as IconData;
              final selected = state.scope == value;
              return ChoiceChip(
                selected: selected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 6),
                    Text(label),
                  ],
                ),
                onSelected: (_) => context.read<HomeFeedCubit>().changeScope(value),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: tabs.length,
          ),
        );
      },
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, __) => _SkeletonCard(),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: 5,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: base,
        height: 180,
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            const Text('Henüz bir bildirim yok'),
            const SizedBox(height: 4),
            Text(
              'Yeni bildirilen sorunlar burada görünecek',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
            )
          ],
        ),
      ),
    );
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
            Icon(Icons.error_outline, size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            const Text('Bir hata oluştu'),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.item});

  final ReportListItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.3,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReportDetailView(reportId: item.id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Header
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(item.reporter.username ?? item.reporter.email),
            subtitle: Text('${item.category.name} • ${_formatRelative(item.createdAt)}'),
            trailing: _StatusChip(status: item.status, priority: item.priority),
          ),
          // Media
          if (item.firstMediaUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                item.firstMediaUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: scheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.broken_image_outlined)),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: scheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          if (item.firstMediaUrl == null)
            Container(
              height: 8,
            ),
          // Title / Description preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (item.location != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.location!,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Footer actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ReportDetailView(reportId: item.id)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  tooltip: 'Yorumlar (${item.commentCount})',
                ),
                const Spacer(),
                const SizedBox.shrink(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                  tooltip: 'Daha fazla',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
          ),
        ),
      );
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'az önce';
    if (diff.inHours < 1) return '${diff.inMinutes} dk';
    if (diff.inDays < 1) return '${diff.inHours} sa';
    return '${diff.inDays} gün';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.priority});

  final String status;
  final String priority;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'COZULDU':
        color = Colors.green;
        break;
      case 'INCELENIYOR':
        color = Colors.orange;
        break;
      case 'REDDEDILDI':
        color = Colors.red;
        break;
      default:
        color = Theme.of(context).colorScheme.primary;
    }

    return Chip(
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      label: Text(status),
      avatar: Icon(Icons.circle, size: 12, color: color),
    );
  }
}

class _BottomLoader extends StatelessWidget {
  const _BottomLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
