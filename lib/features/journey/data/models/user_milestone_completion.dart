/// Samskara/celebration completion record
class UserMilestoneCompletion {
  final String id;
  final String userId;
  final String userJourneyId;
  final String milestoneId;
  final DateTime? completedAt;
  final String? notes;
  final String? photoUrl;
  final bool isPrivate;
  final int? coinsEarned;

  const UserMilestoneCompletion({
    required this.id,
    required this.userId,
    required this.userJourneyId,
    required this.milestoneId,
    this.completedAt,
    this.notes,
    this.photoUrl,
    this.isPrivate = false,
    this.coinsEarned,
  });

  factory UserMilestoneCompletion.fromJson(Map<String, dynamic> json) {
    return UserMilestoneCompletion(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userJourneyId: json['user_journey_id'] as String,
      milestoneId: json['milestone_id'] as String,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
      coinsEarned: json['coins_earned'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_journey_id': userJourneyId,
        'milestone_id': milestoneId,
        'completed_at': completedAt?.toIso8601String(),
        'notes': notes,
        'photo_url': photoUrl,
        'is_private': isPrivate,
        'coins_earned': coinsEarned,
      };
}
