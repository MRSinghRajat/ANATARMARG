class SupabaseConfig {
  // TODO: Replace with your Supabase project URL and anon key
  static const String supabaseUrl = 'https://qyikatemonzykqamtvod.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5aWthdGVtb256eWtxYW10dm9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2NTQzMDIsImV4cCI6MjA4NTIzMDMwMn0.YlulvY1iIlK-pBNkFdmKMwnfn0avMfQO35KW-Z7plAA';

  // TODO: Add Google Web Client ID (Required for Supabase Auth)
  // This can be found in your Google Cloud Console Credentials > OAuth 2.0 Client IDs
  static const String googleWebClientId = '';

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
