import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'Antar मार्ग';
  /// Display name for UI (logo text): Antar मार्ग
  static const String appDisplayName = 'Antar मार्ग';
  static const String appTagline = 'The Inner Path';
  /// Keep in sync with `version` in pubspec.yaml (user-facing part before +).
  static const String appVersion = '1.0.0';

  /// Splash / branding assets (optional)
  static const String splashGifPath = 'assets/animations/splash.gif';
  static const String appLogoPath = 'assets/images/app_logo.png';

  // GPT API Configuration (loaded from .env)
  static const String gptApiBaseUrl = 'https://api.openai.com/v1';
  static String get gptApiKey =>
      dotenv.isInitialized ? (dotenv.env['GPT_API_KEY'] ?? '') : '';

  // Coin Rewards
  static const int readingCompletionCoins = 20; // Base coins per chapter
  static const int taskCompletionCoins = 35; // Base coins per task
  static const int quizCompletionCoins = 50; // Base coins per quiz
  static const int streakBonusCoins = 10; // Bonus per day in streak
  static const int firstTimeChapterBonus = 5;

  // Reading Time
  static const int targetReadingTimeMinutes = 2;

  // Item Rarity Pricing
  static const Map<String, int> itemPricing = {
    'common_min': 50,
    'common_max': 200,
    'rare_min': 200,
    'rare_max': 500,
    'epic_min': 500,
    'epic_max': 2000,
  };

  /// When true, every user is treated as Pro (all premium gates unlock).
  /// Default is false: Pro requires a real RevenueCat entitlement unless you set
  /// `PREMIUM_GRANT_ALL=true` in `.env` (e.g. temporary beta override).
  static bool get premiumGrantAll {
    if (!dotenv.isInitialized) return false;
    final v = dotenv.env['PREMIUM_GRANT_ALL']?.trim().toLowerCase();
    if (v == 'true' || v == '1' || v == 'yes') return true;
    return false;
  }

  /// Show the gradient Pro label on Pro-only UI (e.g. Ashram section titles) even when the user has access.
  static bool showProMarkForPremiumFeature(bool userHasPremiumAccess) =>
      !userHasPremiumAccess || premiumGrantAll;

  /// Aangan temple bell: full HTTPS URL (e.g. Supabase Storage public URL). Empty = silent (visual only).
  /// Other app audio should use Supabase URLs; only [SoundManager] background loop ships in the bundle.
  static String get aanganBellAudioUrl {
    if (!dotenv.isInitialized) return '';
    return (dotenv.env['AANGAN_BELL_AUDIO_URL'] ?? '').trim();
  }
}
