import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local progress storage for when user is not logged in.
/// Uses SharedPreferences so progress persists across app restarts.
class LocalProgressDataSource {
  static const String _key = 'local_reading_progress';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<Map<String, dynamic>> _load() async {
    final prefs = await _prefs;
    final json = prefs.getString(_key);
    if (json == null) return {};
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _save(Map<String, dynamic> data) async {
    final prefs = await _prefs;
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<void> upsertVerseProgress({
    required String verseId,
    String? chapterId,
    bool isRead = false,
  }) async {
    final data = await _load();
    final verses = Map<String, dynamic>.from(
      data['verses'] as Map<String, dynamic>? ?? {},
    );
    if (isRead && chapterId != null) {
      verses[verseId] = true;
      final chapterVerses = Map<String, dynamic>.from(
        data['chapter_verses'] as Map<String, dynamic>? ?? {},
      );
      final list = List<String>.from(
        (chapterVerses[chapterId] as List<dynamic>?)?.cast<String>() ?? [],
      );
      if (!list.contains(verseId)) {
        list.add(verseId);
        chapterVerses[chapterId] = list;
        data['chapter_verses'] = chapterVerses;
      }
    } else if (!isRead) {
      verses.remove(verseId);
    }
    data['verses'] = verses;
    await _save(data);
  }

  Future<void> upsertChapterProgress({
    required String chapterId,
    required String status,
    required int completedVerses,
    String? lastReadVerseId,
  }) async {
    final data = await _load();
    final chapters = Map<String, dynamic>.from(
      data['chapters'] as Map<String, dynamic>? ?? {},
    );
    chapters[chapterId] = {
      'status': status,
      'completed_verses': completedVerses,
      'last_read_verse_id': lastReadVerseId,
    };
    data['chapters'] = chapters;
    await _save(data);
  }

  Future<void> upsertBookProgress({
    required String bookId,
    required int completedChapters,
    String? lastReadChapterId,
  }) async {
    final data = await _load();
    final books = Map<String, dynamic>.from(
      data['books'] as Map<String, dynamic>? ?? {},
    );
    books[bookId] = {
      'completed_chapters': completedChapters,
      'last_read_chapter_id': lastReadChapterId,
      'last_read_at': DateTime.now().toIso8601String(),
    };
    data['books'] = books;
    await _save(data);
  }

  Future<Set<String>> getReadVerseIdsForChapter(String chapterId) async {
    final data = await _load();
    final chapterVerses = data['chapter_verses'] as Map<String, dynamic>? ?? {};
    final list = chapterVerses[chapterId] as List<dynamic>?;
    if (list == null) return {};
    return list.cast<String>().toSet();
  }

  Future<Map<String, dynamic>?> getChapterProgress(String chapterId) async {
    final data = await _load();
    final chapters = data['chapters'] as Map<String, dynamic>? ?? {};
    final ch = chapters[chapterId];
    if (ch == null) return null;
    return Map<String, dynamic>.from(ch as Map);
  }

  Future<Map<String, dynamic>?> getBookProgress(String bookId) async {
    final data = await _load();
    final books = data['books'] as Map<String, dynamic>? ?? {};
    final b = books[bookId];
    if (b == null) return null;
    return Map<String, dynamic>.from(b as Map);
  }

  Future<Set<String>> getBookmarkedVerseIds() async {
    final data = await _load();
    final bookmarks = data['bookmarks'] as Map<String, dynamic>? ?? {};
    return bookmarks.keys.where((k) => bookmarks[k] == true).cast<String>().toSet();
  }

  Future<void> updateLastReadPosition({
    required String bookId,
    required String chapterId,
    String? lastReadVerseId,
  }) async {
    final data = await _load();
    final chapters = Map<String, dynamic>.from(
      data['chapters'] as Map<String, dynamic>? ?? {},
    );
    final ch = chapters[chapterId] as Map<String, dynamic>? ?? {};
    ch['last_read_verse_id'] = lastReadVerseId;
    chapters[chapterId] = ch;
    data['chapters'] = chapters;

    final books = Map<String, dynamic>.from(
      data['books'] as Map<String, dynamic>? ?? {},
    );
    final b = books[bookId] as Map<String, dynamic>? ?? {};
    b['last_read_chapter_id'] = chapterId;
    b['last_read_at'] = DateTime.now().toIso8601String();
    books[bookId] = b;
    data['books'] = books;
    await _save(data);
  }

  Future<void> setVerseBookmarked(String verseId, bool isBookmarked) async {
    final data = await _load();
    final bookmarks = Map<String, dynamic>.from(
      data['bookmarks'] as Map<String, dynamic>? ?? {},
    );
    if (isBookmarked) {
      bookmarks[verseId] = true;
    } else {
      bookmarks.remove(verseId);
    }
    data['bookmarks'] = bookmarks;
    await _save(data);
  }
}
