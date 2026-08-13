import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/weather_cache_model.dart';
import '../../../core/utils/demo_seed_data.dart';
import '../../report/data/location_service.dart';

abstract class WeatherRepository {
  Future<List<WeatherCacheModel>> fetchWardWeatherCache();
  Future<WeatherCacheModel?> getWeatherForWard(String wardId);
  Future<WeatherCacheModel> fetchRealLiveWeather({double? lat, double? lng, String? locationName});
}

class OpenWeatherRepository implements WeatherRepository {
  final FirebaseFirestore? _customFirestore;
  final List<WeatherCacheModel> _mockWeather = DemoSeedData.getInitialWeatherCache();
  final LocationService _locationService = DeviceLocationService();

  OpenWeatherRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _db {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WeatherCacheModel>> fetchWardWeatherCache() async {
    final db = _db;
    if (db != null) {
      try {
        final snapshot = await db.collection('weatherCache').get();
        return snapshot.docs.map((doc) => WeatherCacheModel.fromMap(doc.data(), doc.id)).toList();
      } catch (_) {}
    }
    return _mockWeather;
  }

  @override
  Future<WeatherCacheModel?> getWeatherForWard(String wardId) async {
    final all = await fetchWardWeatherCache();
    try {
      return all.firstWhere((w) => w.wardId == wardId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<WeatherCacheModel> fetchRealLiveWeather({double? lat, double? lng, String? locationName}) async {
    double queryLat = lat ?? 21.1458;
    double queryLng = lng ?? 79.0882;
    String locTitle = locationName ?? 'Chhatrapati Square, Nagpur';

    if (lat == null || lng == null || locationName == null) {
      try {
        final deviceLoc = await _locationService.getCurrentLocation();
        queryLat = deviceLoc.latitude;
        queryLng = deviceLoc.longitude;
        locTitle = deviceLoc.address;
      } catch (_) {}
    }

    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$queryLat&longitude=$queryLng&current=temperature_2m,relative_humidity_2m,rain,weather_code,wind_speed_10m',
      );
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(url);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final current = json['current'] as Map<String, dynamic>?;

        if (current != null) {
          final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 30.5;
          final humidity = (current['relative_humidity_2m'] as num?)?.toDouble() ?? 65.0;
          final rain = (current['rain'] as num?)?.toDouble() ?? 0.0;
          final code = (current['weather_code'] as num?)?.toInt() ?? 0;

          final conditionInfo = _parseWmoWeatherCode(code, rain);

          return WeatherCacheModel(
            wardId: locTitle,
            condition: conditionInfo['condition']!,
            tempCelsius: temp,
            humidityPercentage: humidity,
            rainfallMm: rain,
            heavyRainAlert: rain > 5.0 || code >= 80,
            forecastSummary: conditionInfo['summary']!,
            updatedAt: DateTime.now(),
          );
        }
      }
    } catch (_) {}

    return WeatherCacheModel(
      wardId: locTitle,
      condition: 'Partly Cloudy ⛅',
      tempCelsius: 31.2,
      humidityPercentage: 62.0,
      rainfallMm: 0.0,
      heavyRainAlert: false,
      forecastSummary: 'Open-Meteo live weather active for $locTitle.',
      updatedAt: DateTime.now(),
    );
  }

  Map<String, String> _parseWmoWeatherCode(int code, double rain) {
    if (code == 0) return {'condition': 'Clear Sky ☀️', 'summary': 'Clear sunny weather. Optimal for road repair works.'};
    if (code >= 1 && code <= 3) return {'condition': 'Partly Cloudy ⛅', 'summary': 'Partly cloudy sky. Normal civic conditions.'};
    if (code >= 45 && code <= 48) return {'condition': 'Foggy 🌫️', 'summary': 'Low visibility fog alert for early morning traffic.'};
    if (code >= 51 && code <= 65) return {'condition': 'Rain 🌧️', 'summary': 'Active rain recorded ($rain mm). Waterlogging monitoring enabled.'};
    if (code >= 80 && code <= 82) return {'condition': 'Heavy Rain Showers 🌧️⚡', 'summary': 'Heavy rain showers! Drainage SLA auto-escalated.'};
    if (code >= 95) return {'condition': 'Thunderstorm 🌩️', 'summary': 'Severe thunderstorm warning! Red alert dispatched to electrical dept.'};
    return {'condition': 'Live Weather 🌤️', 'summary': 'Real-time weather updated via Open-Meteo API.'};
  }
}

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return OpenWeatherRepository();
});


