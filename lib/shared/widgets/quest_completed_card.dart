import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class QuestCompletedCard extends StatelessWidget {
  final int bonusCoins;

  const QuestCompletedCard({
    super.key,
    required this.bonusCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.warmOrange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Treasure Chest Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.warmOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 32,
                color: AppColors.warmOrange,
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quest Completed!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All tasks completed • Bonus earned',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            // Coin Reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.coinGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+$bonusCoins',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.coinGreen,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.diamond,
                    size: 20,
                    color: AppColors.coinGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
