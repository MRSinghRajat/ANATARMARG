import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_guide.dart';
import '../../../../shared/widgets/task_card.dart';
import '../../../../core/constants/app_constants.dart';

class OnboardingFirstTaskScreen extends StatelessWidget {
  const OnboardingFirstTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Character
          const AnimatedGuide(
            width: 570,
            height: 570,
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Your Daily Tasks',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          
          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Each day, complete three tasks by reading scripture. Help the sadhu with water, prayer, and food.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Example Task Cards
          TaskCard(
            title: AppConstants.taskNames['water']!,
            subtitle: AppConstants.taskDescriptions['water']!,
            icon: Icons.water_drop,
            coinReward: 35,
            onTap: () {
              // Preview animation
            },
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Complete tasks to earn coins and customize your home!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
