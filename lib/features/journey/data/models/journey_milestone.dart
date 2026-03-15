/// Samskara or one-time celebration
class JourneyMilestone {
  final String id;
  final String journeyTypeId;
  final String phaseId;
  final String slug;
  final String title;
  final String? titleHindi;
  final String? description;
  final String? descriptionHindi;
  final String milestoneType;
  final String triggerType;
  final Map<String, dynamic>? triggerValue;
  final int milestoneOrder;
  final String? icon;
  final bool allowPhoto;
  final bool allowNotes;
  final bool isRequired;
  final int? coinReward;

  const JourneyMilestone({
    required this.id,
    required this.journeyTypeId,
    required this.phaseId,
    required this.slug,
    required this.title,
    this.titleHindi,
    this.description,
    this.descriptionHindi,
    this.milestoneType = 'samskara',
    this.triggerType = 'manual',
    this.triggerValue,
    this.milestoneOrder = 0,
    this.icon,
    this.allowPhoto = true,
    this.allowNotes = true,
    this.isRequired = false,
    this.coinReward,
  });

  factory JourneyMilestone.fromJson(Map<String, dynamic> json) {
    final tv = json['trigger_value'];
    return JourneyMilestone(
      id: json['id'] as String,
      journeyTypeId: json['journey_type_id'] as String,
      phaseId: json['phase_id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String? ?? '',
      titleHindi: json['title_hindi'] as String?,
      description: json['description'] as String?,
      descriptionHindi: json['description_hindi'] as String?,
      milestoneType: json['milestone_type'] as String? ?? 'samskara',
      triggerType: json['trigger_type'] as String? ?? 'manual',
      triggerValue: tv is Map<String, dynamic>
          ? tv
          : (tv != null ? Map<String, dynamic>.from(tv as Map) : null),
      milestoneOrder: json['milestone_order'] as int? ?? 0,
      icon: json['icon'] as String?,
      allowPhoto: json['allow_photo'] as bool? ?? true,
      allowNotes: json['allow_notes'] as bool? ?? true,
      isRequired: json['is_required'] as bool? ?? false,
      coinReward: json['coin_reward'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'journey_type_id': journeyTypeId,
        'phase_id': phaseId,
        'slug': slug,
        'title': title,
        'title_hindi': titleHindi,
        'description': description,
        'description_hindi': descriptionHindi,
        'milestone_type': milestoneType,
        'trigger_type': triggerType,
        'trigger_value': triggerValue,
        'milestone_order': milestoneOrder,
        'icon': icon,
        'allow_photo': allowPhoto,
        'allow_notes': allowNotes,
        'is_required': isRequired,
        'coin_reward': coinReward,
      };
}
