import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/custom_habit_model.dart';

/// Widget for displaying a custom habit
class CustomHabitCard extends StatelessWidget {
  final CustomHabit habit;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onNavigate;
  
  /// Key for animation source position
  final GlobalKey? animationKey;

  const CustomHabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onTap,
    this.onLongPress,
    this.onNavigate,
    this.animationKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onNavigate ?? onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.2),
                    Colors.green.withOpacity(0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    AppColors.deepPurple.withOpacity(0.15),
                    AppColors.deepPurple.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? Colors.green.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox — always triggers completion toggle
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCheckbox(),
              ),
            ),
            
            // Habit icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.2)
                    : AppColors.deepPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconData(habit.iconName),
                color: isCompleted ? Colors.green : AppColors.primaryOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Habit info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: GoogleFonts.poppins(
                      color: isCompleted ? Colors.white54 : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (habit.currentStreak > 0) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 12,
                          color: Colors.orange.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak} day streak',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Streak progress or frequency (keyed for animation)
            KeyedSubtree(
              key: animationKey,
              child: habit.targetStreak != null && habit.targetStreak! > 0
                  ? _buildStreakProgress()
                  : _buildFrequencyBadge(),
            ),
            if (onNavigate != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.25),
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? Colors.green : Colors.transparent,
        border: Border.all(
          color: isCompleted
              ? Colors.green
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: isCompleted
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            )
          : null,
    );
  }

  Widget _buildStreakProgress() {
    final progress = habit.streakProgress;
    
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? Colors.green : AppColors.primaryOrange,
            ),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyBadge() {
    String label;
    switch (habit.frequency) {
      case HabitFrequency.daily:
        label = 'Daily';
        break;
      case HabitFrequency.weekly:
        label = 'Weekly';
        break;
      case HabitFrequency.specificDays:
        label = habit.scheduledDayNames.join(', ');
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white54,
          fontSize: 10,
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'water_drop':
        return Icons.water_drop;
      case 'menu_book':
        return Icons.menu_book;
      case 'favorite':
        return Icons.favorite;
      case 'accessibility_new':
        return Icons.accessibility_new;
      case 'phone_disabled':
        return Icons.phone_disabled;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'air':
        return Icons.air;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'bedtime':
        return Icons.bedtime;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.check_circle;
    }
  }
}

/// Compact tile for habit in list
class CompletedHabitTile extends StatelessWidget {
  final CustomHabit habit;
  final VoidCallback? onTap;

  const CompletedHabitTile({
    super.key,
    required this.habit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                habit.title,
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
