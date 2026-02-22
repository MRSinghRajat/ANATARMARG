import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/garbh_sanskar_models.dart';
import '../../data/repositories/garbh_sanskar_repository.dart';
import '../providers/garbh_sanskar_providers.dart';

/// Shows a list of content items for a given phase + type
class GarbhSanskarContentListScreen extends ConsumerWidget {
  final String phase;
  final String contentType;
  final String title;
  final String titleHindi;
  final Color color;
  final String emoji;
  final String? initialContentId;

  const GarbhSanskarContentListScreen({
    super.key,
    required this.phase,
    required this.contentType,
    required this.title,
    required this.titleHindi,
    required this.color,
    required this.emoji,
    this.initialContentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(
      contentByTypeProvider((phase: phase, type: contentType)),
    );
    final completedIds = ref.watch(completedContentIdsProvider).valueOrNull ?? {};

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
              titleHindi,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: contentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9933)),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'Coming soon...',
                    style: GoogleFonts.inter(color: Colors.white54),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final isCompleted = completedIds.contains(item.id);
              return _ContentListTile(
                content: item,
                color: color,
                isCompleted: isCompleted,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GarbhSanskarContentDetailScreen(
                      content: item,
                      color: color,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ContentListTile extends StatelessWidget {
  final GarbhSanskarContent content;
  final Color color;
  final bool isCompleted;
  final VoidCallback onTap;

  const _ContentListTile({
    required this.content,
    required this.color,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? color.withOpacity(0.5)
                : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  content.typeInfo.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.displayTitle,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (content.subtitle != null)
                    Text(
                      content.subtitle!,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.white54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (content.durationSeconds != null) ...[
                        Icon(Icons.access_time,
                            size: 12, color: Colors.white38),
                        const SizedBox(width: 3),
                        Text(
                          content.formattedDuration,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.white38),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        '+${content.coinsReward} 🪙',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                      if (content.isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Icon(Icons.check_circle, color: color, size: 22)
            else
              Icon(Icons.play_circle_outline,
                  color: color.withOpacity(0.6), size: 22),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CONTENT DETAIL / PLAYER SCREEN
// ============================================================

class GarbhSanskarContentDetailScreen extends ConsumerStatefulWidget {
  final GarbhSanskarContent content;
  final Color color;

  const GarbhSanskarContentDetailScreen({
    super.key,
    required this.content,
    required this.color,
  });

  @override
  ConsumerState<GarbhSanskarContentDetailScreen> createState() =>
      _GarbhSanskarContentDetailScreenState();
}

class _GarbhSanskarContentDetailScreenState
    extends ConsumerState<GarbhSanskarContentDetailScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _hasCompleted = false;
  bool _showTransliteration = false;
  bool _showTranslation = false;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;

  late AnimationController _pulseController;
  late AnimationController _completionController;
  late Animation<double> _completionScale;

  final GarbhSanskarRepository _repo = GarbhSanskarRepository();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _completionScale = CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    );

    _positionSub = _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
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
        if (s == PlayerState.completed && !_hasCompleted) {
          _onContentCompleted();
        }
      }
    });

    // Mark as started
    _repo.startContent(widget.content.id);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      final audioUrl = _repo.getAudioUrl(widget.content.audioStoragePath);
      if (audioUrl != null) {
        await _audioPlayer.play(UrlSource(audioUrl));
      }
    }
  }

  Future<void> _onContentCompleted() async {
    setState(() => _hasCompleted = true);
    _completionController.forward();
    final coins = await _repo.completeContent(
      widget.content.id,
      _position.inSeconds,
      widget.content.coinsReward,
    );
    if (mounted && coins > 0) {
      _showCoinReward(coins);
    }
  }

  void _showCoinReward(int coins) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2A1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Text('🪙', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(
              '+$coins coins earned! 🙏',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;
    final color = widget.color;
    final hasAudio = content.audioStoragePath != null &&
        content.audioStoragePath!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A06),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0A06),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_hasCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ScaleTransition(
                scale: _completionScale,
                child: const Icon(Icons.check_circle,
                    color: Color(0xFFFF9933), size: 26),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      content.typeInfo.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.displayTitle,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (content.subtitle != null)
                        Text(
                          content.subtitle!,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.white60),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Audio player (if audio available)
            if (hasAudio) ...[
              _buildAudioPlayer(color),
              const SizedBox(height: 24),
            ],

            // Description
            if (content.description != null) ...[
              Text(
                content.description!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Sanskrit / body text
            if (content.bodyText != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Text(
                  content.bodyText!,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Transliteration toggle
            if (content.transliteration != null) ...[
              _buildToggleSection(
                label: 'Transliteration (Roman)',
                isOpen: _showTransliteration,
                onToggle: () => setState(
                    () => _showTransliteration = !_showTransliteration),
                content: content.transliteration!,
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Translation toggle
            if (content.translation != null) ...[
              _buildToggleSection(
                label: 'Meaning (English)',
                isOpen: _showTranslation,
                onToggle: () =>
                    setState(() => _showTranslation = !_showTranslation),
                content: content.translation!,
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white60,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Benefits
            if (content.benefits.isNotEmpty) ...[
              Text(
                'Benefits',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...content.benefits.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✓ ',
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          b,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.white60),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Mark complete button (if no audio)
            if (!hasAudio && !_hasCompleted) ...[
              GestureDetector(
                onTap: _onContentCompleted,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Mark as Complete  +${content.coinsReward} 🪙',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(Color color) {
    final isPlaying = _playerState == PlayerState.playing;
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Pulse animation when playing
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(
                      isPlaying ? 0.1 + (_pulseController.value * 0.1) : 0.1),
                  border: Border.all(
                    color: color.withOpacity(
                        isPlaying ? 0.5 + (_pulseController.value * 0.3) : 0.3),
                    width: isPlaying ? 2 : 1,
                  ),
                ),
                child: IconButton(
                  iconSize: 40,
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: color,
                  ),
                  onPressed: _togglePlay,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Progress bar
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: Colors.white12,
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 3,
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) {
                final newPos = Duration(
                  milliseconds: (v * _duration.inMilliseconds).round(),
                );
                _audioPlayer.seek(newPos);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.white38),
              ),
              Text(
                _formatDuration(_duration),
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection({
    required String label,
    required bool isOpen,
    required VoidCallback onToggle,
    required String content,
    required TextStyle textStyle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  isOpen ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white38,
                  size: 20,
                ),
              ],
            ),
            if (isOpen) ...[
              const SizedBox(height: 10),
              Text(content, style: textStyle),
            ],
          ],
        ),
      ),
    );
  }
}
