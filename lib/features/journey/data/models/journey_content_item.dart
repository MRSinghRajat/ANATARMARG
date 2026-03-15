/// Content item from v_journey_content_resolved view.
/// Pre-joined with story/text/lullaby/chapter metadata.
class JourneyContentItem {
  final String id;
  final String taskSlug;
  final String slug;
  final int? ageDaysFrom;
  final int? ageDaysTo;
  final String genderTarget;
  final String category;
  final String rotationType;
  final String title;
  final String? titleHindi;
  final String? content;
  final String? contentHindi;
  final String? instruction;
  final String? instructionHindi;
  final String? refType;
  final String? refId;
  final String? refSlug;
  final String? audioUrl;
  final String? audioUrlEn;
  final String icon;
  final int durationMinutes;
  final int? mantraCount;
  final int displayOrder;

  // Pre-joined resolved fields from the view
  final String? storyTitle;
  final String? storyCoverImage;
  final String? sacredTextTitle;
  final String? sacredTextCover;
  final String? lullabyTitle;
  final String? lullabyStoragePath;
  final String? chapterTitle;
  final String? bookName;

  const JourneyContentItem({
    required this.id,
    required this.taskSlug,
    this.slug = '',
    this.ageDaysFrom,
    this.ageDaysTo,
    this.genderTarget = 'both',
    this.category = '',
    this.rotationType = 'sequential',
    required this.title,
    this.titleHindi,
    this.content,
    this.contentHindi,
    this.instruction,
    this.instructionHindi,
    this.refType,
    this.refId,
    this.refSlug,
    this.audioUrl,
    this.audioUrlEn,
    this.icon = '',
    this.durationMinutes = 0,
    this.mantraCount,
    this.displayOrder = 0,
    this.storyTitle,
    this.storyCoverImage,
    this.sacredTextTitle,
    this.sacredTextCover,
    this.lullabyTitle,
    this.lullabyStoragePath,
    this.chapterTitle,
    this.bookName,
  });

  /// Display title: use the pre-joined resolved title when ref_type links to existing content.
  String get resolvedTitle {
    if (refType == 'story' && storyTitle != null) return storyTitle!;
    if (refType == 'sacred_text' && sacredTextTitle != null) return sacredTextTitle!;
    if (refType == 'lullaby' && lullabyTitle != null) return lullabyTitle!;
    if (refType == 'chapter' && chapterTitle != null) return chapterTitle!;
    return title;
  }

  String? get resolvedCoverImage {
    if (refType == 'story') return storyCoverImage;
    if (refType == 'sacred_text') return sacredTextCover;
    return null;
  }

  bool get isInline => refType == null || refType!.isEmpty;

  factory JourneyContentItem.fromJson(Map<String, dynamic> json) {
    return JourneyContentItem(
      id: json['id'] as String? ?? '',
      taskSlug: json['task_slug'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      ageDaysFrom: json['age_days_from'] as int?,
      ageDaysTo: json['age_days_to'] as int?,
      genderTarget: json['gender_target'] as String? ?? 'both',
      category: json['category'] as String? ?? '',
      rotationType: json['rotation_type'] as String? ?? 'sequential',
      title: json['title'] as String? ?? '',
      titleHindi: json['title_hindi'] as String?,
      content: json['content'] as String?,
      contentHindi: json['content_hindi'] as String?,
      instruction: json['instruction'] as String?,
      instructionHindi: json['instruction_hindi'] as String?,
      refType: json['ref_type'] as String?,
      refId: json['ref_id'] as String?,
      refSlug: json['ref_slug'] as String?,
      audioUrl: json['audio_url'] as String?,
      audioUrlEn: json['audio_url_en'] as String?,
      icon: json['icon'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      mantraCount: json['mantra_count'] as int?,
      displayOrder: json['display_order'] as int? ?? 0,
      storyTitle: json['story_title'] as String?,
      storyCoverImage: json['story_cover_image'] as String?,
      sacredTextTitle: json['sacred_text_title'] as String?,
      sacredTextCover: json['sacred_text_cover'] as String?,
      lullabyTitle: json['lullaby_title'] as String?,
      lullabyStoragePath: json['lullaby_storage_path'] as String?,
      chapterTitle: json['chapter_title'] as String?,
      bookName: json['book_name'] as String?,
    );
  }
}
