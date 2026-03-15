import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../data/models/meditation_guide_model.dart';
import '../providers/now_playing_provider.dart';
import '../widgets/audio_language_toggle.dart';

class MeditationAudioScreen extends ConsumerStatefulWidget {
  final MeditationGuideModel guide;

  const MeditationAudioScreen({super.key, required this.guide});

  @override
  ConsumerState<MeditationAudioScreen> createState() => _MeditationAudioScreenState();
}

class _MeditationAudioScreenState extends ConsumerState<MeditationAudioScreen> {
  AudioLanguage _language = AudioLanguage.hindi;

  String? get _currentAudioUrl =>
      _language == AudioLanguage.hindi ? widget.guide.audioUrl : widget.guide.audioUrlEn;

  void _play() {
    final url = _currentAudioUrl;
    if (url == null || url.isEmpty) return;
    ref.read(nowPlayingProvider.notifier).setTrackAndPlay(
      title: widget.guide.guideName,
      subtitle: widget.guide.typeLabel,
      coverUrl: widget.guide.coverImageUrl,
      audioUrl: url,
    );
  }

  @override
  Widget build(BuildContext context) {
    final guide = widget.guide;
    final nowPlaying = ref.watch(nowPlayingProvider);
    final isPlaying = nowPlaying?.title == guide.guideName && (nowPlaying?.isPlaying ?? false);
    final isLoading = nowPlaying?.title == guide.guideName && (nowPlaying?.isLoading ?? false);
    final isActive = nowPlaying?.title == guide.guideName;
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
                  if (guide.coverImageUrl != null && guide.coverImageUrl!.isNotEmpty)
                    AppNetworkImage(imageUrl: guide.coverImageUrl!, fit: BoxFit.cover)
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.purple.withValues(alpha: 0.4), Colors.indigo.withValues(alpha: 0.15)],
                        ),
                      ),
                      child: const Center(child: Icon(Icons.self_improvement, color: AppColors.matteGold, size: 80)),
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
                  Text(
                    guide.guideName,
                    style: GoogleFonts.crimsonPro(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _infoBadge(guide.typeLabel),
                      _infoBadge(guide.durationFormatted),
                      _infoBadge(guide.difficulty),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Progress bar when active
                  if (isActive && nowPlaying != null) ...[
                    _buildProgress(nowPlaying),
                    const SizedBox(height: 20),
                  ],

                  // Main play button
                  GestureDetector(
                    onTap: () {
                      if (!hasAudio) return;
                      if (isPlaying) {
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
                        gradient: hasAudio
                            ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)])
                            : null,
                        color: hasAudio ? null : Colors.white.withValues(alpha: 0.05),
                        boxShadow: hasAudio
                            ? [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 2)]
                            : null,
                      ),
                      child: isLoading
                          ? const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
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

                  // Steps header
                  if (guide.steps.isNotEmpty) ...[
                    Row(
                      children: [
                        Text('MEDITATION STEPS', style: GoogleFonts.cinzel(fontSize: 10, color: AppColors.matteGold, letterSpacing: 2)),
                        const Spacer(),
                        Text('${guide.steps.length} steps', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.3))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),

          // Steps list
          if (guide.steps.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _buildStepRow(guide.steps[i]),
                childCount: guide.steps.length,
              ),
            ),

          if (guide.completionMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.matteGold.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.matteGold.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.matteGold, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(guide.completionMessage!, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.6), height: 1.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildProgress(NowPlayingState np) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            activeTrackColor: const Color(0xFF7C3AED),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            thumbColor: const Color(0xFF7C3AED),
            overlayColor: const Color(0xFF7C3AED).withValues(alpha: 0.15),
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

  Widget _buildStepRow(MeditationStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.03))),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('${step.stepNumber}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF7C3AED))),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(step.stepTitle, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.8))),
            ),
            Text('${step.durationSeconds}s', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.3))),
          ],
        ),
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
