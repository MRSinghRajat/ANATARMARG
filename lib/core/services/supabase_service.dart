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
}
