import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../screens/full_audio_player_screen.dart';

/// Mini audio player shown only in Granthalaya (Listen mode). Dismissible; tap opens full player.
class GranthalayaAudioMiniPlayer extends StatelessWidget {
  final String title;
  final String? coverImageUrl;
  final double progress; // 0.0 - 1.0
  final VoidCallback onClose;
  final VoidCallback? onPlayPause;

  const GranthalayaAudioMiniPlayer({
    super.key,
    required this.title,
    this.coverImageUrl,
    this.progress = 0.2,
    required this.onClose,
    this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoalCard.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.matteGold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullAudioPlayerScreen(
                  title: title,
                  coverImageUrl: coverImageUrl,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Close button
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.zinc500, size: 20),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 4),
              // Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: coverImageUrl != null && coverImageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: coverImageUrl!,
                          fit: BoxFit.cover,
                          color: Colors.white.withOpacity(0.85),
                          colorBlendMode: BlendMode.modulate,
                          errorWidget: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 12),
              // Title & progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${(progress * 100).round()}% COMPLETED',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.matteGold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.matteGold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Play button
              GestureDetector(
                onTap: () async {
                  onPlayPause?.call();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullAudioPlayerScreen(
                        title: title,
                        coverImageUrl: coverImageUrl,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.matteGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.charcoalDark,
      child: const Icon(Icons.music_note_rounded, color: AppColors.matteGold, size: 24),
    );
  }
}
