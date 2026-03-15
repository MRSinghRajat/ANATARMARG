/// Task from v_journey_tasks_full view (phase info embedded).
class JourneyTask {
  final String id;
  final String journeyTypeId;
  final String slug;
  final String title;
  final String? titleHindi;
  final String? description;
  final String? instruction;
  final String taskType;
  final String? contentType;
  /// Polymorphic ref: ID (UUID or integer string) of record in content_type table.
  final String? contentRef;
  final String? inlineContent;
  final String? inlineContentHindi;
  final String frequency;
  /// Pregnancy week range (inclusive). Null = applies to whole phase.
  final int? weekFrom;
  final int? weekTo;
  final int? durationMinutes;
  final int? mantraCount;
  final int displayOrder;
  final String? icon;
  final int coinReward;
  final bool isPremium;

  // Phase info (embedded from v_journey_tasks_full view)
  final String phaseId;
  final String phaseSlug;
  final String? phaseTitle;
  final String? phaseTitleHindi;
  final String triggerType;
  final Map<String, dynamic>? triggerValue;
  final int phaseOrder;
  final String? phaseDurationLabel;
  final String? phaseIcon;
  final String? phaseColorHex;

  const JourneyTask({
    required this.id,
    required this.journeyTypeId,
    required this.slug,
    required this.title,
    this.titleHindi,
    this.description,
    this.instruction,
    this.taskType = 'ritual',
    this.contentType,
    this.contentRef,
    this.inlineContent,
    this.inlineContentHindi,
    this.frequency = 'daily',
    this.weekFrom,
    this.weekTo,
    this.durationMinutes,
    this.mantraCount,
    this.displayOrder = 0,
    this.icon,
    this.coinReward = 0,
    this.isPremium = false,
    required this.phaseId,
    this.phaseSlug = '',
    this.phaseTitle,
    this.phaseTitleHindi,
    this.triggerType = 'immediate',
    this.triggerValue,
    this.phaseOrder = 0,
    this.phaseDurationLabel,
    this.phaseIcon,
    this.phaseColorHex,
  });

  /// Parses from v_journey_tasks_full view (uses prefixed columns: task_id, task_slug, task_title, etc.)
  /// or from journey_tasks table (id, slug, title). Supports both for backward compatibility.
  factory JourneyTask.fromJson(Map<String, dynamic> json) {
    final tv = json['trigger_value'];
    return JourneyTask(
      // View uses task_id, task_slug, task_title; table uses id, slug, title
      id: (json['task_id'] ?? json['id']) as String,
      journeyTypeId: json['journey_type_id'] as String,
      slug: (json['task_slug'] ?? json['slug']) as String,
      title: (json['task_title'] ?? json['title']) as String? ?? '',
      titleHindi: (json['task_title_hindi'] ?? json['title_hindi']) as String?,
      description: (json['task_description'] ?? json['description']) as String?,
      instruction: (json['task_instruction'] ?? json['instruction']) as String?,
      taskType: json['task_type'] as String? ?? 'ritual',
      contentType: json['content_type'] as String?,
      contentRef: json['content_ref']?.toString(),
      inlineContent: json['inline_content'] as String?,
      inlineContentHindi: json['inline_content_hindi'] as String?,
      frequency: json['frequency'] as String? ?? 'daily',
      weekFrom: (json['week_from'] as num?)?.toInt(),
      weekTo: (json['week_to'] as num?)?.toInt(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      mantraCount: (json['mantra_count'] as num?)?.toInt(),
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String?,
      coinReward: (json['coin_reward'] as num?)?.toInt() ?? 0,
      isPremium: json['is_premium'] as bool? ?? false,
      phaseId: json['phase_id'] as String? ?? '',
      phaseSlug: json['phase_slug'] as String? ?? '',
      phaseTitle: json['phase_title'] as String?,
      phaseTitleHindi: json['phase_title_hindi'] as String?,
      triggerType: json['trigger_type'] as String? ?? 'immediate',
      triggerValue: tv is Map<String, dynamic>
          ? tv
          : (tv != null ? Map<String, dynamic>.from(tv as Map) : null),
      phaseOrder: (json['phase_order'] as num?)?.toInt() ?? 0,
      phaseDurationLabel: json['phase_duration_label'] as String?,
      phaseIcon: json['phase_icon'] as String?,
      phaseColorHex: json['phase_color_hex'] as String?,
    );
  }
}
