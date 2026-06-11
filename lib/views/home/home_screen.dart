import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewmodels/auth/auth_view_model.dart';
import '../../viewmodels/places/places_view_model.dart';
import '../../viewmodels/places/places_event.dart';
import '../../viewmodels/places/places_state.dart';
import '../../data/models/place_model.dart';
import '../../core/widgets/custom_widgets.dart';
import '../../core/widgets/premium_image.dart';
import '../auth/account_screen.dart';
import '../details/details_screen.dart';
import '../explore/explore_screen.dart';
import '../governorates/governorate_details_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_CategoryData> _categories = [
    _CategoryData(
      value: 'Temples',
      titleKey: 'categories.temples',
      icon: Icons.account_balance_rounded,
      color: Color(0xFFD4AF37),
    ),
    _CategoryData(
      value: 'Museums',
      titleKey: 'categories.museums',
      icon: Icons.museum_rounded,
      color: Color(0xFFB86A4F),
    ),
    _CategoryData(
      value: 'Beaches',
      titleKey: 'categories.beaches',
      icon: Icons.waves_rounded,
      color: Color(0xFF2897A5),
    ),
    _CategoryData(
      value: 'Bazaars',
      titleKey: 'categories.bazaars',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF6B4A8E),
    ),
  ];

  static const List<_CityData> _cities = [
    _CityData(
      value: 'Giza',
      nameKey: 'cities.giza',
      subtitleKey: 'cities.giza_subtitle',
      imageUrl:
          'https://images.unsplash.com/photo-1568322445389-f64ac2515020?q=80&w=1954&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      famousForKey: 'governorates.giza.famous_for',
      bestVisitKey: 'governorates.giza.best_visit',
    ),
    _CityData(
      value: 'Cairo',
      nameKey: 'cities.cairo',
      subtitleKey: 'cities.cairo_subtitle',
      imageUrl:
          'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?auto=format&fit=crop&w=900&q=75',
      famousForKey: 'governorates.cairo.famous_for',
      bestVisitKey: 'governorates.cairo.best_visit',
    ),
    _CityData(
      value: 'Alexandria',
      nameKey: 'cities.alexandria',
      subtitleKey: 'cities.alexandria_subtitle',
      imageUrl:
          'https://images.unsplash.com/photo-1652258943679-1516be59461f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8YWxleGFuZHJpYSUyMGVneXB0fGVufDB8fDB8fHww',
      famousForKey: 'governorates.alexandria.famous_for',
      bestVisitKey: 'governorates.alexandria.best_visit',
    ),
    _CityData(
      value: 'Luxor',
      nameKey: 'cities.luxor',
      subtitleKey: 'cities.luxor_subtitle',
      imageUrl:
          'https://images.unsplash.com/photo-1738829235767-83963c09647c?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8bHV4b3IlMjBlZ3lwdHxlbnwwfHwwfHx8MA%3D%3D',
      famousForKey: 'governorates.luxor.famous_for',
      bestVisitKey: 'governorates.luxor.best_visit',
    ),
    _CityData(
      value: 'Aswan',
      nameKey: 'cities.aswan',
      subtitleKey: 'cities.aswan_subtitle',
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1728561809541-1620be0f4004?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTd8fGFzd2FuJTIwZWd5cHR8ZW58MHx8MHx8fDA%3D',
      famousForKey: 'governorates.aswan.famous_for',
      bestVisitKey: 'governorates.aswan.best_visit',
    ),
    _CityData(
      value: 'Hurghada',
      nameKey: 'cities.hurghada',
      subtitleKey: 'cities.hurghada_subtitle',
      imageUrl:
          'https://images.unsplash.com/photo-1730111105840-1b856b5dce60?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8SHVyZ2hhZGElMjBlZ3lwdHxlbnwwfHwwfHx8MA%3D%3D',
      famousForKey: 'governorates.hurghada.famous_for',
      bestVisitKey: 'governorates.hurghada.best_visit',
    ),
    _CityData(
      value: 'fayoum',
      nameKey: 'cities.fayoum',
      subtitleKey: 'cities.fayoum_subtitle',
      imageUrl:
          'https://images.pexels.com/photos/17294256/pexels-photo-17294256.jpeg',
      famousForKey: 'governorates.fayoum.famous_for',
      bestVisitKey: 'governorates.fayoum.best_visit',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 390 ? 16.0 : 20.0;
    final authState = context.watch<AuthCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        actions: [
          _ActionButton(
            icon: Icons.language_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ActionButton(
              icon: authState.isAuthenticated
                  ? Icons.verified_user_outlined
                  : authState.isGuest
                  ? Icons.travel_explore_rounded
                  : Icons.person_outline_rounded,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AccountScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            8,
            horizontalPadding,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StaggeredFadeIn(index: 0, child: _HeroBanner(authState: authState)),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'home.categories'.tr(),
                actionLabel: 'home.see_all'.tr(),
                onTap: () => _openExplore(context),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 128,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return CategoryCard(
                      title: category.titleKey.tr(),
                      icon: category.icon,
                      color: category.color,
                      onTap: () => _openExplore(
                        context,
                        selectedCategory: category.value,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'home.explore_egypt'.tr(),
                actionLabel: 'home.see_all'.tr(),
                onTap: () => _openExplore(context),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _cities.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    return _StaggeredFadeIn(
                      index: index,
                      child: _GovernorateCard(
                        city: city,
                        onTap: () => _openGovernorate(context, city),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              BlocBuilder<PlacesBloc, PlacesState>(
                buildWhen: (previous, current) {
                  if (previous.runtimeType != current.runtimeType) {
                    return true;
                  }
                  return current is PlacesLoaded;
                },
                builder: (context, state) {
                  if (state is PlacesFailure) {
                    return _InlineLoadError(message: state.message);
                  }

                  if (state is! PlacesLoaded) {
                    return const Column(
                      children: [
                        _SmartSectionShimmer(),
                        SizedBox(height: 28),
                        _SmartSectionShimmer(),
                        SizedBox(height: 28),
                        _SmartSectionShimmer(),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _DynamicPlaceSection(
                        title: 'home.trending_now'.tr(),
                        icon: Icons.local_fire_department_rounded,
                        places: state.trendingPlaces,
                        metricBuilder: (place) => place.views > 0
                            ? 'home.views_count'.tr(
                                namedArgs: {'count': place.views.toString()},
                              )
                            : 'home.trending_badge'.tr(),
                        onSeeAll: () => _openExplore(context),
                        onPlaceTap: (place) => _openDetails(context, place),
                      ),
                      const SizedBox(height: 28),
                      _DynamicPlaceSection(
                        title: 'home.top_rated'.tr(),
                        icon: Icons.star_rounded,
                        places: state.topRatedPlaces,
                        metricBuilder: (place) => 'home.ratings_count'.tr(
                          namedArgs: {'count': place.ratingCount.toString()},
                        ),
                        onSeeAll: () => _openExplore(context),
                        onPlaceTap: (place) => _openDetails(context, place),
                      ),
                      const SizedBox(height: 28),
                      _DynamicPlaceSection(
                        title: 'home.most_visited'.tr(),
                        icon: Icons.visibility_rounded,
                        places: state.mostVisitedPlaces,
                        metricBuilder: (place) => 'home.views_count'.tr(
                          namedArgs: {'count': place.views.toString()},
                        ),
                        onSeeAll: () => _openExplore(context),
                        onPlaceTap: (place) => _openDetails(context, place),
                      ),
                      const SizedBox(height: 28),
                      _DynamicPlaceSection(
                        title: 'home.hidden_gems'.tr(),
                        icon: Icons.diamond_outlined,
                        places: _hiddenGems(state.allPlaces),
                        metricBuilder: (place) => 'home.hidden_gem_badge'.tr(),
                        onSeeAll: () => _openExplore(context),
                        onPlaceTap: (place) => _openDetails(context, place),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'home.recommended'.tr(),
                actionLabel: 'home.for_you'.tr(),
                onTap: () => _openExplore(context),
              ),
              const SizedBox(height: 14),
              BlocBuilder<PlacesBloc, PlacesState>(
                builder: (context, state) {
                  if (state is PlacesFailure) {
                    return _InlineLoadError(message: state.message);
                  }

                  final recommendedPlaces = switch (state) {
                    PlacesLoaded loaded => loaded.allPlaces.take(3).toList(),
                    _ => const <Place>[],
                  };

                  if (recommendedPlaces.isEmpty) {
                    return const _LoadingPlaceholder();
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recommendedPlaces.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final place = recommendedPlaces[index];
                      return PlaceCard(
                        name: place.localizedName(context.locale.languageCode),
                        city:
                            '${_cityLabelKey(place.city).tr()} - ${_categoryLabelKey(place.category).tr()}',
                        rating: place.rating,
                        imageUrl: place.imageUrl,
                        onTap: () => _openDetails(context, place),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              Text('home.footer'.tr(), style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  void _openExplore(
    BuildContext context, {
    String? selectedCategory,
    String? selectedCity,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExploreScreen(
          selectedCategory: selectedCategory,
          selectedCity: selectedCity,
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, Place place) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetailsScreen(place: place)),
    );
  }

  void _openGovernorate(BuildContext context, _CityData city) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GovernorateDetailsScreen(
          city: city.value,
          name: city.nameKey.tr(),
          subtitle: city.subtitleKey.tr(),
          imageUrl: city.imageUrl,
          famousFor: city.famousForKey.tr(),
          bestVisitTime: city.bestVisitKey.tr(),
        ),
      ),
    );
  }
}

List<Place> _hiddenGems(List<Place> places) {
  final gems = places
      .where((place) => place.rating >= 4.0 || place.views <= 20)
      .toList(growable: false);

  final sorted = [...(gems.isEmpty ? places : gems)]
    ..sort((a, b) {
      final activity = (a.views + a.favoritesCount + a.ratingCount)
          .compareTo(b.views + b.favoritesCount + b.ratingCount);
      if (activity != 0) {
        return activity;
      }
      return b.rating.compareTo(a.rating);
    });

  return sorted.take(8).toList(growable: false);
}

class _StaggeredFadeIn extends StatelessWidget {
  const _StaggeredFadeIn({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + (index.clamp(0, 5) * 55)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _GovernorateCard extends StatelessWidget {
  const _GovernorateCard({required this.city, required this.onTap});

  final _CityData city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: 244,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'governorate-${city.value}',
                  child: PremiumImage(imageUrl: city.imageUrl),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.82),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 16,
                  end: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'home.explore_badge'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF1F1A14),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        city.nameKey.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        city.subtitleKey.tr(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DynamicPlaceSection extends StatelessWidget {
  const _DynamicPlaceSection({
    required this.title,
    required this.icon,
    required this.places,
    required this.metricBuilder,
    required this.onSeeAll,
    required this.onPlaceTap,
  });

  final String title;
  final IconData icon;
  final List<Place> places;
  final String Function(Place place) metricBuilder;
  final VoidCallback onSeeAll;
  final ValueChanged<Place> onPlaceTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: title,
          actionLabel: 'home.see_all'.tr(),
          onTap: onSeeAll,
        ),
        const SizedBox(height: 14),
        if (places.isEmpty)
          _SmartEmptyState(icon: icon)
        else
          SizedBox(
            height: 236,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: places.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final place = places[index];
                return _SmartPlaceCard(
                  place: place,
                  icon: icon,
                  metric: metricBuilder(place),
                  onTap: () => onPlaceTap(place),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SmartPlaceCard extends StatelessWidget {
  const _SmartPlaceCard({
    required this.place,
    required this.icon,
    required this.metric,
    required this.onTap,
  });

  final Place place;
  final IconData icon;
  final String metric;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = context.locale.languageCode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: 218,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PremiumImage(
                        imageUrl: place.imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: (MediaQuery.sizeOf(context).width * 1.5)
                            .round(),
                      ),
                      PositionedDirectional(
                        top: 10,
                        start: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.42),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 15, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                metric,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.localizedName(languageCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_cityLabelKey(place.city).tr()} - ${_categoryLabelKey(place.category).tr()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.star_rounded,
                            size: 17,
                            color: Color(0xFFD4AF37),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmartEmptyState extends StatelessWidget {
  const _SmartEmptyState({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'home.dynamic_empty'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartSectionShimmer extends StatelessWidget {
  const _SmartSectionShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 170, height: 26, child: _ShimmerBox()),
        const SizedBox(height: 14),
        SizedBox(
          height: 236,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return const SizedBox(width: 218, child: _ShimmerBox());
            },
          ),
        ),
      ],
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_controller.value * 2), -0.4),
              end: Alignment(0.6 + (_controller.value * 2), 0.4),
              colors: const [
                Color(0xFFEDE3D4),
                Color(0xFFF9F3E9),
                Color(0xFFEDE3D4),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 264,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F4C5B).withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const PremiumImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1553913861-c0fddf2619ee?auto=format&fit=crop&w=1200&q=75',
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    const Color(0xFF071D24).withValues(alpha: 0.86),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      authState.isAuthenticated
                          ? 'auth.member_badge'.tr()
                          : authState.isGuest
                          ? 'auth.guest_badge'.tr()
                          : 'home.hero_badge'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    authState.isAuthenticated
                        ? tr(
                            'auth.personal_greeting',
                            namedArgs: {'name': authState.resolvedName},
                          )
                        : 'home.hero_title'.tr(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      height: 1.14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    authState.isAuthenticated
                        ? 'auth.personal_subtitle'.tr()
                        : 'home.hero_subtitle'.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontWeight: FontWeight.w500,
                    ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _InlineLoadError extends StatelessWidget {
  const _InlineLoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Failed to load places',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              context.read<PlacesBloc>().add(const LoadPlaces());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _CategoryData {
  const _CategoryData({
    required this.value,
    required this.titleKey,
    required this.icon,
    required this.color,
  });

  final String value;
  final String titleKey;
  final IconData icon;
  final Color color;
}

class _CityData {
  const _CityData({
    required this.value,
    required this.nameKey,
    required this.subtitleKey,
    required this.imageUrl,
    required this.famousForKey,
    required this.bestVisitKey,
  });

  final String value;
  final String nameKey;
  final String subtitleKey;
  final String imageUrl;
  final String famousForKey;
  final String bestVisitKey;
}

String _cityLabelKey(String city) {
  return switch (city) {
    'Giza' => 'cities.giza',
    'Cairo' => 'cities.cairo',
    'Alexandria' => 'cities.alexandria',
    'Luxor' => 'cities.luxor',
    'Aswan' => 'cities.aswan',
    'Hurghada' => 'cities.hurghada',
    'Fayoum' => 'cities.fayoum',

    _ => 'cities.cairo',
  };
}

String _categoryLabelKey(String category) {
  return switch (category) {
    'Temples' => 'categories.temples',
    'Museums' => 'categories.museums',
    'Beaches' => 'categories.beaches',
    'Bazaars' => 'categories.bazaars',
    _ => 'categories.temples',
  };
}
