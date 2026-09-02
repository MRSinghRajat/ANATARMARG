/// Centralized configuration for all free-tier limits.
///
/// All premium-gating thresholds live here so they can be tuned in one place.
class FeatureGateConfig {
  FeatureGateConfig._();

  // ── Books / Granthalaya ──────────────────────────────────────────────
  /// Number of audio tracks a free user can play per book (sample).
  static const int freeAudioPerBook = 1;

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
