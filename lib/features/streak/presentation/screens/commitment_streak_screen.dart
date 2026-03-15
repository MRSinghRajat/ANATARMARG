import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/daily_streak_service.dart';

/// Asks "How many days do you think you can practice daily?" with options
/// 2, 5, 7, 14 days and "Commit to this goal!" button.
class CommitmentStreakScreen extends StatefulWidget {
  final VoidCallback onCommitted;

  const CommitmentStreakScreen({
    super.key,
    required this.onCommitted,
  });

  static const List<({int days, String label, String emoji})> options = [
    (days: 2, label: 'Baby steps', emoji: '👏'),
    (days: 5, label: 'Strong start', emoji: '💪'),
    (days: 7, label: 'Clearly committed', emoji: '🎯'),
    (days: 14, label: 'Unstoppable streak', emoji: '🔥'),
  ];

  @override
  State<CommitmentStreakScreen> createState() => _CommitmentStreakScreenState();
}

class _CommitmentStreakScreenState extends State<CommitmentStreakScreen> {
  int? _selectedDays;

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF1a1625);
    final gold = AppColors.journeyGold;
    final muted = Colors.white70;
    final cardBg = Colors.white.withValues(alpha: 0.06);
    final border = gold.withValues(alpha: 0.25);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'How many days in a row will you practice with Antar मार्ग?',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a goal that feels doable. You can always raise it later!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              ...CommitmentStreakScreen.options.map((o) {
                final isSelected = _selectedDays == o.days;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: isSelected ? gold.withValues(alpha: 0.15) : cardBg,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedDays = o.days);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? gold : border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              o.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${o.days} days',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    o.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: gold,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedDays == null
                      ? null
                      : () async {
                          HapticFeedback.mediumImpact();
                          await DailyStreakService.instance.setCommittedGoal(
                            _selectedDays!,
                          );
                          widget.onCommitted();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: muted,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Commit to this goal!',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Maybe later',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
