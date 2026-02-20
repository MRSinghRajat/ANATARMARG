import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;

  /// Initialize Supabase client
  Future<void> initialize() async {
    try {
      final url = SupabaseConfig.supabaseUrl;
      final anonKey = SupabaseConfig.supabaseAnonKey;

      // Skip initialization if credentials are placeholders or invalid
      if (!_isValidSupabaseConfig(url, anonKey)) {
        return; // App will use local data
      }

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _client = Supabase.instance.client;
    } catch (e) {
      print('Error initializing Supabase: $e');
      // Continue without Supabase - app will use local data
    }
  }

  bool _isValidSupabaseConfig(String url, String anonKey) {
    if (url.isEmpty || anonKey.isEmpty) return false;
    if (url.contains('YOUR_') || anonKey.contains('YOUR_')) return false;
    if (!url.startsWith('https://') || !url.contains('.supabase')) return false;
    return true;
  }

  SupabaseClient? get client => _client;
  bool get isInitialized => _client != null;

  /// Check if Google Sign-In is configured correctly
  String? validateGoogleConfig() {
    final clientId = SupabaseConfig.googleWebClientId;
    if (clientId.isEmpty) {
      return 'Google Web Client ID is missing in .env';
    }
    if (clientId.contains('YOUR_') || !clientId.endsWith('.apps.googleusercontent.com')) {
      return 'Invalid Google Web Client ID format in .env';
    }
    return null; // Config is valid
  }

  /// Get current user ID (if authenticated)
  String? get currentUserId => _client?.auth.currentUser?.id;

  /// Sign in with Google — iOS uses web-based OAuth (avoids nonce mismatch
  /// between Google's native iOS SDK and Supabase Auth); Android uses native
  /// Google Sign-In with id_token exchange.
  Future<AuthResponse> signInWithGoogle() async {
    if (_client == null) {
      throw Exception('Supabase client not initialized');
    }

    try {
      if (Platform.isIOS) {
        return await _signInWithGoogleOAuth();
      }
      return await _signInWithGoogleNative();
    } catch (e) {
      print('Error during Google Sign In: $e');
      rethrow;
    }
  }

  /// iOS: Supabase OAuth flow in an external browser. The nonce is handled
  /// server-side so there's no mismatch with the native Google SDK.
  /// Uses PKCE flow — supabase_flutter automatically exchanges the auth code
  /// for a session when the deep link callback arrives.
  Future<AuthResponse> _signInWithGoogleOAuth() async {
    final completer = Completer<AuthResponse>();

    late final StreamSubscription<AuthState> sub;
    sub = _client!.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && !completer.isCompleted) {
        sub.cancel();
        final session = data.session;
        completer.complete(
          AuthResponse(session: session, user: session?.user),
        );
      }
    });

    try {
      final res = await _client!.auth.getOAuthSignInUrl(
        provider: OAuthProvider.google,
        redirectTo: SupabaseConfig.authRedirectUrl,
      );

      final launched = await launchUrl(
        Uri.parse(res.url),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        sub.cancel();
        throw Exception('Could not open Google Sign-In');
      }
    } catch (e) {
      sub.cancel();
      rethrow;
    }

    return completer.future;
  }

  /// Android: native Google Sign-In with id_token exchange.
  Future<AuthResponse> _signInWithGoogleNative() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: SupabaseConfig.googleWebClientId,
    );
    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google Sign In cancelled by user');
    }

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('No ID Token found from Google Sign In');
    }

    if (accessToken == null) {
      throw Exception('No Access Token found from Google Sign In');
    }

    return _client!.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  /// Sign in with Apple (native iOS). Uses the `sign_in_with_apple` package
  /// to obtain an identity token, then exchanges it with Supabase Auth.
  Future<AuthResponse> signInWithApple() async {
    if (_client == null) {
      throw Exception('Supabase client not initialized');
    }

    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw Exception('No identity token returned from Apple Sign In');
    }

    return _client!.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Sign out
  Future<void> signOut() async {
    if (_client == null) return;
    await _client!.auth.signOut();
    if (!Platform.isIOS) {
      await GoogleSignIn().signOut();
    }
  }

  /// Sign in with email using OOB (magic link). Sends a link to [email];
  /// [fullName] is stored in user_metadata. Uses SupabaseConfig.authRedirectUrl
  /// unless [emailRedirectTo] is provided; add that URL to Supabase Auth URL allow list.
  Future<void> signInWithOtp({
    required String email,
    String? fullName,
    String? emailRedirectTo,
  }) async {
    if (_client == null) {
      throw Exception('Supabase client not initialized');
    }
    final redirectTo =
        emailRedirectTo ?? SupabaseConfig.authRedirectUrl;
    await _client!.auth.signInWithOtp(
      email: email.trim().toLowerCase(),
      emailRedirectTo: redirectTo.isNotEmpty ? redirectTo : null,
      data: fullName != null && fullName.trim().isNotEmpty
          ? {'full_name': fullName.trim()}
          : null,
      shouldCreateUser: true,
    );
  }

  /// Recover session when app is opened from the magic link (OOB callback).
  /// Parses refresh_token from the URI (fragment or query) and calls setSession.
  Future<bool> recoverSessionFromUri(Uri uri) async {
    if (_client == null) return false;
    try {
      final params = uri.fragment.isNotEmpty
          ? Uri.splitQueryString(uri.fragment)
          : uri.queryParameters;
      final refreshToken = params['refresh_token'];
      if (refreshToken == null || refreshToken.isEmpty) return false;
      await _client!.auth.setSession(refreshToken);
      return true;
    } catch (e) {
      print('recoverSessionFromUri error: $e');
      return false;
    }
  }
}
