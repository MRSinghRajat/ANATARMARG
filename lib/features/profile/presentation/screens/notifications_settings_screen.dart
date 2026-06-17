import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/aangan_notification_realtime_service.dart';
import '../../../../core/services/daily_notification_service.dart';
import '../../../../core/services/notification_preferences.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';

/// Profile notification center: master switch, per-type toggles, link to message inbox.
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _masterOn = true;
  bool _dailyReminders = true;
  bool _prayerAlerts = true;
  bool _newContentUpdates = true;
  bool _readingReminder = true;
  bool _isLoading = true;

  static const _bg = AppColors.ashramBackgroundDark;
  static const _accent = AppColors.ashramSaffron;
  static const _card = AppColors.cardDark;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _masterOn = prefs.getBool(NotificationPreferences.keyMaster) ?? true;
        _dailyReminders =
            prefs.getBool(NotificationPreferences.keyDaily) ?? true;
        _prayerAlerts =
            prefs.getBool(NotificationPreferences.keyPrayer) ?? true;
        _newContentUpdates =
            prefs.getBool(NotificationPreferences.keyUpdates) ?? true;
        _readingReminder =
            prefs.getBool(NotificationPreferences.keyReading) ?? true;
        _isLoading = false;
      });
      if (_masterOn &&
          (_dailyReminders ||
              _prayerAlerts ||
              _newContentUpdates ||
              _readingReminder)) {
        await PushNotificationService().requestPermissionAndRegister();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setMaster(bool enabled) async {
    await NotificationPreferences.setMasterEnabled(enabled);
    setState(() => _masterOn = enabled);
    await DailyNotificationService().rescheduleAllFromPreferences();
    if (enabled) {
      final code =
          WidgetsBinding.instance.platformDispatcher.locale.countryCode;
      final region =
          (code != null && code.isNotEmpty) ? code : null;
      AanganNotificationRealtimeService.instance.stop();
      AanganNotificationRealtimeService.instance.start(userRegion: region);
      if (_dailyReminders ||
          _prayerAlerts ||
          _newContentUpdates ||
          _readingReminder) {
        await PushNotificationService().requestPermissionAndRegister();
      }
    } else {
      AanganNotificationRealtimeService.instance.stop();
    }
  }

  Future<void> _updateChannel(String key, bool value) async {
    await NotificationPreferences.setBool(key, value);
    if (value) {
      await PushNotificationService().requestPermissionAndRegister();
    }
    if (key == NotificationPreferences.keyDaily) {
      await DailyNotificationService.updateFromDailyReminderSetting(value);
    } else if (key == NotificationPreferences.keyReading) {
      await DailyNotificationService.updateFromReadingReminderSetting(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notification center',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _accent),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _inboxCard(context),
                const SizedBox(height: 20),
                Text(
                  'Delivery',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                _masterCard(),
                const SizedBox(height: 20),
                Text(
                  'Notification types',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                _tile(
                  title: 'Daily reminders',
                  subtitle: '6:00 AM tasks ready · 6:00 PM complete reminder',
                  value: _dailyReminders,
                  enabled: _masterOn,
                  onChanged: (v) {
                    setState(() => _dailyReminders = v);
                    _updateChannel(NotificationPreferences.keyDaily, v);
                  },
                ),
                if (_masterOn && _dailyReminders)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4, bottom: 8),
                    child: TextButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await DailyNotificationService()
                            .showTestDailyNotification();
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Test notification in a few seconds',
                                style: GoogleFonts.poppins(),
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: _card,
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.notifications_active_outlined,
                        size: 18,
                        color: _accent,
                      ),
                      label: Text(
                        'Send test now',
                        style: GoogleFonts.poppins(
                          color: _accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                _tile(
                  title: 'Prayer alerts',
                  subtitle: 'Reminders for prayer times (when available)',
                  value: _prayerAlerts,
                  enabled: _masterOn,
                  onChanged: (v) {
                    setState(() => _prayerAlerts = v);
                    _updateChannel(NotificationPreferences.keyPrayer, v);
                  },
                ),
                _tile(
                  title: 'Messages & updates',
                  subtitle:
                      'Community messages and new content from Antar मार्ग',
                  value: _newContentUpdates,
                  enabled: _masterOn,
                  onChanged: (v) {
                    setState(() => _newContentUpdates = v);
                    _updateChannel(NotificationPreferences.keyUpdates, v);
                  },
                ),
                _tile(
                  title: 'Continue reading',
                  subtitle:
                      'Daily 8:00 PM reminder for the book you were reading',
                  value: _readingReminder,
                  enabled: _masterOn,
                  onChanged: (v) {
                    setState(() => _readingReminder = v);
                    _updateChannel(NotificationPreferences.keyReading, v);
                  },
                ),
              ],
            ),
    );
  }

  Widget _inboxCard(BuildContext context) {
    return Material(
      color: _card.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(AppRouter.notificationsList);
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(Icons.inbox_rounded, color: _accent, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message inbox',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Open alerts and community messages',
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _masterCard() {
    return _tile(
      title: 'All notifications',
      subtitle: _masterOn
          ? 'On — you can adjust types below'
          : 'Off — no alerts, reminders, or inbox additions from the app',
      value: _masterOn,
      enabled: true,
      prominent: true,
      onChanged: (v) => _setMaster(v),
    );
  }

  Widget _tile({
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
    bool prominent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: prominent
            ? _accent.withValues(alpha: 0.12)
            : _card.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: enabled ? Colors.white : Colors.white38,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: enabled ? Colors.white60 : Colors.white30,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeTrackColor: _accent.withValues(alpha: 0.55),
                activeThumbColor: Colors.white,
                inactiveThumbColor: Colors.white38,
                inactiveTrackColor: Colors.white12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
