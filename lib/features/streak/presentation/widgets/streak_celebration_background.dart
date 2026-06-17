import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-screen gradient + soft glow orbs aligned with Ashram / Journey theme.
class StreakCelebrationBackground extends StatelessWidget {
  final Widget child;

  const StreakCelebrationBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.ashramBackgroundDark,
            AppColors.journeyDeepPurple.withValues(alpha: 0.92),
            AppColors.deepPurple.withValues(alpha: 0.45),
            AppColors.primaryOrange.withValues(alpha: 0.18),
          ],
          stops: const [0.0, 0.32, 0.72, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -80,
            right: -60,
            child:
                _glowOrb(AppColors.primaryOrange.withValues(alpha: 0.12), 180),
          ),
          Positioned(
            bottom: 40,
            left: -40,
            child: _glowOrb(AppColors.deepPurple.withValues(alpha: 0.18), 200),
          ),
          Positioned(
            top: 120,
            left: 20,
            child: _glowOrb(AppColors.journeyGold.withValues(alpha: 0.06), 120),
          ),
          child,
        ],
      ),
    );
  }

  Widget _glowOrb(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 80,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
