import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'Antar Marg';
  static const String appTagline = 'The Inner Path';
  static const String appVersion = '1.0.0';

  // GPT API Configuration (loaded from .env)
  static const String gptApiBaseUrl = 'https://api.openai.com/v1';
  static String get gptApiKey => dotenv.env['GPT_API_KEY'] ?? '';

  // Coin Rewards
  static const int readingCompletionCoins = 20; // Base coins per chapter
  static const int taskCompletionCoins = 35; // Base coins per task
  static const int quizCompletionCoins = 50; // Base coins per quiz
  static const int streakBonusCoins = 10; // Bonus per day in streak
  static const int firstTimeChapterBonus = 5;

  // Reading Time
  static const int targetReadingTimeMinutes = 2;

  // Item Rarity Pricing
  static const Map<String, int> itemPricing = {
    'common_min': 50,
    'common_max': 200,
    'rare_min': 200,
    'rare_max': 500,
    'epic_min': 500,
    'epic_max': 2000,
  };
}
