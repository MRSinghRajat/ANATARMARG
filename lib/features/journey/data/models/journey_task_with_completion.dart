import 'journey_task.dart';

/// Task with today's completion flag for UI.
class JourneyTaskWithCompletion {
  final JourneyTask task;
  final bool isCompleted;

  const JourneyTaskWithCompletion({
    required this.task,
    required this.isCompleted,
  });
}
