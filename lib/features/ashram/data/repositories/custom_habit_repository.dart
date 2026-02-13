import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/custom_habit_model.dart';

/// Repository for managing user's custom habits
class CustomHabitRepository {
  final SupabaseClient _supabase;

  CustomHabitRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get all active custom habits for the user
  Future<List<CustomHabit>> getHabits() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('user_custom_habits')
          .select()
          .eq('user_id', _userId!)
          .eq('is_active', true)
          .order('created_at');

      return (response as List)
          .map((json) => CustomHabit.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching custom habits: $e');
      return [];
    }
  }

  /// Get habits scheduled for today
  Future<List<CustomHabit>> getTodaysHabits() async {
    final allHabits = await getHabits();
    return allHabits.where((h) => h.isScheduledForToday).toList();
  }

  /// Create a new custom habit
  Future<CustomHabit?> createHabit({
    required String title,
    String? description,
    String iconName = 'check_circle',
    HabitFrequency frequency = HabitFrequency.daily,
    List<int>? specificDays,
    int? targetStreak,
  }) async {
    if (_userId == null) return null;

    try {
      final response = await _supabase
          .from('user_custom_habits')
          .insert({
            'user_id': _userId,
            'title': title,
            'description': description,
            'icon_name': iconName,
            'frequency': frequency.name,
            'specific_days': specificDays,
            'target_streak': targetStreak,
          })
          .select()
          .single();

      return CustomHabit.fromJson(response);
    } catch (e) {
      print('Error creating custom habit: $e');
      return null;
    }
  }

  /// Update a custom habit
  Future<CustomHabit?> updateHabit(CustomHabit habit) async {
    if (_userId == null) return null;

    try {
      final response = await _supabase
          .from('user_custom_habits')
          .update({
            'title': habit.title,
            'description': habit.description,
            'icon_name': habit.iconName,
            'frequency': habit.frequency.name,
            'specific_days': habit.specificDays,
            'target_streak': habit.targetStreak,
            'is_active': habit.isActive,
          })
          .eq('id', habit.id)
          .eq('user_id', _userId!)
          .select()
          .single();

      return CustomHabit.fromJson(response);
    } catch (e) {
      print('Error updating custom habit: $e');
      return null;
    }
  }

  /// Delete a custom habit (soft delete by setting inactive)
  Future<bool> deleteHabit(String habitId) async {
    if (_userId == null) return false;

    try {
      await _supabase
          .from('user_custom_habits')
          .update({'is_active': false})
          .eq('id', habitId)
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      print('Error deleting custom habit: $e');
      return false;
    }
  }

  /// Permanently delete a habit
  Future<bool> permanentlyDeleteHabit(String habitId) async {
    if (_userId == null) return false;

    try {
      await _supabase
          .from('user_custom_habits')
          .delete()
          .eq('id', habitId)
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      print('Error permanently deleting habit: $e');
      return false;
    }
  }

  /// Complete a habit for today
  Future<bool> completeHabit(String habitId) async {
    if (_userId == null) return false;

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Insert completion record
      await _supabase
          .from('user_habit_completions')
          .insert({
            'user_id': _userId,
            'habit_id': habitId,
            'completion_date': today,
          });

      // Update habit's streak
      await _updateHabitStreak(habitId);

      return true;
    } catch (e) {
      // Might fail if already completed today (unique constraint)
      print('Error completing habit: $e');
      return false;
    }
  }

  /// Uncomplete a habit for today
  Future<bool> uncompleteHabit(String habitId) async {
    if (_userId == null) return false;

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      await _supabase
          .from('user_habit_completions')
          .delete()
          .eq('habit_id', habitId)
          .eq('completion_date', today)
          .eq('user_id', _userId!);

      // Recalculate streak
      await _recalculateHabitStreak(habitId);

      return true;
    } catch (e) {
      print('Error uncompleting habit: $e');
      return false;
    }
  }

  /// Update habit streak after completion
  Future<void> _updateHabitStreak(String habitId) async {
    try {
      final habit = await _getHabit(habitId);
      if (habit == null) return;

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      int newStreak = habit.currentStreak;
      int newLongestStreak = habit.longestStreak;

      if (habit.lastCompletedDate == null) {
        newStreak = 1;
      } else {
        final lastCompleted = DateTime(
          habit.lastCompletedDate!.year,
          habit.lastCompletedDate!.month,
          habit.lastCompletedDate!.day,
        );
        
        // Calculate expected days between completions based on frequency
        int expectedDays = 1;
        if (habit.frequency == HabitFrequency.weekly) {
          expectedDays = 7;
        }
        
        final daysDiff = todayDate.difference(lastCompleted).inDays;
        
        if (daysDiff == 0) {
          // Already completed today
          return;
        } else if (daysDiff <= expectedDays) {
          newStreak = habit.currentStreak + 1;
        } else {
          newStreak = 1;
        }
      }

      if (newStreak > newLongestStreak) {
        newLongestStreak = newStreak;
      }

      await _supabase
          .from('user_custom_habits')
          .update({
            'current_streak': newStreak,
            'longest_streak': newLongestStreak,
            'last_completed_date': todayDate.toIso8601String().split('T')[0],
          })
          .eq('id', habitId)
          .eq('user_id', _userId!);
    } catch (e) {
      print('Error updating habit streak: $e');
    }
  }

  /// Recalculate streak after uncompleting
  Future<void> _recalculateHabitStreak(String habitId) async {
    try {
      // Get the last completion date
      final completions = await _supabase
          .from('user_habit_completions')
          .select('completion_date')
          .eq('habit_id', habitId)
          .eq('user_id', _userId!)
          .order('completion_date', ascending: false)
          .limit(1);

      String? lastCompletedDate;
      if ((completions as List).isNotEmpty) {
        lastCompletedDate = completions[0]['completion_date'];
      }

      // Calculate streak from completions
      int streak = 0;
      if (lastCompletedDate != null) {
        streak = await _calculateCurrentStreak(habitId);
      }

      await _supabase
          .from('user_custom_habits')
          .update({
            'current_streak': streak,
            'last_completed_date': lastCompletedDate,
          })
          .eq('id', habitId)
          .eq('user_id', _userId!);
    } catch (e) {
      print('Error recalculating streak: $e');
    }
  }

  /// Calculate current streak from completion history
  Future<int> _calculateCurrentStreak(String habitId) async {
    try {
      final completions = await _supabase
          .from('user_habit_completions')
          .select('completion_date')
          .eq('habit_id', habitId)
          .eq('user_id', _userId!)
          .order('completion_date', ascending: false)
          .limit(365);

      final dates = (completions as List)
          .map((c) => DateTime.parse(c['completion_date']))
          .toList();

      if (dates.isEmpty) return 0;

      int streak = 1;
      for (int i = 0; i < dates.length - 1; i++) {
        final diff = dates[i].difference(dates[i + 1]).inDays;
        if (diff == 1) {
          streak++;
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      print('Error calculating streak: $e');
      return 0;
    }
  }

  /// Get a single habit by ID
  Future<CustomHabit?> _getHabit(String habitId) async {
    if (_userId == null) return null;

    try {
      final response = await _supabase
          .from('user_custom_habits')
          .select()
          .eq('id', habitId)
          .eq('user_id', _userId!)
          .single();

      return CustomHabit.fromJson(response);
    } catch (e) {
      print('Error fetching habit: $e');
      return null;
    }
  }

  /// Check if habit is completed today
  Future<bool> isCompletedToday(String habitId) async {
    if (_userId == null) return false;

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('user_habit_completions')
          .select('id')
          .eq('habit_id', habitId)
          .eq('completion_date', today)
          .eq('user_id', _userId!)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking completion: $e');
      return false;
    }
  }

  /// Get completion history for a habit
  Future<List<DateTime>> getCompletionHistory(String habitId, {int days = 30}) async {
    if (_userId == null) return [];

    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _supabase
          .from('user_habit_completions')
          .select('completion_date')
          .eq('habit_id', habitId)
          .eq('user_id', _userId!)
          .gte('completion_date', startDate.toIso8601String().split('T')[0])
          .order('completion_date', ascending: false);

      return (response as List)
          .map((c) => DateTime.parse(c['completion_date']))
          .toList();
    } catch (e) {
      print('Error getting completion history: $e');
      return [];
    }
  }
}
