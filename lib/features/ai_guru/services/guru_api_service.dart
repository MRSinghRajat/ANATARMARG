import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/services/feature_gate_config.dart';
import '../models/guru_message.dart';
import '../repositories/guru_repository.dart';
import 'guru_ai_credits_service.dart';
import 'guru_context_builder.dart';
import 'guru_spiritual_service_ext.dart';
import '../../chat/data/models/spiritual_service.dart';

class GuruSendResult {
  final bool success;
  final String? reply;
  final String? errorMessage;
  final bool isQuotaExceeded;
  final UserTier? tier;

  const GuruSendResult._({
    required this.success,
    this.reply,
    this.errorMessage,
    this.isQuotaExceeded = false,
    this.tier,
  });

  factory GuruSendResult.success({required String reply}) =>
      GuruSendResult._(success: true, reply: reply);

  factory GuruSendResult.error(String msg) =>
      GuruSendResult._(success: false, errorMessage: msg);

  factory GuruSendResult.quotaExceeded({required UserTier tier}) =>
      GuruSendResult._(
        success: false,
        isQuotaExceeded: true,
        tier: tier,
      );
}

class GuruApiService {
  /// Same model as [GPTApiService] (OpenAI Chat Completions).
  static const _model = 'gpt-4o-mini';

  final GuruContextBuilder _contextBuilder;
  final GuruRepository _repository;
  final GuruAiCreditsService _credits;
  final http.Client _client;

  GuruApiService({
    required GuruContextBuilder contextBuilder,
    required GuruRepository repository,
    required GuruAiCreditsService credits,
    http.Client? client,
  })  : _contextBuilder = contextBuilder,
        _repository = repository,
        _credits = credits,
        _client = client ?? http.Client();

  Future<GuruSendResult> sendMessage({
    required String userId,
    required UserTier tier,
    required String conversationId,
    required SpiritualServiceType service,
    required String userMessage,
    String? imageBase64,
    String? imageMediaType,
  }) async {
    final limits = FeatureGateConfig.getLimits(tier);

    final allowed = await _credits.tryConsume();
    if (!allowed) return GuruSendResult.quotaExceeded(tier: tier);

    final serviceMode = service.guruPromptServiceKey;
    final mode =
        serviceMode == 'general' ? 'general' : serviceMode;

    // Run in parallel: context (several Supabase reads) + history — was sequential and added latency.
    final loaded = await Future.wait([
      _contextBuilder.buildSystemPrompt(
        userId: userId,
        tier: tier,
        serviceMode: mode,
      ),
      _repository.getRecentMessages(
        conversationId,
        limit: limits.historyMessages,
      ),
    ]);
    final systemPrompt = loaded[0] as String;
    final history = loaded[1] as List<GuruMessage>;

    if (AppConfig.gptApiKey.isEmpty) {
      return GuruSendResult.error(
        'OpenAI API key is not configured. Add GPT_API_KEY to your environment.',
      );
    }

    final url = Uri.parse(
      '${AppConfig.gptApiBaseUrl}${ApiConfig.chatEndpoint}',
    );
    final hasImage =
        imageBase64 != null && imageBase64.isNotEmpty;

    final maxTokens = hasImage
        ? FeatureGateConfig.visionMaxTokens(tier)
        : limits.maxTokens;

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // Vision: skip history so the image is analyzed fresh (matches book spiritual chat).
    if (!hasImage) {
      for (final m in history) {
        _appendChatHistoryTurn(messages, m.role, m.content);
      }
      _appendChatHistoryTurn(messages, 'user', userMessage);
    } else {
      final raw = _stripBase64Prefix(imageBase64);
      final media = imageMediaType ?? 'image/jpeg';
      final mime = media.contains('/') ? media : 'image/$media';
      messages.add({
        'role': 'user',
        'content': [
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:$mime;base64,$raw',
              'detail': 'high',
            },
          },
          {'type': 'text', 'text': userMessage},
        ],
      });
    }

    late String reply;
    try {
      final timeout = hasImage
          ? const Duration(seconds: 120)
          : const Duration(seconds: 55);
      final resp = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AppConfig.gptApiKey}',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'max_tokens': maxTokens,
              'temperature': 0.7,
            }),
          )
          .timeout(timeout);

      if (resp.statusCode != 200) {
        return GuruSendResult.error(
          'Server error ${resp.statusCode}',
        );
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        return GuruSendResult.error('Empty response from Guruji.');
      }
      final first = choices.first;
      if (first is! Map<String, dynamic>) {
        return GuruSendResult.error('Empty response from Guruji.');
      }
      final message = first['message'];
      if (message is! Map<String, dynamic>) {
        return GuruSendResult.error('Empty response from Guruji.');
      }
      reply = _openAiMessageContentToString(message['content']);
      if (reply.isEmpty) {
        return GuruSendResult.error('Empty response from Guruji.');
      }
    } on TimeoutException {
      return GuruSendResult.error(
        'Guruji is meditating — please try again.',
      );
    } catch (_) {
      return GuruSendResult.error(
        'Could not reach Guruji. Please check your connection.',
      );
    }

    await _repository.saveMessage(conversationId, 'user', userMessage);
    await _repository.saveMessage(conversationId, 'assistant', reply);

    return GuruSendResult.success(reply: reply);
  }

  /// Merges back-to-back assistant rows (e.g. mood reflection + "Today's suggestion") so
  /// the Chat Completions API sees cleaner turns while Supabase keeps separate bubbles.
  static void _appendChatHistoryTurn(
    List<Map<String, dynamic>> messages,
    String role,
    String content,
  ) {
    if (role == 'assistant' &&
        messages.isNotEmpty &&
        messages.last['role'] == 'assistant') {
      final prev = messages.last['content'] as String;
      messages.last['content'] = '$prev\n\n$content';
      return;
    }
    messages.add({'role': role, 'content': content});
  }

  static String _stripBase64Prefix(String b64) {
    final i = b64.indexOf('base64,');
    if (i >= 0) return b64.substring(i + 7);
    return b64;
  }

  static String _openAiMessageContentToString(dynamic content) {
    if (content == null) return '';
    if (content is String) return content;
    if (content is List) {
      final buf = StringBuffer();
      for (final part in content) {
        if (part is Map && part['type'] == 'text' && part['text'] is String) {
          buf.write(part['text']);
        }
      }
      return buf.toString();
    }
    return content.toString();
  }
}
