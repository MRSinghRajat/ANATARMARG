/// Daily verse for Ashram - from Gita, Mahabharata, or GPT fallback
class AshramDailyVerseModel {
  final String id;
  final String bookName;
  final String? chapterName;
  final String? verseNumber;
  final String sanskritText;
  final String hindiOrEnglishText;
  final String dailyLifeImpact;
  final String? source; // 'supabase' | 'gpt'

  const AshramDailyVerseModel({
    required this.id,
    required this.bookName,
    this.chapterName,
    this.verseNumber,
    required this.sanskritText,
    required this.hindiOrEnglishText,
    required this.dailyLifeImpact,
    this.source,
  });
}
