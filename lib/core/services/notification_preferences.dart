import 'package:shared_preferences/shared_preferences.dart';

/// Central keys for notification toggles (Profile → Notification center).
class NotificationPreferences {
  NotificationPreferences._();

  static const String keyMaster = 'notifications_master_enabled';
  static const String keyDaily = 'notifications_daily';
  static const String keyPrayer = 'notifications_prayer';
  static const String keyUpdates = 'notifications_updates';
  static const String keyReading = 'notifications_reading';

  static Future<bool> isMasterEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(keyMaster) ?? true;
  }

  /// Per-channel delivery (daily / prayer / admin updates / reading). Respects master.
  static Future<bool> shouldDeliver(String channelKey) async {
    if (!await isMasterEnabled()) return false;
    final p = await SharedPreferences.getInstance();
    return p.getBool(channelKey) ?? true;
  }

  /// Master off silences all delivery via [shouldDeliver]; channel toggles are kept
  /// so turning notifications back on restores the user's choices.
  static Future<void> setMasterEnabled(bool enabled) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(keyMaster, enabled);
  }

  static Future<bool> getBool(String key, {bool defaultValue = true}) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, value);
  }
}
