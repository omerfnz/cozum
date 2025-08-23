import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile/product/auth/auth_repository.dart';
import 'package:mobile/product/init/locator.dart';
import 'package:mobile/product/navigation/app_router.dart';
import 'package:oktoast/oktoast.dart';

@RoutePage()
/// Kullanıcı kayıt ekranı
final class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

final class _RegisterViewState extends State<RegisterView> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _parseDioError(DioException e) {
    final res = e.response;
    final data = res?.data;
    if (data is Map<String, dynamic>) {
      // detail alanı öncelikli
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
      // Alan bazlı hata mesajlarını birleştir
      final parts = <String>[];
      data.forEach((key, value) {
        if (value is List) {
          parts.add('${key.toString()}: ${value.join(', ')}');
        } else if (value is String) {
          parts.add('${key.toString()}: $value');
        }
      });
      if (parts.isNotEmpty) return parts.join('\n');
    } else if (data is String) {
      return data;
    }
    return e.message ?? 'Bir hata oluştu';
  }

  /// Kayıt olur, başarılı ise otomatik giriş yapar ve Home'a yönlendirir
  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = di<AuthRepository>();
    final logger = di<Logger>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      logger.i('Kayıt denemesi: email=\\u003c${_emailController.text.trim()}\\u003e, username=\\u003c${_usernameController.text.trim()}\\u003e');
      await repo.register(
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        passwordConfirm: _passwordConfirmController.text,
        firstName: _nameController.text.isEmpty ? null : _nameController.text.trim(),
      );
      showToast('Kayıt başarılı, giriş yapılıyor...');
      await repo.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      showToast('Giriş başarılı');
      logger.i('Kayıt ve giriş başarılı');
      await context.router.replace(const HomeRoute());
    } on DioException catch (e) {
      final msg = _parseDioError(e);
      setState(() => _error = msg);
      showToast('Kayıt başarısız: $msg');
      di<Logger>().e('Kayıt hatası: $msg');
    } on Exception catch (e) {
      final msg = e.toString();
      setState(() => _error = msg);
      showToast('Bir hata oluştu: $msg');
      di<Logger>().e('Kayıt istisnası: $msg');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
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
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  if (_error != null) const SizedBox(height: 12),
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
                    onPressed: _loading ? null : _onRegister,
                    icon: _loading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add_outlined),
                    label: Text(_loading ? 'Kayıt yapılıyor...' : 'Kayıt ol'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            await context.router.replace(const LoginRoute());
                          },
                    child: const Text('Zaten hesabın var mı? Giriş yap'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}