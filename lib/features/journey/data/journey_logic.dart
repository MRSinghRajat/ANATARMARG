import 'models/journey_models.dart';

/// Phase detection and today's task filter — computed at runtime, never stored.
class JourneyLogic {
  JourneyLogic._();

  // ─── L04: date/recurrence helpers ────────────────────────────────────────
  //
  // Week and day boundaries are computed on the LOCAL calendar date (not UTC),
  // matching the existing local-date convention already used for
  // `completed_date` in JourneyRepository (DateTime.now() truncated to a date,
  // no UTC conversion). Mixing local and UTC boundaries here would reintroduce
  // a timezone bug while fixing this one.

  /// Local calendar date with time-of-day stripped (for boundary comparisons).
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Monday-anchored local calendar week containing [date] (inclusive start).
  /// Dart's `DateTime.weekday` is 1=Monday..7=Sunday, so this is a plain
  /// ISO-8601 week start with no cross-locale ambiguity.
  static DateTime weekStart(DateTime date) {
    final d = dateOnly(date);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Calendar days elapsed since [uj.startDate], adjusted for a pause.
  ///
  /// Schema note: `user_journeys` stores only the *most recent* `paused_at`/
  /// `resumed_at` pair, not a full pause history, so a journey paused and
  /// resumed more than once will only have its latest pause window excluded
  /// precisely — earlier pause windows in the same journey are not tracked
  /// and cannot be subtracted without a schema change (out of scope for this
  /// fix; see docs/MVP_LAUNCH_PLAN.md L04). This is still strictly more
  /// correct than the previous behavior, which ignored pauses entirely and
  /// let both day-based phase unlocks and progress bars advance while a
  /// journey was paused.
  ///
  /// - Currently paused: frozen at the day count when the pause started.
  /// - Resumed after a pause: the paused span is excluded from elapsed days.
  /// - Never paused: unchanged raw calendar-day difference.
  static int effectiveDaysSinceStart(UserJourney uj, {DateTime? now}) {
    final start = uj.startDate;
    if (start == null) return 0;
    final today = now ?? DateTime.now();
    final startDay = dateOnly(start);

    if (uj.isPaused && uj.pausedAt != null) {
      final pausedDay = dateOnly(uj.pausedAt!);
      return pausedDay.difference(startDay).inDays.clamp(0, 1 << 30);
    }

    var elapsed = dateOnly(today).difference(startDay).inDays;
    if (uj.pausedAt != null &&
        uj.resumedAt != null &&
        uj.resumedAt!.isAfter(uj.pausedAt!)) {
      final pausedSpan =
          dateOnly(uj.resumedAt!).difference(dateOnly(uj.pausedAt!)).inDays;
      elapsed -= pausedSpan;
    }
    return elapsed.clamp(0, 1 << 30);
  }

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
  ///
  /// [durationDays] is the journey type's actual program length (e.g. 21 or
  /// 40 for a fixed-length program) — pass `JourneyType.durationDays` when
  /// available. Previously this always reported a hardcoded 90-day
  /// denominator for any journey identified only by `startDate` (i.e. every
  /// non-pregnancy fixed-length program), which is a real, visibly-rendered
  /// defect on the Ashram and Journey Home progress bars, not just an
  /// unused helper — confirmed both call sites before changing this.
  static ({int currentDay, int totalDays}) journeyDayProgress(
    UserJourney uj, {
    int? durationDays,
  }) {
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
    final metaDurationDays = (meta['duration_days'] as num?)?.toInt();
    final effectiveDurationDays = durationDays ?? metaDurationDays;
    if (effectiveDurationDays != null &&
        effectiveDurationDays > 0 &&
        uj.startDate != null) {
      final day =
          effectiveDaysSinceStart(uj).clamp(0, effectiveDurationDays);
      return (currentDay: day, totalDays: effectiveDurationDays);
    }
    if (uj.startDate != null) {
      final day = effectiveDaysSinceStart(uj).clamp(0, 99999);
      return (currentDay: day, totalDays: effectiveDurationDays ?? 90);
    }
    return (currentDay: 0, totalDays: effectiveDurationDays ?? 90);
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
        if (userJourney.startDate == null) return false;
        // Pause-aware: a paused journey must not keep unlocking later phases
        // purely because calendar time passed (see effectiveDaysSinceStart).
        final dayOfJourney = effectiveDaysSinceStart(userJourney, now: now);
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
    List<JourneyPhase> phases, {
    DateTime? now,
  }) {
    if (phases.isEmpty) return null;
    final sorted = List<JourneyPhase>.from(phases)
      ..sort((a, b) => a.phaseOrder.compareTo(b.phaseOrder));
    final metadata = userJourney.metadata;
    final effectiveNow = now ?? DateTime.now();

    JourneyPhase? lastMatching;
    for (final phase in sorted) {
      if (_phaseTriggerMatches(userJourney, metadata, effectiveNow, phase)) {
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
    List<JourneyTask> tasks, {
    DateTime? now,
  }) {
    final phases = extractPhases(tasks);
    return getCurrentPhase(userJourney, phases, now: now);
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
  ///
  /// Recurrence semantics (previously a no-op — every frequency fell through
  /// to `true`, so `once` and `weekly` tasks reappeared and stayed
  /// completable every single day, forever):
  /// - `daily`: due every day this phase is active. Unaffected by history.
  /// - `once`: due until it has been completed a single time, ever, for this
  ///   `user_journey_id` — pass every task id with any completion row in
  ///   [completedOnceTaskIds] (i.e. an unfiltered/"ever" query, not just today).
  /// - `weekly`: due until completed within the current local calendar week
  ///   (Monday-anchored, see [weekStart]) — pass task ids completed since
  ///   that week start in [completedThisWeekTaskIds].
  /// - anything else/unrecognized: treated as `daily` (fail open to "show it"
  ///   rather than silently hiding a task with a typo'd frequency value).
  static List<JourneyTask> getTodaysTasks(
    UserJourney userJourney,
    JourneyPhase currentPhase,
    List<JourneyTask> allTasks, {
    Set<String> completedOnceTaskIds = const {},
    Set<String> completedThisWeekTaskIds = const {},
  }) {
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
        case 'once':
          return !completedOnceTaskIds.contains(task.id);
        case 'weekly':
          return !completedThisWeekTaskIds.contains(task.id);
        case 'daily':
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
    List<JourneyTask> allTasks, {
    Set<String> completedOnceTaskIds = const {},
    Set<String> completedThisWeekTaskIds = const {},
  }) {
    final isLiveSlice =
        calendarPhase != null && displayPhase.id == calendarPhase.id;
    if (isLiveSlice) {
      return getTodaysTasks(
        userJourney,
        displayPhase,
        allTasks,
        completedOnceTaskIds: completedOnceTaskIds,
        completedThisWeekTaskIds: completedThisWeekTaskIds,
      );
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
    Set<String> completedOnceTaskIds = const {},
    Set<String> completedThisWeekTaskIds = const {},
  }) {
    return taskCompletionBlockedReason(
          userJourney: userJourney,
          task: task,
          calendarPhase: calendarPhase,
          allTasks: allTasks,
          completedTaskIdsToday: completedTaskIdsToday,
          completedOnceTaskIds: completedOnceTaskIds,
          completedThisWeekTaskIds: completedThisWeekTaskIds,
        ) ==
        null;
  }

  /// Human-readable reason completion is blocked, or null if allowed.
  ///
  /// [completedOnceTaskIds]/[completedThisWeekTaskIds] are the same
  /// recurrence-history sets passed to [getTodaysTasks] — checked explicitly
  /// here too (not just relied on via the `live` list below) so a stale
  /// cached task list can't let a `once`/`weekly` task be completed twice
  /// with duplicate rewards; this is the actual enforcement point, since
  /// `completeTask` is called from here having already checked this reason.
  static String? taskCompletionBlockedReason({
    required UserJourney userJourney,
    required JourneyTask task,
    required JourneyPhase? calendarPhase,
    required List<JourneyTask> allTasks,
    required Set<String> completedTaskIdsToday,
    Set<String> completedOnceTaskIds = const {},
    Set<String> completedThisWeekTaskIds = const {},
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
    if (task.frequency == 'once' && completedOnceTaskIds.contains(task.id)) {
      return 'You already completed this practice.';
    }
    if (task.frequency == 'weekly' &&
        completedThisWeekTaskIds.contains(task.id)) {
      return 'You already completed this practice this week.';
    }
    if (calendarPhase == null || task.phaseId != calendarPhase.id) {
      return 'This task unlocks when your journey reaches this stage on the calendar.';
    }
    final live = getTodaysTasks(
      userJourney,
      calendarPhase,
      allTasks,
      completedOnceTaskIds: completedOnceTaskIds,
      completedThisWeekTaskIds: completedThisWeekTaskIds,
    );
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
