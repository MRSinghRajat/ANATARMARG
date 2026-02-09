class VerseContent {
  final String id;
  final String book;
  final String? chapter;
  final String? verseNumber;
  final String title;
  final String content;
  final String? context;
  final List<String>? relatedCharacters;
  final DateTime? createdAt;
  /// Optional Devanagari verse text for daily verse full-screen (e.g. from AI).
  final String? devanagariText;
  /// Optional daily insight / sacred action suggestion (e.g. from AI).
  final String? dailyInsight;

  VerseContent({
    required this.id,
    required this.book,
    this.chapter,
    this.verseNumber,
    required this.title,
    required this.content,
    this.context,
    this.relatedCharacters,
    this.createdAt,
    this.devanagariText,
    this.dailyInsight,
  });

  factory VerseContent.fromJson(Map<String, dynamic> json) {
    return VerseContent(
      id: json['id'] as String,
      book: json['book'] as String,
      chapter: json['chapter'] as String?,
      verseNumber: json['verseNumber'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      context: json['context'] as String?,
      relatedCharacters: json['relatedCharacters'] != null
          ? List<String>.from(json['relatedCharacters'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      devanagariText: json['devanagariText'] as String?,
      dailyInsight: json['dailyInsight'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book,
      'chapter': chapter,
      'verseNumber': verseNumber,
      'title': title,
      'content': content,
      'context': context,
      'relatedCharacters': relatedCharacters,
      'createdAt': createdAt?.toIso8601String(),
      'devanagariText': devanagariText,
      'dailyInsight': dailyInsight,
    };
  }
}
