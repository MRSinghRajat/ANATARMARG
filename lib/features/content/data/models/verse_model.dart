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
    };
  }
}
