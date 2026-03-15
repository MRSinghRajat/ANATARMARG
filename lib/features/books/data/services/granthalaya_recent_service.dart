import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/supabase_service.dart';

/// Tracks recently opened Granthalaya items for "Last Viewed" section.
/// Keys storage by user ID so new users don't see previous user's recents.
class GranthalayaRecentService {
  static const String _keyBooks = 'granthalaya_recent_books';
  static const String _keyTexts = 'granthalaya_recent_sacred_texts';
  static const String _keyStories = 'granthalaya_recent_sacred_stories';
  static const String _keyDeities = 'granthalaya_recent_deities';
  static const int _maxItems = 20;

  static final GranthalayaRecentService _instance =
      GranthalayaRecentService._internal();
  factory GranthalayaRecentService() => _instance;
  GranthalayaRecentService._internal();

  String get _userPrefix {
    final uid = SupabaseService().currentUserId;
    return (uid != null && uid.isNotEmpty) ? uid : 'guest';
  }

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<List<String>> _getOrderedIds(String baseKey) async {
    final key = '${baseKey}_$_userPrefix';
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(key);
    if (jsonList == null || jsonList.isEmpty) return [];
    final list = <Map<String, dynamic>>[];
    for (final s in jsonList) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        list.add(m);
      } catch (_) {}
    }
    list.sort((a, b) {
      final atA = a['at'] as String? ?? '';
      final atB = b['at'] as String? ?? '';
      return atB.compareTo(atA);
    });
    final ids = <String>[];
    final seen = <String>{};
    for (final m in list) {
      final id = m['id'] as String? ?? m['slug'] as String? ?? '';
      if (id.isNotEmpty && !seen.contains(id)) {
        seen.add(id);
        ids.add(id);
        if (ids.length >= _maxItems) break;
      }
    }
    return ids;
  }

  Future<void> _add(String baseKey, String idOrSlug) async {
    final key = '${baseKey}_$_userPrefix';
    final prefs = await _prefs;
    final existing = prefs.getStringList(key) ?? [];
    final now = DateTime.now().toIso8601String();
    final entry = jsonEncode({'id': idOrSlug, 'at': now});
    final updated = [entry, ...existing.where((s) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return (m['id'] as String? ?? m['slug'] as String?) != idOrSlug;
      } catch (_) {
        return true;
      }
    })].take(_maxItems).toList();
    await prefs.setStringList(key, updated);
  }

  Future<void> recordBookOpened(String bookId) async => _add(_keyBooks, bookId);
  Future<void> recordSacredTextOpened(String id) async => _add(_keyTexts, id);
  Future<void> recordSacredStoryOpened(String id) async => _add(_keyStories, id);
  Future<void> recordDeityOpened(String slug) async => _add(_keyDeities, slug);

  Future<List<String>> getRecentBookIds() async => _getOrderedIds(_keyBooks);
  Future<List<String>> getRecentSacredTextIds() async =>
      _getOrderedIds(_keyTexts);
  Future<List<String>> getRecentSacredStoryIds() async =>
      _getOrderedIds(_keyStories);
  Future<List<String>> getRecentDeitySlugs() async => _getOrderedIds(_keyDeities);
}
