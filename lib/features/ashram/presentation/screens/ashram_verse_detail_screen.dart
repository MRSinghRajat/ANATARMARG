import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/ashram_daily_verse_model.dart';
import '../../data/repositories/ashram_daily_verse_repository.dart';

class AshramVerseDetailScreen extends StatefulWidget {
  final AshramDailyVerseModel verse;

  const AshramVerseDetailScreen({
    super.key,
    required this.verse,
  });

  @override
  State<AshramVerseDetailScreen> createState() =>
      _AshramVerseDetailScreenState();
}

class _AshramVerseDetailScreenState extends State<AshramVerseDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _decorController;
  late Animation<double> _textFade;
  late Animation<double> _decorFade;

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
    );
    _decorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _textFade = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _decorFade = CurvedAnimation(
      parent: _decorController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _decorController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _decorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _textFade,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        FadeTransition(
                          opacity: _decorFade,
                          child: _buildOrnament(),
                        ),
                        const SizedBox(height: 24),
                        _buildVerseReference(),
                        const SizedBox(height: 20),
                        _buildSanskritSection(),
                        const SizedBox(height: 20),
                        _buildTranslationSection(),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        _buildWisdomSection(),
                        const SizedBox(height: 32),
                        FadeTransition(
                          opacity: _decorFade,
                          child: _buildOrnament(),
                        ),
                        const SizedBox(height: 60),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: _gold, size: 20),
                onPressed: () async {
                  await AshramDailyVerseRepository().markViewed();
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Verse',
                      style: GoogleFonts.crimsonPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _goldLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.verse.bookName,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _gold.withValues(alpha: 0.5),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _gold.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_stories,
                        color: _gold.withValues(alpha: 0.7), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Wisdom',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _gold.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildOrnament() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 24,
            height: 1,
            color: _gold.withValues(alpha: 0.2)),
        const SizedBox(width: 8),
        Text(
          '✦',
          style:
              TextStyle(fontSize: 10, color: _gold.withValues(alpha: 0.4)),
        ),
        const SizedBox(width: 8),
        Container(
            width: 24,
            height: 1,
            color: _gold.withValues(alpha: 0.2)),
      ],
    );
  }

  Widget _buildVerseReference() {
    final parts = <String>[];
    if (widget.verse.chapterName != null &&
        widget.verse.chapterName!.isNotEmpty) {
      parts.add(widget.verse.chapterName!);
    }
    if (widget.verse.verseNumber != null &&
        widget.verse.verseNumber!.isNotEmpty) {
      parts.add(widget.verse.verseNumber!);
    }
    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _gold.withValues(alpha: 0.15)),
        ),
      ),
      child: Text(
        parts.join(' • '),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _gold.withValues(alpha: 0.5),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSanskritSection() {
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.format_quote,
                  color: _gold.withValues(alpha: 0.3), size: 16),
              const SizedBox(width: 6),
              Text(
                'Sanskrit',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _gold.withValues(alpha: 0.4),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.verse.sanskritText,
            style: GoogleFonts.crimsonPro(
              fontSize: 19,
              height: 1.9,
              color: const Color(0xFFE8E0D4),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _parchment,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate,
                  color: _gold.withValues(alpha: 0.4), size: 14),
              const SizedBox(width: 6),
              Text(
                'Translation',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _gold.withValues(alpha: 0.4),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.verse.hindiOrEnglishText,
            style: GoogleFonts.crimsonPro(
              fontSize: 17,
              height: 1.8,
              color: const Color(0xFFE8E0D4).withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
            child: Container(
                height: 1,
                color: _gold.withValues(alpha: 0.1))),
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
                height: 1,
                color: _gold.withValues(alpha: 0.1))),
      ],
    );
  }

  Widget _buildWisdomSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: _gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Daily Life Wisdom',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _gold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.verse.dailyLifeImpact,
            style: GoogleFonts.crimsonPro(
              fontSize: 16,
              height: 1.7,
              color: _goldLight.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
