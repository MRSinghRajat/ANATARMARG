import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/utils/sound_manager.dart';
import 'core/services/supabase_service.dart';
import 'core/services/revenuecat_service.dart';
import 'shared/services/avatar_growth_service.dart';
import 'shared/services/premium_service.dart';

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

  runApp(
    const ProviderScope(
      child: AshraePlaygroundApp(),
    ),
  );

}

class AshraePlaygroundApp extends StatefulWidget {
  const AshraePlaygroundApp({super.key});

  @override
  State<AshraePlaygroundApp> createState() => _AshraePlaygroundAppState();
}

class _AshraePlaygroundAppState extends State<AshraePlaygroundApp> {
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
                AppRouter.animatedOnboarding,
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
              AppRouter.animatedOnboarding,
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
      initialRoute: AppRouter.login,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
