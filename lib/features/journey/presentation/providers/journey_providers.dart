import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/journey_logic.dart';
import '../../data/models/journey_models.dart';
import '../../data/repositories/journey_repository.dart';

// ─── Repository ───────────────────────────────────────────────────────────

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  return JourneyRepository();
});

/// Selected journey phase on home (null = follow calendar [current] phase).
final journeyBrowsePhaseIdProvider =
    StateProvider.family<String?, String>((ref, userJourneyId) => null);

// ─── Auth (current user id) ─────────────────────────────────────────────────

final currentUserIdProvider = Provider<String?>((ref) {
  return Supabase.instance.client.auth.currentUser?.id;
});

// ─── Catalog ────────────────────────────────────────────────────────────────

final journeyTypesProvider = FutureProvider<List<JourneyType>>((ref) async {
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.getJourneyTypes();
});

final journeyTypeBySlugProvider =
    FutureProvider.family<JourneyType?, String>((ref, slug) async {
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.getJourneyTypeBySlug(slug);
});

/// Member counts per journey type (for "Joined by X" in Journey tab).
final journeyTypeMemberCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.getJourneyTypeMemberCounts();
});

/// Tasks for a journey (from v_journey_tasks_full view), keyed by journey_type_id.
/// Phase info is embedded in each task.
final journeyTasksProvider =
    FutureProvider.family<List<JourneyTask>, String>((ref, journeyTypeId) async {
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.getTasksByJourneyTypeId(journeyTypeId);
});

final journeyMilestonesProvider =
    FutureProvider.family<List<JourneyMilestone>, String>((ref, journeyTypeId) async {
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.getMilestones(journeyTypeId);
});

/// Milestone completion dates (milestoneId -> completedAt) for journey home UI.
final completedMilestoneDatesProvider =
    FutureProvider.family<Map<String, DateTime>, String>((ref, userJourneyId) async {
  final journey = await ref.watch(userJourneyProvider(userJourneyId).future);
  if (journey == null) return {};
  final repo = ref.read(journeyRepositoryProvider);
  return repo.getCompletedMilestoneDates(journey.userId, userJourneyId);
});

/// Completed milestone row IDs for this user journey (carousel / checklist).
/// Must be a top-level provider — never instantiate FutureProvider inside build().
final journeyCompletedMilestoneIdsProvider =
    FutureProvider.family<List<String>, String>((ref, userJourneyId) async {
  final journey = await ref.watch(userJourneyProvider(userJourneyId).future);
  if (journey == null) return [];
  final repo = ref.read(journeyRepositoryProvider);
  return repo.getCompletedMilestoneIds(journey.userId, userJourneyId);
});

// ─── User journeys ──────────────────────────────────────────────────────────

final activeJourneyProvider = FutureProvider<UserJourney?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;
  final repo = ref.watch(journeyRepositoryProvider);
  // getActiveJourney uses .limit(1) internally to avoid throw when multiple
  // active journeys exist (allowed since migration 25).
  return repo.getActiveJourney(uid);
});

/// All journeys with status `active` — users may run several journey types in parallel.
final activeJourneysProvider = FutureProvider<List<UserJourney>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return [];
  final repo = ref.watch(journeyRepositoryProvider);
  final all = await repo.getAllJourneys(uid);
  return all.where((j) => j.isActive).toList();
});

final allUserJourneysProvider = FutureProvider<List<UserJourney>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return [];
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.getAllJourneys(uid);
});

final userJourneyProvider =
    FutureProvider.family<UserJourney?, String>((ref, userJourneyId) async {
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.getUserJourneyById(userJourneyId);
});

// ─── Derived: current phase (computed from tasks view data) ─────────────────

final currentPhaseProvider =
    FutureProvider.family<JourneyPhase?, String>((ref, userJourneyId) async {
  final repo = ref.watch(journeyRepositoryProvider);
  final journey = await repo.getUserJourneyById(userJourneyId);
  if (journey == null) return null;
  final tasks = await repo.getTasksByJourneyTypeId(journey.journeyTypeId);
  if (tasks.isEmpty) return null;
  return JourneyLogic.getCurrentPhaseFromTasks(journey, tasks);
});

// ─── Phases extracted from tasks (for phase chips UI) ───────────────────────

final journeyPhasesFromTasksProvider =
    FutureProvider.family<List<JourneyPhase>, String>((ref, journeyTypeId) async {
  final tasks = await ref.watch(journeyTasksProvider(journeyTypeId).future);
  return JourneyLogic.extractPhases(tasks);
});

// ─── Today's journey tasks with completion status ───────────────────────────

final todaysJourneyTasksProvider =
    FutureProvider.family<List<JourneyTaskWithCompletion>, String>((ref, userJourneyId) async {
  final repo = ref.watch(journeyRepositoryProvider);
  final journey = await repo.getUserJourneyById(userJourneyId);
  if (journey == null) return [];
  final allTasks = await repo.getTasksByJourneyTypeId(journey.journeyTypeId);
  if (allTasks.isEmpty) return [];
  final currentPhase = JourneyLogic.getCurrentPhaseFromTasks(journey, allTasks);
  if (currentPhase == null) return [];
  final todaysTasks = JourneyLogic.getTodaysTasks(journey, currentPhase, allTasks);
  final completedIds = await repo.getCompletedTaskIdsToday(journey.userId, userJourneyId);
  final completedSet = completedIds.toSet();
  return todaysTasks
      .map((t) => JourneyTaskWithCompletion(
            task: t,
            isCompleted: completedSet.contains(t.id),
          ))
      .toList();
});

/// Task IDs completed today for this user journey (local calendar date).
final journeyCompletedTaskIdsTodayProvider =
    FutureProvider.family<Set<String>, String>((ref, userJourneyId) async {
  final journey = await ref.watch(userJourneyProvider(userJourneyId).future);
  if (journey == null) return {};
  final repo = ref.read(journeyRepositoryProvider);
  final ids = await repo.getCompletedTaskIdsToday(journey.userId, userJourneyId);
  return ids.toSet();
});

/// Daily task list for home: calendar phase when browse is null, else selected phase (preview).
final displayedJourneyTasksProvider =
    FutureProvider.family<List<JourneyTaskWithCompletion>, String>((ref, userJourneyId) async {
  final repo = ref.watch(journeyRepositoryProvider);
  final journey = await repo.getUserJourneyById(userJourneyId);
  if (journey == null) return [];
  final allTasks = await repo.getTasksByJourneyTypeId(journey.journeyTypeId);
  if (allTasks.isEmpty) return [];
  final phases = JourneyLogic.extractPhases(allTasks);
  final calendarPhase = JourneyLogic.getCurrentPhase(journey, phases);
  final browseId = ref.watch(journeyBrowsePhaseIdProvider(userJourneyId));
  JourneyPhase? displayPhase;
  if (browseId != null) {
    for (final p in phases) {
      if (p.id == browseId) {
        displayPhase = p;
        break;
      }
    }
    displayPhase ??= calendarPhase;
  } else {
    displayPhase = calendarPhase;
  }
  if (displayPhase == null) return [];
  final tasks = JourneyLogic.getTasksForDisplayedPhase(
    journey,
    displayPhase,
    calendarPhase,
    allTasks,
  );
  final completedSet =
      await ref.watch(journeyCompletedTaskIdsTodayProvider(userJourneyId).future);
  return tasks
      .map((t) => JourneyTaskWithCompletion(
            task: t,
            isCompleted: completedSet.contains(t.id),
          ))
      .toList();
});

/// All tasks for the journey type, with today's completion (Ashram active journey shows full list).
final allJourneyTasksWithTodayCompletionProvider =
    FutureProvider.family<List<JourneyTaskWithCompletion>, String>((ref, userJourneyId) async {
  final repo = ref.watch(journeyRepositoryProvider);
  final journey = await repo.getUserJourneyById(userJourneyId);
  if (journey == null) return [];
  final allTasks = await repo.getTasksByJourneyTypeId(journey.journeyTypeId);
  if (allTasks.isEmpty) return [];
  final completedIds = await repo.getCompletedTaskIdsToday(journey.userId, userJourneyId);
  final completedSet = completedIds.toSet();
  return allTasks
      .map((t) => JourneyTaskWithCompletion(
            task: t,
            isCompleted: completedSet.contains(t.id),
          ))
      .toList();
});

// ─── Content for a task (from v_journey_content_resolved) ───────────────────

class TaskContentParams {
  final String journeyTypeId;
  final String taskSlug;
  final int? ageDays;
  final String gender;

  const TaskContentParams({
    required this.journeyTypeId,
    required this.taskSlug,
    this.ageDays,
    this.gender = 'both',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskContentParams &&
          journeyTypeId == other.journeyTypeId &&
          taskSlug == other.taskSlug &&
          ageDays == other.ageDays &&
          gender == other.gender;

  @override
  int get hashCode => Object.hash(journeyTypeId, taskSlug, ageDays, gender);
}

final taskContentProvider =
    FutureProvider.family<List<JourneyContentItem>, TaskContentParams>((ref, params) async {
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.getContentForTask(
    journeyTypeId: params.journeyTypeId,
    taskSlug: params.taskSlug,
    ageDays: params.ageDays,
    gender: params.gender,
  );
});

/// Content pool from journey_content_pool table (Layer 3) by task_slug.
/// Use when v_journey_content_resolved is empty; pick one via JourneyRepository.pickFromPool.
final contentPoolByTaskSlugProvider =
    FutureProvider.family<List<Map<String, dynamic>>, ContentPoolParams>((ref, params) async {
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.getContentPoolByTaskSlug(params.taskSlug, journeyTypeId: params.journeyTypeId);
});

class ContentPoolParams {
  final String taskSlug;
  final String? journeyTypeId;

  const ContentPoolParams({required this.taskSlug, this.journeyTypeId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentPoolParams &&
          taskSlug == other.taskSlug &&
          journeyTypeId == other.journeyTypeId;

  @override
  int get hashCode => Object.hash(taskSlug, journeyTypeId);
}

/// Resolved polymorphic content for a task (Garbh Sanskar: content_type + content_ref).
/// Use when task.contentType and task.contentRef are set.
final resolvedTaskContentProvider =
    FutureProvider.family<Map<String, dynamic>?, ResolvedTaskContentParams>((ref, params) async {
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.resolveTaskContent(params.contentType, params.contentRef);
});

class ResolvedTaskContentParams {
  final String? contentType;
  final String? contentRef;

  const ResolvedTaskContentParams({this.contentType, this.contentRef});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvedTaskContentParams &&
          contentType == other.contentType &&
          contentRef == other.contentRef;

  @override
  int get hashCode => Object.hash(contentType, contentRef);
}

// ─── Daily Wisdom — rotates by journey day, scoped per journey type ──────────
//
// Queries journey_content_pool WHERE category = 'wisdom' AND journey_type_id = ?
// Works identically for every journey type — just insert rows with that type's id.

final wisdomForJourneyProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, userJourneyId) async {
  final journey = await ref.watch(userJourneyProvider(userJourneyId).future);
  if (journey == null) return null;
  final repo = ref.read(journeyRepositoryProvider);
  final pool = await repo.getWisdomPool(journey.journeyTypeId);
  if (pool.isEmpty) return null;
  final start = journey.startDate ?? DateTime.now();
  final dayOfJourney = DateTime.now().difference(start).inDays.clamp(0, 999999);
  return pool[dayOfJourney % pool.length];
});

/// After [JourneyRepository.deleteJourney], clear every provider cache keyed by [userJourneyId]
/// so nothing keeps a stale [UserJourney] or task/milestone state. Prefer calling from a
/// [WidgetsBinding.instance.addPostFrameCallback] after navigating away from journey routes.
void invalidateCachesForDeletedUserJourney(
  ProviderContainer container,
  String userJourneyId,
) {
  container.invalidate(journeyBrowsePhaseIdProvider(userJourneyId));
  container.invalidate(userJourneyProvider(userJourneyId));
  container.invalidate(todaysJourneyTasksProvider(userJourneyId));
  container.invalidate(displayedJourneyTasksProvider(userJourneyId));
  container.invalidate(journeyCompletedTaskIdsTodayProvider(userJourneyId));
  container.invalidate(currentPhaseProvider(userJourneyId));
  container.invalidate(journeyCompletedMilestoneIdsProvider(userJourneyId));
  container.invalidate(completedMilestoneDatesProvider(userJourneyId));
  container.invalidate(allJourneyTasksWithTodayCompletionProvider(userJourneyId));
  container.invalidate(wisdomForJourneyProvider(userJourneyId));
  container.invalidate(activeJourneyProvider);
  container.invalidate(activeJourneysProvider);
  container.invalidate(allUserJourneysProvider);
}
