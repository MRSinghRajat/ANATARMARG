import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feeling_suggestion_model.dart';

/// Saves user feeling selections and fetches weekday-based suggestions from Supabase.
class FeelingRepository {
  FeelingRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _logTable = 'user_feeling_log';
  static const String _suggestionsTable = 'feeling_weekday_suggestions';

  String? get _userId => _client.auth.currentUser?.id;

  /// Log that the user selected this feeling today. No-op if not logged in.
  Future<void> logFeeling(String feelingId) async {
    final uid = _userId;
    if (uid == null) return;

    try {
      final today = DateTime.now().toUtc();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _client.from(_logTable).insert({
        'user_id': uid,
        'feeling_id': feelingId,
        'logged_date': dateStr,
      });
    } catch (e) {
      print('FeelingRepository.logFeeling: $e');
    }
  }

  /// Get suggestion for this feeling and current weekday (1 = Monday .. 7 = Sunday).
  /// Returns null if not found or error.
  Future<FeelingSuggestion?> getSuggestionForFeelingAndWeekday(
    String feelingId,
    int weekday,
  ) async {
    try {
      final res = await _client
          .from(_suggestionsTable)
          .select()
          .eq('feeling_id', feelingId)
          .eq('weekday', weekday)
          .maybeSingle();

      if (res == null) return null;
      return FeelingSuggestion.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      print('FeelingRepository.getSuggestionForFeelingAndWeekday: $e');
      return null;
    }
  }
}
