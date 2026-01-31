import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/navigation/presentation/screens/main_navigation_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/animated_onboarding_screen.dart';
import '../../features/prayer/presentation/screens/prayer_screen.dart';
import '../../features/content/presentation/screens/reading_screen.dart';
import '../../features/content/presentation/screens/verse_full_screen.dart';
import '../../features/content/data/models/verse_model.dart';
import '../../features/profile/presentation/screens/notifications_settings_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String animatedOnboarding = '/animated-onboarding';
  static const String home = '/home';
  static const String prayer = '/prayer';
  static const String reading = '/reading';
  static const String verseFullScreen = '/verse-full-screen';
  static const String notificationsSettings = '/notifications-settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case animatedOnboarding:
        return MaterialPageRoute(
            builder: (_) => const AnimatedOnboardingScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case prayer:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PrayerScreen(
            bonusCoins: args?['bonusCoins'] as int?,
          ),
        );
      case reading:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReadingScreen(
            verse: args['verse'] as VerseContent,
            taskId: args['taskId'] as String?,
            coinReward: args['coinReward'] as int? ?? 35,
            taskType: args['taskType'] as String?,
            questStageKey: args['questStageKey'] as String?,
          ),
        );
      case verseFullScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VerseFullScreen(
            verse: args['verse'] as VerseContent,
            likeCount: args['likeCount'] as int?,
            shareCount: args['shareCount'] as int?,
            onLike: args['onLike'] as VoidCallback?,
            onShare: args['onShare'] as VoidCallback?,
          ),
        );
      case notificationsSettings:
        return MaterialPageRoute(
            builder: (_) => const NotificationsSettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
