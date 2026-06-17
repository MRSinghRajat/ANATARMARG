class GuruMessage {
  final String role;
  final String content;
  final DateTime? createdAt;

  const GuruMessage({
    required this.role,
    required this.content,
    this.createdAt,
  });

  factory GuruMessage.fromJson(Map<String, dynamic> json) {
    return GuruMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
