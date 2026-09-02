import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/daily_streak_repository.dart';
import '../utils/app_clock.dart';

/// Tracks daily app engagement streak: last active date, current streak count,
/// and optional user-committed goal. Persists to Supabase per user when logged in,
/// with SharedPreferences as local cache and fallback for anonymous/offline.
class DailyStreakService {
  DailyStreakService._();
  static final DailyStreakService instance = DailyStreakService._();

  static const String _keyPrefix = 'daily_streak_';
  static const String _keyLastActiveDate = '${_keyPrefix}last_active_date';
  static const String _keyCurrentStreak = '${_keyPrefix}current_streak';
  static const String _keyHasSeenDay1Celebration = '${_keyPrefix}seen_day1';
  static const String _keyHasCommittedGoal = '${_keyPrefix}committed_goal';
  static const String _keyCommittedGoalDays = '${_keyPrefix}committed_goal_days';
  static const String _keyUserId = '${_keyPrefix}user_id';

  /// Days without opening app to show "We missed you" (re-engagement). 2+ = streak broken.
  static const int missedYouThresholdDays = 2;

  SharedPreferences? _prefs;
  String? _userId;
  DailyStreakRepository? _repo;

  DailyStreakRepository get _streakRepo => _repo ??= DailyStreakRepository();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  void setUserId(String? userId) {
    _userId = userId;
    _prefs?.setString(_keyUserId, userId ?? '');
  }

  String? get _userPrefix => _userId != null && _userId!.isNotEmpty ? _userId! : 'device';

  String get _kLastActive => '${_keyLastActiveDate}_$_userPrefix';
  String get _kCurrentStreak => '${_keyCurrentStreak}_$_userPrefix';
  String get _kSeenDay1 => '${_keyHasSeenDay1Celebration}_$_userPrefix';
  String get _kCommittedGoal => '${_keyHasCommittedGoal}_$_userPrefix';
  String get _kCommittedDays => '${_keyCommittedGoalDays}_$_userPrefix';

  bool get _useSupabase => _userId != null && _userId!.isNotEmpty;

  /// Sync row from Supabase into local prefs (so logic and getters use same state).
  Future<void> _syncFromSupabase(UserDailyStreakRow row) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_kLastActive, row.lastActiveDate);
    await prefs.setInt(_kCurrentStreak, row.currentStreak);
    await prefs.setBool(_kSeenDay1, row.hasSeenDay1Celebration);
    await prefs.setBool(_kCommittedGoal, row.hasCommittedGoal);
    if (row.committedGoalDays != null) {
      await prefs.setInt(_kCommittedDays, row.committedGoalDays!);
    }
  }

  /// Call when user opens the app (e.g. on home load). Returns what to show.
  /// When logged in, loads and saves streak in Supabase for the user.
  Future<DailyStreakResult> recordVisitAndGetPrompt() async {
    await init();
    final prefs = _prefs!;
    final today = _todayString();

    if (_useSupabase) {
      final row = await _streakRepo.fetch();
      if (row != null) {
        await _syncFromSupabase(row);
      }
    }

    final last = prefs.getString(_kLastActive);
    final streak = prefs.getInt(_kCurrentStreak) ?? 0;
    final seenDay1 = prefs.getBool(_kSeenDay1) ?? false;
    final hasCommitted = prefs.getBool(_kCommittedGoal) ?? false;

    // First time ever
    if (last == null || last.isEmpty) {
      await prefs.setString(_kLastActive, today);
      await prefs.setInt(_kCurrentStreak, 1);
      await prefs.setBool(_kSeenDay1, true);
      if (_useSupabase) {
        await _streakRepo.upsert(
          lastActiveDate: today,
          currentStreak: 1,
          hasSeenDay1Celebration: true,
        );
      }
      return DailyStreakResult(
        prompt: DailyStreakPrompt.day1,
        currentStreak: 1,
        showCommitmentAfter: !hasCommitted,
      );
    }

    final lastDate = DateTime.tryParse(last);
    if (lastDate == null) {
      await prefs.setString(_kLastActive, today);
      await prefs.setInt(_kCurrentStreak, 1);
      if (_useSupabase) {
        await _streakRepo.upsert(
          lastActiveDate: today,
          currentStreak: 1,
          hasSeenDay1Celebration: true,
        );
      }
      return DailyStreakResult(prompt: DailyStreakPrompt.day1, currentStreak: 1, showCommitmentAfter: !hasCommitted);
    }

    final todayDate = DateTime.parse(today);
    final diffDays = todayDate.difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;

    // Already counted today
    if (diffDays == 0) {
      return DailyStreakResult(
        prompt: DailyStreakPrompt.none,
        currentStreak: streak,
      );
    }

    // Yesterday: continue streak
    if (diffDays == 1) {
      final newStreak = streak + 1;
      await prefs.setString(_kLastActive, today);
      await prefs.setInt(_kCurrentStreak, newStreak);
      if (_useSupabase) {
        await _streakRepo.upsert(
          lastActiveDate: today,
          currentStreak: newStreak,
          hasSeenDay1Celebration: seenDay1,
          hasCommittedGoal: hasCommitted,
          committedGoalDays: prefs.getInt(_kCommittedDays),
        );
      }
      return DailyStreakResult(
        prompt: DailyStreakPrompt.streakCount,
        currentStreak: newStreak,
        showStreakCelebration: true,
      );
    }

    // Missed threshold+ days: streak broken, show "We missed you" and let them restart
    if (diffDays >= missedYouThresholdDays) {
      return DailyStreakResult(
        prompt: DailyStreakPrompt.missedYou,
        currentStreak: 0,
        previousStreak: streak,
      );
    }

    return DailyStreakResult(
      prompt: DailyStreakPrompt.none,
      currentStreak: streak,
    );
  }

  /// Call when user taps "Start today" on missed-you screen. Resets to day 1 in DB and local.
  Future<void> restartStreakToday() async {
    await init();
    final prefs = _prefs!;
    final today = _todayString();
    await prefs.setString(_kLastActive, today);
    await prefs.setInt(_kCurrentStreak, 1);
    if (_useSupabase) {
      await _streakRepo.upsert(
        lastActiveDate: today,
        currentStreak: 1,
        hasSeenDay1Celebration: true,
        hasCommittedGoal: prefs.getBool(_kCommittedGoal) ?? false,
        committedGoalDays: prefs.getInt(_kCommittedDays),
      );
    }
  }

  /// Save commitment: how many days in a row user aims to practice. Persists to Supabase when logged in.
  Future<void> setCommittedGoal(int days) async {
    await init();
    await _prefs!.setBool(_kCommittedGoal, true);
    await _prefs!.setInt(_kCommittedDays, days);
    if (_useSupabase) {
      await _streakRepo.setCommittedGoal(days);
    }
  }

  int? get committedGoalDays {
    final v = _prefs?.getInt(_kCommittedDays);
    return v;
  }

  bool get hasCommittedGoal => _prefs?.getBool(_kCommittedGoal) ?? false;

  int get currentStreak => _prefs?.getInt(_kCurrentStreak) ?? 0;

  String get lastActiveDate => _prefs?.getString(_kLastActive) ?? '';

  static String _todayString() => AppClock.todayString();

  @visibleForTesting
  Future<void> debugResetForTests() async {
    _userId = null;
    _prefs = null;
    _repo = null;
    await init();
    final prefs = _prefs;
    if (prefs == null) return;
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}

enum DailyStreakPrompt {
  none,
  day1,
  missedYou,
  streakCount,
  commitment,
}

class DailyStreakResult {
  final DailyStreakPrompt prompt;
  final int currentStreak;
  final int? previousStreak;
  final bool showStreakCelebration;
  final bool showCommitmentAfter;

  const DailyStreakResult({
    required this.prompt,
    this.currentStreak = 0,
    this.previousStreak,
    this.showStreakCelebration = false,
    this.showCommitmentAfter = false,
  });
}
