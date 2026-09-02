import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/localized.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../data/models/granthalaya_models.dart';
import '../providers/now_playing_provider.dart';
import '../widgets/audio_language_toggle.dart';

class SacredTextAudioScreen extends ConsumerStatefulWidget {
  final SacredTextModel sacredText;

  const SacredTextAudioScreen({super.key, required this.sacredText});

  @override
  ConsumerState<SacredTextAudioScreen> createState() => _SacredTextAudioScreenState();
}

class _SacredTextAudioScreenState extends ConsumerState<SacredTextAudioScreen> {
  AudioLanguage _language = AudioLanguage.hindi;

  String? get _currentAudioUrl =>
      _language == AudioLanguage.hindi ? widget.sacredText.audioUrl : widget.sacredText.audioUrlEn;

  static const _deityGradients = <String, List<Color>>{
    'shiva': [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    'krishna': [Color(0xFF0E7490), Color(0xFF0891B2)],
    'hanuman': [Color(0xFFEA580C), Color(0xFFF59E0B)],
    'ganesha': [Color(0xFFE11D48), Color(0xFFF43F5E)],
    'vishnu': [Color(0xFF0284C7), Color(0xFF0EA5E9)],
    'devi': [Color(0xFFDB2777), Color(0xFFF472B6)],
  };

  List<Color> _getDeityGradient(String? slug) {
    if (slug == null) return const [Color(0xFFC5A059), Color(0xFFA88B3D)];
    return _deityGradients[slug.toLowerCase()] ?? const [Color(0xFFC5A059), Color(0xFFA88B3D)];
  }

  void _play() {
    final url = _currentAudioUrl;
    if (url == null || url.isEmpty) return;
    ref.read(nowPlayingProvider.notifier).setTrackAndPlay(
      title: widget.sacredText.title,
      subtitle: widget.sacredText.typeLabel,
      coverUrl: widget.sacredText.coverImageUrl,
      audioUrl: url,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.sacredText;
    final gradient = _getDeityGradient(text.deitySlug);
    final nowPlaying = ref.watch(nowPlayingProvider);
    final isThisPlaying = nowPlaying?.title == text.title && (nowPlaying?.isPlaying ?? false);
    final isLoading = nowPlaying?.title == text.title && (nowPlaying?.isLoading ?? false);
    final isThisActive = nowPlaying?.title == text.title;
    final hasAudio = _currentAudioUrl != null && _currentAudioUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AudioLanguageToggle(
                  selected: _language,
                  onChanged: (lang) => setState(() => _language = lang),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (text.coverImageUrl != null && text.coverImageUrl!.isNotEmpty)
                    AppNetworkImage(imageUrl: text.coverImageUrl!, fit: BoxFit.cover)
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [gradient.first.withValues(alpha: 0.4), gradient.last.withValues(alpha: 0.15)],
                        ),
                      ),
                      child: Center(child: Icon(Icons.auto_stories, color: gradient.first, size: 80)),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF0A0A0A)],
                        stops: [0.5, 1.0],
                      ),
                    ),
                    child: SizedBox.expand(),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Deity gradient label
                  if (text.deitySlug != null) ...[
                    ShaderMask(
                      shaderCallback: (b) => LinearGradient(colors: gradient).createShader(b),
                      child: Text(
                        text.deitySlug!.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.cinzel(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Title
                  Text(
                    localized(ref, en: text.title, hi: text.titleHindi),
                    style: GoogleFonts.crimsonPro(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Info badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (text.verseCount != null) _infoBadge('${text.verseCount} verses'),
                      if (text.difficulty.isNotEmpty) _infoBadge(text.difficulty),
                      if (text.durationSeconds != null) _infoBadge('${text.durationSeconds! ~/ 60}m'),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Progress bar
                  if (isThisActive && nowPlaying != null) ...[
                    _buildProgress(nowPlaying, gradient),
                    const SizedBox(height: 20),
                  ],

                  // Main play/pause button
                  GestureDetector(
                    onTap: () {
                      if (!hasAudio) return;
                      if (isThisPlaying) {
                        ref.read(nowPlayingProvider.notifier).togglePlayPause();
                      } else if (isThisActive) {
                        ref.read(nowPlayingProvider.notifier).togglePlayPause();
                      } else {
                        _play();
                      }
                    },
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: hasAudio
                            ? LinearGradient(colors: gradient)
                            : null,
                        color: hasAudio ? null : Colors.white.withValues(alpha: 0.05),
                        boxShadow: hasAudio
                            ? [BoxShadow(color: gradient.first.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 2)]
                            : null,
                      ),
                      child: isLoading
                          ? const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Icon(
                              isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: hasAudio ? Colors.white : Colors.white.withValues(alpha: 0.2),
                              size: 40,
                            ),
                    ),
                  ),
                  if (!hasAudio) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Audio not available for ${_language == AudioLanguage.hindi ? 'Hindi' : 'English'}',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.35)),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Info section
                  if (text.whenToRecite != null && text.whenToRecite!.isNotEmpty) ...[
                    _buildInfoCard(Icons.access_time_rounded, 'When to Recite', text.whenToRecite!),
                    const SizedBox(height: 16),
                  ],
                  if (text.benefits != null && text.benefits!.isNotEmpty) ...[
                    _buildInfoCard(Icons.auto_awesome_rounded, 'Benefits', text.benefits!),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(NowPlayingState np, List<Color> gradient) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            activeTrackColor: gradient.first,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            thumbColor: gradient.first,
            overlayColor: gradient.first.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: np.progress,
            onChanged: (v) {
              if (np.duration.inMilliseconds > 0) {
                final pos = Duration(milliseconds: (v * np.duration.inMilliseconds).round());
                ref.read(nowPlayingProvider.notifier).seek(pos);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(np.positionFormatted, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              Text(np.durationFormatted, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.matteGold.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.matteGold, size: 18),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.cinzel(fontSize: 11, color: AppColors.matteGold, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Text(body, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.6), height: 1.6)),
        ],
      ),
    );
  }

  Widget _infoBadge(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
      ),
    );
  }
}
