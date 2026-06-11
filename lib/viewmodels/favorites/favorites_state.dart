import '../../data/models/place_model.dart';

abstract class FavoritesState {
  const FavoritesState();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded(this.favorites);

  final List<Place> favorites;
}

class FavoritesFailure extends FavoritesState {
  const FavoritesFailure(this.message, {this.favorites = const <Place>[]});

  final String message;
  final List<Place> favorites;
}
