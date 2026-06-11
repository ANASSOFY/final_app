class Weather {
  const Weather({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.minTemperature,
    required this.maxTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.fetchedAt,
  });

  final String city;
  final double temperature;
  final double feelsLike;
  final double minTemperature;
  final double maxTemperature;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String description;
  final String iconCode;
  final DateTime fetchedAt;

  factory Weather.fromApiJson(Map<String, dynamic> json, String city) {
    final main = json['main'] as Map<String, dynamic>? ?? const {};
    final wind = json['wind'] as Map<String, dynamic>? ?? const {};
    final weatherList = json['weather'] as List<dynamic>? ?? const [];
    final weather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : const <String, dynamic>{};

    return Weather(
      city: city,
      temperature: _asDouble(main['temp']),
      feelsLike: _asDouble(main['feels_like']),
      minTemperature: _asDouble(main['temp_min']),
      maxTemperature: _asDouble(main['temp_max']),
      humidity: _asInt(main['humidity']),
      windSpeed: _asDouble(wind['speed']),
      condition: weather['main']?.toString() ?? '',
      description: weather['description']?.toString() ?? '',
      iconCode: weather['icon']?.toString() ?? '01d',
      fetchedAt: DateTime.now(),
    );
  }

  factory Weather.fromCacheJson(Map<String, dynamic> json) {
    return Weather(
      city: json['city']?.toString() ?? '',
      temperature: _asDouble(json['temperature']),
      feelsLike: _asDouble(json['feelsLike']),
      minTemperature: _asDouble(json['minTemperature']),
      maxTemperature: _asDouble(json['maxTemperature']),
      humidity: _asInt(json['humidity']),
      windSpeed: _asDouble(json['windSpeed']),
      condition: json['condition']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconCode: json['iconCode']?.toString() ?? '01d',
      fetchedAt:
          DateTime.tryParse(json['fetchedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'city': city,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'condition': condition,
      'description': description,
      'iconCode': iconCode,
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _asInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
