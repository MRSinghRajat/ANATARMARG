/// Achievement unlock types
enum AchievementUnlockType {
  streak,
  tasksCompleted,
  versesRead,
  meditationMinutes,
  sevaActs,
  level,
  special;

  String get displayName {
    switch (this) {
      case AchievementUnlockType.streak:
        return 'Streak';
      case AchievementUnlockType.tasksCompleted:
        return 'Tasks Completed';
      case AchievementUnlockType.versesRead:
        return 'Verses Read';
      case AchievementUnlockType.meditationMinutes:
        return 'Meditation Time';
      case AchievementUnlockType.sevaActs:
        return 'Seva Acts';
      case AchievementUnlockType.level:
        return 'Spiritual Level';
      case AchievementUnlockType.special:
        return 'Special';
    }
  }

  static AchievementUnlockType fromString(String? value) {
    switch (value) {
      case 'streak':
        return AchievementUnlockType.streak;
      case 'tasks_completed':
        return AchievementUnlockType.tasksCompleted;
      case 'verses_read':
        return AchievementUnlockType.versesRead;
      case 'meditation_minutes':
        return AchievementUnlockType.meditationMinutes;
      case 'seva_acts':
        return AchievementUnlockType.sevaActs;
      case 'level':
        return AchievementUnlockType.level;
      default:
        return AchievementUnlockType.special;
    }
  }
}

/// Badge rarity/color
enum BadgeColor {
  bronze,
  silver,
  gold,
  purple,
  diamond;

  String get displayName {
    switch (this) {
      case BadgeColor.bronze:
        return 'Bronze';
      case BadgeColor.silver:
        return 'Silver';
      case BadgeColor.gold:
        return 'Gold';
      case BadgeColor.purple:
        return 'Epic';
      case BadgeColor.diamond:
        return 'Legendary';
    }
  }

  int get colorValue {
    switch (this) {
      case BadgeColor.bronze:
        return 0xFFCD7F32;
      case BadgeColor.silver:
        return 0xFFC0C0C0;
      case BadgeColor.gold:
        return 0xFFFFD700;
      case BadgeColor.purple:
        return 0xFF9B59B6;
      case BadgeColor.diamond:
        return 0xFF00D4FF;
    }
  }

  static BadgeColor fromString(String? value) {
    switch (value) {
      case 'silver':
        return BadgeColor.silver;
      case 'gold':
        return BadgeColor.gold;
      case 'purple':
        return BadgeColor.purple;
      case 'diamond':
        return BadgeColor.diamond;
      default:
        return BadgeColor.bronze;
    }
  }
}

/// Model for achievements/badges
class Achievement {
  final String id;
  final String slug;
  final String title;
  final String? titleHindi;
  final String? description;
  final String iconName;
  final BadgeColor badgeColor;
  
  // Unlock conditions
  final AchievementUnlockType unlockType;
  final int unlockValue;
  
  // Rewards
  final int coinReward;
  final int karmaReward;
  final int experienceReward;
  
  // Display
  final int orderIndex;
  final bool isSecret;
  final bool isActive;
  final DateTime createdAt;

  const Achievement({
    required this.id,
    required this.slug,
    required this.title,
    this.titleHindi,
    this.description,
    this.iconName = 'emoji_events',
    this.badgeColor = BadgeColor.gold,
    required this.unlockType,
    required this.unlockValue,
    this.coinReward = 0,
    this.karmaReward = 0,
    this.experienceReward = 0,
    this.orderIndex = 0,
    this.isSecret = false,
    this.isActive = true,
    required this.createdAt,
  });

  /// Get unlock condition description
  String get unlockDescription {
    switch (unlockType) {
      case AchievementUnlockType.streak:
        return 'Maintain a $unlockValue-day streak';
      case AchievementUnlockType.tasksCompleted:
        return 'Complete $unlockValue tasks';
      case AchievementUnlockType.versesRead:
        return 'Read $unlockValue verses';
      case AchievementUnlockType.meditationMinutes:
        if (unlockValue >= 60) {
          final hours = unlockValue ~/ 60;
          return 'Meditate for $hours hour${hours > 1 ? 's' : ''}';
        }
        return 'Meditate for $unlockValue minutes';
      case AchievementUnlockType.sevaActs:
        return 'Perform $unlockValue acts of service';
      case AchievementUnlockType.level:
        return 'Reach spiritual level $unlockValue';
      case AchievementUnlockType.special:
        return description ?? 'Special achievement';
    }
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      titleHindi: json['title_hindi'] as String?,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String? ?? 'emoji_events',
      badgeColor: BadgeColor.fromString(json['badge_color'] as String?),
      unlockType: AchievementUnlockType.fromString(json['unlock_type'] as String?),
      unlockValue: json['unlock_value'] as int,
      coinReward: json['coin_reward'] as int? ?? 0,
      karmaReward: json['karma_reward'] as int? ?? 0,
      experienceReward: json['experience_reward'] as int? ?? 0,
      orderIndex: json['order_index'] as int? ?? 0,
      isSecret: json['is_secret'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'title_hindi': titleHindi,
      'description': description,
      'icon_name': iconName,
      'badge_color': badgeColor.name,
      'unlock_type': unlockType.name,
      'unlock_value': unlockValue,
      'coin_reward': coinReward,
      'karma_reward': karmaReward,
      'experience_reward': experienceReward,
      'order_index': orderIndex,
      'is_secret': isSecret,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Model for user's unlocked achievements
class UserAchievement {
  final String id;
  final String oduserId;
  final String achievementId;
  final Achievement? achievement;
  final DateTime unlockedAt;

  const UserAchievement({
    required this.id,
    required this.oduserId,
    required this.achievementId,
    this.achievement,
    required this.unlockedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json, {Achievement? achievement}) {
    return UserAchievement(
      id: json['id'] as String,
      oduserId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      achievement: achievement,
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': oduserId,
      'achievement_id': achievementId,
      'unlocked_at': unlockedAt.toIso8601String(),
    };
  }
}
