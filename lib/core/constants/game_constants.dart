class GameConstants {
  // Coin Values
  static const int readingCompletionCoins = 20;
  static const int taskCompletionCoins = 35;
  static const int quizCompletionCoins = 50;
  static const int streakBonusCoins = 10;
  static const int firstTimeChapterBonus = 5;
  
  // Item Pricing Ranges
  static const Map<String, Map<String, int>> itemPricing = {
    'common': {'min': 50, 'max': 200},
    'rare': {'min': 200, 'max': 500},
    'epic': {'min': 500, 'max': 2000},
  };
  
  // Wisdom Levels
  static const int maxWisdomLevel = 10;
  static const int chaptersPerWisdomLevel = 5;
  
  // Streak Rewards
  static const Map<int, int> streakBonuses = {
    3: 10,
    7: 25,
    14: 50,
    30: 100,
  };
}
