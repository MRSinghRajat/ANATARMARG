import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language_code');
      if (savedLanguage != null) {
        state = savedLanguage;
      }
    } catch (_) {
      // Use default 'en' if SharedPreferences fails
    }
  }

  Future<void> setLanguage(String languageCode) async {
    state = languageCode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
    } catch (_) {
      // Language change still applied in memory
    }
  }
}
