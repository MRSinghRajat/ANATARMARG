import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/granthalaya_models.dart';

class SacredTextReaderScreen extends StatefulWidget {
  final SacredTextModel sacredText;
  const SacredTextReaderScreen({super.key, required this.sacredText});

  @override
  State<SacredTextReaderScreen> createState() => _SacredTextReaderScreenState();
}

class _SacredTextReaderScreenState extends State<SacredTextReaderScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _decorController;
  bool _showHindi = true;
  bool _showBenefits = false;

  static const _bg1 = Color(0xFF0D0B08);
  static const _bg2 = Color(0xFF1A1510);
  static const _parchment = Color(0xFF1E1A14);
  static const _gold = Color(0xFFC5A059);
  static const _goldLight = Color(0xFFE2C999);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _decorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _decorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.sacredText;
    return Scaffold(
      backgroundColor: _bg1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bg1, _bg2, _bg1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(t),
              Expanded(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _fadeController,
                    curve: Curves.easeIn,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _decorController,
                            curve: Curves.easeInOut,
                          ),
                          child: _buildOrnament(),
                        ),
                        const SizedBox(height: 20),
                        _buildTypeAndInfo(t),
                        const SizedBox(height: 20),
                        _buildMainText(t),
                        const SizedBox(height: 24),
                        if (t.benefits != null || t.whenToRecite != null) ...[
                          _buildDivider(),
                          const SizedBox(height: 20),
                          _buildBenefitsToggle(t),
                          const SizedBox(height: 20),
                        ],
                        FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _decorController,
                            curve: Curves.easeInOut,
                          ),
                          child: _buildOrnament(),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(SacredTextModel t) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: _gold, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _goldLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (t.titleHindi != null)
                      Text(
                        t.titleHindi!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _gold.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ),
              _buildLanguageToggle(),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangButton('HI', _showHindi),
          _buildLangButton('EN', !_showHindi),
        ],
      ),
    );
  }

  Widget _buildLangButton(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _showHindi = label == 'HI'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _gold.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? _gold : Colors.white38,
          ),
        ),
      ),
    );
  }

  Widget _buildOrnament() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 24, height: 1, color: _gold.withValues(alpha: 0.2)),
        const SizedBox(width: 8),
        Text(
          '✦',
          style: TextStyle(fontSize: 10, color: _gold.withValues(alpha: 0.4)),
        ),
        const SizedBox(width: 8),
        Container(width: 24, height: 1, color: _gold.withValues(alpha: 0.2)),
      ],
    );
  }

  Widget _buildTypeAndInfo(SacredTextModel t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _infoBadge(t.typeLabel, Icons.bookmark_outline),
        if (t.verseCount != null) ...[
          const SizedBox(width: 10),
          _infoBadge('${t.verseCount} verses', Icons.format_list_numbered),
        ],
        if (t.difficulty != 'beginner') ...[
          const SizedBox(width: 10),
          _infoBadge(t.difficulty, Icons.signal_cellular_alt),
        ],
      ],
    );
  }

  Widget _infoBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _gold.withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _gold.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainText(SacredTextModel t) {
    // HI = original Hindi, EN = English transliteration (Hindi pronunciation in English alphabets)
    final text = _showHindi
        ? (t.textHindi ?? t.textEnglish ?? t.transliteration ?? '')
        : (t.textEnglish ?? t.transliteration ?? t.textHindi ?? '');

    if (text.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _parchment,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Text coming soon...',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white38,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _parchment,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _gold.withValues(alpha: 0.03),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: SelectableText(
        text,
        style: GoogleFonts.crimsonPro(
          fontSize: _showHindi ? 18 : 16,
          height: _showHindi ? 2.0 : 1.8,
          color: const Color(0xFFE8E0D4),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
            child: Container(
                height: 1, color: _gold.withValues(alpha: 0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '☸',
            style: TextStyle(
                fontSize: 14, color: _gold.withValues(alpha: 0.3)),
          ),
        ),
        Expanded(
            child: Container(
                height: 1, color: _gold.withValues(alpha: 0.1))),
      ],
    );
  }

  Widget _buildBenefitsToggle(SacredTextModel t) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showBenefits = !_showBenefits),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _gold.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: _gold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _showBenefits ? 'Hide Details' : 'Benefits & When to Recite',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _gold,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _showBenefits ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: _gold.withValues(alpha: 0.6), size: 22),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showBenefits
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _parchment,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gold.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (t.benefits != null) ...[
                    Text(
                      'Benefits',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _gold.withValues(alpha: 0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.benefits!,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 15,
                        color: _goldLight.withValues(alpha: 0.8),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (t.whenToRecite != null) ...[
                    Text(
                      'When to Recite',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _gold.withValues(alpha: 0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.whenToRecite!,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 15,
                        color: _goldLight.withValues(alpha: 0.8),
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
