/// User's personal journey instance (active, paused, completed, abandoned)
class UserJourney {
  final String id;
  final String userId;
  final String journeyTypeId;
  final String? currentPhaseId;
  final String status;
  final DateTime? startDate;
  final DateTime? targetDate;
  final DateTime? pausedAt;
  final DateTime? resumedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata;
  final String? planAtStart;
  final String? companionUserId;

  const UserJourney({
    required this.id,
    required this.userId,
    required this.journeyTypeId,
    this.currentPhaseId,
    this.status = 'active',
    this.startDate,
    this.targetDate,
    this.pausedAt,
    this.resumedAt,
    this.completedAt,
    this.metadata = const {},
    this.planAtStart,
    this.companionUserId,
  });

  factory UserJourney.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'];
    return UserJourney(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      journeyTypeId: json['journey_type_id'] as String,
      currentPhaseId: json['current_phase_id'] as String?,
      status: json['status'] as String? ?? 'active',
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String)
          : null,
      targetDate: json['target_date'] != null
          ? DateTime.tryParse(json['target_date'] as String)
          : null,
      pausedAt: json['paused_at'] != null
          ? DateTime.tryParse(json['paused_at'] as String)
          : null,
      resumedAt: json['resumed_at'] != null
          ? DateTime.tryParse(json['resumed_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      metadata: meta is Map<String, dynamic>
          ? meta
          : (meta != null ? Map<String, dynamic>.from(meta as Map) : {}),
      planAtStart: json['plan_at_start'] as String?,
      companionUserId: json['companion_user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'journey_type_id': journeyTypeId,
        'current_phase_id': currentPhaseId,
        'status': status,
        'start_date': startDate?.toIso8601String().split('T').first,
        'target_date': targetDate?.toIso8601String().split('T').first,
        'paused_at': pausedAt?.toIso8601String(),
        'resumed_at': resumedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'metadata': metadata,
        'plan_at_start': planAtStart,
        'companion_user_id': companionUserId,
      };

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCompleted => status == 'completed';
  bool get isAbandoned => status == 'abandoned';
}
