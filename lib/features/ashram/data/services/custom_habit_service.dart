import 'dart:async';
import '../models/custom_habit_model.dart';
import '../repositories/custom_habit_repository.dart';
import '../repositories/spiritual_progress_repository.dart';
import '../../../../shared/services/coin_service.dart';

/// Service for managing custom habits
class CustomHabitService {
  static CustomHabitService? _instance;
  
  final CustomHabitRepository _habitRepository;
  final SpiritualProgressRepository _progressRepository;
  final CoinService _coinService;

  // Stream controller
  final _habitsController = StreamController<List<CustomHabit>>.broadcast();
  Stream<List<CustomHabit>> get habitsStream => _habitsController.stream;

  // Cached data
  List<CustomHabit> _habits = [];
  final Set<String> _completedTodayIds = {};

  List<CustomHabit> get habits => _habits;
  List<CustomHabit> get todaysHabits => 
      _habits.where((h) => h.isScheduledForToday).toList();

  CustomHabitService._({
    CustomHabitRepository? habitRepository,
    SpiritualProgressRepository? progressRepository,
    CoinService? coinService,
  })  : _habitRepository = habitRepository ?? CustomHabitRepository(),
        _progressRepository = progressRepository ?? SpiritualProgressRepository(),
        _coinService = coinService ?? CoinService();

  static CustomHabitService get instance {
    _instance ??= CustomHabitService._();
    return _instance!;
  }

  /// Initialize and load habits
  Future<void> initialize() async {
    await _loadHabits();
  }

  /// Load user's custom habits
  Future<void> _loadHabits() async {
    _habits = await _habitRepository.getHabits();
    
    // Check completion status for each habit
    _completedTodayIds.clear();
    for (final habit in _habits) {
      if (habit.isCompletedToday) {
        _completedTodayIds.add(habit.id);
      }
    }
    
    _habitsController.add(_habits);
  }

  /// Refresh habits
  Future<void> refresh() async {
    await _loadHabits();
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
    final habit = await _habitRepository.createHabit(
      title: title,
      description: description,
      iconName: iconName,
      frequency: frequency,
      specificDays: specificDays,
      targetStreak: targetStreak,
    );

    if (habit != null) {
      await _loadHabits();
    }

    return habit;
  }

  /// Update a habit
  Future<CustomHabit?> updateHabit(CustomHabit habit) async {
    final updated = await _habitRepository.updateHabit(habit);
    if (updated != null) {
      await _loadHabits();
    }
    return updated;
  }

  /// Delete a habit
  Future<bool> deleteHabit(String habitId) async {
    final success = await _habitRepository.deleteHabit(habitId);
    if (success) {
      await _loadHabits();
    }
    return success;
  }

  /// Complete a habit for today
  Future<HabitCompletionResult> completeHabit(CustomHabit habit) async {
    try {
      final success = await _habitRepository.completeHabit(habit.id);
      if (!success) {
        return HabitCompletionResult(
          success: false,
          message: 'Failed to complete habit',
        );
      }

      // Add coins for completing custom habit
      const coinsEarned = 3;
      await _coinService.addCoins(coinsEarned);

      // Update progress
      await _progressRepository.incrementTasksCompleted();

      _completedTodayIds.add(habit.id);
      await _loadHabits();

      return HabitCompletionResult(
        success: true,
        coinsEarned: coinsEarned,
        message: 'Habit completed! +$coinsEarned coins',
      );
    } catch (e) {
      print('Error completing habit: $e');
      return HabitCompletionResult(
        success: false,
        message: 'Error completing habit',
      );
    }
  }

  /// Uncomplete a habit for today
  Future<bool> uncompleteHabit(CustomHabit habit) async {
    final success = await _habitRepository.uncompleteHabit(habit.id);
    if (success) {
      _completedTodayIds.remove(habit.id);
      await _loadHabits();
    }
    return success;
  }

  /// Toggle habit completion
  Future<HabitCompletionResult> toggleHabit(CustomHabit habit) async {
    if (isCompletedToday(habit.id)) {
      final success = await uncompleteHabit(habit);
      return HabitCompletionResult(
        success: success,
        message: success ? 'Habit unmarked' : 'Failed to unmark habit',
      );
    } else {
      return completeHabit(habit);
    }
  }

  /// Check if habit is completed today
  bool isCompletedToday(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw Exception('Habit not found'),
    );
    return habit.isCompletedToday || _completedTodayIds.contains(habitId);
  }

  /// Get pending habits for today
  List<CustomHabit> get pendingHabits =>
      todaysHabits.where((h) => !isCompletedToday(h.id)).toList();

  /// Get completed habits for today
  List<CustomHabit> get completedHabits =>
      todaysHabits.where((h) => isCompletedToday(h.id)).toList();

  /// Get completion percentage for today's habits
  double get todaysCompletionPercentage {
    final todays = todaysHabits;
    if (todays.isEmpty) return 0.0;
    return completedHabits.length / todays.length;
  }

  /// Get habit completion history
  Future<List<DateTime>> getHabitHistory(String habitId, {int days = 30}) async {
    return _habitRepository.getCompletionHistory(habitId, days: days);
  }

  /// Get suggested habit ideas
  List<HabitSuggestion> get habitSuggestions => const [
    HabitSuggestion(
      title: 'Drink 8 glasses of water',
      description: 'Stay hydrated throughout the day',
      iconName: 'water_drop',
    ),
    HabitSuggestion(
      title: 'Read for 15 minutes',
      description: 'Read a spiritual or self-improvement book',
      iconName: 'menu_book',
    ),
    HabitSuggestion(
      title: 'Practice gratitude',
      description: 'Write down 3 things you are grateful for',
      iconName: 'favorite',
    ),
    HabitSuggestion(
      title: 'Morning stretching',
      description: 'Start your day with gentle stretches',
      iconName: 'accessibility_new',
    ),
    HabitSuggestion(
      title: 'No phone before bed',
      description: 'Put away devices 1 hour before sleep',
      iconName: 'phone_disabled',
    ),
    HabitSuggestion(
      title: 'Take a walk',
      description: 'Get some fresh air and movement',
      iconName: 'directions_walk',
    ),
    HabitSuggestion(
      title: 'Practice deep breathing',
      description: 'Take 10 deep breaths to center yourself',
      iconName: 'air',
    ),
    HabitSuggestion(
      title: 'Learn something new',
      description: 'Spend 15 minutes learning a new skill',
      iconName: 'lightbulb',
    ),
  ];

  /// Dispose resources
  void dispose() {
    _habitsController.close();
    _instance = null;
  }
}

/// Result of habit completion
class HabitCompletionResult {
  final bool success;
  final int coinsEarned;
  final String message;

  HabitCompletionResult({
    required this.success,
    this.coinsEarned = 0,
    this.message = '',
  });
}

/// Suggestion for new habits
class HabitSuggestion {
  final String title;
  final String description;
  final String iconName;

  const HabitSuggestion({
    required this.title,
    required this.description,
    required this.iconName,
  });
}
