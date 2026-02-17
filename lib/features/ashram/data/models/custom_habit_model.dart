import '../../../../core/utils/app_clock.dart';

/// Frequency options for custom habits
enum HabitFrequency {
  daily,
  weekly,
  specificDays;

  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.specificDays:
        return 'Specific Days';
    }
  }

  static HabitFrequency fromString(String? value) {
    switch (value) {
      case 'weekly':
        return HabitFrequency.weekly;
      case 'specific_days':
        return HabitFrequency.specificDays;
      default:
        return HabitFrequency.daily;
    }
  }
}

/// Model for user-created custom habits
class CustomHabit {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String iconName;
  final String category;
  
  // Scheduling
  final HabitFrequency frequency;
  final List<int>? specificDays; // 0=Sunday, 6=Saturday
  final DateTime? reminderTime;
  
  // Tracking
  final int? targetStreak;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomHabit({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.iconName = 'check_circle',
    this.category = 'custom',
    this.frequency = HabitFrequency.daily,
    this.specificDays,
    this.reminderTime,
    this.targetStreak,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if habit should be shown today
  bool get isScheduledForToday {
    if (frequency == HabitFrequency.daily) return true;
    if (frequency == HabitFrequency.weekly) {
      // Show weekly habits on Sunday
      return AppClock.now().weekday == DateTime.sunday;
    }
    if (frequency == HabitFrequency.specificDays && specificDays != null) {
      final todayWeekday = AppClock.now().weekday % 7; // Convert to 0=Sunday
      return specificDays!.contains(todayWeekday);
    }
    return true;
  }

  /// Check if completed today
  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = AppClock.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = DateTime(
      lastCompletedDate!.year,
      lastCompletedDate!.month,
      lastCompletedDate!.day,
    );
    return today.isAtSameMomentAs(lastCompleted);
  }

  /// Progress towards target streak (0.0 to 1.0)
  double get streakProgress {
    if (targetStreak == null || targetStreak == 0) return 0.0;
    return (currentStreak / targetStreak!).clamp(0.0, 1.0);
  }

  /// Get day names for specific days
  List<String> get scheduledDayNames {
    if (specificDays == null) return [];
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return specificDays!.map((d) => dayNames[d]).toList();
  }

  factory CustomHabit.fromJson(Map<String, dynamic> json) {
    return CustomHabit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String? ?? 'check_circle',
      category: json['category'] as String? ?? 'custom',
      frequency: HabitFrequency.fromString(json['frequency'] as String?),
      specificDays: (json['specific_days'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      reminderTime: json['reminder_time'] != null
          ? _parseTime(json['reminder_time'] as String)
          : null,
      targetStreak: json['target_streak'] as int?,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastCompletedDate: json['last_completed_date'] != null
          ? DateTime.parse(json['last_completed_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'icon_name': iconName,
      'category': category,
      'frequency': frequency.name,
      'specific_days': specificDays,
      'reminder_time': reminderTime != null
          ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'target_streak': targetStreak,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_completed_date': lastCompletedDate?.toIso8601String().split('T')[0],
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// For inserting new habits (without id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'icon_name': iconName,
      'category': category,
      'frequency': frequency.name,
      'specific_days': specificDays,
      'reminder_time': reminderTime != null
          ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'target_streak': targetStreak,
      'is_active': isActive,
    };
  }

  CustomHabit copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? iconName,
    String? category,
    HabitFrequency? frequency,
    List<int>? specificDays,
    DateTime? reminderTime,
    int? targetStreak,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomHabit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      specificDays: specificDays ?? this.specificDays,
      reminderTime: reminderTime ?? this.reminderTime,
      targetStreak: targetStreak ?? this.targetStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      }
    } catch (_) {}
    return null;
  }
}

/// Model for habit completion records
class HabitCompletion {
  final String id;
  final String userId;
  final String habitId;
  final DateTime completionDate;
  final DateTime completedAt;
  final String? notes;

  const HabitCompletion({
    required this.id,
    required this.userId,
    required this.habitId,
    required this.completionDate,
    required this.completedAt,
    this.notes,
  });

  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitId: json['habit_id'] as String,
      completionDate: DateTime.parse(json['completion_date'] as String),
      completedAt: DateTime.parse(json['completed_at'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'habit_id': habitId,
      'completion_date': completionDate.toIso8601String().split('T')[0],
      'completed_at': completedAt.toIso8601String(),
      'notes': notes,
    };
  }
}
