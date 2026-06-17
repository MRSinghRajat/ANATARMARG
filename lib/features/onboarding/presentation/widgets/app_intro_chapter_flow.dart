import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../data/app_intro_chapter.dart';
import '../../data/app_intro_chapters.dart';
import '../../services/app_intro_prefs.dart';

/// Large-type chapter tour: optional Lottie path per chapter; falls back to pulsing icon.
class AppIntroChapterFlow extends StatefulWidget {
  const AppIntroChapterFlow({
    super.key,
    required this.hindi,
    required this.onComplete,
    this.markSeenOnComplete = true,
    this.allowSkip = true,
    this.finalPrimaryLabelEn,
    this.finalPrimaryLabelHi,
    this.backgroundColor = const Color(0xFF0B1623),
    this.gold = const Color(0xFFD4AF37),
    this.lightGold = const Color(0xFFF4E4B6),
  });

  final bool hindi;
  final VoidCallback onComplete;
  final bool markSeenOnComplete;
  final bool allowSkip;
  /// When set (e.g. Profile replay), replaces "Continue to sign in" on the last page.
  final String? finalPrimaryLabelEn;
  final String? finalPrimaryLabelHi;
  final Color backgroundColor;
  final Color gold;
  final Color lightGold;

  @override
  State<AppIntroChapterFlow> createState() => _AppIntroChapterFlowState();
}

class _AppIntroChapterFlowState extends State<AppIntroChapterFlow>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _page = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulse;

  List<AppIntroChapter> get _chapters => kAppIntroChapters;

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _pulse = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!MediaQuery.disableAnimationsOf(context)) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (widget.markSeenOnComplete) {
      await AppIntroPrefs.markIntroSeen();
    }
    if (!mounted) return;
    widget.onComplete();
  }

  void _skip() {
    _finish();
  }

  void _replayMotion() {
    if (_reduceMotion) return;
    _pulseController
      ..reset()
      ..repeat(reverse: true);
  }

  void _next() {
    if (_page >= _chapters.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: _reduceMotion ? Duration.zero : const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_page <= 0) return;
    _pageController.previousPage(
      duration: _reduceMotion ? Duration.zero : const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  String _title(AppIntroChapter c) =>
      widget.hindi ? c.titleHi : c.titleEn;

  String _body(AppIntroChapter c) =>
      widget.hindi ? c.bodyHi : c.bodyEn;

  @override
  Widget build(BuildContext context) {
    final skipLabel = widget.hindi ? 'इस भाग को छोड़ें' : 'Skip this tour';
    final nextLabel = widget.hindi ? 'आगे' : 'Next';
    final backLabel = widget.hindi ? 'पीछे' : 'Back';
    final replayLabel = widget.hindi ? 'फिर से चलाएँ' : 'Replay motion';
    final lastLabel = widget.hindi
        ? (widget.finalPrimaryLabelHi ?? 'साइन इन पर जाएँ')
        : (widget.finalPrimaryLabelEn ?? 'Continue to sign in');

    return ColoredBox(
      color: widget.backgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  if (_page > 0)
                    TextButton(
                      onPressed: _back,
                      child: Text(
                        backLabel,
                        style: GoogleFonts.tenorSans(
                          fontSize: 16,
                          color: widget.lightGold.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (widget.allowSkip)
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        skipLabel,
                        style: GoogleFonts.tenorSans(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(_chapters.length, (i) {
                  final active = i == _page;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: active
                            ? widget.gold
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _chapters.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final c = _chapters[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                _buildVisual(c),
                                const SizedBox(height: 32),
                                Text(
                                  _title(c),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: widget.lightGold,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _body(c),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.tenorSans(
                                    fontSize: 19,
                                    height: 1.55,
                                    color: Colors.white.withValues(alpha: 0.82),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!_reduceMotion)
                          TextButton.icon(
                            onPressed: _replayMotion,
                            icon: Icon(
                              Icons.replay_rounded,
                              color: widget.gold.withValues(alpha: 0.8),
                              size: 22,
                            ),
                            label: Text(
                              replayLabel,
                              style: GoogleFonts.tenorSans(
                                fontSize: 15,
                                color: widget.gold.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: widget.gold,
                              foregroundColor: const Color(0xFF0B1623),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _next,
                            child: Text(
                              _page >= _chapters.length - 1 ? lastLabel : nextLabel,
                              style: GoogleFonts.tenorSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisual(AppIntroChapter c) {
    final path = c.lottieAsset;
    if (path != null && path.isNotEmpty) {
      return SizedBox(
        height: 200,
        child: Lottie.asset(
          path,
          repeat: !_reduceMotion,
          animate: !_reduceMotion,
          errorBuilder: (_, __, ___) => _buildPulsingIcon(c.icon),
        ),
      );
    }

    return _buildPulsingIcon(c.icon);
  }

  Widget _buildPulsingIcon(IconData icon) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        final scale = _reduceMotion ? 1.0 : _pulse.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.gold.withValues(alpha: 0.12),
              border: Border.all(
                color: widget.gold.withValues(alpha: 0.35),
                width: 2,
              ),
              boxShadow: _reduceMotion
                  ? null
                  : [
                      BoxShadow(
                        color: widget.gold.withValues(alpha: 0.2 * scale),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
            ),
            child: Icon(
              icon,
              size: 64,
              color: widget.gold,
            ),
          ),
        );
      },
    );
  }
}
