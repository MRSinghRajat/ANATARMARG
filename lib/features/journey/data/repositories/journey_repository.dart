import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/journey_models.dart';

/// Repository for journey catalog, user journeys, and completions.
///
/// Reporting / profile: use [getAllJourneys], task rows in `user_journey_task_completions`,
/// and samskara rows in `user_milestone_completions` (plus milestone `is_required` from catalog).
class JourneyRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─── Catalog ─────────────────────────────────────────────────────────────

  Future<List<JourneyType>> getJourneyTypes() async {
    try {
      final res = await _supabase
          .from('journey_types')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);
      final list = res as List;
      return list.map((e) => JourneyType.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('JourneyRepository.getJourneyTypes: $e');
      return [];
    }
  }

  Future<JourneyType?> getJourneyTypeBySlug(String slug) async {
    try {
      final res = await _supabase
          .from('journey_types')
          .select()
          .eq('slug', slug)
          .eq('is_active', true)
          .maybeSingle();
      if (res == null) return null;
      return JourneyType.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      print('JourneyRepository.getJourneyTypeBySlug: $e');
      return null;
    }
  }

  /// Update card image URL for a journey type (e.g. for locked/Popular cards).
  /// Requires RLS policy allowing update on journey_types if used from app.
  Future<bool> updateJourneyTypeCardImage(String journeyTypeId, String? imageUrl) async {
    try {
      await _supabase
          .from('journey_types')
          .update({'card_image_url': imageUrl})
          .eq('id', journeyTypeId);
      return true;
    } catch (e) {
      print('JourneyRepository.updateJourneyTypeCardImage: $e');
      return false;
    }
  }

  /// Member count per journey type for "Joined by X" in Our Spiritual Circle.
  /// Uses get_journey_type_member_counts() RPC.
  Future<Map<String, int>> getJourneyTypeMemberCounts() async {
    try {
      final res = await _supabase.rpc('get_journey_type_member_counts');
      final list = res as List? ?? [];
      final map = <String, int>{};
      for (final e in list) {
        final row = e as Map<String, dynamic>;
        final id = row['journey_type_id']?.toString();
        final count = (row['member_count'] as num?)?.toInt() ?? 0;
        if (id != null) map[id] = count;
      }
      return map;
    } catch (e) {
      print('JourneyRepository.getJourneyTypeMemberCounts: $e');
      return {};
    }
  }

  /// Fetch tasks for a journey using the v_journey_tasks_full view.
  /// Returns tasks with phase info embedded — no need for separate getPhases().
  Future<List<JourneyTask>> getTasksForJourney(String journeySlug) async {
    try {
      final res = await _supabase
          .from('v_journey_tasks_full')
          .select()
          .eq('journey_slug', journeySlug)
          .order('phase_order', ascending: true)
          .order('display_order', ascending: true);
      final list = res as List;
      return list.map((e) => JourneyTask.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('JourneyRepository.getTasksForJourney: $e');
      return [];
    }
  }

  /// Fetch tasks by journey_type_id (for providers that have the ID, not the slug).
  Future<List<JourneyTask>> getTasksByJourneyTypeId(String journeyTypeId) async {
    try {
      final res = await _supabase
          .from('v_journey_tasks_full')
          .select()
          .eq('journey_type_id', journeyTypeId)
          .order('phase_order', ascending: true)
          .order('display_order', ascending: true);
      final list = res as List;
      return list.map((e) => JourneyTask.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('JourneyRepository.getTasksByJourneyTypeId: $e');
      return [];
    }
  }

  /// Fetch content pool by task_slug (Layer 3: journey_content_pool).
  /// Link: journey_tasks.slug = journey_content_pool.task_slug. Returns raw rows for universal rendering.
  Future<List<Map<String, dynamic>>> getContentPoolByTaskSlug(String taskSlug, {String? journeyTypeId}) async {
    try {
      var query = _supabase.from('journey_content_pool').select().eq('task_slug', taskSlug);
      if (journeyTypeId != null && journeyTypeId.isNotEmpty) {
        query = query.eq('journey_type_id', journeyTypeId);
      }
      final res = await query.order('display_order', ascending: true);
      final list = res as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      print('JourneyRepository.getContentPoolByTaskSlug: $e');
      return [];
    }
  }

  /// Pick one item from pool by rotation_type: sequential = day of journey % count, random = date-based seed.
  static Map<String, dynamic>? pickFromPool(
    List<Map<String, dynamic>> pool,
    DateTime? startDate,
    String rotationType,
  ) {
    if (pool.isEmpty) return null;
    if (pool.length == 1) return pool.first;
    final dayOfJourney = startDate != null
        ? DateTime.now().difference(startDate).inDays
        : DateTime.now().difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays;
    if (rotationType == 'random') {
      final seed = DateTime.now().year * 10000 + DateTime.now().month * 100 + DateTime.now().day;
      final index = seed % pool.length;
      return pool[index];
    }
    return pool[dayOfJourney % pool.length];
  }

  /// Fetch content for a specific task from v_journey_content_resolved.
  /// Filters by age and gender if provided.
  Future<List<JourneyContentItem>> getContentForTask({
    required String journeyTypeId,
    required String taskSlug,
    int? ageDays,
    String gender = 'both',
  }) async {
    try {
      var query = _supabase
          .from('v_journey_content_resolved')
          .select()
          .eq('journey_type_id', journeyTypeId)
          .eq('task_slug', taskSlug);

      if (ageDays != null) {
        query = query.lte('age_days_from', ageDays).gte('age_days_to', ageDays);
      }

      query = query.or('gender_target.eq.both,gender_target.eq.$gender');

      final res = await query.order('display_order', ascending: true);
      final list = res as List;
      return list.map((e) => JourneyContentItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('JourneyRepository.getContentForTask: $e');
      return [];
    }
  }

  Future<List<JourneyMilestone>> getMilestones(String journeyTypeId) async {
    try {
      final res = await _supabase
          .from('journey_milestones')
          .select()
          .eq('journey_type_id', journeyTypeId)
          .order('milestone_order', ascending: true);
      final list = res as List;
      return list.map((e) => JourneyMilestone.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('JourneyRepository.getMilestones: $e');
      return [];
    }
  }

  /// Wisdom pool rows (category = 'wisdom') for rotating Daily Wisdom card.
  /// Generic: works for any journey type — just insert rows with that type's id.
  Future<List<Map<String, dynamic>>> getWisdomPool(String journeyTypeId) async {
    try {
      final res = await _supabase
          .from('journey_content_pool')
          .select()
          .eq('journey_type_id', journeyTypeId)
          .eq('category', 'wisdom')
          .order('display_order', ascending: true);
      final list = res as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      print('JourneyRepository.getWisdomPool: $e');
      return [];
    }
  }

  // ─── User journeys ───────────────────────────────────────────────────────

  /// Returns the most recent active journey. Uses .limit(1) before .maybeSingle()
  /// so it never throws when multiple active journeys exist (allowed since migration 25).
  Future<UserJourney?> getActiveJourney(String userId) async {
    try {
      final res = await _supabase
          .from('user_journeys')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('start_date', ascending: false)
          .limit(1)
          .maybeSingle();
      if (res == null) return null;
      return UserJourney.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      print('JourneyRepository.getActiveJourney: $e');
      return null;
    }
  }

  Future<List<UserJourney>> getAllJourneys(String userId) async {
    try {
      final res = await _supabase
          .from('user_journeys')
          .select()
          .eq('user_id', userId)
          .order('start_date', ascending: false);
      final list = res as List;
      return list.map((e) => UserJourney.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('JourneyRepository.getAllJourneys: $e');
      return [];
    }
  }

  /// Active or paused journey for this catalog type (blocks starting the same journey again).
  Future<UserJourney?> getActiveOrPausedJourneyForType({
    required String userId,
    required String journeyTypeId,
  }) async {
    try {
      final res = await _supabase
          .from('user_journeys')
          .select()
          .eq('user_id', userId)
          .eq('journey_type_id', journeyTypeId)
          .inFilter('status', ['active', 'paused'])
          .order('start_date', ascending: false)
          .limit(1)
          .maybeSingle();
      if (res == null) return null;
      return UserJourney.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      print('JourneyRepository.getActiveOrPausedJourneyForType: $e');
      return null;
    }
  }

  Future<UserJourney?> getUserJourneyById(String userJourneyId) async {
    try {
      final res = await _supabase
          .from('user_journeys')
          .select()
          .eq('id', userJourneyId)
          .maybeSingle();
      if (res == null) return null;
      return UserJourney.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      print('JourneyRepository.getUserJourneyById: $e');
      return null;
    }
  }

  Future<UserJourney?> startJourney({
    required String userId,
    required String journeyTypeId,
    required Map<String, dynamic> metadata,
    DateTime? startDate,
    DateTime? targetDate,
  }) async {
    try {
      final insert = <String, dynamic>{
        'user_id': userId,
        'journey_type_id': journeyTypeId,
        'status': 'active',
        'metadata': metadata,
        'start_date': (startDate ?? DateTime.now()).toIso8601String().split('T').first,
        if (targetDate != null) 'target_date': targetDate.toIso8601String().split('T').first,
      };
      final res = await _supabase
          .from('user_journeys')
          .insert(insert)
          .select()
          .single();
      return UserJourney.fromJson(res as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      print('JourneyRepository.startJourney: $e');
      if (e.code == '23505' &&
          (e.message.contains('idx_one_active_journey_per_user'))) {
        throw StateError(
          'Your Supabase database still enforces only one active journey per user. '
          'Apply the migration '
          'supabase/migrations/20240101000040_drop_one_active_journey_per_user_constraint.sql '
          '(run `supabase db push` or execute that SQL in the SQL editor), then try again.',
        );
      }
      rethrow;
    } catch (e) {
      print('JourneyRepository.startJourney: $e');
      rethrow;
    }
  }

  Future<void> pauseJourney(String userJourneyId) async {
    try {
      await _supabase.from('user_journeys').update({
        'status': 'paused',
        'paused_at': DateTime.now().toIso8601String(),
      }).eq('id', userJourneyId);
    } catch (e) {
      print('JourneyRepository.pauseJourney: $e');
      rethrow;
    }
  }

  Future<void> resumeJourney(String userJourneyId) async {
    try {
      await _supabase.from('user_journeys').update({
        'status': 'active',
        'resumed_at': DateTime.now().toIso8601String(),
      }).eq('id', userJourneyId);
    } catch (e) {
      print('JourneyRepository.resumeJourney: $e');
      rethrow;
    }
  }

  Future<void> deleteJourney(String userJourneyId) async {
    try {
      await _supabase.from('user_journeys').delete().eq('id', userJourneyId);
    } catch (e) {
      print('JourneyRepository.deleteJourney: $e');
      rethrow;
    }
  }

  Future<void> updateCurrentPhase(String userJourneyId, String phaseId) async {
    try {
      await _supabase.from('user_journeys').update({
        'current_phase_id': phaseId,
      }).eq('id', userJourneyId);
    } catch (e) {
      print('JourneyRepository.updateCurrentPhase: $e');
      rethrow;
    }
  }

  // ─── Task completions ────────────────────────────────────────────────────

  Future<List<String>> getCompletedTaskIdsToday(String userId, String userJourneyId) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    try {
      final res = await _supabase
          .from('user_journey_task_completions')
          .select('task_id')
          .eq('user_id', userId)
          .eq('user_journey_id', userJourneyId)
          .eq('completed_date', today);
      final list = res as List;
      return list.map((e) => e['task_id'] as String).toList();
    } catch (e) {
      print('JourneyRepository.getCompletedTaskIdsToday: $e');
      return [];
    }
  }

  Future<void> completeTask({
    required String userId,
    required String userJourneyId,
    required String taskId,
    int? durationSeconds,
    int? mantraCountDone,
    String? notes,
    String? photoUrl,
    int? coinReward,
  }) async {
    final uj = await getUserJourneyById(userJourneyId);
    if (uj == null) {
      throw StateError('Journey not found');
    }
    if (uj.status == 'completed') {
      throw StateError('This journey is already complete');
    }
    if (uj.status != 'active') {
      throw StateError('Journey is not active');
    }
    if (uj.userId != userId) {
      throw StateError('Not authorized');
    }
    final today = DateTime.now().toIso8601String().split('T').first;
    try {
      await _supabase.from('user_journey_task_completions').upsert({
        'user_id': userId,
        'user_journey_id': userJourneyId,
        'task_id': taskId,
        'completed_date': today,
        'completed_at': DateTime.now().toIso8601String(),
        'duration_seconds': durationSeconds,
        'mantra_count_done': mantraCountDone,
        'notes': notes,
        'photo_url': photoUrl,
        'coins_earned': coinReward ?? 0,
      }, onConflict: 'user_id,task_id,completed_date');
    } catch (e) {
      print('JourneyRepository.completeTask: $e');
      rethrow;
    }
  }

  /// Removes today's completion row so the user can mark the task again the same day.
  Future<void> uncompleteTaskToday({
    required String userId,
    required String userJourneyId,
    required String taskId,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    try {
      await _supabase
          .from('user_journey_task_completions')
          .delete()
          .eq('user_id', userId)
          .eq('user_journey_id', userJourneyId)
          .eq('task_id', taskId)
          .eq('completed_date', today);
    } catch (e) {
      print('JourneyRepository.uncompleteTaskToday: $e');
      rethrow;
    }
  }

  // ─── Milestone completions ───────────────────────────────────────────────

  Future<List<String>> getCompletedMilestoneIds(String userId, String userJourneyId) async {
    try {
      final res = await _supabase
          .from('user_milestone_completions')
          .select('milestone_id')
          .eq('user_id', userId)
          .eq('user_journey_id', userJourneyId);
      final list = res as List;
      return list.map((e) => e['milestone_id'] as String).toList();
    } catch (e) {
      print('JourneyRepository.getCompletedMilestoneIds: $e');
      return [];
    }
  }

  /// Returns milestoneId -> completedAt for showing completion dates in UI.
  Future<Map<String, DateTime>> getCompletedMilestoneDates(String userId, String userJourneyId) async {
    try {
      final res = await _supabase
          .from('user_milestone_completions')
          .select('milestone_id, completed_at')
          .eq('user_id', userId)
          .eq('user_journey_id', userJourneyId);
      final list = res as List;
      final map = <String, DateTime>{};
      for (final e in list) {
        final row = e as Map<String, dynamic>;
        final id = row['milestone_id'] as String?;
        final at = row['completed_at'] as String?;
        if (id != null && at != null) {
          final dt = DateTime.tryParse(at);
          if (dt != null) map[id] = dt;
        }
      }
      return map;
    } catch (e) {
      print('JourneyRepository.getCompletedMilestoneDates: $e');
      return {};
    }
  }

  Future<void> completeMilestone({
    required String userId,
    required String userJourneyId,
    required String milestoneId,
    String? notes,
    String? photoUrl,
    int? coinsEarned,
  }) async {
    final uj = await getUserJourneyById(userJourneyId);
    if (uj == null) {
      throw StateError('Journey not found');
    }
    if (uj.status == 'completed') {
      throw StateError('This journey is already complete');
    }
    if (uj.status != 'active') {
      throw StateError('Journey is not active');
    }
    if (uj.userId != userId) {
      throw StateError('Not authorized');
    }
    try {
      await _supabase.from('user_milestone_completions').insert({
        'user_id': userId,
        'user_journey_id': userJourneyId,
        'milestone_id': milestoneId,
        'completed_at': DateTime.now().toIso8601String(),
        'notes': notes,
        'photo_url': photoUrl,
        'coins_earned': coinsEarned ?? 0,
      });
    } catch (e) {
      print('JourneyRepository.completeMilestone: $e');
      rethrow;
    }
  }

  /// Dynamically resolves content for ANY task based on content_type.
  /// Journey-agnostic: map content_type to table name and fetch by content_ref.
  /// Samskara tables use integer IDs; all others use UUID (string).
  /// When content_type is null but content_ref is set (e.g. view omits type), tries garbh_sanskar_content first.
  Future<Map<String, dynamic>?> resolveTaskContent(String? contentType, dynamic contentRef) async {
    if (contentRef == null) return null;
    final refStr = contentRef.toString().trim();
    if (refStr.isEmpty) return null;

    final type = contentType?.trim();
    String? tableName;
    if (type != null && type.isNotEmpty) {
      switch (type) {
      case 'garbh_sanskar_content':
        tableName = 'garbh_sanskar_content';
        break;
      case 'garbh_sanskar_samskara':
        tableName = 'garbh_sanskar_samskaras';
        break;
      case 'postnatal_samskara':
        tableName = 'postnatal_samskaras';
        break;
      case 'lullaby':
        tableName = 'lullabies';
        break;
      case 'sacred_story':
        tableName = 'sacred_stories';
        break;
      case 'meditation_guide':
        tableName = 'meditation_guides';
        break;
      case 'audio_chant':
        tableName = 'audio_chants';
        break;
      default:
        if (type.isNotEmpty) {
          print('JourneyRepository.resolveTaskContent: unknown content_type: $type');
        }
        return null;
      }
    } else {
      // content_type missing (e.g. view doesn't expose it): try garbh_sanskar_content by UUID for Garbh Sanskar tasks
      if (_isValidUuid(refStr)) {
        tableName = 'garbh_sanskar_content';
      } else {
        return null;
      }
    }

    dynamic parsedId = refStr;
    if (tableName == 'garbh_sanskar_samskaras' || tableName == 'postnatal_samskaras') {
      parsedId = int.tryParse(refStr);
      if (parsedId == null) return null;
    }

    try {
      final res = await _supabase
          .from(tableName)
          .select()
          .eq('id', parsedId)
          .maybeSingle();
      return res as Map<String, dynamic>?;
    } catch (e) {
      print('JourneyRepository.resolveTaskContent ($tableName id=$parsedId): $e');
      return null;
    }
  }

  static final _uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  static bool _isValidUuid(String s) => s.length == 36 && _uuidRegex.hasMatch(s);

  /// Fetch a single task by id from the view.
  Future<JourneyTask?> getTaskById(String taskId) async {
    try {
      final res = await _supabase
          .from('v_journey_tasks_full')
          .select()
          .eq('id', taskId)
          .maybeSingle();
      if (res == null) return null;
      return JourneyTask.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      print('JourneyRepository.getTaskById: $e');
      return null;
    }
  }

  /// Fetch a single milestone by id.
  Future<JourneyMilestone?> getMilestoneById(String milestoneId) async {
    try {
      final res = await _supabase
          .from('journey_milestones')
          .select()
          .eq('id', milestoneId)
          .maybeSingle();
      if (res == null) return null;
      return JourneyMilestone.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      print('JourneyRepository.getMilestoneById: $e');
      return null;
    }
  }
}
