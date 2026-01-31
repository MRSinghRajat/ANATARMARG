class BookModel {
  final String id;
  final String name;
  final String? nameSanskrit;
  final String description;
  final int totalChapters;
  final int completedChapters;
  final String? coverImagePath;
  final String? coverImageUrl;
  final String category;
  final String language;
  final DateTime? lastReadAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookModel({
    required this.id,
    required this.name,
    this.nameSanskrit,
    required this.description,
    required this.totalChapters,
    this.completedChapters = 0,
    this.coverImagePath,
    this.coverImageUrl,
    this.category = 'scripture',
    this.language = 'en',
    this.lastReadAt,
    this.createdAt,
    this.updatedAt,
  });

  double get progress =>
      totalChapters > 0 ? completedChapters / totalChapters : 0.0;

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameSanskrit: json['name_sanskrit'] as String?,
      description: json['description'] as String,
      totalChapters:
          json['total_chapters'] as int? ?? json['totalChapters'] as int,
      completedChapters: json['completed_chapters'] as int? ??
          json['completedChapters'] as int? ??
          0,
      coverImagePath: json['coverImagePath'] as String?,
      coverImageUrl: json['cover_image_url'] as String? ??
          json['coverImageUrl'] as String?,
      category: json['category'] as String? ?? 'scripture',
      language: json['language'] as String? ?? 'en',
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'] as String)
          : json['lastReadAt'] != null
              ? DateTime.parse(json['lastReadAt'] as String)
              : null,
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
      'name': name,
      'name_sanskrit': nameSanskrit,
      'description': description,
      'total_chapters': totalChapters,
      'completed_chapters': completedChapters,
      'cover_image_url': coverImageUrl ?? coverImagePath,
      'category': category,
      'language': language,
      'last_read_at': lastReadAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
