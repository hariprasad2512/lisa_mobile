import 'package:geolocator/geolocator.dart';

class LocationService {
  static const _keywords = [
    'location', 'where am i', 'weather', 'temperature', 'forecast',
    'rain', 'nearby', 'near me', 'local', 'city', 'place', 'places',
    'restaurant', 'restaurants', 'hotel', 'hotels', 'traffic', 'here'
  ];

  static bool needsLocation(String text) {
    final t = text.toLowerCase();
    return _keywords.any(t.contains);
  }

  static Future<Position?> current() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 8));
    } catch (_) {
      return null;
    }
  }
}
