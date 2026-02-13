/// Models for Granthalaya dynamic content from Supabase
library;

class DeityModel {
  final String id;
  final String slug;
  final String name;
  final String? nameSanskrit;
  final String? imageUrl;
  final String? description;
  final int orderIndex;
  final bool isActive;

  DeityModel({
    required this.id,
    required this.slug,
    required this.name,
    this.nameSanskrit,
    this.imageUrl,
    this.description,
    this.orderIndex = 0,
    this.isActive = true,
  });

  factory DeityModel.fromJson(Map<String, dynamic> json) {
    return DeityModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      nameSanskrit: json['name_sanskrit'] as String?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
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
