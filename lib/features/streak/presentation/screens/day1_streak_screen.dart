import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/streak_celebration_background.dart';
import '../widgets/streak_gradient_buttons.dart';

/// Day 1 streak celebration: animated flame, gradients, themed CTAs.
class Day1StreakScreen extends StatefulWidget {
  final VoidCallback onLetsGo;
  final VoidCallback? onSetGoal;

  const Day1StreakScreen({
    super.key,
    required this.onLetsGo,
    this.onSetGoal,
  });

  @override
  State<Day1StreakScreen> createState() => _Day1StreakScreenState();
}

class _Day1StreakScreenState extends State<Day1StreakScreen>
    with TickerProviderStateMixin {
  late AnimationController _entry;
  late AnimationController _flamePulse;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _flameScale;
  late Animation<double> _flameRotate;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _flamePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _entry, curve: Curves.elasticOut),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entry, curve: Curves.easeOut),
    );
    _flameScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _flamePulse, curve: Curves.easeInOut),
    );
    _flameRotate = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _flamePulse, curve: Curves.easeInOut),
    );
    _entry.forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    _flamePulse.dispose();
    super.dispose();
  }

  void _safeLetsGo() {
    HapticFeedback.mediumImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onLetsGo();
    });
  }

  void _safeSetGoal() {
    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onSetGoal?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gold = AppColors.journeyGold;
    final muted = Colors.white.withValues(alpha: 0.72);

    return Scaffold(
      body: StreakCelebrationBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: Listenable.merge([_entry, _flamePulse]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacity.value,
                      child: Transform.scale(
                        scale: _scale.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                gold,
                                AppColors.primaryOrange,
                                AppColors.ashramAccentGold,
                              ],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'DAY 1',
                            style: GoogleFonts.inter(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 6,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _entry,
                  builder: (_, __) => Opacity(
                    opacity: _opacity.value,
                    child: Text(
                      'Day Streak',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: muted,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: Listenable.merge([_entry, _flamePulse]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacity.value,
                      child: Transform.rotate(
                        angle: _flameRotate.value,
                        child: Transform.scale(
                          scale: _flameScale.value * _scale.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                size: 120,
                                color: AppColors.primaryOrange
                                    .withValues(alpha: 0.35),
                              ),
                              Icon(
                                Icons.local_fire_department_rounded,
                                size: 88,
                                color: gold,
                                shadows: [
                                  Shadow(
                                    color: AppColors.primaryOrange
                                        .withValues(alpha: 0.9),
                                    blurRadius: 28,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                AnimatedBuilder(
                  animation: _entry,
                  builder: (_, __) => Opacity(
                    opacity: _opacity.value,
                    child: Text(
                      'Come back tomorrow to maintain\nyour streak!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'A little practice each day builds a lasting habit.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: muted,
                    height: 1.45,
                  ),
                ),
                const Spacer(flex: 2),
                if (widget.onSetGoal != null) ...[
                  StreakGradientOutlineButton(
                    label: 'Set your goal',
                    onPressed: _safeSetGoal,
                  ),
                  const SizedBox(height: 12),
                ],
                StreakGradientPrimaryButton(
                  label: "Let's go!",
                  onPressed: _safeLetsGo,
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _flamePulse,
                  builder: (_, __) {
                    return Transform.scale(
                      scale:
                          1 + 0.12 * math.sin(_flamePulse.value * 2 * math.pi),
                      child: const Text('🔥', style: TextStyle(fontSize: 26)),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
