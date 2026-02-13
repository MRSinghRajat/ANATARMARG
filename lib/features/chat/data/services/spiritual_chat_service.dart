import '../models/spiritual_service.dart';
import '../config/spiritual_service_prompts.dart';
import '../../../content/data/datasources/gpt_api_service.dart';

/// Service for handling spiritual chat interactions with GPT API.
class SpiritualChatService {
  final GPTApiService _gptService = GPTApiService();

  /// Send a message to the AI spiritual advisor and get a response.
  /// 
  /// [service] - The spiritual service type (numerology, kundli, etc.)
  /// [userMessage] - The user's message
  /// [userProfile] - Optional user profile data (name, DOB, etc.)
  /// [history] - Previous conversation history in GPT format
  /// [imageBase64] - Optional base64 image for palmistry
  Future<String> chat({
    required SpiritualServiceType service,
    required String userMessage,
    Map<String, dynamic>? userProfile,
    List<Map<String, String>>? history,
    String? imageBase64,
  }) async {
    final systemPrompt = _buildSystemPrompt(service, userProfile);
    
    return await _gptService.chatWithSpiritualService(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      history: history ?? [],
      imageBase64: imageBase64,
    );
  }

  /// Build the system prompt with service-specific instructions and user profile context.
  String _buildSystemPrompt(SpiritualServiceType service, Map<String, dynamic>? userProfile) {
    final basePrompt = SpiritualServicePrompts.getSystemPrompt(service);
    
    if (userProfile == null || userProfile.isEmpty) {
      return basePrompt;
    }

    // Add user profile context to the system prompt
    final profileContext = StringBuffer();
    profileContext.writeln('\n\n--- USER PROFILE ---');
    userProfile.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        final label = key.replaceAll('_', ' ').split(' ').map((w) => 
          w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}'
        ).join(' ');
        profileContext.writeln('$label: $value');
      }
    });
    profileContext.writeln('--- END USER PROFILE ---');
    profileContext.writeln('\nUse this profile information when providing readings and guidance.');

    return basePrompt + profileContext.toString();
  }
}
