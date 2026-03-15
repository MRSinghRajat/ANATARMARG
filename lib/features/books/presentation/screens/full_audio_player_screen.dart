import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/antarmarg_placeholder.dart';
import '../providers/now_playing_provider.dart';

/// Full-screen audio player. Opened when user taps the mini player bar.
/// Uses shared NowPlayingProvider - no own AudioPlayer.
class FullAudioPlayerScreen extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final String? coverImageUrl;
  final String? audioUrl;
  final VoidCallback? onClose;

  const FullAudioPlayerScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.coverImageUrl,
    this.audioUrl,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nowPlayingProvider);
    if (state == null) {
      return const Scaffold(
        backgroundColor: AppColors.charcoalDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.matteGold)),
      );
    }

    final notifier = ref.read(nowPlayingProvider.notifier);
    final hasRealAudio = state.audioUrl != null && state.audioUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.charcoalDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                    onPressed: () => Navigator.of(context).pop(),
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
                    child: (state.coverUrl != null && state.coverUrl!.isNotEmpty)
                        ? AppNetworkImage(
                            imageUrl: state.coverUrl!,
                            fit: BoxFit.cover,
                            color: Colors.white.withOpacity(0.9),
                            colorBlendMode: BlendMode.modulate,
                            errorBuilder: (_, __, ___) => _placeholderCover(),
                          )
                        : _placeholderCover(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    state.title,
                    style: GoogleFonts.crimsonPro(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (state.subtitle != null && state.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      state.subtitle!,
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
                      value: state.progress.clamp(0.0, 1.0),
                      onChanged: hasRealAudio && state.duration.inMilliseconds > 0
                          ? (v) {
                              final ms = (v * state.duration.inMilliseconds).round();
                              notifier.seek(Duration(milliseconds: ms));
                            }
                          : null,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.positionFormatted,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.zinc500,
                        ),
                      ),
                      Text(
                        state.duration.inMilliseconds > 0
                            ? state.durationFormatted
                            : '--:--',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 40),
                  onPressed: () => notifier.seek(Duration.zero),
                ),
                const SizedBox(width: 24),
                Material(
                  color: AppColors.matteGold,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: state.isLoading ? null : () => notifier.togglePlayPause(),
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: state.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(
                              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 48,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 40),
                  onPressed: () => notifier.seek(state.duration),
                ),
              ],
            ),
            const SizedBox(height: 16),
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

  static Widget _placeholderCover() {
    return const AntarmargPlaceholder();
  }
}
