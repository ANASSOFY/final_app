import '../../data/models/place_model.dart';

abstract class PlacesState {
  const PlacesState();
}

class PlacesInitial extends PlacesState {
  const PlacesInitial();
}

class PlacesLoading extends PlacesState {
  const PlacesLoading({this.currentPlaces = const []});

  final List<Place> currentPlaces;
}

class PlacesFailure extends PlacesState {
  const PlacesFailure(this.message);

  final String message;
}

class PlacesLoaded extends PlacesState {
  const PlacesLoaded({
    required this.allPlaces,
    required this.visiblePlaces,
    required this.trendingPlaces,
    required this.topRatedPlaces,
    required this.mostVisitedPlaces,
    required this.selectedCategory,
    required this.selectedCity,
    required this.searchQuery,
    this.ratingSubmissionPlaceId,
    this.ratingErrorMessage,
    this.ratingSuccessPlaceId,
  });

  final List<Place> allPlaces;
  final List<Place> visiblePlaces;
  final List<Place> trendingPlaces;
  final List<Place> topRatedPlaces;
  final List<Place> mostVisitedPlaces;
  final String selectedCategory;
  final String selectedCity;
  final String searchQuery;
  final String? ratingSubmissionPlaceId;
  final String? ratingErrorMessage;
  final String? ratingSuccessPlaceId;

  bool isSubmittingRating(String placeId) => ratingSubmissionPlaceId == placeId;

  List<String> get categories => [
    'All',
    ...{for (final place in allPlaces) place.category},
  ];

  List<String> get cities => [
    'All',
    ...{for (final place in allPlaces) place.city},
  ];

  PlacesLoaded copyWith({
    List<Place>? allPlaces,
    List<Place>? visiblePlaces,
    List<Place>? trendingPlaces,
    List<Place>? topRatedPlaces,
    List<Place>? mostVisitedPlaces,
    String? selectedCategory,
    String? selectedCity,
    String? searchQuery,
    String? ratingSubmissionPlaceId,
    String? ratingErrorMessage,
    String? ratingSuccessPlaceId,
    bool clearRatingSubmission = false,
    bool clearRatingError = false,
    bool clearRatingSuccess = false,
  }) {
    return PlacesLoaded(
      allPlaces: allPlaces ?? this.allPlaces,
      visiblePlaces: visiblePlaces ?? this.visiblePlaces,
      trendingPlaces: trendingPlaces ?? this.trendingPlaces,
      topRatedPlaces: topRatedPlaces ?? this.topRatedPlaces,
      mostVisitedPlaces: mostVisitedPlaces ?? this.mostVisitedPlaces,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCity: selectedCity ?? this.selectedCity,
      searchQuery: searchQuery ?? this.searchQuery,
      ratingSubmissionPlaceId: clearRatingSubmission
          ? null
          : ratingSubmissionPlaceId ?? this.ratingSubmissionPlaceId,
      ratingErrorMessage: clearRatingError
          ? null
          : ratingErrorMessage ?? this.ratingErrorMessage,
      ratingSuccessPlaceId: clearRatingSuccess
          ? null
          : ratingSuccessPlaceId ?? this.ratingSuccessPlaceId,
    );
  }
}
