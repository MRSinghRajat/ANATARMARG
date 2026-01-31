class ParvaModel {
  final int id;
  final String name;
  final String subtitle;
  final ParvaStatus status;
  final int? requiredLevel;
  final String? description;
  final String? imageUrl;

  ParvaModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.status,
    this.requiredLevel,
    this.description,
    this.imageUrl,
  });

  String get displayNumber => id.toString().padLeft(2, '0');

  factory ParvaModel.fromJson(Map<String, dynamic> json) {
    return ParvaModel(
      id: json['id'] as int,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String,
      status: ParvaStatus.values.firstWhere(
        (e) => e.name == json['status'] as String,
        orElse: () => ParvaStatus.locked,
      ),
      requiredLevel: json['required_level'] as int?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'status': status.name,
      'required_level': requiredLevel,
      'description': description,
      'image_url': imageUrl,
    };
  }
}

enum ParvaStatus {
  completed,
  active,
  locked,
}
