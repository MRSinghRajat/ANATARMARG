import '../../../../core/services/supabase_service.dart';
import '../../../../core/config/supabase_config.dart';

/// Data source for user progress (book, chapter, verse/shlok).
/// Persists to Supabase when user is authenticated.
class SupabaseProgressDataSource {
  final SupabaseService _supabase = SupabaseService();

  bool get canPersist =>
      _supabase.isInitialized && _supabase.currentUserId != null;

  /// Upsert user book progress (completed_chapters, last_read_chapter_id, last_read_at)
  Future<void> upsertBookProgress({
    required String bookId,
    required int completedChapters,
    String? lastReadChapterId,
    DateTime? lastReadAt,
  }) async {
    if (!canPersist) return;
    final userId = _supabase.currentUserId!;
    try {
      await _supabase.client!.from(SupabaseConfig.userBookProgressTable).upsert(
        {
          'user_id': userId,
          'book_id': bookId,
          'completed_chapters': completedChapters,
          'last_read_chapter_id': lastReadChapterId,
          'last_read_at': lastReadAt?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,book_id',
      );
    } catch (e) {
      print('Error upserting book progress: $e');
    }
  }

  /// Upsert user chapter progress (status, completed_verses, last_read_verse_id)
  Future<void> upsertChapterProgress({
    required String chapterId,
    required String status,
    required int completedVerses,
    String? lastReadVerseId,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    if (!canPersist) return;
    final userId = _supabase.currentUserId!;
    try {
      await _supabase.client!
          .from(SupabaseConfig.userChapterProgressTable)
          .upsert(
        {
          'user_id': userId,
          'chapter_id': chapterId,
          'status': status,
          'completed_verses': completedVerses,
          'last_read_verse_id': lastReadVerseId,
          'started_at': startedAt?.toIso8601String(),
          'completed_at': completedAt?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,chapter_id',
      );
    } catch (e) {
      print('Error upserting chapter progress: $e');
    }
  }

  /// Upsert user verse/shlok progress (is_read, is_bookmarked, read_at)
  /// [chapterId] optional, used by local fallback for chapter-verse mapping
  Future<void> upsertVerseProgress({
    required String verseId,
    String? chapterId,
    bool isRead = false,
    bool isBookmarked = false,
    DateTime? readAt,
  }) async {
    if (!canPersist) return;
    final userId = _supabase.currentUserId!;
    try {
      await _supabase.client!
          .from(SupabaseConfig.userVerseProgressTable)
          .upsert(
        {
          'user_id': userId,
          'verse_id': verseId,
          'is_read': isRead,
          'is_bookmarked': isBookmarked,
          'read_at': readAt?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,verse_id',
      );
    } catch (e) {
      print('Error upserting verse progress: $e');
    }
  }

  /// Get chapter progress for a user
  Future<Map<String, dynamic>?> getChapterProgress(String chapterId) async {
    if (!canPersist) return null;
    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.userChapterProgressTable)
          .select()
          .eq('user_id', _supabase.currentUserId!)
          .eq('chapter_id', chapterId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error fetching chapter progress: $e');
      return null;
    }
  }

  /// Get set of read verse IDs for a chapter (from user_verse_progress joined with verses)
  Future<Set<String>> getReadVerseIdsForChapter(String chapterId) async {
    if (!canPersist) return {};
    try {
      final verses = await _supabase.client!
          .from('verses')
          .select('id')
          .eq('chapter_id', chapterId);
      final verseIds = (verses as List).map((v) => v['id'] as String).toList();
      if (verseIds.isEmpty) return {};

      final progress = await _supabase.client!
          .from(SupabaseConfig.userVerseProgressTable)
          .select('verse_id')
          .eq('user_id', _supabase.currentUserId!)
          .inFilter('verse_id', verseIds)
          .eq('is_read', true);
      return (progress as List).map((p) => p['verse_id'] as String).toSet();
    } catch (e) {
      print('Error fetching read verses: $e');
      return {};
    }
  }

  /// Get user book progress
  Future<Map<String, dynamic>?> getBookProgress(String bookId) async {
    if (!canPersist) return null;
    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.userBookProgressTable)
          .select()
          .eq('user_id', _supabase.currentUserId!)
          .eq('book_id', bookId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error fetching book progress: $e');
      return null;
    }
  }

  /// Update only last-read position (chapter + book) without overwriting completed counts
  Future<void> updateLastReadPosition({
    required String bookId,
    required String chapterId,
    String? lastReadVerseId,
  }) async {
    if (!canPersist) return;
    final userId = _supabase.currentUserId!;
    final now = DateTime.now().toIso8601String();
    try {
      final existing = await _supabase.client!
          .from(SupabaseConfig.userChapterProgressTable)
          .select()
          .eq('user_id', userId)
          .eq('chapter_id', chapterId)
          .maybeSingle();
      await _supabase.client!
          .from(SupabaseConfig.userChapterProgressTable)
          .upsert({
        'user_id': userId,
        'chapter_id': chapterId,
        'last_read_verse_id': lastReadVerseId,
        'status': existing?['status'] ?? 'in_progress',
        'completed_verses': existing?['completed_verses'] ?? 0,
        'updated_at': now,
      }, onConflict: 'user_id,chapter_id');
    } catch (e) {
      print('Error updating chapter last read: $e');
    }
    try {
      final bookProgress = await getBookProgress(bookId);
      final completedChapters =
          bookProgress?['completed_chapters'] as int? ?? 0;
      await _supabase.client!
          .from(SupabaseConfig.userBookProgressTable)
          .upsert({
        'user_id': userId,
        'book_id': bookId,
        'completed_chapters': completedChapters,
        'last_read_chapter_id': chapterId,
        'last_read_at': now,
        'updated_at': now,
      }, onConflict: 'user_id,book_id');
    } catch (e) {
      print('Error updating book last read: $e');
    }
  }

  /// Get set of bookmarked verse IDs
  Future<Set<String>> getBookmarkedVerseIds() async {
    if (!canPersist) return {};
    try {
      final progress = await _supabase.client!
          .from(SupabaseConfig.userVerseProgressTable)
          .select('verse_id')
          .eq('user_id', _supabase.currentUserId!)
          .eq('is_bookmarked', true);
      return (progress as List).map((p) => p['verse_id'] as String).toSet();
    } catch (e) {
      print('Error fetching bookmarks: $e');
      return {};
    }
  }
}
