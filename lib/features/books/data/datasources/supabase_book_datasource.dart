import '../../../../core/services/supabase_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/book_model.dart';

class SupabaseBookDataSource {
  final SupabaseService _supabase = SupabaseService();

  List<dynamic> _toList(dynamic response) {
    if (response == null) return [];
    if (response is List) return response;
    final data = (response as dynamic).data;
    if (data is List) return data;
    return [];
  }

  /// Fetch all books from Supabase (ascending order)
  Future<List<BookModel>> getAllBooks() async {
    if (!_supabase.isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.booksTable)
          .select()
          .order('id', ascending: true);

      final list = _toList(response);
      return list
          .map((json) => BookModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching books from Supabase: $e');
      rethrow;
    }
  }

  /// Fetch a single book by ID
  Future<BookModel?> getBookById(String bookId) async {
    if (!_supabase.isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.booksTable)
          .select()
          .eq('id', bookId)
          .maybeSingle();

      if (response != null) {
        return BookModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching book $bookId from Supabase: $e');
      return null;
    }
  }

  /// Get user's progress for a book
  Future<Map<String, dynamic>?> getUserBookProgress(
      String bookId, String userId) async {
    if (!_supabase.isInitialized) {
      return null;
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.userBookProgressTable)
          .select()
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching user book progress: $e');
      return null;
    }
  }
}
