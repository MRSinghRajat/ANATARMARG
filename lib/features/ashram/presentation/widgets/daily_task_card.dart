import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/daily_task_model.dart';

/// Widget for displaying a single daily task
class DailyTaskCard extends StatelessWidget {
  final UserDailyTask task;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onNavigate;
  final bool showCategory;
  
  /// Key for the rewards section - used for flying coin animation
  final GlobalKey? rewardsKey;

  const DailyTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onLongPress,
    this.onNavigate,
    this.showCategory = true,
    this.rewardsKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onNavigate ?? onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: task.isCompleted
              ? LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.2),
                    Colors.green.withOpacity(0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    _getCategoryColor(task.category).withOpacity(0.15),
                    _getCategoryColor(task.category).withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted
                ? Colors.green.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox - tapping this toggles completion
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCheckbox(),
              ),
            ),
            
            // Task info - tapping this navigates
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip (optional)
                  if (showCategory) ...[
                    _buildCategoryChip(),
                    const SizedBox(height: 4),
                  ],
                  
                  // Title
                  Text(
                    task.title,
                    style: GoogleFonts.poppins(
                      color: task.isCompleted
                          ? Colors.white54
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  
                  // Description
                  if (task.description != null && !task.isCompleted) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.description!,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Navigate arrow for tasks with screens
            if (onNavigate != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.4),
                size: 20,
              ),
            ],
            
            // Rewards
            KeyedSubtree(
              key: rewardsKey,
              child: _buildRewards(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: task.isCompleted
            ? Colors.green
            : Colors.transparent,
        border: Border.all(
          color: task.isCompleted
              ? Colors.green
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: task.isCompleted
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            )
          : null,
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getCategoryColor(task.category).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(task.category),
            size: 12,
            color: _getCategoryColor(task.category),
          ),
          const SizedBox(width: 4),
          Text(
            TaskCategory.fromString(task.category).displayName,
            style: GoogleFonts.poppins(
              color: _getCategoryColor(task.category),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewards() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? Colors.green.withOpacity(0.2)
            : Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            task.isCompleted ? Icons.check : Icons.monetization_on,
            size: 14,
            color: task.isCompleted ? Colors.green : Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            task.isCompleted ? 'Done' : '+${task.coinReward}',
            style: GoogleFonts.poppins(
              color: task.isCompleted ? Colors.green : Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'scripture':
        return AppColors.primaryOrange;
      case 'meditation':
        return Colors.purple;
      case 'seva':
        return Colors.pink;
      case 'lifestyle':
        return Colors.teal;
      case 'devotion':
        return Colors.amber;
      case 'learning':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'scripture':
        return Icons.menu_book;
      case 'meditation':
        return Icons.self_improvement;
      case 'seva':
        return Icons.volunteer_activism;
      case 'lifestyle':
        return Icons.eco;
      case 'devotion':
        return Icons.temple_hindu;
      case 'learning':
        return Icons.school;
      default:
        return Icons.check_circle;
    }
  }
}

/// Compact version for completed tasks section
class CompletedTaskTile extends StatelessWidget {
  final UserDailyTask task;
  final VoidCallback? onTap;

  const CompletedTaskTile({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                task.title,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '+${task.coinsEarned}',
              style: GoogleFonts.poppins(
                color: Colors.amber,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
