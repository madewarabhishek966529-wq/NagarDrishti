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
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          return await _buildLocationResult(lastPos);
        }
        return _fallbackLocation('Location services disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          final lastPos = await Geolocator.getLastKnownPosition();
          if (lastPos != null) {
            return await _buildLocationResult(lastPos);
          }
          return _fallbackLocation('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          return await _buildLocationResult(lastPos);
        }
        return _fallbackLocation('Location permission permanently denied');
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 12),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        return await _buildLocationResult(position);
      }

      return _fallbackLocation('Nagpur Central');
    } catch (_) {
      return _fallbackLocation('Nagpur Central');
    }
  }

  Future<LocationResult> _buildLocationResult(Position position) async {
    String address = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
    String ward = AppConstants.nagpurWards.first;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final street = place.street ?? place.subLocality ?? place.name;
        final locality = place.locality ?? place.subAdministrativeArea ?? 'Nagpur';
        address = '${street != null && street.isNotEmpty ? "$street, " : ""}$locality';

        final locLower = '${place.subLocality} ${place.name} ${place.thoroughfare}'.toLowerCase();
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

