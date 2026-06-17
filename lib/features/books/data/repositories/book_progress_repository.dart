import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/daily_notification_service.dart';
import '../../../../core/services/notification_preferences.dart';
import '../datasources/local_progress_datasource.dart';
import '../datasources/supabase_progress_datasource.dart';

/// Repository for tracking book, chapter, and verse/shlok progress.
/// Uses Supabase when user is logged in, otherwise local storage.
class BookProgressRepository {
  static final BookProgressRepository _instance =
      BookProgressRepository._internal();
  factory BookProgressRepository() => _instance;
  BookProgressRepository._internal();

  final SupabaseProgressDataSource _supabase = SupabaseProgressDataSource();
  final LocalProgressDataSource _local = LocalProgressDataSource();

  bool get _useSupabase => _supabase.canPersist;

  /// Mark a verse/shlok as read and update chapter progress
  Future<void> markVerseRead({
    required String verseId,
    required String chapterId,
    required String bookId,
    required int completedVersesCount,
    required int totalVerses,
  }) async {
    if (_useSupabase) {
      await _supabase.upsertVerseProgress(
        verseId: verseId,
        isRead: true,
        readAt: DateTime.now(),
      );
    } else {
      await _local.upsertVerseProgress(
        verseId: verseId,
        chapterId: chapterId,
        isRead: true,
      );
    }
    final status =
        completedVersesCount >= totalVerses ? 'completed' : 'in_progress';
    if (_useSupabase) {
      await _supabase.upsertChapterProgress(
        chapterId: chapterId,
        status: status,
        completedVerses: completedVersesCount,
        lastReadVerseId: verseId,
        completedAt: status == 'completed' ? DateTime.now() : null,
      );
    } else {
      await _local.upsertChapterProgress(
        chapterId: chapterId,
        status: status,
        completedVerses: completedVersesCount,
        lastReadVerseId: verseId,
      );
    }
  }

  /// Mark a verse/shlok as bookmarked
  Future<void> setVerseBookmarked(String verseId, bool isBookmarked) async {
    if (_useSupabase) {
      await _supabase.upsertVerseProgress(
        verseId: verseId,
        isBookmarked: isBookmarked,
      );
    } else {
      await _local.setVerseBookmarked(verseId, isBookmarked);
    }
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
    if (_useSupabase) {
      for (final verseId in verseIds) {
        await _supabase.upsertVerseProgress(
          verseId: verseId,
          isRead: true,
          readAt: now,
        );
      }
      await _supabase.upsertChapterProgress(
        chapterId: chapterId,
        status: 'completed',
        completedVerses: verseIds.length,
        lastReadVerseId: verseIds.isNotEmpty ? verseIds.last : null,
        completedAt: now,
      );
      await _supabase.upsertBookProgress(
        bookId: bookId,
        completedChapters: completedChaptersCount,
        lastReadChapterId: chapterId,
        lastReadAt: now,
      );
    } else {
      for (final verseId in verseIds) {
        await _local.upsertVerseProgress(
          verseId: verseId,
          chapterId: chapterId,
          isRead: true,
        );
      }
      await _local.upsertChapterProgress(
        chapterId: chapterId,
        status: 'completed',
        completedVerses: verseIds.length,
        lastReadVerseId: verseIds.isNotEmpty ? verseIds.last : null,
      );
      await _local.upsertBookProgress(
        bookId: bookId,
        completedChapters: completedChaptersCount,
        lastReadChapterId: chapterId,
      );
    }
  }

  /// Get read verse IDs for a chapter (for visual indicators)
  Future<Set<String>> getReadVerseIds(String chapterId) async {
    if (_useSupabase) {
      return _supabase.getReadVerseIdsForChapter(chapterId);
    }
    return _local.getReadVerseIdsForChapter(chapterId);
  }

  /// Get book progress (completed_chapters, last_read_at, etc.)
  Future<Map<String, dynamic>?> getBookProgress(String bookId) async {
    if (_useSupabase) {
      return _supabase.getBookProgress(bookId);
    }
    return _local.getBookProgress(bookId);
  }

  /// Get bookmarked verse IDs
  Future<Set<String>> getBookmarkedVerseIds() async {
    if (_useSupabase) {
      return _supabase.getBookmarkedVerseIds();
    }
    return _local.getBookmarkedVerseIds();
  }

  /// Get last-read verse ID for a chapter (for resuming)
  Future<String?> getLastReadVerseId(String chapterId) async {
    final progress = _useSupabase
        ? await _supabase.getChapterProgress(chapterId)
        : await _local.getChapterProgress(chapterId);
    return progress?['last_read_verse_id'] as String?;
  }

  /// Save last-read position when user leaves (resume from here next time)
  Future<void> saveLastReadPosition({
    required String bookId,
    required String chapterId,
    String? lastReadVerseId,
    String? bookNameForReminder,
  }) async {
    if (_useSupabase) {
      await _supabase.updateLastReadPosition(
        bookId: bookId,
        chapterId: chapterId,
        lastReadVerseId: lastReadVerseId,
      );
    } else {
      await _local.updateLastReadPosition(
        bookId: bookId,
        chapterId: chapterId,
        lastReadVerseId: lastReadVerseId,
      );
    }
    if (bookNameForReminder != null && bookNameForReminder.isNotEmpty) {
      final p = await SharedPreferences.getInstance();
      await p.setString('reading_reminder_book_id', bookId);
      await p.setString('reading_reminder_book_title', bookNameForReminder);
      final readingOn = await NotificationPreferences.getBool(
        NotificationPreferences.keyReading,
      );
      await DailyNotificationService.updateFromReadingReminderSetting(
        readingOn,
      );
    }
  }
}
