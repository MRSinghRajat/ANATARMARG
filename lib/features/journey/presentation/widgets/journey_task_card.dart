import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/journey_models.dart';
import '../../../../core/theme/app_colors.dart';

class JourneyTaskCard extends StatelessWidget {
  final JourneyTask task;
  final bool isCompleted;
  final VoidCallback? onTap;

  const JourneyTaskCard({
    super.key,
    required this.task,
    required this.isCompleted,
    this.onTap,
  });

  static const Color _text = Color(0xFFF5F0E8);
  static const Color _textMuted = Color(0xFFB8B2A8);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.ashramCardDark.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isCompleted
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                      : AppColors.primaryOrange.withValues(alpha: 0.15),
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                        : AppColors.primaryOrange.withValues(alpha: 0.35),
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, color: Color(0xFF81C784), size: 24)
                      : Text(task.icon ?? '📿', style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _text,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: _textMuted,
                      ),
                    ),
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _textMuted,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (task.coinReward > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${task.coinReward}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                )
              else if (isCompleted)
                Icon(Icons.chevron_right_rounded, color: _textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
