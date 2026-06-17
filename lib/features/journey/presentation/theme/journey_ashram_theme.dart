import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Journey UI aligned with [AshramScreen]: dark surfaces, orange–purple glass
/// cards, and [AppColors.primaryOrange] as the primary accent.
abstract final class JourneyAshramTheme {
  static Color get accent => AppColors.primaryOrange;

  /// Same gradient + border as Ashram streak / section cards.
  static BoxDecoration streakCardDecoration({double borderRadius = 16}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryOrange.withValues(alpha: 0.2),
          AppColors.deepPurple.withValues(alpha: 0.2),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
    );
  }

  static BoxDecoration darkCardDecoration({double borderRadius = 16}) {
    return BoxDecoration(
      color: AppColors.ashramCardDark.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.08),
        width: 1,
      ),
    );
  }

  /// Lighter streak for empty / placeholder panels.
  static BoxDecoration softStreakDecoration({double borderRadius = 16}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryOrange.withValues(alpha: 0.1),
          AppColors.deepPurple.withValues(alpha: 0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.08),
        width: 1,
      ),
    );
  }
}
