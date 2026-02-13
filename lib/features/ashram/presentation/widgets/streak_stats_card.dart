import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/user_spiritual_progress_model.dart';

/// Widget displaying streak and progress statistics
class StreakStatsCard extends StatelessWidget {
  final UserSpiritualProgress? progress;
  final VoidCallback? onTap;

  const StreakStatsCard({
    super.key,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryOrange.withOpacity(0.2),
              AppColors.deepPurple.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Main streak display
            Row(
              children: [
                // Streak flame
                _buildStreakFlame(),
                const SizedBox(width: 16),
                
                // Streak info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${progress?.currentStreak ?? 0} Day Streak',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStreakMessage(),
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Level badge
                _buildLevelBadge(),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stats row
            Row(
              children: [
                _buildStatItem(
                  icon: Icons.check_circle_outline,
                  value: '${progress?.totalTasksCompleted ?? 0}',
                  label: 'Tasks',
                  color: Colors.green,
                ),
                _buildStatDivider(),
                _buildStatItem(
                  icon: Icons.menu_book_outlined,
                  value: '${progress?.totalVersesRead ?? 0}',
                  label: 'Verses',
                  color: Colors.blue,
                ),
                _buildStatDivider(),
                _buildStatItem(
                  icon: Icons.self_improvement,
                  value: _formatMinutes(progress?.totalMeditationMinutes ?? 0),
                  label: 'Meditation',
                  color: Colors.purple,
                ),
                _buildStatDivider(),
                _buildStatItem(
                  icon: Icons.volunteer_activism,
                  value: '${progress?.totalSevaActs ?? 0}',
                  label: 'Seva',
                  color: Colors.orange,
                ),
              ],
            ),
            
            // XP Progress bar
            if (progress != null) ...[
              const SizedBox(height: 16),
              _buildXpProgressBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakFlame() {
    final streak = progress?.currentStreak ?? 0;
    final isActive = progress?.isStreakActive ?? false;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                (isActive ? Colors.orange : Colors.grey).withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Flame icon
        Icon(
          Icons.local_fire_department,
          size: 40,
          color: isActive
              ? _getStreakColor(streak)
              : Colors.grey.withOpacity(0.5),
        ),
      ],
    );
  }

  Color _getStreakColor(int streak) {
    if (streak >= 365) return Colors.purpleAccent;
    if (streak >= 108) return Colors.deepPurple;
    if (streak >= 40) return Colors.red;
    if (streak >= 21) return Colors.deepOrange;
    if (streak >= 7) return Colors.orange;
    return Colors.orangeAccent;
  }

  String _getStreakMessage() {
    final streak = progress?.currentStreak ?? 0;
    final isActive = progress?.isStreakActive ?? false;
    
    if (!isActive) {
      return 'Start your journey today!';
    }
    
    if (streak >= 365) return 'Incredible! A year of dedication!';
    if (streak >= 108) return 'Sacred 108 achieved! You are a Sadhak!';
    if (streak >= 40) return '40-day Tapas complete! Keep going!';
    if (streak >= 21) return 'Habit formed! 21 days strong!';
    if (streak >= 7) return 'One week strong! Great progress!';
    if (streak >= 3) return 'Building momentum! Stay consistent!';
    if (streak == 1) return 'Great start! Come back tomorrow!';
    return 'Keep the flame alive!';
  }

  Widget _buildLevelBadge() {
    final level = progress?.spiritualLevel ?? 1;
    final title = progress?.spiritualTitle ?? 'Beginner';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getLevelColor(level).withOpacity(0.3),
            _getLevelColor(level).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getLevelColor(level).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Lv.$level',
            style: GoogleFonts.poppins(
              color: _getLevelColor(level),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 50) return Colors.purpleAccent;
    if (level >= 25) return Colors.amber;
    if (level >= 10) return Colors.lightBlue;
    return Colors.green;
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '${hours}h${mins}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  Widget _buildXpProgressBar() {
    final level = progress?.spiritualLevel ?? 1;
    final progressPercent = progress?.levelProgress ?? 0.0;
    final xpNeeded = progress?.xpForNextLevel ?? 100;
    final currentXp = ((progress?.experiencePoints ?? 0) % xpNeeded);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level ${level + 1} Progress',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              '$currentXp / $xpNeeded XP',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressPercent,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getLevelColor(level),
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
