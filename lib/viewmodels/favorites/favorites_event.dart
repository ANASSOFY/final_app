import '../../data/models/place_model.dart';

abstract class FavoritesEvent {
  const FavoritesEvent();
}

class LoadFavorites extends FavoritesEvent {
  const LoadFavorites({this.userId});

  final String? userId;
}

class ClearFavorites extends FavoritesEvent {
  const ClearFavorites();
}

class AddFavorite extends FavoritesEvent {
  const AddFavorite(this.place);

  final Place place;
}

class RemoveFavorite extends FavoritesEvent {
  const RemoveFavorite(this.place);

  final Place place;
}
