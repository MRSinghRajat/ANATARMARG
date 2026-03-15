import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/antarmarg_placeholder.dart';
import '../providers/now_playing_provider.dart';
import '../screens/full_audio_player_screen.dart';
import 'glass_shimmer_box.dart';

/// Mini audio player - uses NowPlayingProvider for real progress.
/// Compact footer; shows position/duration (e.g. 1:23 / 4:56); tap opens full player.
class GranthalayaAudioMiniPlayer extends ConsumerWidget {
  final VoidCallback onClose;

  const GranthalayaAudioMiniPlayer({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nowPlayingProvider);
    if (state == null) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: GlassShimmerBox(
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.zinc500, size: 18),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullAudioPlayerScreen(
                      title: state.title,
                      subtitle: state.subtitle,
                      coverImageUrl: state.coverUrl,
                      audioUrl: state.audioUrl,
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: state.coverUrl != null && state.coverUrl!.isNotEmpty
                        ? AppNetworkImage(
                            imageUrl: state.coverUrl!,
                            fit: BoxFit.cover,
                            color: Colors.white.withOpacity(0.9),
                            colorBlendMode: BlendMode.modulate,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullAudioPlayerScreen(
                        title: state.title,
                        subtitle: state.subtitle,
                        coverImageUrl: state.coverUrl,
                        audioUrl: state.audioUrl,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.title,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            state.positionFormatted,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.matteGold.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            ' / ',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.zinc500,
                            ),
                          ),
                          Text(
                            state.duration.inMilliseconds > 0
                                ? state.durationFormatted
                                : '--:--',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.zinc500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 3,
                          child: LinearProgressIndicator(
                            value: state.progress.clamp(0.0, 1.0),
                            minHeight: 3,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              state.isPlaying
                                  ? AppColors.matteGold
                                  : AppColors.matteGold.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _PlayButton(
                state: state,
                onToggle: () => ref.read(nowPlayingProvider.notifier).togglePlayPause(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const AntarmargPlaceholder(compact: true);
  }
}

class _PlayButton extends StatelessWidget {
  final dynamic state;
  final VoidCallback onToggle;

  const _PlayButton({required this.state, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.matteGold,
          shape: BoxShape.circle,
          boxShadow: state.isPlaying
              ? [
                  BoxShadow(
                    color: AppColors.matteGold.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: state.isLoading
            ? const Padding(
                padding: EdgeInsets.all(6),
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
              )
            : Icon(
                state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.black,
                size: 18,
              ),
      ),
    );
  }
}
