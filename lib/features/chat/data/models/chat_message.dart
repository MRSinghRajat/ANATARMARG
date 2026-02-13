import 'package:uuid/uuid.dart';

/// Represents a single message in the spiritual chat conversation.
class ChatMessage {
  final String id;
  final String conversationId;
  final ChatRole role;
  final String content;
  final DateTime createdAt;
  final List<String>? quickReplies;
  final bool isReading; // True if this is a formatted "reading" response
  final String? imageBase64; // Base64 encoded image data (for displaying in chat)

  ChatMessage({
    String? id,
    required this.conversationId,
    required this.role,
    required this.content,
    DateTime? createdAt,
    this.quickReplies,
    this.isReading = false,
    this.imageBase64,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory ChatMessage.user({
    required String conversationId,
    required String content,
    String? imageBase64,
  }) {
    return ChatMessage(
      conversationId: conversationId,
      role: ChatRole.user,
      content: content,
      imageBase64: imageBase64,
    );
  }

  factory ChatMessage.assistant({
    required String conversationId,
    required String content,
    List<String>? quickReplies,
    bool isReading = false,
  }) {
    return ChatMessage(
      conversationId: conversationId,
      role: ChatRole.assistant,
      content: content,
      quickReplies: quickReplies,
      isReading: isReading,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'role': role.name,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: ChatRole.values.firstWhere((r) => r.name == json['role']),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to format expected by GPT API
  Map<String, String> toGptFormat() => {
        'role': role == ChatRole.user ? 'user' : 'assistant',
        'content': content,
      };
}

enum ChatRole {
  user,
  assistant,
}

/// Represents a conversation with a spiritual service
class ChatConversation {
  final String id;
  final String? userId;
  final String service;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? userProfile;

  ChatConversation({
    String? id,
    this.userId,
    required this.service,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.userProfile,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'service': service,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'user_profile': userProfile,
      };

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      service: json['service'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userProfile: json['user_profile'] as Map<String, dynamic>?,
    );
  }

  ChatConversation copyWith({
    String? id,
    String? userId,
    String? service,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? userProfile,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      service: service ?? this.service,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userProfile: userProfile ?? this.userProfile,
    );
  }
}
