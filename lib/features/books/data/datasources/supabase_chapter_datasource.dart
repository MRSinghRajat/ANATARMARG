import '../../../../core/services/supabase_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/chapter_model.dart';

class SupabaseChapterDataSource {
  final SupabaseService _supabase = SupabaseService();

  List<dynamic> _toList(dynamic response) {
    if (response == null) return [];
    if (response is List) return response;
    final data = (response as dynamic).data;
    if (data is List) return data;
    return [];
  }

  Map<String, dynamic>? _toSingle(dynamic response) {
    if (response == null) return null;
    if (response is Map<String, dynamic>) return response;
    final data = (response as dynamic).data;
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  /// Fetch all chapters for a book
  Future<List<ChapterModel>> getChaptersForBook(String bookId) async {
    if (!_supabase.isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.chaptersTable)
          .select()
          .eq('book_id', bookId)
          .order('order_index', ascending: true);

      final list = _toList(response);
      return list
          .map((json) => ChapterModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching chapters from Supabase: $e');
      rethrow;
    }
  }

  /// Fetch a single chapter by ID
  Future<ChapterModel?> getChapterById(String chapterId) async {
    if (!_supabase.isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.chaptersTable)
          .select()
          .eq('id', chapterId)
          .maybeSingle();

      if (response != null) {
        return ChapterModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching chapter $chapterId from Supabase: $e');
      return null;
    }
  }

  /// Get user's progress for a chapter
  Future<Map<String, dynamic>?> getUserChapterProgress(
      String chapterId, String userId) async {
    if (!_supabase.isInitialized) {
      return null;
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.userChapterProgressTable)
          .select()
          .eq('user_id', userId)
          .eq('chapter_id', chapterId)
          .maybeSingle();

      return _toSingle(response);
    } catch (e) {
      print('Error fetching user chapter progress: $e');
      return null;
    }
  }
}
