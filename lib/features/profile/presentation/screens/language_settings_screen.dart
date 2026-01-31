import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/language_provider.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);

    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'hi', 'name': 'Hindi (हिंदी)'},
      {'code': 'sa', 'name': 'Sanskrit (संस्कृतम्)'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
        backgroundColor: AppColors.primaryBackground,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: languages.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final language = languages[index];
            final code = language['code']!;
            final name = language['name']!;
            final isSelected = currentLanguage == code;

            return ListTile(
              title: Text(name),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppColors.warmOrange)
                  : null,
              onTap: () {
                ref.read(languageProvider.notifier).setLanguage(code);
              },
            );
          },
        ),
      ),
    );
  }
}
