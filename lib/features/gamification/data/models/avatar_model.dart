/// Ashram stages of inner development (vision-aligned)
enum Ashram {
  brahmacharya, // Learning & Discipline
  grihastha, // Responsibility & Balance
  vanaprastha, // Reflection & Detachment
  sannyasa, // Inner Freedom
}

/// Inner Avatar model - represents the user's Inner Self
/// Grows through daily actions; no punishment, no shame
class AvatarModel {
  final String? id; // Supabase UUID when synced
  final Ashram ashram;
  final int wisdomLevel; // 1-10; affects visual aura
  final int karmaBalance; // Balance, not score; ethical gamification
  final int streakDays; // Gentle streak; no shame on break
  final DateTime? lastActivityAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  AvatarModel({
    this.id,
    this.ashram = Ashram.brahmacharya,
    this.wisdomLevel = 1,
    this.karmaBalance = 0,
    this.streakDays = 0,
    this.lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Aura opacity based on wisdom level (for visual growth)
  /// Level 1-3: No glow
  /// Level 4-6: Subtle (0.1)
  /// Level 7-9: Medium (0.2)
  /// Level 10: Bright (0.3)
  double get auraOpacity {
    if (wisdomLevel >= 10) return 0.3;
    if (wisdomLevel >= 7) return 0.2;
    if (wisdomLevel >= 4) return 0.1;
    return 0.0;
  }

  AvatarModel copyWith({
    String? id,
    Ashram? ashram,
    int? wisdomLevel,
    int? karmaBalance,
    int? streakDays,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AvatarModel(
      id: id ?? this.id,
      ashram: ashram ?? this.ashram,
      wisdomLevel: wisdomLevel ?? this.wisdomLevel,
      karmaBalance: karmaBalance ?? this.karmaBalance,
      streakDays: streakDays ?? this.streakDays,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['id'] as String?,
      ashram: Ashram.values.firstWhere(
        (e) => e.name == json['ashram'],
        orElse: () => Ashram.brahmacharya,
      ),
      wisdomLevel:
          json['wisdom_level'] as int? ?? json['wisdomLevel'] as int? ?? 1,
      karmaBalance:
          json['karma_balance'] as int? ?? json['karmaBalance'] as int? ?? 0,
      streakDays:
          json['streak_days'] as int? ?? json['streakDays'] as int? ?? 0,
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.parse(json['last_activity_at'] as String)
          : json['lastActivityAt'] != null
              ? DateTime.parse(json['lastActivityAt'] as String)
              : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ashram': ashram.name,
      'wisdom_level': wisdomLevel,
      'karma_balance': karmaBalance,
      'streak_days': streakDays,
      'last_activity_at': lastActivityAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
