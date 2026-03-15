import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/journey_logic.dart';
import '../../data/models/journey_models.dart';
import '../../data/repositories/journey_repository.dart';

// ─── Repository ───────────────────────────────────────────────────────────

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  return JourneyRepository();
});

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

// ─── User journeys ──────────────────────────────────────────────────────────

final activeJourneyProvider = FutureProvider<UserJourney?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;
  final repo = ref.watch(journeyRepositoryProvider);
  return repo.getActiveJourney(uid);
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
