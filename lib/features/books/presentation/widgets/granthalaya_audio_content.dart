import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Single audio item info for "now playing" and play actions.
class AudioItemInfo {
  final String title;
  final String? subtitle;
  final String? coverUrl;
  final String duration;

  const AudioItemInfo({
    required this.title,
    this.subtitle,
    this.coverUrl,
    this.duration = '0:00',
  });
}

/// Audio library UI: Concepts Narrated, Deity Chants, Scripture Audiobooks, Resource Discussions.
class GranthalayaAudioContent extends StatelessWidget {
  final ValueChanged<AudioItemInfo> onPlay;

  const GranthalayaAudioContent({super.key, required this.onPlay});

  static const _conceptsNarrated = [
    ('Brahman', '12:45', 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400'),
    ('Sanatana Dharma', '18:20', 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400'),
    ('Avatars', '15:10', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400'),
  ];

  static const _deityChants = [
    ('Hanuman Chalisa', '09:12', 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400'),
    ('Shiva Stotram', '07:45', 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400'),
  ];

  static const _scriptureAudiobooks = [
    ('Bhagavad Gita', '8h 45m • 18 Chapters', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'),
    ('Mahabharata', '42h 15m • Full Epic', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400'),
  ];

  static const _resourceDiscussions = [
    (Icons.podcasts, 'Hymn Vocabulary', '34:20'),
    (Icons.forum, 'Dharma Principles', '52:15'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 140),
      children: [
        _sectionTitle('Concepts Narrated'),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _conceptsNarrated.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) {
              final (title, duration, url) = _conceptsNarrated[i];
              return _buildConceptCard(context, title, duration, url);
            },
          ),
        ),
        const SizedBox(height: 32),
        _sectionTitle('Deity Chants'),
        const SizedBox(height: 16),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _deityChants.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) {
              final (title, duration, url) = _deityChants[i];
              return _buildDeityChantCard(context, title, duration, url);
            },
          ),
        ),
        const SizedBox(height: 32),
        _sectionTitle('Scripture Audiobooks'),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _scriptureAudiobooks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) {
              final (title, subtitle, url) = _scriptureAudiobooks[i];
              return _buildScriptureAudiobookCard(context, title, subtitle, url);
            },
          ),
        ),
        const SizedBox(height: 32),
        _sectionTitle('Resource Discussions'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(
              _resourceDiscussions.length,
              (i) {
                final (icon, title, duration) = _resourceDiscussions[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildResourceDiscussionCard(context, icon, title, duration),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.matteGold, width: 4)),
        ),
        child: Text(
          text,
          style: GoogleFonts.crimsonPro(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildConceptCard(BuildContext context, String title, String duration, String imageUrl) {
    return GestureDetector(
      onTap: () => onPlay(AudioItemInfo(title: title, coverUrl: imageUrl, duration: duration)),
      child: SizedBox(
        width: 176,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.charcoalCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.matteGold.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        color: Colors.white.withOpacity(0.7),
                        colorBlendMode: BlendMode.modulate,
                        errorWidget: (_, __, ___) => _imgPlaceholder(),
                      ),
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.4),
                    ),
                    const Center(
                      child: Icon(Icons.play_circle, color: AppColors.matteGold, size: 48),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    duration,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.zinc500,
                    ),
                  ),
                  const Spacer(),
                  _waveformBar(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeityChantCard(BuildContext context, String title, String duration, String imageUrl) {
    return GestureDetector(
      onTap: () => onPlay(AudioItemInfo(title: title, coverUrl: imageUrl, duration: duration)),
      child: SizedBox(
        width: 256,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.charcoalCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.matteGold.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        color: Colors.white.withOpacity(0.7),
                        colorBlendMode: BlendMode.modulate,
                        errorWidget: (_, __, ___) => _imgPlaceholder(),
                      ),
                      Container(color: Colors.black.withOpacity(0.4)),
                      const Center(
                        child: Icon(Icons.play_arrow, color: AppColors.matteGold, size: 32),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          duration,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.zinc500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _waveformBar(height: 8)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScriptureAudiobookCard(
    BuildContext context,
    String title,
    String subtitle,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () => onPlay(
        AudioItemInfo(title: title, subtitle: subtitle, coverUrl: imageUrl),
      ),
      child: SizedBox(
        width: 280,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  height: 160,
                  color: Colors.white.withOpacity(0.5),
                  colorBlendMode: BlendMode.modulate,
                  errorWidget: (_, __, ___) => _imgPlaceholder(),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.charcoalDark.withOpacity(0.3),
                      AppColors.charcoalDark,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.matteGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.black, size: 24),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          subtitle.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: AppColors.zinc500,
                          ),
                        ),
                        const Spacer(),
                        _waveformBar(height: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceDiscussionCard(
    BuildContext context,
    IconData icon,
    String title,
    String duration,
  ) {
    return GestureDetector(
      onTap: () => onPlay(AudioItemInfo(title: title, duration: duration)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.charcoalCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.matteGold.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.matteGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.matteGold, size: 24),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.matteGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.charcoalDark, width: 2),
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.black, size: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        duration.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          letterSpacing: 2,
                          color: AppColors.zinc500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _waveformBar(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _waveformBar({double height = 12}) {
    const heights = [0.4, 0.8, 1.0, 0.6, 0.9];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        5,
        (i) => Container(
          width: 3,
          height: height * heights[i],
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: AppColors.matteGold.withOpacity(0.6),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      color: AppColors.charcoalCard,
      child: const Icon(Icons.music_note, color: AppColors.matteGold, size: 40),
    );
  }
}
