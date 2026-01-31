import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Google Web Client ID (Required for Supabase Auth)
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  // Table names
  static const String parvasTable = 'parvas';
  static const String questStagesTable = 'quest_stages';
  static const String userProgressTable = 'user_progress';
  static const String userParvaProgressTable = 'user_parva_progress';

  // Books, Chapters, Verses tables
  static const String booksTable = 'books';
  static const String chaptersTable = 'chapters';
  static const String versesTable = 'verses';

  static const String verseTranslationsTable = 'verse_translations';
  static const String userBookProgressTable = 'user_book_progress';
  static const String userChapterProgressTable = 'user_chapter_progress';
  static const String userVerseProgressTable = 'user_verse_progress';
  static const String userVerseNotesTable = 'user_verse_notes';

  // Avatar (Inner Self)
  static const String avatarsTable = 'avatars';
}
