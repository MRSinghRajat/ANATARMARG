// L04 — journey recurrence and date behavior.
//
// Behavioral tests for the defects described in docs/MVP_LAUNCH_PLAN.md L04
// and docs/CLAUDE_HANDOFF.md:
//   - `once`/`weekly` tasks previously reappeared and stayed completable
//     every day forever (JourneyLogic.getTodaysTasks ignored `frequency`).
//   - Duplicate completion of a `once`/`weekly` task could duplicate coin
//     rewards, because the only completion check available was "today".
//   - Day-based phase unlocks and progress bars advanced during a pause,
//     because elapsed time was computed from raw calendar days with no
//     awareness of paused_at/resumed_at.
//   - journeyDayProgress hardcoded a 90-day denominator for every
//     fixed-length program (21-day, 40-day), not just pregnancy journeys.
//
// These are pure-function tests against JourneyLogic — no Supabase, no
// widgets — matching "focused tests" for a domain-logic fix.

import 'package:flutter_test/flutter_test.dart';
import 'package:antarmarg/features/journey/data/journey_logic.dart';
import 'package:antarmarg/features/journey/data/models/journey_models.dart';

UserJourney _journey({
  String status = 'active',
  DateTime? startDate,
  DateTime? pausedAt,
  DateTime? resumedAt,
  Map<String, dynamic> metadata = const {},
}) {
  return UserJourney(
    id: 'uj-1',
    userId: 'user-1',
    journeyTypeId: 'jt-1',
    status: status,
    startDate: startDate,
    pausedAt: pausedAt,
    resumedAt: resumedAt,
    metadata: metadata,
  );
}

JourneyPhase _phase(
  String id, {
  int phaseOrder = 0,
  String triggerType = 'immediate',
  Map<String, dynamic>? triggerValue,
}) {
  return JourneyPhase(
    id: id,
    journeyTypeId: 'jt-1',
    slug: id,
    title: id,
    phaseOrder: phaseOrder,
    triggerType: triggerType,
    triggerValue: triggerValue,
  );
}

JourneyTask _task(
  String id, {
  String phaseId = 'phase-1',
  String frequency = 'daily',
  int displayOrder = 0,
}) {
  return JourneyTask(
    id: id,
    journeyTypeId: 'jt-1',
    slug: id,
    title: id,
    frequency: frequency,
    phaseId: phaseId,
    displayOrder: displayOrder,
  );
}

void main() {
  group('weekStart — Monday-anchored local week boundary', () {
    test('a Monday maps to itself', () {
      final monday = DateTime(2026, 9, 14); // confirmed Monday
      expect(JourneyLogic.weekStart(monday), DateTime(2026, 9, 14));
    });

    test('a Sunday maps back to the same week\'s Monday, not forward', () {
      final sunday = DateTime(2026, 9, 20);
      expect(JourneyLogic.weekStart(sunday), DateTime(2026, 9, 14));
    });

    test('mid-week (Thursday) maps to that week\'s Monday', () {
      final thursday = DateTime(2026, 9, 17);
      expect(JourneyLogic.weekStart(thursday), DateTime(2026, 9, 14));
    });

    test('strips time-of-day', () {
      final withTime = DateTime(2026, 9, 16, 23, 59, 59);
      expect(JourneyLogic.weekStart(withTime), DateTime(2026, 9, 14));
    });
  });

  group('effectiveDaysSinceStart — pause-aware elapsed days', () {
    final start = DateTime(2026, 1, 1);

    test('never paused: plain calendar-day difference', () {
      final uj = _journey(startDate: start);
      final now = DateTime(2026, 1, 11);
      expect(JourneyLogic.effectiveDaysSinceStart(uj, now: now), 10);
    });

    test('currently paused: frozen at the day count when paused, ignores time since', () {
      final uj = _journey(
        status: 'paused',
        startDate: start,
        pausedAt: DateTime(2026, 1, 6),
      );
      // Even though "now" is much later, the journey is still paused.
      final now = DateTime(2026, 3, 1);
      expect(JourneyLogic.effectiveDaysSinceStart(uj, now: now), 5);
    });

    test('resumed after a pause: the paused span is excluded from elapsed days', () {
      // Day 5: paused. Day 10: resumed (5 days paused). "Now" is day 20
      // real time -> should read as day 15 effective (20 - 5 paused).
      final uj = _journey(
        startDate: start,
        pausedAt: DateTime(2026, 1, 6), // day 5
        resumedAt: DateTime(2026, 1, 11), // day 10
      );
      final now = DateTime(2026, 1, 21); // day 20 real time
      expect(JourneyLogic.effectiveDaysSinceStart(uj, now: now), 15);
    });

    test('no start date: zero, never negative/null', () {
      final uj = _journey(startDate: null);
      expect(JourneyLogic.effectiveDaysSinceStart(uj), 0);
    });
  });

  group('journeyDayProgress — real program length, pause-aware', () {
    test('fixed-length program reports its real duration, not a hardcoded 90', () {
      final uj = _journey(startDate: DateTime(2026, 1, 1));
      final progress = JourneyLogic.journeyDayProgress(uj, durationDays: 21);
      expect(progress.totalDays, 21);
    });

    test('missing durationDays still falls back to 90 (no regression for callers not yet updated)', () {
      final uj = _journey(startDate: DateTime(2026, 1, 1));
      final progress = JourneyLogic.journeyDayProgress(uj);
      expect(progress.totalDays, 90);
    });

    test('currentDay does not advance while paused', () {
      final uj = _journey(
        status: 'paused',
        startDate: DateTime(2026, 1, 1),
        pausedAt: DateTime(2026, 1, 21), // day 20 of a 40-day program
      );
      final progress = JourneyLogic.journeyDayProgress(uj, durationDays: 40);
      expect(progress.currentDay, 20);
    });
  });

  group('getTodaysTasks — recurrence (the core L04 defect)', () {
    final uj = _journey(startDate: DateTime(2026, 1, 1));
    final phase = _phase('phase-1');

    test('daily task always included, history irrelevant', () {
      final tasks = [_task('t-daily', frequency: 'daily')];
      final result = JourneyLogic.getTodaysTasks(uj, phase, tasks,
          completedOnceTaskIds: {'t-daily'}, completedThisWeekTaskIds: {'t-daily'});
      expect(result.map((t) => t.id), contains('t-daily'));
    });

    test('once task included when never completed', () {
      final tasks = [_task('t-once', frequency: 'once')];
      final result = JourneyLogic.getTodaysTasks(uj, phase, tasks);
      expect(result.map((t) => t.id), contains('t-once'));
    });

    test('once task excluded forever once it has any completion, regardless of which day', () {
      final tasks = [_task('t-once', frequency: 'once')];
      final result = JourneyLogic.getTodaysTasks(
        uj,
        phase,
        tasks,
        completedOnceTaskIds: {'t-once'},
      );
      expect(result, isEmpty);
    });

    test('weekly task included when not completed this week', () {
      final tasks = [_task('t-weekly', frequency: 'weekly')];
      final result = JourneyLogic.getTodaysTasks(uj, phase, tasks);
      expect(result.map((t) => t.id), contains('t-weekly'));
    });

    test('weekly task excluded once completed this week', () {
      final tasks = [_task('t-weekly', frequency: 'weekly')];
      final result = JourneyLogic.getTodaysTasks(
        uj,
        phase,
        tasks,
        completedThisWeekTaskIds: {'t-weekly'},
      );
      expect(result, isEmpty);
    });

    test('weekly task reappears next week even though it was completed last week', () {
      // Simulates rollover: last week's completion set does not include this
      // week's bucket, so the task is due again — this is the defined
      // "weekly uses defined week boundaries" behavior, not a regression of
      // "once".
      final tasks = [_task('t-weekly', frequency: 'weekly')];
      final result = JourneyLogic.getTodaysTasks(
        uj,
        phase,
        tasks,
        completedThisWeekTaskIds: {}, // this week's set, deliberately empty
      );
      expect(result.map((t) => t.id), contains('t-weekly'));
    });

    test('unrecognized/blank frequency fails open (treated as daily, not silently hidden)', () {
      final tasks = [_task('t-unknown', frequency: 'fortnightly')];
      final result = JourneyLogic.getTodaysTasks(uj, phase, tasks);
      expect(result.map((t) => t.id), contains('t-unknown'));
    });

    test('tasks outside the current phase are never included', () {
      final tasks = [_task('t-other-phase', phaseId: 'phase-2', frequency: 'daily')];
      final result = JourneyLogic.getTodaysTasks(uj, phase, tasks);
      expect(result, isEmpty);
    });
  });

  group('day_offset phase trigger — pause-aware 21/40-day boundaries', () {
    test('a later phase does not unlock while the journey is paused, even if calendar time has passed', () {
      final uj = _journey(
        status: 'paused',
        startDate: DateTime(2026, 1, 1),
        pausedAt: DateTime(2026, 1, 6), // paused on day 5
      );
      final phases = [
        _phase('p0', phaseOrder: 0, triggerType: 'immediate'),
        _phase('p1', phaseOrder: 1, triggerType: 'day_offset', triggerValue: {'days': 21}),
      ];
      // Real time has advanced well past day 21, but the journey paused on day 5.
      final current = JourneyLogic.getCurrentPhase(uj, phases, now: DateTime(2026, 3, 1));
      expect(current?.id, 'p0');
    });

    test('day-21 phase unlocks once effective elapsed active days reach 21', () {
      final uj = _journey(startDate: DateTime(2026, 1, 1));
      final phases = [
        _phase('p0', phaseOrder: 0, triggerType: 'immediate'),
        _phase('p1', phaseOrder: 1, triggerType: 'day_offset', triggerValue: {'days': 21}),
      ];
      final current = JourneyLogic.getCurrentPhase(uj, phases, now: DateTime(2026, 1, 22));
      expect(current?.id, 'p1');
    });

    test('day-40 boundary: still on the prior phase on day 39, advances on day 40', () {
      final uj = _journey(startDate: DateTime(2026, 1, 1));
      final phases = [
        _phase('p0', phaseOrder: 0, triggerType: 'immediate'),
        _phase('p1', phaseOrder: 1, triggerType: 'day_offset', triggerValue: {'days': 40}),
      ];
      final day39 = JourneyLogic.getCurrentPhase(uj, phases, now: DateTime(2026, 2, 9));
      expect(day39?.id, 'p0');
      final day40 = JourneyLogic.getCurrentPhase(uj, phases, now: DateTime(2026, 2, 10));
      expect(day40?.id, 'p1');
    });

    test('pause then resume: paused span is excluded, so the boundary shifts forward by the pause length', () {
      // Started Jan 1 (day 0), paused on day 5 (Jan 6), resumed on day 10
      // (Jan 11) -> 5 days paused. A day-21 trigger normally fires on
      // calendar day 21 (Jan 22); with 5 days excluded it must instead wait
      // until calendar day 26 (Jan 27, i.e. 21 + 5 days later in real time).
      final uj = _journey(
        startDate: DateTime(2026, 1, 1),
        pausedAt: DateTime(2026, 1, 6),
        resumedAt: DateTime(2026, 1, 11),
      );
      final phases = [
        _phase('p0', phaseOrder: 0, triggerType: 'immediate'),
        _phase('p1', phaseOrder: 1, triggerType: 'day_offset', triggerValue: {'days': 21}),
      ];
      // Calendar day 25 (Jan 26) -> effective day 20 (25 - 5 paused): not yet.
      final beforeShiftedBoundary =
          JourneyLogic.getCurrentPhase(uj, phases, now: DateTime(2026, 1, 26));
      expect(beforeShiftedBoundary?.id, 'p0');
      // Calendar day 26 (Jan 27) -> effective day 21 (26 - 5 paused): unlocks.
      final atShiftedBoundary =
          JourneyLogic.getCurrentPhase(uj, phases, now: DateTime(2026, 1, 27));
      expect(atShiftedBoundary?.id, 'p1');
    });
  });

  group('taskCompletionBlockedReason — duplicate completion cannot duplicate rewards', () {
    final phase = _phase('phase-1');
    final uj = _journey(startDate: DateTime(2026, 1, 1));

    test('once task already completed (any day) is blocked even if not in today\'s set', () {
      final task = _task('t-once', frequency: 'once');
      final reason = JourneyLogic.taskCompletionBlockedReason(
        userJourney: uj,
        task: task,
        calendarPhase: phase,
        allTasks: [task],
        completedTaskIdsToday: {}, // empty: not completed *today*
        completedOnceTaskIds: {'t-once'}, // but completed previously
      );
      expect(reason, isNotNull);
    });

    test('weekly task already completed this week is blocked', () {
      final task = _task('t-weekly', frequency: 'weekly');
      final reason = JourneyLogic.taskCompletionBlockedReason(
        userJourney: uj,
        task: task,
        calendarPhase: phase,
        allTasks: [task],
        completedTaskIdsToday: {},
        completedThisWeekTaskIds: {'t-weekly'},
      );
      expect(reason, isNotNull);
    });

    test('daily task with no completion history is allowed', () {
      final task = _task('t-daily', frequency: 'daily');
      final reason = JourneyLogic.taskCompletionBlockedReason(
        userJourney: uj,
        task: task,
        calendarPhase: phase,
        allTasks: [task],
        completedTaskIdsToday: {},
      );
      expect(reason, isNull);
    });

    test('a completed journey blocks all completion regardless of frequency', () {
      final completedJourney = _journey(status: 'completed', startDate: DateTime(2026, 1, 1));
      final task = _task('t-daily', frequency: 'daily');
      final reason = JourneyLogic.taskCompletionBlockedReason(
        userJourney: completedJourney,
        task: task,
        calendarPhase: phase,
        allTasks: [task],
        completedTaskIdsToday: {},
      );
      expect(reason, isNotNull);
    });

    test('a paused journey blocks completion (resume required)', () {
      final pausedJourney = _journey(
        status: 'paused',
        startDate: DateTime(2026, 1, 1),
        pausedAt: DateTime(2026, 1, 5),
      );
      final task = _task('t-daily', frequency: 'daily');
      final reason = JourneyLogic.taskCompletionBlockedReason(
        userJourney: pausedJourney,
        task: task,
        calendarPhase: phase,
        allTasks: [task],
        completedTaskIdsToday: {},
      );
      expect(reason, isNotNull);
    });
  });
}
