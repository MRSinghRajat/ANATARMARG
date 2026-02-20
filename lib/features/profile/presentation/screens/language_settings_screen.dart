import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../providers/language_provider.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);

    final languages = [
      {'code': 'en', 'name': 'Hinglish', 'subtitle': 'Hindi in English alphabet', 'example': 'Namaste! Aapki yatra shuru ho rahi hai'},
      {'code': 'hi', 'name': 'हिन्दी (देवनागरी)', 'subtitle': 'Full Hindi in Devanagari script', 'example': 'नमस्ते! आपकी यात्रा शुरू हो रही है'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        title: Text(
          AppStrings.get('language_settings', currentLanguage),
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0B1623),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: languages.map((language) {
              final code = language['code']!;
              final name = language['name']!;
              final subtitle = language['subtitle']!;
              final example = language['example']!;
              final isSelected = currentLanguage == code;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => ref.read(languageProvider.notifier).setLanguage(code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.ashramSaffron.withOpacity(0.12)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.ashramSaffron.withOpacity(0.5)
                            : Colors.white.withOpacity(0.08),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: GoogleFonts.poppins(
                                color: isSelected ? AppColors.ashramSaffron : Colors.white,
                                fontSize: 16, fontWeight: FontWeight.w600,
                              )),
                              const SizedBox(height: 2),
                              Text(subtitle, style: GoogleFonts.poppins(
                                color: Colors.white54, fontSize: 12,
                              )),
                              const SizedBox(height: 8),
                              Text('"$example"', style: GoogleFonts.poppins(
                                color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic,
                              )),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.ashramSaffron, size: 24),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
