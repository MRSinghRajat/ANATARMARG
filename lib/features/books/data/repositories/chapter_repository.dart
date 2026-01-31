import '../models/chapter_model.dart';
import '../datasources/supabase_chapter_datasource.dart';
import '../../../../core/services/supabase_service.dart';

class ChapterRepository {
  static final ChapterRepository _instance = ChapterRepository._internal();
  factory ChapterRepository() => _instance;
  ChapterRepository._internal();

  final SupabaseChapterDataSource _supabaseDataSource =
      SupabaseChapterDataSource();
  final SupabaseService _supabase = SupabaseService();

  /// Fetch all chapters for a book - tries Supabase first, falls back to local data
  Future<List<ChapterModel>> getChaptersForBook(String bookId) async {
    if (_supabase.isInitialized) {
      try {
        final chapters = await _supabaseDataSource.getChaptersForBook(bookId);
        return chapters;
      } catch (e) {
        print('Error fetching chapters from Supabase, using local data: $e');
        return _getDefaultChapters(bookId);
      }
    }
    return _getDefaultChapters(bookId);
  }

  /// Fetch a single chapter by ID - tries Supabase first, falls back to local data
  Future<ChapterModel?> getChapterById(String chapterId) async {
    if (_supabase.isInitialized) {
      try {
        return await _supabaseDataSource.getChapterById(chapterId);
      } catch (e) {
        print('Error fetching chapter from Supabase: $e');
        return null;
      }
    }
    return null;
  }

  /// Synchronous method for fallback (used when Supabase fails)
  List<ChapterModel> getChaptersForBookSync(String bookId) {
    return _getDefaultChapters(bookId);
  }

  List<ChapterModel> _getDefaultChapters(String bookId) {
    // Fallback: Generate default chapters based on book
    switch (bookId) {
      case 'bhagavad_gita':
      case 'geeta':
        return List.generate(18, (index) {
          final chapterNum = index + 1;
          return ChapterModel(
            id: 'bg_chapter_$chapterNum',
            bookId: bookId,
            chapterNumber: chapterNum,
            title: 'Chapter $chapterNum',
            orderIndex: chapterNum,
            estimatedReadingMinutes: 2,
          );
        });
      case 'mahabharata':
        return List.generate(18, (index) {
          final chapterNum = index + 1;
          return ChapterModel(
            id: 'mh_parva_$chapterNum',
            bookId: bookId,
            chapterNumber: chapterNum,
            title: 'Parva $chapterNum',
            orderIndex: chapterNum,
            estimatedReadingMinutes: 2,
          );
        });
      case 'ramayan':
        return List.generate(7, (index) {
          final chapterNum = index + 1;
          return ChapterModel(
            id: 'ramayan_kand_$chapterNum',
            bookId: bookId,
            chapterNumber: chapterNum,
            title: 'Kand $chapterNum',
            orderIndex: chapterNum,
            estimatedReadingMinutes: 2,
          );
        });
      default:
        return [];
    }
  }
}
