/// Model for daily task templates (system-defined tasks)
class DailyTaskTemplate {
  final String id;
  final String slug;
  final String category;
  final String title;
  final String? titleHindi;
  final String? description;
  final String iconName;
  final int coinReward;
  final int karmaReward;
  final double streakMultiplier;
  final bool isDaily;
  final bool isSystemTask;
  final bool requiresVerification;
  final int estimatedMinutes;
  final List<int> availableDays;
  final int unlockAfterDays;
  final int orderIndex;
  final bool isActive;

  const DailyTaskTemplate({
    required this.id,
    required this.slug,
    required this.category,
    required this.title,
    this.titleHindi,
    this.description,
    this.iconName = 'auto_awesome',
    this.coinReward = 5,
    this.karmaReward = 1,
    this.streakMultiplier = 1.0,
    this.isDaily = true,
    this.isSystemTask = true,
    this.requiresVerification = false,
    this.estimatedMinutes = 5,
    this.availableDays = const [0, 1, 2, 3, 4, 5, 6],
    this.unlockAfterDays = 0,
    this.orderIndex = 0,
    this.isActive = true,
  });

  factory DailyTaskTemplate.fromJson(Map<String, dynamic> json) {
    return DailyTaskTemplate(
      id: json['id'] as String,
      slug: json['slug'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      titleHindi: json['title_hindi'] as String?,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String? ?? 'auto_awesome',
      coinReward: json['coin_reward'] as int? ?? 5,
      karmaReward: json['karma_reward'] as int? ?? 1,
      streakMultiplier: (json['streak_multiplier'] as num?)?.toDouble() ?? 1.0,
      isDaily: json['is_daily'] as bool? ?? true,
      isSystemTask: json['is_system_task'] as bool? ?? true,
      requiresVerification: json['requires_verification'] as bool? ?? false,
      estimatedMinutes: json['estimated_minutes'] as int? ?? 5,
      availableDays: (json['available_days'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [0, 1, 2, 3, 4, 5, 6],
      unlockAfterDays: json['unlock_after_days'] as int? ?? 0,
      orderIndex: json['order_index'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'category': category,
      'title': title,
      'title_hindi': titleHindi,
      'description': description,
      'icon_name': iconName,
      'coin_reward': coinReward,
      'karma_reward': karmaReward,
      'streak_multiplier': streakMultiplier,
      'is_daily': isDaily,
      'is_system_task': isSystemTask,
      'requires_verification': requiresVerification,
      'estimated_minutes': estimatedMinutes,
      'available_days': availableDays,
      'unlock_after_days': unlockAfterDays,
      'order_index': orderIndex,
      'is_active': isActive,
    };
  }
}

/// Task status enum
enum TaskStatus { pending, completed, skipped, expired }

/// Model for user's daily task assignments
class UserDailyTask {
  final String id;
  final String userId;
  final DateTime taskDate;
  final String? templateId;
  final DailyTaskTemplate? template;
  final Map<String, dynamic> dynamicContent;
  final TaskStatus status;
  final DateTime? completedAt;
  final int coinsEarned;
  final int karmaEarned;
  final DateTime createdAt;

  const UserDailyTask({
    required this.id,
    required this.userId,
    required this.taskDate,
    this.templateId,
    this.template,
    this.dynamicContent = const {},
    this.status = TaskStatus.pending,
    this.completedAt,
    this.coinsEarned = 0,
    this.karmaEarned = 0,
    required this.createdAt,
  });

  bool get isCompleted => status == TaskStatus.completed;
  bool get isPending => status == TaskStatus.pending;

  String get slug => template?.slug ?? dynamicContent['slug'] as String? ?? '';
  String get title => template?.title ?? dynamicContent['title'] as String? ?? 'Task';
  String? get titleHindi => template?.titleHindi ?? dynamicContent['title_hindi'] as String?;
  String? get description => template?.description ?? dynamicContent['description'] as String?;
  String get iconName => template?.iconName ?? dynamicContent['icon_name'] as String? ?? 'check_circle';
  String get category => template?.category ?? dynamicContent['category'] as String? ?? 'custom';
  int get coinReward => template?.coinReward ?? dynamicContent['coin_reward'] as int? ?? 5;
  int get karmaReward => template?.karmaReward ?? dynamicContent['karma_reward'] as int? ?? 1;
  int get estimatedMinutes => template?.estimatedMinutes ?? dynamicContent['estimated_minutes'] as int? ?? 5;

  factory UserDailyTask.fromJson(Map<String, dynamic> json, {DailyTaskTemplate? template}) {
    return UserDailyTask(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      taskDate: DateTime.parse(json['task_date'] as String),
      templateId: json['template_id'] as String?,
      template: template,
      dynamicContent: json['dynamic_content'] as Map<String, dynamic>? ?? {},
      status: _parseStatus(json['status'] as String?),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      coinsEarned: json['coins_earned'] as int? ?? 0,
      karmaEarned: json['karma_earned'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'task_date': taskDate.toIso8601String().split('T')[0],
      'template_id': templateId,
      'dynamic_content': dynamicContent,
      'status': status.name,
      'completed_at': completedAt?.toIso8601String(),
      'coins_earned': coinsEarned,
      'karma_earned': karmaEarned,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserDailyTask copyWith({
    String? id,
    String? userId,
    DateTime? taskDate,
    String? templateId,
    DailyTaskTemplate? template,
    Map<String, dynamic>? dynamicContent,
    TaskStatus? status,
    DateTime? completedAt,
    int? coinsEarned,
    int? karmaEarned,
    DateTime? createdAt,
  }) {
    return UserDailyTask(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskDate: taskDate ?? this.taskDate,
      templateId: templateId ?? this.templateId,
      template: template ?? this.template,
      dynamicContent: dynamicContent ?? this.dynamicContent,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      karmaEarned: karmaEarned ?? this.karmaEarned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static TaskStatus _parseStatus(String? status) {
    switch (status) {
      case 'completed':
        return TaskStatus.completed;
      case 'skipped':
        return TaskStatus.skipped;
      case 'expired':
        return TaskStatus.expired;
      default:
        return TaskStatus.pending;
    }
  }
}

/// Task category enum with display properties
enum TaskCategory {
  scripture,
  meditation,
  seva,
  lifestyle,
  devotion,
  learning,
  custom;

  String get displayName {
    switch (this) {
      case TaskCategory.scripture:
        return 'Scripture';
      case TaskCategory.meditation:
        return 'Meditation';
      case TaskCategory.seva:
        return 'Seva';
      case TaskCategory.lifestyle:
        return 'Lifestyle';
      case TaskCategory.devotion:
        return 'Devotion';
      case TaskCategory.learning:
        return 'Learning';
      case TaskCategory.custom:
        return 'Custom';
    }
  }

  String get displayNameHindi {
    switch (this) {
      case TaskCategory.scripture:
        return 'शास्त्र';
      case TaskCategory.meditation:
        return 'ध्यान';
      case TaskCategory.seva:
        return 'सेवा';
      case TaskCategory.lifestyle:
        return 'जीवनशैली';
      case TaskCategory.devotion:
        return 'भक्ति';
      case TaskCategory.learning:
        return 'शिक्षा';
      case TaskCategory.custom:
        return 'व्यक्तिगत';
    }
  }

  String get iconName {
    switch (this) {
      case TaskCategory.scripture:
        return 'menu_book';
      case TaskCategory.meditation:
        return 'self_improvement';
      case TaskCategory.seva:
        return 'volunteer_activism';
      case TaskCategory.lifestyle:
        return 'eco';
      case TaskCategory.devotion:
        return 'temple_hindu';
      case TaskCategory.learning:
        return 'school';
      case TaskCategory.custom:
        return 'add_task';
    }
  }

  static TaskCategory fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'scripture':
        return TaskCategory.scripture;
      case 'meditation':
        return TaskCategory.meditation;
      case 'seva':
        return TaskCategory.seva;
      case 'lifestyle':
        return TaskCategory.lifestyle;
      case 'devotion':
        return TaskCategory.devotion;
      case 'learning':
        return TaskCategory.learning;
      default:
        return TaskCategory.custom;
    }
  }
}
