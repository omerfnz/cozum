import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../product/navigation/app_router.dart';
import '../../../product/service/auth/auth_service.dart';

@RoutePage()
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = GetIt.I<IAuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurumsal Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                context.router.replaceAll([const LoginViewRoute()]);
              }
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return GridView.count(
              crossAxisCount: isWide ? 3 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _DashboardCard(
                  color: Colors.indigo,
                  title: 'Görevler',
                  icon: Icons.task_alt_rounded,
                  onTap: () => context.router.push(const TasksViewRoute()),
                ),
                _DashboardCard(
                  color: Colors.teal,
                  title: 'Ekipler',
                  icon: Icons.groups_2_rounded,
                  onTap: () => context.router.push(const TeamsViewRoute()),
                ),
                _DashboardCard(
                  color: Colors.orange,
                  title: 'Rapor Oluştur',
                  icon: Icons.description_outlined,
                  onTap: () => context.router.push(const CreateReportViewRoute()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}