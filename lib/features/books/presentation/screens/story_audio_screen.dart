import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../data/models/granthalaya_models.dart';
import '../providers/now_playing_provider.dart';
import '../widgets/audio_language_toggle.dart';

class StoryAudioScreen extends ConsumerStatefulWidget {
  final SacredStoryModel story;

  const StoryAudioScreen({super.key, required this.story});

  @override
  ConsumerState<StoryAudioScreen> createState() => _StoryAudioScreenState();
}

class _StoryAudioScreenState extends ConsumerState<StoryAudioScreen> {
  AudioLanguage _language = AudioLanguage.hindi;

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

  String? get _currentAudioUrl =>
      _language == AudioLanguage.hindi ? widget.story.audioUrl : widget.story.audioUrlEn;

  void _play() {
    final url = _currentAudioUrl;
    if (url == null || url.isEmpty) return;
    ref.read(nowPlayingProvider.notifier).setTrackAndPlay(
      title: widget.story.title,
      subtitle: 'Sacred Story',
      coverUrl: widget.story.coverImageUrl,
      audioUrl: url,
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final gradient = _getDeityGradient(story.deitySlug);
    final nowPlaying = ref.watch(nowPlayingProvider);
    final isThisPlaying = nowPlaying?.title == story.title && (nowPlaying?.isPlaying ?? false);
    final isLoading = nowPlaying?.title == story.title && (nowPlaying?.isLoading ?? false);
    final isActive = nowPlaying?.title == story.title;
    final hasAudio = _currentAudioUrl != null && _currentAudioUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
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
                  if (story.coverImageUrl != null && story.coverImageUrl!.isNotEmpty)
                    AppNetworkImage(imageUrl: story.coverImageUrl!, fit: BoxFit.cover)
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
                  if (story.deitySlug != null) ...[
                    ShaderMask(
                      shaderCallback: (b) => LinearGradient(colors: gradient).createShader(b),
                      child: Text(
                        story.deitySlug!.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.cinzel(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    story.title,
                    style: GoogleFonts.crimsonPro(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  if (story.titleHindi != null) ...[
                    const SizedBox(height: 4),
                    Text(story.titleHindi!, style: GoogleFonts.crimsonPro(fontSize: 16, color: Colors.white.withValues(alpha: 0.5)), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '${story.estimatedMinutes}m · Sacred Story',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(height: 28),

                  // Progress slider
                  if (isActive && nowPlaying != null) ...[
                    _buildProgress(nowPlaying, gradient),
                    const SizedBox(height: 20),
                  ],

                  // Play/pause button
                  GestureDetector(
                    onTap: () {
                      if (!hasAudio) return;
                      if (isThisPlaying) {
                        ref.read(nowPlayingProvider.notifier).togglePlayPause();
                      } else if (isActive) {
                        ref.read(nowPlayingProvider.notifier).togglePlayPause();
                      } else {
                        _play();
                      }
                    },
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: hasAudio ? LinearGradient(colors: gradient) : null,
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

                  // Info cards
                  if (story.keyTeaching != null && story.keyTeaching!.isNotEmpty) ...[
                    _buildInfoCard(Icons.lightbulb_outline, 'Key Teaching', story.keyTeaching!),
                    const SizedBox(height: 16),
                  ],
                  if (story.reflectionPrompt != null && story.reflectionPrompt!.isNotEmpty) ...[
                    _buildInfoCard(Icons.psychology_outlined, 'Reflect', story.reflectionPrompt!),
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
}
