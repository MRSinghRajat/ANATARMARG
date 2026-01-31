import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/supabase_service.dart';
import '../datasources/supabase_verse_notes_datasource.dart';

/// Model for a verse note (shlok copy + user comment)
class VerseNoteModel {
  final String verseId;
  final String verseText;
  final String note;
  final String bookId;
  final String chapterId;
  final int shlokaNumber;
  final DateTime createdAt;

  VerseNoteModel({
    required this.verseId,
    required this.verseText,
    required this.note,
    required this.bookId,
    required this.chapterId,
    required this.shlokaNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'verseId': verseId,
        'verseText': verseText,
        'note': note,
        'bookId': bookId,
        'chapterId': chapterId,
        'shlokaNumber': shlokaNumber,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VerseNoteModel.fromJson(Map<String, dynamic> json) => VerseNoteModel(
        verseId: json['verseId'] as String,
        verseText: json['verseText'] as String,
        note: json['note'] as String,
        bookId: json['bookId'] as String,
        chapterId: json['chapterId'] as String,
        shlokaNumber: json['shlokaNumber'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// Service for bookmarks and verse notes.
/// When user is authenticated: saves to Supabase (persists across login).
/// When anonymous: uses SharedPreferences (local only).
class VerseNotesService {
  static const String _keyBookmarks = 'verse_bookmarks';
  static const String _keyNotes = 'verse_notes';

  static final VerseNotesService _instance = VerseNotesService._internal();
  factory VerseNotesService() => _instance;
  VerseNotesService._internal();

  final SupabaseService _supabase = SupabaseService();
  final SupabaseVerseNotesDataSource _supabaseNotes =
      SupabaseVerseNotesDataSource();

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  String? get _userId => _supabase.currentUserId;

  // --- Bookmarks ---
  Future<Set<String>> getBookmarkedVerseIds() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_keyBookmarks);
    return list != null ? list.toSet() : {};
  }

  Future<bool> isBookmarked(String verseId) async {
    final ids = await getBookmarkedVerseIds();
    return ids.contains(verseId);
  }

  Future<void> toggleBookmark(String verseId) async {
    final prefs = await _prefs;
    final ids = await getBookmarkedVerseIds();
    if (ids.contains(verseId)) {
      ids.remove(verseId);
    } else {
      ids.add(verseId);
    }
    await prefs.setStringList(_keyBookmarks, ids.toList());
  }

  // --- Notes (Supabase when auth, else local) ---
  Future<List<VerseNoteModel>> getNotesForBook(String bookId) async {
    final all = await _getAllNotes();
    return all.where((n) => n.bookId == bookId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<VerseNoteModel>> getNotesForChapter(String chapterId) async {
    final all = await _getAllNotes();
    return all.where((n) => n.chapterId == chapterId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<VerseNoteModel>> getNotesForVerse(String verseId) async {
    final all = await _getAllNotes();
    return all.where((n) => n.verseId == verseId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addNote(VerseNoteModel note) async {
    // Save to Supabase when authenticated
    final userId = _userId;
    if (userId != null && _supabase.isInitialized) {
      try {
        await _supabaseNotes.addNote(userId, note);
      } catch (_) {}
    }
    // Always save locally (fallback + offline)
    final all = await _getAllNotes();
    all.removeWhere((n) => n.verseId == note.verseId && n.note == note.note);
    all.insert(0, note);
    await _saveAllNotes(all);
  }

  Future<void> removeNote(String verseId, String note) async {
    final userId = _userId;
    if (userId != null && _supabase.isInitialized) {
      try {
        await _supabaseNotes.removeNote(userId, verseId, note);
      } catch (_) {}
    }
    final all = await _getAllNotes();
    all.removeWhere((n) => n.verseId == verseId && n.note == note);
    await _saveAllNotes(all);
  }

  Future<void> removeNoteByVerseId(String verseId) async {
    final all = await _getAllNotes();
    final toRemove = all.where((n) => n.verseId == verseId).toList();
    for (final n in toRemove) {
      await removeNote(n.verseId, n.note);
    }
  }

  Future<List<VerseNoteModel>> _getAllNotes() async {
    // Load from Supabase when authenticated (merge with local)
    final userId = _userId;
    if (userId != null && _supabase.isInitialized) {
      try {
        final supabaseNotes = await _supabaseNotes.getNotesForUser(userId);
        if (supabaseNotes.isNotEmpty) {
          final prefs = await _prefs;
          final jsonList = prefs.getStringList(_keyNotes);
          List<VerseNoteModel> local = [];
          if (jsonList != null) {
            local = jsonList
                .map((s) {
                  try {
                    return VerseNoteModel.fromJson(
                        jsonDecode(s) as Map<String, dynamic>);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<VerseNoteModel>()
                .toList();
          }
          final supabaseIds =
              supabaseNotes.map((n) => '${n.verseId}_${n.note}').toSet();
          for (final n in local) {
            if (!supabaseIds.contains('${n.verseId}_${n.note}')) {
              supabaseNotes.add(n);
            }
          }
          supabaseNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return supabaseNotes;
        }
      } catch (_) {}
    }
    final prefs = await _prefs;
    final jsonList = prefs.getStringList(_keyNotes);
    if (jsonList == null) return [];
    return jsonList
        .map((s) {
          try {
            return VerseNoteModel.fromJson(
                jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<VerseNoteModel>()
        .toList();
  }

  Future<void> _saveAllNotes(List<VerseNoteModel> notes) async {
    final prefs = await _prefs;
    final jsonList = notes.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_keyNotes, jsonList);
  }
}
