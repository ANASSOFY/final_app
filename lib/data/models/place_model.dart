class Place {
  const Place({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.city,
    required this.category,
    required this.rating,
    required this.ratingCount,
    required this.views,
    required this.favoritesCount,
    required this.trendingScore,
    required this.imageUrl,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.lat,
    required this.lng,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String city;
  final String category;
  final double rating;
  final int ratingCount;
  final int views;
  final int favoritesCount;
  final double trendingScore;
  final String imageUrl;
  final String descriptionEn;
  final String descriptionAr;
  final double lat;
  final double lng;

  String localizedName(String lang) => lang == 'ar' ? nameAr : nameEn;

  String localizedDescription(String lang) =>
      lang == 'ar' ? descriptionAr : descriptionEn;

  Place copyWith({
    double? rating,
    int? ratingCount,
    int? views,
    int? favoritesCount,
    double? trendingScore,
  }) {
    return Place(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      city: city,
      category: category,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      views: views ?? this.views,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      trendingScore: trendingScore ?? this.trendingScore,
      imageUrl: imageUrl,
      descriptionEn: descriptionEn,
      descriptionAr: descriptionAr,
      lat: lat,
      lng: lng,
    );
  }

  factory Place.fromFirestore(Map<String, dynamic> data, String id) {
    return Place(
      id: id,
      nameEn: _stringValue(data['name_en']),
      nameAr: _stringValue(data['name_ar']),
      city: _normalizeCity(_stringValue(data['city'])),
      category: _normalizeCategory(_stringValue(data['category'])),
      rating: _doubleValue(data['rating']),
      ratingCount: _intValue(data['ratingCount']),
      views: _intValue(data['views']),
      favoritesCount: _intValue(data['favoritesCount']),
      trendingScore: _doubleValue(data['trendingScore']),
      imageUrl: _stringValue(data['image'] ?? data['imageUrl']),
      descriptionEn: _stringValue(data['description_en']),
      descriptionAr: _stringValue(data['description_ar']),
      lat: _doubleValue(data['latitude'] ?? data['lat']),
      lng: _doubleValue(data['longitude'] ?? data['lng']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Place && other.id == id);

  @override
  int get hashCode => id.hashCode;

  String get googleMapsQuery => '$lat,$lng';
}

String _stringValue(dynamic value) => (value as String? ?? '').trim();

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

String _normalizeCity(String value) {
  switch (value.toLowerCase()) {
    case 'giza':
      return 'Giza';
    case 'cairo':
      return 'Cairo';
    case 'alexandria':
      return 'Alexandria';
    case 'luxor':
      return 'Luxor';
    case 'aswan':
      return 'Aswan';
    case 'hurghada':
      return 'Hurghada';
    case 'fayoum':
      return 'Fayoum';
    default:
      return value;
  }
}

String _normalizeCategory(String value) {
  switch (value.toLowerCase()) {
    case 'temples':
      return 'Temples';
    case 'museums':
      return 'Museums';
    case 'beaches':
      return 'Beaches';
    case 'bazaars':
      return 'Bazaars';
    default:
      return value;
  }
}
