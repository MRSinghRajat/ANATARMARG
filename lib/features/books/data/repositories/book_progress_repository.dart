import '../datasources/supabase_progress_datasource.dart';

/// Repository for tracking book, chapter, and verse/shlok progress.
/// Coordinates updates across user_book_progress, user_chapter_progress, user_verse_progress.
class BookProgressRepository {
  static final BookProgressRepository _instance =
      BookProgressRepository._internal();
  factory BookProgressRepository() => _instance;
  BookProgressRepository._internal();

  final SupabaseProgressDataSource _progressDataSource =
      SupabaseProgressDataSource();

  /// Mark a verse/shlok as read and update chapter progress
  Future<void> markVerseRead({
    required String verseId,
    required String chapterId,
    required String bookId,
    required int completedVersesCount,
    required int totalVerses,
  }) async {
    await _progressDataSource.upsertVerseProgress(
      verseId: verseId,
      isRead: true,
      readAt: DateTime.now(),
    );
    final status =
        completedVersesCount >= totalVerses ? 'completed' : 'in_progress';
    await _progressDataSource.upsertChapterProgress(
      chapterId: chapterId,
      status: status,
      completedVerses: completedVersesCount,
      lastReadVerseId: verseId,
      completedAt: status == 'completed' ? DateTime.now() : null,
    );
  }

  /// Mark a verse/shlok as bookmarked (sync to Supabase when logged in)
  Future<void> setVerseBookmarked(String verseId, bool isBookmarked) async {
    await _progressDataSource.upsertVerseProgress(
      verseId: verseId,
      isBookmarked: isBookmarked,
    );
  }

  /// Complete a chapter: mark all verses read, update chapter & book progress
  Future<void> completeChapter({
    required String bookId,
    required String chapterId,
    required List<String> verseIds,
    required int completedChaptersCount,
    required int totalChapters,
  }) async {
    final now = DateTime.now();
    for (final verseId in verseIds) {
      await _progressDataSource.upsertVerseProgress(
        verseId: verseId,
        isRead: true,
        readAt: now,
      );
    }
    await _progressDataSource.upsertChapterProgress(
      chapterId: chapterId,
      status: 'completed',
      completedVerses: verseIds.length,
      lastReadVerseId: verseIds.isNotEmpty ? verseIds.last : null,
      completedAt: now,
    );
    await _progressDataSource.upsertBookProgress(
      bookId: bookId,
      completedChapters: completedChaptersCount,
      lastReadChapterId: chapterId,
      lastReadAt: now,
    );
  }

  /// Get read verse IDs for a chapter (for visual indicators)
  Future<Set<String>> getReadVerseIds(String chapterId) async {
    return _progressDataSource.getReadVerseIdsForChapter(chapterId);
  }

  /// Get bookmarked verse IDs (Supabase-backed when logged in)
  Future<Set<String>> getBookmarkedVerseIds() async {
    return _progressDataSource.getBookmarkedVerseIds();
  }

  /// Get last-read verse ID for a chapter (for resuming)
  Future<String?> getLastReadVerseId(String chapterId) async {
    final progress = await _progressDataSource.getChapterProgress(chapterId);
    return progress?['last_read_verse_id'] as String?;
  }

  /// Save last-read position when user leaves (resume from here next time)
  Future<void> saveLastReadPosition({
    required String bookId,
    required String chapterId,
    String? lastReadVerseId,
  }) async {
    await _progressDataSource.updateLastReadPosition(
      bookId: bookId,
      chapterId: chapterId,
      lastReadVerseId: lastReadVerseId,
    );
  }
}
