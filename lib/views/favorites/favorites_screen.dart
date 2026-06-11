import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewmodels/auth/auth_view_model.dart';
import '../../viewmodels/favorites/favorites_view_model.dart';
import '../../viewmodels/favorites/favorites_event.dart';
import '../../viewmodels/favorites/favorites_state.dart';
import '../../data/models/place_model.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../details/details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text('navigation.favorites'.tr())),
      body: SafeArea(
        child: authState.isGuest
            ? _FavoritesAuthPrompt(theme: theme)
            : BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  if (state is FavoritesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is FavoritesFailure) {
                    return _FavoritesError(message: state.message);
                  }

                  final favorites = state is FavoritesLoaded
                      ? state.favorites
                      : const <Place>[];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth >= 700;
                      final horizontalPadding = isTablet ? 24.0 : 16.0;

                      if (favorites.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'favorites.empty'.tr(),
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (isTablet) {
                        return GridView.builder(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            12,
                            horizontalPadding,
                            24,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 160,
                              ),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final place = favorites[index];
                            return _FavoriteTile(place: place);
                          },
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          12,
                          horizontalPadding,
                          24,
                        ),
                        itemCount: favorites.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final place = favorites[index];
                          return _FavoriteTile(place: place);
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _FavoritesError extends StatelessWidget {
  const _FavoritesError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: Color(0xFFB86A4F),
            ),
            const SizedBox(height: 12),
            Text(
              'favorites.error_title'.tr(),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                final uid = context.read<AuthCubit>().state.uid;
                context.read<FavoritesBloc>().add(LoadFavorites(userId: uid));
              },
              child: Text('favorites.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesAuthPrompt extends StatelessWidget {
  const _FavoritesAuthPrompt({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 32,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'auth.favorites_lock_title'.tr(),
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'auth.favorites_lock_subtitle'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetailsScreen(place: place),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.localizedName(context.locale.languageCode),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_cityKey(place.city).tr()} - ${_categoryKey(place.category).tr()}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<FavoritesBloc>().add(RemoveFavorite(place));
                },
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _cityKey(String city) {
  return switch (city) {
    'Giza' => 'cities.giza',
    'Cairo' => 'cities.cairo',
    'Alexandria' => 'cities.alexandria',
    'Luxor' => 'cities.luxor',
    'Aswan' => 'cities.aswan',
    'Hurghada' => 'cities.hurghada',
    _ => 'cities.cairo',
  };
}

String _categoryKey(String category) {
  return switch (category) {
    'Temples' => 'categories.temples',
    'Museums' => 'categories.museums',
    'Beaches' => 'categories.beaches',
    'Bazaars' => 'categories.bazaars',
    _ => 'categories.temples',
  };
}
