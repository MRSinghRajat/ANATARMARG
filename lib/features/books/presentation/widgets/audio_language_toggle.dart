import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

enum AudioLanguage { hindi, english }

class AudioLanguageToggle extends StatelessWidget {
  final AudioLanguage selected;
  final ValueChanged<AudioLanguage> onChanged;

  const AudioLanguageToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.matteGold.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(AudioLanguage.hindi, 'HI'),
          _buildSegment(AudioLanguage.english, 'EN'),
        ],
      ),
    );
  }

  Widget _buildSegment(AudioLanguage lang, String label) {
    final isActive = selected == lang;
    return GestureDetector(
      onTap: () => onChanged(lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.matteGold : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.black : AppColors.matteGold.withValues(alpha: 0.6),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
