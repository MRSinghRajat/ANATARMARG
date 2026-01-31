import '../../../../core/services/supabase_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../services/verse_notes_service.dart';

/// Supabase datasource for user verse notes (persists across login)
class SupabaseVerseNotesDataSource {
  final SupabaseService _supabase = SupabaseService();

  List<dynamic> _toList(dynamic response) {
    if (response == null) return [];
    if (response is List) return response;
    final data = (response as dynamic).data;
    if (data is List) return data;
    return [];
  }

  Future<List<VerseNoteModel>> getNotesForUser(String userId) async {
    if (!_supabase.isInitialized) return [];

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.userVerseNotesTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = _toList(response);
      return list
          .map((json) => _noteFromRow(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching notes from Supabase: $e');
      return [];
    }
  }

  Future<List<VerseNoteModel>> getNotesForChapter(
      String userId, String chapterId) async {
    if (!_supabase.isInitialized) return [];

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.userVerseNotesTable)
          .select()
          .eq('user_id', userId)
          .eq('chapter_id', chapterId)
          .order('created_at', ascending: false);

      final list = _toList(response);
      return list
          .map((json) => _noteFromRow(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching chapter notes from Supabase: $e');
      return [];
    }
  }

  Future<void> addNote(String userId, VerseNoteModel note) async {
    if (!_supabase.isInitialized) return;

    try {
      await _supabase.client!.from(SupabaseConfig.userVerseNotesTable).insert({
        'user_id': userId,
        'verse_id': note.verseId,
        'verse_text': note.verseText,
        'note': note.note,
        'book_id': note.bookId,
        'chapter_id': note.chapterId,
        'shloka_number': note.shlokaNumber,
      });
    } catch (e) {
      print('Error adding note to Supabase: $e');
      rethrow;
    }
  }

  Future<void> removeNote(String userId, String verseId, String note) async {
    if (!_supabase.isInitialized) return;

    try {
      await _supabase.client!
          .from(SupabaseConfig.userVerseNotesTable)
          .delete()
          .eq('user_id', userId)
          .eq('verse_id', verseId)
          .eq('note', note);
    } catch (e) {
      print('Error removing note from Supabase: $e');
    }
  }

  VerseNoteModel _noteFromRow(Map<String, dynamic> row) {
    return VerseNoteModel(
      verseId: row['verse_id'] as String,
      verseText: row['verse_text'] as String,
      note: row['note'] as String,
      bookId: row['book_id'] as String,
      chapterId: row['chapter_id'] as String,
      shlokaNumber: row['shloka_number'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
