import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/sound_manager.dart';
import 'language_settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final SoundManager _soundManager = SoundManager();
  bool _isSoundEnabled = true;
  double _soundVolume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadSoundSettings();
  }

  Future<void> _loadSoundSettings() async {
    setState(() {
      _isSoundEnabled = !_soundManager.isMuted;
      _soundVolume = _soundManager.volume;
    });
  }

  Future<void> _toggleSound() async {
    await _soundManager.toggleMute();
    setState(() {
      _isSoundEnabled = !_soundManager.isMuted;
    });
  }

  Future<void> _updateVolume(double value) async {
    setState(() {
      _soundVolume = value;
    });
    await _soundManager.setVolume(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: AppColors.primaryBackground,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.warmOrange,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Spiritual Learner',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Settings Section
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Sound Settings Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.music_note,
                                color: AppColors.warmOrange,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Background Sound',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isSoundEnabled,
                            onChanged: (value) => _toggleSound(),
                            activeTrackColor: AppColors.warmOrange,
                            activeThumbColor: Colors.white,
                          ),
                        ],
                      ),
                      if (_isSoundEnabled) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Volume',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.volume_mute, size: 20),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.warmOrange,
                                  thumbColor: AppColors.warmOrange,
                                ),
                                child: Slider(
                                  value: _soundVolume,
                                  onChanged: _updateVolume,
                                  min: 0.0,
                                  max: 1.0,
                                ),
                              ),
                            ),
                            const Icon(Icons.volume_up, size: 20),
                          ],
                        ),
                        Text(
                          'Bird singing ambience plays throughout the app',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.secondaryText,
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Other Settings (placeholder for future features)
              Text(
                'Other',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(
                        context, AppRouter.notificationsSettings);
                  },
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSettingsScreen(),
                      ),
                    );
                  },
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Show about dialog
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
