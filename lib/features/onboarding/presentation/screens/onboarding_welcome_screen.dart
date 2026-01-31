import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/animated_guide.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.lightGreen.withOpacity(0.3),
            AppColors.primaryBackground,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Character
          const AnimatedGuide(
            width: 720,
            height: 720,
          ),
          
          const SizedBox(height: 32),
          
          // App Name
          Text(
            AppConfig.appName.toUpperCase(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
          ),
          
          const SizedBox(height: 8),
          
          // Tagline
          Text(
            AppConfig.appTagline,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.secondaryText,
                ),
          ),
          
          const SizedBox(height: 48),
          
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Embark on a journey through ancient Indian wisdom. Learn from Mahabharata, Ramayan, and Geeta through daily reflection and guidance.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
