import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewmodels/auth/auth_view_model.dart';
import '../../core/widgets/premium_image.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await context.read<AuthCubit>().register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted || !success) {
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _continueWithGoogle() async {
    final success = await context.read<AuthCubit>().signInWithGoogle();
    if (!mounted || !success) {
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF9F4EA), Color(0xFFEAF2EF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 880;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Padding(
                      padding: EdgeInsets.all(wide ? 32 : 20),
                      child: wide
                          ? Row(
                              children: [
                                const Expanded(
                                  flex: 5,
                                  child: _AuthImagePanel(
                                    titleKey: 'auth.register_visual_title',
                                    subtitleKey:
                                        'auth.register_visual_subtitle',
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 4,
                                  child: _RegisterFormCard(
                                    theme: theme,
                                    formKey: _formKey,
                                    nameController: _nameController,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    obscurePassword: _obscurePassword,
                                    onTogglePassword: _togglePassword,
                                    onSubmit: _submit,
                                    onGoogle: _continueWithGoogle,
                                  ),
                                ),
                              ],
                            )
                          : ListView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _MobileHeader(
                                  title: 'auth.register_title'.tr(),
                                  subtitle: 'auth.register_subtitle'.tr(),
                                ),
                                const SizedBox(height: 18),
                                _RegisterFormCard(
                                  theme: theme,
                                  formKey: _formKey,
                                  nameController: _nameController,
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  obscurePassword: _obscurePassword,
                                  onTogglePassword: _togglePassword,
                                  onSubmit: _submit,
                                  onGoogle: _continueWithGoogle,
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
}

class _RegisterFormCard extends StatelessWidget {
  const _RegisterFormCard({
    required this.theme,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onGoogle,
  });

  final ThemeData theme;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackButtonRow(title: 'auth.create_account'.tr()),
            const SizedBox(height: 22),
            Text(
              'auth.register_title'.tr(),
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              'auth.register_subtitle'.tr(),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6A6054),
                fontWeight: FontWeight.w500,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 24),
            _AuthTextField(
              controller: nameController,
              label: 'auth.full_name'.tr(),
              hint: 'Nile Explorer',
              icon: Icons.person_outline_rounded,
              validator: (value) {
                if ((value ?? '').trim().length < 2) {
                  return 'auth.invalid_name'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _AuthTextField(
              controller: emailController,
              label: 'auth.email'.tr(),
              hint: 'name@example.com',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty || !text.contains('@')) {
                  return 'auth.invalid_email'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _AuthTextField(
              controller: passwordController,
              label: 'auth.password'.tr(),
              hint: '********',
              icon: Icons.lock_outline_rounded,
              obscureText: obscurePassword,
              validator: (value) {
                if ((value ?? '').trim().length < 6) {
                  return 'auth.invalid_password'.tr();
                }
                return null;
              },
              suffixIcon: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : onSubmit,
                child: Text(
                  authState.isLoading
                      ? 'auth.creating_account'.tr()
                      : 'auth.create_account'.tr(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: authState.isLoading ? null : onGoogle,
                icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                label: Text('auth.continue_with_google'.tr()),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('auth.have_account'.tr()),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                    child: Text('auth.sign_in'.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthImagePanel extends StatelessWidget {
  const _AuthImagePanel({required this.titleKey, required this.subtitleKey});

  final String titleKey;
  final String subtitleKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const PremiumImage(
            imageUrl:
                'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?auto=format&fit=crop&w=1300&q=80',
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  const Color(0xFF071D24).withValues(alpha: 0.86),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFF1F1A14),
                  ),
                ),
                const Spacer(),
                Text(
                  titleKey.tr(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 38,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitleKey.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton.filledTonal(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(height: 22),
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF6A6054),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BackButtonRow extends StatelessWidget {
  const _BackButtonRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 10),
        Text(title, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8F4EC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
        ),
      ),
    );
  }
}
