import 'models/journey_models.dart';

/// Phase detection and today's task filter — computed at runtime, never stored.
class JourneyLogic {
  JourneyLogic._();

  /// Extracts unique phases from the tasks list (from v_journey_tasks_full view).
  /// Returns JourneyPhase objects reconstructed from embedded phase fields.
  static List<JourneyPhase> extractPhases(List<JourneyTask> tasks) {
    final seen = <String>{};
    final phases = <JourneyPhase>[];
    for (final task in tasks) {
      if (seen.contains(task.phaseId)) continue;
      seen.add(task.phaseId);
      phases.add(JourneyPhase(
        id: task.phaseId,
        journeyTypeId: task.journeyTypeId,
        slug: task.phaseSlug,
        title: task.phaseTitle ?? task.phaseSlug,
        titleHindi: task.phaseTitleHindi,
        phaseOrder: task.phaseOrder,
        triggerType: task.triggerType,
        triggerValue: task.triggerValue,
        durationLabel: task.phaseDurationLabel,
        icon: task.phaseIcon,
        colorHex: task.phaseColorHex,
      ));
    }
    phases.sort((a, b) => a.phaseOrder.compareTo(b.phaseOrder));
    return phases;
  }

  /// Returns the current phase for this user journey based on today's date and metadata.
  /// Works with phases extracted from the tasks view.
  static JourneyPhase? getCurrentPhase(
    UserJourney userJourney,
    List<JourneyPhase> phases,
  ) {
    if (phases.isEmpty) return null;
    final sorted = List<JourneyPhase>.from(phases)
      ..sort((a, b) => a.phaseOrder.compareTo(b.phaseOrder));
    final metadata = userJourney.metadata;
    final now = DateTime.now();

    for (var i = sorted.length - 1; i >= 0; i--) {
      final phase = sorted[i];
      switch (phase.triggerType) {
        case 'immediate':
          return phase;
        case 'age_days':
          final childDobStr = metadata['child_dob'] as String?;
          if (childDobStr == null) continue;
          final childDob = DateTime.tryParse(childDobStr);
          if (childDob == null) continue;
          final ageDays = now.difference(childDob).inDays;
          final from = (phase.triggerValue?['age_days_from'] as num?)?.toInt() ?? 0;
          final to = (phase.triggerValue?['age_days_to'] as num?)?.toInt() ?? 99999;
          if (ageDays >= from && ageDays <= to) return phase;
          break;
        case 'days_before_target':
          final target = userJourney.targetDate;
          if (target == null) continue;
          final daysUntilTarget = target.difference(now).inDays;
          final threshold = (phase.triggerValue?['days_before_target'] as num?)?.toInt();
          if (threshold != null && daysUntilTarget <= threshold) return phase;
          break;
        case 'day_offset':
          final start = userJourney.startDate;
          if (start == null) continue;
          final dayOfJourney = now.difference(start).inDays;
          final fromDay = (phase.triggerValue?['days'] as num?)?.toInt() ?? 0;
          if (dayOfJourney >= fromDay) return phase;
          break;
        case 'week':
          // Use target_date or metadata.pregnancy_due_date (Garbh Sanskar spec)
          DateTime? targetDate = userJourney.targetDate;
          if (targetDate == null) {
            final dueStr = metadata['pregnancy_due_date'] as String?;
            if (dueStr != null) targetDate = DateTime.tryParse(dueStr);
          }
          if (targetDate == null) continue;
          final weeksRemaining = targetDate.difference(now).inDays / 7;
          final currentWeek = (40 - weeksRemaining).ceil().clamp(1, 42);
          final weekVal = (phase.triggerValue?['week'] as num?)?.toInt();
          if (weekVal != null && currentWeek >= weekVal) return phase;
          break;
        default:
          break;
      }
    }
    return sorted.isNotEmpty ? sorted.first : null;
  }

  /// Convenience: detect current phase directly from tasks list + user journey.
  /// Returns null if tasks are empty or phases cannot be determined.
  static JourneyPhase? getCurrentPhaseFromTasks(
    UserJourney userJourney,
    List<JourneyTask> tasks,
  ) {
    final phases = extractPhases(tasks);
    return getCurrentPhase(userJourney, phases);
  }

  /// Current pregnancy week (1–42) from user_journey target_date or metadata.pregnancy_due_date.
  /// Returns null if not in pregnancy mode.
  static int? getCurrentPregnancyWeek(UserJourney userJourney) {
    DateTime? targetDate = userJourney.targetDate;
    if (targetDate == null) {
      final dueStr = userJourney.metadata['pregnancy_due_date'] as String?;
      if (dueStr != null) targetDate = DateTime.tryParse(dueStr);
    }
    if (targetDate == null) return null;
    final now = DateTime.now();
    final weeksRemaining = targetDate.difference(now).inDays / 7;
    return (40 - weeksRemaining).ceil().clamp(1, 42);
  }

  /// Filters tasks that are due today for the given user journey and current phase.
  /// For Garbh Sanskar: filters by week_from/week_to when task has week bounds and user is pregnant.
  static List<JourneyTask> getTodaysTasks(
    UserJourney userJourney,
    JourneyPhase currentPhase,
    List<JourneyTask> allTasks,
  ) {
    final pregnancyWeek = getCurrentPregnancyWeek(userJourney);

    final filtered = allTasks.where((task) {
      if (task.phaseId != currentPhase.id) return false;

      // Apply week_from/week_to only when we have a pregnancy week (due date set).
      // In planning mode (no due date), ignore week bounds so all phase tasks are shown.
      if (pregnancyWeek != null && (task.weekFrom != null || task.weekTo != null)) {
        if (task.weekFrom != null && pregnancyWeek < task.weekFrom!) return false;
        if (task.weekTo != null && pregnancyWeek > task.weekTo!) return false;
      }

      switch (task.frequency) {
        case 'daily':
          return true;
        case 'once':
          return true;
        case 'weekly':
          return true;
        default:
          return true;
      }
    }).toList();

    filtered.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return filtered;
  }

  /// Picks today's content item from a pool using day-based rotation.
  static JourneyContentItem? pickTodaysContent(
    List<JourneyContentItem> pool,
    UserJourney userJourney,
  ) {
    if (pool.isEmpty) return null;
    final start = userJourney.startDate ?? DateTime.now();
    final dayOfJourney = DateTime.now().difference(start).inDays;
    return pool[dayOfJourney % pool.length];
  }
}
