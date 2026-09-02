import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
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
import '../../features/profile/presentation/screens/notifications_list_screen.dart';
import '../../features/profile/presentation/screens/my_growth_screen.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../../features/subscription/presentation/screens/customer_center_screen.dart';
import '../../features/subscription/presentation/screens/subscription_dev_settings.dart';
import '../../features/legal/presentation/screens/legal_document_screen.dart';
import '../../features/journey/presentation/screens/journey_setup_screen.dart';
import '../../features/journey/presentation/screens/journey_home_screen.dart';
import '../../features/journey/presentation/screens/journey_task_detail_screen.dart';
import '../../features/journey/presentation/screens/journey_milestone_detail_screen.dart';
import '../../features/journey/presentation/widgets/journey_premium_gate.dart';
import '../../features/books/presentation/screens/sacred_text_audio_screen.dart';
import '../../features/books/presentation/screens/book_audio_detail_screen.dart';
import '../../features/books/presentation/screens/story_audio_screen.dart';
import '../../features/books/presentation/screens/all_sacred_texts_listen_screen.dart';
import '../../features/books/presentation/screens/all_books_listen_screen.dart';
import '../../features/books/presentation/screens/all_stories_listen_screen.dart';
import '../../features/books/presentation/screens/all_chants_listen_screen.dart';
import '../../features/books/data/models/granthalaya_models.dart';
import '../../features/books/data/models/book_model.dart';
import '../../features/journey/presentation/screens/journey_content_link_screen.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String onboarding = '/onboarding';
  static const String animatedOnboarding = '/animated-onboarding';
  static const String spiritualOnboarding = '/spiritual-onboarding';
  static const String home = '/home';
  static const String reading = '/reading';
  static const String verseFullScreen = '/verse-full-screen';
  static const String notificationsSettings = '/notifications-settings';
  static const String notificationsList = '/notifications-list';
  static const String paywall = '/paywall';
  static const String customerCenter = '/customer-center';
  static const String subscriptionDevSettings = '/subscription-dev-settings';
  static const String journeySetup = '/journey/setup';
  static const String journeyHome = '/journey/home';
  static const String journeyTask = '/journey/task';
  static const String journeyMilestone = '/journey/milestone';
  static const String journeyOpenContent = '/journey/open-content';
  static const String myGrowth = '/my-growth';
  static const String termsOfService = '/legal/terms';
  static const String privacyPolicy = '/legal/privacy';

  // Listen tab routes
  static const String listenSacredText = '/listen/sacred-text';
  static const String listenBook = '/listen/book';
  static const String listenStory = '/listen/story';
  static const String listenAllTexts = '/listen/all-texts';
  static const String listenAllBooks = '/listen/all-books';
  static const String listenAllStories = '/listen/all-stories';
  static const String listenAllChants = '/listen/all-chants';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
          fullscreenDialog: false,
        );
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
        return MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
          settings: settings,
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
      case notificationsList:
        return MaterialPageRoute(
            builder: (_) => const NotificationsListScreen());
      case paywall:
        return MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const PaywallRouteScreen(),
        );
      case customerCenter:
        return MaterialPageRoute(
            builder: (_) => const CustomerCenterScreen());
      case subscriptionDevSettings:
        if (kDebugMode) {
          return MaterialPageRoute(
            builder: (_) => const SubscriptionDevSettings(),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const _SubscriptionDevBlocked(),
          settings: settings,
        );
      case journeySetup: {
        final args = settings.arguments as Map<String, dynamic>?;
        final slug = args?['slug'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => JourneyPremiumGate(
            slug: slug,
            child: JourneySetupScreen(slug: slug),
          ),
          settings: settings,
        );
      }
      case journeyHome: {
        final args = settings.arguments is Map<String, dynamic> ? settings.arguments as Map<String, dynamic>? : null;
        final userJourneyId = (args != null ? args['userJourneyId'] as String? : null) ?? '';
        return MaterialPageRoute(
          builder: (_) => JourneyPremiumGate(
            userJourneyId: userJourneyId,
            child: JourneyHomeScreen(userJourneyId: userJourneyId),
          ),
          settings: settings,
        );
      }
      case journeyTask: {
        final args = settings.arguments as Map<String, dynamic>?;
        final userJourneyId = args?['userJourneyId'] as String? ?? '';
        final taskId = args?['taskId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => JourneyPremiumGate(
            userJourneyId: userJourneyId,
            child: JourneyTaskDetailScreen(
              userJourneyId: userJourneyId,
              taskId: taskId,
            ),
          ),
          settings: settings,
        );
      }
      case journeyMilestone: {
        final args = settings.arguments as Map<String, dynamic>?;
        final userJourneyId = args?['userJourneyId'] as String? ?? '';
        final milestoneId = args?['milestoneId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => JourneyPremiumGate(
            userJourneyId: userJourneyId,
            child: JourneyMilestoneDetailScreen(
              userJourneyId: userJourneyId,
              milestoneId: milestoneId,
            ),
          ),
          settings: settings,
        );
      }
      case listenSacredText: {
        final text = settings.arguments as SacredTextModel;
        return MaterialPageRoute(builder: (_) => SacredTextAudioScreen(sacredText: text), settings: settings);
      }
      case listenBook: {
        final book = settings.arguments as BookModel;
        return MaterialPageRoute(builder: (_) => BookAudioDetailScreen(book: book), settings: settings);
      }
      case listenStory: {
        final story = settings.arguments as SacredStoryModel;
        return MaterialPageRoute(builder: (_) => StoryAudioScreen(story: story), settings: settings);
      }
      case listenAllTexts:
        return MaterialPageRoute(builder: (_) => const AllSacredTextsListenScreen(), settings: settings);
      case listenAllBooks:
        return MaterialPageRoute(builder: (_) => const AllBooksListenScreen(), settings: settings);
      case listenAllStories:
        return MaterialPageRoute(builder: (_) => const AllStoriesListenScreen(), settings: settings);
      case listenAllChants:
        return MaterialPageRoute(builder: (_) => const AllChantsListenScreen(), settings: settings);
      case journeyOpenContent: {
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => JourneyContentLinkScreen(
            refType: args['refType'] as String? ?? '',
            refIdOrSlug: args['refIdOrSlug'] as String? ?? '',
            displayTitle: args['displayTitle'] as String?,
          ),
          settings: settings,
        );
      }
      case myGrowth:
        return MaterialPageRoute(builder: (_) => const MyGrowthScreen(), settings: settings);
      case termsOfService:
        return MaterialPageRoute(
          builder: (_) => const TermsOfServiceScreen(),
          settings: settings,
        );
      case privacyPolicy:
        return MaterialPageRoute(
          builder: (_) => const PrivacyPolicyScreen(),
          settings: settings,
        );
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

/// Shown if a release build opens the dev-only subscription route (e.g. stale link).
class _SubscriptionDevBlocked extends StatefulWidget {
  const _SubscriptionDevBlocked();

  @override
  State<_SubscriptionDevBlocked> createState() => _SubscriptionDevBlockedState();
}

class _SubscriptionDevBlockedState extends State<_SubscriptionDevBlocked> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
