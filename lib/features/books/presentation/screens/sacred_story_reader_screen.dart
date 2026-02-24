import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/granthalaya_models.dart';

/// Reader for sacred stories from the dedicated sacred_stories table.
/// Uses the same visual language as StoryReaderScreen but works with SacredStoryModel.
class SacredStoryReaderScreen extends StatefulWidget {
  final SacredStoryModel story;
  const SacredStoryReaderScreen({super.key, required this.story});

  @override
  State<SacredStoryReaderScreen> createState() =>
      _SacredStoryReaderScreenState();
}

class _SacredStoryReaderScreenState extends State<SacredStoryReaderScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _decorController;

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
    )..forward();
    _decorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _decorController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (index == _currentPage) return;
    setState(() => _currentPage = index);
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
                    ? Center(
                        child: Text('Story coming soon...',
                            style: GoogleFonts.inter(color: Colors.white38)))
                    : PageView.builder(
                        controller: _pageController,
                        physics: const PageScrollPhysics(),
                        itemCount: pages.length,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (_, i) =>
                            _buildPage(pages[i], i),
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
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: _gold, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.story.title,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _goldLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.story.source != null)
                      Text(
                        '${widget.story.source} • ${widget.story.estimatedMinutes} min',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _gold.withValues(alpha: 0.5),
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
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(
                _gold.withValues(alpha: 0.7),
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
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langBtn('EN', !_showHindi),
          _langBtn('HI', _showHindi),
        ],
      ),
    );
  }

  Widget _langBtn(String label, bool active) {
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

  Widget _buildPage(SacredStoryPage page, int index) {
    final text = _showHindi ? page.textHindi : page.textEnglish;
    final isFinal = page.isFinal || index == widget.story.pages.length - 1;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            FadeTransition(
              opacity: CurvedAnimation(
                  parent: _decorController, curve: Curves.easeInOut),
              child: _buildOrnament(),
            ),
            const SizedBox(height: 16),
            _buildPageNumber(index),
            const SizedBox(height: 16),
            _buildParchmentText(text),
            const SizedBox(height: 24),
            if (isFinal) ...[
              _buildDivider(),
              const SizedBox(height: 20),
              if (widget.story.keyTeaching != null) _buildKeyTeaching(),
              const SizedBox(height: 16),
              if (widget.story.reflectionPrompt != null) _buildReflection(),
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
        Container(width: 24, height: 1, color: _gold.withValues(alpha: 0.2)),
        const SizedBox(width: 8),
        Text('✦',
            style:
                TextStyle(fontSize: 10, color: _gold.withValues(alpha: 0.4))),
        const SizedBox(width: 8),
        Container(width: 24, height: 1, color: _gold.withValues(alpha: 0.2)),
      ],
    );
  }

  Widget _buildPageNumber(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _gold.withValues(alpha: 0.15)),
        ),
      ),
      child: Text(
        'Page ${index + 1} of ${widget.story.pages.length}',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _gold.withValues(alpha: 0.4),
          letterSpacing: 2,
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
        border: Border.all(color: _gold.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
        Expanded(
            child: Container(
                height: 1, color: _gold.withValues(alpha: 0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('☸',
              style: TextStyle(
                  fontSize: 14, color: _gold.withValues(alpha: 0.3))),
        ),
        Expanded(
            child: Container(
                height: 1, color: _gold.withValues(alpha: 0.1))),
      ],
    );
  }

  Widget _buildKeyTeaching() {
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
              color: _goldLight.withValues(alpha: 0.8),
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
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_outlined,
                  color: _gold.withValues(alpha: 0.6), size: 18),
              const SizedBox(width: 8),
              Text(
                'Reflect',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _gold.withValues(alpha: 0.7),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.story.reflectionPrompt ?? '',
            style: GoogleFonts.crimsonPro(
              fontSize: 15,
              height: 1.6,
              color: Colors.white60,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _bg1.withValues(alpha: 0.0),
            _bg1,
          ],
        ),
      ),
      child: Center(
        child: Text(
          '${_currentPage + 1} / $totalPages',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _gold.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
