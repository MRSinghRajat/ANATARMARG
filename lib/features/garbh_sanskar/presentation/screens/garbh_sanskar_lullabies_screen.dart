import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/garbh_sanskar_models.dart';
import '../../data/repositories/garbh_sanskar_repository.dart';
import '../providers/garbh_sanskar_providers.dart';

/// Lullaby library screen with audio player
class GarbhSanskarLullabiesScreen extends ConsumerStatefulWidget {
  const GarbhSanskarLullabiesScreen({super.key});

  @override
  ConsumerState<GarbhSanskarLullabiesScreen> createState() =>
      _GarbhSanskarLullabiesScreenState();
}

class _GarbhSanskarLullabiesScreenState
    extends ConsumerState<GarbhSanskarLullabiesScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final GarbhSanskarRepository _repo = GarbhSanskarRepository();

  Lullaby? _currentLullaby;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _selectedMood;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _positionSub =
        _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _durationSub =
        _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _stateSub = _audioPlayer.onPlayerStateChanged.listen((s) {
      if (mounted) {
        setState(() => _playerState = s);
        if (s == PlayerState.playing) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.value = 0;
        }
        if (s == PlayerState.completed) {
          _onLullabyCompleted();
        }
      }
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _audioPlayer.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _playLullaby(Lullaby lullaby) async {
    if (_currentLullaby?.id == lullaby.id &&
        _playerState == PlayerState.playing) {
      await _audioPlayer.pause();
      return;
    }
    setState(() {
      _currentLullaby = lullaby;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    final url = _repo.getLullabyAudioUrl(lullaby.audioStoragePath);
    if (url != null) {
      await _audioPlayer.play(UrlSource(url));
    }
  }

  void _onLullabyCompleted() {
    // Auto-play next lullaby
    final lullabies = ref.read(lullabiesProvider).valueOrNull ?? [];
    if (_currentLullaby == null || lullabies.isEmpty) return;
    final currentIndex =
        lullabies.indexWhere((l) => l.id == _currentLullaby!.id);
    if (currentIndex < lullabies.length - 1) {
      _playLullaby(lullabies[currentIndex + 1]);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final lullabiesAsync = ref.watch(lullabiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A06),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0A06),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'लोरियाँ',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                color: const Color(0xFF6366F1),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Lullabies',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Mood filter chips
          _buildMoodFilter(),

          // Lullaby list
          Expanded(
            child: lullabiesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF6366F1)),
              ),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: Colors.white)),
              ),
              data: (lullabies) {
                final filtered = _selectedMood == null
                    ? lullabies
                    : lullabies
                        .where((l) => l.mood == _selectedMood)
                        .toList();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final lullaby = filtered[i];
                    final isPlaying =
                        _currentLullaby?.id == lullaby.id &&
                            _playerState == PlayerState.playing;
                    final isCurrent =
                        _currentLullaby?.id == lullaby.id;

                    return _LullabyTile(
                      lullaby: lullaby,
                      isPlaying: isPlaying,
                      isCurrent: isCurrent,
                      onTap: () => _playLullaby(lullaby),
                    );
                  },
                );
              },
            ),
          ),

          // Mini player (shown when a lullaby is selected)
          if (_currentLullaby != null) _buildMiniPlayer(),
        ],
      ),
    );
  }

  Widget _buildMoodFilter() {
    final moods = [
      ('All', null, '🎵'),
      ('Bedtime', 'bedtime', '🌙'),
      ('Devotional', 'devotional', '🙏'),
      ('Calming', 'calming', '💆'),
      ('Playful', 'playful', '😄'),
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: moods.length,
        itemBuilder: (context, i) {
          final (label, value, emoji) = moods[i];
          final isSelected = _selectedMood == value;
          return GestureDetector(
            onTap: () => setState(() => _selectedMood = value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF1A1D23),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : Colors.white12,
                ),
              ),
              child: Text(
                '$emoji $label',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniPlayer() {
    final lullaby = _currentLullaby!;
    final isPlaying = _playerState == PlayerState.playing;
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1D23),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF6366F1),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFF6366F1),
              overlayColor:
                  const Color(0xFF6366F1).withOpacity(0.2),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 5),
              trackHeight: 2,
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) {
                final newPos = Duration(
                  milliseconds:
                      (v * _duration.inMilliseconds).round(),
                );
                _audioPlayer.seek(newPos);
              },
            ),
          ),
          Row(
            children: [
              // Lullaby info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lullaby.displayTitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.white38),
                    ),
                  ],
                ),
              ),
              // Controls
              Row(
                children: [
                  // Previous
                  IconButton(
                    icon: const Icon(Icons.skip_previous,
                        color: Colors.white54),
                    onPressed: () {
                      final lullabies =
                          ref.read(lullabiesProvider).valueOrNull ?? [];
                      final idx = lullabies.indexWhere(
                          (l) => l.id == lullaby.id);
                      if (idx > 0) _playLullaby(lullabies[idx - 1]);
                    },
                  ),
                  // Play/Pause
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) => Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6366F1).withOpacity(
                            isPlaying
                                ? 0.2 +
                                    (_pulseController.value * 0.1)
                                : 0.2),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: const Color(0xFF6366F1),
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            _audioPlayer.pause();
                          } else {
                            _playLullaby(lullaby);
                          }
                        },
                      ),
                    ),
                  ),
                  // Next
                  IconButton(
                    icon: const Icon(Icons.skip_next,
                        color: Colors.white54),
                    onPressed: () {
                      final lullabies =
                          ref.read(lullabiesProvider).valueOrNull ?? [];
                      final idx = lullabies.indexWhere(
                          (l) => l.id == lullaby.id);
                      if (idx < lullabies.length - 1) {
                        _playLullaby(lullabies[idx + 1]);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LullabyTile extends StatelessWidget {
  final Lullaby lullaby;
  final bool isPlaying;
  final bool isCurrent;
  final VoidCallback onTap;

  const _LullabyTile({
    required this.lullaby,
    required this.isPlaying,
    required this.isCurrent,
    required this.onTap,
  });

  String get _moodEmoji {
    switch (lullaby.mood) {
      case 'bedtime':
        return '🌙';
      case 'devotional':
        return '🙏';
      case 'calming':
        return '💆';
      case 'playful':
        return '😄';
      default:
        return '🎵';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrent
              ? const Color(0xFF1A1530)
              : const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent
                ? const Color(0xFF6366F1).withOpacity(0.5)
                : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            // Play indicator / number
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(
                    isCurrent ? 0.3 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: isPlaying
                    ? const Icon(Icons.pause,
                        color: Color(0xFF6366F1), size: 22)
                    : isCurrent
                        ? const Icon(Icons.play_arrow,
                            color: Color(0xFF6366F1), size: 22)
                        : Text(
                            '🌙',
                            style: const TextStyle(fontSize: 20),
                          ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lullaby.displayTitle,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: isCurrent
                          ? const Color(0xFF6366F1)
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (lullaby.deityAssociated != null)
                    Text(
                      lullaby.deityAssociated!
                          .substring(0, 1)
                          .toUpperCase() +
                          lullaby.deityAssociated!.substring(1),
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.white54),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _moodEmoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lullaby.mood ?? '',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.white38),
                      ),
                      if (lullaby.durationSeconds != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          lullaby.formattedDuration,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.white38),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Lyrics button
            if (lullaby.lyrics != null)
              IconButton(
                icon: const Icon(Icons.lyrics_outlined,
                    color: Colors.white38, size: 20),
                onPressed: () => _showLyrics(context, lullaby),
              ),
          ],
        ),
      ),
    );
  }

  void _showLyrics(BuildContext context, Lullaby lullaby) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D23),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lullaby.displayTitle,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  color: const Color(0xFF6366F1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (lullaby.lyrics != null)
                Text(
                  lullaby.lyrics!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    color: Colors.white,
                    height: 2.0,
                  ),
                ),
              if (lullaby.transliteration != null) ...[
                const SizedBox(height: 16),
                Text(
                  lullaby.transliteration!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white60,
                    fontStyle: FontStyle.italic,
                    height: 1.8,
                  ),
                ),
              ],
              if (lullaby.translation != null) ...[
                const SizedBox(height: 16),
                Text(
                  lullaby.translation!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.4),
                    height: 1.6,
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
