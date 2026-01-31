class VerseTranslationModel {
  final String id;
  final String verseId;
  final String languageCode;
  final String languageName;
  final String text;
  final String? transliteration;
  final String? translationSource;
  final bool isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VerseTranslationModel({
    required this.id,
    required this.verseId,
    required this.languageCode,
    required this.languageName,
    required this.text,
    this.transliteration,
    this.translationSource,
    this.isPrimary = false,
    this.createdAt,
    this.updatedAt,
  });

  factory VerseTranslationModel.fromJson(Map<String, dynamic> json) {
    return VerseTranslationModel(
      id: json['id'] as String,
      verseId: json['verse_id'] as String,
      languageCode: json['language_code'] as String,
      languageName: json['language_name'] as String,
      text: json['text'] as String,
      transliteration: json['transliteration'] as String?,
      translationSource: json['translation_source'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
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
      'verse_id': verseId,
      'language_code': languageCode,
      'language_name': languageName,
      'text': text,
      'transliteration': transliteration,
      'translation_source': translationSource,
      'is_primary': isPrimary,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
