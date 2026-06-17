import 'package:firebase_core/firebase_core.dart';
import 'push_notification_service_platform_stub.dart'
    if (dart.library.io) 'push_notification_service_platform_io.dart' as platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles Apple (APNs) / FCM push: permission, token, and saving to Supabase.
/// Requires Firebase project + GoogleService-Info.plist (iOS) and APNs key in Firebase.
/// Must be registered with [FirebaseMessaging.onBackgroundMessage] in [main]
/// **before** [runApp] (see Firebase Messaging docs). Not inside a widget or post-frame callback.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Background message: ${message.messageId}');
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Call once after Firebase.initializeApp() (e.g. from main.dart).
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      _initialized = true;
      await _refreshTokenAndSave();
      _messaging.onTokenRefresh.listen((_) => _refreshTokenAndSave());
    } catch (e) {
      if (kDebugMode) print('PushNotificationService init error: $e');
    }
  }

  /// Call when user enables notifications in settings (e.g. from NotificationsSettingsScreen).
  Future<bool> requestPermissionAndRegister() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _refreshTokenAndSave();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('PushNotificationService requestPermission error: $e');
      return false;
    }
  }

  Future<void> _refreshTokenAndSave() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        if (kDebugMode) print('FCM token obtained (length ${token.length})');
        await _upsertTokenToSupabase(token);
      }
    } catch (e) {
      if (kDebugMode) print('PushNotificationService getToken/upsert error: $e');
    }
  }

  Future<void> _upsertTokenToSupabase(String token) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      final platformName = platform.pushPlatform;
      await client.from('push_tokens').upsert(
        {
          'user_id': user.id,
          'token': token,
          'platform': platformName,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id',
      );
    } catch (e) {
      if (kDebugMode) print('Supabase push_tokens upsert error: $e');
    }
  }

  /// Optional: handle foreground messages (e.g. show in-app banner).
  static void setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message: ${message.notification?.title}');
      }
    });
  }
}
