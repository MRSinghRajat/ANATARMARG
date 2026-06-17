import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/guru_message.dart';

class GuruConversationSummary {
  final String id;
  final String service;
  final String? title;
  final DateTime updatedAt;

  const GuruConversationSummary({
    required this.id,
    required this.service,
    this.title,
    required this.updatedAt,
  });

  factory GuruConversationSummary.fromJson(Map<String, dynamic> json) {
    return GuruConversationSummary(
      id: json['id'] as String,
      service: json['service'] as String,
      title: json['title'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class GuruRepository {
  final SupabaseClient _supabase;

  GuruRepository(this._supabase);

  Future<String> getOrCreateConversation({
    required String userId,
    required String service,
  }) async {
    final existing = await _supabase
        .from('spiritual_chat_conversations')
        .select('id')
        .eq('user_id', userId)
        .eq('service', service)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    final created = await _supabase
        .from('spiritual_chat_conversations')
        .insert({
          'user_id': userId,
          'service': service,
        })
        .select('id')
        .single();

    return created['id'] as String;
  }

  Future<void> touchConversationUpdatedAt(String conversationId) async {
    await _supabase.from('spiritual_chat_conversations').update({
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', conversationId);
  }

  Future<void> setConversationTitle(String conversationId, String title) async {
    final trimmed = title.length > 120 ? '${title.substring(0, 117)}...' : title;
    await _supabase.from('spiritual_chat_conversations').update({
      'title': trimmed,
    }).eq('id', conversationId);
  }

  Future<List<GuruConversationSummary>> listConversations(String userId) async {
    final rows = await _supabase
        .from('spiritual_chat_conversations')
        .select('id, service, title, updated_at')
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (rows as List)
        .map((e) => GuruConversationSummary.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<GuruMessage>> getRecentMessages(
    String conversationId, {
    int limit = 12,
  }) async {
    final rows = await _supabase
        .from('spiritual_chat_messages')
        .select('role, content, created_at')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false)
        .limit(limit);

    final list = (rows as List)
        .map((e) => GuruMessage.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return list.reversed.toList();
  }

  Future<void> saveMessage(
    String conversationId,
    String role,
    String content,
  ) async {
    await _supabase.from('spiritual_chat_messages').insert({
      'conversation_id': conversationId,
      'role': role,
      'content': content,
    });
    await touchConversationUpdatedAt(conversationId);
  }

  Future<void> deleteConversation(String conversationId) async {
    await _supabase
        .from('spiritual_chat_conversations')
        .delete()
        .eq('id', conversationId);
  }
}
