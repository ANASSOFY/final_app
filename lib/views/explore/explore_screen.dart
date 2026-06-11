import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewmodels/places/places_view_model.dart';
import '../../viewmodels/places/places_event.dart';
import '../../viewmodels/places/places_state.dart';
import '../../data/models/place_model.dart';
import '../../core/widgets/custom_widgets.dart';
import '../details/details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    this.selectedCategory,
    this.selectedCity,
  });

  final String? selectedCategory;
  final String? selectedCity;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _initialFiltersApplied = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: Navigator.of(context).canPop(),
        title: Text('navigation.explore'.tr()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<PlacesBloc, PlacesState>(
          listener: (context, state) {
            if (state is PlacesLoaded && !_initialFiltersApplied) {
              _applyInitialFilters(context, state);
            }
          },
          builder: (context, state) {
            if (state is PlacesInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PlacesFailure) {
              return _ErrorState(message: state.message);
            }

            final isLoading = state is PlacesLoading;
            final loadedState = state is PlacesLoaded ? state : null;

            final currentPlaces = loadedState?.visiblePlaces ??
                (state is PlacesLoading ? state.currentPlaces : const <Place>[]);

            final categories = loadedState?.categories ?? const <String>['All'];
            final cities = loadedState?.cities ?? const <String>['All'];

            final selectedCategory = loadedState?.selectedCategory ?? 'All';
            final selectedCity = loadedState?.selectedCity ?? 'All';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: [
                  const SizedBox(height: 10),

                  /// ?? HEADER
                  _ExploreHeader(resultCount: currentPlaces.length),

                  const SizedBox(height: 20),

                  /// ?? SEARCH (?????)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {});
                        context.read<PlacesBloc>().add(SearchPlaces(value));
                      },
                      decoration: InputDecoration(
                        hintText: 'explore.search_hint'.tr(),
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<PlacesBloc>()
                                      .add(const SearchPlaces(''));
                                },
                              ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ??? CATEGORIES
                  _SectionTitle(title: 'home.categories'.tr()),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category;

                        return _PremiumFilterChip(
                          label: Text(_labelForCategory(category).tr()),
                          selected: isSelected,
                          onSelected: (_) {
                            context
                                .read<PlacesBloc>()
                                .add(FilterByCategory(category));
                          },
                          selectedColor: const Color(0xFFD4AF37),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ??? CITIES
                  _SectionTitle(title: 'home.cities'.tr()),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cities.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        final isSelected = selectedCity == city;

                        return _PremiumFilterChip(
                          label: Text(_labelForCity(city).tr()),
                          selected: isSelected,
                          onSelected: (_) {
                            context
                                .read<PlacesBloc>()
                                .add(FilterByCity(city));
                          },
                          selectedColor: const Color(0xFF1F4C5B),
                          selectedTextColor: Colors.white,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ?? RESULT HEADER
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'explore.places'.tr(),
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        tr('explore.found_count', namedArgs: {
                          'count': currentPlaces.length.toString(),
                        }),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// ?? PLACES
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (currentPlaces.isEmpty)
                    const _EmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentPlaces.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final place = currentPlaces[index];

                        return _AnimatedPlaceEntry(
                          index: index,
                          child: PlaceCard(
                            name: place.localizedName(
                                context.locale.languageCode),
                            city:
                                '${_labelForCity(place.city).tr()} - ${_labelForCategory(place.category).tr()}',
                            rating: place.rating,
                            imageUrl: place.imageUrl,
                            onTap: () => _openDetails(context, place),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _applyInitialFilters(BuildContext context, PlacesLoaded state) {
    _initialFiltersApplied = true;

    if (widget.selectedCategory != null &&
        state.categories.contains(widget.selectedCategory)) {
      context
          .read<PlacesBloc>()
          .add(FilterByCategory(widget.selectedCategory!));
    }

    if (widget.selectedCity != null &&
        state.cities.contains(widget.selectedCity)) {
      context.read<PlacesBloc>().add(FilterByCity(widget.selectedCity!));
    }
  }

  void _openDetails(BuildContext context, Place place) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailsScreen(place: place),
      ),
    );
  }
}

/// ?? HEADER
class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({required this.resultCount});

  final int resultCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2F3A), Color(0xFFD4AF37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F4C5B).withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'explore.header_title'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'explore.header_subtitle'.tr(),
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'explore.curated_count'.tr(
                namedArgs: {'count': resultCount.toString()},
              ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFilterChip extends StatelessWidget {
  const _PremiumFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.selectedColor,
    this.selectedTextColor = const Color(0xFF1F1A14),
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final Color selectedColor;
  final Color selectedTextColor;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: label,
      selected: selected,
      onSelected: onSelected,
      selectedColor: selectedColor,
      backgroundColor: Colors.white,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? selectedTextColor : const Color(0xFF6D6256),
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected
              ? selectedColor.withValues(alpha: 0.5)
              : const Color(0xFFE7DDCF),
        ),
      ),
    );
  }
}

class _AnimatedPlaceEntry extends StatelessWidget {
  const _AnimatedPlaceEntry({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (index.clamp(0, 5) * 40)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// ??? SECTION TITLE
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// ? EMPTY
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Icon(Icons.travel_explore, size: 50),
        const SizedBox(height: 10),
        Text('explore.empty_title'.tr()),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 52),
            const SizedBox(height: 12),
            Text(
              'Failed to load places',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<PlacesBloc>().add(const LoadPlaces());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _labelForCategory(String category) {
  return switch (category) {
    'All' => 'common.all',
    'Temples' => 'categories.temples',
    'Museums' => 'categories.museums',
    'Beaches' => 'categories.beaches',
    'Bazaars' => 'categories.bazaars',
    _ => 'common.all',
  };
}

String _labelForCity(String city) {
  return switch (city) {
    'All' => 'common.all',
    'Giza' => 'cities.giza',
    'Cairo' => 'cities.cairo',
    'Alexandria' => 'cities.alexandria',
    'Luxor' => 'cities.luxor',
    'Aswan' => 'cities.aswan',
    'Hurghada' => 'cities.hurghada',
    'Fayoum' => 'cities.fayoum',
    _ => 'common.all',
  };
}
