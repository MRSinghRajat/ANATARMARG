import '../../../../core/services/supabase_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/parva_model.dart';

class SupabaseParvaDataSource {
  final SupabaseService _supabase = SupabaseService();

  /// Fetch all parvas from Supabase
  Future<List<ParvaModel>> getAllParvas() async {
    if (!_supabase.isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.parvasTable)
          .select()
          .order('id', ascending: true);

      return (response as List)
          .map((json) => ParvaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching parvas from Supabase: $e');
      rethrow;
    }
  }

  /// Fetch a single parva by ID
  Future<ParvaModel?> getParvaById(int parvaId) async {
    if (!_supabase.isInitialized) {
      throw Exception('Supabase not initialized');
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.parvasTable)
          .select()
          .eq('id', parvaId)
          .single();

      return ParvaModel.fromJson(response);
    } catch (e) {
      print('Error fetching parva $parvaId from Supabase: $e');
      return null;
    }
  }

  /// Get user's progress for a parva
  Future<ParvaStatus?> getUserParvaStatus(int parvaId, String userId) async {
    if (!_supabase.isInitialized) {
      return null;
    }

    try {
      final response = await _supabase.client!
          .from(SupabaseConfig.userParvaProgressTable)
          .select('status')
          .eq('user_id', userId)
          .eq('parva_id', parvaId)
          .maybeSingle();

      if (response != null) {
        return ParvaStatus.values.firstWhere(
          (e) => e.name == response['status'],
          orElse: () => ParvaStatus.locked,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching user parva status: $e');
      return null;
    }
  }
}
