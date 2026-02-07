import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/verse_model.dart';
import '../models/chapter_model.dart';

class GPTApiService {
  static final GPTApiService _instance = GPTApiService._internal();
  factory GPTApiService() => _instance;
  GPTApiService._internal();

  final SupabaseService _supabase = SupabaseService();

  static const String _model = 'gpt-4';
  static const int _maxTokens = 1000;

  Future<VerseContent> getVerse({
    required String book,
    String? chapter,
    String? character,
    bool random = false,
  }) async {
    final prompt = ApiConfig.getVersePrompt(book, chapter, character);

    final response = await _makeChatRequest([
      {
        'role': 'system',
        'content':
            'You are a wise guide helping users understand ancient Indian scriptures. Provide concise, spiritual, and reflective summaries suitable for 2-minute daily reading.',
      },
      {
        'role': 'user',
        'content': prompt,
      },
    ]);

    final content = response['choices'][0]['message']['content'] as String;

    return VerseContent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      book: book,
      chapter: chapter,
      title: _extractTitle(content),
      content: content,
      context: _extractContext(content),
      relatedCharacters: character != null ? [character] : null,
      createdAt: DateTime.now(),
    );
  }

  /// Get chapter summary - hybrid approach: check database first, generate if needed
  Future<ChapterContent> getChapterSummary({
    required String book,
    required String chapterId,
  }) async {
    // Try to get summary from database first (hybrid approach)
    if (_supabase.isInitialized) {
      try {
        final response = await _supabase.client!
            .from(SupabaseConfig.chaptersTable)
            .select(
                'id, title, summary, key_themes, key_characters, estimated_reading_minutes')
            .eq('id', chapterId)
            .maybeSingle();

        // Supabase v2 may return PostgrestResponse with .data
        final data = response is Map<String, dynamic>
            ? response
            : (response as dynamic)?.data as Map<String, dynamic>?;

        if (data != null &&
            data['summary'] != null &&
            (data['summary'] as String).isNotEmpty) {
          // Found summary in database
          return ChapterContent(
            id: data['id'] as String,
            book: book,
            chapterId: chapterId,
            chapterNumber: chapterId,
            title: data['title'] as String,
            summary: data['summary'] as String,
            estimatedReadingMinutes:
                data['estimated_reading_minutes'] as int? ?? 2,
            keyThemes: data['key_themes'] != null
                ? List<String>.from(data['key_themes'] as List)
                : null,
            keyCharacters: data['key_characters'] != null
                ? List<String>.from(data['key_characters'] as List)
                : null,
            createdAt: DateTime.now(),
          );
        }
      } catch (e) {
        print('Error checking database for chapter summary: $e');
        // Continue to GPT generation
      }
    }

    // Generate summary using GPT (fallback or when not in database)
    final prompt = ApiConfig.getChapterSummaryPrompt(book, chapterId);

    final response = await _makeChatRequest([
      {
        'role': 'system',
        'content':
            'You are a wise guide helping users understand ancient Indian scriptures. Provide concise summaries focusing on key teachings, characters, and spiritual insights. Keep summaries to approximately 2 minutes of reading time.',
      },
      {
        'role': 'user',
        'content': prompt,
      },
    ]);

    final content = response['choices'][0]['message']['content'] as String;

    final chapterContent = ChapterContent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      book: book,
      chapterId: chapterId,
      chapterNumber: chapterId,
      title: _extractTitle(content),
      summary: content,
      estimatedReadingMinutes: 2,
      createdAt: DateTime.now(),
    );

    // Cache the generated summary in database (hybrid approach)
    if (_supabase.isInitialized) {
      try {
        await _supabase.client!.from(SupabaseConfig.chaptersTable).update({
          'summary': content,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', chapterId);
      } catch (e) {
        print('Error caching chapter summary in database: $e');
        // Continue even if caching fails
      }
    }

    return chapterContent;
  }

  /// Generate verse reflection/commentary (always uses GPT, can be cached)
  Future<String> getVerseReflection({
    required String book,
    required String chapterId,
    required String verseNumber,
    required String verseText,
  }) async {
    final prompt =
        'Provide a brief spiritual reflection and commentary on this verse from $book, Chapter $chapterId, Verse $verseNumber:\n\n$verseText\n\nKeep it concise, insightful, and suitable for contemplation.';

    final response = await _makeChatRequest([
      {
        'role': 'system',
        'content':
            'You are a wise guide helping users understand ancient Indian scriptures. Provide brief, insightful reflections on verses that deepen understanding and spiritual insight.',
      },
      {
        'role': 'user',
        'content': prompt,
      },
    ]);

    return response['choices'][0]['message']['content'] as String;
  }

  Future<String> chatWithBook({
    required String book,
    String? bookDescription,
    String? category,
    required String userMessage,
    required List<Map<String, String>> history,
  }) async {
    final systemPrompt = ApiConfig.getBookChatSystemPrompt(
      bookName: book,
      bookDescription: bookDescription,
      category: category,
    );

    final messages = [
      {
        'role': 'system',
        'content': systemPrompt,
      },
      ...history,
      {
        'role': 'user',
        'content': userMessage,
      },
    ];

    final response = await _makeChatRequest(messages);
    return response['choices'][0]['message']['content'] as String;
  }

  Future<VerseContent> getVerseOfTheDay() async {
    final prompt = ApiConfig.getVerseOfTheDayPrompt();

    final response = await _makeChatRequest([
      {
        'role': 'system',
        'content':
            'You are a wise guide helping users understand ancient Indian scriptures. Provide a beautiful, inspiring verse of the day that is spiritually meaningful and suitable for daily contemplation. Format: Book Name Chapter:Verse - Verse text. Include a brief reflection.',
      },
      {
        'role': 'user',
        'content': prompt,
      },
    ]);

    final content = response['choices'][0]['message']['content'] as String;

    // Parse the verse reference and content
    final lines = content.split('\n');
    String verseReference = 'Verse of the Day';
    String verseText = content;

    // Try to extract reference from first line
    if (lines.isNotEmpty) {
      final firstLine = lines[0].trim();
      if (firstLine.contains(':') || firstLine.contains('Chapter')) {
        verseReference = firstLine;
        verseText = lines.skip(1).join('\n').trim();
      }
    }

    return VerseContent(
      id: 'verse_of_day_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}',
      book: 'Daily Wisdom',
      chapter: null,
      title: verseReference,
      content: verseText,
      context: verseText.length > 300
          ? '${verseText.substring(0, 300)}...'
          : verseText,
      relatedCharacters: null,
      createdAt: DateTime.now(),
    );
  }

  Future<Map<String, dynamic>> _makeChatRequest(
      List<Map<String, dynamic>> messages) async {
    if (AppConfig.gptApiKey.isEmpty) {
      throw Exception('GPT API key not configured');
    }

    final url =
        Uri.parse('${AppConfig.gptApiBaseUrl}${ApiConfig.chatEndpoint}');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AppConfig.gptApiKey}',
          },
          body: jsonEncode({
            'model': _model,
            'messages': messages,
            'max_tokens': _maxTokens,
            'temperature': 0.7,
          }),
        )
        .timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'GPT API error: ${response.statusCode} - ${response.body}');
    }
  }

  String _extractTitle(String content) {
    // Simple extraction - first line or first sentence
    final lines = content.split('\n');
    if (lines.isNotEmpty && lines[0].trim().isNotEmpty) {
      return lines[0].trim();
    }
    final sentences = content.split('.');
    return sentences.isNotEmpty ? sentences[0].trim() : 'Reading';
  }

  String? _extractContext(String content) {
    // Extract context if available
    if (content.length > 200) {
      return '${content.substring(0, 200)}...';
    }
    return null;
  }
}
