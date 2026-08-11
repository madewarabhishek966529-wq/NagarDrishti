import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/constants/app_constants.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String address;
  final String ward;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.ward,
  });
}

abstract class LocationService {
  Future<LocationResult> getCurrentLocation();
}

class DeviceLocationService implements LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallbackLocation('Location services disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _fallbackLocation('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _fallbackLocation('Location permission permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      String address = 'Nagpur, Maharashtra';
      String ward = AppConstants.nagpurWards.first;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = '${place.street ?? place.subLocality ?? "Road"}, ${place.locality ?? "Nagpur"}';

          final locLower = (place.subLocality ?? place.name ?? '').toLowerCase();
          for (final w in AppConstants.nagpurWards) {
            final wardNameOnly = w.split('-').last.trim().toLowerCase();
            if (locLower.contains(wardNameOnly)) {
              ward = w;
              break;
            }
          }
        }
      } catch (_) {}

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        ward: ward,
      );
    } catch (_) {
      return _fallbackLocation('Nagpur Central');
    }
  }

  LocationResult _fallbackLocation(String note) {
    return const LocationResult(
      latitude: 21.1458,
      longitude: 79.0882,
      address: 'Wardha Road, Dharampeth, Nagpur',
      ward: 'Ward 2 - Dharampeth',
    );
  }
}
