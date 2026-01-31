enum QuestStageStatus {
  completed,
  current,
  locked,
}

class QuestStageModel {
  final String id;
  final int parvaId;
  final String title;
  final String description;
  final QuestStageStatus status;
  final int orderIndex;
  final String? imageUrl;
  final String? content; // Full content/story for the stage

  QuestStageModel({
    required this.id,
    required this.parvaId,
    required this.title,
    required this.description,
    required this.status,
    required this.orderIndex,
    this.imageUrl,
    this.content,
  });

  factory QuestStageModel.fromJson(Map<String, dynamic> json) {
    return QuestStageModel(
      id: json['id'] as String,
      parvaId: json['parva_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      status: QuestStageStatus.values.firstWhere(
        (e) => e.name == json['status'] as String,
        orElse: () => QuestStageStatus.locked,
      ),
      orderIndex: json['order_index'] as int,
      imageUrl: json['image_url'] as String?,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parva_id': parvaId,
      'title': title,
      'description': description,
      'status': status.name,
      'order_index': orderIndex,
      'image_url': imageUrl,
      'content': content,
    };
  }
}
