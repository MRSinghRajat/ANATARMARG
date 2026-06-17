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

  /// Day index + denominator for progress bars (Ashram, etc.). Matches Journey Home / Granthalaya context labels.
  static ({int currentDay, int totalDays}) journeyDayProgress(UserJourney uj) {
    final meta = uj.metadata;
    if (meta.containsKey('due_date')) {
      final due = DateTime.tryParse(meta['due_date'] as String? ?? '');
      if (due != null) {
        final start = due.subtract(const Duration(days: 280));
        final elapsed = DateTime.now().difference(start).inDays.clamp(0, 280);
        return (currentDay: elapsed, totalDays: 280);
      }
    }
    if (meta.containsKey('child_dob')) {
      final dob = DateTime.tryParse(meta['child_dob'] as String? ?? '');
      if (dob != null) {
        final days = DateTime.now().difference(dob).inDays.clamp(0, 99999);
        return (currentDay: days, totalDays: 365);
      }
    }
    if (uj.startDate != null) {
      final day = DateTime.now().difference(uj.startDate!).inDays.clamp(0, 99999);
      return (currentDay: day, totalDays: 90);
    }
    return (currentDay: 0, totalDays: 90);
  }

  static bool _phaseTriggerMatches(
    UserJourney userJourney,
    Map<String, dynamic> metadata,
    DateTime now,
    JourneyPhase phase,
  ) {
    switch (phase.triggerType) {
      case 'immediate':
        return true;
      case 'age_days':
        final childDobStr = metadata['child_dob'] as String?;
        if (childDobStr == null) return false;
        final childDob = DateTime.tryParse(childDobStr);
        if (childDob == null) return false;
        final ageDays = now.difference(childDob).inDays;
        final from = (phase.triggerValue?['age_days_from'] as num?)?.toInt() ?? 0;
        final to = (phase.triggerValue?['age_days_to'] as num?)?.toInt() ?? 99999;
        return ageDays >= from && ageDays <= to;
      case 'days_before_target':
        final target = userJourney.targetDate;
        if (target == null) return false;
        final daysUntilTarget = target.difference(now).inDays;
        final threshold = (phase.triggerValue?['days_before_target'] as num?)?.toInt();
        if (threshold == null) return false;
        return daysUntilTarget <= threshold;
      case 'day_offset':
        final start = userJourney.startDate;
        if (start == null) return false;
        final dayOfJourney = now.difference(start).inDays;
        final fromDay = (phase.triggerValue?['days'] as num?)?.toInt() ?? 0;
        return dayOfJourney >= fromDay;
      case 'week':
        DateTime? targetDate = userJourney.targetDate;
        if (targetDate == null) {
          final dueStr = metadata['pregnancy_due_date'] as String?;
          if (dueStr != null) targetDate = DateTime.tryParse(dueStr);
        }
        if (targetDate == null) return false;
        final weeksRemaining = targetDate.difference(now).inDays / 7;
        final currentWeek = (40 - weeksRemaining).ceil().clamp(1, 42);
        final weekVal = (phase.triggerValue?['week'] as num?)?.toInt();
        if (weekVal == null) return false;
        return currentWeek >= weekVal;
      default:
        return false;
    }
  }

  /// Current phase: walk phases in order; stay on the last consecutive phase whose trigger matches.
  /// Avoids the old reverse-scan bug where a high-order `immediate` phase hid earlier stages on day 1.
  static JourneyPhase? getCurrentPhase(
    UserJourney userJourney,
    List<JourneyPhase> phases,
  ) {
    if (phases.isEmpty) return null;
    final sorted = List<JourneyPhase>.from(phases)
      ..sort((a, b) => a.phaseOrder.compareTo(b.phaseOrder));
    final metadata = userJourney.metadata;
    final now = DateTime.now();

    JourneyPhase? lastMatching;
    for (final phase in sorted) {
      if (_phaseTriggerMatches(userJourney, metadata, now, phase)) {
        lastMatching = phase;
      } else {
        break;
      }
    }
    return lastMatching ?? sorted.first;
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

  /// Tasks to show for a phase: when [displayPhase] matches the calendar [calendarPhase],
  /// applies the same pregnancy-week / "today" filters as [getTodaysTasks]. Otherwise returns
  /// all tasks in that phase so the user can preview a future trimester read-only.
  static List<JourneyTask> getTasksForDisplayedPhase(
    UserJourney userJourney,
    JourneyPhase displayPhase,
    JourneyPhase? calendarPhase,
    List<JourneyTask> allTasks,
  ) {
    final isLiveSlice =
        calendarPhase != null && displayPhase.id == calendarPhase.id;
    if (isLiveSlice) {
      return getTodaysTasks(userJourney, displayPhase, allTasks);
    }
    final list =
        allTasks.where((t) => t.phaseId == displayPhase.id).toList();
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  /// Whether this task may be completed today (active journey, calendar phase, in live list, not already done).
  static bool canCompleteTaskToday({
    required UserJourney userJourney,
    required JourneyTask task,
    required JourneyPhase? calendarPhase,
    required List<JourneyTask> allTasks,
    required Set<String> completedTaskIdsToday,
  }) {
    return taskCompletionBlockedReason(
          userJourney: userJourney,
          task: task,
          calendarPhase: calendarPhase,
          allTasks: allTasks,
          completedTaskIdsToday: completedTaskIdsToday,
        ) ==
        null;
  }

  /// Human-readable reason completion is blocked, or null if allowed.
  static String? taskCompletionBlockedReason({
    required UserJourney userJourney,
    required JourneyTask task,
    required JourneyPhase? calendarPhase,
    required List<JourneyTask> allTasks,
    required Set<String> completedTaskIdsToday,
  }) {
    if (userJourney.isCompleted) {
      return 'This journey is complete. You can review tasks, but you cannot mark them again.';
    }
    if (!userJourney.isActive) {
      return 'Resume your journey to complete tasks.';
    }
    if (completedTaskIdsToday.contains(task.id)) {
      return 'You already completed this task today.';
    }
    if (calendarPhase == null || task.phaseId != calendarPhase.id) {
      return 'This task unlocks when your journey reaches this stage on the calendar.';
    }
    final live = getTodaysTasks(userJourney, calendarPhase, allTasks);
    if (!live.any((t) => t.id == task.id)) {
      return 'This task is not available yet for your current week or stage.';
    }
    return null;
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
