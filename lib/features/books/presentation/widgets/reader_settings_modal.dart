import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum ReaderTheme { light, paper, dark }
enum ReaderFont { serif, sans, rounded }

class ReaderSettingsModal extends StatefulWidget {
  final double currentFontSize;
  final ReaderTheme currentTheme;
  final ReaderFont currentFont;
  final Function(double) onFontSizeChanged;
  final Function(ReaderTheme) onThemeChanged;
  final Function(ReaderFont) onFontChanged;

  const ReaderSettingsModal({
    super.key,
    required this.currentFontSize,
    required this.currentTheme,
    required this.currentFont,
    required this.onFontSizeChanged,
    required this.onThemeChanged,
    required this.onFontChanged,
  });

  @override
  State<ReaderSettingsModal> createState() => _ReaderSettingsModalState();
}

class _ReaderSettingsModalState extends State<ReaderSettingsModal> {
  late double _fontSize;
  late ReaderTheme _theme;
  late ReaderFont _font;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.currentFontSize;
    _theme = widget.currentTheme;
    _font = widget.currentFont;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getModalBackgroundColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildThemeSection(),
          const SizedBox(height: 24),
          _buildFontSizeSection(),
          const SizedBox(height: 24),
          _buildFontFamilySection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Color _getModalBackgroundColor() {
    switch (_theme) {
      case ReaderTheme.dark:
        return const Color(0xFF1E1E1E);
      default:
        return Colors.white;
    }
  }

  Color _getTextColor() {
    return _theme == ReaderTheme.dark ? Colors.white : AppColors.primaryText;
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
            color: _getTextColor(),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: _getTextColor().withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildThemeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildThemeOption(ReaderTheme.light, Colors.white, 'Light'),
        _buildThemeOption(ReaderTheme.paper, const Color(0xFFF9F7F2), 'Paper'), // Warm/Sepia
        _buildThemeOption(ReaderTheme.dark, const Color(0xFF121212), 'Dark'),
      ],
    );
  }

  Widget _buildThemeOption(ReaderTheme theme, Color color, String label) {
    // Use local state _theme
    final isSelected = _theme == theme;
    return GestureDetector(
      onTap: () {
        setState(() => _theme = theme); // Immediate UI update
        widget.onThemeChanged(theme);
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.warmOrange : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: AppColors.warmOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: AppColors.warmOrange)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.warmOrange : _getTextColor().withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
            color: _getTextColor().withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('A', style: TextStyle(fontSize: 14, color: _getTextColor())),
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
                  divisions: 9, // 14, 16, 18, 20...
                  onChanged: (val) {
                    setState(() => _fontSize = val); // Immediate UI update
                    widget.onFontSizeChanged(val);
                  },
                ),
              ),
            ),
            Text('A', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _getTextColor())),
          ],
        ),
      ],
    );
  }

  Widget _buildFontFamilySection() {
    return Container(
      decoration: BoxDecoration(
        color: _theme == ReaderTheme.dark // Use local state
            ? Colors.white.withOpacity(0.05) 
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildFontOption(ReaderFont.serif, 'Serif'),
          _buildFontOption(ReaderFont.sans, 'Sans'),
          _buildFontOption(ReaderFont.rounded, 'Round'),
        ],
      ),
    );
  }

  Widget _buildFontOption(ReaderFont font, String label) {
    final isSelected = _font == font;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _font = font);
          widget.onFontChanged(font);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? (_theme == ReaderTheme.dark ? Colors.white.withOpacity(0.15) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected && _theme != ReaderTheme.dark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: _getTextColor(),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontFamily: _getFontFamily(font),
            ),
          ),
        ),
      ),
    );
  }

  String? _getFontFamily(ReaderFont font) {
    switch (font) {
      case ReaderFont.serif:
        return 'Serif'; // Ensure this uses system serif or specific font if added
      case ReaderFont.sans:
        return null; // Default system sans
      case ReaderFont.rounded:
        return 'VarelaRound'; // If available, otherwise maybe just sans
    }
  }
}
