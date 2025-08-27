import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/navigation/app_router.dart';
import '../../../product/widgets/snackbar.dart';
import '../view_model/login_cubit.dart';
import '../view_model/login_state.dart';

@RoutePage()
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: const _LoginViewBody(),
    );
  }
}

class _LoginViewBody extends StatefulWidget {
  const _LoginViewBody();

  @override
  State<_LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<_LoginViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    context.read<LoginCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.showSnack('Hoş geldiniz!', type: SnackbarType.success);
          context.router.replaceAll([const HomeViewRoute()]);
        } else if (state is LoginFailure) {
          context.showSnack(state.message, type: SnackbarType.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Giriş Yap')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Çözüm Var',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hesabınıza giriş yapın',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        BlocSelector<LoginCubit, LoginState, String?>(
                          selector: (state) => state is LoginValidationError ? state.emailError : null,
                          builder: (context, emailError) {
                            return TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'E-posta',
                                prefixIcon: const Icon(Icons.alternate_email_rounded),
                                errorText: emailError,
                              ),
                              validator: context.read<LoginCubit>().validateEmail,
                              autofillHints: const [AutofillHints.email],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        BlocSelector<LoginCubit, LoginState, String?>(
                          selector: (state) => state is LoginValidationError ? state.passwordError : null,
                          builder: (context, passwordError) {
                            return TextFormField(
                              controller: _passwordController,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Şifre',
                                prefixIcon: const Icon(Icons.lock_rounded),
                                errorText: passwordError,
                                suffixIcon: IconButton(
                                  tooltip: _obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
                                  icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: context.read<LoginCubit>().validatePassword,
                              autofillHints: const [AutofillHints.password],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: BlocSelector<LoginCubit, LoginState, bool>(
                            selector: (state) => state is LoginLoading,
                            builder: (context, isLoading) {
                              return TextButton(
                                onPressed: isLoading ? null : () => context.showSnack('Şifre sıfırlama yakında eklenecek', type: SnackbarType.info),
                                child: const Text('Şifremi Unuttum'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48,
                          child: BlocSelector<LoginCubit, LoginState, bool>(
                            selector: (state) => state is LoginLoading,
                            builder: (context, isLoading) {
                              return ElevatedButton.icon(
                                onPressed: isLoading ? null : _submit,
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(isLoading ? 'Giriş yapılıyor...' : 'Giriş Yap'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Hesabın yok mu?'),
                            BlocSelector<LoginCubit, LoginState, bool>(
                              selector: (state) => state is LoginLoading,
                              builder: (context, isLoading) {
                                return TextButton(
                                  onPressed: isLoading ? null : () => context.router.replace(const RegisterViewRoute()),
                                  child: const Text('Kayıt Ol'),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}