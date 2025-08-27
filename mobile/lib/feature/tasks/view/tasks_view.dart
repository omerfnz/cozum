import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../product/models/report.dart';
import '../../../product/navigation/navigation_guard.dart';
import '../../../product/widgets/snackbar.dart';
import '../view_model/tasks_cubit.dart';
import '../view_model/tasks_state.dart';

@RoutePage()
class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TasksCubit()..fetchTasks(),
      child: const _TasksViewBody(),
    );
  }
}

class _TasksViewBody extends StatefulWidget {
  const _TasksViewBody();

  @override
  State<_TasksViewBody> createState() => _TasksViewBodyState();
}

class _TasksViewBodyState extends State<_TasksViewBody> {
  Future<void> _onRefresh() async {
    await context.read<TasksCubit>().fetchTasks();
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

    if (confirmed == true && mounted) {
      context.read<TasksCubit>().deleteTask(report);
    }
  }

  Future<void> _updateTaskStatus(Report report, ReportStatus newStatus) async {
    context.read<TasksCubit>().updateTaskStatus(report, newStatus);
  }

  void _showTaskActions(Report report) {
    final cubit = context.read<TasksCubit>();
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
            if (cubit.canManageTask(report)) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Durumu Değiştir'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showStatusUpdateDialog(report);
                },
              ),
            ],
            if (cubit.canDeleteTask(report))
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
    return BlocConsumer<TasksCubit, TasksState>(
      listener: (context, state) {
        if (state is TasksTaskDeleted) {
          context.showSnack('Görev başarıyla silindi', type: SnackbarType.success);
        } else if (state is TasksTaskUpdated) {
          context.showSnack('Görev durumu güncellendi', type: SnackbarType.success);
        } else if (state is TasksError) {
          context.showSnack('Hata: ${state.message}', type: SnackbarType.error);
        }
      },
      builder: (context, state) {
        if (state is TasksLoading) {
          return const _TasksShimmer();
        }

        if (state is TasksError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 36),
                const SizedBox(height: 8),
                Text(state.message),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.read<TasksCubit>().fetchTasks(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar dene'),
                ),
              ],
            ),
          );
        }

        if (state is TasksLoaded) {
          if (state.tasks.isEmpty) {
            return const Center(child: Text('Henüz görev bulunmuyor.'));
          }

          final cubit = context.read<TasksCubit>();
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final r = state.tasks[index];
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
                        if (cubit.canManageTask(r) || cubit.canDeleteTask(r))
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

        return const SizedBox.shrink();
      },
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