import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/localized.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_guide.dart';

class OnboardingCharacterIntroScreen extends ConsumerWidget {
  const OnboardingCharacterIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RoomPainter(),
                    ),
                  ),
                  const Center(
                    child: AnimatedGuide(
                      width: 570,
                      height: 570,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              localized(ref, en: 'Meet Your Guide', hi: 'अपने मार्गदर्शक से मिलें'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    localized(
                      ref,
                      en: 'This wise old sadhu will be your companion on this spiritual journey.',
                      hi: 'यह ज्ञानी साधु इस आध्यात्मिक यात्रा में आपके साथी होंगे।',
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localized(
                      ref,
                      en: 'Each day, help the sadhu by completing three tasks:\n• Water\n• Prayer\n• Food',
                      hi: 'हर दिन तीन कार्य पूरे करके साधु की मदद करें:\n• जल\n• प्रार्थना\n• भोजन',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localized(
                      ref,
                      en: 'Complete these tasks by reading sacred texts, and earn coins to customize your home.',
                      hi: 'पवित्र ग्रंथ पढ़कर ये कार्य पूरे करें, और सिक्के कमाकर अपना घर सजाएँ।',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
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

class _RoomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.earthBrown.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw wooden planks
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
