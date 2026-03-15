import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/verse_model.dart';

class VerseOfDayRepository {
  static final VerseOfDayRepository _instance = VerseOfDayRepository._internal();
  factory VerseOfDayRepository() => _instance;
  VerseOfDayRepository._internal();

  static const String _cacheKey = 'verse_of_day';
  static const String _dateKey = 'verse_of_day_date';

  Future<VerseContent> getVerseOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}_${today.month}_${today.day}';

    // Use cached verse for today if available
    final cachedDate = prefs.getString(_dateKey);
    if (cachedDate == todayString) {
      final cachedVerseJson = prefs.getString(_cacheKey);
      if (cachedVerseJson != null) {
        final verseMap = jsonDecode(cachedVerseJson) as Map<String, dynamic>;
        return VerseContent.fromJson(verseMap);
      }
    }

    // No API: return a static fallback verse for today (no GPT call)
    final verse = _getFallbackVerseOfDay(today);
    await prefs.setString(_cacheKey, jsonEncode(verse.toJson()));
    await prefs.setString(_dateKey, todayString);
    return verse;
  }

  static VerseContent _getFallbackVerseOfDay(DateTime date) {
    return VerseContent(
      id: 'verse_of_day_${date.year}_${date.month}_${date.day}',
      book: 'Bhagavad Gita',
      chapter: null,
      title: 'Verse of the Day',
      content:
          'योगस्थ: कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय। सिद्ध्यसिद्ध्यो: समो भूत्वा समत्वं योग उच्यते।\n\nPerform actions, established in yoga, abandoning attachment, O Dhananjaya. Being the same in success and failure—that evenness is called yoga.',
      context: null,
      relatedCharacters: null,
      createdAt: date,
      devanagariText: 'योगस्थ: कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय।',
      dailyInsight: 'Practice evenness of mind in success and failure.',
    );
  }
}
