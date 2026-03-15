import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../books/data/models/granthalaya_models.dart';
import '../../../books/data/services/granthalaya_bookmarks_service.dart';
import '../../../books/data/services/verse_notes_service.dart'
    show VerseNotesService, VerseNoteModel;
import '../../../books/data/repositories/book_repository.dart';
import '../../../books/data/repositories/chapter_repository.dart';
import '../../../books/presentation/providers/book_providers.dart';
import '../../../books/presentation/screens/book_chapter_screen.dart';
import '../../../books/presentation/screens/sacred_text_reader_screen.dart';
import '../../../books/presentation/screens/sacred_story_reader_screen.dart';
import '../../data/bookmarked_items_service.dart';

/// Full-screen list of all bookmarked verses, sacred texts, sacred stories, and notes.
class BookmarkedNotesScreen extends ConsumerStatefulWidget {
  const BookmarkedNotesScreen({super.key});

  @override
  ConsumerState<BookmarkedNotesScreen> createState() =>
      _BookmarkedNotesScreenState();
}

class _BookmarkedNotesScreenState extends ConsumerState<BookmarkedNotesScreen> {
  bool _isLoading = true;
  List<BookmarkedVerseItem> _verseItems = [];
  List<SacredTextModel> _bookmarkedTexts = [];
  List<SacredStoryModel> _bookmarkedStories = [];
  List<_NoteWithContext> _notesWithContext = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final textsAsync = ref.read(sacredTextsProvider(null).future);
    final storiesAsync = ref.read(sacredStoriesCollectionProvider(null).future);
    final allTexts = await textsAsync;
    final allStories = await storiesAsync;

    final verseService = BookmarkedItemsService();
    final bookmarkService = GranthalayaBookmarksService();
    final notesService = VerseNotesService();
    final bookRepo = BookRepository();
    final chapterRepo = ChapterRepository();

    final verseItems = await verseService.getBookmarkedItems();
    final textIds = await bookmarkService.getBookmarkedSacredTextIds();
    final storyIds = await bookmarkService.getBookmarkedSacredStoryIds();
    final notes = await notesService.getAllNotes();

    final bookmarkedTexts =
        allTexts.where((t) => textIds.contains(t.id)).toList();
    final bookmarkedStories =
        allStories.where((s) => storyIds.contains(s.id)).toList();

    final notesWithContext = <_NoteWithContext>[];
    for (final note in notes.take(50)) {
      final book = await bookRepo.getBookById(note.bookId);
      final chapter = await chapterRepo.getChapterById(note.chapterId);
      notesWithContext.add(_NoteWithContext(
        note: note,
        bookName: book?.name ?? note.bookId,
        chapterLabel: chapter != null
            ? 'Chapter ${chapter.chapterNumber}'
            : 'Chapter',
      ));
    }

    if (mounted) {
      setState(() {
        _verseItems = verseItems;
        _bookmarkedTexts = bookmarkedTexts;
        _bookmarkedStories = bookmarkedStories;
        _notesWithContext = notesWithContext;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepAsh,
      appBar: AppBar(
        backgroundColor: AppColors.deepAsh,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.matteGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bookmarks & Notes',
          style: GoogleFonts.crimsonPro(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.matteGold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.matteGold),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.matteGold,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_verseItems.isNotEmpty ||
                      _bookmarkedTexts.isNotEmpty ||
                      _bookmarkedStories.isNotEmpty) ...[
                    _sectionTitle('Bookmarked'),
                    const SizedBox(height: 12),
                    ..._verseItems.map((bv) => _verseTile(bv)),
                    ..._bookmarkedTexts.map((t) => _sacredTextTile(t)),
                    ..._bookmarkedStories.map((s) => _sacredStoryTile(s)),
                    const SizedBox(height: 24),
                  ],
                  if (_notesWithContext.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.note,
                            color: AppColors.matteGold.withOpacity(0.8),
                            size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Notes',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.matteGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._notesWithContext.map((item) => _noteTile(item)),
                  ],
                  if (_verseItems.isEmpty &&
                      _bookmarkedTexts.isEmpty &&
                      _bookmarkedStories.isEmpty &&
                      _notesWithContext.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'No bookmarks or notes yet.\nBookmark verses, texts, or stories while reading.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.zinc500,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Icon(Icons.bookmark, color: AppColors.matteGold.withOpacity(0.8), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.matteGold,
          ),
        ),
      ],
    );
  }

  Widget _verseTile(BookmarkedVerseItem bv) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookChapterScreen(
                  book: bv.book,
                  chapter: bv.chapter,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.charcoalCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.matteGold.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.matteGold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bv.book.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Chapter ${bv.chapter.chapterNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.zinc500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sacredTextTile(SacredTextModel text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SacredTextReaderScreen(sacredText: text),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.charcoalCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.matteGold.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_stories,
                    size: 20, color: AppColors.matteGold.withOpacity(0.8)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sacredStoryTile(SacredStoryModel story) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SacredStoryReaderScreen(story: story),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.charcoalCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.matteGold.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.menu_book,
                    size: 20, color: AppColors.matteGold.withOpacity(0.8)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    story.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _noteTile(_NoteWithContext item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final book =
                await BookRepository().getBookById(item.note.bookId);
            final chapter =
                await ChapterRepository().getChapterById(item.note.chapterId);
            if (!mounted) return;
            if (book != null && chapter != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookChapterScreen(
                    book: book,
                    chapter: chapter,
                  ),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.charcoalCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.matteGold.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.bookName} · ${item.chapterLabel}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.matteGold.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.note.note,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoteWithContext {
  final VerseNoteModel note;
  final String bookName;
  final String chapterLabel;

  _NoteWithContext({
    required this.note,
    required this.bookName,
    required this.chapterLabel,
  });
}
