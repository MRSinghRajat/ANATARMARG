class BookModel {
  final String id;
  final String name;
  final String description;
  final int totalChapters;
  final int completedChapters;
  final String? coverImagePath;
  final DateTime? lastReadAt;

  BookModel({
    required this.id,
    required this.name,
    required this.description,
    required this.totalChapters,
    this.completedChapters = 0,
    this.coverImagePath,
    this.lastReadAt,
  });

  double get progress => totalChapters > 0 
      ? completedChapters / totalChapters 
      : 0.0;

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      totalChapters: json['totalChapters'] as int,
      completedChapters: json['completedChapters'] as int? ?? 0,
      coverImagePath: json['coverImagePath'] as String?,
      lastReadAt: json['lastReadAt'] != null
          ? DateTime.parse(json['lastReadAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'totalChapters': totalChapters,
      'completedChapters': completedChapters,
      'coverImagePath': coverImagePath,
      'lastReadAt': lastReadAt?.toIso8601String(),
    };
  }
}
