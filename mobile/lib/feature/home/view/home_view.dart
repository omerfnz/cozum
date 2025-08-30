import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'dart:async';

import '../../../product/navigation/app_router.dart';
import '../../../product/service/auth/auth_service.dart';
import '../../../product/widgets/connectivity_banner.dart';
import '../../feed/view/feed_view.dart';
import '../../categories/view/categories_view.dart';
import '../../tasks/view/tasks_view.dart';
import '../../teams/view/teams_view.dart';
import '../../profile/view/profile_view.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _authService = GetIt.I<IAuthService>();
  int _currentIndex = 0;
  String _role = 'VATANDAS';

  @override
  void initState() {
    super.initState();
    // kullanıcı verisini arka planda çekiyoruz
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final me = await _authService
          .getCurrentUser()
          .timeout(const Duration(seconds: 12));
      if (!mounted) return;
      setState(() {
        _role = me.data?.role ?? 'VATANDAS';
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() {});
    }
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _goCreateReport() {
    context.router.push(const CreateReportViewRoute());
  }

  void _goSettings() {
    context.router.push(const SettingsViewRoute());
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        // UI'nin güncellenmesi için kısa bir bekleme
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          context.router.replaceAll([const LoginViewRoute()]);
        }
      }
    } catch (e) {
      if (mounted) {
        context.router.replaceAll([const LoginViewRoute()]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kullanıcı bilgisi beklenirken de ana UI'yi göster
    final tabs = _buildTabsByRole(_role);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(tabs)),
        actions: [
          const ConnectivityBanner(child: SizedBox.shrink()),
          // Yeni bildirim butonu AppBar'dan kaldırıldı (FAB zaten mevcut)
          // Ayarlar butonu üç nokta menüsüne taşındı
          PopupMenuButton<String>(
            tooltip: 'Diğer',
            onSelected: (v) {
              if (v == 'settings') _goSettings();
              if (v == 'logout') _logout();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 12),
                    Text('Ayarlar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded),
                    SizedBox(width: 12),
                    Text('Çıkış Yap'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTap,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final t in tabs)
                  NavigationRailDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.selectedIcon ?? t.icon),
                    label: Text(t.label),
                  ),
              ],
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: tabs[_currentIndex].builder(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTap,
              items: [
                for (final t in tabs)
                  BottomNavigationBarItem(
                    icon: Icon(t.icon),
                    activeIcon: Icon(t.selectedIcon ?? t.icon),
                    label: t.label,
                  ),
              ],
            ),
      floatingActionButton: tabs[_currentIndex].showFab
          ? FloatingActionButton.extended(
              onPressed: _goCreateReport,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Bildirim'),
            )
          : null,
    );
  }

  String _appBarTitle(List<_TabItem> tabs) => tabs[_currentIndex].label;

  List<_TabItem> _buildTabsByRole(String role) {
    // final isCitizen = role == 'VATANDAS'; // kullanılmıyordu, kaldırıldı
    final isTeam = role == 'EKIP';
    final isOperator = role == 'OPERATOR';
    final isAdmin = role == 'ADMIN';

    final all = <_TabItem>[
      _TabItem(
        label: 'Akış',
        icon: Icons.dynamic_feed_outlined,
        selectedIcon: Icons.dynamic_feed,
        builder: (_) => const FeedView(),
        showFab: true,
      ),
      _TabItem(
        label: 'Görevler',
        icon: Icons.task_alt_outlined,
        selectedIcon: Icons.task_alt,
        builder: (_) => const TasksView(),
        visible: isTeam || isOperator || isAdmin,
      ),
      _TabItem(
        label: 'Kategoriler',
        icon: Icons.category_outlined,
        selectedIcon: Icons.category,
        builder: (_) => const CategoriesView(),
      ),
      _TabItem(
        label: 'Ekipler',
        icon: Icons.groups_2_outlined,
        selectedIcon: Icons.groups_2,
        builder: (_) => const TeamsView(),
        visible: isTeam || isOperator || isAdmin,
      ),
      _TabItem(
        label: 'Profil',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        builder: (_) => const ProfileView(),
      ),
    ];

    final filtered = all.where((e) => e.visible).toList();
    if (_currentIndex >= filtered.length) {
      _currentIndex = 0;
    }
    return filtered;
  }
}

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.builder,
    this.selectedIcon,
    this.visible = true,
    this.showFab = false,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final bool visible;
  final bool showFab;
  final WidgetBuilder builder;
}

// Aşağıdaki geçici sekme widget'ları kaldırıldı:
// class _TasksTab extends StatelessWidget {
//   const _TasksTab();
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: 10,
//       separatorBuilder: (_, __) => const SizedBox(height: 8),
//       itemBuilder: (context, index) {
//         return Card(
//           child: ListTile(
//             leading: const Icon(Icons.check_circle_outline_rounded),
//             title: Text('Görev #${index + 1}'),
//             subtitle: const Text('Durum: Bekliyor'),
//             trailing: const Icon(Icons.chevron_right_rounded),
//             onTap: () {},
//           ),
//         );
//       },
//     );
//   }
// }
// class _TeamsTab extends StatelessWidget {
//   const _TeamsTab();
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       itemCount: 8,
//       separatorBuilder: (_, __) => const SizedBox(height: 8),
//       itemBuilder: (context, index) {
//         return Card(
//           child: ListTile(
//             leading: const Icon(Icons.group_outlined),
//             title: Text('Ekip #${index + 1}'),
//             subtitle: const Text('Üye sayısı: 5'),
//             trailing: const Icon(Icons.chevron_right_rounded),
//             onTap: () {},
//           ),
//         );
//       },
//     );
//   }
// }
// class _ProfileTab extends StatelessWidget {
//   const _ProfileTab();
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
//           const SizedBox(height: 12),
//           Text('Profil', style: Theme.of(context).textTheme.titleLarge),
//           const SizedBox(height: 8),
//           const Text('Profil bilgileri yakında burada olacak.'),
//         ],
//       ),
//     );
//   }
// }