import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/streak_celebration_background.dart';
import '../widgets/streak_gradient_buttons.dart';

/// Re-engagement when user was away — animated heart, gradients.
class MissedYouStreakScreen extends StatefulWidget {
  final int? previousStreak;
  final Future<void> Function() onStartToday;

  const MissedYouStreakScreen({
    super.key,
    required this.onStartToday,
    this.previousStreak,
  });

  @override
  State<MissedYouStreakScreen> createState() => _MissedYouStreakScreenState();
}

class _MissedYouStreakScreenState extends State<MissedYouStreakScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _heartScale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _onStart() async {
    HapticFeedback.mediumImpact();
    await widget.onStartToday();
    if (!mounted) return;
    await Navigator.of(context, rootNavigator: true).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final muted = Colors.white.withValues(alpha: 0.75);

    return Scaffold(
      body: StreakCelebrationBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: _heartScale.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                            size: 100,
                            color: AppColors.heartRed.withValues(alpha: 0.2),
                          ),
                          Icon(
                            Icons.favorite_rounded,
                            size: 72,
                            color: AppColors.heartRed.withValues(alpha: 0.95),
                            shadows: [
                              Shadow(
                                color:
                                    AppColors.heartRed.withValues(alpha: 0.6),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'We missed you so much!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.previousStreak != null && widget.previousStreak! > 0
                      ? 'Your ${widget.previousStreak}-day streak has ended — and that\'s okay. Ready to start fresh?'
                      : 'Antar मार्ग is here whenever you are. Start today and build your practice again.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: muted,
                    height: 1.5,
                  ),
                ),
                const Spacer(flex: 2),
                StreakGradientPrimaryButton(
                  label: 'Start today',
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _onStart();
                    });
                  },
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) {
                    return Transform.rotate(
                      angle: 0.05 * math.sin(_pulse.value * 2 * math.pi),
                      child: const Text('✨', style: TextStyle(fontSize: 28)),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
