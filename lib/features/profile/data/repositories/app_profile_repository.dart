import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_profile_model.dart';

/// Repository for app profile (display name, avatar) stored in DB.
class AppProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get current user's app profile from DB.
  Future<AppProfile?> getProfile() async {
    if (_userId == null) return null;
    try {
      final res = await _supabase
          .from('app_profiles')
          .select()
          .eq('user_id', _userId!)
          .maybeSingle();
      return res == null ? null : AppProfile.fromJson(res);
    } catch (e) {
      // ignore: avoid_print
      print('AppProfileRepository getProfile: $e');
      return null;
    }
  }

  /// Upsert app profile (display_name, avatar_url). Creates row if missing.
  Future<AppProfile?> upsertProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    if (_userId == null) return null;
    try {
      final data = <String, dynamic>{
        'user_id': _userId!,
        if (displayName != null) 'display_name': displayName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };
      final res = await _supabase
          .from('app_profiles')
          .upsert(
            data,
            onConflict: 'user_id',
            ignoreDuplicates: false,
          )
          .select()
          .single();
      return AppProfile.fromJson(res);
    } catch (e) {
      // ignore: avoid_print
      print('AppProfileRepository upsertProfile: $e');
      return null;
    }
  }

  /// Get display name: from app_profiles first, else null (caller can fallback to auth/onboarding).
  Future<String?> getDisplayName() async {
    final profile = await getProfile();
    final name = profile?.displayName?.trim();
    return (name != null && name.isNotEmpty) ? name : null;
  }

  /// Get avatar URL from app_profiles.
  Future<String?> getAvatarUrl() async {
    final profile = await getProfile();
    final url = profile?.avatarUrl?.trim();
    return (url != null && url.isNotEmpty) ? url : null;
  }

  /// Get display name: DB first, then sync from auth/onboarding if missing and return.
  /// [onboardingName] optional fallback from SpiritualOnboardingScreen.getStoredUserName().
  Future<String?> getDisplayNameWithFallback({String? onboardingName}) async {
    var profile = await getProfile();
    var name = profile?.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final uid = _userId;
    if (uid == null) return onboardingName;
    final authName = _supabase.auth.currentUser?.userMetadata?['full_name']?.toString().trim() ??
        _supabase.auth.currentUser?.userMetadata?['name']?.toString().trim();
    final toSave = (authName != null && authName.isNotEmpty)
        ? authName
        : (onboardingName != null && onboardingName.isNotEmpty)
            ? onboardingName
            : null;
    if (toSave != null) await upsertProfile(displayName: toSave);
    return toSave ?? onboardingName;
  }

  /// Get avatar URL with fallback from auth.
  Future<String?> getAvatarUrlWithFallback() async {
    var profile = await getProfile();
    var url = profile?.avatarUrl?.trim();
    if (url != null && url.isNotEmpty) return url;
    final authUrl = _supabase.auth.currentUser?.userMetadata?['avatar_url']?.toString().trim();
    if (authUrl != null && authUrl.isNotEmpty) await upsertProfile(avatarUrl: authUrl);
    return authUrl;
  }
}
