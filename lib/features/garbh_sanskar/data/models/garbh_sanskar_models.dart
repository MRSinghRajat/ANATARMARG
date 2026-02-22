// ============================================================
// GARBH SANSKAR DATA MODELS
// ============================================================

/// Represents a single piece of Garbh Sanskar content
/// (mantra, meditation, yoga, pranayama, diet tip, ritual, affirmation, lullaby)
class GarbhSanskarContent {
  final String id;
  final String phase; // prenatal | postnatal | newborn | all
  final String contentType; // mantra | meditation | yoga | pranayama | diet_tip | ritual | affirmation | lullaby
  final int? weekStart;
  final int? weekEnd;
  final int? trimester;
  final String title;
  final String? titleHindi;
  final String? titleSanskrit;
  final String? subtitle;
  final String? description;
  final String? bodyText;
  final String? transliteration;
  final String? translation;
  final String? audioStoragePath;
  final String? videoUrl;
  final String? imageUrl;
  final int? durationSeconds;
  final String? deityAssociated;
  final List<String> benefits;
  final List<String> tags;
  final int coinsReward;
  final bool isPremium;
  final bool isActive;
  final int orderIndex;
  final DateTime createdAt;

  const GarbhSanskarContent({
    required this.id,
    required this.phase,
    required this.contentType,
    this.weekStart,
    this.weekEnd,
    this.trimester,
    required this.title,
    this.titleHindi,
    this.titleSanskrit,
    this.subtitle,
    this.description,
    this.bodyText,
    this.transliteration,
    this.translation,
    this.audioStoragePath,
    this.videoUrl,
    this.imageUrl,
    this.durationSeconds,
    this.deityAssociated,
    this.benefits = const [],
    this.tags = const [],
    this.coinsReward = 5,
    this.isPremium = false,
    this.isActive = true,
    this.orderIndex = 0,
    required this.createdAt,
  });

  factory GarbhSanskarContent.fromJson(Map<String, dynamic> json) {
    return GarbhSanskarContent(
      id: json['id'] as String,
      phase: json['phase'] as String? ?? 'prenatal',
      contentType: json['content_type'] as String? ?? 'mantra',
      weekStart: json['week_start'] as int?,
      weekEnd: json['week_end'] as int?,
      trimester: json['trimester'] as int?,
      title: json['title'] as String? ?? '',
      titleHindi: json['title_hindi'] as String?,
      titleSanskrit: json['title_sanskrit'] as String?,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      bodyText: json['body_text'] as String?,
      transliteration: json['transliteration'] as String?,
      translation: json['translation'] as String?,
      audioStoragePath: json['audio_storage_path'] as String?,
      videoUrl: json['video_url'] as String?,
      imageUrl: json['image_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      deityAssociated: json['deity_associated'] as String?,
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      coinsReward: json['coins_reward'] as int? ?? 5,
      isPremium: json['is_premium'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      orderIndex: json['order_index'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String get displayTitle => titleHindi ?? title;

  String get formattedDuration {
    if (durationSeconds == null) return '';
    final mins = durationSeconds! ~/ 60;
    final secs = durationSeconds! % 60;
    if (mins == 0) return '${secs}s';
    if (secs == 0) return '${mins} min';
    return '${mins}m ${secs}s';
  }

  ContentTypeInfo get typeInfo => ContentTypeInfo.fromType(contentType);
}

/// Display info for each content type
class ContentTypeInfo {
  final String label;
  final String labelHindi;
  final String emoji;
  final int colorValue;

  const ContentTypeInfo({
    required this.label,
    required this.labelHindi,
    required this.emoji,
    required this.colorValue,
  });

  static ContentTypeInfo fromType(String type) {
    switch (type) {
      case 'mantra':
        return const ContentTypeInfo(
            label: 'Mantra', labelHindi: 'मंत्र', emoji: '🕉️', colorValue: 0xFFFF9933);
      case 'meditation':
        return const ContentTypeInfo(
            label: 'Meditation', labelHindi: 'ध्यान', emoji: '🧘', colorValue: 0xFF7C3AED);
      case 'yoga':
        return const ContentTypeInfo(
            label: 'Yoga', labelHindi: 'योग', emoji: '🌿', colorValue: 0xFF16A34A);
      case 'pranayama':
        return const ContentTypeInfo(
            label: 'Pranayama', labelHindi: 'प्राणायाम', emoji: '💨', colorValue: 0xFF0EA5E9);
      case 'diet_tip':
        return const ContentTypeInfo(
            label: 'Diet', labelHindi: 'आहार', emoji: '🥗', colorValue: 0xFFEA580C);
      case 'ritual':
        return const ContentTypeInfo(
            label: 'Ritual', labelHindi: 'संस्कार', emoji: '🪔', colorValue: 0xFFD97706);
      case 'affirmation':
        return const ContentTypeInfo(
            label: 'Affirmation', labelHindi: 'पुष्टि', emoji: '💛', colorValue: 0xFFF59E0B);
      case 'lullaby':
        return const ContentTypeInfo(
            label: 'Lullaby', labelHindi: 'लोरी', emoji: '🌙', colorValue: 0xFF6366F1);
      case 'story':
        return const ContentTypeInfo(
            label: 'Story', labelHindi: 'कहानी', emoji: '📖', colorValue: 0xFFEC4899);
      default:
        return const ContentTypeInfo(
            label: 'Content', labelHindi: 'सामग्री', emoji: '✨', colorValue: 0xFF6B7280);
    }
  }
}

/// User's pregnancy journey state
class UserPregnancyJourney {
  final String id;
  final String userId;
  final DateTime? dueDate;
  final DateTime? birthDate;
  final String? babyName;
  final String? babyGender;
  final int? currentWeek;
  final String mode; // prenatal | postnatal | completed
  final String? motherName;
  final String preferredLanguage;
  final int totalSessionsCompleted;
  final int totalMinutesListened;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserPregnancyJourney({
    required this.id,
    required this.userId,
    this.dueDate,
    this.birthDate,
    this.babyName,
    this.babyGender,
    this.currentWeek,
    required this.mode,
    this.motherName,
    this.preferredLanguage = 'hi',
    this.totalSessionsCompleted = 0,
    this.totalMinutesListened = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPregnancyJourney.fromJson(Map<String, dynamic> json) {
    return UserPregnancyJourney(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'] as String)
          : null,
      babyName: json['baby_name'] as String?,
      babyGender: json['baby_gender'] as String?,
      currentWeek: json['current_week'] as int?,
      mode: json['mode'] as String? ?? 'prenatal',
      motherName: json['mother_name'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'hi',
      totalSessionsCompleted: json['total_sessions_completed'] as int? ?? 0,
      totalMinutesListened: json['total_minutes_listened'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'due_date': dueDate?.toIso8601String().split('T')[0],
        'birth_date': birthDate?.toIso8601String().split('T')[0],
        'baby_name': babyName,
        'baby_gender': babyGender,
        'current_week': currentWeek,
        'mode': mode,
        'mother_name': motherName,
        'preferred_language': preferredLanguage,
      };

  bool get isPrenatal => mode == 'prenatal';
  bool get isPostnatal => mode == 'postnatal';

  int get computedCurrentWeek {
    if (currentWeek != null) return currentWeek!;
    if (dueDate == null) return 1;
    final daysUntilDue = dueDate!.difference(DateTime.now()).inDays;
    final week = 40 - (daysUntilDue / 7).ceil();
    return week.clamp(1, 42);
  }

  int get trimester {
    final w = computedCurrentWeek;
    if (w <= 13) return 1;
    if (w <= 27) return 2;
    return 3;
  }

  String get trimesterLabel {
    switch (trimester) {
      case 1:
        return 'First Trimester';
      case 2:
        return 'Second Trimester';
      case 3:
        return 'Third Trimester';
      default:
        return '';
    }
  }

  String get trimesterLabelHindi {
    switch (trimester) {
      case 1:
        return 'पहली तिमाही';
      case 2:
        return 'दूसरी तिमाही';
      case 3:
        return 'तीसरी तिमाही';
      default:
        return '';
    }
  }

  int? get babyAgeInDays {
    if (birthDate == null) return null;
    return DateTime.now().difference(birthDate!).inDays;
  }

  String get babyAgeLabel {
    final days = babyAgeInDays;
    if (days == null) return '';
    if (days < 7) return '$days days old';
    if (days < 30) return '${days ~/ 7} weeks old';
    final months = days ~/ 30;
    return '$months month${months == 1 ? '' : 's'} old';
  }

  UserPregnancyJourney copyWith({
    DateTime? dueDate,
    DateTime? birthDate,
    String? babyName,
    String? babyGender,
    int? currentWeek,
    String? mode,
    String? motherName,
    int? totalSessionsCompleted,
    int? totalMinutesListened,
  }) {
    return UserPregnancyJourney(
      id: id,
      userId: userId,
      dueDate: dueDate ?? this.dueDate,
      birthDate: birthDate ?? this.birthDate,
      babyName: babyName ?? this.babyName,
      babyGender: babyGender ?? this.babyGender,
      currentWeek: currentWeek ?? this.currentWeek,
      mode: mode ?? this.mode,
      motherName: motherName ?? this.motherName,
      preferredLanguage: preferredLanguage,
      totalSessionsCompleted:
          totalSessionsCompleted ?? this.totalSessionsCompleted,
      totalMinutesListened: totalMinutesListened ?? this.totalMinutesListened,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// A Samskara (prenatal or postnatal)
class GarbhSamskara {
  final int id;
  final String name;
  final String nameSanskrit;
  final String timing;
  final String description;
  final String? significance;
  final List<SamskaraStep> ritualSteps;
  final List<String> requiredItems;
  final List<String> mantras;
  final String? imageUrl;
  final int orderIndex;
  final String type; // 'prenatal' | 'postnatal'

  const GarbhSamskara({
    required this.id,
    required this.name,
    required this.nameSanskrit,
    required this.timing,
    required this.description,
    this.significance,
    required this.ritualSteps,
    required this.requiredItems,
    required this.mantras,
    this.imageUrl,
    required this.orderIndex,
    required this.type,
  });

  factory GarbhSamskara.fromJson(Map<String, dynamic> json, String type) {
    final stepsRaw = json['ritual_steps'];
    List<SamskaraStep> steps = [];
    if (stepsRaw is List) {
      steps = stepsRaw
          .map((s) => SamskaraStep.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return GarbhSamskara(
      id: json['id'] as int,
      name: json['name'] as String,
      nameSanskrit: json['name_sanskrit'] as String,
      timing: json['timing'] as String,
      description: json['description'] as String,
      significance: json['significance'] as String?,
      ritualSteps: steps,
      requiredItems: (json['required_items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mantras: (json['mantras'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: json['image_url'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      type: type,
    );
  }
}

class SamskaraStep {
  final int step;
  final String title;
  final String description;
  final String? mantra;

  const SamskaraStep({
    required this.step,
    required this.title,
    required this.description,
    this.mantra,
  });

  factory SamskaraStep.fromJson(Map<String, dynamic> json) {
    return SamskaraStep(
      step: json['step'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mantra: json['mantra'] as String?,
    );
  }
}

/// User's content progress
class UserGsContentProgress {
  final String id;
  final String userId;
  final String contentId;
  final String status; // started | completed
  final DateTime? completedAt;
  final int listenDurationSeconds;
  final int coinsEarned;

  const UserGsContentProgress({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.status,
    this.completedAt,
    this.listenDurationSeconds = 0,
    this.coinsEarned = 0,
  });

  factory UserGsContentProgress.fromJson(Map<String, dynamic> json) {
    return UserGsContentProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      contentId: json['content_id'] as String,
      status: json['status'] as String? ?? 'started',
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      listenDurationSeconds: json['listen_duration_seconds'] as int? ?? 0,
      coinsEarned: json['coins_earned'] as int? ?? 0,
    );
  }

  bool get isCompleted => status == 'completed';
}

/// Lullaby model
class Lullaby {
  final String id;
  final String title;
  final String? titleHindi;
  final String language;
  final String? deityAssociated;
  final String? lyrics;
  final String? transliteration;
  final String? translation;
  final String audioStoragePath;
  final String? imageUrl;
  final int? durationSeconds;
  final int ageRangeMonthsMin;
  final int ageRangeMonthsMax;
  final String? mood;
  final int orderIndex;

  const Lullaby({
    required this.id,
    required this.title,
    this.titleHindi,
    required this.language,
    this.deityAssociated,
    this.lyrics,
    this.transliteration,
    this.translation,
    required this.audioStoragePath,
    this.imageUrl,
    this.durationSeconds,
    this.ageRangeMonthsMin = 0,
    this.ageRangeMonthsMax = 36,
    this.mood,
    this.orderIndex = 0,
  });

  factory Lullaby.fromJson(Map<String, dynamic> json) {
    return Lullaby(
      id: json['id'] as String,
      title: json['title'] as String,
      titleHindi: json['title_hindi'] as String?,
      language: json['language'] as String? ?? 'hi',
      deityAssociated: json['deity_associated'] as String?,
      lyrics: json['lyrics'] as String?,
      transliteration: json['transliteration'] as String?,
      translation: json['translation'] as String?,
      audioStoragePath: json['audio_storage_path'] as String,
      imageUrl: json['image_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      ageRangeMonthsMin: json['age_range_months_min'] as int? ?? 0,
      ageRangeMonthsMax: json['age_range_months_max'] as int? ?? 36,
      mood: json['mood'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  String get displayTitle => titleHindi ?? title;

  String get formattedDuration {
    if (durationSeconds == null) return '';
    final mins = durationSeconds! ~/ 60;
    final secs = durationSeconds! % 60;
    if (mins == 0) return '${secs}s';
    if (secs == 0) return '${mins} min';
    return '${mins}m ${secs}s';
  }
}

/// Baby milestone model
class BabyMilestone {
  final String id;
  final String userId;
  final String milestoneType;
  final DateTime milestoneDate;
  final int? babyAgeDays;
  final String? notes;
  final String? photoStoragePath;
  final int coinsEarned;
  final DateTime createdAt;

  const BabyMilestone({
    required this.id,
    required this.userId,
    required this.milestoneType,
    required this.milestoneDate,
    this.babyAgeDays,
    this.notes,
    this.photoStoragePath,
    this.coinsEarned = 10,
    required this.createdAt,
  });

  factory BabyMilestone.fromJson(Map<String, dynamic> json) {
    return BabyMilestone(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      milestoneType: json['milestone_type'] as String,
      milestoneDate:
          DateTime.parse(json['milestone_date'] as String),
      babyAgeDays: json['baby_age_days'] as int?,
      notes: json['notes'] as String?,
      photoStoragePath: json['photo_storage_path'] as String?,
      coinsEarned: json['coins_earned'] as int? ?? 10,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String get milestoneLabel {
    switch (milestoneType) {
      case 'jatakarma':
        return 'Jatakarma';
      case 'namakarana':
        return 'Namakarana';
      case 'nishkramana':
        return 'Nishkramana';
      case 'annaprashana':
        return 'Annaprashana';
      case 'chudakarana':
        return 'Chudakarana';
      case 'karnavedha':
        return 'Karnavedha';
      case 'vidyarambha':
        return 'Vidyarambha';
      case 'first_smile':
        return 'First Smile 😊';
      case 'first_word':
        return 'First Word 🗣️';
      case 'first_step':
        return 'First Step 👣';
      case 'first_laugh':
        return 'First Laugh 😂';
      case 'head_control':
        return 'Head Control';
      case 'sitting':
        return 'Sitting Up';
      case 'crawling':
        return 'Crawling';
      default:
        return milestoneType;
    }
  }

  String get milestoneEmoji {
    switch (milestoneType) {
      case 'jatakarma':
        return '🪔';
      case 'namakarana':
        return '📿';
      case 'nishkramana':
        return '☀️';
      case 'annaprashana':
        return '🍚';
      case 'chudakarana':
        return '✂️';
      case 'karnavedha':
        return '💎';
      case 'vidyarambha':
        return '📚';
      case 'first_smile':
        return '😊';
      case 'first_word':
        return '🗣️';
      case 'first_step':
        return '👣';
      case 'first_laugh':
        return '😂';
      case 'head_control':
        return '💪';
      case 'sitting':
        return '🧸';
      case 'crawling':
        return '🐾';
      default:
        return '⭐';
    }
  }
}

/// Week-by-week development info (static data)
class WeekDevelopmentInfo {
  final int week;
  final String babySize;
  final String babySizeEmoji;
  final String babyDevelopment;
  final String motherTip;
  final String mantraRecommendation;

  const WeekDevelopmentInfo({
    required this.week,
    required this.babySize,
    required this.babySizeEmoji,
    required this.babyDevelopment,
    required this.motherTip,
    required this.mantraRecommendation,
  });

  static WeekDevelopmentInfo forWeek(int week) {
    return _weekData[week.clamp(1, 40)] ?? _weekData[1]!;
  }

  static final Map<int, WeekDevelopmentInfo> _weekData = {
    1: WeekDevelopmentInfo(
        week: 1, babySize: 'Poppy seed', babySizeEmoji: '🌱',
        babyDevelopment: 'The journey begins. The fertilised egg is implanting in the uterus.',
        motherTip: 'Start taking folic acid. Eat fresh fruits and vegetables.',
        mantraRecommendation: 'Ganesha Mantra — for auspicious beginnings'),
    4: WeekDevelopmentInfo(
        week: 4, babySize: 'Sesame seed', babySizeEmoji: '🌾',
        babyDevelopment: 'The neural tube is forming — the foundation of the brain and spinal cord.',
        motherTip: 'Rest as much as possible. Morning sickness may begin.',
        mantraRecommendation: 'Gayatri Mantra — for the baby\'s developing mind'),
    8: WeekDevelopmentInfo(
        week: 8, babySize: 'Raspberry', babySizeEmoji: '🫐',
        babyDevelopment: 'Tiny fingers and toes are forming. The heart is beating strongly.',
        motherTip: 'Eat small, frequent meals to manage nausea.',
        mantraRecommendation: 'Santana Gopala Mantra — for the baby\'s heart'),
    12: WeekDevelopmentInfo(
        week: 12, babySize: 'Lime', babySizeEmoji: '🍋',
        babyDevelopment: 'All major organs are formed. The baby can move, though you can\'t feel it yet.',
        motherTip: 'First trimester is ending. Energy levels should improve soon.',
        mantraRecommendation: 'Maha Mrityunjaya Mantra — for protection and health'),
    16: WeekDevelopmentInfo(
        week: 16, babySize: 'Avocado', babySizeEmoji: '🥑',
        babyDevelopment: 'The baby can hear! Your voice is the most comforting sound in their world.',
        motherTip: 'Start talking and singing to your baby. They can hear you.',
        mantraRecommendation: 'Om Namah Shivaya — the baby can hear this mantra'),
    20: WeekDevelopmentInfo(
        week: 20, babySize: 'Banana', babySizeEmoji: '🍌',
        babyDevelopment: 'Halfway there! The baby is swallowing amniotic fluid and developing taste buds.',
        motherTip: 'Eat a variety of flavours — your baby tastes what you eat.',
        mantraRecommendation: 'Vishnu Sahasranama — for the baby\'s protection'),
    24: WeekDevelopmentInfo(
        week: 24, babySize: 'Corn', babySizeEmoji: '🌽',
        babyDevelopment: 'The baby\'s face is fully formed. They are making facial expressions.',
        motherTip: 'Practice prenatal yoga to relieve back pain and improve sleep.',
        mantraRecommendation: 'Lalita Sahasranama — invoking the Divine Mother'),
    28: WeekDevelopmentInfo(
        week: 28, babySize: 'Eggplant', babySizeEmoji: '🍆',
        babyDevelopment: 'The baby can open their eyes and see light. The brain is developing rapidly.',
        motherTip: 'Sleep on your left side for better circulation.',
        mantraRecommendation: 'Lalita Sahasranama — for safe delivery'),
    32: WeekDevelopmentInfo(
        week: 32, babySize: 'Squash', babySizeEmoji: '🎃',
        babyDevelopment: 'The baby is practising breathing movements. They have a regular sleep cycle.',
        motherTip: 'Prepare your birth plan. Practice breathing exercises.',
        mantraRecommendation: 'Maha Mrityunjaya Mantra — for a safe birth'),
    36: WeekDevelopmentInfo(
        week: 36, babySize: 'Papaya', babySizeEmoji: '🍈',
        babyDevelopment: 'The baby is almost ready. They are in the head-down position.',
        motherTip: 'Pack your hospital bag. Rest as much as possible.',
        mantraRecommendation: 'Devi Stuti — invoking the Mother\'s grace'),
    40: WeekDevelopmentInfo(
        week: 40, babySize: 'Watermelon', babySizeEmoji: '🍉',
        babyDevelopment: 'Full term! The baby is ready to meet you.',
        motherTip: 'Trust your body. The divine is with you.',
        mantraRecommendation: 'Surrender Meditation — release and trust'),
  };
}
