import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/place_model.dart';

class PlacesRemoteDataSource {
  PlacesRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _placesCollection =>
      _firestore.collection('places');

  CollectionReference<Map<String, dynamic>> get _ratingsCollection =>
      _firestore.collection('ratings');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<List<Place>> getPlaces() async {
    final snapshot = await _placesCollection
        .get(const GetOptions(source: Source.serverAndCache))
        .timeout(const Duration(seconds: 15));

    return snapshot.docs
        .map((doc) => Place.fromFirestore(doc.data(), doc.id))
        .toList(growable: false);
  }

  Future<List<Place>> getTrendingPlaces({int limit = 8}) async {
    final snapshot = await _placesCollection
        .orderBy('trendingScore', descending: true)
        .limit(limit)
        .get(const GetOptions(source: Source.serverAndCache))
        .timeout(const Duration(seconds: 15));

    return snapshot.docs
        .map((doc) => Place.fromFirestore(doc.data(), doc.id))
        .toList(growable: false);
  }

  Future<List<Place>> getTopRatedPlaces({int limit = 8}) async {
    final snapshot = await _placesCollection
        .orderBy('rating', descending: true)
        .limit(limit * 2)
        .get(const GetOptions(source: Source.serverAndCache))
        .timeout(const Duration(seconds: 15));

    return snapshot.docs
        .map((doc) => Place.fromFirestore(doc.data(), doc.id))
        .toList(growable: false);
  }

  Future<List<Place>> getMostVisitedPlaces({int limit = 8}) async {
    final snapshot = await _placesCollection
        .orderBy('views', descending: true)
        .limit(limit)
        .get(const GetOptions(source: Source.serverAndCache))
        .timeout(const Duration(seconds: 15));

    return snapshot.docs
        .map((doc) => Place.fromFirestore(doc.data(), doc.id))
        .toList(growable: false);
  }

  Stream<Place> watchPlace(String placeId) {
    return _placesCollection.doc(placeId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) {
        throw Exception('Place not found.');
      }

      return Place.fromFirestore(data, doc.id);
    });
  }

  Stream<double?> watchUserRating({
    required String placeId,
    required String userId,
  }) {
    return _userRatingDocument(placeId: placeId, userId: userId)
        .snapshots()
        .map((doc) {
      final rating = doc.data()?['rating'];
      if (rating is num) {
        return rating.toDouble();
      }

      return double.tryParse(rating?.toString() ?? '');
    });
  }

  Future<Place> ratePlace({
    required String placeId,
    required String userId,
    required double rating,
  }) async {
    final normalizedRating = rating.clamp(1.0, 5.0).toDouble();
    final placeReference = _placesCollection.doc(placeId);
    final globalRatingReference = await _globalRatingDocument(
      placeId: placeId,
      userId: userId,
    );
    final userRatingReference = _userRatingDocument(
      placeId: placeId,
      userId: userId,
    );

    return _firestore
        .runTransaction<Place>((transaction) async {
          final placeSnapshot = await transaction.get(placeReference);
          if (!placeSnapshot.exists) {
            throw Exception('Place not found.');
          }

          final globalRatingSnapshot = await transaction.get(
            globalRatingReference,
          );
          final userRatingSnapshot = await transaction.get(userRatingReference);
          final placeData = placeSnapshot.data() ?? <String, dynamic>{};
          final currentAverage = _doubleValue(placeData['rating']);
          final currentCount = _intValue(placeData['ratingCount']);
          final previousRating =
              _snapshotRating(globalRatingSnapshot) ??
              _snapshotRating(userRatingSnapshot);

          final int newCount = previousRating == null
              ? currentCount + 1
              : currentCount.clamp(1, 1 << 31).toInt();

          final previousTotal = currentAverage * currentCount;
          final updatedTotal = previousRating == null
              ? previousTotal + normalizedRating
              : previousTotal - previousRating + normalizedRating;
          final updatedAverage = newCount == 0 ? 0.0 : updatedTotal / newCount;
          final now = FieldValue.serverTimestamp();

          final ratingData = {
            'placeId': placeId,
            'userId': userId,
            'rating': normalizedRating,
            'updatedAt': now,
          };

          transaction.set(globalRatingReference, {
            ...ratingData,
            if (!globalRatingSnapshot.exists) 'createdAt': now,
          }, SetOptions(merge: true));

          transaction.set(userRatingReference, {
            ...ratingData,
            if (!userRatingSnapshot.exists) 'createdAt': now,
          }, SetOptions(merge: true));

          transaction.update(placeReference, {
            'rating': updatedAverage,
            'ratingCount': newCount,
          });

          return Place.fromFirestore({
            ...placeData,
            'rating': updatedAverage,
            'ratingCount': newCount,
          }, placeSnapshot.id);
        })
        .timeout(const Duration(seconds: 15));
  }

  Future<void> incrementPlaceViews(String placeId) async {
    final placeReference = _placesCollection.doc(placeId);

    await _firestore
        .runTransaction<void>((transaction) async {
          final placeSnapshot = await transaction.get(placeReference);
          if (!placeSnapshot.exists) {
            return;
          }

          final data = placeSnapshot.data() ?? <String, dynamic>{};
          final nextTrendingScore =
              _trendingScore(Place.fromFirestore(data, placeSnapshot.id)) + 1;

          transaction.update(placeReference, {
            'views': FieldValue.increment(1),
            'trendingScore': nextTrendingScore,
            'lastViewedAt': FieldValue.serverTimestamp(),
          });
        })
        .timeout(const Duration(seconds: 10));
  }

  Future<void> updatePlaceFavoriteCount({
    required String placeId,
    required bool isFavorite,
  }) async {
    final placeReference = _placesCollection.doc(placeId);

    await _firestore
        .runTransaction<void>((transaction) async {
          final snapshot = await transaction.get(placeReference);
          if (!snapshot.exists) {
            return;
          }

          final data = snapshot.data() ?? <String, dynamic>{};
          final currentFavorites = _intValue(data['favoritesCount']);
          final nextFavorites = isFavorite
              ? currentFavorites + 1
              : (currentFavorites - 1).clamp(0, 1 << 31).toInt();
          final currentTrending = _doubleValue(data['trendingScore']);
          final nextTrending = (currentTrending + (isFavorite ? 2 : -2))
              .clamp(0, 1 << 31)
              .toDouble();

          transaction.update(placeReference, {
            'favoritesCount': nextFavorites,
            'trendingScore': nextTrending,
          });
        })
        .timeout(const Duration(seconds: 10));
  }

  DocumentReference<Map<String, dynamic>> _ratingDocument({
    required String placeId,
    required String userId,
  }) {
    return _placesCollection.doc(placeId).collection('ratings').doc(userId);
  }

  Future<DocumentReference<Map<String, dynamic>>> _globalRatingDocument({
    required String placeId,
    required String userId,
  }) async {
    final existing = await _ratingsCollection
        .where('placeId', isEqualTo: placeId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get(const GetOptions(source: Source.serverAndCache))
        .timeout(const Duration(seconds: 10));

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.reference;
    }

    return _ratingsCollection.doc(_ratingDocumentId(
      placeId: placeId,
      userId: userId,
    ));
  }

  DocumentReference<Map<String, dynamic>> _userRatingDocument({
    required String placeId,
    required String userId,
  }) {
    return _usersCollection.doc(userId).collection('ratings').doc(placeId);
  }
}

double? _snapshotRating(DocumentSnapshot<Map<String, dynamic>> snapshot) {
  if (!snapshot.exists) {
    return null;
  }

  final rating = snapshot.data()?['rating'];
  if (rating is num) {
    return rating.toDouble();
  }

  return double.tryParse(rating?.toString().trim() ?? '');
}

String _ratingDocumentId({required String placeId, required String userId}) {
  final sanitizedUserId = _sanitizeDocumentId(userId);
  final sanitizedPlaceId = _sanitizeDocumentId(placeId);
  return '${sanitizedUserId}_$sanitizedPlaceId';
}

String _sanitizeDocumentId(String value) {
  return value.trim().replaceAll(RegExp(r'[/#?\[\]]'), '_');
}

double _trendingScore(Place place) {
  if (place.trendingScore > 0) {
    return place.trendingScore;
  }

  return place.views + (place.favoritesCount * 2) + (place.ratingCount * 0.35);
}

double _doubleValue(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString().trim() ?? '') ?? 0;
}

int _intValue(dynamic value) {
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString().trim() ?? '') ?? 0;
}
