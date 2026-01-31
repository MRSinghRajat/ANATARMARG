import '../constants/game_constants.dart';

class CoinCalculator {
  static int calculateReadingReward(bool isFirstTime) {
    int baseReward = GameConstants.readingCompletionCoins;
    if (isFirstTime) {
      baseReward += GameConstants.firstTimeChapterBonus;
    }
    return baseReward;
  }

  static int calculateTaskReward() {
    return GameConstants.taskCompletionCoins;
  }

  static int calculateQuizReward(int score) {
    // Score is percentage (0-100)
    int baseReward = GameConstants.quizCompletionCoins;
    if (score >= 90) {
      return (baseReward * 1.5).round(); // 75 coins
    } else if (score >= 70) {
      return baseReward; // 50 coins
    } else if (score >= 50) {
      return (baseReward * 0.7).round(); // 35 coins
    } else {
      return (baseReward * 0.5).round(); // 25 coins
    }
  }

  static int calculateStreakBonus(int streakDays) {
    int bonus = 0;
    GameConstants.streakBonuses.forEach((days, reward) {
      if (streakDays >= days) {
        bonus = reward;
      }
    });
    return bonus;
  }

  static int getTotalDailyReward({
    required int completedTasks,
    required int completedReadings,
    required int streakDays,
    required bool firstTimeReading,
  }) {
    int total = 0;
    
    // Task rewards
    total += completedTasks * calculateTaskReward();
    
    // Reading rewards
    total += completedReadings * calculateReadingReward(firstTimeReading);
    
    // Streak bonus
    total += calculateStreakBonus(streakDays);
    
    return total;
  }
}
