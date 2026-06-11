import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/place_model.dart';
import '../../data/repositories/places_repository.dart';
import 'places_event.dart';
import 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  PlacesBloc({required PlacesRepository placesRepository})
    : _placesRepository = placesRepository,
      super(const PlacesInitial()) {
    on<LoadPlaces>(_onLoadPlaces);
    on<FilterByCategory>(_onFilterByCategory);
    on<FilterByCity>(_onFilterByCity);
    on<SearchPlaces>(_onSearchPlaces);
    on<RatePlace>(_onRatePlace);
    on<TrackPlaceView>(_onTrackPlaceView);
  }

  final PlacesRepository _placesRepository;
  final Map<String, DateTime> _recentlyTrackedViews = {};

  Future<void> _onLoadPlaces(
    LoadPlaces event,
    Emitter<PlacesState> emit,
  ) async {
    emit(const PlacesLoading());

    try {
      final results = await Future.wait([
        _placesRepository.getPlaces(),
        _placesRepository.getTrendingPlaces(),
        _placesRepository.getTopRatedPlaces(),
        _placesRepository.getMostVisitedPlaces(),
      ]);

      final places = results[0];
      final trendingPlaces = results[1].isEmpty
          ? sortTrendingPlaces(places).take(8).toList()
          : results[1];
      final topRatedPlaces = results[2].isEmpty
          ? sortTopRatedPlaces(places).take(8).toList()
          : results[2];
      final mostVisitedPlaces = results[3].isEmpty
          ? sortMostVisitedPlaces(places).take(8).toList()
          : results[3];

      emit(
        PlacesLoaded(
          allPlaces: places,
          visiblePlaces: places,
          trendingPlaces: trendingPlaces,
          topRatedPlaces: topRatedPlaces,
          mostVisitedPlaces: mostVisitedPlaces,
          selectedCategory: 'All',
          selectedCity: 'All',
          searchQuery: '',
        ),
      );
    } catch (e) {
      emit(PlacesFailure(e.toString()));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<PlacesState> emit,
  ) async {
    final current = state;
    if (current is! PlacesLoaded) {
      return;
    }

    emit(_applyFilters(current.copyWith(selectedCategory: event.category)));
  }

  Future<void> _onFilterByCity(
    FilterByCity event,
    Emitter<PlacesState> emit,
  ) async {
    final current = state;
    if (current is! PlacesLoaded) {
      return;
    }

    emit(_applyFilters(current.copyWith(selectedCity: event.city)));
  }

  Future<void> _onSearchPlaces(
    SearchPlaces event,
    Emitter<PlacesState> emit,
  ) async {
    final current = state;
    if (current is! PlacesLoaded) {
      return;
    }

    emit(_applyFilters(current.copyWith(searchQuery: event.query)));
  }

  Future<void> _onRatePlace(RatePlace event, Emitter<PlacesState> emit) async {
    final current = state;
    if (current is! PlacesLoaded) {
      return;
    }

    emit(
      current.copyWith(
        ratingSubmissionPlaceId: event.placeId,
        clearRatingError: true,
        clearRatingSuccess: true,
      ),
    );

    try {
      final updatedPlace = await _placesRepository.ratePlace(
        placeId: event.placeId,
        userId: event.userId,
        rating: event.rating,
      );

      final latest = state;
      if (latest is! PlacesLoaded) {
        return;
      }

      final updatedAllPlaces = _replacePlace(latest.allPlaces, updatedPlace);
      final updatedVisiblePlaces = _replacePlace(
        latest.visiblePlaces,
        updatedPlace,
      );
      final updatedTrendingPlaces = _replacePlace(
        latest.trendingPlaces,
        updatedPlace,
      );
      final updatedTopRatedPlaces = sortTopRatedPlaces(
        _replacePlace(latest.topRatedPlaces, updatedPlace),
      );
      final updatedMostVisitedPlaces = _replacePlace(
        latest.mostVisitedPlaces,
        updatedPlace,
      );

      emit(
        latest.copyWith(
          allPlaces: updatedAllPlaces,
          visiblePlaces: updatedVisiblePlaces,
          trendingPlaces: updatedTrendingPlaces,
          topRatedPlaces: updatedTopRatedPlaces,
          mostVisitedPlaces: updatedMostVisitedPlaces,
          ratingSuccessPlaceId: event.placeId,
          clearRatingSubmission: true,
          clearRatingError: true,
        ),
      );
    } catch (e) {
      final latest = state;
      if (latest is! PlacesLoaded) {
        return;
      }

      emit(
        latest.copyWith(
          ratingErrorMessage: e.toString(),
          clearRatingSubmission: true,
          clearRatingSuccess: true,
        ),
      );
    }
  }

  Future<void> _onTrackPlaceView(
    TrackPlaceView event,
    Emitter<PlacesState> emit,
  ) async {
    final now = DateTime.now();
    final lastTracked = _recentlyTrackedViews[event.placeId];
    if (lastTracked != null && now.difference(lastTracked).inSeconds < 45) {
      return;
    }

    _recentlyTrackedViews[event.placeId] = now;
    await _placesRepository.incrementPlaceViews(event.placeId);

    final current = state;
    if (current is! PlacesLoaded) {
      return;
    }

    Place? updatedPlace;
    for (final place in current.allPlaces) {
      if (place.id == event.placeId) {
        updatedPlace = place.copyWith(
          views: place.views + 1,
          trendingScore: place.trendingScore > 0
              ? place.trendingScore + 1
              : place.views +
                    1 +
                    (place.favoritesCount * 2) +
                    (place.ratingCount * 0.35),
        );
        break;
      }
    }

    if (updatedPlace == null) {
      return;
    }

    final updatedAllPlaces = _replacePlace(current.allPlaces, updatedPlace);
    final updatedVisiblePlaces = _replacePlace(
      current.visiblePlaces,
      updatedPlace,
    );

    emit(
      current.copyWith(
        allPlaces: updatedAllPlaces,
        visiblePlaces: updatedVisiblePlaces,
        trendingPlaces: sortTrendingPlaces(updatedAllPlaces).take(8).toList(),
        topRatedPlaces: _replacePlace(current.topRatedPlaces, updatedPlace),
        mostVisitedPlaces: sortMostVisitedPlaces(
          updatedAllPlaces,
        ).take(8).toList(),
      ),
    );
  }

  PlacesLoaded _applyFilters(PlacesLoaded state) {
    final query = _normalized(state.searchQuery);
    final selectedCategory = _normalized(state.selectedCategory);
    final selectedCity = _normalized(state.selectedCity);

    final filtered = state.allPlaces.where((place) {
      final placeCategory = _normalized(place.category);
      final placeCity = _normalized(place.city);
      final categoryMatches =
          selectedCategory == 'all' || placeCategory == selectedCategory;
      final cityMatches = selectedCity == 'all' || placeCity == selectedCity;
      final searchMatches =
          query.isEmpty ||
          _normalized(place.nameEn).contains(query) ||
          _normalized(place.nameAr).contains(query) ||
          placeCity.contains(query) ||
          placeCategory.contains(query);

      return categoryMatches && cityMatches && searchMatches;
    }).toList();

    return state.copyWith(visiblePlaces: filtered);
  }
}

String _normalized(String value) => value.trim().toLowerCase();

List<Place> _replacePlace(List<Place> places, Place updatedPlace) {
  return places
      .map((place) => place.id == updatedPlace.id ? updatedPlace : place)
      .toList(growable: false);
}
