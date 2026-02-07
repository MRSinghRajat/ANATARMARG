import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/book_model.dart';
import '../../data/models/chapter_model.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../data/repositories/verse_repository.dart';
import '../../data/repositories/book_progress_repository.dart';
import '../../data/services/verse_notes_service.dart';
import 'book_chapter_screen.dart';
import 'book_chat_screen.dart';
import 'book_notes_screen.dart';

/// Progress Hub - Dark theme with gold accents. Matches HTML design.
class _ProgressHubColors {
  static const Color primary = Color(0xFFFFB347);
  static const Color backgroundDeep = Color(0xFF0F1115);
  static const Color cardDark = Color(0xFF1E2229);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color offWhite = Color(0xFFF5F5F0);
  static const Color mutedGold = Color(0xFFC5A059);
  static const Color headerBgStart = Color(0xFF0A0D12);
  static const Color headerBgEnd = Color(0xFF1A202C);
}

enum _ChapterStatus { completed, inProgress, locked }

class BookDetailScreen extends ConsumerStatefulWidget {
  final BookModel book;

  const BookDetailScreen({
    super.key,
    required this.book,
  });

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  final ChapterRepository _chapterRepository = ChapterRepository();
  final VerseRepository _verseRepository = VerseRepository();
  final BookProgressRepository _progressRepository = BookProgressRepository();
  final VerseNotesService _notesService = VerseNotesService();
  List<ChapterModel> _chapters = [];
  Map<String, int> _verseCountByChapter = {};
  Map<String, int> _completedVersesByChapter = {};
  // ignore: unused_field - used for future notes badge
  Map<String, List<VerseNoteModel>> _notesByChapter = {};
  bool _isLoading = true;

  int _selectedTab = 0; // 0: Chapters, 1: Chat, 2: Notes

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    setState(() => _isLoading = true);
    try {
      final chapters =
          await _chapterRepository.getChaptersForBook(widget.book.id);
      setState(() => _chapters = chapters);

      final counts = <String, int>{};
      final completedMap = <String, int>{};
      final notesMap = <String, List<VerseNoteModel>>{};
      await Future.wait(chapters.map((ch) async {
        final count = await _verseRepository.getVerseCountForChapter(ch.id);
        counts[ch.id] = count;
        final readVerses = await _progressRepository.getReadVerseIds(ch.id);
        completedMap[ch.id] = readVerses.length;
        final notes = await _notesService.getNotesForChapter(ch.id);
        if (notes.isNotEmpty) notesMap[ch.id] = notes;
      }));
      if (mounted) {
        setState(() {
          _verseCountByChapter = counts;
          _completedVersesByChapter = completedMap;
          _notesByChapter = notesMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _chapters = _chapterRepository.getChaptersForBookSync(widget.book.id);
        _isLoading = false;
      });
    }
  }

  int get _effectiveCompletedChapters {
    int count = 0;
    for (final ch in _chapters) {
      final completed = _completedVersesByChapter[ch.id] ?? 0;
      final total = _verseCountByChapter[ch.id] ?? 0;
      if (total > 0 && completed >= total) count++;
    }
    return count;
  }

  double get _effectiveProgress {
    if (widget.book.totalChapters <= 0) return 0;
    return _effectiveCompletedChapters / widget.book.totalChapters;
  }

  int get _currentChapterIndex {
    for (var i = 0; i < _chapters.length; i++) {
      final ch = _chapters[i];
      final total = _verseCountByChapter[ch.id] ?? 0;
      final completed = _completedVersesByChapter[ch.id] ?? 0;
      if (total > 0 && completed > 0 && completed < total) return i;
    }
    return _effectiveCompletedChapters.clamp(0, _chapters.length - 1);
  }

  _ChapterStatus _chapterStatus(ChapterModel ch, int index) {
    final total = _verseCountByChapter[ch.id] ?? 0;
    final completed = _completedVersesByChapter[ch.id] ?? 0;
    if (total > 0 && completed >= total) return _ChapterStatus.completed;
    if (total > 0 && completed > 0) return _ChapterStatus.inProgress;
    final currentIdx = _currentChapterIndex;
    if (index <= currentIdx) return _ChapterStatus.inProgress;
    return _ChapterStatus.locked;
  }

  bool _canTapChapter(ChapterModel ch, int index) {
    final status = _chapterStatus(ch, index);
    return status != _ChapterStatus.locked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProgressHubColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBookCard(context),
                    const SizedBox(height: 24),
                    if (_selectedTab == 0) ...[
                      _buildChapterOverview(context),
                      const SizedBox(height: 24),
                      _buildChapterTimeline(context),
                      const SizedBox(height: 32),
                      _buildLegend(context),
                    ] else if (_selectedTab == 1)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: BookChatScreen(book: widget.book),
                      )
                    else
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: BookNotesScreen(book: widget.book),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _ProgressHubColors.headerBgStart,
            _ProgressHubColors.headerBgEnd,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            color: _ProgressHubColors.mutedGold,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
          Text(
            'Progress Hub',
            style: GoogleFonts.libreBaskerville(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _ProgressHubColors.offWhite,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookChatScreen(book: widget.book),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            color: _ProgressHubColors.mutedGold,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context) {
    final totalCh = widget.book.totalChapters;
    final currentCh = _currentChapterIndex + 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ProgressHubColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _ProgressHubColors.goldAccent.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2D333B), _ProgressHubColors.cardDark],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: _ProgressHubColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book.name,
                              style: GoogleFonts.libreBaskerville(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (widget.book.nameSanskrit != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.book.nameSanskrit!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                  color: _ProgressHubColors.primary,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '$currentCh/$totalCh',
                          style: GoogleFonts.libreBaskerville(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _ProgressHubColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _effectiveProgress.clamp(0.0, 1.0),
                              minHeight: 4,
                              backgroundColor: Colors.black.withOpacity(0.4),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                _ProgressHubColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Progress',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: _ProgressHubColors.mutedGold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.05),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCardTab(0, 'Chapters', Icons.list_alt, true),
              const SizedBox(width: 6),
              _buildCardTab(1, 'Chat', Icons.auto_awesome, false),
              const SizedBox(width: 6),
              _buildCardTab(2, 'Notes', Icons.sticky_note_2_outlined, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardTab(int index, String label, IconData icon, bool fillIcon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: Material(
        color: isSelected
            ? _ProgressHubColors.primary.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => setState(() => _selectedTab = index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: _ProgressHubColors.primary.withOpacity(0.2))
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? _ProgressHubColors.primary
                      : Colors.grey.shade500,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? _ProgressHubColors.primary
                        : Colors.grey.shade400,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterOverview(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Chapter Overview',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _ProgressHubColors.mutedGold,
            letterSpacing: 2,
          ),
        ),
        Text(
          '${_chapters.length} Sections',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildChapterTimeline(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: _ProgressHubColors.primary),
        ),
      );
    }
    if (_chapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 12),
            Text(
              'No chapters available',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Positioned(
          left: 20,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _ProgressHubColors.primary.withOpacity(0.5),
                  _ProgressHubColors.primary.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
                stops: const [0.0, 0.1, 0.15],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            children: List.generate(_chapters.length, (index) {
              final ch = _chapters[index];
              final status = _chapterStatus(ch, index);
              final total = _verseCountByChapter[ch.id] ?? 0;
              final completed = _completedVersesByChapter[ch.id] ?? 0;
              final remaining = (total - completed).clamp(0, total);
              final pct = total > 0 ? (completed / total * 100).round() : 0;
              final isActive = status == _ChapterStatus.inProgress &&
                  index == _currentChapterIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _ChapterTimelineItem(
                  chapter: ch,
                  status: status,
                  isActive: isActive,
                  percent: pct,
                  versesRemaining: remaining,
                  onTap: _canTapChapter(ch, index)
                      ? () => _openChapter(ch)
                      : null,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Future<void> _openChapter(ChapterModel chapter) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookChapterScreen(
          book: widget.book,
          chapter: chapter,
        ),
      ),
    );
    _loadChapters();
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _ProgressHubColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          'Completed',
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _ProgressHubColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _ProgressHubColors.primary.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          'Active',
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
          ),
          'Locked',
        ),
      ],
    );
  }

  Widget _buildLegendItem(Widget dot, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade400,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _ChapterTimelineItem extends StatelessWidget {
  final ChapterModel chapter;
  final _ChapterStatus status;
  final bool isActive;
  final int percent;
  final int versesRemaining;
  final VoidCallback? onTap;

  const _ChapterTimelineItem({
    required this.chapter,
    required this.status,
    required this.isActive,
    required this.percent,
    required this.versesRemaining,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: status == _ChapterStatus.locked ? 0.6 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNode(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.displayTitle,
                        style: GoogleFonts.libreBaskerville(
                          fontSize: isActive ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: status == _ChapterStatus.locked
                              ? Colors.grey.shade400
                              : (isActive
                                  ? Colors.white
                                  : _ProgressHubColors.offWhite.withOpacity(0.9)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (status == _ChapterStatus.completed)
                            Text(
                              'Completed',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _ProgressHubColors.primary,
                                letterSpacing: 1,
                              ),
                            )
                          else if (status == _ChapterStatus.inProgress)
                            Text(
                              'In-Progress • $percent%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _ProgressHubColors.primary,
                                letterSpacing: 1,
                              ),
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 10,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Locked',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _ProgressHubColors.cardDark.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _ProgressHubColors.goldAccent.withOpacity(0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                chapter.summary ??
                                    "Focus on the soul's immortality and the nature of duty. You have $versesRemaining verses remaining in this section.",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.grey.shade300,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Material(
                                color: _ProgressHubColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: onTap,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Continue Reading',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _ProgressHubColors.primary,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode() {
    if (status == _ChapterStatus.completed) {
      return Container(
        width: 16,
        height: 16,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: _ProgressHubColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: _ProgressHubColors.backgroundDeep, width: 2),
        ),
        child: const Icon(Icons.check, size: 10, color: _ProgressHubColors.backgroundDeep),
      );
    }
    if (status == _ChapterStatus.inProgress && isActive) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _ProgressHubColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: _ProgressHubColors.primary.withOpacity(0.2),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: _ProgressHubColors.primary.withOpacity(0.4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
    );
  }
}
