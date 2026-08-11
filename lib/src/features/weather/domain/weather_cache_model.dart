class WeatherCacheModel {
  final String wardId;
  final String condition;
  final double tempCelsius;
  final double humidityPercentage;
  final double rainfallMm;
  final bool heavyRainAlert;
  final String forecastSummary;
  final DateTime updatedAt;

  const WeatherCacheModel({
    required this.wardId,
    required this.condition,
    required this.tempCelsius,
    required this.humidityPercentage,
    required this.rainfallMm,
    required this.heavyRainAlert,
    required this.forecastSummary,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'wardId': wardId,
      'condition': condition,
      'tempCelsius': tempCelsius,
      'humidityPercentage': humidityPercentage,
      'rainfallMm': rainfallMm,
      'heavyRainAlert': heavyRainAlert,
      'forecastSummary': forecastSummary,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WeatherCacheModel.fromMap(Map<String, dynamic> map, String docId) {
    return WeatherCacheModel(
      wardId: docId,
      condition: map['condition'] as String? ?? 'Cloudy',
      tempCelsius: (map['tempCelsius'] as num?)?.toDouble() ?? 29.5,
      humidityPercentage: (map['humidityPercentage'] as num?)?.toDouble() ?? 78.0,
      rainfallMm: (map['rainfallMm'] as num?)?.toDouble() ?? 45.0,
      heavyRainAlert: map['heavyRainAlert'] as bool? ?? false,
      forecastSummary: map['forecastSummary'] as String? ?? 'Moderate rainfall expected',
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
