import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../data/models/book_model.dart';
import '../../data/models/chapter_model.dart';
import '../providers/book_providers.dart';
import '../providers/now_playing_provider.dart';
import '../widgets/audio_language_toggle.dart';

class BookAudioDetailScreen extends ConsumerStatefulWidget {
  final BookModel book;

  const BookAudioDetailScreen({super.key, required this.book});

  @override
  ConsumerState<BookAudioDetailScreen> createState() => _BookAudioDetailScreenState();
}

class _BookAudioDetailScreenState extends ConsumerState<BookAudioDetailScreen> {
  AudioLanguage _language = AudioLanguage.hindi;
  String? _expandedChapterId;

  String? _bookAudioUrl() =>
      _language == AudioLanguage.hindi ? widget.book.audioUrl : widget.book.audioUrlEn;

  void _playTrack(String title, String? subtitle, String? coverUrl, String? audioUrl) {
    if (audioUrl == null || audioUrl.isEmpty) return;
    ref.read(nowPlayingProvider.notifier).setTrackAndPlay(
      title: title,
      subtitle: subtitle,
      coverUrl: coverUrl,
      audioUrl: audioUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final chaptersAsync = ref.watch(chaptersWithAudioProvider(book.id));
    final chapters = chaptersAsync.valueOrNull ?? [];
    final nowPlaying = ref.watch(nowPlayingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0A0A),
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
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
                  if (book.coverImageUrl != null)
                    AppNetworkImage(imageUrl: book.coverImageUrl!, fit: BoxFit.cover)
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [AppColors.matteGold.withValues(alpha: 0.3), const Color(0xFF0A0A0A)],
                        ),
                      ),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, const Color(0xFF0A0A0A).withValues(alpha: 0.7), const Color(0xFF0A0A0A)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24, right: 24, bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.name, style: GoogleFonts.crimsonPro(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        if (book.nameSanskrit != null) ...[
                          const SizedBox(height: 4),
                          Text(book.nameSanskrit!, style: GoogleFonts.crimsonPro(fontSize: 16, color: Colors.white.withValues(alpha: 0.6))),
                        ],
                        const SizedBox(height: 8),
                        Text('${book.totalChapters} chapters', style: GoogleFonts.inter(fontSize: 12, color: AppColors.matteGold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookAudioPlayer(book, nowPlaying),
                  const SizedBox(height: 32),
                  Text('CHAPTERS', style: GoogleFonts.cinzel(fontSize: 10, color: AppColors.matteGold, letterSpacing: 2)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (chaptersAsync.isLoading)
            const SliverToBoxAdapter(
              child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.matteGold))),
            )
          else if (chapters.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('No chapter audio available', style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.4))),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _buildChapterTile(chapters[i], nowPlaying),
                childCount: chapters.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildBookAudioPlayer(BookModel book, NowPlayingState? nowPlaying) {
    final audioUrl = _bookAudioUrl();
    final isPlaying = nowPlaying?.title == book.name && (nowPlaying?.isPlaying ?? false);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.matteGold.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.matteGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.menu_book, color: AppColors.matteGold, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Full Book Audio', style: GoogleFonts.crimsonPro(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(
                  audioUrl != null ? (_language == AudioLanguage.hindi ? 'Hindi' : 'English') : 'Not available',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          Material(
            color: audioUrl != null ? AppColors.matteGold : Colors.white.withValues(alpha: 0.1),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: audioUrl != null
                  ? () {
                      if (isPlaying) {
                        ref.read(nowPlayingProvider.notifier).togglePlayPause();
                      } else {
                        _playTrack(book.name, 'Full Book', book.coverImageUrl, audioUrl);
                      }
                    }
                  : null,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 44, height: 44,
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: audioUrl != null ? Colors.black : Colors.white.withValues(alpha: 0.3),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterTile(ChapterModel chapter, NowPlayingState? nowPlaying) {
    final chapterAudioUrl = _language == AudioLanguage.hindi ? chapter.audioUrl : chapter.audioUrlEn;
    final isExpanded = _expandedChapterId == chapter.id;
    final isPlaying = nowPlaying?.title == chapter.title && (nowPlaying?.isPlaying ?? false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expandedChapterId = isExpanded ? null : chapter.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isExpanded ? Colors.white.withValues(alpha: 0.04) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isExpanded ? AppColors.matteGold.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.matteGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          chapter.displayNumber,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.matteGold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(chapter.title, style: GoogleFonts.crimsonPro(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          if (chapter.subtitle != null)
                            Text(chapter.subtitle!, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    if (chapterAudioUrl != null)
                      Material(
                        color: AppColors.matteGold.withValues(alpha: 0.9),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () {
                            if (isPlaying) {
                              ref.read(nowPlayingProvider.notifier).togglePlayPause();
                            } else {
                              _playTrack(chapter.title, 'Ch. ${chapter.displayNumber}', widget.book.coverImageUrl, chapterAudioUrl);
                            }
                          },
                          customBorder: const CircleBorder(),
                          child: SizedBox(
                            width: 36, height: 36,
                            child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 20),
                          ),
                        ),
                      )
                    else
                      Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.2)),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  _buildVerseAudioList(chapter),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerseAudioList(ChapterModel chapter) {
    final versesAsync = ref.watch(versesWithAudioProvider(chapter.id));
    final verses = versesAsync.valueOrNull ?? [];
    final nowPlaying = ref.watch(nowPlayingProvider);

    if (versesAsync.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.matteGold, strokeWidth: 2))),
      );
    }

    if (verses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text('No verse audio available', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.3))),
      );
    }

    return Column(
      children: verses.map((verse) {
        final verseAudioUrl = _language == AudioLanguage.hindi ? verse.audioUrl : verse.audioUrlEn;
        final isPlaying = nowPlaying?.title == verse.title && (nowPlaying?.isPlaying ?? false);
        return Padding(
          padding: const EdgeInsets.only(left: 44, bottom: 8),
          child: Row(
            children: [
              Text(
                verse.verseNumber ?? '',
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.matteGold.withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  verse.title,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
              if (verseAudioUrl != null)
                GestureDetector(
                  onTap: () {
                    if (isPlaying) {
                      ref.read(nowPlayingProvider.notifier).togglePlayPause();
                    } else {
                      _playTrack(verse.title, 'Verse ${verse.verseNumber}', widget.book.coverImageUrl, verseAudioUrl);
                    }
                  },
                  child: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
                    color: AppColors.matteGold,
                    size: 24,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
