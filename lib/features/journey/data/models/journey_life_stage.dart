/// Reference catalog: prenatal, child, elder, etc.
class JourneyLifeStage {
  final String id;
  final String slug;
  final String? title;
  final String? titleHindi;
  final int? displayOrder;

  const JourneyLifeStage({
    required this.id,
    required this.slug,
    this.title,
    this.titleHindi,
    this.displayOrder,
  });

  factory JourneyLifeStage.fromJson(Map<String, dynamic> json) {
    return JourneyLifeStage(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String?,
      titleHindi: json['title_hindi'] as String?,
      displayOrder: json['display_order'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'title': title,
        'title_hindi': titleHindi,
        'display_order': displayOrder,
      };
}
