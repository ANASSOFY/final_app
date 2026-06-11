import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewmodels/places/places_view_model.dart';
import '../../viewmodels/places/places_state.dart';
import '../../data/models/place_model.dart';
import '../../core/widgets/premium_image.dart';
import '../details/details_screen.dart';
import '../weather/weather_screen.dart';

class GovernorateDetailsScreen extends StatelessWidget {
  const GovernorateDetailsScreen({
    super.key,
    required this.city,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.famousFor,
    required this.bestVisitTime,
  });

  final String city;
  final String name;
  final String subtitle;
  final String imageUrl;
  final String famousFor;
  final String bestVisitTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<PlacesBloc, PlacesState>(
        buildWhen: (previous, current) => current is PlacesLoaded,
        builder: (context, state) {
          final places = state is PlacesLoaded
              ? state.allPlaces.where((place) => place.city == city).toList()
              : const <Place>[];
          final topAttractions = [...places]
            ..sort((a, b) {
              final rating = b.rating.compareTo(a.rating);
              if (rating != 0) {
                return rating;
              }
              return b.views.compareTo(a.views);
            });

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  city: city,
                  name: name,
                  subtitle: subtitle,
                  imageUrl: imageUrl,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    _QuickInfo(
                      location: name,
                      population: _populationFor(city),
                      famousFor: famousFor,
                      bestVisitTime: bestVisitTime,
                    ),
                    const SizedBox(height: 16),
                    WeatherSummaryCard(city: city, name: name),
                    const SizedBox(height: 26),
                    _SectionTitle(title: 'governorates.top_attractions'.tr()),
                    const SizedBox(height: 14),
                    if (topAttractions.isEmpty)
                      const _EmptyAttractions()
                    else
                      _AttractionMasonry(
                        places: topAttractions.take(8).toList(),
                      ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.city,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
  });

  final String city;
  final String name;
  final String subtitle;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 360,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'governorate-$city',
            child: PremiumImage(imageUrl: imageUrl),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  const Color(0xFF071D24).withValues(alpha: 0.92),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          PositionedDirectional(
            start: 20,
            end: 20,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'governorates.explore'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFD4AF37),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 38,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
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

class _QuickInfo extends StatelessWidget {
  const _QuickInfo({
    required this.location,
    required this.population,
    required this.famousFor,
    required this.bestVisitTime,
  });

  final String location;
  final String population;
  final String famousFor;
  final String bestVisitTime;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 620 ? 4 : 2;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              childAspectRatio: constraints.maxWidth > 620 ? 1.45 : 1.25,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'governorates.location'.tr(),
                  value: location,
                ),
                _InfoTile(
                  icon: Icons.groups_2_outlined,
                  label: 'governorates.population'.tr(),
                  value: population,
                ),
                _InfoTile(
                  icon: Icons.auto_awesome_outlined,
                  label: 'governorates.famous_for'.tr(),
                  value: famousFor,
                ),
                _InfoTile(
                  icon: Icons.wb_sunny_outlined,
                  label: 'governorates.best_visit'.tr(),
                  value: bestVisitTime,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 22),
            const Spacer(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttractionMasonry extends StatelessWidget {
  const _AttractionMasonry({required this.places});

  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    final left = <Place>[];
    final right = <Place>[];
    for (var i = 0; i < places.length; i++) {
      (i.isEven ? left : right).add(places[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _MasonryColumn(places: left, startIndex: 0)),
        const SizedBox(width: 12),
        Expanded(child: _MasonryColumn(places: right, startIndex: 1)),
      ],
    );
  }
}

class _MasonryColumn extends StatelessWidget {
  const _MasonryColumn({required this.places, required this.startIndex});

  final List<Place> places;
  final int startIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < places.length; i++) ...[
          _AttractionTile(place: places[i], tall: (i + startIndex).isEven),
          if (i != places.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _AttractionTile extends StatelessWidget {
  const _AttractionTile({required this.place, required this.tall});

  final Place place;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = context.locale.languageCode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetailsScreen(place: place),
            ),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: tall ? 190 : 140,
                  child: Hero(
                    tag: 'place-image-${place.id}',
                    child: PremiumImage(imageUrl: place.imageUrl),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.localizedName(languageCode),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFD4AF37),
                            size: 17,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _EmptyAttractions extends StatelessWidget {
  const _EmptyAttractions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'governorates.empty_attractions'.tr(),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

String _populationFor(String city) {
  return switch (city) {
    'Giza' => '9.6M+',
    'Cairo' => '10M+',
    'Alexandria' => '5.5M+',
    'Luxor' => '1.4M+',
    'Aswan' => '1.6M+',
    'Hurghada' => '260K+',
    _ => '-',
  };
}
