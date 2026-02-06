class AppConfig {
  static const String appName = 'Ashrae Playground';
  static const String appTagline = 'The Inner Path';
  static const String appVersion = '1.0.0';
  
  // GPT API Configuration
  static const String gptApiBaseUrl = 'https://api.openai.com/v1';
  static const String gptApiKey = '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';
  
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
