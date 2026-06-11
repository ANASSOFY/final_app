import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/place_model.dart';

class FavoritesRepository {
  FavoritesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> get _placesCollection =>
      _firestore.collection('places');

  CollectionReference<Map<String, dynamic>> get _favoritesCollection =>
      _firestore.collection('favorites');

  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  Future<List<Place>> getFavorites({String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      return const <Place>[];
    }

    try {
      final snapshot = await _favoritesCollection
          .doc(uid)
          .collection('favorites')
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 15));

      final places = await Future.wait(
        snapshot.docs.map(_placeFromFavoriteDocument),
      );

      return places.nonNulls.toList(growable: false);
    } on FirebaseException catch (error) {
      debugPrint(
        'FavoritesRepository Firebase error: ${error.code} ${error.message}',
      );
      throw Exception(
        'Firebase ${error.code}: ${error.message ?? 'Could not load favorites.'}',
      );
    } catch (error) {
      debugPrint('FavoritesRepository load error: $error');
      throw Exception('Could not load favorites: $error');
    }
  }

  Future<void> addFavorite(Place place, {String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      throw Exception('Sign in to save favorites.');
    }

    final favoriteReference = _favoriteDocument(userId: uid, placeId: place.id);

    await favoriteReference
        .set({
          ..._placeToFavoriteData(place),
          'savedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .timeout(const Duration(seconds: 15));
  }

  Future<void> removeFavorite(Place place, {String? userId}) async {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      throw Exception('Sign in to edit favorites.');
    }

    final favoriteReference = _favoriteDocument(userId: uid, placeId: place.id);

    await _firestore
        .runTransaction<void>((transaction) async {
          final favoriteSnapshot = await transaction.get(favoriteReference);
          if (favoriteSnapshot.exists) {
            transaction.delete(favoriteReference);
          }

          final legacySnapshot = await _favoritesCollection
              .doc(uid)
              .collection('favorites')
              .where('placeId', isEqualTo: place.id)
              .get();

          for (final doc in legacySnapshot.docs) {
            transaction.delete(doc.reference);
          }
        })
        .timeout(const Duration(seconds: 15));
  }

  DocumentReference<Map<String, dynamic>> _favoriteDocument({
    required String userId,
    required String placeId,
  }) {
    return _favoritesCollection
        .doc(userId)
        .collection('favorites')
        .doc(placeId);
  }

  Map<String, dynamic> _placeToFavoriteData(Place place) {
    return {
      'placeId': place.id,
      'name_en': place.nameEn,
      'name_ar': place.nameAr,
      'city': place.city,
      'category': place.category,
      'rating': place.rating,
      'ratingCount': place.ratingCount,
      'views': place.views,
      'favoritesCount': place.favoritesCount,
      'trendingScore': place.trendingScore,
      'image': place.imageUrl,
      'description_en': place.descriptionEn,
      'description_ar': place.descriptionAr,
      'latitude': place.lat,
      'longitude': place.lng,
    };
  }

  Future<Place?> _placeFromFavoriteDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();
    final placeId = data['placeId']?.toString().trim().isNotEmpty == true
        ? data['placeId'].toString().trim()
        : doc.id;

    if ((data['name_en'] ?? data['name_ar']) != null) {
      return Place.fromFirestore(data, placeId);
    }

    final placeSnapshot = await _placesCollection
        .doc(placeId)
        .get(const GetOptions(source: Source.serverAndCache));
    final placeData = placeSnapshot.data();
    if (placeData == null) {
      return null;
    }

    return Place.fromFirestore(placeData, placeSnapshot.id);
  }
}
