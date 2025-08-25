import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../product/navigation/app_router.dart';
import '../../../product/service/auth/auth_service.dart';
import '../../feed/view/feed_view.dart';
import '../../categories/view/categories_view.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _authService = GetIt.I<IAuthService>();
  int _currentIndex = 0;
  bool _loadingUser = true;
  String _role = 'VATANDAS';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final me = await _authService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _role = me.data?.role ?? 'VATANDAS';
        _loadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingUser = false);
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
    await _authService.logout();
    if (mounted) {
      context.router.replaceAll([const LoginViewRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tabs = _buildTabsByRole(_role);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(tabs)),
        actions: [
          IconButton(
            tooltip: 'Yeni Bildirim',
            onPressed: _goCreateReport,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          IconButton(
            tooltip: 'Ayarlar',
            onPressed: _goSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: 'Diğer',
            onSelected: (v) {
              if (v == 'logout') _logout();
            },
            itemBuilder: (context) => [
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goCreateReport,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Bildirim'),
      ),
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
      ),
      _TabItem(
        label: 'Görevler',
        icon: Icons.task_alt_outlined,
        selectedIcon: Icons.task_alt,
        builder: (_) => const _TasksTab(),
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
        builder: (_) => const _TeamsTab(),
        visible: isTeam || isOperator || isAdmin,
      ),
      _TabItem(
        label: 'Profil',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        builder: (_) => const _ProfileTab(),
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
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final bool visible;
  final WidgetBuilder builder;
}

class _TasksTab extends StatelessWidget {
  const _TasksTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.check_circle_outline_rounded),
            title: Text('Görev #${index + 1}'),
            subtitle: const Text('Durum: Bekliyor'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        );
      },
    );
  }
}

class _TeamsTab extends StatelessWidget {
  const _TeamsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.group_outlined),
            title: Text('Ekip #${index + 1}'),
            subtitle: const Text('Üye sayısı: 5'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
          const SizedBox(height: 12),
          Text('Profil', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Profil bilgileri yakında burada olacak.'),
        ],
      ),
    );
  }
}