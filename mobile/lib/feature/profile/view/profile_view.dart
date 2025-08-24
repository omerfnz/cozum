import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:mobile/core/widgets/widgets.dart';
import 'package:mobile/product/auth/auth_repository.dart';
import 'package:mobile/product/init/locator.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<String, dynamic>? _me;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }
    try {
      final me = await di<AuthRepository>().me();
      if (!mounted) return;
      setState(() {
        _me = me;
        _error = null;
      });
    } catch (e, st) {
      di<Logger>().e('[Profile] me() hata', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _error = 'Profil bilgisi alınamadı';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _loading
          ? const GlobalLoadingWidget(message: 'Profil yükleniyor...')
          : _error != null
              ? GlobalErrorWidget(
                  error: _error!,
                  onRetry: _load,
                )
              : _me == null
                  ? const EmptyStateWidget(
                      message: 'Profil bilgisi bulunamadı',
                      icon: Icons.person_outline,
                    )
                  : _buildProfile(),
    );
  }

  Widget _buildProfile() {
    final me = _me ?? {};
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(me['username'] ?? me['email'] ?? 'Kullanıcı'),
          subtitle: Text(me['email'] ?? ''),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: const Text('Ad Soyad'),
          subtitle: Text('${me['first_name'] ?? ''} ${me['last_name'] ?? ''}'),
        ),
        ListTile(
          leading: const Icon(Icons.admin_panel_settings_outlined),
          title: const Text('Rol'),
          subtitle: Text(me['role_display'] ?? me['role'] ?? ''),
        ),
        if (me['team'] != null)
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text('Takım'),
            subtitle: Text(me['team']['name'] ?? ''),
          ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Yenile'),
        )
      ],
    );
  }
}