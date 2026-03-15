/// One row per journey card shown in the app (Garbh Sanskar, Little Sadhu, etc.)
class JourneyType {
  final String id;
  final String slug;
  final String? lifeStageId;
  final String title;
  final String? titleHindi;
  final String? subtitle;
  final String? subtitleHindi;
  final String? description;
  final String? descriptionHindi;
  final String? icon;
  final String? colorPrimary;
  final String? colorSecondary;
  final String? bannerUrl;
  final String? cardImageUrl;
  final String? category;
  final String? targetAudience;
  final List<dynamic>? setupSchema;
  final String? setupType;
  final int? durationDays;
  final bool canRepeat;
  final bool isSeasonal;
  final String? seasonalKey;
  final bool isPremium;
  final String? requiredPlan;
  final bool isActive;
  final bool isComingSoon;
  final int displayOrder;

  const JourneyType({
    required this.id,
    required this.slug,
    this.lifeStageId,
    required this.title,
    this.titleHindi,
    this.subtitle,
    this.subtitleHindi,
    this.description,
    this.descriptionHindi,
    this.icon,
    this.colorPrimary,
    this.colorSecondary,
    this.bannerUrl,
    this.cardImageUrl,
    this.category,
    this.targetAudience,
    this.setupSchema,
    this.setupType,
    this.durationDays,
    this.canRepeat = false,
    this.isSeasonal = false,
    this.seasonalKey,
    this.isPremium = false,
    this.requiredPlan,
    this.isActive = true,
    this.isComingSoon = false,
    this.displayOrder = 0,
  });

  factory JourneyType.fromJson(Map<String, dynamic> json) {
    return JourneyType(
      id: json['id'] as String,
      slug: json['slug'] as String,
      lifeStageId: json['life_stage_id'] as String?,
      title: json['title'] as String? ?? '',
      titleHindi: json['title_hindi'] as String?,
      subtitle: json['subtitle'] as String?,
      subtitleHindi: json['subtitle_hindi'] as String?,
      description: json['description'] as String?,
      descriptionHindi: json['description_hindi'] as String?,
      icon: json['icon'] as String?,
      colorPrimary: json['color_primary'] as String?,
      colorSecondary: json['color_secondary'] as String?,
      bannerUrl: json['banner_url'] as String?,
      cardImageUrl: json['card_image_url'] as String?,
      category: json['category'] as String?,
      targetAudience: json['target_audience'] as String?,
      setupSchema: json['setup_schema'] as List<dynamic>?,
      setupType: json['setup_type'] as String?,
      durationDays: json['duration_days'] as int?,
      canRepeat: json['can_repeat'] as bool? ?? false,
      isSeasonal: json['is_seasonal'] as bool? ?? false,
      seasonalKey: json['seasonal_key'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      requiredPlan: json['required_plan'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isComingSoon: json['is_coming_soon'] as bool? ?? false,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'life_stage_id': lifeStageId,
        'title': title,
        'title_hindi': titleHindi,
        'subtitle': subtitle,
        'subtitle_hindi': subtitleHindi,
        'description': description,
        'description_hindi': descriptionHindi,
        'icon': icon,
        'color_primary': colorPrimary,
        'color_secondary': colorSecondary,
        'banner_url': bannerUrl,
        'card_image_url': cardImageUrl,
        'category': category,
        'target_audience': targetAudience,
        'setup_schema': setupSchema,
        'setup_type': setupType,
        'duration_days': durationDays,
        'can_repeat': canRepeat,
        'is_seasonal': isSeasonal,
        'seasonal_key': seasonalKey,
        'is_premium': isPremium,
        'required_plan': requiredPlan,
        'is_active': isActive,
        'is_coming_soon': isComingSoon,
        'display_order': displayOrder,
      };
}
