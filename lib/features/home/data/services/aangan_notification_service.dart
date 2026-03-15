import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/supabase_aangan_notification_datasource.dart';

/// In-app notification to show on Aangan (e.g. "Happy Holi", "New update coming soon").
/// Displayed as a slide-in-from-right overlay; content is decided by date (festivals)
/// or by dev-defined messages.
class AanganNotificationItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? emojiOrIcon; // e.g. "🎉" or icon name

  const AanganNotificationItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.emojiOrIcon,
  });
}

/// Decides which Aangan in-app notification to show.
/// Prefers Supabase (targeted by user location / user_id / all), then local festival/dev fallback.
/// Persists "dismissed" per day so we don't show again until next day after dismiss.
class AanganNotificationService {
  static const String _lastShownDateKey = 'aangan_notification_last_shown_date';
  static const String _lastShownIdKey = 'aangan_notification_last_shown_id';
  static const String _hiddenIdsKey = 'aangan_notification_hidden_ids';

  final SupabaseAanganNotificationDataSource _supabaseNotifications =
      SupabaseAanganNotificationDataSource();

  /// Festival dates (month 1–12, day). Update yearly for accuracy.
  /// Holi: full moon of Phalguna (≈ March); Diwali: Oct–Nov.
  static const List<({int month, int day, String id, String title, String? subtitle, String? emoji})> _festivals = [
    (month: 3, day: 14, id: 'holi', title: 'Happy Holi', subtitle: 'May your life be filled with colours of joy', emoji: '🎨'),
    (month: 3, day: 25, id: 'holi_approx', title: 'Happy Holi', subtitle: 'Celebrate the festival of colours', emoji: '🎨'),
    (month: 11, day: 1, id: 'diwali', title: 'Happy Diwali', subtitle: 'Light up your life with peace and prosperity', emoji: '🪔'),
    (month: 11, day: 12, id: 'diwali_approx', title: 'Happy Diwali', subtitle: 'Wishing you a blessed Diwali', emoji: '🪔'),
    (month: 9, day: 17, id: 'ganesh', title: 'Happy Ganesh Chaturthi', subtitle: 'May Lord Ganesha bless you', emoji: '🙏'),
    (month: 1, day: 14, id: 'makar', title: 'Happy Makar Sankranti', subtitle: 'Harvest festival blessings', emoji: '🪁'),
    (month: 8, day: 15, id: 'independence', title: 'Happy Independence Day', subtitle: 'Jai Hind', emoji: '🇮🇳'),
  ];

  /// Dev-defined messages (e.g. "New update coming soon"). Shown when no festival matches.
  /// Optional [start] and [end] dates (YYYY-MM-DD) to limit visibility.
  static final List<({String id, String title, String? subtitle, String? emoji, String? start, String? end})> _devMessages = [
    (id: 'update_soon', title: 'New update coming soon', subtitle: 'Stay tuned for new features', emoji: '✨', start: null, end: null),
    (id: 'welcome', title: 'Welcome to Antarmarg', subtitle: 'Your spiritual companion', emoji: '🙏', start: null, end: null),
  ];

  /// Optional user region (e.g. 'IN', 'US') for location-based Supabase notifications.
  /// Set from device locale or profile; null = only 'all' and user-specific targets match.
  String? userRegion;

  /// Returns all notifications to show in the notification list (Supabase + today's local).
  Future<List<AanganNotificationItem>> getNotificationsForList() async {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final hiddenIds = await _getHiddenNotificationIds();
    final result = <AanganNotificationItem>[];

    final fromSupabase = await _supabaseNotifications.getActiveNotifications(
      userRegion: userRegion,
    );
    for (final n in fromSupabase) {
      if (!hiddenIds.contains(n.id)) result.add(n);
    }

    final prefs = await SharedPreferences.getInstance();
    final lastShownDate = prefs.getString(_lastShownDateKey);
    final skipLocal = lastShownDate == todayKey;

    if (!skipLocal) {
      for (final f in _festivals) {
        if (hiddenIds.contains(f.id)) continue;
        if (now.month == f.month && now.day == f.day) {
          result.add(AanganNotificationItem(
            id: f.id,
            title: f.title,
            subtitle: f.subtitle,
            emojiOrIcon: f.emoji,
          ));
          break;
        }
      }
      for (final m in _devMessages) {
        if (hiddenIds.contains(m.id)) continue;
        if (!_isInDateRange(now, m.start, m.end)) continue;
        result.add(AanganNotificationItem(
          id: m.id,
          title: m.title,
          subtitle: m.subtitle,
          emojiOrIcon: m.emoji,
        ));
        break;
      }
    }
    return result;
  }

  /// Returns the notification to show (single; for backward compatibility).
  /// 1) Supabase notifications always shown when available (so new ones appear as soon as you open Aangan).
  /// 2) Local fallback: festival by date, then dev message — only if not already dismissed today.
  Future<AanganNotificationItem?> getNotificationForToday() async {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // 1) Supabase first: always fetch and show if any (newly created notifications show immediately)
    final hiddenIds = await _getHiddenNotificationIds();
    final fromSupabase = await _supabaseNotifications.getActiveNotifications(
      userRegion: userRegion,
    );
    final visibleFromSupabase = fromSupabase.where((n) => !hiddenIds.contains(n.id)).toList();
    if (visibleFromSupabase.isNotEmpty) {
      return visibleFromSupabase.first;
    }

    // 2) Local fallback: respect "dismissed today" so we don't spam local messages
    final prefs = await SharedPreferences.getInstance();
    final lastShownDate = prefs.getString(_lastShownDateKey);
    if (lastShownDate == todayKey) {
      if (kDebugMode) return getTestNotificationUpdate();
      return null;
    }

    // 3) Local: festival if today matches (skip if user chose "don't show again")
    for (final f in _festivals) {
      if (hiddenIds.contains(f.id)) continue;
      if (now.month == f.month && now.day == f.day) {
        return AanganNotificationItem(
          id: f.id,
          title: f.title,
          subtitle: f.subtitle,
          emojiOrIcon: f.emoji,
        );
      }
    }

    // 4) Local: dev message within date range
    for (final m in _devMessages) {
      if (hiddenIds.contains(m.id)) continue;
      if (!_isInDateRange(now, m.start, m.end)) continue;
      return AanganNotificationItem(
        id: m.id,
        title: m.title,
        subtitle: m.subtitle,
        emojiOrIcon: m.emoji,
      );
    }

    return null;
  }

  bool _isInDateRange(DateTime now, String? start, String? end) {
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (start != null && today.compareTo(start) < 0) return false;
    if (end != null && today.compareTo(end) > 0) return false;
    return true;
  }

  Future<void> _markShown(String dateKey, String id, SharedPreferences prefs) async {
    await prefs.setString(_lastShownDateKey, dateKey);
    await prefs.setString(_lastShownIdKey, id);
  }

  Future<Set<String>> _getHiddenNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_hiddenIdsKey);
    if (json == null || json.isEmpty) return {};
    try {
      final list = jsonDecode(json) as List<dynamic>?;
      return (list ?? []).map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Call when user taps the cross: do not show this notification again.
  Future<void> markDoNotShowAgain(String notificationId) async {
    if (notificationId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final hidden = await _getHiddenNotificationIds();
    hidden.add(notificationId);
    await prefs.setString(_hiddenIdsKey, jsonEncode(hidden.toList()));
  }

  /// Call when user dismisses the notification (so we don't show again until next day).
  Future<void> markDismissed() async {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastShownDateKey, todayKey);
  }

  /// For testing: force a specific notification (e.g. "Happy Holi") regardless of date.
  static AanganNotificationItem getTestNotificationHoli() {
    return const AanganNotificationItem(
      id: 'holi_test',
      title: 'Happy Holi',
      subtitle: 'May your life be filled with colours of joy',
      emojiOrIcon: '🎨',
    );
  }

  static AanganNotificationItem getTestNotificationDiwali() {
    return const AanganNotificationItem(
      id: 'diwali_test',
      title: 'Happy Diwali',
      subtitle: 'Light up your life with peace and prosperity',
      emojiOrIcon: '🪔',
    );
  }

  static AanganNotificationItem getTestNotificationUpdate() {
    return const AanganNotificationItem(
      id: 'update_test',
      title: 'New update coming soon',
      subtitle: 'Stay tuned for new features',
      emojiOrIcon: '✨',
    );
  }
}
