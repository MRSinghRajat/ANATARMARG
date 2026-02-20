import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/navigation/presentation/screens/main_navigation_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/animated_onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/spiritual_onboarding_screen.dart';
import '../../features/content/presentation/screens/reading_screen.dart';
import '../../features/content/presentation/screens/verse_full_screen.dart';
import '../../features/content/data/models/verse_model.dart';
import '../../features/profile/presentation/screens/notifications_settings_screen.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../../features/subscription/presentation/screens/customer_center_screen.dart';
import '../../features/subscription/presentation/screens/subscription_dev_settings.dart';

class AppRouter {
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String onboarding = '/onboarding';
  static const String animatedOnboarding = '/animated-onboarding';
  static const String spiritualOnboarding = '/spiritual-onboarding';
  static const String home = '/home';
  static const String reading = '/reading';
  static const String verseFullScreen = '/verse-full-screen';
  static const String notificationsSettings = '/notifications-settings';
  static const String paywall = '/paywall';
  static const String customerCenter = '/customer-center';
  static const String subscriptionDevSettings = '/subscription-dev-settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case animatedOnboarding:
        return MaterialPageRoute(
            builder: (_) => const AnimatedOnboardingScreen());
      case spiritualOnboarding:
        return MaterialPageRoute(
            builder: (_) => const SpiritualOnboardingScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
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
      case paywall:
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const PaywallScreen(),
        );
      case customerCenter:
        return MaterialPageRoute(
            builder: (_) => const CustomerCenterScreen());
      case subscriptionDevSettings:
        return MaterialPageRoute(
            builder: (_) => const SubscriptionDevSettings());
      default:
        // Auth callback deep links (/?code=... or /?refresh_token=...) arrive
        // here when the Navigator sees them as routes. Redirect to login and
        // let the deep link handler process the auth.
        if (settings.name != null &&
            (settings.name!.contains('code=') ||
             settings.name!.contains('refresh_token='))) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
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
