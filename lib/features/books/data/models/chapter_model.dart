class ChapterModel {
  final String id;
  final String bookId;
  final int chapterNumber;
  final String title;
  final String? titleSanskrit;
  final String? subtitle;
  final String? summary;
  final List<String>? keyThemes;
  final List<String>? keyCharacters;
  final int estimatedReadingMinutes;
  final int orderIndex;
  final String? audioUrl;
  final String? audioUrlEn;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChapterModel({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.title,
    this.titleSanskrit,
    this.subtitle,
    this.summary,
    this.keyThemes,
    this.keyCharacters,
    this.estimatedReadingMinutes = 2,
    required this.orderIndex,
    this.audioUrl,
    this.audioUrlEn,
    this.createdAt,
    this.updatedAt,
  });

  String get displayNumber => chapterNumber.toString();
  String get displayTitle => subtitle != null ? '$title - $subtitle' : title;

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      chapterNumber: json['chapter_number'] as int,
      title: json['title'] as String,
      titleSanskrit: json['title_sanskrit'] as String?,
      subtitle: json['subtitle'] as String?,
      summary: json['summary'] as String?,
      keyThemes: json['key_themes'] != null
          ? List<String>.from(json['key_themes'] as List)
          : null,
      keyCharacters: json['key_characters'] != null
          ? List<String>.from(json['key_characters'] as List)
          : null,
      estimatedReadingMinutes: json['estimated_reading_minutes'] as int? ?? 2,
      orderIndex: json['order_index'] as int,
      audioUrl: json['audio_url'] as String?,
      audioUrlEn: json['audio_url_en'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'title': title,
      'title_sanskrit': titleSanskrit,
      'subtitle': subtitle,
      'summary': summary,
      'key_themes': keyThemes,
      'key_characters': keyCharacters,
      'estimated_reading_minutes': estimatedReadingMinutes,
      'order_index': orderIndex,
      'audio_url': audioUrl,
      'audio_url_en': audioUrlEn,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
