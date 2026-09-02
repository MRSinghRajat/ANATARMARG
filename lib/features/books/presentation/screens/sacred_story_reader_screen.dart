import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/localized.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../profile/presentation/providers/language_provider.dart';
import '../../data/models/granthalaya_models.dart';
import '../../data/services/granthalaya_bookmarks_service.dart';
import '../../data/services/granthalaya_recent_service.dart';

/// Reader for sacred stories from the dedicated sacred_stories table.
/// Uses the same visual language as StoryReaderScreen but works with SacredStoryModel.
class SacredStoryReaderScreen extends ConsumerStatefulWidget {
  final SacredStoryModel story;
  const SacredStoryReaderScreen({super.key, required this.story});

  @override
  ConsumerState<SacredStoryReaderScreen> createState() =>
      _SacredStoryReaderScreenState();
}

class _SacredStoryReaderScreenState extends ConsumerState<SacredStoryReaderScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _decorController;

  int _currentPage = 0;
  /// Null = follow [languageProvider]; true/false = mid-read override (AM-61).
  bool? _overrideHindi;
  bool _isBookmarked = false;
  final GranthalayaBookmarksService _bookmarksService =
      GranthalayaBookmarksService();

  bool get _showHindi =>
      _overrideHindi ?? (ref.watch(languageProvider) == 'hi');

  static const _bg1 = Color(0xFF0D0B08);
  static const _bg2 = Color(0xFF1A1510);
  static const _parchment = Color(0xFF1E1A14);
  static const _gold = Color(0xFFC5A059);
  static const _goldLight = Color(0xFFE2C999);

  @override
  void initState() {
    super.initState();
    GranthalayaRecentService().recordSacredStoryOpened(widget.story.id);
    _loadBookmarkState();
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

  Future<void> _loadBookmarkState() async {
    final b = await _bookmarksService.isSacredStoryBookmarked(widget.story.id);
    if (mounted) setState(() => _isBookmarked = b);
  }

  Future<void> _toggleBookmark() async {
    await _bookmarksService.toggleSacredStoryBookmark(widget.story.id);
    if (mounted) setState(() => _isBookmarked = !_isBookmarked);
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
                    : InteractiveViewer(
                        minScale: 0.6,
                        maxScale: 3.5,
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const PageScrollPhysics(),
                          itemCount: pages.length,
                          onPageChanged: _onPageChanged,
                          itemBuilder: (_, i) =>
                              _buildPage(pages[i], i),
                        ),
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
                      localized(ref, en: widget.story.title, hi: widget.story.titleHindi)
                          .toUpperCase(),
                      style: GoogleFonts.crimsonPro(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _goldLight,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.story.source != null)
                      Text(
                        widget.story.estimatedMinutes > 0
                            ? '${widget.story.source} • ${widget.story.estimatedMinutes} min'
                            : widget.story.source!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _gold.withValues(alpha: 0.5),
                          letterSpacing: 1,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _gold,
                  size: 24,
                ),
                onPressed: _toggleBookmark,
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
      onTap: () => setState(() => _overrideHindi = label == 'HI'),
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
    final isFinal = page.isFinal(widget.story.pages.length) || index == widget.story.pages.length - 1;
    final totalPages = widget.story.pages.length;
    // Use only this page's image so each page can show its own image (not the same cover on every page)
    final pageImage = page.imageUrl != null && page.imageUrl!.isNotEmpty ? page.imageUrl : null;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image section on top: this page's image only, or placeholder if none
            if (pageImage != null)
              _buildBlendedImageWithPageBar(pageImage, index, totalPages)
            else
              _buildPlaceholderImageSection(index, totalPages),
            // 2. Story text below (same layout for all pages)
            _buildStoryTextBlended(text),
            const SizedBox(height: 24),
            if (isFinal) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDivider(),
              ),
              const SizedBox(height: 20),
              if (widget.story.keyTeaching != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildKeyTeaching(),
                ),
              const SizedBox(height: 16),
              if (widget.story.reflectionPrompt != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildReflection(),
                ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  /// Placeholder image section when neither page nor story has an image (keeps layout consistent).
  Widget _buildPlaceholderImageSection(int index, int totalPages) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _gold.withValues(alpha: 0.12),
                  _bg2,
                  _bg1,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Center(
              child: Text(
                'ॐ',
                style: TextStyle(
                  fontSize: 72,
                  color: _gold.withValues(alpha: 0.15),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold.withValues(alpha: 0.3)),
              ),
              child: Text(
                'PAGE ${index + 1} OF $totalPages',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _goldLight,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Full-bleed image with gradient overlay and "PAGE X OF Y" bar overlaid at bottom (blended look).
  Widget _buildBlendedImageWithPageBar(String imageUrl, int index, int totalPages) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            cacheFailure: true,
            fallback: Container(color: _bg2),
          ),
          // Gradient overlay so page bar and transition to text blend into image
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _bg1.withValues(alpha: 0.6),
                    _bg1,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Page indicator overlaid on bottom of image (dark gold bar)
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold.withValues(alpha: 0.3)),
              ),
              child: Text(
                'PAGE ${index + 1} OF $totalPages',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _goldLight,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Story text directly below image on same dark background (blended).
  Widget _buildStoryTextBlended(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      color: _bg1,
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

  Widget _buildPageNumber(int index, int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _gold.withValues(alpha: 0.15)),
        ),
      ),
      child: Text(
        'Page ${index + 1} of $totalPages',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _gold.withValues(alpha: 0.4),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildImageTop(String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AppNetworkImage(
          imageUrl: url,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          cacheFailure: true,
          fallback: const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildFullBleedImage(String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AppNetworkImage(
          imageUrl: url,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          cacheFailure: true,
          fallback: const SizedBox.shrink(),
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
