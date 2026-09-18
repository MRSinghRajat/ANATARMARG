import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/localized.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.deepAsh,
      appBar: AppBar(
        title: Text(localized(ref, en: 'About', hi: 'ऐप के बारे में')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Semantics(
              header: true,
              child: const Text(AppConfig.appDisplayName,
                  style: TextStyle(fontSize: 28, color: AppColors.matteGold)),
            ),
            const SizedBox(height: 8),
            Text(localized(ref,
                en: 'Version ${AppConfig.appVersion}',
                hi: 'संस्करण ${AppConfig.appVersion}')),
            const SizedBox(height: 24),
            Text(
                localized(ref,
                    en: 'Make space for daily spiritual practice, sacred reading and guided journeys, in Hindi or English, wherever you live.',
                    hi: 'आप जहाँ भी रहें, हिंदी या अंग्रेज़ी में दैनिक आध्यात्मिक अभ्यास, पवित्र ग्रंथों के अध्ययन और मार्गदर्शित यात्राओं के लिए समय निकालें।'),
                style: const TextStyle(fontSize: 18, height: 1.5)),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                  localized(ref, en: 'Terms of Service', hi: 'सेवा की शर्तें')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.termsOfService),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                  localized(ref, en: 'Privacy Policy', hi: 'गोपनीयता नीति')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.privacyPolicy),
            ),
          ],
        ),
      ),
    );
  }
}
