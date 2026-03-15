import 'package:shared_preferences/shared_preferences.dart';

/// Bookmarks for Granthalaya sacred texts and sacred stories (by id).
/// Verse bookmarks remain in VerseNotesService / BookProgressRepository.
class GranthalayaBookmarksService {
  static const String _keySacredTexts = 'granthalaya_bookmarks_sacred_texts';
  static const String _keySacredStories = 'granthalaya_bookmarks_sacred_stories';

  static final GranthalayaBookmarksService _instance =
      GranthalayaBookmarksService._internal();
  factory GranthalayaBookmarksService() => _instance;
  GranthalayaBookmarksService._internal();

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<Set<String>> getBookmarkedSacredTextIds() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_keySacredTexts);
    return list != null ? list.toSet() : {};
  }

  Future<Set<String>> getBookmarkedSacredStoryIds() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_keySacredStories);
    return list != null ? list.toSet() : {};
  }

  Future<bool> isSacredTextBookmarked(String id) async {
    final ids = await getBookmarkedSacredTextIds();
    return ids.contains(id);
  }

  Future<bool> isSacredStoryBookmarked(String id) async {
    final ids = await getBookmarkedSacredStoryIds();
    return ids.contains(id);
  }

  Future<void> toggleSacredTextBookmark(String id) async {
    final prefs = await _prefs;
    final ids = await getBookmarkedSacredTextIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await prefs.setStringList(_keySacredTexts, ids.toList());
  }

  Future<void> toggleSacredStoryBookmark(String id) async {
    final prefs = await _prefs;
    final ids = await getBookmarkedSacredStoryIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await prefs.setStringList(_keySacredStories, ids.toList());
  }
}
