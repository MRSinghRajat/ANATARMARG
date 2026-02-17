import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Chant {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final String audioUrl;
  final int? durationSeconds;

  const _Chant({
    required this.id,
    required this.title,
    this.description,
    this.category,
    required this.audioUrl,
    this.durationSeconds,
  });

  factory _Chant.fromJson(Map<String, dynamic> json) {
    return _Chant(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Chant',
      description: json['description'] as String?,
      category: json['category'] as String?,
      audioUrl: json['audio_url'] as String? ?? '',
      durationSeconds: json['duration_seconds'] as int?,
    );
  }
}

class ChantPlayerScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const ChantPlayerScreen({super.key, this.onComplete});

  @override
  State<ChantPlayerScreen> createState() => _ChantPlayerScreenState();
}

class _ChantPlayerScreenState extends State<ChantPlayerScreen>
    with TickerProviderStateMixin {
  List<_Chant> _chants = [];
  bool _loading = true;
  String? _error;

  // Playback state
  _Chant? _currentChant;
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _hasListened = false;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;

  late AnimationController _pulseController;
  late AnimationController _completionController;
  late Animation<double> _completionScale;

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
          _pulseController.value = 0.0;
        }
        if (s == PlayerState.completed) {
          _hasListened = true;
        }
      }
    });

    _fetchChants();
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

  Future<void> _fetchChants() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('audio_chants')
          .select()
          .eq('is_active', true)
          .order('is_featured', ascending: false);

      final list = data as List;
      setState(() {
        _chants = list
            .map((e) => _Chant.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load chants: $e';
        _loading = false;
      });
    }
  }

  Future<void> _playChant(_Chant chant) async {
    if (_currentChant?.id == chant.id &&
        _playerState == PlayerState.playing) {
      await _audioPlayer.pause();
      return;
    }

    if (_currentChant?.id == chant.id &&
        _playerState == PlayerState.paused) {
      await _audioPlayer.resume();
      return;
    }

    setState(() {
      _currentChant = chant;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(chant.audioUrl));
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: Colors.orange))
            : _hasListened
                ? _buildCompletion()
                : _buildMain(),
      ),
    );
  }

  Widget _buildMain() {
    return Column(
      children: [
        // App bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () {
                  _audioPlayer.stop();
                  Navigator.pop(context);
                },
              ),
              const Spacer(),
              Text(
                'Sacred Chants',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Dharmic intro
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.withValues(alpha: 0.15),
                          Colors.deepOrange.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'नादब्रह्म',
                          style: GoogleFonts.notoSerifDevanagari(
                            color: Colors.orange.shade200,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nada Brahma — The Universe is Sound',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'In the Vedic tradition, sound (Nada) is the primordial vibration from which '
                          'creation emerged. Chanting sacred mantras purifies the mind, aligns the '
                          'chakras, and connects us with the cosmic rhythm.',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 12,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Now playing
                if (_currentChant != null) ...[
                  const SizedBox(height: 24),
                  _buildNowPlaying(),
                ],

                const SizedBox(height: 24),

                Text(
                  'Choose a Chant',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Listen fully to complete the task',
                  style: GoogleFonts.poppins(
                      color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 12),

                if (_error != null && _chants.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      style: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Chant list
                ...List.generate(
                  _chants.length,
                  (i) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + i * 120),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    ),
                    child: _buildChantCard(_chants[i]),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Mark complete (only after listening)
        if (_hasListened)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  _audioPlayer.stop();
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Complete Task',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNowPlaying() {
    final chant = _currentChant!;
    final isPlaying = _playerState == PlayerState.playing;
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D23),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.orange.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.08);
              final glow = _pulseController.value * 0.2;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.2 + glow),
                        Colors.orange.withValues(alpha: 0.03),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.orange
                          .withValues(alpha: isPlaying ? 0.5 : 0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.music_note
                        : Icons.music_note_outlined,
                    color: Colors.orange,
                    size: 36,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          Text(
            chant.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          if (chant.description != null) ...[
            const SizedBox(height: 4),
            Text(
              chant.description!,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 20),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 4,
            ),
          ),

          const SizedBox(height: 8),

          // Time labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: GoogleFonts.poppins(
                    color: Colors.white38, fontSize: 11),
              ),
              Text(
                _formatDuration(_duration),
                style: GoogleFonts.poppins(
                    color: Colors.white38, fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Play/pause button
          GestureDetector(
            onTap: () => _playChant(chant),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  Colors.orange.shade600,
                  Colors.deepOrange.shade600,
                ]),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChantCard(_Chant chant) {
    final isCurrent = _currentChant?.id == chant.id;
    final isPlaying =
        isCurrent && _playerState == PlayerState.playing;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _playChant(chant),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrent
                  ? Colors.orange.withValues(alpha: 0.08)
                  : const Color(0xFF1A1D23),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isPlaying
                        ? Icons.graphic_eq
                        : Icons.music_note_outlined,
                    color: isCurrent
                        ? Colors.orange
                        : Colors.white54,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chant.title,
                        style: GoogleFonts.poppins(
                          color: isCurrent
                              ? Colors.orange.shade200
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (chant.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          chant.description!,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (chant.category != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            chant.category!,
                            style: GoogleFonts.poppins(
                              color: Colors.orange.withValues(alpha: 0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: isCurrent
                      ? Colors.orange
                      : Colors.white.withValues(alpha: 0.3),
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletion() {
    _completionController.forward();
    return ScaleTransition(
      scale: _completionScale,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.3),
                    Colors.orange.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: const Icon(Icons.music_note,
                  color: Colors.orange, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Chanting Complete',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '"ॐ नमो भगवते वासुदेवाय"\nOm Namo Bhagavate Vasudevaya',
              style: GoogleFonts.crimsonPro(
                color: Colors.orange.shade200,
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sound is the gateway to the divine. Each vibration '
              'of a sacred mantra purifies your consciousness.',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  _audioPlayer.stop();
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Complete Task',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _audioPlayer.stop();
                Navigator.pop(context);
              },
              child: Text(
                'Close',
                style: GoogleFonts.poppins(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
