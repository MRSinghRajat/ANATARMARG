import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/utils/sound_manager.dart';
import 'core/services/supabase_service.dart';
import 'core/services/revenuecat_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/daily_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'shared/services/avatar_growth_service.dart';
import 'shared/services/premium_service.dart';
import 'features/onboarding/presentation/screens/spiritual_onboarding_screen.dart';

/// Checked during startup to decide initial route
bool _onboardingComplete = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('=== ENV LOADED ===');
    print('GPT_API_KEY exists: ${dotenv.env['GPT_API_KEY']?.isNotEmpty ?? false}');
    print('GPT_API_KEY length: ${dotenv.env['GPT_API_KEY']?.length ?? 0}');
  } catch (e) {
    print('Error loading .env file: $e');
  }

  // Initialize Supabase (optional - app works without it)
  try {
    await SupabaseService().initialize();
  } catch (e) {
    print('Supabase initialization failed: $e. App will use local data.');
  }

  // Initialize Firebase and push notifications (Apple APNs via FCM)
  try {
    await Firebase.initializeApp();
    await PushNotificationService().initialize();
    PushNotificationService.setupForegroundHandler();
  } catch (e) {
    print('Firebase / push init failed: $e. Add Firebase project and GoogleService-Info.plist for push.');
  }

  // Daily local notification at 6:00 AM: "Your daily tasks are ready"
  try {
    await DailyNotificationService().initialize();
  } catch (e) {
    print('Daily notification init failed: $e');
  }

  // Initialize Inner Avatar (vision-aligned growth system)
  try {
    await AvatarGrowthService().initialize();
  } catch (e) {
    print('Avatar initialization failed: $e. App will use default avatar.');
  }

  // Initialize RevenueCat for in-app purchases
  try {
    await RevenueCatService.instance.initialize();
    await PremiumService.instance.initialize();
    print('RevenueCat initialized successfully');
  } catch (e) {
    print('RevenueCat initialization failed: $e. Subscriptions may not work.');
  }

  // Allow Google Fonts to load from network for fonts not in assets (e.g. Cormorant Light/Medium, Tenor Sans, Merriweather).
  // Bundled fonts in pubspec (Cormorant Garamond, Inter, etc.) are still used when specified in theme.
  GoogleFonts.config.allowRuntimeFetching = true;

  // Check if onboarding has been completed
  _onboardingComplete = await SpiritualOnboardingScreen.isOnboardingComplete();

  runApp(
    const ProviderScope(
      child: AntarMargApp(),
    ),
  );

}

class AntarMargApp extends StatefulWidget {
  const AntarMargApp({super.key});

  @override
  State<AntarMargApp> createState() => _AntarMargAppState();
}

class _AntarMargAppState extends State<AntarMargApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _listenToAuthLinks();
    _handleInitialAuthLink();
    // Defer sound init so it doesn't block the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundManager().initialize();
    });
  }

  Future<void> _handleInitialAuthLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri == null) return;
      _handleAuthUri(uri);
    } catch (_) {}
  }

  void _listenToAuthLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri == null) return;
      _handleAuthUri(uri);
    });
  }

  /// Handles auth callback deep links for both implicit flow (refresh_token)
  /// and PKCE flow (code). For PKCE, supabase_flutter exchanges the code
  /// automatically — we just listen for the resulting auth state change.
  void _handleAuthUri(Uri uri) {
    if (uri.scheme != 'antarmarg' || uri.host != 'auth-callback') return;

    final params = uri.fragment.isNotEmpty
        ? Uri.splitQueryString(uri.fragment)
        : uri.queryParameters;

    if (params.containsKey('refresh_token')) {
      SupabaseService().recoverSessionFromUri(uri).then((recovered) {
        if (recovered) _navigateHome();
      });
    } else if (params.containsKey('code')) {
      // PKCE flow: supabase_flutter handles the code exchange automatically.
      // Wait for the signedIn event then navigate.
      final client = SupabaseService().client;
      if (client == null) return;
      late final StreamSubscription sub;
      sub = client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.signedIn) {
          sub.cancel();
          _navigateHome();
        }
      });
    }
  }

  void _navigateHome() {
    if (_navigatorKey.currentContext != null) {
      Navigator.of(_navigatorKey.currentContext!).pushNamedAndRemoveUntil(
        AppRouter.home,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: _onboardingComplete ? AppRouter.login : AppRouter.spiritualOnboarding,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
