import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/garbh_sanskar_models.dart';

/// Repository for all Garbh Sanskar data operations
class GarbhSanskarRepository {
  final SupabaseClient _supabase;

  GarbhSanskarRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  // ============================================================
  // PREGNANCY JOURNEY
  // ============================================================

  /// Get the current user's pregnancy journey
  Future<UserPregnancyJourney?> getJourney() async {
    if (_userId == null) return null;
    try {
      final response = await _supabase
          .from('user_pregnancy_journey')
          .select()
          .eq('user_id', _userId!)
          .maybeSingle();
      if (response == null) return null;
      return UserPregnancyJourney.fromJson(response);
    } catch (e) {
      print('GarbhSanskarRepository.getJourney error: $e');
      return null;
    }
  }

  /// Create or update the pregnancy journey
  Future<UserPregnancyJourney?> upsertJourney(
      UserPregnancyJourney journey) async {
    if (_userId == null) return null;
    try {
      final data = journey.toJson();
      data['user_id'] = _userId!;

      final response = await _supabase
          .from('user_pregnancy_journey')
          .upsert(data, onConflict: 'user_id')
          .select()
          .single();
      return UserPregnancyJourney.fromJson(response);
    } catch (e) {
      print('GarbhSanskarRepository.upsertJourney error: $e');
      return null;
    }
  }

  /// Delete the current user's pregnancy journey
  Future<bool> deleteJourney() async {
    if (_userId == null) return false;
    try {
      await _supabase
          .from('user_pregnancy_journey')
          .delete()
          .eq('user_id', _userId!);
      return true;
    } catch (e) {
      print('GarbhSanskarRepository.deleteJourney error: $e');
      return false;
    }
  }

  /// Switch to postnatal mode after birth
  Future<bool> switchToPostnatal(DateTime birthDate, {String? babyName}) async {
    if (_userId == null) return false;
    try {
      await _supabase.from('user_pregnancy_journey').update({
        'mode': 'postnatal',
        'birth_date': birthDate.toIso8601String().split('T')[0],
        if (babyName != null) 'baby_name': babyName,
      }).eq('user_id', _userId!);
      return true;
    } catch (e) {
      print('GarbhSanskarRepository.switchToPostnatal error: $e');
      return false;
    }
  }

  // ============================================================
  // CONTENT
  // ============================================================

  /// Get all content for a given phase
  Future<List<GarbhSanskarContent>> getContentByPhase(String phase) async {
    try {
      final response = await _supabase
          .from('garbh_sanskar_content')
          .select()
          .or('phase.eq.$phase,phase.eq.all')
          .eq('is_active', true)
          .order('order_index');
      return (response as List)
          .map((json) => GarbhSanskarContent.fromJson(json))
          .toList();
    } catch (e) {
      print('GarbhSanskarRepository.getContentByPhase error: $e');
      return [];
    }
  }

  /// Get content for a specific week
  Future<List<GarbhSanskarContent>> getContentForWeek(int week) async {
    try {
      final response = await _supabase
          .from('garbh_sanskar_content')
          .select()
          .eq('phase', 'prenatal')
          .eq('is_active', true)
          .or('week_start.is.null,week_start.lte.$week')
          .or('week_end.is.null,week_end.gte.$week')
          .order('order_index');
      return (response as List)
          .map((json) => GarbhSanskarContent.fromJson(json))
          .toList();
    } catch (e) {
      print('GarbhSanskarRepository.getContentForWeek error: $e');
      return [];
    }
  }

  /// Get content by type
  Future<List<GarbhSanskarContent>> getContentByType(
      String phase, String contentType) async {
    try {
      final response = await _supabase
          .from('garbh_sanskar_content')
          .select()
          .or('phase.eq.$phase,phase.eq.all')
          .eq('content_type', contentType)
          .eq('is_active', true)
          .order('order_index');
      return (response as List)
          .map((json) => GarbhSanskarContent.fromJson(json))
          .toList();
    } catch (e) {
      print('GarbhSanskarRepository.getContentByType error: $e');
      return [];
    }
  }

  // ============================================================
  // SAMSKARAS
  // ============================================================

  /// Get all prenatal Samskaras
  Future<List<GarbhSamskara>> getPrenatalSamskaras() async {
    try {
      final response = await _supabase
          .from('garbh_sanskar_samskaras')
          .select()
          .order('order_index');
      return (response as List)
          .map((json) => GarbhSamskara.fromJson(json, 'prenatal'))
          .toList();
    } catch (e) {
      print('GarbhSanskarRepository.getPrenatalSamskaras error: $e');
      return [];
    }
  }

  /// Get all postnatal Samskaras
  Future<List<GarbhSamskara>> getPostnatalSamskaras() async {
    try {
      final response = await _supabase
          .from('postnatal_samskaras')
          .select()
          .order('order_index');
      return (response as List)
          .map((json) => GarbhSamskara.fromJson(json, 'postnatal'))
          .toList();
    } catch (e) {
      print('GarbhSanskarRepository.getPostnatalSamskaras error: $e');
      return [];
    }
  }

  /// Mark a Samskara as completed
  Future<bool> completeSamskara({
    required String samskaraType,
    required int samskaraId,
    DateTime? completedDate,
    String? notes,
  }) async {
    if (_userId == null) return false;
    try {
      await _supabase.from('user_samskara_completions').upsert({
        'user_id': _userId!,
        'samskara_type': samskaraType,
        'samskara_id': samskaraId,
        'completed_date': (completedDate ?? DateTime.now())
            .toIso8601String()
            .split('T')[0],
        if (notes != null) 'notes': notes,
        'coins_earned': 25,
      }, onConflict: 'user_id,samskara_type,samskara_id');
      return true;
    } catch (e) {
      print('GarbhSanskarRepository.completeSamskara error: $e');
      return false;
    }
  }

  /// Get completed Samskaras for current user
  Future<List<Map<String, dynamic>>> getCompletedSamskaras() async {
    if (_userId == null) return [];
    try {
      final response = await _supabase
          .from('user_samskara_completions')
          .select()
          .eq('user_id', _userId!);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('GarbhSanskarRepository.getCompletedSamskaras error: $e');
      return [];
    }
  }

  // ============================================================
  // LULLABIES
  // ============================================================

  /// Get all active lullabies
  Future<List<Lullaby>> getLullabies() async {
    try {
      final response = await _supabase
          .from('lullabies')
          .select()
          .eq('is_active', true)
          .order('order_index');
      return (response as List)
          .map((json) => Lullaby.fromJson(json))
          .toList();
    } catch (e) {
      print('GarbhSanskarRepository.getLullabies error: $e');
      return [];
    }
  }

  // ============================================================
  // USER PROGRESS
  // ============================================================

  /// Mark content as started
  Future<void> startContent(String contentId) async {
    if (_userId == null) return;
    try {
      await _supabase.from('user_gs_content_progress').upsert({
        'user_id': _userId!,
        'content_id': contentId,
        'status': 'started',
      }, onConflict: 'user_id,content_id');
    } catch (e) {
      print('GarbhSanskarRepository.startContent error: $e');
    }
  }

  /// Mark content as completed and award coins
  Future<int> completeContent(
      String contentId, int listenDurationSeconds, int coinsReward) async {
    if (_userId == null) return 0;
    try {
      await _supabase.from('user_gs_content_progress').upsert({
        'user_id': _userId!,
        'content_id': contentId,
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
        'listen_duration_seconds': listenDurationSeconds,
        'coins_earned': coinsReward,
      }, onConflict: 'user_id,content_id');

      // Update journey stats
      await _supabase.rpc('increment_gs_stats', params: {
        'p_user_id': _userId!,
        'p_sessions': 1,
        'p_minutes': listenDurationSeconds ~/ 60,
      }).catchError((_) => null); // Non-critical

      return coinsReward;
    } catch (e) {
      print('GarbhSanskarRepository.completeContent error: $e');
      return 0;
    }
  }

  /// Get all completed content IDs for current user
  Future<Set<String>> getCompletedContentIds() async {
    if (_userId == null) return {};
    try {
      final response = await _supabase
          .from('user_gs_content_progress')
          .select('content_id')
          .eq('user_id', _userId!)
          .eq('status', 'completed');
      return (response as List)
          .map((r) => r['content_id'] as String)
          .toSet();
    } catch (e) {
      print('GarbhSanskarRepository.getCompletedContentIds error: $e');
      return {};
    }
  }

  // ============================================================
  // BABY MILESTONES
  // ============================================================

  /// Get all milestones for current user
  Future<List<BabyMilestone>> getMilestones() async {
    if (_userId == null) return [];
    try {
      final response = await _supabase
          .from('baby_milestones')
          .select()
          .eq('user_id', _userId!)
          .order('milestone_date', ascending: false);
      return (response as List)
          .map((json) => BabyMilestone.fromJson(json))
          .toList();
    } catch (e) {
      print('GarbhSanskarRepository.getMilestones error: $e');
      return [];
    }
  }

  /// Add a new milestone
  Future<bool> addMilestone({
    required String milestoneType,
    required DateTime milestoneDate,
    int? babyAgeDays,
    String? notes,
  }) async {
    if (_userId == null) return false;
    try {
      await _supabase.from('baby_milestones').insert({
        'user_id': _userId!,
        'milestone_type': milestoneType,
        'milestone_date': milestoneDate.toIso8601String().split('T')[0],
        if (babyAgeDays != null) 'baby_age_days': babyAgeDays,
        if (notes != null) 'notes': notes,
        'coins_earned': 10,
      });
      return true;
    } catch (e) {
      print('GarbhSanskarRepository.addMilestone error: $e');
      return false;
    }
  }

  // ============================================================
  // STORAGE URL HELPERS
  // ============================================================

  /// Get public URL for audio in the garbh-sanskar-audio bucket
  String? getAudioUrl(String? storagePath) {
    if (storagePath == null || storagePath.isEmpty) return null;
    try {
      return _supabase.storage
          .from('garbh-sanskar-audio')
          .getPublicUrl(storagePath);
    } catch (e) {
      return null;
    }
  }

  /// Get public URL for lullaby audio
  String? getLullabyAudioUrl(String? storagePath) {
    if (storagePath == null || storagePath.isEmpty) return null;
    try {
      return _supabase.storage
          .from('lullabies')
          .getPublicUrl(storagePath);
    } catch (e) {
      return null;
    }
  }
}
