import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../data/models/chapter_model.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../data/repositories/verse_repository.dart';
import '../../data/repositories/book_progress_repository.dart';
import '../../data/services/verse_notes_service.dart';
import 'book_chapter_screen.dart';
import 'book_chat_screen.dart';
import 'book_notes_screen.dart';

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
  Map<String, List<VerseNoteModel>> _notesByChapter = {};
  bool _isLoading = true;

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

      // Load verse counts and notes in parallel
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

  int _selectedTab = 0; // 0: Chapters, 1: Chat, 2: Notes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookChatScreen(book: widget.book),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Book Info Card
          _buildBookInfo(context),

          // Tabs
          _buildTabs(),

          // Content
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  int _readingMinutes(int shlokCount) {
    if (shlokCount <= 0) return 2;
    return (shlokCount * 0.5).ceil().clamp(2, 999);
  }

  Widget _buildBookInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.book.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.book.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: widget.book.progress,
                      backgroundColor: AppColors.borderColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.warmOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${widget.book.completedChapters}/${widget.book.totalChapters}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab(0, 'Chapters', Icons.list),
          _buildTab(1, 'Chat', Icons.chat_bubble_outline),
          _buildTab(2, 'Notes', Icons.note),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.warmOrange.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    isSelected ? AppColors.warmOrange : AppColors.tertiaryText,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? AppColors.warmOrange
                      : AppColors.tertiaryText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_selectedTab) {
      case 0:
        return RefreshIndicator(
          onRefresh: _loadChapters,
          color: AppColors.warmOrange,
          child: _buildChaptersList(context),
        );
      case 1:
        return BookChatScreen(book: widget.book);
      case 2:
        return BookNotesScreen(book: widget.book);
      default:
        return RefreshIndicator(
          onRefresh: _loadChapters,
          color: AppColors.warmOrange,
          child: _buildChaptersList(context),
        );
    }
  }

  Widget _buildChaptersList(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined,
                size: 64, color: AppColors.tertiaryText),
            const SizedBox(height: 16),
            Text(
              'No chapters available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chapters.length,
      itemBuilder: (context, index) {
        final chapter = _chapters[index];
        final isCompleted =
            chapter.chapterNumber <= widget.book.completedChapters;
        final shlokCount = _verseCountByChapter[chapter.id] ?? 0;
        final chapterNotes = _notesByChapter[chapter.id] ?? [];
        final hasNotes = chapterNotes.isNotEmpty;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookChapterScreen(
                    book: widget.book,
                    chapter: chapter,
                  ),
                ),
              );
              // Refresh progress when returning
              _loadChapters();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isCompleted
                            ? AppColors.successColor.withOpacity(0.1)
                            : AppColors.borderColor,
                        child: Icon(
                          isCompleted ? Icons.check : Icons.book,
                          color: isCompleted
                              ? AppColors.successColor
                              : AppColors.tertiaryText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chapter.displayTitle,
                              style: TextStyle(
                                fontWeight: isCompleted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (shlokCount > 0) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (_completedVersesByChapter[chapter.id] ?? 0) / shlokCount,
                                  backgroundColor: AppColors.borderColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isCompleted ? AppColors.successColor : AppColors.warmOrange,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Row(
                              children: [
                                if (shlokCount > 0)
                                  Text(
                                    '${_completedVersesByChapter[chapter.id] ?? 0}/$shlokCount completed',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.warmOrange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                  ),
                                if (shlokCount > 0) const Text(' • '),
                                Text(
                                  '${shlokCount > 0 ? _readingMinutes(shlokCount) : chapter.estimatedReadingMinutes} min read',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.tertiaryText,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (hasNotes)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warmOrange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.note,
                                size: 14,
                                color: AppColors.warmOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${chapterNotes.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.warmOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right,
                          color: AppColors.tertiaryText),
                    ],
                  ),
                  if (hasNotes) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warmOrange.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.comment,
                            size: 16,
                            color: AppColors.warmOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              chapterNotes.first.note,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.secondaryText,
                                    fontStyle: FontStyle.italic,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
