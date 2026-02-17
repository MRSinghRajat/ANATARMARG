class StoryPage {
  final int pageNumber;
  final String textEnglish;
  final String textHindi;
  final String? illustrationUrl;
  final bool isFinal;

  StoryPage({
    required this.pageNumber,
    required this.textEnglish,
    required this.textHindi,
    this.illustrationUrl,
    this.isFinal = false,
  });

  factory StoryPage.fromJson(Map<String, dynamic> json) {
    return StoryPage(
      pageNumber: json['page_number'] as int? ?? 0,
      textEnglish: json['text_english'] as String? ?? '',
      textHindi: json['text_hindi'] as String? ?? '',
      illustrationUrl: json['illustration_url'] as String?,
      isFinal: json['is_final'] as bool? ?? false,
    );
  }
}

class DailyStoryModel {
  final String id;
  final int dayOfYear;
  final String storyTitle;
  final String? source;
  final String category;
  final int estimatedMinutes;
  final int totalPages;
  final List<StoryPage> pages;
  final String? keyTeaching;
  final String? reflectionPrompt;
  final String? audioUrl;
  final String? coverImageUrl;
  final bool isActive;

  DailyStoryModel({
    required this.id,
    required this.dayOfYear,
    required this.storyTitle,
    this.source,
    required this.category,
    this.estimatedMinutes = 3,
    this.totalPages = 1,
    required this.pages,
    this.keyTeaching,
    this.reflectionPrompt,
    this.audioUrl,
    this.coverImageUrl,
    this.isActive = true,
  });

  factory DailyStoryModel.fromJson(Map<String, dynamic> json) {
    final rawPages = json['pages'];
    List<StoryPage> pages = [];
    if (rawPages is List) {
      pages = rawPages
          .map((p) => StoryPage.fromJson(p as Map<String, dynamic>))
          .toList();
      pages.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
    }

    return DailyStoryModel(
      id: json['id'] as String? ?? '',
      dayOfYear: json['day_of_year'] as int? ?? 0,
      storyTitle: json['story_title'] as String? ?? 'Story',
      source: json['source'] as String?,
      category: json['category'] as String? ?? 'wisdom',
      estimatedMinutes: json['estimated_minutes'] as int? ?? 3,
      totalPages: json['total_pages'] as int? ?? 1,
      pages: pages,
      keyTeaching: json['key_teaching'] as String?,
      reflectionPrompt: json['reflection_prompt'] as String?,
      audioUrl: json['audio_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
