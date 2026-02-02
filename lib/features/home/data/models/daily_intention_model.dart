enum IntentionTone {
  gentle,
  neutral,
  encouraging,
}

enum AgeGroup {
  kids,
  adults,
}

class DailyIntentionModel {
  final String id;
  final String text;
  final IntentionTone tone;
  final AgeGroup ageGroup;

  DailyIntentionModel({
    required this.id,
    required this.text,
    this.tone = IntentionTone.gentle,
    this.ageGroup = AgeGroup.kids,
  });

  factory DailyIntentionModel.fromJson(Map<String, dynamic> json) {
    return DailyIntentionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      tone: IntentionTone.values.firstWhere(
        (e) => e.name == json['tone'],
        orElse: () => IntentionTone.gentle,
      ),
      ageGroup: AgeGroup.values.firstWhere(
        (e) => e.name == json['ageGroup'],
        orElse: () => AgeGroup.kids,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'tone': tone.name,
      'ageGroup': ageGroup.name,
    };
  }
}
