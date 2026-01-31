class ChapterContent {
  final String id;
  final String book;
  final String chapterId;
  final String chapterNumber;
  final String title;
  final String summary;
  final int estimatedReadingMinutes;
  final List<String>? keyCharacters;
  final List<String>? keyThemes;
  final DateTime? createdAt;

  ChapterContent({
    required this.id,
    required this.book,
    required this.chapterId,
    required this.chapterNumber,
    required this.title,
    required this.summary,
    this.estimatedReadingMinutes = 2,
    this.keyCharacters,
    this.keyThemes,
    this.createdAt,
  });

  factory ChapterContent.fromJson(Map<String, dynamic> json) {
    return ChapterContent(
      id: json['id'] as String,
      book: json['book'] as String,
      chapterId: json['chapterId'] as String,
      chapterNumber: json['chapterNumber'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      estimatedReadingMinutes: json['estimatedReadingMinutes'] as int? ?? 2,
      keyCharacters: json['keyCharacters'] != null
          ? List<String>.from(json['keyCharacters'])
          : null,
      keyThemes: json['keyThemes'] != null
          ? List<String>.from(json['keyThemes'])
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
      'chapterId': chapterId,
      'chapterNumber': chapterNumber,
      'title': title,
      'summary': summary,
      'estimatedReadingMinutes': estimatedReadingMinutes,
      'keyCharacters': keyCharacters,
      'keyThemes': keyThemes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
