import '../../../../core/services/supabase_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/quest_stage_model.dart';

class SupabaseQuestStageDataSource {
  final SupabaseService _supabase = SupabaseService();

  /// Fetch all quest stages for a parva
  Future<List<QuestStageModel>> getStagesForParva(int parvaId) async {
    if (!_supabase.isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.questStagesTable)
          .select()
          .eq('parva_id', parvaId)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => QuestStageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching quest stages from Supabase: $e');
      rethrow;
    }
  }

  /// Get user's progress for a quest stage
  Future<QuestStageStatus?> getUserStageStatus(
      String stageId, String userId) async {
    if (!_supabase.isInitialized) {
      return null;
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.userProgressTable)
          .select('status')
          .eq('user_id', userId)
          .eq('stage_id', stageId)
          .maybeSingle();

      if (response != null) {
        return QuestStageStatus.values.firstWhere(
          (e) => e.name == response['status'],
          orElse: () => QuestStageStatus.locked,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching user stage status: $e');
      return null;
    }
  }
}
