import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/localized.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/widgets/animated_guide.dart';

class OnboardingWelcomeScreen extends ConsumerWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const AnimatedGuide(
            width: 720,
            height: 720,
          ),
          const SizedBox(height: 32),
          Text(
            AppConfig.appName.toUpperCase(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            localized(ref, en: AppConfig.appTagline, hi: 'भीतर का मार्ग'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.secondaryText,
                ),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              localized(
                ref,
                en: 'Embark on a journey through ancient Indian wisdom. Learn from Mahabharata, Ramayan, and Geeta through daily reflection and guidance.',
                hi: 'प्राचीन भारतीय ज्ञान की यात्रा पर निकलें। महाभारत, रामायण और गीता से प्रतिदिन चिंतन और मार्गदर्शन पाएँ।',
              ),
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
