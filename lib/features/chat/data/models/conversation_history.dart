import 'dart:convert';
import 'spiritual_service.dart';
import 'chat_message.dart';

/// Represents a saved conversation for history list.
class ConversationHistory {
  final String id;
  final SpiritualServiceType service;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessage;
  final List<ChatMessage> messages;
  final Map<String, dynamic>? userProfile;

  ConversationHistory({
    required this.id,
    required this.service,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.messages = const [],
    this.userProfile,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'service': service.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lastMessage': lastMessage,
    'messages': messages.map((m) => m.toJson()).toList(),
    'userProfile': userProfile,
  };

  factory ConversationHistory.fromJson(Map<String, dynamic> json) {
    return ConversationHistory(
      id: json['id'] as String,
      service: SpiritualServiceType.values.firstWhere(
        (s) => s.name == json['service'],
        orElse: () => SpiritualServiceType.values.first,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastMessage: json['lastMessage'] as String?,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList() ?? [],
      userProfile: json['userProfile'] as Map<String, dynamic>?,
    );
  }

  static String encodeList(List<ConversationHistory> list) =>
      jsonEncode(list.map((c) => c.toJson()).toList());

  static List<ConversationHistory> decodeList(String encoded) {
    final list = jsonDecode(encoded) as List<dynamic>;
    return list
        .map((j) => ConversationHistory.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Creates a copy with updated fields.
  ConversationHistory copyWith({
    String? id,
    SpiritualServiceType? service,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessage,
    List<ChatMessage>? messages,
    Map<String, dynamic>? userProfile,
  }) {
    return ConversationHistory(
      id: id ?? this.id,
      service: service ?? this.service,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      messages: messages ?? this.messages,
      userProfile: userProfile ?? this.userProfile,
    );
  }

  /// Creates a new conversation history entry.
  factory ConversationHistory.create({
    required SpiritualServiceType service,
    Map<String, dynamic>? userProfile,
  }) {
    final now = DateTime.now();
    return ConversationHistory(
      id: '${now.millisecondsSinceEpoch}',
      service: service,
      createdAt: now,
      updatedAt: now,
      messages: [],
      userProfile: userProfile,
    );
  }

  /// Returns a preview string for the list view.
  String get preview {
    if (lastMessage != null && lastMessage!.isNotEmpty) {
      if (lastMessage!.length > 80) {
        return '${lastMessage!.substring(0, 80)}...';
      }
      return lastMessage!;
    }
    return 'Tap to continue conversation';
  }

  /// Returns a formatted date string.
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
    }
  }
}
