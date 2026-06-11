import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/place_model.dart';

class PlacesLocalDataSource {
  PlacesLocalDataSource({AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  Future<List<Place>> getPlaces() async {
    final rawJson = await _assetBundle.loadString('assets/data/places.json');
    if (rawJson.trim().isEmpty) {
      return const <Place>[];
    }

    final decoded = jsonDecode(rawJson);
    final items = switch (decoded) {
      List<dynamic> list => list,
      {'places': final List<dynamic> list} => list,
      {'data': final List<dynamic> list} => list,
      _ => const <dynamic>[],
    };

    return items
        .whereType<Map<String, dynamic>>()
        .map((data) {
          final id = (data['id'] ?? data['placeId'] ?? '').toString();
          return Place.fromFirestore(data, id);
        })
        .where((place) => place.id.trim().isNotEmpty)
        .toList(growable: false);
  }
}
