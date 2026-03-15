import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase persistence for user daily streak (one row per user).
class DailyStreakRepository {
  DailyStreakRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'user_daily_streak';

  String? get _userId => _client.auth.currentUser?.id;

  /// Fetch streak row for current user. Returns null if not found or error.
  Future<UserDailyStreakRow?> fetch() async {
    final uid = _userId;
    if (uid == null) return null;

    try {
      final res = await _client
          .from(_table)
          .select()
          .eq('user_id', uid)
          .maybeSingle();

      if (res == null) return null;
      return UserDailyStreakRow.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      print('DailyStreakRepository.fetch: $e');
      return null;
    }
  }

  /// Upsert streak row (insert or update). Uses user_id from auth.
  Future<UserDailyStreakRow?> upsert({
    required String lastActiveDate,
    required int currentStreak,
    bool? hasSeenDay1Celebration,
    bool? hasCommittedGoal,
    int? committedGoalDays,
  }) async {
    final uid = _userId;
    if (uid == null) return null;

    try {
      final payload = <String, dynamic>{
        'user_id': uid,
        'last_active_date': lastActiveDate,
        'current_streak': currentStreak,
      };
      if (hasSeenDay1Celebration != null) {
        payload['has_seen_day1_celebration'] = hasSeenDay1Celebration;
      }
      if (hasCommittedGoal != null) {
        payload['has_committed_goal'] = hasCommittedGoal;
      }
      if (committedGoalDays != null) {
        payload['committed_goal_days'] = committedGoalDays;
      }

      final res = await _client
          .from(_table)
          .upsert(
            payload,
            onConflict: 'user_id',
          )
          .select()
          .single();

      return UserDailyStreakRow.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      print('DailyStreakRepository.upsert: $e');
      return null;
    }
  }

  /// Update only commitment fields.
  Future<UserDailyStreakRow?> setCommittedGoal(int days) async {
    final uid = _userId;
    if (uid == null) return null;

    try {
      final res = await _client
          .from(_table)
          .update({
            'has_committed_goal': true,
            'committed_goal_days': days,
          })
          .eq('user_id', uid)
          .select()
          .maybeSingle();

      if (res == null) return null;
      return UserDailyStreakRow.fromJson(res as Map<String, dynamic>);
    } catch (e) {
      print('DailyStreakRepository.setCommittedGoal: $e');
      return null;
    }
  }
}

/// One row from user_daily_streak.
class UserDailyStreakRow {
  final String userId;
  final String lastActiveDate;
  final int currentStreak;
  final bool hasSeenDay1Celebration;
  final bool hasCommittedGoal;
  final int? committedGoalDays;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserDailyStreakRow({
    required this.userId,
    required this.lastActiveDate,
    required this.currentStreak,
    this.hasSeenDay1Celebration = false,
    this.hasCommittedGoal = false,
    this.committedGoalDays,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDailyStreakRow.fromJson(Map<String, dynamic> json) {
    return UserDailyStreakRow(
      userId: json['user_id'] as String,
      lastActiveDate: json['last_active_date'] as String,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      hasSeenDay1Celebration:
          json['has_seen_day1_celebration'] as bool? ?? false,
      hasCommittedGoal: json['has_committed_goal'] as bool? ?? false,
      committedGoalDays: (json['committed_goal_days'] as num?)?.toInt(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}
