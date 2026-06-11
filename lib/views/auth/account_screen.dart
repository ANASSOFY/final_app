import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodels/auth/auth_view_model.dart';
import 'auth_landing_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('auth.account'.tr()),
      ),
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final horizontalPadding =
                MediaQuery.sizeOf(context).width >= 700 ? 24.0 : 16.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                24,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF153F4A),
                        Color(0xFFD4AF37),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        child: Text(
                          state.resolvedName.isNotEmpty
                              ? state.resolvedName.substring(0, 1).toUpperCase()
                              : 'E',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.resolvedName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              state.email ??
                                  (state.isGuest
                                      ? 'auth.guest_badge'.tr()
                                      : 'auth.not_signed_in'.tr()),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.84),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (state.status == AuthStatus.unauthenticated)
                  _SignedOutSection(theme: theme),
                if (state.isGuest) _GuestSection(theme: theme),
                if (state.isAuthenticated) _SignedInSection(theme: theme),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SignedOutSection extends StatelessWidget {
  const _SignedOutSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('auth.account_prompt'.tr(), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'auth.account_prompt_subtitle'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                );
              },
              child: Text('auth.sign_in'.tr()),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RegisterScreen(),
                  ),
                );
              },
              child: Text('auth.create_account'.tr()),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().continueAsGuest();
            },
            child: Text('auth.continue_as_guest'.tr()),
          ),
        ],
      ),
    );
  }
}

class _GuestSection extends StatelessWidget {
  const _GuestSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('auth.guest_mode'.tr(), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'auth.guest_mode_subtitle'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RegisterScreen(),
                  ),
                );
              },
              child: Text('auth.upgrade_account'.tr()),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
            child: Text('auth.leave_guest_mode'.tr()),
          ),
        ],
      ),
    );
  }
}

class _SignedInSection extends StatelessWidget {
  const _SignedInSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('auth.account_ready'.tr(), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'auth.account_ready_subtitle'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthCubit>().signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const AuthLandingScreen(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: Text('auth.sign_out'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
