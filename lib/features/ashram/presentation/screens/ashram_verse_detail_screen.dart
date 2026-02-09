import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/ashram_daily_verse_model.dart';
import '../../data/repositories/ashram_daily_verse_repository.dart';

class AshramVerseDetailScreen extends StatelessWidget {
  final AshramDailyVerseModel verse;

  const AshramVerseDetailScreen({
    super.key,
    required this.verse,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ashramBackgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.ashramBackgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () async {
            await AshramDailyVerseRepository().markViewed();
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
        title: Text(
          verse.bookName,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (verse.chapterName != null || verse.verseNumber != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  [verse.chapterName, verse.verseNumber]
                      .whereType<String>()
                      .where((s) => s.isNotEmpty)
                      .join(' • '),
                  style: GoogleFonts.outfit(
                    color: AppColors.ashramAccentGold,
                    fontSize: 14,
                  ),
                ),
              ),
            // Sanskrit
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.ashramSaffron.withOpacity(0.2)),
              ),
              child: Text(
                verse.sanskritText,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Hindi/English
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.ashramSaffron.withOpacity(0.2)),
              ),
              child: Text(
                verse.hindiOrEnglishText,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Daily life impact
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.ashramSaffron.withOpacity(0.15),
                    AppColors.ashramSaffron.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.ashramSaffron.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.ashramAccentGold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Life Wisdom',
                        style: GoogleFonts.outfit(
                          color: AppColors.ashramAccentGold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    verse.dailyLifeImpact,
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'This is how it impacts your daily life and how you should process it in your daily life.',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
