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
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
    } catch (e) {
      print('Error initializing Supabase: $e');
      // Continue without Supabase - app will use local data
    }
  }

  SupabaseClient? get client => _client;
  bool get isInitialized => _client != null;

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
}
