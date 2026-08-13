import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/weather_cache_model.dart';
import '../../../core/utils/demo_seed_data.dart';

abstract class WeatherRepository {
  Future<List<WeatherCacheModel>> fetchWardWeatherCache();
  Future<WeatherCacheModel?> getWeatherForWard(String wardId);
}

class OpenWeatherRepository implements WeatherRepository {
  final FirebaseFirestore? _customFirestore;
  final List<WeatherCacheModel> _mockWeather = DemoSeedData.getInitialWeatherCache();

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
}
