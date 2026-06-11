abstract class PlacesEvent {
  const PlacesEvent();
}

class LoadPlaces extends PlacesEvent {
  const LoadPlaces();
}

class TrackPlaceView extends PlacesEvent {
  const TrackPlaceView(this.placeId);

  final String placeId;
}

class FilterByCategory extends PlacesEvent {
  const FilterByCategory(this.category);

  final String category;
}

class FilterByCity extends PlacesEvent {
  const FilterByCity(this.city);

  final String city;
}

class SearchPlaces extends PlacesEvent {
  const SearchPlaces(this.query);

  final String query;
}

class RatePlace extends PlacesEvent {
  const RatePlace({
    required this.placeId,
    required this.userId,
    required this.rating,
  });

  final String placeId;
  final String userId;
  final double rating;
}
