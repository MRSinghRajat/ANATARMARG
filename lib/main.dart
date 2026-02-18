import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/utils/sound_manager.dart';
import 'core/services/supabase_service.dart';
import 'core/services/revenuecat_service.dart';
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

  // Initialize sound manager and start playing bird singing sound
  await SoundManager().initialize();

  // Disable Google Fonts runtime fetching to prevent ImageDecoder errors.
  // Fonts are bundled locally in assets/fonts/ instead.
  GoogleFonts.config.allowRuntimeFetching = false;

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
  }

  Future<void> _handleInitialAuthLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri == null) return;
      if (uri.scheme == 'antarmarg' && uri.host == 'auth-callback') {
        final recovered = await SupabaseService().recoverSessionFromUri(uri);
        if (recovered && mounted && _navigatorKey.currentContext != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_navigatorKey.currentContext != null) {
              Navigator.of(_navigatorKey.currentContext!).pushNamedAndRemoveUntil(
                AppRouter.home,
                (route) => false,
              );
            }
          });
        }
      }
    } catch (_) {}
  }

  void _listenToAuthLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri == null) return;
      if (uri.scheme == 'antarmarg' && uri.host == 'auth-callback') {
        SupabaseService().recoverSessionFromUri(uri).then((recovered) {
          if (recovered && _navigatorKey.currentContext != null) {
            Navigator.of(_navigatorKey.currentContext!).pushNamedAndRemoveUntil(
              AppRouter.home,
              (route) => false,
            );
          }
        });
      }
    });
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
