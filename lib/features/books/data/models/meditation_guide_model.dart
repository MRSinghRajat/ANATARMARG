class MeditationStep {
  final int stepNumber;
  final String stepTitle;
  final String instruction;
  final int durationSeconds;

  const MeditationStep({
    required this.stepNumber,
    required this.stepTitle,
    required this.instruction,
    required this.durationSeconds,
  });

  factory MeditationStep.fromJson(Map<String, dynamic> json) {
    return MeditationStep(
      stepNumber: json['step_number'] as int? ?? 1,
      stepTitle: json['step_title'] as String? ?? 'Step',
      instruction: json['instruction'] as String? ?? '',
      durationSeconds: json['duration_seconds'] as int? ?? 60,
    );
  }
}

class MeditationGuideModel {
  final String id;
  final String guideName;
  final String meditationType;
  final int durationSeconds;
  final String difficulty;
  final int totalSteps;
  final List<MeditationStep> steps;
  final String? description;
  final String? completionMessage;
  final String? coverImageUrl;
  final String? audioUrl;
  final String? audioUrlEn;
  final int orderIndex;

  const MeditationGuideModel({
    required this.id,
    required this.guideName,
    required this.meditationType,
    required this.durationSeconds,
    required this.difficulty,
    required this.totalSteps,
    required this.steps,
    this.description,
    this.completionMessage,
    this.coverImageUrl,
    this.audioUrl,
    this.audioUrlEn,
    this.orderIndex = 0,
  });

  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    if (m == 0) return '${s}s';
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }

  String get typeLabel {
    switch (meditationType) {
      case 'breath':
        return 'Breathing';
      case 'body_scan':
        return 'Body Scan';
      case 'visualization':
        return 'Visualization';
      case 'mantra':
        return 'Mantra';
      case 'mindfulness':
        return 'Mindfulness';
      default:
        return meditationType;
    }
  }

  factory MeditationGuideModel.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as List<dynamic>? ?? [];
    return MeditationGuideModel(
      id: json['id'] as String,
      guideName: json['guide_name'] as String? ?? 'Meditation',
      meditationType: json['meditation_type'] as String? ?? 'breath',
      durationSeconds: json['duration_seconds'] as int? ?? 300,
      difficulty: json['difficulty'] as String? ?? 'beginner',
      totalSteps: json['total_steps'] as int? ?? 1,
      steps: stepsJson
          .map((s) => MeditationStep.fromJson(s as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.stepNumber.compareTo(b.stepNumber)),
      description: json['description'] as String?,
      completionMessage: json['completion_message'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      audioUrlEn: json['audio_url_en'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }
}
