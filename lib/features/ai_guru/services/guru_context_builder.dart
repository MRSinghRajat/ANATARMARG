import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_clock.dart';
import '../../../shared/services/feature_gate_config.dart';
import '../constants/guru_prompts.dart';

class GuruContextBuilder {
  final SupabaseClient _supabase;

  GuruContextBuilder(this._supabase);

  /// [serviceMode] matches keys in [GuruPrompts.serviceSub] or `'general'` for Ask Anything.
  ///
  /// Bounded wait so a slow Supabase region or join does not block the chat for minutes.
  Future<String> buildSystemPrompt({
    required String userId,
    required UserTier tier,
    required String serviceMode,
  }) async {
    try {
      return await _buildSystemPromptFromSupabase(
        userId: userId,
        tier: tier,
        serviceMode: serviceMode,
      ).timeout(
        const Duration(seconds: 12),
        onTimeout: () => _degradedSystemPrompt(serviceMode),
      );
    } catch (_) {
      return _degradedSystemPrompt(serviceMode);
    }
  }

  /// Base persona + service instructions only (no DB). Used when Supabase is slow or errors.
  String _degradedSystemPrompt(String serviceMode) {
    final sub = GuruPrompts.serviceSub[serviceMode] ?? '';
    final extra = serviceMode == 'general'
        ? ''
        : '\n(User context could not be loaded in time — rely on what they tell you in the thread.)\n';
    return '${GuruPrompts.base}$extra$sub';
  }

  Future<String> _buildSystemPromptFromSupabase({
    required String userId,
    required UserTier tier,
    required String serviceMode,
  }) async {
    final futures = <Future<dynamic>>[
      _fetchStreak(userId),
      _fetchUserName(userId),
    ];
    if (tier != UserTier.free) {
      futures.addAll([
        _fetchActiveJourneyContext(userId),
        _fetchTodayTasksFlags(userId),
        _fetchLastVerse(userId),
      ]);
    }
    if (tier == UserTier.pro) {
      futures.addAll([
        _fetchBookmarks(userId),
      ]);
    }

    final results = await Future.wait(futures);

    final streak = results[0] as int;
    final name = results[1] as String;

    var contextBlock = '''

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 USER CONTEXT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name: $name
Streak: $streak days
Service: $serviceMode''';

    if (tier == UserTier.free) {
      final subPrompt = GuruPrompts.serviceSub[serviceMode] ?? '';
      return '${GuruPrompts.base}$contextBlock\n$subPrompt';
    }

    final journeyCtx = results[2] as String;
    final taskFlags = results[3] as Map<String, bool>;
    final lastVerse = results[4] as String?;

    contextBlock += '''
Today: Prayer=${taskFlags['prayer']! ? 'done' : 'not yet'} | Verse=${taskFlags['verse']! ? 'done' : 'not yet'} | Journey=${taskFlags['journey']! ? 'done' : 'not yet'}
Journey: $journeyCtx
Last verse read: ${lastVerse ?? 'none yet'}''';

    if (tier == UserTier.pro) {
      final bookmarks = results[5] as List<String>;
      contextBlock += '''
Bookmarks: ${bookmarks.isEmpty ? 'none' : bookmarks.join(', ')}''';
    }

    final subPrompt = GuruPrompts.serviceSub[serviceMode] ?? '';
    return '${GuruPrompts.base}$contextBlock\n$subPrompt';
  }

  Future<int> _fetchStreak(String uid) async {
    final res = await _supabase
        .from('user_spiritual_progress')
        .select('current_streak')
        .eq('user_id', uid)
        .maybeSingle();
    return (res?['current_streak'] as num?)?.toInt() ?? 0;
  }

  Future<String> _fetchUserName(String uid) async {
    final res = await _supabase
        .from('app_profiles')
        .select('display_name')
        .eq('user_id', uid)
        .maybeSingle();
    final n = res?['display_name'] as String?;
    if (n != null && n.trim().isNotEmpty) return n.trim();
    return 'Sadhak';
  }

  Future<String> _fetchActiveJourneyContext(String uid) async {
    final res = await _supabase
        .from('user_journeys')
        .select(
          'metadata, start_date, current_phase_id, journey_types(slug, title)',
        )
        .eq('user_id', uid)
        .eq('status', 'active')
        .order('start_date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (res == null) return 'No active journey';

    final jt = res['journey_types'];
    final meta = res['metadata'] as Map<String, dynamic>? ?? {};
    String slug = '';
    String title = 'Journey';
    if (jt is Map) {
      slug = jt['slug'] as String? ?? '';
      title = jt['title'] as String? ?? title;
    }

    String phaseName = '';
    final phaseId = res['current_phase_id'] as String?;
    if (phaseId != null) {
      final phase = await _supabase
          .from('journey_phases')
          .select('title, slug')
          .eq('id', phaseId)
          .maybeSingle();
      phaseName = phase?['title'] as String? ?? '';
    }

    final start = res['start_date'] as String?;
    var line = '$title — Phase: ${phaseName.isEmpty ? '—' : phaseName}';
    if (start != null && start.isNotEmpty) {
      final sd = DateTime.tryParse(start);
      if (sd != null) {
        final days = AppClock.now().difference(sd).inDays + 1;
        line += ', Day $days';
      }
    }
    if (slug == 'garbh-sanskar') {
      line += ' (due: ${meta['due_date'] ?? 'unknown'})';
    }
    if (slug == 'little-sadhu') {
      line += ' (child: ${meta['child_name'] ?? ''})';
    }
    return line;
  }

  Future<Map<String, bool>> _fetchTodayTasksFlags(String uid) async {
    final today = AppClock.todayString();
    final rows = await _supabase
        .from('user_daily_tasks')
        .select('status, dynamic_content, daily_task_templates(slug, category)')
        .eq('user_id', uid)
        .eq('task_date', today);

    var prayer = false;
    var verse = false;
    var journey = false;

    for (final row in rows as List) {
      final map = Map<String, dynamic>.from(row as Map);
      final st = map['status'] as String? ?? '';
      if (st != 'completed') continue;
      final tpl = map['daily_task_templates'];
      if (tpl is! Map) continue;
      final slug = (tpl['slug'] as String? ?? '').toLowerCase();
      final cat = (tpl['category'] as String? ?? '').toLowerCase();
      final dyn = map['dynamic_content'];

      if (slug == 'daily_verse' || cat == 'scripture') verse = true;
      if (cat == 'devotion' ||
          slug.contains('aarti') ||
          slug.contains('japa') ||
          slug == 'listen_chant') {
        prayer = true;
      }
      if (slug.contains('journey') ||
          slug.contains('milestone') ||
          (dyn is Map && dyn['journey_task'] == true)) {
        journey = true;
      }
    }

    return {'prayer': prayer, 'verse': verse, 'journey': journey};
  }

  Future<String?> _fetchLastVerse(String uid) async {
    final res = await _supabase
        .from('user_verse_progress')
        .select('verse_id')
        .eq('user_id', uid)
        .eq('is_read', true)
        .order('read_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return res?['verse_id'] as String?;
  }

  Future<List<String>> _fetchBookmarks(String uid) async {
    final rows = await _supabase
        .from('user_verse_progress')
        .select('verse_id')
        .eq('user_id', uid)
        .eq('is_bookmarked', true)
        .limit(3);
    return (rows as List)
        .map((r) => (r as Map)['verse_id'] as String)
        .whereType<String>()
        .toList();
  }
}
