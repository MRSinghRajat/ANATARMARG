import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_spiritual_progress_model.dart';

/// Repository for managing user's spiritual progress
class SpiritualProgressRepository {
  final SupabaseClient _supabase;

  SpiritualProgressRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get user's spiritual progress
  Future<UserSpiritualProgress?> getProgress() async {
    if (_userId == null) return null;

    try {
      final response = await _supabase
          .from('user_spiritual_progress')
          .select()
          .eq('user_id', _userId!)
          .maybeSingle();

      if (response == null) {
        // Create initial progress record
        return await _createInitialProgress();
      }

      return UserSpiritualProgress.fromJson(response);
    } catch (e) {
      print('Error fetching spiritual progress: $e');
      return null;
    }
  }

  /// Create initial progress record for new users
  Future<UserSpiritualProgress?> _createInitialProgress() async {
    if (_userId == null) return null;

    try {
      final now = DateTime.now();
      final dateStr = now.toIso8601String().split('T')[0];
      
      final response = await _supabase
          .from('user_spiritual_progress')
          .insert({
            'user_id': _userId,
            'journey_start_date': dateStr,
          })
          .select()
          .single();

      return UserSpiritualProgress.fromJson(response);
    } catch (e) {
      print('Error creating initial progress: $e');
      return null;
    }
  }

  /// Update streak when task is completed
  Future<UserSpiritualProgress?> updateStreakOnTaskComplete() async {
    if (_userId == null) return null;

    try {
      final progress = await getProgress();
      if (progress == null) return null;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      int newStreak = progress.currentStreak;
      int newLongestStreak = progress.longestStreak;

      // Check if this is a new day of activity
      if (progress.lastActivityDate == null) {
        // First ever activity
        newStreak = 1;
      } else {
        final lastActivity = DateTime(
          progress.lastActivityDate!.year,
          progress.lastActivityDate!.month,
          progress.lastActivityDate!.day,
        );
        final daysDiff = today.difference(lastActivity).inDays;

        if (daysDiff == 0) {
          // Already completed something today, no streak change
          return progress;
        } else if (daysDiff == 1) {
          // Consecutive day, increase streak
          newStreak = progress.currentStreak + 1;
        } else {
          // Streak broken
          newStreak = 1;
        }
      }

      // Update longest streak if needed
      if (newStreak > newLongestStreak) {
        newLongestStreak = newStreak;
      }

      final dateStr = today.toIso8601String().split('T')[0];

      final response = await _supabase
          .from('user_spiritual_progress')
          .update({
            'current_streak': newStreak,
            'longest_streak': newLongestStreak,
            'last_activity_date': dateStr,
          })
          .eq('user_id', _userId!)
          .select()
          .single();

      return UserSpiritualProgress.fromJson(response);
    } catch (e) {
      print('Error updating streak: $e');
      return null;
    }
  }

  /// Increment total tasks completed
  Future<UserSpiritualProgress?> incrementTasksCompleted() async {
    if (_userId == null) return null;

    try {
      final progress = await getProgress();
      if (progress == null) return null;

      final response = await _supabase
          .from('user_spiritual_progress')
          .update({
            'total_tasks_completed': progress.totalTasksCompleted + 1,
          })
          .eq('user_id', _userId!)
          .select()
          .single();

      return UserSpiritualProgress.fromJson(response);
    } catch (e) {
      print('Error incrementing tasks completed: $e');
      return null;
    }
  }

  /// Increment verses read
  Future<bool> incrementVersesRead({int count = 1}) async {
    if (_userId == null) return false;

    try {
      final progress = await getProgress();
      if (progress == null) return false;

      await _supabase
          .from('user_spiritual_progress')
          .update({
            'total_verses_read': progress.totalVersesRead + count,
          })
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      print('Error incrementing verses read: $e');
      return false;
    }
  }

  /// Increment meditation minutes
  Future<bool> incrementMeditationMinutes(int minutes) async {
    if (_userId == null) return false;

    try {
      final progress = await getProgress();
      if (progress == null) return false;

      await _supabase
          .from('user_spiritual_progress')
          .update({
            'total_meditation_minutes': progress.totalMeditationMinutes + minutes,
          })
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      print('Error incrementing meditation minutes: $e');
      return false;
    }
  }

  /// Increment seva acts
  Future<bool> incrementSevaActs() async {
    if (_userId == null) return false;

    try {
      final progress = await getProgress();
      if (progress == null) return false;

      await _supabase
          .from('user_spiritual_progress')
          .update({
            'total_seva_acts': progress.totalSevaActs + 1,
          })
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      print('Error incrementing seva acts: $e');
      return false;
    }
  }

  /// Increment book pages read
  Future<bool> incrementBookPagesRead({int count = 1}) async {
    if (_userId == null) return false;

    try {
      final progress = await getProgress();
      if (progress == null) return false;

      await _supabase
          .from('user_spiritual_progress')
          .update({
            'total_book_pages_read': progress.totalBookPagesRead + count,
          })
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      print('Error incrementing book pages: $e');
      return false;
    }
  }

  /// Add experience points and handle level up
  Future<UserSpiritualProgress?> addExperience(int xp) async {
    if (_userId == null) return null;

    try {
      final progress = await getProgress();
      if (progress == null) return null;

      int newXp = progress.experiencePoints + xp;
      int newLevel = progress.spiritualLevel;

      // Check for level up
      int xpForLevel = (100 * (newLevel * 1.5)).round();
      while (newXp >= xpForLevel) {
        newXp -= xpForLevel;
        newLevel++;
        xpForLevel = (100 * (newLevel * 1.5)).round();
      }

      final response = await _supabase
          .from('user_spiritual_progress')
          .update({
            'experience_points': newXp,
            'spiritual_level': newLevel,
          })
          .eq('user_id', _userId!)
          .select()
          .single();

      return UserSpiritualProgress.fromJson(response);
    } catch (e) {
      print('Error adding experience: $e');
      return null;
    }
  }

  /// Use a streak freeze
  Future<bool> useStreakFreeze() async {
    if (_userId == null) return false;

    try {
      final progress = await getProgress();
      if (progress == null || progress.streakFreezeAvailable <= 0) return false;

      final today = DateTime.now().toIso8601String().split('T')[0];

      await _supabase
          .from('user_spiritual_progress')
          .update({
            'streak_freeze_available': progress.streakFreezeAvailable - 1,
            'streak_freeze_used_date': today,
          })
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      print('Error using streak freeze: $e');
      return false;
    }
  }

  /// Add streak freeze (reward for achievements)
  Future<bool> addStreakFreeze({int count = 1}) async {
    if (_userId == null) return false;

    try {
      final progress = await getProgress();
      if (progress == null) return false;

      await _supabase
          .from('user_spiritual_progress')
          .update({
            'streak_freeze_available': progress.streakFreezeAvailable + count,
          })
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      print('Error adding streak freeze: $e');
      return false;
    }
  }

  /// Record task completion with all related updates
  Future<UserSpiritualProgress?> recordTaskCompletion({
    required String taskCategory,
    int? meditationMinutes,
    int experienceGained = 10,
  }) async {
    // Update streak
    await updateStreakOnTaskComplete();
    
    // Increment tasks completed
    await incrementTasksCompleted();

    // Category-specific updates
    switch (taskCategory.toLowerCase()) {
      case 'scripture':
        await incrementVersesRead();
        break;
      case 'meditation':
        if (meditationMinutes != null && meditationMinutes > 0) {
          await incrementMeditationMinutes(meditationMinutes);
        }
        break;
      case 'seva':
        await incrementSevaActs();
        break;
    }

    // Add experience
    return addExperience(experienceGained);
  }
}
