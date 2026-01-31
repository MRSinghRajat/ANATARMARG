import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/verse_model.dart';
import '../datasources/gpt_api_service.dart';

class VerseOfDayRepository {
  static final VerseOfDayRepository _instance = VerseOfDayRepository._internal();
  factory VerseOfDayRepository() => _instance;
  VerseOfDayRepository._internal();

  final GPTApiService _gptService = GPTApiService();
  static const String _cacheKey = 'verse_of_day';
  static const String _dateKey = 'verse_of_day_date';

  Future<VerseContent> getVerseOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}_${today.month}_${today.day}';
    
    // Check if we have a cached verse for today
    final cachedDate = prefs.getString(_dateKey);
    if (cachedDate == todayString) {
      final cachedVerseJson = prefs.getString(_cacheKey);
      if (cachedVerseJson != null) {
        final verseMap = jsonDecode(cachedVerseJson) as Map<String, dynamic>;
        return VerseContent.fromJson(verseMap);
      }
    }
    
    // Fetch new verse from GPT
    final verse = await _gptService.getVerseOfTheDay();
    
    // Cache it
    await prefs.setString(_cacheKey, jsonEncode(verse.toJson()));
    await prefs.setString(_dateKey, todayString);
    
    return verse;
  }
}
