import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/daily_story_model.dart';

class StoryReaderScreen extends StatefulWidget {
  final DailyStoryModel story;

  const StoryReaderScreen({super.key, required this.story});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _decorController;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _decorFadeAnimation;

  int _currentPage = 0;
  bool _showHindi = false;

  static const _bg1 = Color(0xFF0D0B08);
  static const _bg2 = Color(0xFF1A1510);
  static const _parchment = Color(0xFF1E1A14);
  static const _gold = Color(0xFFC5A059);
  static const _goldLight = Color(0xFFE2C999);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _decorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textFadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _decorFadeAnimation = CurvedAnimation(
      parent: _decorController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _decorController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _decorController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= widget.story.pages.length) return;
    _fadeController.reset();
    _decorController.reset();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
    setState(() => _currentPage = index);
    _fadeController.forward();
    _decorController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.story.pages;
    final progress = pages.isEmpty ? 0.0 : (_currentPage + 1) / pages.length;

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
              _buildHeader(progress),
              Expanded(
                child: pages.isEmpty
                    ? _buildEmptyState()
                    : PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pages.length,
                        onPageChanged: (i) {
                          setState(() => _currentPage = i);
                          _fadeController.reset();
                          _decorController.reset();
                          _fadeController.forward();
                          _decorController.forward();
                        },
                        itemBuilder: (_, i) => _buildStoryPage(pages[i], i),
                      ),
              ),
              _buildBottomNav(pages.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: _gold, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.story.storyTitle,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _goldLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.story.category[0].toUpperCase()}${widget.story.category.substring(1)} • ${widget.story.estimatedMinutes} min',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _gold.withOpacity(0.5),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLanguageToggle(),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(
                _gold.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangButton('EN', !_showHindi),
          _buildLangButton('HI', _showHindi),
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
          color: active ? _gold.withOpacity(0.15) : Colors.transparent,
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

  Widget _buildStoryPage(StoryPage page, int index) {
    final text = _showHindi ? page.textHindi : page.textEnglish;
    final isFinal = page.isFinal || index == widget.story.pages.length - 1;

    return FadeTransition(
      opacity: _textFadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _decorFadeAnimation,
              child: _buildOrnament(),
            ),
            const SizedBox(height: 20),
            if (page.illustrationUrl != null && page.illustrationUrl!.isNotEmpty)
              _buildIllustration(page.illustrationUrl!),
            _buildPageNumber(index),
            const SizedBox(height: 16),
            _buildParchmentText(text),
            const SizedBox(height: 24),
            if (isFinal) ...[
              _buildDivider(),
              const SizedBox(height: 20),
              if (widget.story.keyTeaching != null)
                _buildKeyTeaching(),
              const SizedBox(height: 16),
              if (widget.story.reflectionPrompt != null)
                _buildReflection(),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnament() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 24, height: 1, color: _gold.withOpacity(0.2)),
        const SizedBox(width: 8),
        Text(
          '✦',
          style: TextStyle(fontSize: 10, color: _gold.withOpacity(0.4)),
        ),
        const SizedBox(width: 8),
        Container(width: 24, height: 1, color: _gold.withOpacity(0.2)),
      ],
    );
  }

  Widget _buildPageNumber(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _gold.withOpacity(0.15)),
        ),
      ),
      child: Text(
        'Page ${index + 1} of ${widget.story.pages.length}',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _gold.withOpacity(0.4),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildIllustration(String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: url,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildParchmentText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _parchment,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _gold.withOpacity(0.03),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.crimsonPro(
          fontSize: _showHindi ? 19 : 18,
          height: 1.9,
          color: const Color(0xFFE8E0D4),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: _gold.withOpacity(0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '☸',
            style: TextStyle(fontSize: 14, color: _gold.withOpacity(0.3)),
          ),
        ),
        Expanded(child: Container(height: 1, color: _gold.withOpacity(0.1))),
      ],
    );
  }

  Widget _buildKeyTeaching() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: _gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Key Teaching',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _gold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.story.keyTeaching ?? '',
            style: GoogleFonts.crimsonPro(
              fontSize: 16,
              height: 1.7,
              color: _goldLight.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: _gold.withOpacity(0.3), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reflect',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _gold.withOpacity(0.6),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.story.reflectionPrompt ?? '',
            style: GoogleFonts.crimsonPro(
              fontSize: 16,
              height: 1.7,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No pages in this story.',
        style: GoogleFonts.inter(color: Colors.white38),
      ),
    );
  }

  Widget _buildBottomNav(int totalPages) {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage >= totalPages - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: _bg1.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: _gold.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildNavButton(
              icon: Icons.chevron_left,
              label: 'Previous',
              enabled: !isFirst,
              onTap: () => _goToPage(_currentPage - 1),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentPage + 1} / $totalPages',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _gold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildNavButton(
              icon: Icons.chevron_right,
              label: isLast ? 'Done' : 'Next',
              enabled: true,
              isForward: true,
              onTap: isLast ? () => Navigator.pop(context) : () => _goToPage(_currentPage + 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool isForward = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isForward && enabled
                ? _gold.withOpacity(0.12)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isForward && enabled
                  ? _gold.withOpacity(0.2)
                  : Colors.white.withOpacity(0.06),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isForward) Icon(icon, size: 18, color: enabled ? Colors.white70 : Colors.white24),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isForward && enabled ? _gold : (enabled ? Colors.white70 : Colors.white24),
                ),
              ),
              if (isForward) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 18, color: enabled ? _gold : Colors.white24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
