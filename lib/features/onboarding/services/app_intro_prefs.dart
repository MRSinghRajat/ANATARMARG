import 'package:shared_preferences/shared_preferences.dart';

/// Persists app-teaching tour state separately from [SpiritualOnboardingScreen] completion.
class AppIntroPrefs {
  AppIntroPrefs._();

  static const String introSeenKey = 'onboarding_app_intro_v1_seen';
  static const String coachDoneKey = 'first_run_coach_v1_done';

  static Future<bool> isIntroSeen() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(introSeenKey) ?? false;
  }

  static Future<void> markIntroSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(introSeenKey, true);
  }

  static Future<bool> isCoachDone() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(coachDoneKey) ?? false;
  }

  static Future<void> markCoachDone() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(coachDoneKey, true);
  }

  /// First time user reaches main tabs (after login or skip); not tied to pre-login flows.
  static Future<bool> shouldShowPostLoginTabTour() async {
    final done = await isCoachDone();
    return !done;
  }
}
