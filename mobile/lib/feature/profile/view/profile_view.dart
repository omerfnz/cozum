import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../product/navigation/app_router.dart';
import '../../../product/service/auth/auth_service.dart';
import '../../../product/widgets/enhanced_shimmer.dart';
import '../view_model/profile_cubit.dart';
import '../view_model/profile_state.dart';

@RoutePage()
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(GetIt.I<IAuthService>())..load(),
      child: const _ProfileViewBody(),
    );
  }
}

class _ProfileViewBody extends StatelessWidget {
  const _ProfileViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() => const _ProfileShimmer(),
              ProfileLoading() => const _ProfileShimmer(),
              ProfileError(:final message) => _ErrorView(
                  message: message,
                  onRetry: () => context.read<ProfileCubit>().load(),
                ),
              ProfileLoaded(:final user) => _ProfileContent(user: user),
              _ => const _ProfileShimmer(),
            };
          },
        ),
      ),
    );
  }

}


class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().load(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final avatarRadius = _avatarRadiusForWidth(maxW);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        _initials(user),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: (avatarRadius * 0.9).clamp(18, 42),
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _displayName(user),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _roleDisplay(user.role),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    if (user.email.isNotEmpty)
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildProfileMenuItem(
                context,
                icon: Icons.person_outline,
                title: 'Kişisel Bilgiler',
                onTap: () {
                  context.router.push(const SettingsViewRoute());
                },
              ),
              // Admin Dashboard - sadece admin kullanıcılar için
              if (user.role == 'ADMIN')
                _buildProfileMenuItem(
                  context,
                  icon: Icons.admin_panel_settings,
                  title: 'Admin Dashboard',
                  onTap: () {
                    context.router.push(const AdminDashboardViewRoute());
                  },
                ),
              _buildProfileMenuItem(
                context,
                icon: Icons.notifications_outlined,
                title: 'Bildirim Ayarları',
                onTap: () {
                  context.router.push(const SettingsViewRoute());
                },
              ),
              _buildProfileMenuItem(
                context,
                icon: Icons.history,
                title: 'Geçmiş Bildiriler',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yakında eklenecek.')),
                  );
                },
              ),
              _buildProfileMenuItem(
                context,
                icon: Icons.help_outline,
                title: 'Yardım & Destek',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const _HelpDialog(),
                  );
                },
              ),
              _buildProfileMenuItem(
                context,
                icon: Icons.logout_rounded,
                title: 'Çıkış Yap',
                onTap: () => context.read<ProfileCubit>().logout(context.router),
              ),
              const SizedBox(height: 12),
              _InfoCard(user: user),
            ],
          );
        },
      ),
    );
  }

  double _avatarRadiusForWidth(double w) {
    if (w >= 1000) return 70;
    if (w >= 700) return 60;
    if (w >= 400) return 50;
    return 42;
  }

  String _initials(User u) {
    final base = _displayName(u).trim().isEmpty ? u.username : _displayName(u);
    final parts = base.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  String _displayName(User u) {
    final hasName = (u.firstName?.isNotEmpty ?? false) || (u.lastName?.isNotEmpty ?? false);
    if (hasName) {
      final fn = u.firstName?.trim() ?? '';
      final ln = u.lastName?.trim() ?? '';
      return '$fn $ln'.trim();
    }
    return u.username;
  }

  String _roleDisplay(String role) {
    switch (role) {
      case 'ADMIN':
        return 'Admin';
      case 'OPERATOR':
        return 'Operatör';
      case 'EKIP':
        return 'Saha Ekibi';
      case 'VATANDAS':
      default:
        return 'Vatandaş';
    }
  }

  Widget _buildProfileMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hesap Bilgileri', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _row(context, 'Kullanıcı Adı', user.username),
            _row(context, 'E-posta', user.email),
            _row(context, 'Rol', _roleDisplay(user.role)),
            if (user.team != null) _row(context, 'Takım', (user.team?['name'] as String?) ?? '—'),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  String _roleDisplay(String role) {
    switch (role) {
      case 'ADMIN':
        return 'Admin';
      case 'OPERATOR':
        return 'Operatör';
      case 'EKIP':
        return 'Saha Ekibi';
      case 'VATANDAS':
      default:
        return 'Vatandaş';
    }
  }
}

class _HelpDialog extends StatelessWidget {
  const _HelpDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yardım & Destek'),
      content: const Text('Destek için lütfen admin ile iletişime geçin veya uygulama mağazasındaki destek adresini kullanın.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Kapat')),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
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

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return const ProfileShimmer(
      hasStats: true,
      menuItemsCount: 6,
    );
  }
}