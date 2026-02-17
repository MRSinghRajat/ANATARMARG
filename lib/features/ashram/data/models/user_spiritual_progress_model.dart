import '../../../../core/utils/app_clock.dart';

/// Model for user's overall spiritual progress
class UserSpiritualProgress {
  final String id;
  final String userId;
  
  // Streaks
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final int streakFreezeAvailable;
  final DateTime? streakFreezeUsedDate;
  
  // Lifetime stats
  final int totalTasksCompleted;
  final int totalVersesRead;
  final int totalMeditationMinutes;
  final int totalBookPagesRead;
  final int totalSevaActs;
  final int totalCustomHabitsCompleted;
  
  // Levels & Experience
  final int spiritualLevel;
  final int experiencePoints;
  
  // Journey
  final DateTime journeyStartDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSpiritualProgress({
    required this.id,
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.streakFreezeAvailable = 0,
    this.streakFreezeUsedDate,
    this.totalTasksCompleted = 0,
    this.totalVersesRead = 0,
    this.totalMeditationMinutes = 0,
    this.totalBookPagesRead = 0,
    this.totalSevaActs = 0,
    this.totalCustomHabitsCompleted = 0,
    this.spiritualLevel = 1,
    this.experiencePoints = 0,
    required this.journeyStartDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate XP needed for next level (exponential growth)
  int get xpForNextLevel => (100 * (spiritualLevel * 1.5)).round();

  /// Calculate progress to next level (0.0 to 1.0)
  double get levelProgress {
    final xpNeeded = xpForNextLevel;
    final xpInCurrentLevel = experiencePoints % xpNeeded;
    return xpInCurrentLevel / xpNeeded;
  }

  /// Get spiritual title based on level
  String get spiritualTitle {
    if (spiritualLevel >= 100) return 'Enlightened One';
    if (spiritualLevel >= 75) return 'Siddha';
    if (spiritualLevel >= 50) return 'Yogi';
    if (spiritualLevel >= 35) return 'Sadhak';
    if (spiritualLevel >= 25) return 'Practitioner';
    if (spiritualLevel >= 15) return 'Seeker';
    if (spiritualLevel >= 10) return 'Aspirant';
    if (spiritualLevel >= 5) return 'Awakening';
    return 'Beginner';
  }

  String get spiritualTitleHindi {
    if (spiritualLevel >= 100) return 'प्रबुद्ध';
    if (spiritualLevel >= 75) return 'सिद्ध';
    if (spiritualLevel >= 50) return 'योगी';
    if (spiritualLevel >= 35) return 'साधक';
    if (spiritualLevel >= 25) return 'अभ्यासी';
    if (spiritualLevel >= 15) return 'खोजी';
    if (spiritualLevel >= 10) return 'आकांक्षी';
    if (spiritualLevel >= 5) return 'जागृत';
    return 'आरंभकर्ता';
  }

  /// Get streak multiplier for rewards
  double get streakMultiplier {
    if (currentStreak >= 365) return 3.0;
    if (currentStreak >= 108) return 2.5;
    if (currentStreak >= 40) return 2.0;
    if (currentStreak >= 21) return 1.75;
    if (currentStreak >= 7) return 1.5;
    if (currentStreak >= 3) return 1.25;
    return 1.0;
  }

  /// Check if streak is active (completed something today or yesterday)
  bool get isStreakActive {
    if (lastActivityDate == null) return false;
    final now = AppClock.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      lastActivityDate!.year,
      lastActivityDate!.month,
      lastActivityDate!.day,
    );
    final difference = today.difference(lastActivity).inDays;
    return difference <= 1;
  }

  /// Check if user completed tasks today
  bool get completedToday {
    if (lastActivityDate == null) return false;
    final now = AppClock.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      lastActivityDate!.year,
      lastActivityDate!.month,
      lastActivityDate!.day,
    );
    return today.isAtSameMomentAs(lastActivity);
  }

  /// Days since journey started
  int get daysSinceStart {
    return AppClock.now().difference(journeyStartDate).inDays;
  }

  factory UserSpiritualProgress.fromJson(Map<String, dynamic> json) {
    return UserSpiritualProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'] as String)
          : null,
      streakFreezeAvailable: json['streak_freeze_available'] as int? ?? 0,
      streakFreezeUsedDate: json['streak_freeze_used_date'] != null
          ? DateTime.parse(json['streak_freeze_used_date'] as String)
          : null,
      totalTasksCompleted: json['total_tasks_completed'] as int? ?? 0,
      totalVersesRead: json['total_verses_read'] as int? ?? 0,
      totalMeditationMinutes: json['total_meditation_minutes'] as int? ?? 0,
      totalBookPagesRead: json['total_book_pages_read'] as int? ?? 0,
      totalSevaActs: json['total_seva_acts'] as int? ?? 0,
      totalCustomHabitsCompleted: json['total_custom_habits_completed'] as int? ?? 0,
      spiritualLevel: json['spiritual_level'] as int? ?? 1,
      experiencePoints: json['experience_points'] as int? ?? 0,
      journeyStartDate: json['journey_start_date'] != null
          ? DateTime.parse(json['journey_start_date'] as String)
          : AppClock.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : AppClock.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : AppClock.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity_date': lastActivityDate?.toIso8601String().split('T')[0],
      'streak_freeze_available': streakFreezeAvailable,
      'streak_freeze_used_date': streakFreezeUsedDate?.toIso8601String().split('T')[0],
      'total_tasks_completed': totalTasksCompleted,
      'total_verses_read': totalVersesRead,
      'total_meditation_minutes': totalMeditationMinutes,
      'total_book_pages_read': totalBookPagesRead,
      'total_seva_acts': totalSevaActs,
      'total_custom_habits_completed': totalCustomHabitsCompleted,
      'spiritual_level': spiritualLevel,
      'experience_points': experiencePoints,
      'journey_start_date': journeyStartDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserSpiritualProgress copyWith({
    String? id,
    String? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    int? streakFreezeAvailable,
    DateTime? streakFreezeUsedDate,
    int? totalTasksCompleted,
    int? totalVersesRead,
    int? totalMeditationMinutes,
    int? totalBookPagesRead,
    int? totalSevaActs,
    int? totalCustomHabitsCompleted,
    int? spiritualLevel,
    int? experiencePoints,
    DateTime? journeyStartDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSpiritualProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      streakFreezeAvailable: streakFreezeAvailable ?? this.streakFreezeAvailable,
      streakFreezeUsedDate: streakFreezeUsedDate ?? this.streakFreezeUsedDate,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalVersesRead: totalVersesRead ?? this.totalVersesRead,
      totalMeditationMinutes: totalMeditationMinutes ?? this.totalMeditationMinutes,
      totalBookPagesRead: totalBookPagesRead ?? this.totalBookPagesRead,
      totalSevaActs: totalSevaActs ?? this.totalSevaActs,
      totalCustomHabitsCompleted: totalCustomHabitsCompleted ?? this.totalCustomHabitsCompleted,
      spiritualLevel: spiritualLevel ?? this.spiritualLevel,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      journeyStartDate: journeyStartDate ?? this.journeyStartDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create empty progress for new users
  factory UserSpiritualProgress.empty(String userId) {
    final now = AppClock.now();
    return UserSpiritualProgress(
      id: '',
      userId: userId,
      journeyStartDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }
}
