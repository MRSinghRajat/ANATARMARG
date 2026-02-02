import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPresenceService {
  static const String _lastSeenKey = 'aangan_last_seen_date';
  static const String _diyaLitKey = 'aangan_diya_lit_date';
  static const String _lastCleanedKey = 'aangan_last_cleaned_date';
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Updates last seen locally AND in the cloud
  Future<void> updateLastSeen() async {
    final now = DateTime.now();
    
    // 1. Local Update (Fast)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSeenKey, now.toIso8601String());

    // 2. Cloud Update (Async/Background)
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('user_presence').upsert({
          'user_id': user.id,
          'last_seen_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        }, onConflict: 'user_id');
      }
    } catch (e) {
      // Fail silently for network errors in background sync
      print('Aangan: Failed to sync presence to cloud: $e');
    }
  }

  /// Checks if the Diya has been lit today
  Future<bool> isDiyaLitToday() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_diyaLitKey);
    
    if (dateStr == null) return false;
    
    final litDate = DateTime.parse(dateStr);
    final now = DateTime.now();
    
    return litDate.year == now.year && 
           litDate.month == now.month && 
           litDate.day == now.day;
  }

  /// Lights the Diya for today
  Future<void> lightDiya() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_diyaLitKey, now.toIso8601String());
  }

  /// Checks if the room is dusty (Cleaned > 12 hours ago)
  Future<bool> isRoomDusty() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_lastCleanedKey);
    
    if (dateStr == null) return true; // Never cleaned = Dusty
    
    final lastCleaned = DateTime.parse(dateStr);
    final now = DateTime.now();
    
    // Testing mode: Dusty after 10 seconds
    return now.difference(lastCleaned).inSeconds > 10; 
  }

  /// Marks the room as cleaned
  Future<void> cleanRoom() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCleanedKey, now.toIso8601String());
  }

  /// Gets last seen from Local Cache (Speed) but triggers background sync
  Future<DateTime?> getLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_lastSeenKey);
    
    // Trigger background sync to get fresher data from cloud if possible
    _syncFromCloud();

    if (dateStr != null) {
      return DateTime.parse(dateStr);
    }
    return null;
  }

  /// Background sync: Pulls latest 'last_seen' from cloud and updates local
  Future<void> _syncFromCloud() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('user_presence')
          .select('last_seen_at')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null && response['last_seen_at'] != null) {
        final cloudDate = DateTime.parse(response['last_seen_at']);
        
        // Update local if cloud is newer (e.g. used app on another device)
        final prefs = await SharedPreferences.getInstance();
        final localDateStr = prefs.getString(_lastSeenKey);
        
        bool shouldUpdate = false;
        if (localDateStr == null) {
          shouldUpdate = true;
        } else {
          final localDate = DateTime.parse(localDateStr);
          if (cloudDate.isAfter(localDate)) {
            shouldUpdate = true;
          }
        }

        if (shouldUpdate) {
          await prefs.setString(_lastSeenKey, cloudDate.toIso8601String());
        }
      }
    } catch (e) {
      // Ignore sync errors
      print('Aangan: Sync from cloud failed: $e');
    }
  }

  Future<int> getDaysSinceLastVisit() async {
    final lastSeen = await getLastSeen(); // This reads local
    if (lastSeen == null) {
      return 0; // First visit effectively
    }

    final now = DateTime.now();
    final difference = now.difference(lastSeen).inDays;
    return difference;
  }
}
