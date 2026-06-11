import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewmodels/auth/auth_view_model.dart';
import '../../core/widgets/premium_image.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthLandingScreen extends StatefulWidget {
  const AuthLandingScreen({super.key});

  @override
  State<AuthLandingScreen> createState() => _AuthLandingScreenState();
}

class _AuthLandingScreenState extends State<AuthLandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      titleKey: 'auth.onboarding_1_title',
      subtitleKey: 'auth.onboarding_1_subtitle',
      stat: '12+',
      statLabelKey: 'auth.onboarding_1_stat',
      imageUrl:
          'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?auto=format&fit=crop&w=1400&q=80',
      icon: Icons.explore_rounded,
    ),
    _OnboardingSlide(
      titleKey: 'auth.onboarding_2_title',
      subtitleKey: 'auth.onboarding_2_subtitle',
      stat: '4.8',
      statLabelKey: 'auth.onboarding_2_stat',
      imageUrl:
          'https://images.unsplash.com/photo-1568322445389-f64ac2515020?auto=format&fit=crop&w=1400&q=80',
      icon: Icons.bookmark_added_rounded,
    ),
    _OnboardingSlide(
      titleKey: 'auth.onboarding_3_title',
      subtitleKey: 'auth.onboarding_3_subtitle',
      stat: '24h',
      statLabelKey: 'auth.onboarding_3_stat',
      imageUrl:
          'https://images.unsplash.com/photo-1539650116574-75c0c6d73f6e?auto=format&fit=crop&w=1400&q=80',
      icon: Icons.route_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
              colors: [
                Color(0xFFF9F4EA),
                Color(0xFFEAF2EF),
                Color(0xFFFFFCF6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final padding = wide ? 32.0 : 20.0;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1160),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: wide
                          ? Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: _OnboardingShowcase(
                                    pageController: _pageController,
                                    currentPage: _currentPage,
                                    slides: _slides,
                                    onPageChanged: _setPage,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 4,
                                  child: _AuthActionPanel(theme: theme),
                                ),
                              ],
                            )
                          : ListView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: 520,
                                  child: _OnboardingShowcase(
                                    pageController: _pageController,
                                    currentPage: _currentPage,
                                    slides: _slides,
                                    onPageChanged: _setPage,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _AuthActionPanel(theme: theme),
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

  void _setPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }
}

class _OnboardingShowcase extends StatelessWidget {
  const _OnboardingShowcase({
    required this.pageController,
    required this.currentPage,
    required this.slides,
    required this.onPageChanged,
  });

  final PageController pageController;
  final int currentPage;
  final List<_OnboardingSlide> slides;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return _SlideView(slide: slides[index]);
            },
          ),
          PositionedDirectional(
            start: 22,
            top: 22,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                'auth.badge'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 22,
            end: 22,
            bottom: 22,
            child: Row(
              children: [
                Expanded(
                  child: _PageDots(
                    count: slides.length,
                    currentPage: currentPage,
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
                    final next = (currentPage + 1) % slides.length;
                    pageController.animateToPage(
                      next,
                      duration: const Duration(milliseconds: 360),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF153F4A),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        PremiumImage(imageUrl: slide.imageUrl, fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.12),
                const Color(0xFF071D24).withValues(alpha: 0.88),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 88, 24, 82),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(slide.icon, color: const Color(0xFF1F1A14)),
              ),
              const SizedBox(height: 18),
              Text(
                slide.titleKey.tr(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                slide.subtitleKey.tr(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              _StatPill(value: slide.stat, label: slide.statLabelKey.tr()),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthActionPanel extends StatelessWidget {
  const _AuthActionPanel({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.68)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandMark(theme: theme),
          const SizedBox(height: 26),
          Text('auth.start_title'.tr(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'auth.start_subtitle'.tr(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF6A6054),
              fontWeight: FontWeight.w500,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: authState.isLoading
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
              icon: const Icon(Icons.lock_open_rounded),
              label: Text('auth.sign_in'.tr()),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: authState.isLoading
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text('auth.create_account'.tr()),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: authState.isLoading
                  ? null
                  : () async {
                      final success = await context
                          .read<AuthCubit>()
                          .signInWithGoogle();
                      if (!context.mounted || !success) {
                        return;
                      }
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
              icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
              label: Text('auth.continue_with_google'.tr()),
            ),
          ),
          const SizedBox(height: 18),
          _GuestStrip(
            isLoading: authState.isLoading,
            onTap: () {
              context.read<AuthCubit>().continueAsGuest();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF153F4A),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.temple_hindu_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('app_title'.tr(), style: theme.textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                'auth.brand_subtitle'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuestStrip extends StatelessWidget {
  const _GuestStrip({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: const Color(0xFFF8F4EC),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.travel_explore_rounded, color: Color(0xFF0E6B68)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'auth.guest_title'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'auth.guest_subtitle'.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.currentPage});

  final int count;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        final selected = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: selected ? 28 : 8,
          height: 8,
          margin: const EdgeInsetsDirectional.only(end: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: selected ? 1 : 0.38),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFD4AF37),
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.titleKey,
    required this.subtitleKey,
    required this.stat,
    required this.statLabelKey,
    required this.imageUrl,
    required this.icon,
  });

  final String titleKey;
  final String subtitleKey;
  final String stat;
  final String statLabelKey;
  final String imageUrl;
  final IconData icon;
}
