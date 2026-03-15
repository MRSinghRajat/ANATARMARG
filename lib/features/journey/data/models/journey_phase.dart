/// Stage within a journey (Trimester 1, Balak, etc.)
class JourneyPhase {
  final String id;
  final String journeyTypeId;
  final String slug;
  final String title;
  final String? titleHindi;
  final String? description;
  final int phaseOrder;
  final String triggerType;
  final Map<String, dynamic>? triggerValue;
  final String? durationLabel;
  final String? icon;
  final String? colorHex;

  const JourneyPhase({
    required this.id,
    required this.journeyTypeId,
    required this.slug,
    required this.title,
    this.titleHindi,
    this.description,
    this.phaseOrder = 0,
    this.triggerType = 'immediate',
    this.triggerValue,
    this.durationLabel,
    this.icon,
    this.colorHex,
  });

  factory JourneyPhase.fromJson(Map<String, dynamic> json) {
    final tv = json['trigger_value'];
    return JourneyPhase(
      id: json['id'] as String,
      journeyTypeId: json['journey_type_id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String? ?? '',
      titleHindi: json['title_hindi'] as String?,
      description: json['description'] as String?,
      phaseOrder: json['phase_order'] as int? ?? 0,
      triggerType: json['trigger_type'] as String? ?? 'immediate',
      triggerValue: tv is Map<String, dynamic>
          ? tv
          : (tv != null ? Map<String, dynamic>.from(tv as Map) : null),
      durationLabel: json['duration_label'] as String?,
      icon: json['icon'] as String?,
      colorHex: json['color_hex'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'journey_type_id': journeyTypeId,
        'slug': slug,
        'title': title,
        'title_hindi': titleHindi,
        'description': description,
        'phase_order': phaseOrder,
        'trigger_type': triggerType,
        'trigger_value': triggerValue,
        'duration_label': durationLabel,
        'icon': icon,
        'color_hex': colorHex,
      };
}
