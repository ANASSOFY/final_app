import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/place_model.dart';
import '../../data/repositories/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({required FavoritesRepository favoritesRepository})
    : _favoritesRepository = favoritesRepository,
      super(const FavoritesLoaded([])) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ClearFavorites>(_onClearFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
  }

  final FavoritesRepository _favoritesRepository;

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    try {
      final favorites = await _favoritesRepository.getFavorites(
        userId: event.userId,
      );
      emit(FavoritesLoaded(favorites));
    } catch (error) {
      emit(FavoritesFailure(error.toString()));
    }
  }

  void _onClearFavorites(ClearFavorites event, Emitter<FavoritesState> emit) {
    emit(const FavoritesLoaded([]));
  }

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentFavorites = _currentFavorites;
    if (currentFavorites.contains(event.place)) {
      return;
    }

    final nextFavorites = [event.place, ...currentFavorites];
    emit(FavoritesLoaded(nextFavorites));

    try {
      await _favoritesRepository.addFavorite(event.place);
    } catch (error) {
      emit(FavoritesFailure(error.toString(), favorites: currentFavorites));
      emit(FavoritesLoaded(currentFavorites));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentFavorites = _currentFavorites;
    final nextFavorites = currentFavorites
        .where((place) => place.id != event.place.id)
        .toList(growable: false);

    emit(FavoritesLoaded(nextFavorites));

    try {
      await _favoritesRepository.removeFavorite(event.place);
    } catch (error) {
      emit(FavoritesFailure(error.toString(), favorites: currentFavorites));
      emit(FavoritesLoaded(currentFavorites));
    }
  }

  List<Place> get _currentFavorites {
    final current = state;
    return switch (current) {
      FavoritesLoaded loaded => loaded.favorites,
      FavoritesFailure failure => failure.favorites,
      _ => const <Place>[],
    };
  }
}
