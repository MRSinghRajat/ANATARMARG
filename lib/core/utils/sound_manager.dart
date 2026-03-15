import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundType {
  home,
  reading,
  prayer,
  books,
  forest,
  birdSinging, // Bird singing sound for background ambience
}

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  AudioPlayer? _oneShotPlayer;
  bool _isMuted = false;
  double _volume = 0.5;
  SoundType? _currentSound;
  bool _isInitialized = false;

  AudioPlayer get _oneShot {
    _oneShotPlayer ??= AudioPlayer();
    return _oneShotPlayer!;
  }

  bool get isMuted => _isMuted;
  double get volume => _volume;
  SoundType? get currentSound => _currentSound;

  /// Initialize sound manager and load saved preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool('sound_muted') ?? false;
      _volume = prefs.getDouble('sound_volume') ?? 0.5;

      // Start playing bird singing sound if not muted
      if (!_isMuted) {
        await playBirdSinging();
      }

      _isInitialized = true;
    } catch (e) {
      print('Error initializing SoundManager: $e');
    }
  }

  /// Play bird singing sound continuously throughout the app
  Future<void> playBirdSinging() async {
    await playBackgroundSound(SoundType.birdSinging);
  }

  Future<void> playBackgroundSound(SoundType type) async {
    if (_isMuted) return;
    // Avoid restarting the same sound (prevents overlapping / fast loop)
    if (_currentSound == type) return;

    _currentSound = type;
    String soundPath = _getSoundPath(type);

    try {
      await _backgroundPlayer.stop();
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.play(AssetSource(soundPath));
      await _backgroundPlayer.setVolume(_volume);
    } catch (e) {
      // Sound file not found - gracefully handle missing files
      print('Sound file not found: $soundPath. Continuing without sound.');
      _currentSound = null;
    }
  }

  Future<void> stopBackgroundSound() async {
    await _backgroundPlayer.stop();
    _currentSound = null;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);

    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('sound_volume', _volume);
    } catch (e) {
      print('Error saving volume: $e');
    }

    await _backgroundPlayer.setVolume(_volume);
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;

    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_muted', _isMuted);
    } catch (e) {
      print('Error saving mute state: $e');
    }

    if (_isMuted) {
      await _backgroundPlayer.setVolume(0.0);
      await stopBackgroundSound();
    } else {
      await _backgroundPlayer.setVolume(_volume);
      // Always resume bird singing when unmuted (it's the default background sound)
      await playBirdSinging();
    }
  }

  /// Play a one-shot sound (e.g. meditation inhale/exhale, step transition).
  /// Respects mute. Fails silently if asset is missing.
  Future<void> playOneShot(String assetPath) async {
    if (_isMuted) return;
    try {
      await _oneShot.setReleaseMode(ReleaseMode.release);
      await _oneShot.setVolume(_volume);
      await _oneShot.play(AssetSource(assetPath));
    } catch (_) {
      // Asset may not exist; ignore
    }
  }

  String _getSoundPath(SoundType type) {
    switch (type) {
      case SoundType.home:
        return 'sounds/home_ambience.mp3';
      case SoundType.reading:
        return 'sounds/forest_reading.mp3';
      case SoundType.prayer:
        return 'sounds/prayer_meditation.mp3';
      case SoundType.books:
        return 'sounds/library_ambience.mp3';
      case SoundType.forest:
        return 'sounds/forest_birds_sitar.mp3';
      case SoundType.birdSinging:
        return 'sounds/bird_singing.wav'; // Bird singing WAV file
    }
  }

  // Note: Sound files are optional. The app works without them.
  // See SOUND_FILES_GUIDE.md for instructions on adding sounds.

  void dispose() {
    _backgroundPlayer.dispose();
    _oneShotPlayer?.dispose();
  }
}
