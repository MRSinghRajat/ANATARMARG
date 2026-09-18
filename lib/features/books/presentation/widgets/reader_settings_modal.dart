import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/localized.dart';
import '../../../../core/theme/app_colors.dart';

enum ReaderTheme { light, paper, dark }

enum ReaderFont {
  /// Crimson Pro — long-form reading
  serif,

  /// Inter — clean UI-style body text
  sans,

  /// Noto Serif Devanagari — Hindi / Devanagari verses
  devanagari,
}

enum ReaderLayout { scroll, card }

class ReaderSettingsModal extends ConsumerStatefulWidget {
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
    this.currentLayout = ReaderLayout.card,
    required this.onFontSizeChanged,
    required this.onThemeChanged,
    required this.onFontChanged,
    required this.onLayoutChanged,
  });

  @override
  ConsumerState<ReaderSettingsModal> createState() =>
      _ReaderSettingsModalState();

  /// Public helper so verse/sacred text readers can apply the selected font.
  static String? getFontFamily(ReaderFont font) {
    switch (font) {
      case ReaderFont.serif:
        return GoogleFonts.crimsonPro().fontFamily;
      case ReaderFont.sans:
        return GoogleFonts.inter().fontFamily;
      case ReaderFont.devanagari:
        return GoogleFonts.notoSerifDevanagari().fontFamily;
    }
  }
}

class _ReaderSettingsModalState extends ConsumerState<ReaderSettingsModal> {
  late double _fontSize;
  late ReaderFont _font;
  late ReaderLayout _layout;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.currentFontSize.isFinite
        ? widget.currentFontSize.clamp(14.0, 32.0)
        : 18.0;
    _font = widget.currentFont;
    _layout = widget.currentLayout;
  }

  String _label(String en, String hi) => localized(ref, en: en, hi: hi);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(_label('Appearance', 'पढ़ने की सेटिंग'),
                        style: const TextStyle(
                            fontSize: 20, color: Colors.white))),
                IconButton(
                  tooltip: _label('Close settings', 'सेटिंग बंद करें'),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ]),
              const SizedBox(height: 16),
              _heading(_label('Reading layout', 'पढ़ने का तरीका')),
              Wrap(spacing: 12, runSpacing: 8, children: [
                for (final layout in ReaderLayout.values)
                  ChoiceChip(
                    label: Text(layout == ReaderLayout.scroll
                        ? _label('Scroll', 'स्क्रॉल')
                        : _label('Card', 'कार्ड')),
                    selected: _layout == layout,
                    onSelected: (_) {
                      setState(() => _layout = layout);
                      widget.onLayoutChanged(layout);
                    },
                  ),
              ]),
              const SizedBox(height: 24),
              _heading(_label('Text size', 'अक्षर का आकार')),
              Semantics(
                label: _label('Text size', 'अक्षर का आकार'),
                child: Slider(
                  value: _fontSize,
                  min: 14,
                  max: 32,
                  divisions: 9,
                  activeColor: AppColors.warmOrange,
                  label: _fontSize.round().toString(),
                  semanticFormatterCallback: (value) =>
                      value.round().toString(),
                  onChanged: (value) {
                    setState(() => _fontSize = value);
                    widget.onFontSizeChanged(value);
                  },
                ),
              ),
              const SizedBox(height: 24),
              _heading(_label('Font style', 'अक्षर की शैली')),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final font in ReaderFont.values)
                  ChoiceChip(
                    label: Text(switch (font) {
                      ReaderFont.serif => _label('Serif', 'सेरिफ़'),
                      ReaderFont.sans => _label('Sans', 'सैन्स'),
                      ReaderFont.devanagari => _label('Devanagari', 'देवनागरी'),
                    }),
                    selected: _font == font,
                    onSelected: (_) {
                      setState(() => _font = font);
                      widget.onFontChanged(font);
                    },
                  ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Semantics(
            header: true,
            child: Text(title,
                style: const TextStyle(fontSize: 16, color: Colors.white))),
      );
}
