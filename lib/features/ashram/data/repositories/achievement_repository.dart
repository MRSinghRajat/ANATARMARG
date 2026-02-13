import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/achievement_model.dart';
import '../models/user_spiritual_progress_model.dart';

/// Repository for managing achievements
class AchievementRepository {
  final SupabaseClient _supabase;

  AchievementRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get all active achievements
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final response = await _supabase
          .from('achievements')
          .select()
          .eq('is_active', true)
          .order('order_index');

      return (response as List)
          .map((json) => Achievement.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  /// Get user's unlocked achievements
  Future<List<UserAchievement>> getUserAchievements() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('user_achievements')
          .select('*, achievements(*)')
          .eq('user_id', _userId!)
          .order('unlocked_at', ascending: false);

      return (response as List).map((json) {
        final achievementJson = json['achievements'];
        Achievement? achievement;
        if (achievementJson != null) {
          achievement = Achievement.fromJson(achievementJson);
        }
        return UserAchievement.fromJson(json, achievement: achievement);
      }).toList();
    } catch (e) {
      print('Error fetching user achievements: $e');
      return [];
    }
  }

  /// Get unlocked achievement IDs for quick lookup
  Future<Set<String>> getUnlockedAchievementIds() async {
    final userAchievements = await getUserAchievements();
    return userAchievements.map((ua) => ua.achievementId).toSet();
  }

  /// Check and unlock any newly eligible achievements
  Future<List<Achievement>> checkAndUnlockAchievements(
    UserSpiritualProgress progress,
  ) async {
    if (_userId == null) return [];

    try {
      final allAchievements = await getAllAchievements();
      final unlockedIds = await getUnlockedAchievementIds();
      final newlyUnlocked = <Achievement>[];

      for (final achievement in allAchievements) {
        // Skip if already unlocked
        if (unlockedIds.contains(achievement.id)) continue;

        // Skip secret achievements that aren't special type
        if (achievement.isSecret && achievement.unlockType != AchievementUnlockType.special) {
          continue;
        }

        // Check if user meets the unlock condition
        if (_meetsUnlockCondition(achievement, progress)) {
          final success = await _unlockAchievement(achievement.id);
          if (success) {
            newlyUnlocked.add(achievement);
          }
        }
      }

      return newlyUnlocked;
    } catch (e) {
      print('Error checking achievements: $e');
      return [];
    }
  }

  /// Check if user meets unlock condition
  bool _meetsUnlockCondition(Achievement achievement, UserSpiritualProgress progress) {
    switch (achievement.unlockType) {
      case AchievementUnlockType.streak:
        return progress.currentStreak >= achievement.unlockValue ||
            progress.longestStreak >= achievement.unlockValue;
      case AchievementUnlockType.tasksCompleted:
        return progress.totalTasksCompleted >= achievement.unlockValue;
      case AchievementUnlockType.versesRead:
        return progress.totalVersesRead >= achievement.unlockValue;
      case AchievementUnlockType.meditationMinutes:
        return progress.totalMeditationMinutes >= achievement.unlockValue;
      case AchievementUnlockType.sevaActs:
        return progress.totalSevaActs >= achievement.unlockValue;
      case AchievementUnlockType.level:
        return progress.spiritualLevel >= achievement.unlockValue;
      case AchievementUnlockType.special:
        // Special achievements are unlocked via specific conditions
        return false;
    }
  }

  /// Unlock an achievement for the user
  Future<bool> _unlockAchievement(String achievementId) async {
    if (_userId == null) return false;

    try {
      await _supabase.from('user_achievements').insert({
        'user_id': _userId,
        'achievement_id': achievementId,
      });
      return true;
    } catch (e) {
      // May fail if already unlocked (unique constraint)
      print('Error unlocking achievement: $e');
      return false;
    }
  }

  /// Unlock a special achievement by slug
  Future<Achievement?> unlockSpecialAchievement(String slug) async {
    if (_userId == null) return null;

    try {
      // Get the achievement by slug
      final achievementResponse = await _supabase
          .from('achievements')
          .select()
          .eq('slug', slug)
          .eq('is_active', true)
          .maybeSingle();

      if (achievementResponse == null) return null;

      final achievement = Achievement.fromJson(achievementResponse);

      // Check if already unlocked
      final unlockedIds = await getUnlockedAchievementIds();
      if (unlockedIds.contains(achievement.id)) return null;

      // Unlock it
      final success = await _unlockAchievement(achievement.id);
      return success ? achievement : null;
    } catch (e) {
      print('Error unlocking special achievement: $e');
      return null;
    }
  }

  /// Get achievement progress (how close user is to unlocking)
  Map<String, double> calculateProgress(
    List<Achievement> achievements,
    UserSpiritualProgress progress,
    Set<String> unlockedIds,
  ) {
    final progressMap = <String, double>{};

    for (final achievement in achievements) {
      if (unlockedIds.contains(achievement.id)) {
        progressMap[achievement.id] = 1.0;
        continue;
      }

      double achievementProgress = 0.0;
      switch (achievement.unlockType) {
        case AchievementUnlockType.streak:
          achievementProgress = (progress.longestStreak / achievement.unlockValue).clamp(0.0, 1.0);
          break;
        case AchievementUnlockType.tasksCompleted:
          achievementProgress = (progress.totalTasksCompleted / achievement.unlockValue).clamp(0.0, 1.0);
          break;
        case AchievementUnlockType.versesRead:
          achievementProgress = (progress.totalVersesRead / achievement.unlockValue).clamp(0.0, 1.0);
          break;
        case AchievementUnlockType.meditationMinutes:
          achievementProgress = (progress.totalMeditationMinutes / achievement.unlockValue).clamp(0.0, 1.0);
          break;
        case AchievementUnlockType.sevaActs:
          achievementProgress = (progress.totalSevaActs / achievement.unlockValue).clamp(0.0, 1.0);
          break;
        case AchievementUnlockType.level:
          achievementProgress = (progress.spiritualLevel / achievement.unlockValue).clamp(0.0, 1.0);
          break;
        case AchievementUnlockType.special:
          achievementProgress = 0.0; // Special achievements don't show progress
          break;
      }

      progressMap[achievement.id] = achievementProgress;
    }

    return progressMap;
  }

  /// Get recent unlocks (last 7 days)
  Future<List<UserAchievement>> getRecentUnlocks() async {
    if (_userId == null) return [];

    try {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));

      final response = await _supabase
          .from('user_achievements')
          .select('*, achievements(*)')
          .eq('user_id', _userId!)
          .gte('unlocked_at', weekAgo.toIso8601String())
          .order('unlocked_at', ascending: false);

      return (response as List).map((json) {
        final achievementJson = json['achievements'];
        Achievement? achievement;
        if (achievementJson != null) {
          achievement = Achievement.fromJson(achievementJson);
        }
        return UserAchievement.fromJson(json, achievement: achievement);
      }).toList();
    } catch (e) {
      print('Error fetching recent unlocks: $e');
      return [];
    }
  }

  /// Count total achievements
  Future<Map<String, int>> getAchievementCounts() async {
    try {
      final all = await getAllAchievements();
      final unlocked = await getUserAchievements();

      return {
        'total': all.length,
        'unlocked': unlocked.length,
        'locked': all.length - unlocked.length,
      };
    } catch (e) {
      print('Error getting achievement counts: $e');
      return {'total': 0, 'unlocked': 0, 'locked': 0};
    }
  }
}
