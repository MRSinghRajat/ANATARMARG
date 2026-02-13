import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/verse_model.dart';

/// Obsidian Gold full-screen daily verse: category, Devanagari, translation,
/// and Daily Insight / Sacred Action from AI. Shown when user taps the daily verse card.
class VerseFullScreen extends StatelessWidget {
  final VerseContent verse;
  final int? likeCount;
  final int? shareCount;
  final VoidCallback? onLike;
  final VoidCallback? onShare;

  const VerseFullScreen({
    super.key,
    required this.verse,
    this.likeCount,
    this.shareCount,
    this.onLike,
    this.onShare,
  });

  static const Color _obsidianBg = Color(0xFF0B1013);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _cream = Color(0xFFF5F5DC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _obsidianBg,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.5, 0),
              radius: 1.2,
              colors: [
                Color(0x14D4AF37),
                _obsidianBg,
              ],
              stops: [0.0, 0.7],
            ),
          ),
          child: Column(
            children: [
              _buildTopBar(context),
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      _buildCategoryTag(),
                      const SizedBox(height: 24),
                      _buildVerseBlock(context),
                      const SizedBox(height: 24),
                      _buildSeparator(),
                      const SizedBox(height: 16),
                      _buildTranslation(context),
                      const SizedBox(height: 32),
                      _buildInsightCard(context),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatTime(DateTime.now()),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _cream,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.signal_cellular_alt, size: 18, color: _cream.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Icon(Icons.wifi, size: 18, color: _cream.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Transform.rotate(
                angle: -1.5708,
                child: Icon(Icons.battery_full, size: 18, color: _cream.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.volume_up_rounded, color: _gold, size: 22),
              ),
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.close_rounded, color: _cream, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTag() {
    final category = verse.book.isEmpty ? 'Verse of the Day' : verse.book.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.5)),
      ),
      child: Text(
        category,
        style: GoogleFonts.cinzel(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: _gold,
        ),
      ),
    );
  }

  Widget _buildVerseBlock(BuildContext context) {
    final devanagari = verse.devanagariText;
    if (devanagari != null && devanagari.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            devanagari,
            style: GoogleFonts.notoSerifDevanagari(
              fontSize: 26,
              height: 1.5,
              color: _cream,
              shadows: [
                Shadow(
                  color: _cream.withValues(alpha: 0.3),
                  blurRadius: 15,
                ),
              ],
            ),
          ),
          if (verse.title.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              verse.title,
              style: GoogleFonts.cinzel(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: _gold.withValues(alpha: 0.85),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          verse.content,
          style: GoogleFonts.inter(
            fontSize: 22,
            height: 1.5,
            color: _cream,
            fontWeight: FontWeight.w300,
            shadows: [
              Shadow(
                color: _cream.withValues(alpha: 0.25),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        if (verse.title.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            verse.title,
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: _gold.withValues(alpha: 0.85),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: 48,
      height: 1,
      color: _gold.withValues(alpha: 0.3),
    );
  }

  Widget _buildTranslation(BuildContext context) {
    if (verse.devanagariText != null && verse.devanagariText!.isNotEmpty) {
      return Text(
        verse.content,
        style: GoogleFonts.inter(
          fontSize: 20,
          height: 1.4,
          color: _cream.withValues(alpha: 0.9),
          fontWeight: FontWeight.w300,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInsightCard(BuildContext context) {
    final insight = verse.dailyInsight ??
        'Reflect on this verse today. Let it guide a small act of kindness or mindfulness.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _gold.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.filter_vintage_rounded, color: _gold, size: 20),
              const SizedBox(width: 8),
              Text(
                'SACRED ACTION',
                style: GoogleFonts.cinzel(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: _gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.5,
              color: _cream.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          Text(
            'Breathe in wisdom, breathe out peace.',
            style: GoogleFonts.cinzel(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              letterSpacing: 2,
              color: _cream.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 32),
          const _DragHandleBar(),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour;
    final m = t.minute;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

class _DragHandleBar extends StatelessWidget {
  const _DragHandleBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
