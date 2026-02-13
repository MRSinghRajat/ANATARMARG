import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_task_model.dart';

/// Repository for managing daily tasks
class DailyTaskRepository {
  final SupabaseClient _supabase;

  DailyTaskRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get all active task templates
  Future<List<DailyTaskTemplate>> getTaskTemplates() async {
    try {
      final response = await _supabase
          .from('daily_task_templates')
          .select()
          .eq('is_active', true)
          .order('order_index');

      return (response as List)
          .map((json) => DailyTaskTemplate.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching task templates: $e');
      return [];
    }
  }

  /// Get templates available for user based on their days since signup
  Future<List<DailyTaskTemplate>> getAvailableTemplates(int daysSinceStart) async {
    try {
      final response = await _supabase
          .from('daily_task_templates')
          .select()
          .eq('is_active', true)
          .lte('unlock_after_days', daysSinceStart)
          .order('order_index');

      return (response as List)
          .map((json) => DailyTaskTemplate.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching available templates: $e');
      return [];
    }
  }

  /// Get user's tasks for a specific date
  Future<List<UserDailyTask>> getUserTasksForDate(DateTime date) async {
    if (_userId == null) return [];

    try {
      final dateStr = date.toIso8601String().split('T')[0];
      
      // Get user tasks with template info
      final response = await _supabase
          .from('user_daily_tasks')
          .select('*, daily_task_templates(*)')
          .eq('user_id', _userId!)
          .eq('task_date', dateStr);

      return (response as List).map((json) {
        final templateJson = json['daily_task_templates'];
        DailyTaskTemplate? template;
        if (templateJson != null) {
          template = DailyTaskTemplate.fromJson(templateJson);
        }
        return UserDailyTask.fromJson(json, template: template);
      }).toList();
    } catch (e) {
      print('Error fetching user tasks: $e');
      return [];
    }
  }

  /// Get today's tasks
  Future<List<UserDailyTask>> getTodaysTasks() async {
    return getUserTasksForDate(DateTime.now());
  }

  /// Generate daily tasks for user
  Future<List<UserDailyTask>> generateDailyTasks({
    required int daysSinceStart,
    required int currentStreak,
  }) async {
    if (_userId == null) return [];

    try {
      final today = DateTime.now();
      final dateStr = today.toIso8601String().split('T')[0];
      final weekday = today.weekday % 7; // 0 = Sunday

      // Check if tasks already exist for today
      final existingTasks = await getTodaysTasks();
      if (existingTasks.isNotEmpty) {
        return existingTasks;
      }

      // Get available templates
      final templates = await getAvailableTemplates(daysSinceStart);
      
      // Filter by available days
      final todaysTemplates = templates.where((t) {
        return t.availableDays.contains(weekday);
      }).toList();

      // Select tasks for today (mix of categories)
      final selectedTasks = _selectDailyTasks(todaysTemplates, currentStreak);

      // Insert tasks
      final insertData = selectedTasks.map((template) => {
        'user_id': _userId,
        'task_date': dateStr,
        'template_id': template.id,
        'status': 'pending',
      }).toList();

      if (insertData.isNotEmpty) {
        await _supabase.from('user_daily_tasks').insert(insertData);
      }

      // Return the generated tasks
      return getTodaysTasks();
    } catch (e) {
      print('Error generating daily tasks: $e');
      return [];
    }
  }

  /// Select tasks for today from available templates
  List<DailyTaskTemplate> _selectDailyTasks(
    List<DailyTaskTemplate> templates,
    int currentStreak,
  ) {
    final selectedTasks = <DailyTaskTemplate>[];
    final categories = <String>{};

    // Always include daily verse task
    final dailyVerse = templates.where((t) => t.slug == 'daily_verse').firstOrNull;
    if (dailyVerse != null) {
      selectedTasks.add(dailyVerse);
      categories.add(dailyVerse.category);
    }

    // Always include a meditation task
    final meditationTasks = templates
        .where((t) => t.category == 'meditation' && t.slug != 'silent_hour')
        .toList();
    if (meditationTasks.isNotEmpty) {
      meditationTasks.shuffle();
      selectedTasks.add(meditationTasks.first);
      categories.add('meditation');
    }

    // Add tasks from other categories (diversify)
    final remainingTemplates = templates
        .where((t) => !selectedTasks.contains(t))
        .toList();
    remainingTemplates.shuffle();

    // Add 2-4 more tasks based on streak
    final additionalCount = currentStreak >= 21 ? 4 : (currentStreak >= 7 ? 3 : 2);
    
    for (final template in remainingTemplates) {
      if (selectedTasks.length >= additionalCount + 2) break;
      
      // Prefer tasks from categories not yet added
      if (!categories.contains(template.category) || selectedTasks.length < 4) {
        selectedTasks.add(template);
        categories.add(template.category);
      }
    }

    return selectedTasks;
  }

  /// Complete a task
  Future<bool> completeTask(String taskId) async {
    if (_userId == null) return false;

    try {
      // Get the task to calculate rewards
      final taskResponse = await _supabase
          .from('user_daily_tasks')
          .select('*, daily_task_templates(*)')
          .eq('id', taskId)
          .eq('user_id', _userId!)
          .single();

      final templateJson = taskResponse['daily_task_templates'];
      final coinReward = templateJson?['coin_reward'] as int? ?? 5;
      final karmaReward = templateJson?['karma_reward'] as int? ?? 1;

      // Update task status
      await _supabase
          .from('user_daily_tasks')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toIso8601String(),
            'coins_earned': coinReward,
            'karma_earned': karmaReward,
          })
          .eq('id', taskId)
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      print('Error completing task: $e');
      return false;
    }
  }

  /// Uncomplete a task (for toggling)
  Future<bool> uncompleteTask(String taskId) async {
    if (_userId == null) return false;

    try {
      await _supabase
          .from('user_daily_tasks')
          .update({
            'status': 'pending',
            'completed_at': null,
            'coins_earned': 0,
            'karma_earned': 0,
          })
          .eq('id', taskId)
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      print('Error uncompleting task: $e');
      return false;
    }
  }

  /// Skip a task
  Future<bool> skipTask(String taskId) async {
    if (_userId == null) return false;

    try {
      await _supabase
          .from('user_daily_tasks')
          .update({'status': 'skipped'})
          .eq('id', taskId)
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      print('Error skipping task: $e');
      return false;
    }
  }

  /// Get completed tasks count for today
  Future<int> getTodaysCompletedCount() async {
    if (_userId == null) return 0;

    try {
      final dateStr = DateTime.now().toIso8601String().split('T')[0];
      
      final response = await _supabase
          .from('user_daily_tasks')
          .select('id')
          .eq('user_id', _userId!)
          .eq('task_date', dateStr)
          .eq('status', 'completed');

      return (response as List).length;
    } catch (e) {
      print('Error getting completed count: $e');
      return 0;
    }
  }

  /// Get task history for past N days
  Future<Map<DateTime, List<UserDailyTask>>> getTaskHistory(int days) async {
    if (_userId == null) return {};

    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      final response = await _supabase
          .from('user_daily_tasks')
          .select('*, daily_task_templates(*)')
          .eq('user_id', _userId!)
          .gte('task_date', startDate.toIso8601String().split('T')[0])
          .lte('task_date', endDate.toIso8601String().split('T')[0])
          .order('task_date', ascending: false);

      final Map<DateTime, List<UserDailyTask>> history = {};
      
      for (final json in response as List) {
        final templateJson = json['daily_task_templates'];
        DailyTaskTemplate? template;
        if (templateJson != null) {
          template = DailyTaskTemplate.fromJson(templateJson);
        }
        
        final task = UserDailyTask.fromJson(json, template: template);
        final dateKey = DateTime(task.taskDate.year, task.taskDate.month, task.taskDate.day);
        
        history.putIfAbsent(dateKey, () => []);
        history[dateKey]!.add(task);
      }

      return history;
    } catch (e) {
      print('Error getting task history: $e');
      return {};
    }
  }
}
