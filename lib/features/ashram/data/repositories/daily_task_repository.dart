import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_clock.dart';
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

  /// Get user's tasks for a specific date (uses local date so today matches user's day).
  Future<List<UserDailyTask>> getUserTasksForDate(DateTime date) async {
    if (_userId == null) return [];

    try {
      final dateStr = AppClock.localDateString(date);
      
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
    return getUserTasksForDate(AppClock.now());
  }

  /// Generate daily tasks for user
  Future<List<UserDailyTask>> generateDailyTasks({
    required int daysSinceStart,
    required int currentStreak,
  }) async {
    if (_userId == null) return [];

    try {
      final today = AppClock.now();
      final dateStr = AppClock.todayString();
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

  /// Deterministic meditation slug for each weekday (1=Mon .. 7=Sun)
  static const _meditationByWeekday = {
    1: 'daily_meditation',    // Mon: Breath Awareness
    2: 'morning_meditation',  // Tue: 5-min
    3: 'pranayama',           // Wed: Pranayama
    4: 'daily_meditation',    // Thu: Breath Awareness
    5: 'morning_meditation',  // Fri: 5-min
    6: 'pranayama',           // Sat: Pranayama
    7: 'listen_chant',        // Sun: Sacred Chant
  };

  /// Deterministic extra-slot slug for each weekday
  static const _extraByWeekday = {
    1: 'help_someone',
    2: 'light_diya',
    3: 'japa_108',
    4: 'help_someone',
    5: 'evening_aarti',
    6: 'share_wisdom',
    7: 'help_someone',
  };

  /// Select tasks for today from available templates (deterministic by weekday)
  List<DailyTaskTemplate> _selectDailyTasks(
    List<DailyTaskTemplate> templates,
    int currentStreak,
  ) {
    final selectedSlugs = <String>{};
    final selectedTasks = <DailyTaskTemplate>[];

    DailyTaskTemplate? _findBySlug(String slug) {
      return templates.where((t) => t.slug == slug).firstOrNull;
    }

    void _addIfAvailable(String slug) {
      if (selectedSlugs.contains(slug)) return;
      final t = _findBySlug(slug);
      if (t != null) {
        selectedTasks.add(t);
        selectedSlugs.add(slug);
      }
    }

    // ── Core tasks (always present) ──
    _addIfAvailable('daily_verse');
    _addIfAvailable('daily_story');
    _addIfAvailable('donate');
    _addIfAvailable('gratitude_practice');
    _addIfAvailable('japa_108');
    _addIfAvailable('manifestation');

    // ── Meditation slot (weekday-based) ──
    final weekday = AppClock.now().weekday; // 1=Mon .. 7=Sun
    final meditationSlug = _meditationByWeekday[weekday] ?? 'daily_meditation';
    _addIfAvailable(meditationSlug);

    // ── Extra slot (weekday-based) ──
    final extraSlug = _extraByWeekday[weekday] ?? 'help_someone';
    _addIfAvailable(extraSlug);

    return selectedTasks;
  }

  /// Complete a task. [DailyTaskCompleteOutcome.grantedNewRewards] is false if this row was
  /// already rewarded (re-check after un-check) — caller must not add coins/XP again.
  Future<DailyTaskCompleteOutcome> completeTask(String taskId) async {
    if (_userId == null) {
      return const DailyTaskCompleteOutcome(success: false);
    }

    try {
      final taskResponse = await _supabase
          .from('user_daily_tasks')
          .select('*, daily_task_templates(*)')
          .eq('id', taskId)
          .eq('user_id', _userId!)
          .single();

      final rawGranted = taskResponse['rewards_granted_at'];
      final priorGranted = rawGranted != null
          ? DateTime.tryParse(rawGranted.toString())
          : null;
      final alreadyRewarded = priorGranted != null;

      final templateJson = taskResponse['daily_task_templates'];
      final coinReward = templateJson?['coin_reward'] as int? ?? 5;
      final karmaReward = templateJson?['karma_reward'] as int? ?? 1;

      final nowIso = AppClock.now().toIso8601String();

      if (alreadyRewarded) {
        await _supabase
            .from('user_daily_tasks')
            .update({
              'status': 'completed',
              'completed_at': nowIso,
              'coins_earned': coinReward,
              'karma_earned': karmaReward,
            })
            .eq('id', taskId)
            .eq('user_id', _userId!);

        return DailyTaskCompleteOutcome(
          success: true,
          grantedNewRewards: false,
          rewardsGrantedAt: priorGranted,
        );
      }

      await _supabase
          .from('user_daily_tasks')
          .update({
            'status': 'completed',
            'completed_at': nowIso,
            'coins_earned': coinReward,
            'karma_earned': karmaReward,
            'rewards_granted_at': nowIso,
          })
          .eq('id', taskId)
          .eq('user_id', _userId!);

      final grantedAt = DateTime.tryParse(nowIso) ?? DateTime.now();
      return DailyTaskCompleteOutcome(
        success: true,
        grantedNewRewards: true,
        rewardsGrantedAt: grantedAt,
      );
    } catch (e) {
      print('Error completing task: $e');
      return const DailyTaskCompleteOutcome(success: false);
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
      final dateStr = AppClock.todayString();
      
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
      final endDate = AppClock.now();
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

  /// Activity count per day for the last [days] days (for heatmap).
  /// Returns date -> number of completed tasks that day.
  Future<Map<DateTime, int>> getActivityHeatmap(int days) async {
    if (_userId == null) return {};

    try {
      final endDate = AppClock.now();
      final startDate = endDate.subtract(Duration(days: days));
      final response = await _supabase
          .from('user_daily_tasks')
          .select('task_date')
          .eq('user_id', _userId!)
          .eq('status', 'completed')
          .gte('task_date', startDate.toIso8601String().split('T')[0])
          .lte('task_date', endDate.toIso8601String().split('T')[0]);

      final Map<DateTime, int> counts = {};
      for (final row in response as List) {
        final dateStr = row['task_date'] as String?;
        if (dateStr == null) continue;
        final d = DateTime.parse(dateStr);
        final key = DateTime(d.year, d.month, d.day);
        counts[key] = (counts[key] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      print('Error getting activity heatmap: $e');
      return {};
    }
  }

  /// Total completed japa sessions (tasks with slug japa_108) for practice stats.
  Future<int> getTotalJapaCompletions() async {
    if (_userId == null) return 0;
    try {
      final templates = await _supabase
          .from('daily_task_templates')
          .select('id, slug')
          .eq('is_active', true);
      final japaIds = <String>[];
      for (final t in templates as List) {
        final slug = t['slug'] as String? ?? '';
        if (slug == 'japa_108' || slug.contains('japa')) {
          japaIds.add(t['id'] as String);
        }
      }
      if (japaIds.isEmpty) return 0;
      final response = await _supabase
          .from('user_daily_tasks')
          .select('id')
          .eq('user_id', _userId!)
          .eq('status', 'completed')
          .inFilter('template_id', japaIds);
      return (response as List).length;
    } catch (e) {
      print('Error getting japa completions: $e');
      return 0;
    }
  }

  /// Count completed gratitude / reflection practice sessions for My Growth.
  Future<int> getGratitudeCompletionsCount() async {
    if (_userId == null) return 0;
    try {
      final templates = await _supabase
          .from('daily_task_templates')
          .select('id, slug')
          .eq('is_active', true);
      final ids = <String>[];
      for (final t in templates as List) {
        final slug = t['slug'] as String? ?? '';
        if (slug.contains('gratitude') || slug.contains('reflection')) {
          ids.add(t['id'] as String);
        }
      }
      if (ids.isEmpty) return 0;
      final response = await _supabase
          .from('user_daily_tasks')
          .select('id')
          .eq('user_id', _userId!)
          .eq('status', 'completed')
          .inFilter('template_id', ids);
      return (response as List).length;
    } catch (e) {
      print('Error getting gratitude completions: $e');
      return 0;
    }
  }
}
