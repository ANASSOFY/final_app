import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../datasources/local/places_local_data_source.dart';
import '../datasources/remote/places_remote_data_source.dart';
import '../models/place_model.dart';

class PlacesRepository {
  PlacesRepository({
    PlacesRemoteDataSource? remoteDataSource,
    PlacesLocalDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource ?? PlacesRemoteDataSource(),
        _localDataSource = localDataSource ?? PlacesLocalDataSource();

  final PlacesRemoteDataSource _remoteDataSource;
  final PlacesLocalDataSource _localDataSource;

  Future<List<Place>> getPlaces() async {
    try {
      final places = await _remoteDataSource.getPlaces();
      debugPrint(
        'PlacesRepository: loaded ${places.length} places from Firestore',
      );

      if (places.isNotEmpty) {
        return places;
      }
    } on FirebaseException catch (e) {
      debugPrint('PlacesRepository Firebase error: ${e.code} ${e.message}');
    } catch (e) {
      debugPrint('PlacesRepository remote fallback: $e');
    }

    try {
      final places = await _localDataSource.getPlaces();
      debugPrint('PlacesRepository: loaded ${places.length} local places');
      return places;
    } catch (e) {
      debugPrint('PlacesRepository local error: $e');
      throw Exception('Failed to load places.');
    }
  }

  Future<List<Place>> getTrendingPlaces({int limit = 8}) async {
    try {
      final places = await _remoteDataSource.getTrendingPlaces(limit: limit);
      if (places.isNotEmpty) {
        return places;
      }
    } catch (e) {
      debugPrint('PlacesRepository trending fallback: $e');
    }

    final places = await getPlaces();
    return sortTrendingPlaces(places).take(limit).toList(growable: false);
  }

  Future<List<Place>> getTopRatedPlaces({int limit = 8}) async {
    try {
      final places = sortTopRatedPlaces(
        await _remoteDataSource.getTopRatedPlaces(limit: limit),
      );
      if (places.isNotEmpty) {
        return places.take(limit).toList(growable: false);
      }
    } catch (e) {
      debugPrint('PlacesRepository top rated fallback: $e');
    }

    final places = await getPlaces();
    return sortTopRatedPlaces(places).take(limit).toList(growable: false);
  }

  Future<List<Place>> getMostVisitedPlaces({int limit = 8}) async {
    try {
      final places = await _remoteDataSource.getMostVisitedPlaces(limit: limit);
      if (places.isNotEmpty) {
        return places;
      }
    } catch (e) {
      debugPrint('PlacesRepository most visited fallback: $e');
    }

    final places = await getPlaces();
    return sortMostVisitedPlaces(places).take(limit).toList(growable: false);
  }

  Stream<Place> watchPlace(String placeId) {
    return _remoteDataSource.watchPlace(placeId);
  }

  Stream<double?> watchUserRating({
    required String placeId,
    required String userId,
  }) {
    return _remoteDataSource.watchUserRating(
      placeId: placeId,
      userId: userId,
    );
  }

  Future<Place> ratePlace({
    required String placeId,
    required String userId,
    required double rating,
  }) async {
    try {
      return await _remoteDataSource.ratePlace(
        placeId: placeId,
        userId: userId,
        rating: rating,
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'PlacesRepository rating Firebase error: ${e.code} ${e.message}',
      );
      throw Exception('Failed to save rating: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('PlacesRepository rating unexpected error: $e');
      throw Exception('Failed to save rating.');
    }
  }

  Future<void> incrementPlaceViews(String placeId) async {
    try {
      await _remoteDataSource.incrementPlaceViews(placeId);
    } on FirebaseException catch (e) {
      debugPrint(
        'PlacesRepository view Firebase error: ${e.code} ${e.message}',
      );
    } catch (e) {
      debugPrint('PlacesRepository view unexpected error: $e');
    }
  }

  Future<void> updatePlaceFavoriteCount({
    required String placeId,
    required bool isFavorite,
  }) async {
    try {
      await _remoteDataSource.updatePlaceFavoriteCount(
        placeId: placeId,
        isFavorite: isFavorite,
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'PlacesRepository favorite count Firebase error: ${e.code} ${e.message}',
      );
    } catch (e) {
      debugPrint('PlacesRepository favorite count unexpected error: $e');
    }
  }
}

double _trendingScore(Place place) {
  if (place.trendingScore > 0) {
    return place.trendingScore;
  }

  return place.views + (place.favoritesCount * 2) + (place.ratingCount * 0.35);
}

List<Place> sortTrendingPlaces(List<Place> places) {
  return [...places]
    ..sort((a, b) => _trendingScore(b).compareTo(_trendingScore(a)));
}

List<Place> sortTopRatedPlaces(List<Place> places) {
  return [...places]..sort((a, b) {
      final ratingComparison = b.rating.compareTo(a.rating);
      if (ratingComparison != 0) {
        return ratingComparison;
      }
      return b.ratingCount.compareTo(a.ratingCount);
    });
}

List<Place> sortMostVisitedPlaces(List<Place> places) {
  return [...places]..sort((a, b) => b.views.compareTo(a.views));
}
