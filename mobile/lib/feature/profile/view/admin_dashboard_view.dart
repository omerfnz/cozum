import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../product/constants/api_endpoints.dart';
import '../../../product/models/user.dart' as user_model;
import '../../../product/models/user.dart' show Team;
import '../../../product/models/report.dart';
import '../../../product/service/network/network_service.dart';
import '../../../product/widgets/enhanced_shimmer.dart';

@RoutePage()
class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> with TickerProviderStateMixin {
  final _net = GetIt.I<INetworkService>();
  
  late TabController _tabController;
  
  bool _loading = true;
  String? _error;
  
  // Dashboard stats
  int _totalUsers = 0;
  int _totalReports = 0;
  int _pendingReports = 0;
  int _activeTeams = 0;
  
  // Recent data
  List<user_model.User> _recentUsers = [];
  List<Report> _recentReports = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDashboardData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      // Load dashboard statistics and recent data
      await Future.wait([
        _loadUsers(),
        _loadReports(),
        _loadTeams(),
      ]);
      
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }
  
  Future<void> _loadUsers() async {
    final response = await _net.request<List<user_model.User>>(
      path: ApiEndpoints.users,
      type: RequestType.get,
      parser: (json) => (json as List).map((e) => user_model.User.fromJson(e)).toList(),
    );
    
    if (response.isSuccess && response.data != null) {
      final users = response.data!;
      _totalUsers = users.length;
      _recentUsers = users.take(5).toList();
    }
  }
  
  Future<void> _loadReports() async {
    final response = await _net.request<List<Report>>(
      path: ApiEndpoints.reports,
      type: RequestType.get,
      parser: (json) => (json as List).map((e) => Report.fromJson(e)).toList(),
    );
    
    if (response.isSuccess && response.data != null) {
      final reports = response.data!;
      _totalReports = reports.length;
      _pendingReports = reports.where((r) => r.status == ReportStatus.beklemede).length;
      _recentReports = reports.take(5).toList();
    }
  }
  
  Future<void> _loadTeams() async {
    final response = await _net.request<List<Team>>(
      path: ApiEndpoints.teams,
      type: RequestType.get,
      parser: (json) => (json as List).map((e) => Team.fromJson(e)).toList(),
    );
    
    if (response.isSuccess && response.data != null) {
      final teams = response.data!;
      _activeTeams = teams.length;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Genel Bakış'),
            Tab(icon: Icon(Icons.people_outline), text: 'Kullanıcılar'),
            Tab(icon: Icon(Icons.report_outlined), text: 'Raporlar'),
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Analitik'),
          ],
        ),
      ),
      body: _loading
          ? const _DashboardShimmer()
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _loadDashboardData)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(
                      totalUsers: _totalUsers,
                      totalReports: _totalReports,
                      pendingReports: _pendingReports,
                      activeTeams: _activeTeams,
                      recentUsers: _recentUsers,
                      recentReports: _recentReports,
                    ),
                    _UsersTab(users: _recentUsers),
                    _ReportsTab(reports: _recentReports),
                    const _AnalyticsTab(),
                  ],
                ),
    );
  }
}

// Overview Tab Widget
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.totalUsers,
    required this.totalReports,
    required this.pendingReports,
    required this.activeTeams,
    required this.recentUsers,
    required this.recentReports,
  });
  
  final int totalUsers;
  final int totalReports;
  final int pendingReports;
  final int activeTeams;
  final List<user_model.User> recentUsers;
  final List<Report> recentReports;
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                title: 'Toplam Kullanıcı',
                value: totalUsers.toString(),
                icon: Icons.people_outline,
                color: Colors.blue,
              ),
              _StatCard(
                title: 'Toplam Rapor',
                value: totalReports.toString(),
                icon: Icons.report_outlined,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Bekleyen Raporlar',
                value: pendingReports.toString(),
                icon: Icons.pending_outlined,
                color: Colors.orange,
              ),
              _StatCard(
                title: 'Aktif Ekipler',
                value: activeTeams.toString(),
                icon: Icons.groups_outlined,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Recent Users Section
          Text(
            'Son Kayıt Olan Kullanıcılar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentUsers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = recentUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.username[0].toUpperCase()),
                  ),
                  title: Text(user.username),
                  subtitle: Text(user.email),
                  trailing: Chip(
                    label: Text(user.role.value),
                    backgroundColor: _getRoleColor(user.role),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Recent Reports Section
          Text(
            'Son Raporlar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentReports.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final report = recentReports[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(report.status),
                    child: Icon(
                      Icons.report_outlined,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    report.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(report.category.name),
                  trailing: Text(
                    report.formattedDate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getRoleColor(user_model.UserRole role) {
    switch (role) {
      case user_model.UserRole.admin:
        return Colors.red.shade100;
      case user_model.UserRole.operator:
        return Colors.blue.shade100;
      case user_model.UserRole.ekip:
        return Colors.green.shade100;
      case user_model.UserRole.vatandas:
        return Colors.grey.shade100;
    }
  }
  
  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.beklemede:
        return Colors.orange;
      case ReportStatus.inceleniyor:
        return Colors.blue;
      case ReportStatus.cozuldu:
        return Colors.green;
      case ReportStatus.reddedildi:
        return Colors.red;
    }
  }
}

// Statistics Card Widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Users Tab Widget
class _UsersTab extends StatelessWidget {
  const _UsersTab({required this.users});
  
  final List<user_model.User> users;
  
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.username[0].toUpperCase()),
            ),
            title: Text(user.username),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                if (user.team != null)
                  Text('Ekip: ${user.team!.name}'),
              ],
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(user.role.value),
                  backgroundColor: _getRoleColor(user.role),
                ),
                if (!user.isActive)
                  const Icon(Icons.block, color: Colors.red, size: 16),
              ],
            ),
            onTap: () {
              // TODO: Navigate to user detail
            },
          ),
        );
      },
    );
  }
  
  Color _getRoleColor(user_model.UserRole role) {
    switch (role) {
      case user_model.UserRole.admin:
        return Colors.red.shade100;
      case user_model.UserRole.operator:
        return Colors.blue.shade100;
      case user_model.UserRole.ekip:
        return Colors.green.shade100;
      case user_model.UserRole.vatandas:
        return Colors.grey.shade100;
    }
  }
}

// Reports Tab Widget
class _ReportsTab extends StatelessWidget {
  const _ReportsTab({required this.reports});
  
  final List<Report> reports;
  
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(report.status),
              child: const Icon(Icons.report_outlined, color: Colors.white),
            ),
            title: Text(
              report.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kategori: ${report.category.name}'),
                Text('Rapor Eden: ${report.reporter.username}'),
                if (report.assignedTeam != null)
                  Text('Atanan Ekip: ${report.assignedTeam!.name}'),
              ],
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                   label: Text(report.status.displayName),
                   backgroundColor: _getStatusColor(report.status).withValues(alpha: 0.2),
                 ),
                Text(
                  report.formattedDate,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            onTap: () {
              // TODO: Navigate to report detail
            },
          ),
        );
      },
    );
  }
  
  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.beklemede:
        return Colors.orange;
      case ReportStatus.inceleniyor:
        return Colors.blue;
      case ReportStatus.cozuldu:
        return Colors.green;
      case ReportStatus.reddedildi:
        return Colors.red;
    }
  }
}

// Analytics Tab Widget
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Analitik Özellikleri',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Grafik ve istatistikler burada gösterilecek',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Dashboard Shimmer Widget
class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats grid shimmer
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: List.generate(
              4,
              (index) => const EnhancedShimmer(
                 animationType: ShimmerAnimationType.pulse,
                 intensity: ShimmerIntensity.medium,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShimmerCircle(size: 32),
                        SizedBox(height: 8),
                        ShimmerLine(width: 60, height: 24),
                        SizedBox(height: 4),
                        ShimmerLine(width: 80, height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // List shimmer
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: EnhancedShimmer(
                 animationType: ShimmerAnimationType.pulse,
                 intensity: ShimmerIntensity.medium,
                child: Card(
                  child: ListTile(
                    leading: const ShimmerCircle(size: 40),
                    title: const ShimmerLine(width: 150, height: 16),
                    subtitle: const ShimmerLine(width: 100, height: 12),
                    trailing: const ShimmerBox(
                      width: 60,
                      height: 24,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Error View Widget
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
  });
  
  final String error;
  final VoidCallback onRetry;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Hata Oluştu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}