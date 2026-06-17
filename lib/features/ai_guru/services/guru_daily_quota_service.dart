import 'package:shared_preferences/shared_preferences.dart';

class GuruDailyQuotaService {
  static String _todayKey(String type) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return 'guru_${type}_$today';
  }

  Future<int> getTodayCount(String userId, String type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$userId/${_todayKey(type)}') ?? 0;
  }

  Future<void> increment(String userId, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$userId/${_todayKey(type)}';
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
  }

  Future<bool> canUse(String userId, String type, int limit) async {
    if (limit == -1) return true;
    final count = await getTodayCount(userId, type);
    return count < limit;
  }

  Future<int> remaining(String userId, String type, int limit) async {
    if (limit == -1) return 999;
    final count = await getTodayCount(userId, type);
    return (limit - count).clamp(0, limit);
  }
}
