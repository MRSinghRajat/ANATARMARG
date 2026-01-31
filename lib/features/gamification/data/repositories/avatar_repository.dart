import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/avatar_model.dart';

/// Persists and retrieves avatar data (Inner Self)
/// Uses SharedPreferences locally; Supabase when authenticated
class AvatarRepository {
  static final AvatarRepository _instance = AvatarRepository._internal();
  factory AvatarRepository() => _instance;
  AvatarRepository._internal();

  static const String _prefsKey = 'user_avatar';

  final _avatarController = StreamController<AvatarModel>.broadcast();

  Stream<AvatarModel> get avatarStream => _avatarController.stream;

  /// Get current avatar - tries Supabase first if authenticated, else local
  Future<AvatarModel> getAvatar() async {
    final supabase = SupabaseService();
    if (supabase.isInitialized && supabase.currentUserId != null) {
      try {
        final avatar = await _fetchFromSupabase(supabase.currentUserId!);
        if (avatar != null) {
          await _saveToLocal(avatar);
          _avatarController.add(avatar);
          return avatar;
        }
      } catch (e) {
        print('Error fetching avatar from Supabase: $e');
      }
    }

    return _loadFromLocal();
  }

  /// Save avatar - persists locally and to Supabase if authenticated
  Future<void> saveAvatar(AvatarModel avatar) async {
    await _saveToLocal(avatar);
    _avatarController.add(avatar);

    final supabase = SupabaseService();
    if (supabase.isInitialized && supabase.currentUserId != null) {
      try {
        await _upsertToSupabase(supabase.currentUserId!, avatar);
      } catch (e) {
        print('Error saving avatar to Supabase: $e');
      }
    }
  }

  /// Update avatar with growth (e.g. after completing Seva or Dilemma)
  Future<AvatarModel> recordAction({
    int wisdomGain = 0,
    int karmaGain = 0,
    bool extendsStreak = false,
  }) async {
    final avatar = await getAvatar();
    final now = DateTime.now();

    int newStreak = avatar.streakDays;
    if (extendsStreak) {
      final lastActivity = avatar.lastActivityAt;
      if (lastActivity != null) {
        final daysSince = now.difference(lastActivity).inDays;
        if (daysSince == 0) {
          // Same day - no change
        } else if (daysSince == 1) {
          newStreak = avatar.streakDays + 1;
        } else {
          newStreak = 1; // Streak broken, start fresh (no shame)
        }
      } else {
        newStreak = 1;
      }
    }

    final updated = avatar.copyWith(
      wisdomLevel: (avatar.wisdomLevel + wisdomGain).clamp(1, 10),
      karmaBalance: avatar.karmaBalance + karmaGain,
      streakDays: newStreak,
      lastActivityAt: now,
      updatedAt: now,
    );

    await saveAvatar(updated);
    return updated;
  }

  Future<AvatarModel> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);

    if (json != null) {
      try {
        final avatar = AvatarModel.fromJson(
          jsonDecode(json) as Map<String, dynamic>,
        );
        _avatarController.add(avatar);
        return avatar;
      } catch (e) {
        print('Error parsing avatar: $e');
      }
    }

    final defaultAvatar = AvatarModel();
    await _saveToLocal(defaultAvatar);
    _avatarController.add(defaultAvatar);
    return defaultAvatar;
  }

  Future<void> _saveToLocal(AvatarModel avatar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(avatar.toJson()));
  }

  Future<AvatarModel?> _fetchFromSupabase(String userId) async {
    final response = await SupabaseService()
        .client!
        .from(SupabaseConfig.avatarsTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response != null) {
      final map = Map<String, dynamic>.from(response as Map);
      return AvatarModel.fromJson(map);
    }
    return null;
  }

  Future<void> _upsertToSupabase(String userId, AvatarModel avatar) async {
    await SupabaseService().client!.from(SupabaseConfig.avatarsTable).upsert({
      'user_id': userId,
      'ashram': avatar.ashram.name,
      'wisdom_level': avatar.wisdomLevel,
      'karma_balance': avatar.karmaBalance,
      'streak_days': avatar.streakDays,
      'last_activity_at': avatar.lastActivityAt?.toIso8601String(),
      'updated_at': avatar.updatedAt.toIso8601String(),
    }, onConflict: 'user_id');
  }

  void dispose() {
    _avatarController.close();
  }
}
