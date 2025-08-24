import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/widgets/widgets.dart';
import 'package:mobile/feature/auth/cubit/auth_cubit.dart';
import 'package:mobile/feature/auth/cubit/auth_state.dart';
import 'package:mobile/product/navigation/app_router.dart';
import 'package:oktoast/oktoast.dart';

@RoutePage()
/// Kullanıcı kayıt ekranı
final class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: const _RegisterViewBody(),
    );
  }
}

class _RegisterViewBody extends StatefulWidget {
  const _RegisterViewBody();

  @override
  State<_RegisterViewBody> createState() => _RegisterViewBodyState();
}

class _RegisterViewBodyState extends State<_RegisterViewBody> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Kayıt olur, başarılı ise otomatik giriş yapar ve Home'a yönlendirir
  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    context.read<AuthCubit>().register(
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      passwordConfirm: _passwordConfirmController.text,
      firstName: _nameController.text.isEmpty ? null : _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.error != null) {
          showToast('Kayıt hatası: ${state.error}');
        } else if (state.user != null && !state.isLoading) {
          showToast('Kayıt ve giriş başarılı');
          context.router.replace(const HomeRoute());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final scheme = Theme.of(context).colorScheme;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.person_add_alt_1_outlined, size: 56, color: scheme.primary),
                        const SizedBox(height: 12),
                        Text(
                          'Hesap oluştur',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kaydol ve hemen kullanmaya başla',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: 24),
                        if (state.error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.error!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (state.error != null) const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Ad (opsiyonel)',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'Email zorunlu';
                            if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value)) {
                              return 'Geçerli bir email girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Kullanıcı adı',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'Kullanıcı adı zorunlu';
                            if (value.length < 3) return 'En az 3 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (v) {
                            final value = v ?? '';
                            if (value.isEmpty) return 'Şifre zorunlu';
                            if (value.length < 8) return 'En az 8 karakter';
                            // Django NumericPasswordValidator: sadece rakam olamaz
                            if (RegExp(r'^\d+').hasMatch(value)) return 'Şifre sadece rakamlardan oluşamaz';
                            // En az bir harf ve bir rakam içersin (temel karmaşıklık)
                            final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
                            final hasDigit = RegExp(r'\d').hasMatch(value);
                            if (!hasLetter || !hasDigit) return 'Şifre en az bir harf ve bir rakam içermeli';
                            // E-posta/kullanıcı adıyla aşırı benzer olmasın (yaklaşık kontrol)
                            final email = _emailController.text.trim().toLowerCase();
                            final username = _usernameController.text.trim().toLowerCase();
                            final pw = value.toLowerCase();
                            final emailLocal = email.contains('@') ? email.split('@').first : email;
                            if (emailLocal.isNotEmpty && pw.contains(emailLocal)) {
                              return 'Şifre e-posta ile çok benzer';
                            }
                            if (username.isNotEmpty && pw.contains(username)) {
                              return 'Şifre kullanıcı adı ile çok benzer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordConfirmController,
                          decoration: const InputDecoration(
                            labelText: 'Şifre (tekrar)',
                            prefixIcon: Icon(Icons.lock_reset_outlined),
                          ),
                          obscureText: true,
                          validator: (v) {
                            final value = v ?? '';
                            if (value.isEmpty) return 'Şifre tekrarı zorunlu';
                            if (value != _passwordController.text) return 'Şifreler uyuşmuyor';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: state.isLoading ? null : _onRegister,
                          icon: state.isLoading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: ButtonLoadingWidget(),
                                )
                              : const Icon(Icons.person_add_outlined),
                          label: Text(state.isLoading ? 'Kayıt yapılıyor...' : 'Kayıt ol'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  await context.router.replace(const LoginRoute());
                                },
                          child: const Text('Zaten hesabın var mı? Giriş yap'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}