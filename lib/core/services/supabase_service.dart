import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    if (_client == null) {
      throw Exception('Supabase client not initialized');
    }

    try {
      // Google Sign In
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
    } catch (e) {
      print('Error during Google Sign In: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (_client == null) return;
    await _client!.auth.signOut();
    await GoogleSignIn().signOut();
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
