import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../product/navigation/app_router.dart';
import '../../../product/service/auth/auth_service.dart';
import '../../../product/theme/theme_constants.dart';
import '../../../product/theme/theme_selector.dart';

@RoutePage()
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;

  Future<void> _logout() async {
    try {
      await GetIt.I<IAuthService>().logout();
    } catch (_) {}
    if (!mounted) return;
    context.router.replaceAll([const LoginViewRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: AppPadding.page,
        children: [
          // Tema bölümü
          Text(
            'Görünüm',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.sm),
          const Card(
            child: Padding(
              padding: AppPadding.card,
              child: ThemeSelector(isExpanded: true, showLabels: true),
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // Bildirimler
          Text(
            'Bildirimler',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.sm),
          Card(
            child: Padding(
              padding: AppPadding.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    value: _pushEnabled,
                    onChanged: (val) => setState(() => _pushEnabled = val),
                    title: const Text('Push bildirimleri'),
                    subtitle: const Text('Uygulama güncellemeleri ve bildirimler'),
                  ),
                  const Divider(height: 0),
                  SwitchListTile(
                    value: _emailEnabled,
                    onChanged: (val) => setState(() => _emailEnabled = val),
                    title: const Text('E-posta bildirimleri'),
                    subtitle: const Text('Özetler ve önemli duyurular'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // Hesap
          Text(
            'Hesap',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.sm),
          Card(
            child: Padding(
              padding: AppPadding.card,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Şifreyi değiştir'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app_rounded),
                    title: const Text('Çıkış yap'),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // Hakkında
          Text(
            'Hakkında',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.sm),
          Card(
            child: Padding(
              padding: AppPadding.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Sürüm: 1.0.0'),
                  SizedBox(height: AppDimensions.xs),
                  Text('Çözüm Var mobil uygulaması')
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}