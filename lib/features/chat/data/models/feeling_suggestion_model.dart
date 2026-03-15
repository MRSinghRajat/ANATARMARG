/// One row from feeling_weekday_suggestions: suggestion for a (feeling_id, weekday).
class FeelingSuggestion {
  final String id;
  final String feelingId;
  final int weekday;
  final String suggestionType;
  final String title;
  final String? description;
  final String? contentSlug;

  const FeelingSuggestion({
    required this.id,
    required this.feelingId,
    required this.weekday,
    required this.suggestionType,
    required this.title,
    this.description,
    this.contentSlug,
  });

  factory FeelingSuggestion.fromJson(Map<String, dynamic> json) {
    return FeelingSuggestion(
      id: json['id'] as String,
      feelingId: json['feeling_id'] as String,
      weekday: (json['weekday'] as num).toInt(),
      suggestionType: json['suggestion_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      contentSlug: json['content_slug'] as String?,
    );
  }
}
