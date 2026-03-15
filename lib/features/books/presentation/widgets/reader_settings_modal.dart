import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

enum ReaderTheme { light, paper, dark }
enum ReaderFont {
  serif,
  sans,
  rounded,
  mono,
  slab,
  devanagari,
  merriweather,
  playfair,
  lora,
  notoSerif,
}
enum ReaderLayout { scroll, card }

class ReaderSettingsModal extends StatefulWidget {
  final double currentFontSize;
  final ReaderTheme currentTheme;
  final ReaderFont currentFont;
  final ReaderLayout currentLayout;
  final Function(double) onFontSizeChanged;
  final Function(ReaderTheme) onThemeChanged;
  final Function(ReaderFont) onFontChanged;
  final Function(ReaderLayout) onLayoutChanged;

  const ReaderSettingsModal({
    super.key,
    required this.currentFontSize,
    required this.currentTheme,
    required this.currentFont,
    this.currentLayout = ReaderLayout.scroll,
    required this.onFontSizeChanged,
    required this.onThemeChanged,
    required this.onFontChanged,
    required this.onLayoutChanged,
  });

  @override
  State<ReaderSettingsModal> createState() => _ReaderSettingsModalState();

  /// Public helper so verse/sacred text readers can apply the selected font.
  static String? getFontFamily(ReaderFont font) {
    switch (font) {
      case ReaderFont.serif:
        return GoogleFonts.crimsonPro().fontFamily;
      case ReaderFont.sans:
        return GoogleFonts.inter().fontFamily;
      case ReaderFont.rounded:
        return GoogleFonts.varelaRound().fontFamily;
      case ReaderFont.mono:
        return GoogleFonts.jetBrainsMono().fontFamily;
      case ReaderFont.slab:
        return GoogleFonts.robotoSlab().fontFamily;
      case ReaderFont.devanagari:
        return GoogleFonts.notoSerifDevanagari().fontFamily;
      case ReaderFont.merriweather:
        return GoogleFonts.merriweather().fontFamily;
      case ReaderFont.playfair:
        return GoogleFonts.playfairDisplay().fontFamily;
      case ReaderFont.lora:
        return GoogleFonts.lora().fontFamily;
      case ReaderFont.notoSerif:
        return GoogleFonts.notoSerif().fontFamily;
    }
  }
}

class _ReaderSettingsModalState extends State<ReaderSettingsModal> {
  late double _fontSize;
  late ReaderFont _font;
  late ReaderLayout _layout;

  static const Color _darkBg = Color(0xFF1E1E1E);
  static const Color _darkText = Color(0xFFE8E8E8);

  @override
  void initState() {
    super.initState();
    _fontSize = widget.currentFontSize;
    _font = widget.currentFont;
    _layout = widget.currentLayout;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _darkBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildLayoutSection(),
          const SizedBox(height: 24),
          _buildFontSizeSection(),
          const SizedBox(height: 24),
          _buildFontFamilySection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Appearance',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _darkText,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: _darkText.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildFontSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text Size',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _darkText.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('A', style: TextStyle(fontSize: 14, color: _darkText)),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.warmOrange,
                  thumbColor: AppColors.warmOrange,
                  inactiveTrackColor: AppColors.warmOrange.withOpacity(0.2),
                ),
                child: Slider(
                  value: _fontSize,
                  min: 14,
                  max: 32,
                  divisions: 9,
                  onChanged: (val) {
                    setState(() => _fontSize = val);
                    widget.onFontSizeChanged(val);
                  },
                ),
              ),
            ),
            Text('A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _darkText)),
          ],
        ),
      ],
    );
  }

  Widget _buildFontFamilySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Style',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _darkText.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFontOption(ReaderFont.serif, 'Serif'),
              _buildFontOption(ReaderFont.sans, 'Sans'),
              _buildFontOption(ReaderFont.rounded, 'Rounded'),
              _buildFontOption(ReaderFont.mono, 'Mono'),
              _buildFontOption(ReaderFont.slab, 'Slab'),
              _buildFontOption(ReaderFont.devanagari, 'Devanagari'),
              _buildFontOption(ReaderFont.merriweather, 'Merriweather'),
              _buildFontOption(ReaderFont.playfair, 'Playfair'),
              _buildFontOption(ReaderFont.lora, 'Lora'),
              _buildFontOption(ReaderFont.notoSerif, 'Noto Serif'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFontOption(ReaderFont font, String label) {
    final isSelected = _font == font;
    return GestureDetector(
      onTap: () {
        setState(() => _font = font);
        widget.onFontChanged(font);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.warmOrange : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _darkText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: _getFontFamily(font),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String? _getFontFamily(ReaderFont font) {
    return ReaderSettingsModal.getFontFamily(font);
  }

  Widget _buildLayoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading Layout',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _darkText.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildLayoutOption(ReaderLayout.scroll, 'Scroll', Icons.view_day),
            const SizedBox(width: 12),
            _buildLayoutOption(ReaderLayout.card, 'Card', Icons.view_carousel),
          ],
        ),
      ],
    );
  }

  Widget _buildLayoutOption(ReaderLayout layout, String label, IconData icon) {
    final isSelected = _layout == layout;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _layout = layout);
          widget.onLayoutChanged(layout);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.warmOrange : Colors.white.withOpacity(0.08),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: isSelected ? AppColors.warmOrange : _darkText.withOpacity(0.5)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.warmOrange : _darkText.withOpacity(0.7),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
