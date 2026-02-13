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
