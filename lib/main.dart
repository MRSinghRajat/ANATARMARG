import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:app_links/app_links.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, LicenseRegistry, LicenseEntryWithLineBreaks;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/utils/sound_manager.dart';
import 'core/services/supabase_service.dart';
import 'core/services/compressed_image_cache.dart';
import 'core/services/revenuecat_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/daily_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'shared/services/avatar_growth_service.dart';
import 'shared/services/premium_service.dart';

/// Runs after first frame so app shows quickly; reduces startup/login latency.
void _deferredInit() async {
  try {
    await PushNotificationService().initialize();
    PushNotificationService.setupForegroundHandler();
  } catch (e) {
    if (kDebugMode) print('Firebase / push init failed: $e');
  }
  try {
    await DailyNotificationService().initialize();
  } catch (e) {
    if (kDebugMode) print('Daily notification init failed: $e');
  }
  try {
    await AvatarGrowthService().initialize();
  } catch (e) {
    if (kDebugMode) print('Avatar initialization failed: $e');
  }
  try {
    await RevenueCatService.instance.initialize();
    await PremiumService.instance.initialize();
    if (kDebugMode) print('RevenueCat initialized successfully');
  } catch (e) {
    if (kDebugMode) print('RevenueCat initialization failed: $e');
  }
  CompressedImageCache.instance.initialize();
}

Future<void> _initSupabase() async {
  try {
    await SupabaseService().initialize();
  } catch (e) {
    if (kDebugMode) {
      print('Supabase initialization failed: $e. App will use local data.');
    }
  }
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    // FCM: register before runApp (iOS release can crash if this runs after runApp).
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    if (kDebugMode) print('Firebase init failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Minimal blocking init so first frame shows fast (avoids 1000+ ms startup latency)
  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      print('=== ENV LOADED ===');
    }
  } catch (e) {
    if (kDebugMode) print('Error loading .env file: $e');
  }

  // Independent of each other; a failure in one must not cancel the other.
  await Future.wait<void>([
    _initSupabase(),
    _initFirebase(),
  ]);

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  // All 11 families live in assets/fonts/. A missing file must fail locally
  // (fallback typeface) instead of silently hitting fonts.gstatic.com.
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(
    const ProviderScope(
      child: AntarMargApp(),
    ),
  );

  // Defer heavy init so app and login feel responsive (no 1000+ ms block before first paint)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _deferredInit();
    // After first frame: background music / prefs (avoids racing plugin registration at process start).
    SoundManager().initialize();
  });
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

  bool _pushingHome = false;

  void _navigateHome() {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null || _pushingHome) return;
    if (ModalRoute.of(ctx)?.settings.name == AppRouter.home) return;
    _pushingHome = true;
    Navigator.of(ctx).pushNamedAndRemoveUntil(
      AppRouter.home,
      (route) => false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushingHome = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
