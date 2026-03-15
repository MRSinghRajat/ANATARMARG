/// Daily task completion record (UNIQUE user_id, task_id, completed_date)
class UserJourneyTaskCompletion {
  final String id;
  final String userId;
  final String userJourneyId;
  final String taskId;
  final DateTime completedDate;
  final DateTime? completedAt;
  final int? durationSeconds;
  final int? mantraCountDone;
  final String? notes;
  final String? photoUrl;
  final int? coinsEarned;
  final int? karmaEarned;

  const UserJourneyTaskCompletion({
    required this.id,
    required this.userId,
    required this.userJourneyId,
    required this.taskId,
    required this.completedDate,
    this.completedAt,
    this.durationSeconds,
    this.mantraCountDone,
    this.notes,
    this.photoUrl,
    this.coinsEarned,
    this.karmaEarned,
  });

  factory UserJourneyTaskCompletion.fromJson(Map<String, dynamic> json) {
    return UserJourneyTaskCompletion(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userJourneyId: json['user_journey_id'] as String,
      taskId: json['task_id'] as String,
      completedDate: DateTime.parse(json['completed_date'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      durationSeconds: json['duration_seconds'] as int?,
      mantraCountDone: json['mantra_count_done'] as int?,
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
      coinsEarned: json['coins_earned'] as int?,
      karmaEarned: json['karma_earned'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_journey_id': userJourneyId,
        'task_id': taskId,
        'completed_date': completedDate.toIso8601String().split('T').first,
        'completed_at': completedAt?.toIso8601String(),
        'duration_seconds': durationSeconds,
        'mantra_count_done': mantraCountDone,
        'notes': notes,
        'photo_url': photoUrl,
        'coins_earned': coinsEarned,
        'karma_earned': karmaEarned,
      };
}
