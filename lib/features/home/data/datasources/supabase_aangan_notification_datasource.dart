import 'package:flutter/foundation.dart' show kDebugMode;

import '../../../../core/config/supabase_config.dart';
import '../../../../core/services/supabase_service.dart';
import '../services/aangan_notification_service.dart';

/// Fetches Aangan notifications from Supabase.
/// Notifications are targeted by: all users, region (user location), or user_id.
class SupabaseAanganNotificationDataSource {
  final SupabaseService _supabase = SupabaseService();

  List<dynamic> _toList(dynamic response) {
    if (response == null) return [];
    if (response is List) return response;
    final data = (response as dynamic).data;
    if (data is List) return data;
    return [];
  }

  /// Fetches active notifications for the current context.
  /// [userRegion] Optional ISO country code (e.g. 'IN', 'US') for location-based targeting.
  /// Returns notifications where: target_type = 'all', or target_region = userRegion, or target_user_id = currentUser.
  Future<List<AanganNotificationItem>> getActiveNotifications({
    String? userRegion,
  }) async {
    if (!_supabase.isInitialized) return [];

    try {
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final userId = _supabase.currentUserId;

      final response = await _supabase.client!
          .from(SupabaseConfig.aanganNotificationsTable)
          .select('id, title, subtitle, emoji_or_icon, target_type, target_region, target_user_id, start_date, end_date')
          .eq('is_active', true)
          .order('order_index', ascending: true);

      final list = _toList(response);
      if (list.isEmpty) return [];

      final results = <AanganNotificationItem>[];
      for (final row in list) {
        final map = row as Map<String, dynamic>;
        final targetType = map['target_type'] as String? ?? 'all';
        final targetRegion = map['target_region'] as String?;
        final targetUserId = map['target_user_id'] as String?;

        bool matches = false;
        if (targetType == 'all') {
          matches = true;
        } else if (targetType == 'region' &&
            userRegion != null &&
            targetRegion != null &&
            targetRegion.toUpperCase() == userRegion.toUpperCase()) {
          matches = true;
        } else if (targetType == 'user' &&
            userId != null &&
            targetUserId == userId) {
          matches = true;
        }

        if (matches) {
          final startDate = map['start_date'] as String?;
          final endDate = map['end_date'] as String?;
          if (startDate != null && today.compareTo(startDate) < 0) continue;
          if (endDate != null && today.compareTo(endDate) > 0) continue;

          results.add(AanganNotificationItem(
            id: map['id']?.toString() ?? '',
            title: (map['title'] as String?) ?? '',
            subtitle: map['subtitle'] as String?,
            emojiOrIcon: map['emoji_or_icon'] as String?,
          ));
        }
      }
      return results;
    } catch (e) {
      if (kDebugMode) print('SupabaseAanganNotificationDataSource error: $e');
      return [];
    }
  }

  /// Whether a row (e.g. from Realtime INSERT) should be shown to this user.
  static bool rowMatchesUser(
    Map<String, dynamic> map, {
    required String? userId,
    String? userRegion,
  }) {
    if (map['is_active'] == false) return false;
    final targetType = map['target_type'] as String? ?? 'all';
    final targetRegion = map['target_region'] as String?;
    final targetUserId = map['target_user_id'] as String?;
    bool matches = false;
    if (targetType == 'all') {
      matches = true;
    } else if (targetType == 'region' &&
        userRegion != null &&
        targetRegion != null &&
        targetRegion.toUpperCase() == userRegion.toUpperCase()) {
      matches = true;
    } else if (targetType == 'user' &&
        userId != null &&
        targetUserId == userId) {
      matches = true;
    }
    if (!matches) return false;
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final startDate = map['start_date'] as String?;
    final endDate = map['end_date'] as String?;
    if (startDate != null && today.compareTo(startDate) < 0) return false;
    if (endDate != null && today.compareTo(endDate) > 0) return false;
    return true;
  }

  static AanganNotificationItem? itemFromRow(Map<String, dynamic> map) {
    final title = (map['title'] as String?) ?? '';
    if (title.isEmpty) return null;
    return AanganNotificationItem(
      id: map['id']?.toString() ?? '',
      title: title,
      subtitle: map['subtitle'] as String?,
      emojiOrIcon: map['emoji_or_icon'] as String?,
    );
  }
}
