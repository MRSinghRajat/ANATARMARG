import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'notification_preferences.dart';

/// Schedules daily task reminders:
/// - 6:00 AM: "Your daily tasks are ready."
/// - 6:00 PM: "Complete your daily tasks."
/// Respects the "Daily Reminders" toggle in notification settings.
class DailyNotificationService {
  static const int _dailyTaskNotificationId = 100;
  static const int _eveningReminderNotificationId = 101;
  static const int _readingReminderNotificationId = 102;
  static const int _adminMessageBaseId = 500;
  static const String _channelId = 'daily_tasks';
  static const String _channelName = 'Daily reminders';
  static const String _readingChannelId = 'reading_reminder';
  static const String _readingChannelName = 'Reading reminders';
  static const String _adminChannelId = 'admin_updates';
  static const String _adminChannelName = 'Messages & updates';

  static const String _prefReadingBookTitle = 'reading_reminder_book_title';

  static final DailyNotificationService _instance = DailyNotificationService._internal();
  factory DailyNotificationService() => _instance;
  DailyNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Call once from main.dart after WidgetsBinding.ensureInitialized().
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      final deviceTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTz));
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(requestAlertPermission: false),
        ),
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      await _createChannel();
      await _createReadingChannel();
      await _createAdminChannel();
      _initialized = true;
      await _rescheduleFromPrefs();
    } catch (e) {
      if (kDebugMode) print('DailyNotificationService init error: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Optional: navigate to Ashram/Home when user taps the notification
  }

  Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Daily task and reminder notifications',
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _createReadingChannel() async {
    const channel = AndroidNotificationChannel(
      _readingChannelId,
      _readingChannelName,
      description: 'Daily reminder to continue your book',
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _createAdminChannel() async {
    const channel = AndroidNotificationChannel(
      _adminChannelId,
      _adminChannelName,
      description: 'New messages from your spiritual community',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Reads "Daily Reminders" from prefs and schedules or cancels the daily notification.
  Future<void> _rescheduleFromPrefs() async {
    try {
      final master = await NotificationPreferences.isMasterEnabled();
      if (!master) {
        await cancelDailyTaskNotification();
        await cancelReadingReminder();
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final dailyOn = prefs.getBool(NotificationPreferences.keyDaily) ?? true;
      if (dailyOn) {
        await scheduleDailyTaskNotification();
      } else {
        await cancelDailyTaskNotification();
      }
      final readingOn = prefs.getBool(NotificationPreferences.keyReading) ?? true;
      if (readingOn) {
        await scheduleReadingReminderFromPrefs();
      } else {
        await cancelReadingReminder();
      }
    } catch (_) {}
  }

  /// Re-read prefs and reschedule daily + reading (e.g. after master toggle).
  Future<void> rescheduleAllFromPreferences() async {
    await _rescheduleFromPrefs();
  }

  /// Daily reminder to continue the last-read book (8:00 PM local).
  Future<void> scheduleReadingReminderFromPrefs() async {
    if (!_initialized) return;
    if (!await NotificationPreferences.shouldDeliver(NotificationPreferences.keyReading)) {
      await cancelReadingReminder();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final title = prefs.getString(_prefReadingBookTitle);
      if (title == null || title.isEmpty) {
        await cancelReadingReminder();
        return;
      }
      await _plugin.cancel(_readingReminderNotificationId);
      await _plugin.zonedSchedule(
        _readingReminderNotificationId,
        'Antar मार्ग',
        'Continue reading: $title',
        _nextTime(20, 0),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _readingChannelId,
            _readingChannelName,
            channelDescription: 'Continue your sacred reading',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) print('Reading reminder schedule error: $e');
    }
  }

  Future<void> cancelReadingReminder() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_readingReminderNotificationId);
    } catch (_) {}
  }

  /// Show a one-shot local notification (e.g. new Supabase message for this user).
  Future<void> showAdminStyleNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    if (!await NotificationPreferences.shouldDeliver(NotificationPreferences.keyUpdates)) {
      return;
    }
    try {
      final id = _adminMessageBaseId + (DateTime.now().millisecondsSinceEpoch % 9000);
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _adminChannelId,
            _adminChannelName,
            channelDescription: 'Targeted messages',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) print('showAdminStyleNotification error: $e');
    }
  }

  /// Call when user toggles "Daily Reminders" on → schedule both 6 AM and 6 PM.
  Future<void> scheduleDailyTaskNotification() async {
    if (!_initialized) return;
    if (!await NotificationPreferences.shouldDeliver(NotificationPreferences.keyDaily)) {
      await cancelDailyTaskNotification();
      return;
    }
    try {
      await _plugin.zonedSchedule(
        _dailyTaskNotificationId,
        'Antar मार्ग',
        'Your daily tasks are ready.',
        _nextTime(6, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Daily task reminders',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      await _plugin.zonedSchedule(
        _eveningReminderNotificationId,
        'Antar मार्ग',
        'Complete your daily tasks.',
        _nextTime(18, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Daily task reminders',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      if (kDebugMode) print('Daily task notifications scheduled: 6:00 AM and 6:00 PM.');
    } catch (e) {
      if (kDebugMode) print('DailyNotificationService schedule error: $e');
    }
  }

  /// Call when user toggles "Daily Reminders" off → cancel both.
  Future<void> cancelDailyTaskNotification() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_dailyTaskNotificationId);
      await _plugin.cancel(_eveningReminderNotificationId);
      if (kDebugMode) print('Daily task notifications cancelled.');
    } catch (_) {}
  }

  tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (now.isAfter(at) || now.isAtSameMomentAs(at)) {
      at = at.add(const Duration(days: 1));
    }
    return at;
  }

  /// Call after the user changes the "Daily Reminders" setting.
  static Future<void> updateFromDailyReminderSetting(bool dailyRemindersOn) async {
    final service = DailyNotificationService();
    if (!service.isInitialized) return;
    if (dailyRemindersOn) {
      await service.scheduleDailyTaskNotification();
    } else {
      await service.cancelDailyTaskNotification();
    }
  }

  static Future<void> updateFromReadingReminderSetting(bool on) async {
    final service = DailyNotificationService();
    if (!service.isInitialized) return;
    if (on) {
      await service.scheduleReadingReminderFromPrefs();
    } else {
      await service.cancelReadingReminder();
    }
  }

  /// Call when daily tasks have just been generated (e.g. user opened app and tasks were created).
  /// Shows a one-time notification now if Daily Reminders is on.
  Future<void> notifyTasksGeneratedNow({int? pendingCount}) async {
    if (!_initialized) return;
    try {
      if (!await NotificationPreferences.shouldDeliver(NotificationPreferences.keyDaily)) {
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final dailyOn = prefs.getBool(NotificationPreferences.keyDaily) ?? true;
      if (!dailyOn) return;
      final body = pendingCount != null && pendingCount > 0
          ? 'You have $pendingCount tasks to complete. Open Ashram to continue.'
          : 'Your daily tasks are ready. Open Ashram to complete them.';
      await _plugin.zonedSchedule(
        _dailyTaskNotificationId + 2,
        'Antar मार्ग',
        body,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Daily task reminders',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) print('DailyNotificationService notifyTasksGeneratedNow error: $e');
    }
  }

  /// Show the same "daily tasks ready" notification in a few seconds (for testing).
  Future<void> showTestDailyNotification() async {
    if (!_initialized) return;
    if (!await NotificationPreferences.shouldDeliver(NotificationPreferences.keyDaily)) {
      return;
    }
    try {
      await _plugin.zonedSchedule(
        _dailyTaskNotificationId + 1,
        'Antar मार्ग',
        'Your daily tasks are ready.',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Daily task reminders',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) print('Test daily notification error: $e');
    }
  }
}
