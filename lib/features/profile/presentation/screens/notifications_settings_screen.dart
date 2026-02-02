import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';

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
                  subtitle: 'Get daily inspiration and reminders',
                  value: _dailyReminders,
                  onChanged: (value) {
                    setState(() => _dailyReminders = value);
                    _updateSetting('notifications_daily', value);
                  },
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
