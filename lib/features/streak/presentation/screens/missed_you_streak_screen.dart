import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Re-engagement screen when user hasn't opened the app for a while.
/// "We missed you so much", "Start today" to restart streak.
class MissedYouStreakScreen extends StatelessWidget {
  final int? previousStreak;
  final VoidCallback onStartToday;

  const MissedYouStreakScreen({
    super.key,
    required this.onStartToday,
    this.previousStreak,
  });

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF1a1625);
    final gold = AppColors.journeyGold;
    final muted = Colors.white70;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Heart icon
              Icon(
                Icons.favorite_rounded,
                size: 64,
                color: AppColors.heartRed.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 24),
              Text(
                'We missed you so much!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                previousStreak != null && previousStreak! > 0
                    ? 'Your previous $previousStreak-day streak has ended, but great to see you back. Ready to start fresh?'
                    : 'Antar मार्ग is here whenever you are. Start today and build your practice again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: muted,
                  height: 1.45,
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onStartToday();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: gold.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Start today',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
