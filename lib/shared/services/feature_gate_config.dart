/// Centralized configuration for all free-tier limits.
///
/// All premium-gating thresholds live here so they can be tuned in one place.
class FeatureGateConfig {
  FeatureGateConfig._();

  // ── Books / Granthalaya ──────────────────────────────────────────────
  /// Number of audio tracks a free user can play per book (sample).
  static const int freeAudioPerBook = 1;

  // ── AI Chat ──────────────────────────────────────────────────────────
  /// Monthly consultation limit for free users (shared across all services).
  static const int freeConsultationsPerMonth = 3;

  /// "Ask Anything" questions per month for free users (AI Guru).
  static const int freeAskAnythingPerMonth = 2;

  /// "Ask Anything" questions per month for premium users (-1 = unlimited).
  static const int premiumAskAnythingPerMonth = -1;

  // ── AI Guru — weekly included credits (enforced in Supabase; see user_guru_ai_weekly) ──
  static const int guruWeeklyIncludedFree = 5;
  static const int guruWeeklyIncludedPlus = 10;
  static const int guruWeeklyIncludedPro = 20;

  /// Purchasable credit pack sizes (must match grant_guru_ai_purchased_credits).
  static const List<int> guruCreditPackAmounts = [10, 30, 100];

  // ── AI Guru (OpenAI) — model quality / context (not weekly caps) ─────────────────
  static const int freeMaxTokens = 150;
  static const int freeHistoryMessages = 6;

  static const int plusMaxTokens = 400;
  static const int plusHistoryMessages = 20;

  static const int proMaxTokens = 800;
  static const int proHistoryMessages = 30;

  /// Vision (palmistry image, etc.) needs a much higher cap than text chat; tier still scales quality headroom.
  static int visionMaxTokens(UserTier tier) {
    switch (tier) {
      case UserTier.pro:
        return 3500;
      case UserTier.plus:
        return 2800;
      case UserTier.free:
        return 2200;
    }
  }

  /// Legacy daily fields: unused for quota (weekly credits are authoritative). Kept -1 so old callers don't cap.
  static GuruLimits getLimits(UserTier tier) {
    switch (tier) {
      case UserTier.pro:
        return const GuruLimits(
          askAnythingPerDay: -1,
          consultationsPerDay: -1,
          maxTokens: proMaxTokens,
          historyMessages: proHistoryMessages,
        );
      case UserTier.plus:
        return const GuruLimits(
          askAnythingPerDay: -1,
          consultationsPerDay: -1,
          maxTokens: plusMaxTokens,
          historyMessages: plusHistoryMessages,
        );
      case UserTier.free:
        return const GuruLimits(
          askAnythingPerDay: -1,
          consultationsPerDay: -1,
          maxTokens: freeMaxTokens,
          historyMessages: freeHistoryMessages,
        );
    }
  }

  // ── Ashram ───────────────────────────────────────────────────────────
  /// Maximum custom habits a free user can create.
  static const int freeCustomHabitsMax = 2;

  /// Number of chants available for free in Chant Player.
  static const int freeChantsCount = 1;

  // ── Quests ───────────────────────────────────────────────────────────
  /// Number of parvas (quest arcs) available for free.
  static const int freeParvasCount = 2;

  // ── Sanctuary / Aangan ───────────────────────────────────────────────
  /// Number of purchasable Mandir decor items available for free.
  static const int freeMandirDecorCount = 3;
}

enum UserTier { free, plus, pro }

class GuruLimits {
  final int askAnythingPerDay;
  final int consultationsPerDay;
  final int maxTokens;
  final int historyMessages;

  bool get isUnlimitedAsk => askAnythingPerDay == -1;
  bool get isUnlimitedConsult => consultationsPerDay == -1;

  const GuruLimits({
    required this.askAnythingPerDay,
    required this.consultationsPerDay,
    required this.maxTokens,
    required this.historyMessages,
  });
}
