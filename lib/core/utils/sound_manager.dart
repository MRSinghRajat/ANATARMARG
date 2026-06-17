import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundType {
  home,
  reading,
  prayer,
  books,
  forest,
  /// Default looping background music (Profile → Background Sound).
  defaultBackground,
}

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  bool _isMuted = false;
  double _volume = 0.5;
  SoundType? _currentSound;
  bool _isInitialized = false;
  Future<void>? _initializeFuture;

  /// True when Profile "Background Sound" is on (`!isMuted`).
  final ValueNotifier<bool> backgroundSoundEnabled = ValueNotifier<bool>(true);

  /// Profile volume slider 0–1; Mandir WebView Aarti audio listens via [AanganScreen].
  final ValueNotifier<double> backgroundVolume = ValueNotifier<double>(0.5);

  bool get isMuted => _isMuted;
  double get volume => _volume;
  SoundType? get currentSound => _currentSound;

  /// Initialize sound manager and load saved preferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    _initializeFuture ??= _initializeBody();
    try {
      await _initializeFuture!;
    } finally {
      _initializeFuture = null;
    }
  }

  Future<void> _initializeBody() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // First install: no key yet — treat as ON and persist so Profile/onboarding stay consistent.
      if (!prefs.containsKey('sound_muted')) {
        await prefs.setBool('sound_muted', false);
      }
      _isMuted = prefs.getBool('sound_muted') ?? false;
      _volume = prefs.getDouble('sound_volume') ?? 0.5;
      backgroundSoundEnabled.value = !_isMuted;
      backgroundVolume.value = _volume;

      if (!_isMuted) {
        await playDefaultBackgroundMusic();
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing SoundManager: $e');
      }
    }
  }

  /// Loops [backgroundmusic.mp3] until the user turns off Background Sound in Profile.
  Future<void> playDefaultBackgroundMusic() async {
    await playBackgroundSound(SoundType.defaultBackground);
  }

  Future<void> playBackgroundSound(SoundType type) async {
    if (_isMuted) return;
    // Avoid restarting the same sound (prevents overlapping / fast loop)
    if (_currentSound == type) return;

    _currentSound = type;
    String soundPath = _getSoundPath(type);

    try {
      await _backgroundPlayer.stop();
      if (_isMuted) {
        _currentSound = null;
        return;
      }
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      if (_isMuted) {
        _currentSound = null;
        return;
      }
      await _backgroundPlayer.play(AssetSource(soundPath));
      if (_isMuted) {
        await _backgroundPlayer.stop();
        _currentSound = null;
        return;
      }
      await _backgroundPlayer.setVolume(_volume);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sound file not found: $soundPath. Continuing without sound.');
      }
      _currentSound = null;
    }
  }

  Future<void> stopBackgroundSound() async {
    await _backgroundPlayer.stop();
    _currentSound = null;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    backgroundVolume.value = _volume;
    // Apply to hardware immediately (don’t wait for prefs I/O).
    await _backgroundPlayer.setVolume(_isMuted ? 0.0 : _volume);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('sound_volume', _volume);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving volume: $e');
      }
    }
  }

  /// Sets Profile "Background Sound" on/off without relying on toggle heuristics.
  Future<void> setBackgroundSoundEnabled(bool enabled) async {
    if ((!_isMuted) == enabled) {
      backgroundSoundEnabled.value = enabled;
      return;
    }
    await toggleMute();
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    backgroundSoundEnabled.value = !_isMuted;

    if (_isMuted) {
      await stopBackgroundSound();
      await _backgroundPlayer.setVolume(0.0);
    } else {
      await _backgroundPlayer.setVolume(_volume);
      await playDefaultBackgroundMusic();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_muted', _isMuted);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving mute state: $e');
      }
    }
  }

  /// Single bundled asset: background loop for Profile / app ambience. All other audio uses remote URLs.
  String _getSoundPath(SoundType _) => 'sounds/backgroundmusic.mp3';

  void dispose() {
    _backgroundPlayer.dispose();
  }
}
