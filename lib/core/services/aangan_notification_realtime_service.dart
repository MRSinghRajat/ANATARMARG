import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/home/data/datasources/supabase_aangan_notification_datasource.dart';
import '../config/supabase_config.dart';
import 'app_notification_service.dart';
import 'daily_notification_service.dart';
import 'notification_preferences.dart';
import 'supabase_service.dart';

/// Listens for new rows in [aangan_notifications] so targeted users get an
/// in-app message + local notification without opening Ashram.
///
/// Enable Realtime for `aangan_notifications` in Supabase Dashboard
/// (Database → Replication) if inserts are not received.
class AanganNotificationRealtimeService {
  AanganNotificationRealtimeService._();
  static final AanganNotificationRealtimeService instance =
      AanganNotificationRealtimeService._();

  RealtimeChannel? _channel;
  bool _started = false;

  void start({String? userRegion}) {
    final client = SupabaseService().client;
    if (client == null || _started) return;

    try {
      _channel = client.channel('public_aangan_notifications');
      _channel!.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: SupabaseConfig.aanganNotificationsTable,
        callback: (payload) => _onInsert(payload, userRegion: userRegion),
      );
      _channel!.subscribe();
      _started = true;
      if (kDebugMode) {
        print('AanganNotificationRealtimeService: subscribed to inserts');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AanganNotificationRealtimeService subscribe failed: $e');
      }
    }
  }

  void stop() {
    try {
      _channel?.unsubscribe();
    } catch (_) {}
    _channel = null;
    _started = false;
  }

  Future<void> _onInsert(
    PostgresChangePayload payload, {
    String? userRegion,
  }) async {
    try {
      final row = payload.newRecord;
      if (row.isEmpty) return;

      final userId = SupabaseService().currentUserId;
      if (!SupabaseAanganNotificationDataSource.rowMatchesUser(
        row,
        userId: userId,
        userRegion: userRegion,
      )) {
        return;
      }

      if (!await NotificationPreferences.isMasterEnabled()) return;
      if (!await NotificationPreferences.shouldDeliver(
          NotificationPreferences.keyUpdates)) {
        return;
      }

      final item = SupabaseAanganNotificationDataSource.itemFromRow(row);
      if (item == null) return;

      final title = item.emojiOrIcon != null
          ? '${item.emojiOrIcon} ${item.title}'
          : item.title;
      final body = item.subtitle ?? '';
      final customId = 'aangan_${item.id}';

      await AppNotificationService.instance.addNotification(
        title: title,
        body: body,
        type: 'aangan',
        customId: customId,
      );

      await DailyNotificationService().showAdminStyleNotification(
        title: item.title,
        body: body.isNotEmpty ? body : 'Open the app to read more.',
      );
    } catch (e) {
      if (kDebugMode) print('AanganNotificationRealtimeService _onInsert: $e');
    }
  }
}
