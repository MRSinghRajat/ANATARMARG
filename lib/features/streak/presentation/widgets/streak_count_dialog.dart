import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'streak_gradient_buttons.dart';

/// Celebration for day N streak (N > 1).
class StreakCountDialog extends StatefulWidget {
  final int dayCount;
  final VoidCallback onDismiss;

  const StreakCountDialog({
    super.key,
    required this.dayCount,
    required this.onDismiss,
  });

  static Future<void> show(BuildContext context, int dayCount) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => StreakCountDialog(
        dayCount: dayCount,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  State<StreakCountDialog> createState() => _StreakCountDialogState();
}

class _StreakCountDialogState extends State<StreakCountDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = AppColors.journeyGold;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.ashramCardDark,
              AppColors.journeyDeepPurple.withValues(alpha: 0.85),
              AppColors.deepPurple.withValues(alpha: 0.4),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
          border: Border.all(color: gold.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) {
                  return Transform.scale(
                    scale: 1 + 0.06 * math.sin(_pulse.value * 2 * math.pi),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [gold, AppColors.primaryOrange],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'DAY ${widget.dayCount}',
                        style: GoogleFonts.inter(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 6,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Day Streak',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.primaryOrange.withValues(alpha: 0.9),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Great work! Keep it up tomorrow.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              StreakGradientPrimaryButton(
                label: "Let's go!",
                onPressed: () {
                  HapticFeedback.lightImpact();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onDismiss();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
