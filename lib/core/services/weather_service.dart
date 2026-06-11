import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/weather_model.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  static const _apiKey = '98cde3027b56bbf6431772ff1040b599';
  static const _baseUrl = 'api.openweathermap.org';
  static const _cachePrefix = 'weather_cache_';
  static const _cacheTtl = Duration(minutes: 30);

  final http.Client _client;

  Future<Weather> getWeatherForGovernorate(String governorate) async {
    final location = WeatherGovernorates.locationFor(governorate);
    final cachedWeather = await _readFreshCache(location.key);
    if (cachedWeather != null) {
      return cachedWeather;
    }

    final uri = Uri.https(_baseUrl, '/data/2.5/weather', {
      'lat': location.latitude.toString(),
      'lon': location.longitude.toString(),
      'appid': _apiKey,
      'units': 'metric',
      'lang': 'en',
    });

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        final message = _messageFromResponse(response.body);
        throw WeatherException(message);
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final weather = Weather.fromApiJson(json, location.key);
      await _writeCache(location.key, weather);
      return weather;
    } on WeatherException {
      rethrow;
    } catch (_) {
      final fallback = await _readAnyCache(location.key);
      if (fallback != null) {
        return fallback;
      }
      throw const WeatherException('weather.error_message');
    }
  }

  Future<Weather?> _readFreshCache(String key) async {
    final weather = await _readAnyCache(key);
    if (weather == null) {
      return null;
    }

    final age = DateTime.now().difference(weather.fetchedAt);
    return age <= _cacheTtl ? weather : null;
  }

  Future<Weather?> _readAnyCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final rawCache = prefs.getString('$_cachePrefix$key');
    if (rawCache == null) {
      return null;
    }

    try {
      final json = jsonDecode(rawCache) as Map<String, dynamic>;
      return Weather.fromCacheJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(String key, Weather weather) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_cachePrefix$key',
      jsonEncode(weather.toCacheJson()),
    );
  }

  String _messageFromResponse(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['message']?.toString() ?? 'weather.error_message';
    } catch (_) {
      return 'weather.error_message';
    }
  }
}

class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;
}

class WeatherGovernorates {
  const WeatherGovernorates._();

  static const _locations = <String, WeatherLocation>{
    'Giza': WeatherLocation('Giza', 30.0131, 31.2089),
    'Cairo': WeatherLocation('Cairo', 30.0444, 31.2357),
    'Alexandria': WeatherLocation('Alexandria', 31.2001, 29.9187),
    'Luxor': WeatherLocation('Luxor', 25.6872, 32.6396),
    'Aswan': WeatherLocation('Aswan', 24.0889, 32.8998),
    'Hurghada': WeatherLocation('Hurghada', 27.2579, 33.8116),
    'Fayoum': WeatherLocation('Fayoum', 29.3084, 30.8428),
  };

  static WeatherLocation locationFor(String governorate) {
    final normalized = governorate.trim().toLowerCase();
    return _locations.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == normalized,
          orElse: () => _locations.entries.first,
        )
        .value;
  }
}

class WeatherLocation {
  const WeatherLocation(this.key, this.latitude, this.longitude);

  final String key;
  final double latitude;
  final double longitude;
}
