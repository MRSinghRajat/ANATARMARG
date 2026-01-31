import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_guide.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';

class OnboardingHomeTourScreen extends StatelessWidget {
  const OnboardingHomeTourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
      ),
      child: Column(
        children: [
          // Character
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AnimatedGuide(
                    width: 570,
                    height: 570,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Welcome to Your Home',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'This is your spiritual home. Complete daily tasks, read scriptures, and earn coins to customize it.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Navigation Preview
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Navigate using the bottom bar:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                BottomNavBar(
                  currentItem: NavItem.home,
                  onTap: (item) {
                    // Preview navigation
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
