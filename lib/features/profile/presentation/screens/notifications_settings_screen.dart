import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/services/daily_notification_service.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _dailyReminders = true;
  bool _prayerAlerts = true;
  bool _newContentUpdates = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _dailyReminders = prefs.getBool('notifications_daily') ?? true;
          _prayerAlerts = prefs.getBool('notifications_prayer') ?? true;
          _newContentUpdates = prefs.getBool('notifications_updates') ?? true;
          _isLoading = false;
        });
        final anyOn = _dailyReminders || _prayerAlerts || _newContentUpdates;
        if (anyOn) PushNotificationService().requestPermissionAndRegister();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
      if (value) {
        await PushNotificationService().requestPermissionAndRegister();
      }
      if (key == 'notifications_daily') {
        await DailyNotificationService.updateFromDailyReminderSetting(value);
      }
    } catch (_) {
      // Ignore - settings will use in-memory value
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primaryBackground,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNotificationTile(
                  title: 'Daily Reminders',
                  subtitle: '6:00 AM tasks ready · 6:00 PM complete reminder',
                  value: _dailyReminders,
                  onChanged: (value) {
                    setState(() => _dailyReminders = value);
                    _updateSetting('notifications_daily', value);
                  },
                ),
                if (_dailyReminders)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: TextButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await DailyNotificationService().showTestDailyNotification();
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Test notification in 3 seconds'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.notifications_active_outlined, size: 18),
                      label: const Text('Send test now'),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildNotificationTile(
                  title: 'Prayer Alerts',
                  subtitle: 'Reminders for prayer times',
                  value: _prayerAlerts,
                  onChanged: (value) {
                    setState(() => _prayerAlerts = value);
                    _updateSetting('notifications_prayer', value);
                  },
                ),
                const SizedBox(height: 16),
                _buildNotificationTile(
                  title: 'New Content Updates',
                  subtitle: 'Be notified when new content is added',
                  value: _newContentUpdates,
                  onChanged: (value) {
                    setState(() => _newContentUpdates = value);
                    _updateSetting('notifications_updates', value);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.warmOrange,
              activeThumbColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
