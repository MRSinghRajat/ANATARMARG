/// Centralized feature flags for shipping control.
///
/// Keep these as compile-time constants so they can be toggled safely and
/// referenced from routing and UI without runtime config dependencies.
class FeatureFlags {
  FeatureFlags._();

  /// Granthalaya "Listen" (audio) is intentionally hidden until audio ships.
  static const bool kListenEnabled = false;
}

