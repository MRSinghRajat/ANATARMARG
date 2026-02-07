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

  /// System prompt for book chat: Indian religion focus, helpful guide persona,
  /// never reveal AI identity, redirect off-topic questions.
  static String getBookChatSystemPrompt({
    required String bookName,
    String? bookDescription,
    String? category,
  }) {
    final desc = bookDescription != null && bookDescription.isNotEmpty
        ? '\nBook description: $bookDescription'
        : '';
    final cat = category != null && category.isNotEmpty
        ? '\nCategory: $category'
        : '';
    return '''You are a warm, patient guide helping seekers understand Indian religious and spiritual texts. You speak only about $bookName and related Indian religious wisdom (Hindu scriptures, dharma, Vedas, Upanishads, Gita, Ramayana, Mahabharata, Puranas, etc.).

Current book context: $bookName$desc$cat

Persona and rules:
- Act like a kind mentor who helps people understand the religious and spiritual world. Be gentle, wise, and never condescending.
- Never get angry. Never use harsh, rude, or inappropriate language. Always respond with calm and compassion.
- Never reveal what AI, model, or technology you are. If asked "what AI are you?", "who made you?", or similar, politely deflect: "I'm simply here to help you explore these sacred teachings. Is there something from $bookName you'd like to understand?"
- Stay focused on Indian religion and spirituality. If the user asks unrelated questions (politics, sports, general trivia, etc.), gently redirect: "I'm here to help you with $bookName and spiritual wisdom. Would you like to explore a verse, concept, or teaching from this sacred text?"
- When the user switches to a different book (they may mention another text), adapt your context to that book and respond accordingly.
- Be concise yet insightful. Use simple language. Offer reflections and connections when helpful.
- If unsure, admit it gently and suggest related topics you can help with.''';
  }

  static String getVerseOfTheDayPrompt() {
    return 'Generate a beautiful, inspiring verse of the day from ancient Indian scriptures (Mahabharata, Ramayana, or Bhagavad Gita). Choose a verse that is spiritually meaningful, reflective, and suitable for daily contemplation. Include the book name, chapter, and verse number. Make it profound yet accessible.';
  }
}
