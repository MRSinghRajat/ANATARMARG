import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/services/feature_gate_config.dart';

/// Server-tracked weekly AI Guru credits + purchased balance (Supabase).
class GuruAiCreditsService {
  GuruAiCreditsService(this._client);

  final SupabaseClient _client;

  /// Writes [tier] to app_profiles for RPC allowance (free / plus / pro).
  Future<void> syncTierToProfile(UserTier tier) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await _client.rpc(
        'sync_guru_ai_tier_to_profile',
        params: {'p_tier': tier.name},
      );
    } catch (e) {
      debugPrint('GuruAiCreditsService.syncTierToProfile: $e');
    }
  }

  Future<GuruCreditPeek?> peek() async {
    if (_client.auth.currentUser == null) return null;
    try {
      final raw = await _client.rpc('peek_guru_ai_credits');
      if (raw == null) return null;
      final m = Map<String, dynamic>.from(raw as Map);
      if (m['ok'] != true) return null;
      return GuruCreditPeek(
        tierWire: m['tier'] as String? ?? 'free',
        allowance: (m['allowance'] as num?)?.toInt() ?? 0,
        includedRemaining: (m['included_remaining'] as num?)?.toInt() ?? 0,
        purchasedCredits: (m['purchased_credits'] as num?)?.toInt() ?? 0,
        totalSendable: (m['total_sendable'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      debugPrint('GuruAiCreditsService.peek: $e');
      return null;
    }
  }

  /// Returns false if quota exceeded (do not call OpenAI).
  Future<bool> tryConsume() async {
    if (_client.auth.currentUser == null) return false;
    try {
      final raw = await _client.rpc('consume_guru_ai_credit');
      if (raw == null) return false;
      final m = Map<String, dynamic>.from(raw as Map);
      return m['ok'] == true;
    } catch (e) {
      debugPrint('GuruAiCreditsService.tryConsume: $e');
      return false;
    }
  }

  Future<bool> grantPurchasedCredits(int amount) async {
    if (!FeatureGateConfig.guruCreditPackAmounts.contains(amount)) return false;
    if (_client.auth.currentUser == null) return false;
    try {
      final raw = await _client.rpc(
        'grant_guru_ai_purchased_credits',
        params: {'p_amount': amount},
      );
      if (raw == null) return false;
      final m = Map<String, dynamic>.from(raw as Map);
      return m['ok'] == true;
    } catch (e) {
      debugPrint('GuruAiCreditsService.grantPurchasedCredits: $e');
      return false;
    }
  }
}

class GuruCreditPeek {
  final String tierWire;
  final int allowance;
  final int includedRemaining;
  final int purchasedCredits;
  final int totalSendable;

  const GuruCreditPeek({
    required this.tierWire,
    required this.allowance,
    required this.includedRemaining,
    required this.purchasedCredits,
    required this.totalSendable,
  });
}
