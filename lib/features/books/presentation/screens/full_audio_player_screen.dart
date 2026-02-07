import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-screen audio player with full controls. Shown when user expands mini player in Granthalaya.
class FullAudioPlayerScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? coverImageUrl;
  final VoidCallback? onClose;

  const FullAudioPlayerScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.coverImageUrl,
    this.onClose,
  });

  @override
  State<FullAudioPlayerScreen> createState() => _FullAudioPlayerScreenState();
}

class _FullAudioPlayerScreenState extends State<FullAudioPlayerScreen> {
  bool _isPlaying = false;
  double _progress = 0.2; // 0.0 - 1.0
  static const int _totalSeconds = 549; // 9:09
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
          if (!mounted) return;
          setState(() {
            _progress += 0.5 / _totalSeconds;
            if (_progress >= 1.0) {
              _progress = 1.0;
              _progressTimer?.cancel();
              _isPlaying = false;
            }
          });
        });
      } else {
        _progressTimer?.cancel();
      }
    });
  }

  String _formatTime(double progress) {
    final secs = (progress * _totalSeconds).round();
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  Text(
                    'Now Playing',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Cover art
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.matteGold.withOpacity(0.2),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: widget.coverImageUrl != null && widget.coverImageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.coverImageUrl!,
                            fit: BoxFit.cover,
                            color: Colors.white.withOpacity(0.9),
                            colorBlendMode: BlendMode.modulate,
                            errorWidget: (_, __, ___) => _placeholderCover(),
                          )
                        : _placeholderCover(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Title & subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.crimsonPro(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.zinc500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.matteGold,
                      inactiveTrackColor: Colors.white.withOpacity(0.1),
                      thumbColor: AppColors.matteGold,
                      overlayColor: AppColors.matteGold.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _progress.clamp(0.0, 1.0),
                      onChanged: (v) {
                        setState(() => _progress = v);
                        if (_isPlaying && _progress >= 1.0) {
                          _progressTimer?.cancel();
                          _isPlaying = false;
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(_progress),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.zinc500,
                        ),
                      ),
                      Text(
                        _formatTime(1.0),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.zinc500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Controls: previous, play/pause, next
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 40),
                  onPressed: () {
                    setState(() => _progress = 0);
                    _progressTimer?.cancel();
                    _isPlaying = false;
                  },
                ),
                const SizedBox(width: 24),
                Material(
                  color: AppColors.matteGold,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _togglePlay,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 40),
                  onPressed: () {
                    setState(() => _progress = 0);
                    _progressTimer?.cancel();
                    _isPlaying = false;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Optional: repeat, shuffle (simple icons)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle_rounded, color: AppColors.zinc500, size: 24),
                  onPressed: () {},
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.repeat_rounded, color: AppColors.zinc500, size: 24),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _placeholderCover() {
    return Container(
      color: AppColors.charcoalCard,
      child: const Icon(Icons.music_note_rounded, color: AppColors.matteGold, size: 80),
    );
  }
}
