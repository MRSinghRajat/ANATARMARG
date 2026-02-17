/// Models for Granthalaya dynamic content from Supabase
library;

class DeityModel {
  final String id;
  final String slug;
  final String name;
  final String? nameSanskrit;
  final String? titleHindi;
  final String? imageUrl;
  final String? description;
  final String? mythology;
  final Map<String, dynamic> iconography;
  final Map<String, dynamic> family;
  final List<String> mantras;
  final int? sacredNumber;
  final String? sacredDay;
  final List<dynamic> festivals;
  final String? howToWorship;
  final List<dynamic> temples;
  final List<dynamic> timeline;
  final String color;
  final int orderIndex;
  final bool isActive;

  DeityModel({
    required this.id,
    required this.slug,
    required this.name,
    this.nameSanskrit,
    this.titleHindi,
    this.imageUrl,
    this.description,
    this.mythology,
    this.iconography = const {},
    this.family = const {},
    this.mantras = const [],
    this.sacredNumber,
    this.sacredDay,
    this.festivals = const [],
    this.howToWorship,
    this.temples = const [],
    this.timeline = const [],
    this.color = '#C5A059',
    this.orderIndex = 0,
    this.isActive = true,
  });

  factory DeityModel.fromJson(Map<String, dynamic> json) {
    return DeityModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      nameSanskrit: json['name_sanskrit'] as String?,
      titleHindi: json['title_hindi'] as String?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      mythology: json['mythology'] as String?,
      iconography: json['iconography'] as Map<String, dynamic>? ?? {},
      family: json['family'] as Map<String, dynamic>? ?? {},
      mantras: (json['mantras'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sacredNumber: json['sacred_number'] as int?,
      sacredDay: json['sacred_day'] as String?,
      festivals: json['festivals'] as List<dynamic>? ?? [],
      howToWorship: json['how_to_worship'] as String?,
      temples: json['temples'] as List<dynamic>? ?? [],
      timeline: json['timeline'] as List<dynamic>? ?? [],
      color: json['color'] as String? ?? '#C5A059',
      orderIndex: json['order_index'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// Sacred text: Chalisa, Stotra, Mantra, Aarti, etc.
class SacredTextModel {
  final String id;
  final String slug;
  final String title;
  final String? titleHindi;
  final String type;
  final String? deitySlug;
  final String? textHindi;
  final String? textEnglish;
  final String? transliteration;
  final String? audioUrl;
  final int? durationSeconds;
  final String? benefits;
  final String? whenToRecite;
  final int? verseCount;
  final String category;
  final String difficulty;
  final bool isFeatured;
  final int orderIndex;

  SacredTextModel({
    required this.id,
    required this.slug,
    required this.title,
    this.titleHindi,
    required this.type,
    this.deitySlug,
    this.textHindi,
    this.textEnglish,
    this.transliteration,
    this.audioUrl,
    this.durationSeconds,
    this.benefits,
    this.whenToRecite,
    this.verseCount,
    this.category = 'daily_prayer',
    this.difficulty = 'beginner',
    this.isFeatured = false,
    this.orderIndex = 0,
  });

  factory SacredTextModel.fromJson(Map<String, dynamic> json) {
    return SacredTextModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      titleHindi: json['title_hindi'] as String?,
      type: json['type'] as String? ?? 'stotra',
      deitySlug: json['deity_slug'] as String?,
      textHindi: json['text_hindi'] as String?,
      textEnglish: json['text_english'] as String?,
      transliteration: json['transliteration'] as String?,
      audioUrl: json['audio_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      benefits: json['benefits'] as String?,
      whenToRecite: json['when_to_recite'] as String?,
      verseCount: json['verse_count'] as int?,
      category: json['category'] as String? ?? 'daily_prayer',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      isFeatured: json['is_featured'] as bool? ?? false,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  String get typeLabel {
    switch (type) {
      case 'chalisa': return 'Chalisa';
      case 'stotra': return 'Stotra';
      case 'mantra': return 'Mantra';
      case 'aarti': return 'Aarti';
      case 'stuti': return 'Stuti';
      case 'suktam': return 'Suktam';
      case 'kavach': return 'Kavach';
      case 'sahasranama': return 'Sahasranama';
      default: return type;
    }
  }
}

/// Sacred story for Granthalaya (separate from daily_stories)
class SacredStoryModel {
  final String id;
  final String slug;
  final String title;
  final String? titleHindi;
  final String? deitySlug;
  final String? source;
  final String category;
  final List<SacredStoryPage> pages;
  final String? coverImageUrl;
  final String? keyTeaching;
  final String? reflectionPrompt;
  final int estimatedMinutes;
  final bool isFeatured;
  final int orderIndex;

  SacredStoryModel({
    required this.id,
    required this.slug,
    required this.title,
    this.titleHindi,
    this.deitySlug,
    this.source,
    this.category = 'mythology',
    this.pages = const [],
    this.coverImageUrl,
    this.keyTeaching,
    this.reflectionPrompt,
    this.estimatedMinutes = 3,
    this.isFeatured = false,
    this.orderIndex = 0,
  });

  factory SacredStoryModel.fromJson(Map<String, dynamic> json) {
    final pagesJson = json['pages'] as List<dynamic>? ?? [];
    return SacredStoryModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      titleHindi: json['title_hindi'] as String?,
      deitySlug: json['deity_slug'] as String?,
      source: json['source'] as String?,
      category: json['category'] as String? ?? 'mythology',
      pages: pagesJson
          .map((p) => SacredStoryPage.fromJson(p as Map<String, dynamic>))
          .toList(),
      coverImageUrl: json['cover_image_url'] as String?,
      keyTeaching: json['key_teaching'] as String?,
      reflectionPrompt: json['reflection_prompt'] as String?,
      estimatedMinutes: json['estimated_minutes'] as int? ?? 3,
      isFeatured: json['is_featured'] as bool? ?? false,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}

class SacredStoryPage {
  final String textEnglish;
  final String textHindi;
  final String? illustrationUrl;
  final bool isFinal;

  SacredStoryPage({
    required this.textEnglish,
    required this.textHindi,
    this.illustrationUrl,
    this.isFinal = false,
  });

  factory SacredStoryPage.fromJson(Map<String, dynamic> json) {
    return SacredStoryPage(
      textEnglish: json['text_english'] as String? ?? '',
      textHindi: json['text_hindi'] as String? ?? '',
      illustrationUrl: json['illustration_url'] as String?,
      isFinal: json['is_final'] as bool? ?? false,
    );
  }
}

class ResourceCardModel {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final int orderIndex;

  ResourceCardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.iconName = 'menu_book',
    this.orderIndex = 0,
  });

  factory ResourceCardModel.fromJson(Map<String, dynamic> json) {
    return ResourceCardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconName: json['icon_name'] as String? ?? 'menu_book',
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}

class DeepDiveModel {
  final String id;
  final String title;
  final String quote;
  final String? durationLabel;
  final int orderIndex;

  DeepDiveModel({
    required this.id,
    required this.title,
    required this.quote,
    this.durationLabel,
    this.orderIndex = 0,
  });

  factory DeepDiveModel.fromJson(Map<String, dynamic> json) {
    return DeepDiveModel(
      id: json['id'] as String,
      title: json['title'] as String,
      quote: json['quote'] as String,
      durationLabel: json['duration_label'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}

class AudioCategoryModel {
  final String id;
  final String slug;
  final String name;
  final int orderIndex;

  AudioCategoryModel({
    required this.id,
    required this.slug,
    required this.name,
    this.orderIndex = 0,
  });

  factory AudioCategoryModel.fromJson(Map<String, dynamic> json) {
    return AudioCategoryModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}

class AudioWisdomCardModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String categorySlug;
  final int orderIndex;
  final String? audioUrl;
  final String? deitySlug;

  AudioWisdomCardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.categorySlug = 'audio_books',
    this.orderIndex = 0,
    this.audioUrl,
    this.deitySlug,
  });

  factory AudioWisdomCardModel.fromJson(
    Map<String, dynamic> json, {
    String? effectiveAudioUrl,
  }) {
    final url = effectiveAudioUrl ?? json['audio_url'] as String?;
    return AudioWisdomCardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['image_url'] as String,
      categorySlug: json['category_slug'] as String? ?? 'audio_books',
      orderIndex: json['order_index'] as int? ?? 0,
      audioUrl: url?.isNotEmpty == true ? url : null,
      deitySlug: json['deity_slug'] as String?,
    );
  }
}

class AudioInProgressModel {
  final String id;
  final String tag;
  final String title;
  final String imageUrl;
  final int currentTimeSeconds;
  final int totalTimeSeconds;
  final bool isActiveItem;
  final int orderIndex;
  final String? audioUrl;
  final String? deitySlug;

  AudioInProgressModel({
    required this.id,
    required this.tag,
    required this.title,
    required this.imageUrl,
    this.currentTimeSeconds = 0,
    required this.totalTimeSeconds,
    this.isActiveItem = false,
    this.orderIndex = 0,
    this.audioUrl,
    this.deitySlug,
  });

  String get currentFormatted {
    final m = currentTimeSeconds ~/ 60;
    final s = currentTimeSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get totalFormatted {
    final m = totalTimeSeconds ~/ 60;
    final s = totalTimeSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get progress => totalTimeSeconds > 0
      ? (currentTimeSeconds / totalTimeSeconds).clamp(0.0, 1.0)
      : 0.0;

  factory AudioInProgressModel.fromJson(
    Map<String, dynamic> json, {
    String? effectiveAudioUrl,
  }) {
    final url = effectiveAudioUrl ?? json['audio_url'] as String?;
    return AudioInProgressModel(
      id: json['id'] as String,
      tag: json['tag'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      currentTimeSeconds: json['current_time_seconds'] as int? ?? 0,
      totalTimeSeconds: json['total_time_seconds'] as int,
      isActiveItem: json['is_active_item'] as bool? ?? false,
      orderIndex: json['order_index'] as int? ?? 0,
      audioUrl: url?.isNotEmpty == true ? url : null,
      deitySlug: json['deity_slug'] as String?,
    );
  }
}

/// User-specific audio in-progress (from user_audio_progress table).
class UserAudioProgressModel {
  final String id;
  final String title;
  final String tag;
  final String? subtitle;
  final String? imageUrl;
  final String? audioUrl;
  final int currentTimeSeconds;
  final int totalTimeSeconds;
  final DateTime lastPlayedAt;

  UserAudioProgressModel({
    required this.id,
    required this.title,
    this.tag = '',
    this.subtitle,
    this.imageUrl,
    this.audioUrl,
    this.currentTimeSeconds = 0,
    this.totalTimeSeconds = 0,
    required this.lastPlayedAt,
  });

  String get currentFormatted {
    final m = currentTimeSeconds ~/ 60;
    final s = currentTimeSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get totalFormatted {
    final m = totalTimeSeconds ~/ 60;
    final s = totalTimeSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get progress => totalTimeSeconds > 0
      ? (currentTimeSeconds / totalTimeSeconds).clamp(0.0, 1.0)
      : 0.0;

  factory UserAudioProgressModel.fromJson(Map<String, dynamic> json) {
    return UserAudioProgressModel(
      id: json['id'] as String,
      title: json['title'] as String,
      tag: json['tag'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      currentTimeSeconds: json['current_time_seconds'] as int? ?? 0,
      totalTimeSeconds: json['total_time_seconds'] as int? ?? 0,
      lastPlayedAt: DateTime.parse(json['last_played_at'] as String),
    );
  }
}

/// Chant with playable audio from Supabase Storage or direct URL.
class ChantModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? storageBucket;
  final String? storagePath;
  final String? audioUrl;
  final int? durationSeconds;
  final String? deitySlug;
  final int orderIndex;

  /// Playable URL: audio_url if set, else constructed from Supabase Storage.
  final String effectiveAudioUrl;

  ChantModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.storageBucket,
    this.storagePath,
    this.audioUrl,
    this.durationSeconds,
    this.deitySlug,
    this.orderIndex = 0,
    required this.effectiveAudioUrl,
  });

  String get durationFormatted {
    if (durationSeconds == null) return '0:00';
    final m = durationSeconds! ~/ 60;
    final s = durationSeconds! % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  factory ChantModel.fromJson(
    Map<String, dynamic> json, {
    required String effectiveAudioUrl,
  }) {
    return ChantModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String?,
      storageBucket: json['storage_bucket'] as String?,
      storagePath: json['storage_path'] as String?,
      audioUrl: json['audio_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      deitySlug: json['deity_slug'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      effectiveAudioUrl: effectiveAudioUrl,
    );
  }
}
