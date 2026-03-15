import '../../../../core/services/supabase_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/verse_model.dart';
import '../models/verse_translation_model.dart';

class SupabaseVerseDataSource {
  final SupabaseService _supabase = SupabaseService();

  /// Extract list from Supabase response (v2 returns PostgrestResponse with .data)
  List<dynamic> _toList(dynamic response) {
    if (response == null) return [];
    if (response is List) return response;
    // Supabase v2 returns PostgrestResponse with .data property
    final data = (response as dynamic).data;
    if (data is List) return data;
    return [];
  }

  /// Get verse count for a chapter (lightweight - selects id only)
  Future<int> getVerseCountForChapter(String chapterId) async {
    if (!_supabase.isInitialized) return 0;
    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.versesTable)
          .select('id')
          .eq('chapter_id', chapterId);
      final list = _toList(response);
      return list.length;
    } catch (e) {
      return 0;
    }
  }

  /// Fetch all verses for a chapter
  /// Query: SELECT * FROM verses WHERE chapter_id = ? ORDER BY order_index
  Future<List<VerseModel>> getVersesForChapter(String chapterId) async {
    if (!_supabase.isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.versesTable)
          .select()
          .eq('chapter_id', chapterId)
          .order('order_index', ascending: true);

      final list = _toList(response);
      return list
          .map((json) => VerseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching verses (chapter_id=$chapterId): $e');
      rethrow;
    }
  }

  /// Extract single object from maybeSingle response
  Map<String, dynamic>? _toSingle(dynamic response) {
    if (response == null) return null;
    if (response is Map<String, dynamic>) return response;
    final data = (response as dynamic).data;
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  /// Fetch a single verse by ID
  Future<VerseModel?> getVerseById(String verseId) async {
    if (!_supabase.isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.versesTable)
          .select()
          .eq('id', verseId)
          .maybeSingle();

      final data = _toSingle(response);
      if (data != null) {
        return VerseModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching verse $verseId from Supabase: $e');
      return null;
    }
  }

  /// Fetch translations for a verse
  Future<List<VerseTranslationModel>> getVerseTranslations(String verseId,
      {String? languageCode}) async {
    if (!_supabase.isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      var query = _supabase.client!
          .from(SupabaseConfig.verseTranslationsTable)
          .select()
          .eq('verse_id', verseId);

      if (languageCode != null) {
        query = query.eq('language_code', languageCode);
      }

      final response = await query.order('is_primary', ascending: false);

      final list = _toList(response);
      return list
          .map((json) =>
              VerseTranslationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching verse translations from Supabase: $e');
      rethrow;
    }
  }

  /// Fetch verses with translations for a chapter
  /// Uses 2 queries: verses first, then all translations in one batch (no N+1)
  /// Pass preferredLanguageCode for single language, or null for ALL translations (Hindi + English)
  Future<List<VerseWithTranslations>> getVersesWithTranslations(
    String chapterId, {
    String? preferredLanguageCode,
  }) async {
    if (!_supabase.isInitialized) {
      throw Exception('Supabase not initialized');
    }

    // Query 1: Get all verses for chapter
    final verses = await getVersesForChapter(chapterId);
    if (verses.isEmpty) return [];

    // Query 2: Get ALL translations for these verses in one request
    final verseIds = verses.map((v) => v.id).toList();
    final translationsList = await _getTranslationsForVerseIds(
      verseIds,
      languageCode: preferredLanguageCode,
    );

    // Group translations by verse_id
    final translationsByVerse = <String, List<VerseTranslationModel>>{};
    for (final t in translationsList) {
      translationsByVerse.putIfAbsent(t.verseId, () => []).add(t);
    }

    // Combine verses with their translations (preserve verse order)
    return verses
        .map((verse) => VerseWithTranslations(
              verse: verse,
              translations: translationsByVerse[verse.id] ?? [],
            ))
        .toList();
  }

  /// Fetch translations for multiple verse IDs in one query
  Future<List<VerseTranslationModel>> _getTranslationsForVerseIds(
    List<String> verseIds, {
    String? languageCode,
  }) async {
    if (verseIds.isEmpty) return [];

    try {
      var query = _supabase.client!
          .from(SupabaseConfig.verseTranslationsTable)
          .select()
          .inFilter('verse_id', verseIds);

      if (languageCode != null) {
        query = query.eq('language_code', languageCode);
      }

      final response = await query.order('is_primary', ascending: false);

      final list = response as List;
      final result = <VerseTranslationModel>[];

      for (final row in list) {
        final tMap = row as Map<String, dynamic>;
        result.add(VerseTranslationModel.fromJson(tMap));
      }

      return result;
    } catch (e) {
      print('Error fetching translations for verse IDs: $e');
      rethrow;
    }
  }

  /// Get user's progress for a verse
  Future<Map<String, dynamic>?> getUserVerseProgress(
      String verseId, String userId) async {
    if (!_supabase.isInitialized) {
      return null;
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.userVerseProgressTable)
          .select()
          .eq('user_id', userId)
          .eq('verse_id', verseId)
          .maybeSingle();

      final data = _toSingle(response);
      return data;
    } catch (e) {
      print('Error fetching user verse progress: $e');
      return null;
    }
  }
}

/// Helper class to combine verse with its translations
class VerseWithTranslations {
  final VerseModel verse;
  final List<VerseTranslationModel> translations;

  VerseWithTranslations({
    required this.verse,
    required this.translations,
  });

  /// Get translation by language code
  VerseTranslationModel? getTranslation(String languageCode) {
    try {
      return translations.firstWhere((t) => t.languageCode == languageCode);
    } catch (e) {
      return null;
    }
  }

  /// Get Hindi translation (hi or sa for Devanagari)
  VerseTranslationModel? get hindiTranslation =>
      getTranslation('hi') ?? getTranslation('sa');

  /// Get English translation
  VerseTranslationModel? get englishTranslation => getTranslation('en');

  /// Get English AI commentary (language_code: en-commentary)
  VerseTranslationModel? get englishCommentary =>
      getTranslation('en-commentary');

  /// Get Hindi AI commentary (language_code: hi-commentary or Hi-commentary)
  VerseTranslationModel? get hindiCommentary =>
      getTranslation('hi-commentary') ?? getTranslation('Hi-commentary');

  /// Get primary translation
  VerseTranslationModel? get primaryTranslation {
    try {
      return translations.firstWhere((t) => t.isPrimary);
    } catch (e) {
      return translations.isNotEmpty ? translations.first : null;
    }
  }
}
