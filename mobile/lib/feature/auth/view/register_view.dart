import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/navigation/app_router.dart';
import '../../../product/widgets/snackbar.dart';
import '../../../product/widgets/enhanced_form_validation.dart';
import '../view_model/register_cubit.dart';
import '../view_model/register_state.dart';

@RoutePage()
class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: const _RegisterViewBody(),
    );
  }
}

class _RegisterViewBody extends StatefulWidget {
  const _RegisterViewBody();

  @override
  State<_RegisterViewBody> createState() => _RegisterViewBodyState();
}

class _RegisterViewBodyState extends State<_RegisterViewBody> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateConfirm(String? value) {
    return FormValidators.validateConfirmPassword(value, _passwordController.text);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    context.read<RegisterCubit>().register(
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          context.showSnack('Kayıt başarılı! Lütfen giriş yapın.', type: SnackbarType.success);
          context.router.replace(const LoginViewRoute());
        } else if (state is RegisterFailure) {
          context.showSnack(state.message, type: SnackbarType.error);
        } else if (state is RegisterValidationError) {
          setFieldError('email', state.emailError);
          setFieldError('username', state.usernameError);
          setFieldError('password', state.passwordError);
          setFieldError('confirmPassword', state.confirmPasswordError);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Kayıt Ol')),
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
                          'Yeni hesap oluşturun',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        BlocSelector<RegisterCubit, RegisterState, String?>(
                          selector: (state) => state is RegisterValidationError ? state.emailError : null,
                          builder: (context, emailError) {
                            return EnhancedTextFormField(
                              controller: _emailController,
                              labelText: 'E-posta',
                              prefixIcon: const Icon(Icons.alternate_email_rounded),
                              keyboardType: TextInputType.emailAddress,
                              validator: FormValidators.validateEmail,
                              autofillHints: const [AutofillHints.email],
                              showRealTimeValidation: true,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        BlocSelector<RegisterCubit, RegisterState, String?>(
                          selector: (state) => state is RegisterValidationError ? state.usernameError : null,
                          builder: (context, usernameError) {
                            return EnhancedTextFormField(
                              controller: _usernameController,
                              labelText: 'Kullanıcı Adı',
                              prefixIcon: const Icon(Icons.person_rounded),
                              validator: FormValidators.validateUsername,
                              autofillHints: const [AutofillHints.username],
                              showRealTimeValidation: true,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        BlocSelector<RegisterCubit, RegisterState, String?>(
                          selector: (state) => state is RegisterValidationError ? state.passwordError : null,
                          builder: (context, passwordError) {
                            return EnhancedTextFormField(
                              controller: _passwordController,
                              labelText: 'Şifre',
                              prefixIcon: const Icon(Icons.lock_rounded),
                              obscureText: _obscure1,
                              suffixIcon: IconButton(
                                tooltip: _obscure1 ? 'Şifreyi göster' : 'Şifreyi gizle',
                                icon: Icon(_obscure1 ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                                onPressed: () => setState(() => _obscure1 = !_obscure1),
                              ),
                              validator: (value) => FormValidators.validatePassword(value, requireStrong: true),
                              autofillHints: const [AutofillHints.newPassword],
                              showRealTimeValidation: true,
                              showPasswordStrength: true,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        BlocSelector<RegisterCubit, RegisterState, String?>(
                          selector: (state) => state is RegisterValidationError ? state.confirmPasswordError : null,
                          builder: (context, confirmPasswordError) {
                            return EnhancedTextFormField(
                              controller: _confirmController,
                              labelText: 'Şifre (Tekrar)',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              obscureText: _obscure2,
                              suffixIcon: IconButton(
                                tooltip: _obscure2 ? 'Şifreyi göster' : 'Şifreyi gizle',
                                icon: Icon(_obscure2 ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                                onPressed: () => setState(() => _obscure2 = !_obscure2),
                              ),
                              validator: _validateConfirm,
                              autofillHints: const [AutofillHints.password],
                              showRealTimeValidation: true,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        BlocSelector<RegisterCubit, RegisterState, bool>(
                          selector: (state) => state is RegisterLoading,
                          builder: (context, isLoading) {
                            return SizedBox(
                              height: 48,
                              child: FilledButton.icon(
                                onPressed: isLoading ? null : _submit,
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.person_add_rounded),
                                label: Text(isLoading ? 'Kayıt yapılıyor...' : 'Kayıt Ol'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Zaten hesabınız var mı? ',
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => context.router.replace(const LoginViewRoute()),
                              child: const Text('Giriş yapın'),
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