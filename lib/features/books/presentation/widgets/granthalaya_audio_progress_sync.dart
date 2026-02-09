import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_providers.dart';
import '../providers/now_playing_provider.dart';

/// Syncs now playing progress to user_audio_progress table periodically.
/// Invisible widget - place in listen-mode tree.
class GranthalayaAudioProgressSync extends ConsumerStatefulWidget {
  final Widget child;

  const GranthalayaAudioProgressSync({super.key, required this.child});

  @override
  ConsumerState<GranthalayaAudioProgressSync> createState() => _GranthalayaAudioProgressSyncState();
}

class _GranthalayaAudioProgressSyncState extends ConsumerState<GranthalayaAudioProgressSync> {
  Timer? _syncTimer;

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  void _scheduleSync(NowPlayingState? state) {
    _syncTimer?.cancel();
    if (state == null) return;

    _syncTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      final s = ref.read(nowPlayingProvider);
      if (s == null) {
        _syncTimer?.cancel();
        return;
      }
      await ref.read(granthalayaDataSourceProvider).upsertUserAudioProgress(
            title: s.title,
            tag: s.subtitle ?? '',
            subtitle: s.subtitle,
            imageUrl: s.coverUrl,
            audioUrl: s.audioUrl,
            currentTimeSeconds: s.position.inSeconds,
            totalTimeSeconds: s.duration.inSeconds > 0 ? s.duration.inSeconds : 0,
          );
      ref.invalidate(userAudioProgressProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nowPlayingProvider);
    ref.listen<NowPlayingState?>(nowPlayingProvider, (prev, next) {
      _syncTimer?.cancel();
      if (next != null) {
        _scheduleSync(next);
      }
    });
    if (state != null && _syncTimer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleSync(state));
    }
    return widget.child;
  }
}
