import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/daily_task_model.dart';
import '../../../../core/constants/app_constants.dart';

class TaskRepository {
  static final TaskRepository _instance = TaskRepository._internal();
  factory TaskRepository() => _instance;
  TaskRepository._internal();
  final _tasksController = StreamController<List<DailyTaskModel>>.broadcast();

  Stream<List<DailyTaskModel>> get tasksStream => _tasksController.stream;

  Future<List<DailyTaskModel>> getDailyTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'tasks_${today.year}_${today.month}_${today.day}';

    // Check if tasks exist for today
    final tasksJson = prefs.getString(todayKey);
    if (tasksJson != null) {
      final List<dynamic> tasksList = jsonDecode(tasksJson);
      final tasks = tasksList
          .map((t) => DailyTaskModel.fromJson(t as Map<String, dynamic>))
          .toList();
      _tasksController.add(tasks);
      return tasks;
    }

    // Generate new tasks for today
    final tasks = await _generateDailyTasks();
    await _saveTasks(tasks, todayKey);
    _tasksController.add(tasks);
    return tasks;
  }

  Future<List<DailyTaskModel>> _generateDailyTasks() async {
    final today = DateTime.now();
    final tasks = <DailyTaskModel>[];

    for (final taskType in AppConstants.dailyTaskTypes) {
      final task = DailyTaskModel(
        id: '${taskType}_${today.millisecondsSinceEpoch}',
        type: TaskType.values.firstWhere((e) => e.name == taskType),
        assignedDate: today,
        coinReward: 35,
        readingTimeMinutes: 2,
      );
      tasks.add(task);
    }

    return tasks;
  }

  Future<DailyTaskModel> loadTaskVerse(DailyTaskModel task) async {
    // No API: verse stays null for now; UI can show task without verse
    return task;
  }

  Future<void> completeTask(String taskId) async {
    final tasks = await getDailyTasks();
    final updatedTasks = tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isCompleted: true);
      }
      return task;
    }).toList();

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'tasks_${today.year}_${today.month}_${today.day}';
    await _saveTasks(updatedTasks, todayKey);
    _tasksController.add(updatedTasks);
  }

  Future<void> skipTask(String taskId) async {
    final tasks = await getDailyTasks();
    final updatedTasks = tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isSkipped: true);
      }
      return task;
    }).toList();

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = 'tasks_${today.year}_${today.month}_${today.day}';
    await _saveTasks(updatedTasks, todayKey);
    _tasksController.add(updatedTasks);
  }

  Future<void> _saveTasks(List<DailyTaskModel> tasks, String key) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(key, tasksJson);
  }

  void dispose() {
    _tasksController.close();
  }
}
