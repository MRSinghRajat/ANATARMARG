import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/journey_models.dart';

/// Minimal local persistence for journeys so the free starter can be tested even
/// when the CMS/Supabase content is not yet imported or credentials are absent.
///
/// This store is intentionally scoped: it does not attempt to mirror the full
/// server schema. It only persists what the UI already uses.
class LocalJourneyStore {
  static const String _journeysKey = 'am_local_user_journeys_v1';
  static const String _taskCompletionsKey =
      'am_local_user_journey_task_completions_v1';

  static bool isLocalId(String id) => id.startsWith('local_');

  static Future<List<UserJourney>> getAllJourneysForUser(String userId) async {
    final all = await _loadJourneys();
    return all.where((j) => j.userId == userId).toList();
  }

  static Future<UserJourney?> getJourneyById(String id) async {
    final all = await _loadJourneys();
    for (final j in all) {
      if (j.id == id) return j;
    }
    return null;
  }

  static Future<void> upsertJourney(UserJourney journey) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _loadJourneys();
    final idx = all.indexWhere((j) => j.id == journey.id);
    if (idx >= 0) {
      all[idx] = journey;
    } else {
      all.add(journey);
    }
    await prefs.setString(_journeysKey, jsonEncode(all.map((j) => j.toJson()).toList()));
  }

  static Future<void> deleteJourney(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await _loadJourneys();
    all.removeWhere((j) => j.id == id);
    await prefs.setString(_journeysKey, jsonEncode(all.map((j) => j.toJson()).toList()));

    final completions = await _loadTaskCompletions();
    completions.remove(id);
    await prefs.setString(_taskCompletionsKey, jsonEncode(completions));
  }

  static Future<Set<String>> getCompletedTaskIdsForDate({
    required String userId,
    required String userJourneyId,
    required String yyyyMmDd,
  }) async {
    final journey = await getJourneyById(userJourneyId);
    if (journey == null || journey.userId != userId) return {};
    final completions = await _loadTaskCompletions();
    final byDate = completions[userJourneyId];
    if (byDate == null) return {};
    final list = byDate[yyyyMmDd];
    if (list is List) {
      return list.map((e) => e.toString()).where((s) => s.isNotEmpty).toSet();
    }
    return {};
  }

  static Future<void> upsertTaskCompletion({
    required String userId,
    required String userJourneyId,
    required String taskId,
    required String yyyyMmDd,
  }) async {
    final journey = await getJourneyById(userJourneyId);
    if (journey == null || journey.userId != userId) {
      throw StateError('Journey not found');
    }
    final prefs = await SharedPreferences.getInstance();
    final completions = await _loadTaskCompletions();
    completions[userJourneyId] ??= <String, dynamic>{};
    final byDate = completions[userJourneyId]!;
    final raw = byDate[yyyyMmDd];
    final list = raw is List ? raw.map((e) => e.toString()).toList() : <String>[];
    if (!list.contains(taskId)) list.add(taskId);
    byDate[yyyyMmDd] = list;
    await prefs.setString(_taskCompletionsKey, jsonEncode(completions));
  }

  static Future<void> removeTaskCompletion({
    required String userId,
    required String userJourneyId,
    required String taskId,
    required String yyyyMmDd,
  }) async {
    final journey = await getJourneyById(userJourneyId);
    if (journey == null || journey.userId != userId) return;
    final prefs = await SharedPreferences.getInstance();
    final completions = await _loadTaskCompletions();
    final byDate = completions[userJourneyId];
    if (byDate == null) return;
    final raw = byDate[yyyyMmDd];
    final list = raw is List ? raw.map((e) => e.toString()).toList() : <String>[];
    list.removeWhere((e) => e == taskId);
    byDate[yyyyMmDd] = list;
    await prefs.setString(_taskCompletionsKey, jsonEncode(completions));
  }

  static Future<List<UserJourney>> _loadJourneys() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_journeysKey);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => UserJourney.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, Map<String, dynamic>>> _loadTaskCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_taskCompletionsKey);
    if (raw == null || raw.trim().isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final out = <String, Map<String, dynamic>>{};
      decoded.forEach((k, v) {
        if (k is! String) return;
        if (v is Map) out[k] = Map<String, dynamic>.from(v);
      });
      return out;
    } catch (_) {
      return {};
    }
  }
}

