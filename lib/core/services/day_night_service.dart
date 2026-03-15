import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Uses device location to determine if it's night (for Aangan sky: stars only at night).
/// Falls back to local time 6:00–18:00 as day if location unavailable.
class DayNightService {
  DayNightService._();
  static final DayNightService _instance = DayNightService._();
  static DayNightService get instance => _instance;

  static const double _rad = math.pi / 180;

  /// True when it's night at the user's location (sun below horizon).
  /// Uses [latitude] and [longitude] if provided; otherwise gets current position.
  /// On permission/location failure, uses device local time (18:00–6:00 = night).
  Future<bool> isNightTime({double? latitude, double? longitude}) async {
    double? lat = latitude;
    double? lon = longitude;
    if (lat == null || lon == null) {
      final pos = await _getCurrentPosition();
      if (pos != null) {
        lat = pos.latitude;
        lon = pos.longitude;
      }
    }
    if (lat != null && lon != null) {
      return _isSunBelowHorizon(lat, lon, DateTime.now());
    }
    return _isNightByLocalTime(DateTime.now());
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      if (!status.isGranted) {
        final result = await Permission.locationWhenInUse.request();
        if (!result.isGranted) return null;
      }
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Sun elevation < 0 => night. Uses simplified solar position.
  bool _isSunBelowHorizon(double lat, double lon, DateTime dt) {
    final utc = dt.toUtc();
    final jd = _julianDay(utc.year, utc.month, utc.day);
    final n = jd - 2451545.0;
    final decl = _rad * (23.45 * math.sin(_rad * (360 / 365.0 * (n + 10))));
    final latRad = lat * _rad;
    final hourUtc = utc.hour + utc.minute / 60.0 + utc.second / 3600.0;
    final localSolarTime = hourUtc + lon / 15.0;
    final hourAngle = _rad * 15.0 * (localSolarTime - 12.0);
    final sinElev = math.sin(latRad) * math.sin(decl) +
        math.cos(latRad) * math.cos(decl) * math.cos(hourAngle);
    final elev = math.asin(sinElev.clamp(-1.0, 1.0));
    return elev < 0;
  }

  double _julianDay(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5;
  }

  bool _isNightByLocalTime(DateTime local) {
    final hour = local.hour + local.minute / 60.0;
    return hour < 6.0 || hour >= 18.0;
  }
}
