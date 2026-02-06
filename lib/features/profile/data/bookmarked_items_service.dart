import '../../books/data/models/book_model.dart';
import '../../books/data/models/chapter_model.dart';
import '../../books/data/models/verse_model.dart';
import '../../books/data/repositories/book_progress_repository.dart';
import '../../books/data/repositories/book_repository.dart';
import '../../books/data/repositories/chapter_repository.dart';
import '../../books/data/repositories/verse_repository.dart';
import '../../books/data/services/verse_notes_service.dart';

/// Model for a bookmarked verse with full book/chapter context.
class BookmarkedVerseItem {
  final String verseId;
  final VerseModel verse;
  final BookModel book;
  final ChapterModel chapter;
  final String? verseTextSnippet;

  BookmarkedVerseItem({
    required this.verseId,
    required this.verse,
    required this.book,
    required this.chapter,
    this.verseTextSnippet,
  });
}

/// Service to fetch all bookmarked verses with full book/chapter/verse details.
class BookmarkedItemsService {
  static final BookmarkedItemsService _instance =
      BookmarkedItemsService._internal();
  factory BookmarkedItemsService() => _instance;
  BookmarkedItemsService._internal();

  final VerseNotesService _notesService = VerseNotesService();
  final BookProgressRepository _progressRepo = BookProgressRepository();
  final VerseRepository _verseRepo = VerseRepository();
  final BookRepository _bookRepo = BookRepository();
  final ChapterRepository _chapterRepo = ChapterRepository();

  /// Fetch all bookmarked verses with full details.
  /// Merges bookmarks from local (SharedPreferences) and Supabase.
  Future<List<BookmarkedVerseItem>> getBookmarkedItems() async {
    var ids = await _notesService.getBookmarkedVerseIds();
    final supabaseIds = await _progressRepo.getBookmarkedVerseIds();
    if (supabaseIds.isNotEmpty) {
      ids = ids.union(supabaseIds);
    }
    if (ids.isEmpty) return [];

    final items = <BookmarkedVerseItem>[];
    final seenVerseIds = <String>{};

    for (final verseId in ids) {
      if (seenVerseIds.contains(verseId)) continue;
      seenVerseIds.add(verseId);

      final verse = await _verseRepo.getVerseById(verseId);
      if (verse == null) continue;

      final book = await _bookRepo.getBookById(verse.bookId);
      if (book == null) continue;

      final chapter = await _chapterRepo.getChapterById(verse.chapterId);
      if (chapter == null) continue;

      items.add(BookmarkedVerseItem(
        verseId: verseId,
        verse: verse,
        book: book,
        chapter: chapter,
      ));
    }

    return items;
  }

  /// Get unique books that have at least one bookmarked verse, with bookmark count.
  Future<Map<BookModel, int>> getBooksWithBookmarks() async {
    final items = await getBookmarkedItems();
    final countByBookId = <String, int>{};
    final bookById = <String, BookModel>{};
    for (final item in items) {
      countByBookId[item.book.id] = (countByBookId[item.book.id] ?? 0) + 1;
      bookById[item.book.id] = item.book;
    }
    return {
      for (final id in countByBookId.keys) bookById[id]!: countByBookId[id]!,
    };
  }
}
