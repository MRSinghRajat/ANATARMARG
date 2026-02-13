import 'dart:async';
import '../models/daily_task_model.dart';
import '../models/user_spiritual_progress_model.dart';
import '../models/achievement_model.dart';
import '../repositories/daily_task_repository.dart';
import '../repositories/spiritual_progress_repository.dart';
import '../repositories/achievement_repository.dart';
import '../../../../shared/services/coin_service.dart';

/// Service for managing daily tasks and related operations
class DailyTaskService {
  static DailyTaskService? _instance;
  
  final DailyTaskRepository _taskRepository;
  final SpiritualProgressRepository _progressRepository;
  final AchievementRepository _achievementRepository;
  final CoinService _coinService;

  // Stream controllers
  final _tasksController = StreamController<List<UserDailyTask>>.broadcast();
  final _progressController = StreamController<UserSpiritualProgress?>.broadcast();
  final _achievementController = StreamController<Achievement>.broadcast();

  Stream<List<UserDailyTask>> get tasksStream => _tasksController.stream;
  Stream<UserSpiritualProgress?> get progressStream => _progressController.stream;
  Stream<Achievement> get achievementUnlockedStream => _achievementController.stream;

  // Cached data
  List<UserDailyTask> _currentTasks = [];
  UserSpiritualProgress? _currentProgress;

  List<UserDailyTask> get currentTasks => _currentTasks;
  UserSpiritualProgress? get currentProgress => _currentProgress;

  DailyTaskService._({
    DailyTaskRepository? taskRepository,
    SpiritualProgressRepository? progressRepository,
    AchievementRepository? achievementRepository,
    CoinService? coinService,
  })  : _taskRepository = taskRepository ?? DailyTaskRepository(),
        _progressRepository = progressRepository ?? SpiritualProgressRepository(),
        _achievementRepository = achievementRepository ?? AchievementRepository(),
        _coinService = coinService ?? CoinService();

  static DailyTaskService get instance {
    _instance ??= DailyTaskService._();
    return _instance!;
  }

  /// Initialize and load today's data
  Future<void> initialize() async {
    await Future.wait([
      _loadProgress(),
      _loadTodaysTasks(),
    ]);
  }

  /// Load user's spiritual progress
  Future<void> _loadProgress() async {
    _currentProgress = await _progressRepository.getProgress();
    _progressController.add(_currentProgress);
  }

  /// Load today's tasks
  Future<void> _loadTodaysTasks() async {
    _currentTasks = await _taskRepository.getTodaysTasks();
    
    // Generate tasks if none exist for today
    if (_currentTasks.isEmpty && _currentProgress != null) {
      _currentTasks = await _taskRepository.generateDailyTasks(
        daysSinceStart: _currentProgress!.daysSinceStart,
        currentStreak: _currentProgress!.currentStreak,
      );
    }

    _tasksController.add(_currentTasks);
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  /// Complete a task
  Future<TaskCompletionResult> completeTask(UserDailyTask task) async {
    try {
      // Mark task as completed
      final success = await _taskRepository.completeTask(task.id);
      if (!success) {
        return TaskCompletionResult(
          success: false,
          message: 'Failed to complete task',
        );
      }

      // Add coins and karma
      await _coinService.addCoins(task.coinReward);

      // Update progress
      final updatedProgress = await _progressRepository.recordTaskCompletion(
        taskCategory: task.category,
        meditationMinutes: task.estimatedMinutes,
        experienceGained: _calculateExperience(task),
      );

      if (updatedProgress != null) {
        _currentProgress = updatedProgress;
        _progressController.add(_currentProgress);

        // Check for newly unlocked achievements
        final newAchievements = await _achievementRepository.checkAndUnlockAchievements(
          updatedProgress,
        );

        // Award achievements
        for (final achievement in newAchievements) {
          await _coinService.addCoins(achievement.coinReward);
          _achievementController.add(achievement);
        }

        // Check for first task ever achievement
        if (updatedProgress.totalTasksCompleted == 1) {
          final firstDawn = await _achievementRepository.unlockSpecialAchievement('first_dawn');
          if (firstDawn != null) {
            await _coinService.addCoins(firstDawn.coinReward);
            _achievementController.add(firstDawn);
          }
        }
      }

      // Reload tasks to get updated state
      await _loadTodaysTasks();

      return TaskCompletionResult(
        success: true,
        coinsEarned: task.coinReward,
        karmaEarned: task.karmaReward,
        experienceEarned: _calculateExperience(task),
        newStreak: _currentProgress?.currentStreak ?? 0,
        message: 'Task completed! +${task.coinReward} coins',
      );
    } catch (e) {
      print('Error completing task: $e');
      return TaskCompletionResult(
        success: false,
        message: 'Error completing task',
      );
    }
  }

  /// Uncomplete a task (for toggle functionality)
  Future<bool> uncompleteTask(UserDailyTask task) async {
    try {
      final success = await _taskRepository.uncompleteTask(task.id);
      if (success) {
        await _loadTodaysTasks();
      }
      return success;
    } catch (e) {
      print('Error uncompleting task: $e');
      return false;
    }
  }

  /// Toggle task completion
  Future<TaskCompletionResult> toggleTask(UserDailyTask task) async {
    if (task.isCompleted) {
      final success = await uncompleteTask(task);
      return TaskCompletionResult(
        success: success,
        message: success ? 'Task unmarked' : 'Failed to unmark task',
      );
    } else {
      return completeTask(task);
    }
  }

  /// Skip a task
  Future<bool> skipTask(UserDailyTask task) async {
    try {
      final success = await _taskRepository.skipTask(task.id);
      if (success) {
        await _loadTodaysTasks();
      }
      return success;
    } catch (e) {
      print('Error skipping task: $e');
      return false;
    }
  }

  /// Calculate experience for completing a task
  int _calculateExperience(UserDailyTask task) {
    int baseXp = 10;
    
    // Category bonuses
    switch (task.category.toLowerCase()) {
      case 'scripture':
        baseXp = 15;
        break;
      case 'meditation':
        baseXp = 12;
        break;
      case 'seva':
        baseXp = 20;
        break;
      case 'devotion':
        baseXp = 12;
        break;
    }

    // Apply streak multiplier
    final multiplier = _currentProgress?.streakMultiplier ?? 1.0;
    return (baseXp * multiplier).round();
  }

  /// Get pending tasks
  List<UserDailyTask> get pendingTasks =>
      _currentTasks.where((t) => t.isPending).toList();

  /// Get completed tasks
  List<UserDailyTask> get completedTasks =>
      _currentTasks.where((t) => t.isCompleted).toList();

  /// Get completion percentage for today
  double get todaysCompletionPercentage {
    if (_currentTasks.isEmpty) return 0.0;
    return completedTasks.length / _currentTasks.length;
  }

  /// Get tasks grouped by category
  Map<TaskCategory, List<UserDailyTask>> get tasksByCategory {
    final grouped = <TaskCategory, List<UserDailyTask>>{};
    for (final task in _currentTasks) {
      final category = TaskCategory.fromString(task.category);
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(task);
    }
    return grouped;
  }

  /// Check if all tasks are completed
  bool get allTasksCompleted =>
      _currentTasks.isNotEmpty && pendingTasks.isEmpty;

  /// Get task history
  Future<Map<DateTime, List<UserDailyTask>>> getTaskHistory({int days = 7}) async {
    return _taskRepository.getTaskHistory(days);
  }

  /// Dispose resources
  void dispose() {
    _tasksController.close();
    _progressController.close();
    _achievementController.close();
    _instance = null;
  }
}

/// Result of task completion
class TaskCompletionResult {
  final bool success;
  final int coinsEarned;
  final int karmaEarned;
  final int experienceEarned;
  final int newStreak;
  final String message;
  final List<Achievement> unlockedAchievements;

  TaskCompletionResult({
    required this.success,
    this.coinsEarned = 0,
    this.karmaEarned = 0,
    this.experienceEarned = 0,
    this.newStreak = 0,
    this.message = '',
    this.unlockedAchievements = const [],
  });
}
