import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/localized.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_guide.dart';
import '../../../../shared/widgets/task_card.dart';
import '../../../../core/constants/app_constants.dart';

class OnboardingFirstTaskScreen extends ConsumerWidget {
  const OnboardingFirstTaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AnimatedGuide(
            width: 570,
            height: 570,
          ),
          const SizedBox(height: 32),
          Text(
            localized(ref, en: 'Your Daily Tasks', hi: 'आपके दैनिक कार्य'),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              localized(
                ref,
                en: 'Each day, complete three tasks by reading scripture. Help the sadhu with water, prayer, and food.',
                hi: 'हर दिन शास्त्र पढ़कर तीन कार्य पूरे करें। साधु की जल, प्रार्थना और भोजन में मदद करें।',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          TaskCard(
            title: localized(ref, en: AppConstants.taskNames['water']!, hi: 'जल कार्य'),
            subtitle: localized(
              ref,
              en: AppConstants.taskDescriptions['water']!,
              hi: 'साधु के लिए जल जुटाने हेतु शास्त्र पढ़ें',
            ),
            icon: Icons.water_drop,
            coinReward: 35,
            onTap: () {
              // Preview animation
            },
          ),
          const SizedBox(height: 16),
          Text(
            localized(
              ref,
              en: 'Complete tasks to earn coins and customize your home!',
              hi: 'कार्य पूरे करके सिक्के कमाएँ और अपना घर सजाएँ!',
            ),
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
