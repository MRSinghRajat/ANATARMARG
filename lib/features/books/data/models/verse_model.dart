class VerseModel {
  final String id;
  final String bookId;
  final String chapterId;
  final int verseNumber;
  final String verseNumberDisplay;
  final int orderIndex;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VerseModel({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.verseNumber,
    required this.verseNumberDisplay,
    required this.orderIndex,
    this.createdAt,
    this.updatedAt,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      chapterId: json['chapter_id'] as String,
      verseNumber: json['verse_number'] as int,
      verseNumberDisplay: json['verse_number_display'] as String,
      orderIndex: json['order_index'] as int,
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
      'chapter_id': chapterId,
      'verse_number': verseNumber,
      'verse_number_display': verseNumberDisplay,
      'order_index': orderIndex,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
