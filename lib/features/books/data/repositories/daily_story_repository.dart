import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/utils/app_clock.dart';
import '../models/daily_story_model.dart';

class DailyStoryRepository {
  final _supabase = Supabase.instance.client;

  /// Fetch all active stories, optionally filtered by category.
  Future<List<DailyStoryModel>> getAllStories({String? category}) async {
    var query = _supabase
        .from(SupabaseConfig.dailyStoriesTable)
        .select()
        .eq('is_active', true);

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final data = await query.order('day_of_year', ascending: true);

    return (data as List)
        .map((json) => DailyStoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all distinct categories.
  Future<List<String>> getCategories() async {
    final data = await _supabase
        .from(SupabaseConfig.dailyStoriesTable)
        .select('category')
        .eq('is_active', true);

    final categories = <String>{};
    for (final row in (data as List)) {
      final cat = row['category'] as String?;
      if (cat != null && cat.isNotEmpty) categories.add(cat);
    }
    final sorted = categories.toList()..sort();
    return sorted;
  }

  /// Fetch today's story using deterministic day-of-year selection.
  /// Only fetches 1 row instead of the entire table.
  Future<DailyStoryModel?> getStoryForToday() async {
    final now = AppClock.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;

    // Try exact match first
    final exact = await _supabase
        .from(SupabaseConfig.dailyStoriesTable)
        .select()
        .eq('is_active', true)
        .eq('day_of_year', dayOfYear)
        .maybeSingle();

    if (exact != null) {
      return DailyStoryModel.fromJson(exact);
    }

    // Fallback: count active stories, pick one deterministically
    final countResult = await _supabase
        .from(SupabaseConfig.dailyStoriesTable)
        .select('id')
        .eq('is_active', true);

    final total = (countResult as List).length;
    if (total == 0) return null;

    final offset = dayOfYear % total;
    final fallback = await _supabase
        .from(SupabaseConfig.dailyStoriesTable)
        .select()
        .eq('is_active', true)
        .order('day_of_year', ascending: true)
        .range(offset, offset);

    final list = fallback as List;
    if (list.isEmpty) return null;
    return DailyStoryModel.fromJson(list.first as Map<String, dynamic>);
  }

  /// Fetch a single story by ID.
  Future<DailyStoryModel?> getStoryById(String id) async {
    final data = await _supabase
        .from(SupabaseConfig.dailyStoriesTable)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return DailyStoryModel.fromJson(data);
  }
}
