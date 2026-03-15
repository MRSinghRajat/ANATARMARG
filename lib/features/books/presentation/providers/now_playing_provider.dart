import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Real-time now playing state - shared between mini player and full player.
class NowPlayingState {
  final String title;
  final String? subtitle;
  final String? coverUrl;
  final String? audioUrl;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isLoading;

  const NowPlayingState({
    required this.title,
    this.subtitle,
    this.coverUrl,
    this.audioUrl,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isLoading = false,
  });

  double get progress =>
      duration.inMilliseconds > 0
          ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
          : 0.0;

  String get positionFormatted {
    final m = position.inMinutes;
    final s = position.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get durationFormatted {
    final m = duration.inMinutes;
    final s = duration.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  NowPlayingState copyWith({
    String? title,
    String? subtitle,
    String? coverUrl,
    String? audioUrl,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isLoading,
  }) {
    return NowPlayingState(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NowPlayingNotifier extends StateNotifier<NowPlayingState?> {
  NowPlayingNotifier() : super(null);

  AudioPlayer? _player;
  bool _sourceLoaded = false;
  VoidCallback? _onCompleteCallback;

  void _disposePlayer() {
    _player?.dispose();
    _player = null;
    _sourceLoaded = false;
  }

  /// Register a callback that fires when the current track finishes.
  void setOnComplete(VoidCallback? callback) {
    _onCompleteCallback = callback;
  }

  void _setupListeners(AudioPlayer player) {
    player.onDurationChanged.listen((d) {
      if (state != null) {
        state = state!.copyWith(duration: d);
      }
    });
    player.onPositionChanged.listen((p) {
      if (state != null) {
        state = state!.copyWith(position: p);
      }
    });
    player.onPlayerComplete.listen((_) {
      if (state != null) {
        state = state!.copyWith(
          isPlaying: false,
          position: state!.duration,
          isLoading: false,
        );
      }
      _onCompleteCallback?.call();
    });
  }

  /// Set track and auto-start playback when audioUrl is provided.
  Future<void> setTrackAndPlay({
    required String title,
    String? subtitle,
    String? coverUrl,
    String? audioUrl,
  }) async {
    _disposePlayer();
    state = NowPlayingState(
      title: title,
      subtitle: subtitle,
      coverUrl: coverUrl,
      audioUrl: audioUrl,
    );

    if (audioUrl != null && audioUrl.isNotEmpty) {
      state = state!.copyWith(isLoading: true);
      _player = AudioPlayer();
      _setupListeners(_player!);
      try {
        await _player!.play(UrlSource(audioUrl));
        _sourceLoaded = true;
        if (state != null) {
          state = state!.copyWith(isPlaying: true, isLoading: false);
        }
      } catch (e) {
        if (state != null) {
          state = state!.copyWith(isLoading: false);
        }
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (state == null || _player == null) return;
    final hasAudio = state!.audioUrl != null && state!.audioUrl!.isNotEmpty;
    if (!hasAudio) return;

    if (state!.isPlaying) {
      await _player!.pause();
      state = state!.copyWith(isPlaying: false);
    } else {
      try {
        if (_sourceLoaded) {
          await _player!.resume();
        } else {
          await _player!.play(UrlSource(state!.audioUrl!));
          _sourceLoaded = true;
        }
        state = state!.copyWith(isPlaying: true);
      } catch (_) {}
    }
  }

  Future<void> seek(Duration position) async {
    if (_player != null) {
      await _player!.seek(position);
    }
  }

  void updateProgress(Duration position, Duration duration) {
    if (state != null) {
      state = state!.copyWith(position: position, duration: duration);
    }
  }

  void setPlaying(bool isPlaying) {
    if (state != null) {
      state = state!.copyWith(isPlaying: isPlaying);
    }
  }

  void clear() {
    _disposePlayer();
    state = null;
  }
}

final nowPlayingProvider = StateNotifierProvider<NowPlayingNotifier, NowPlayingState?>((ref) {
  return NowPlayingNotifier();
});
