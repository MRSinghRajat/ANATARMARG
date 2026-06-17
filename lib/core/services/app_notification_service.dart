import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification.dart';
import 'notification_preferences.dart';

const String _keyNotifications = 'app_notifications_list';

/// Persists in-app notifications and read state. Listen to [unreadCountNotifier] for badge.
class AppNotificationService {
  AppNotificationService._();
  static final AppNotificationService _instance = AppNotificationService._();
  static AppNotificationService get instance => _instance;

  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  List<AppNotification> _list = [];
  bool _loaded = false;

  Future<List<AppNotification>> _load() async {
    if (_loaded) return _list;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyNotifications);
    if (raw == null || raw.isEmpty) {
      _list = [];
    } else {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _list = list
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
        _list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (_) {
        _list = [];
      }
    }
    _loaded = true;
    _updateUnreadCount();
    return _list;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyNotifications,
      jsonEncode(_list.map((e) => e.toJson()).toList()),
    );
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCountNotifier.value = _list.where((n) => !n.read).length;
  }

  /// All notifications, newest first.
  Future<List<AppNotification>> getNotifications() => _load();

  /// Unread count for badge.
  Future<int> getUnreadCount() async {
    await _load();
    return _list.where((n) => !n.read).length;
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String id) async {
    await _load();
    final i = _list.indexWhere((n) => n.id == id);
    if (i >= 0 && !_list[i].read) {
      _list[i] = _list[i].copyWith(read: true);
      await _save();
    }
  }

  /// Mark all as read.
  Future<void> markAllAsRead() async {
    await _load();
    bool changed = false;
    for (int i = 0; i < _list.length; i++) {
      if (!_list[i].read) {
        _list[i] = _list[i].copyWith(read: true);
        changed = true;
      }
    }
    if (changed) await _save();
  }

  /// Add a notification (e.g. from push or in-app event).
  /// [customId] if set is used as id and allows deduplication (e.g. aangan_holi_2025-03-14).
  Future<void> addNotification({
    required String title,
    required String body,
    String? type,
    String? customId,
  }) async {
    if (!await NotificationPreferences.isMasterEnabled()) return;
    await _load();
    if (customId != null && _list.any((n) => n.id == customId)) return;
    final id = customId ?? '${DateTime.now().millisecondsSinceEpoch}_${_list.length}';
    _list.insert(
      0,
      AppNotification(
        id: id,
        title: title,
        body: body,
        read: false,
        createdAt: DateTime.now(),
        type: type,
      ),
    );
    await _save();
  }

  /// Remove a notification.
  Future<void> removeNotification(String id) async {
    await _load();
    _list.removeWhere((n) => n.id == id);
    await _save();
  }

  /// Refresh and return list (e.g. when opening the screen).
  Future<List<AppNotification>> refresh() async {
    _loaded = false;
    return _load();
  }
}
