class ApiConfig {
  // GPT API Endpoints
  static const String chatEndpoint = '/chat/completions';
  static const String modelsEndpoint = '/models';

  // Request Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Content Generation Prompts
  static String getVersePrompt(
      String book, String? chapter, String? character) {
    return 'Generate a 2-minute reading summary from $book${chapter != null ? ", chapter $chapter" : ""}${character != null ? ", focusing on $character" : ""}. Make it spiritual, reflective, and suitable for daily reading.';
  }

  static String getChapterSummaryPrompt(String book, String chapterId) {
    return 'Provide a concise summary of $book, chapter $chapterId. Focus on key teachings, characters, and spiritual insights. Keep it to approximately 2 minutes of reading time. Do NOT start with "Chapter X of Bhagavad Gita" or similar - the chapter name is already shown in the app header.';
  }

  static String getBookChatSystemPrompt(String book) {
    return 'You are a wise guide helping users understand $book. Answer questions with wisdom, clarity, and respect for the ancient teachings. Be concise and reflective.';
  }

  static String getVerseOfTheDayPrompt() {
    return 'Generate a beautiful, inspiring verse of the day from ancient Indian scriptures (Mahabharata, Ramayana, or Bhagavad Gita). Choose a verse that is spiritually meaningful, reflective, and suitable for daily contemplation. Include the book name, chapter, and verse number. Make it profound yet accessible.';
  }
}
