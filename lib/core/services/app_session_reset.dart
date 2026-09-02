import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/onboarding/presentation/screens/spiritual_onboarding_screen.dart';
import '../../shared/services/coin_service.dart';
import '../../shared/services/premium_service.dart';
import '../../features/sanctuary/data/services/sanctuary_customization_service.dart';
import 'daily_streak_service.dart';
import 'revenuecat_service.dart';

/// Clears in-memory singleton caches and unnamespaced user-scoped prefs on sign-out.
///
/// Device-global prefs (language, sound, notification toggles, onboarding_complete)
/// are left intact. Streak keys are already per-user and are not deleted.
class AppSessionReset {
  AppSessionReset._();

  /// SharedPreferences keys that hold user-scoped data without a user-id suffix.
  static const List<String> unnamespacedUserKeys = [
    SpiritualOnboardingScreen.onboardingUserNameKey,
    'sanctuary_customization_v2',
    'sanctuary_purchased_items_v2',
    'temple_ground_type',
    'mandir_deity_background',
    'mandir_light',
    'granthalaya_bookmarks_sacred_texts',
    'granthalaya_bookmarks_sacred_stories',
    'local_reading_progress',
    'verse_bookmarks',
    'verse_notes',
    'user_items',
    'aangan_active_festival_bundle_id',
    'aangan_owned_festival_bundle_ids',
    'user_avatar',
    'is_premium_override',
  ];

  static Future<void> onSignOut() async {
    try {
      await RevenueCatService.instance.logOut();
    } catch (e) {
      if (kDebugMode) debugPrint('AppSessionReset: RevenueCat logOut: $e');
    }

    DailyStreakService.instance.setUserId(null);

    await PremiumService.instance.resetSession();
    await CoinService().resetSession();
    await SanctuaryCustomizationService().resetSession();

    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in unnamespacedUserKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AppSessionReset: prefs clear: $e');
    }
  }
}
