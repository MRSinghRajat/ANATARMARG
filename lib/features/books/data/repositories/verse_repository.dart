import '../models/verse_model.dart';
import '../models/verse_translation_model.dart';
import '../datasources/supabase_verse_datasource.dart';
import '../../../../core/services/supabase_service.dart';

class VerseRepository {
  static final VerseRepository _instance = VerseRepository._internal();
  factory VerseRepository() => _instance;
  VerseRepository._internal();

  final SupabaseVerseDataSource _supabaseDataSource = SupabaseVerseDataSource();
  final SupabaseService _supabase = SupabaseService();

  /// Get verse (shlok) count for a chapter
  Future<int> getVerseCountForChapter(String chapterId) async {
    if (_supabase.isInitialized) {
      try {
        return await _supabaseDataSource.getVerseCountForChapter(chapterId);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  /// Fetch all verses for a chapter - tries Supabase first, falls back to empty list
  Future<List<VerseModel>> getVersesForChapter(String chapterId) async {
    if (_supabase.isInitialized) {
      try {
        return await _supabaseDataSource.getVersesForChapter(chapterId);
      } catch (e) {
        print('Error fetching verses from Supabase: $e');
        return [];
      }
    }
    return [];
  }

  /// Fetch a single verse by ID
  Future<VerseModel?> getVerseById(String verseId) async {
    if (_supabase.isInitialized) {
      try {
        return await _supabaseDataSource.getVerseById(verseId);
      } catch (e) {
        print('Error fetching verse from Supabase: $e');
        return null;
      }
    }
    return null;
  }

  /// Fetch translations for a verse
  Future<List<VerseTranslationModel>> getVerseTranslations(
    String verseId, {
    String? languageCode,
  }) async {
    if (_supabase.isInitialized) {
      try {
        return await _supabaseDataSource.getVerseTranslations(verseId,
            languageCode: languageCode);
      } catch (e) {
        print('Error fetching verse translations from Supabase: $e');
        return [];
      }
    }
    return [];
  }

  /// Fetch verses with translations for a chapter
  /// Returns empty list if Supabase not initialized or on error.
  /// Errors are rethrown so callers can show retry/error UI.
  Future<List<VerseWithTranslations>> getVersesWithTranslations(
    String chapterId, {
    String? preferredLanguageCode,
  }) async {
    if (!_supabase.isInitialized) {
      throw Exception(
          'Supabase not connected. Check your internet connection.');
    }
    return await _supabaseDataSource.getVersesWithTranslations(
      chapterId,
      preferredLanguageCode: preferredLanguageCode,
    );
  }

  /// Fetch verses with ALL translations (Hindi + English) for displaying both
  Future<List<VerseWithTranslations>> getVersesWithAllTranslations(
    String chapterId,
  ) async {
    return getVersesWithTranslations(chapterId, preferredLanguageCode: null);
  }
}
