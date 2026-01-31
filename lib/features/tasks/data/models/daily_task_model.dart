import '../../../content/data/models/verse_model.dart';
import '../../../../core/constants/app_constants.dart';

enum TaskType {
  water,
  prayer,
  food,
}

class DailyTaskModel {
  final String id;
  final TaskType type;
  final String? book; // Optional, can be random
  final String? character; // Optional
  final bool isCompleted;
  final bool isSkipped;
  final DateTime assignedDate;
  final VerseContent? verse; // Loaded when clicked
  final int coinReward;
  final int readingTimeMinutes;

  DailyTaskModel({
    required this.id,
    required this.type,
    this.book,
    this.character,
    this.isCompleted = false,
    this.isSkipped = false,
    required this.assignedDate,
    this.verse,
    this.coinReward = 35,
    this.readingTimeMinutes = 2,
  });

  String get title => AppConstants.taskNames[type.name] ?? 'Task';
  String get description => AppConstants.taskDescriptions[type.name] ?? '';

  factory DailyTaskModel.fromJson(Map<String, dynamic> json) {
    return DailyTaskModel(
      id: json['id'] as String,
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaskType.water,
      ),
      book: json['book'] as String?,
      character: json['character'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isSkipped: json['isSkipped'] as bool? ?? false,
      assignedDate: DateTime.parse(json['assignedDate'] as String),
      verse: json['verse'] != null
          ? VerseContent.fromJson(json['verse'] as Map<String, dynamic>)
          : null,
      coinReward: json['coinReward'] as int? ?? 35,
      readingTimeMinutes: json['readingTimeMinutes'] as int? ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'book': book,
      'character': character,
      'isCompleted': isCompleted,
      'isSkipped': isSkipped,
      'assignedDate': assignedDate.toIso8601String(),
      'verse': verse?.toJson(),
      'coinReward': coinReward,
      'readingTimeMinutes': readingTimeMinutes,
    };
  }

  DailyTaskModel copyWith({
    String? id,
    TaskType? type,
    String? book,
    String? character,
    bool? isCompleted,
    bool? isSkipped,
    DateTime? assignedDate,
    VerseContent? verse,
    int? coinReward,
    int? readingTimeMinutes,
  }) {
    return DailyTaskModel(
      id: id ?? this.id,
      type: type ?? this.type,
      book: book ?? this.book,
      character: character ?? this.character,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      assignedDate: assignedDate ?? this.assignedDate,
      verse: verse ?? this.verse,
      coinReward: coinReward ?? this.coinReward,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
    );
  }
}
