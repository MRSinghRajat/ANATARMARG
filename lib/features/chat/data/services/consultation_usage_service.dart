import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/services/feature_gate_config.dart';
import '../../../../shared/services/premium_service.dart';

/// Service to track and manage consultation usage for free tier limits.
class ConsultationUsageService {
  static ConsultationUsageService? _instance;
  static ConsultationUsageService get instance => _instance ??= ConsultationUsageService._();
  ConsultationUsageService._();

  static const int freeMonthlyLimit = FeatureGateConfig.freeConsultationsPerMonth;
  static const String _localCountKey = 'consultation_count';
  static const String _localMonthKey = 'consultation_month';

  static const String _askAnythingCountKey = 'ask_anything_count';
  static const String _askAnythingMonthKey = 'ask_anything_month';

  final SupabaseService _supabase = SupabaseService();

  /// Check if user can start a new consultation.
  Future<bool> canStartConsultation() async {
    if (await PremiumService.instance.isPremium) {
      return true;
    }
    final count = await getMonthlyConsultationCount();
    return count < freeMonthlyLimit;
  }

  /// Get the number of consultations used this month.
  Future<int> getMonthlyConsultationCount() async {
    // Try Supabase first if user is authenticated
    final userId = _supabase.currentUserId;
    if (_supabase.isInitialized && userId != null) {
      try {
        final result = await _supabase.client!.rpc(
          'get_consultation_count',
          params: {'p_user_id': userId},
        );
        return (result as int?) ?? 0;
      } catch (e) {
        // Fall back to local storage
        print('Error getting consultation count from Supabase: $e');
      }
    }

    // Use local storage as fallback
    return await _getLocalCount();
  }

  /// Increment the consultation count after a reading is delivered.
  /// Call this after a successful AI reading.
  Future<int> incrementConsultationCount() async {
    // Try Supabase first if user is authenticated
    final userId = _supabase.currentUserId;
    if (_supabase.isInitialized && userId != null) {
      try {
        final result = await _supabase.client!.rpc(
          'increment_consultation_count',
          params: {'p_user_id': userId},
        );
        return (result as int?) ?? 1;
      } catch (e) {
        print('Error incrementing consultation count in Supabase: $e');
      }
    }

    // Use local storage as fallback
    return await _incrementLocalCount();
  }

  /// Get remaining consultations for free tier.
  /// Returns -1 for premium users (unlimited).
  Future<int> getRemainingConsultations() async {
    if (await PremiumService.instance.isPremium) {
      return -1;
    }
    final count = await getMonthlyConsultationCount();
    return (freeMonthlyLimit - count).clamp(0, freeMonthlyLimit);
  }

  // Local storage methods for offline/non-authenticated use

  Future<int> _getLocalCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = _getCurrentMonth();
    final storedMonth = prefs.getString(_localMonthKey);

    // Reset count if it's a new month
    if (storedMonth != currentMonth) {
      await prefs.setString(_localMonthKey, currentMonth);
      await prefs.setInt(_localCountKey, 0);
      return 0;
    }

    return prefs.getInt(_localCountKey) ?? 0;
  }

  Future<int> _incrementLocalCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = _getCurrentMonth();
    final storedMonth = prefs.getString(_localMonthKey);

    int newCount;
    if (storedMonth != currentMonth) {
      // New month, reset to 1
      newCount = 1;
      await prefs.setString(_localMonthKey, currentMonth);
    } else {
      newCount = (prefs.getInt(_localCountKey) ?? 0) + 1;
    }

    await prefs.setInt(_localCountKey, newCount);
    return newCount;
  }

  String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  // ── Ask Anything (AI Guru) limits ─────────────────────────────────────

  /// Whether the user can send another "Ask Anything" question this month.
  Future<bool> canAskAnything() async {
    if (await PremiumService.instance.isPremium) {
      if (FeatureGateConfig.premiumAskAnythingPerMonth < 0) return true;
      final count = await _getAskAnythingLocalCount();
      return count < FeatureGateConfig.premiumAskAnythingPerMonth;
    }
    final count = await _getAskAnythingLocalCount();
    return count < FeatureGateConfig.freeAskAnythingPerMonth;
  }

  /// Remaining "Ask Anything" questions this month. -1 = unlimited (premium).
  Future<int> getRemainingAskAnything() async {
    if (await PremiumService.instance.isPremium) {
      if (FeatureGateConfig.premiumAskAnythingPerMonth < 0) return -1;
      final count = await _getAskAnythingLocalCount();
      return (FeatureGateConfig.premiumAskAnythingPerMonth - count)
          .clamp(0, FeatureGateConfig.premiumAskAnythingPerMonth);
    }
    final count = await _getAskAnythingLocalCount();
    return (FeatureGateConfig.freeAskAnythingPerMonth - count)
        .clamp(0, FeatureGateConfig.freeAskAnythingPerMonth);
  }

  /// Call after a successful "Ask Anything" AI response.
  Future<int> incrementAskAnythingCount() async {
    final prefs = await SharedPreferences.getInstance();
    final month = _getCurrentMonth();
    final storedMonth = prefs.getString(_askAnythingMonthKey);
    int newCount;
    if (storedMonth != month) {
      newCount = 1;
      await prefs.setString(_askAnythingMonthKey, month);
    } else {
      newCount = (prefs.getInt(_askAnythingCountKey) ?? 0) + 1;
    }
    await prefs.setInt(_askAnythingCountKey, newCount);
    return newCount;
  }

  Future<int> _getAskAnythingLocalCount() async {
    final prefs = await SharedPreferences.getInstance();
    final month = _getCurrentMonth();
    final storedMonth = prefs.getString(_askAnythingMonthKey);
    if (storedMonth != month) return 0;
    return prefs.getInt(_askAnythingCountKey) ?? 0;
  }
}
