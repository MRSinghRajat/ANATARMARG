/// In-app notification item (list on Notifications screen).
class AppNotification {
  final String id;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  final String? type;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.read = false,
    required this.createdAt,
    this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'read': read,
        'created_at': createdAt.toIso8601String(),
        'type': type,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      read: json['read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      type: json['type'] as String?,
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    bool? read,
    DateTime? createdAt,
    String? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
    );
  }
}
