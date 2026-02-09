import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../books/data/datasources/supabase_verse_datasource.dart'
    show VerseWithTranslations;
import '../../../books/data/repositories/chapter_repository.dart';
import '../../../books/data/repositories/verse_repository.dart';
import '../../../content/data/datasources/gpt_api_service.dart';
import '../../../content/data/repositories/verse_of_day_repository.dart';
import '../models/ashram_daily_verse_model.dart';

/// Provides daily verse for Ashram - from Supabase (Gita/Mahabharata) or GPT fallback.
/// Tracks whether user has viewed it today (hide after view).
class AshramDailyVerseRepository {
  static final AshramDailyVerseRepository _instance =
      AshramDailyVerseRepository._internal();
  factory AshramDailyVerseRepository() => _instance;
  AshramDailyVerseRepository._internal();

  final VerseRepository _verseRepository = VerseRepository();
  final ChapterRepository _chapterRepository = ChapterRepository();
  final VerseOfDayRepository _verseOfDayRepo = VerseOfDayRepository();
  final GPTApiService _gptService = GPTApiService();

  static const String _viewedKey = 'ashram_verse_viewed_date';
  static const String _cacheKey = 'ashram_verse_cache';
  static const String _cacheDateKey = 'ashram_verse_cache_date';

  static const List<String> _sourceBooks = ['bhagavad_gita', 'mahabharata'];

  /// Get today's verse. Returns null if user already viewed it today.
  Future<AshramDailyVerseModel?> getTodaysVerse({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();

    if (!forceRefresh) {
      final viewedDate = prefs.getString(_viewedKey);
      if (viewedDate == today) {
        return null; // User already viewed - hide card
      }
    }

    // Check cache for today
    final cachedDate = prefs.getString(_cacheDateKey);
    if (cachedDate == today && !forceRefresh) {
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        return _parseCachedVerse(cached);
      }
    }

    try {
      final verse = await _getVerseFromSupabase();
      if (verse != null) {
        await _cacheVerse(prefs, today, verse);
        return verse;
      }
    } catch (e) {
      debugPrint('AshramDailyVerse: Supabase failed: $e');
    }

    // Fallback to GPT
    try {
      final verse = await _getVerseFromGpt();
      await _cacheVerse(prefs, today, verse);
      return verse;
    } catch (e) {
      debugPrint('AshramDailyVerse: GPT fallback failed: $e');
    }

    // Last resort: show a static verse so user always has something
    return AshramDailyVerseModel(
      id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      bookName: 'Bhagavad Gita',
      chapterName: 'Chapter 2',
      verseNumber: '47',
      sanskritText: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।',
      hindiOrEnglishText:
          'You have the right to work only, but never to its fruits. Let not the fruits of action be your motive, nor let your attachment be to inaction.',
      dailyLifeImpact:
          'Focus on giving your best effort without being attached to outcomes. This verse teaches us to act with dedication while maintaining inner peace regardless of results. Apply this in your daily work, relationships, and spiritual practice.',
      source: null,
    );
  }

  /// Mark verse as viewed for today - card will hide
  Future<void> markViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_viewedKey, _todayString());
  }

  String _todayString() {
    final n = DateTime.now();
    return '${n.year}_${n.month}_${n.day}';
  }

  Future<AshramDailyVerseModel?> _getVerseFromSupabase() async {
    final random = Random();
    for (var i = 0; i < 5; i++) {
      final bookId = _sourceBooks[random.nextInt(_sourceBooks.length)];
      final chapters = await _chapterRepository.getChaptersForBook(bookId);
      if (chapters.isEmpty) continue;

      final chapter = chapters[random.nextInt(chapters.length)];
      final verses = await _verseRepository.getVersesWithAllTranslations(chapter.id);
      if (verses.isEmpty) continue;

      final v = verses[random.nextInt(verses.length)];
      final dailyLife = await _getDailyLifeImpact(v);
      final bookName = _bookDisplayName(bookId);

      return AshramDailyVerseModel(
        id: v.verse.id,
        bookName: bookName,
        chapterName: chapter.title,
        verseNumber: v.verse.verseNumberDisplay,
        sanskritText: () {
          final s = _getSanskrit(v);
          return s.isNotEmpty ? s : v.verse.verseNumberDisplay;
        }(),
        hindiOrEnglishText: _getHindiOrEnglish(v),
        dailyLifeImpact: dailyLife,
        source: 'supabase',
      );
    }
    return null;
  }

  Future<AshramDailyVerseModel> _getVerseFromGpt() async {
    final content = await _verseOfDayRepo.getVerseOfTheDay();
    final dailyLife = await _gptService.getVerseReflection(
      book: content.book,
      chapterId: content.chapter ?? '',
      verseNumber: content.verseNumber ?? '',
      verseText: content.content,
    );

    return AshramDailyVerseModel(
      id: content.id,
      bookName: content.book,
      chapterName: content.chapter,
      verseNumber: content.verseNumber,
      sanskritText: content.title,
      hindiOrEnglishText: content.content,
      dailyLifeImpact: dailyLife,
      source: 'gpt',
    );
  }

  String _getSanskrit(VerseWithTranslations v) {
    final sa = v.getTranslation('sa');
    if (sa != null && sa.text.isNotEmpty) return sa.text;
    final hi = v.hindiTranslation;
    if (hi != null && (hi.transliteration ?? hi.text).isNotEmpty) {
      return hi.transliteration ?? hi.text;
    }
    return v.primaryTranslation?.text ?? '';
  }

  String _getHindiOrEnglish(VerseWithTranslations v) {
    final en = v.englishTranslation;
    if (en != null && en.text.isNotEmpty) return en.text;
    final hi = v.hindiTranslation;
    if (hi != null && hi.text.isNotEmpty) return hi.text;
    return v.primaryTranslation?.text ?? '';
  }

  Future<String> _getDailyLifeImpact(VerseWithTranslations v) async {
    final text = _getHindiOrEnglish(v);
    try {
      final reflection = await _gptService.getVerseReflection(
        book: _bookDisplayName(v.verse.bookId),
        chapterId: v.verse.chapterId,
        verseNumber: v.verse.verseNumberDisplay,
        verseText: text,
      );
      return reflection;
    } catch (e) {
      return 'Reflect on this wisdom and how it can guide your actions today. Apply it with compassion in your daily interactions.';
    }
  }

  String _bookDisplayName(String bookId) {
    switch (bookId) {
      case 'bhagavad_gita':
        return 'Bhagavad Gita';
      case 'mahabharata':
        return 'Mahabharata';
      default:
        return bookId;
    }
  }

  Future<void> _cacheVerse(
    SharedPreferences prefs,
    String date,
    AshramDailyVerseModel verse,
  ) async {
    await prefs.setString(_cacheDateKey, date);
    await prefs.setString(_cacheKey, _verseToCacheString(verse));
  }

  String _verseToCacheString(AshramDailyVerseModel v) {
    return '${v.id}|||${v.bookName}|||${v.chapterName ?? ''}|||${v.verseNumber ?? ''}|||${v.sanskritText}|||${v.hindiOrEnglishText}|||${v.dailyLifeImpact}';
  }

  AshramDailyVerseModel? _parseCachedVerse(String cached) {
    final parts = cached.split('|||');
    if (parts.length < 7) return null;
    return AshramDailyVerseModel(
      id: parts[0],
      bookName: parts[1],
      chapterName: parts[2].isEmpty ? null : parts[2],
      verseNumber: parts[3].isEmpty ? null : parts[3],
      sanskritText: parts[4],
      hindiOrEnglishText: parts[5],
      dailyLifeImpact: parts[6],
    );
  }
}
