import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/localized.dart';
import '../../../../shared/widgets/antarmarg_placeholder.dart';
import '../../data/models/granthalaya_models.dart';
import '../../data/models/book_model.dart';
import '../providers/book_providers.dart';
import 'sacred_text_reader_screen.dart';
import 'sacred_story_reader_screen.dart';
import 'book_detail_screen.dart';
import '../../data/services/granthalaya_recent_service.dart';
import '../widgets/deity_portrait.dart';

class DeityDetailScreen extends ConsumerStatefulWidget {
  final DeityModel deity;
  const DeityDetailScreen({super.key, required this.deity});

  @override
  ConsumerState<DeityDetailScreen> createState() => _DeityDetailScreenState();
}

class _DeityDetailScreenState extends ConsumerState<DeityDetailScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _fadeController;

  static const _bg = Color(0xFF0D0B08);
  static const _parchment = Color(0xFF1E1A14);

  Color get _accent => _hexToColor(widget.deity.color);

  static Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void initState() {
    super.initState();
    GranthalayaRecentService().recordDeityOpened(widget.deity.slug);
    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.deity;

    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxScrolled) => [
          _buildHeroHeader(d),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              tabBar: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: _accent,
                indicatorWeight: 2.5,
                labelColor: _accent,
                unselectedLabelColor: Colors.white38,
                labelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                dividerHeight: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Library'),
                  Tab(text: 'Worship & Culture'),
                  Tab(text: 'Timeline'),
                ],
              ),
              color: _bg,
            ),
          ),
        ],
        body: FadeTransition(
          opacity: CurvedAnimation(
            parent: _fadeController,
            curve: Curves.easeIn,
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(d),
              _buildLibraryTab(d),
              _buildWorshipTab(d),
              _buildTimelineTab(d),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroHeader(DeityModel d) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: _bg,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          d.name,
          style: GoogleFonts.crimsonPro(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _accent,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 56),
        background: Stack(
          fit: StackFit.expand,
          children: [
            DeityPortrait(
              imageUrl: d.imageUrl,
              slug: d.slug,
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.3),
              colorBlendMode: BlendMode.darken,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    _bg.withValues(alpha: 0.5),
                    _bg,
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deity name in both scripts: scripture-body exception (AM-58).
                  if (d.titleHindi != null)
                    Text(
                      d.titleHindi!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _accent.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (d.description != null && d.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        d.description!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white60,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1 — OVERVIEW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildOverviewTab(DeityModel d) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20, bottom: 80),
      children: [
        if (d.sacredDay != null) ...[
          _buildSacredDay(d),
          const SizedBox(height: 24),
        ],
        if (d.mantras.isNotEmpty) ...[
          _buildQuickMantras(d),
          const SizedBox(height: 24),
        ],
        if (d.mythology != null && d.mythology!.isNotEmpty)
          _buildMythology(d),
      ],
    );
  }

  // ── Quick Mantras (no "Tap to copy" to avoid overflow) ──
  Widget _buildQuickMantras(DeityModel d) {
    return _section(
      'Quick Mantras',
      Icons.music_note_rounded,
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: d.mantras.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: d.mantras[i]));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mantra copied',
                      style: GoogleFonts.inter(fontSize: 13)),
                  duration: const Duration(seconds: 1),
                  backgroundColor: _accent.withValues(alpha: 0.9),
                ),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: _accent.withValues(alpha: 0.15)),
              ),
              child: Center(
                child: Text(
                  d.mantras[i],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSacredDay(DeityModel d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _accent.withValues(alpha: 0.12),
              _accent.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accent.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.calendar_today, color: _accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sacred Day',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _accent.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    d.sacredDay!,
                    style: GoogleFonts.crimsonPro(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (d.sacredNumber != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Sacred #${d.sacredNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMythology(DeityModel d) {
    return _section(
      'Mythology',
      Icons.auto_stories,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _parchment,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _accent.withValues(alpha: 0.08)),
          ),
          child: Text(
            d.mythology!,
            style: GoogleFonts.crimsonPro(
              fontSize: 16,
              color: const Color(0xFFE8E0D4),
              height: 1.8,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2 — LIBRARY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLibraryTab(DeityModel d) {
    final sacredTexts = ref.watch(sacredTextsProvider(d.slug));
    final sacredStories = ref.watch(sacredStoriesCollectionProvider(d.slug));
    final deityBooks = ref.watch(booksByDeityProvider(d.slug));

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20, bottom: 80),
      children: [
        sacredTexts.when(
          data: (texts) =>
              texts.isEmpty ? _buildEmpty('No sacred texts yet') : _buildSacredTextsSection(texts),
          loading: () => _buildSectionLoading(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        sacredStories.when(
          data: (stories) =>
              stories.isEmpty ? _buildEmpty('No stories yet') : _buildStoriesSection(stories),
          loading: () => _buildSectionLoading(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        deityBooks.when(
          data: (books) =>
              books.isEmpty ? _buildEmpty('No books linked yet') : _buildBooksSection(books),
          loading: () => _buildSectionLoading(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSacredTextsSection(List<SacredTextModel> texts) {
    return _section(
      'Sacred Texts',
      Icons.menu_book_rounded,
      child: SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: texts.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _buildSacredTextCard(texts[i]),
        ),
      ),
      bottomPadding: 24,
    );
  }

  Widget _buildSacredTextCard(SacredTextModel text) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SacredTextReaderScreen(sacredText: text),
        ),
      ),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _accent.withValues(alpha: 0.12),
              _accent.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accent.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text.typeLabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _accent,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              localized(ref, en: text.title, hi: text.titleHindi),
              style: GoogleFonts.crimsonPro(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                if (text.verseCount != null) ...[
                  Icon(Icons.format_list_numbered,
                      size: 12, color: _accent.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    '${text.verseCount} verses',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.white38),
                  ),
                ],
                const Spacer(),
                Icon(Icons.arrow_forward_ios,
                    size: 12, color: _accent.withValues(alpha: 0.4)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesSection(List<SacredStoryModel> stories) {
    return _section(
      'Sacred Stories',
      Icons.local_library_rounded,
      child: SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: stories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _buildStoryCard(stories[i]),
        ),
      ),
      bottomPadding: 24,
    );
  }

  Widget _buildStoryCard(SacredStoryModel story) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SacredStoryReaderScreen(story: story),
        ),
      ),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _parchment,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accent.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    story.source ?? story.category,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${story.estimatedMinutes} min',
                  style:
                      GoogleFonts.inter(fontSize: 10, color: Colors.white38),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              localized(ref, en: story.title, hi: story.titleHindi),
              style: GoogleFonts.crimsonPro(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE8E0D4),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.auto_stories,
                    size: 14, color: _accent.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Text(
                  '${story.pages.length} pages',
                  style:
                      GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios,
                    size: 12, color: _accent.withValues(alpha: 0.4)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksSection(List<BookModel> books) {
    return _section(
      'Sacred Books',
      Icons.menu_book_rounded,
      child: SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: books.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, i) => _buildDeityBookCard(books[i]),
        ),
      ),
      bottomPadding: 24,
    );
  }

  Widget _buildDeityBookCard(BookModel book) {
    final hasImage =
        book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
      ),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accent.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                AppNetworkImage(
                  imageUrl: book.coverImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _buildBookGradientBg(),
                )
              else
                _buildBookGradientBg(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book.name,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (book.nameSanskrit != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        book.nameSanskrit!,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: _accent.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${book.totalChapters} chapters',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookGradientBg() {
    return AntarmargPlaceholder(compact: true);
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3 — WORSHIP & CULTURE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildWorshipTab(DeityModel d) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20, bottom: 80),
      children: [
        _buildHowToWorship(d),
        if (d.iconography.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildIconography(d),
        ],
        if (d.family.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildFamily(d),
        ],
        if (d.festivals.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildFestivals(d),
        ],
        if (d.temples.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildTemples(d),
        ],
      ],
    );
  }

  Widget _buildHowToWorship(DeityModel d) {
    if (d.howToWorship == null || d.howToWorship!.isEmpty) {
      return _buildEmpty('Worship guide coming soon');
    }
    final steps =
        d.howToWorship!.split('\n').where((s) => s.trim().isNotEmpty).toList();

    return _section(
      'How to Worship',
      Icons.temple_hindu,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _accent.withValues(alpha: 0.08),
                _accent.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _accent.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _accent,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value
                            .replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFFE8E0D4)
                              .withValues(alpha: 0.85),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildIconography(DeityModel d) {
    final weapons =
        (d.iconography['weapons'] as List<dynamic>?)?.cast<String>() ?? [];
    final symbols =
        (d.iconography['symbols'] as List<dynamic>?)?.cast<String>() ?? [];
    final forms =
        (d.iconography['forms'] as List<dynamic>?)?.cast<String>() ?? [];
    final mount = d.iconography['mount'] as String?;

    if (weapons.isEmpty && symbols.isEmpty && forms.isEmpty && mount == null) {
      return const SizedBox.shrink();
    }

    return _section(
      'Iconography',
      Icons.auto_awesome,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mount != null) _buildChipRow('Mount', [mount]),
            if (weapons.isNotEmpty) _buildChipRow('Weapons', weapons),
            if (symbols.isNotEmpty) _buildChipRow('Symbols', symbols),
            if (forms.isNotEmpty) _buildChipRow('Forms', forms),
          ],
        ),
      ),
    );
  }

  Widget _buildChipRow(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _accent.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: items
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _accent.withValues(alpha: 0.1)),
                      ),
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.white70),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFamily(DeityModel d) {
    final entries = <MapEntry<String, String>>[];
    d.family.forEach((k, v) {
      if (v is String && v.isNotEmpty) {
        entries.add(MapEntry(k, v));
      } else if (v is List && v.isNotEmpty) {
        entries.add(MapEntry(k, v.join(', ')));
      }
    });
    if (entries.isEmpty) return const SizedBox.shrink();

    return _section(
      'Family',
      Icons.people_outline,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _parchment,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _accent.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        _capitalizeLabel(e.key),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _accent.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.value,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFestivals(DeityModel d) {
    return _section(
      'Festivals',
      Icons.celebration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: d.festivals.map((f) {
            final fest = f as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _accent.withValues(alpha: 0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.event, color: _accent, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fest['name'] as String? ?? '',
                          style: GoogleFonts.crimsonPro(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          fest['month'] as String? ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: _accent.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fest['description'] as String? ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white60,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTemples(DeityModel d) {
    return _section(
      'Famous Temples',
      Icons.location_on,
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: d.temples.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final t = d.temples[i] as Map<String, dynamic>;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: _accent.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t['name'] as String? ?? '',
                    style: GoogleFonts.crimsonPro(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t['city'] as String? ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _accent.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 4 — TIMELINE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTimelineTab(DeityModel d) {
    if (d.timeline.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timeline, size: 48, color: _accent.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'Timeline coming soon',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      itemCount: d.timeline.length,
      itemBuilder: (_, i) {
        final event = d.timeline[i] as Map<String, dynamic>;
        final isFirst = i == 0;
        final isLast = i == d.timeline.length - 1;
        return _buildTimelineEvent(event, isFirst, isLast);
      },
    );
  }

  Widget _buildTimelineEvent(
      Map<String, dynamic> event, bool isFirst, bool isLast) {
    final title = event['title'] as String? ?? '';
    final description = event['description'] as String? ?? '';
    final era = event['era'] as String? ?? '';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (isFirst) const SizedBox(height: 8),
                if (!isFirst)
                  Expanded(
                    flex: 0,
                    child: Container(
                      width: 2,
                      height: 8,
                      color: _accent.withValues(alpha: 0.2),
                    ),
                  ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isFirst || isLast
                        ? _accent
                        : _accent.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: isFirst || isLast
                        ? [
                            BoxShadow(
                              color: _accent.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _accent.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _parchment,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _accent.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (era.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        era,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  Text(
                    title,
                    style: GoogleFonts.crimsonPro(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFFE8E0D4).withValues(alpha: 0.75),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SHARED HELPERS
  // ═══════════════════════════════════════════════════════════════
  Widget _section(String title, IconData icon,
      {required Widget child, double bottomPadding = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: _accent, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _accent,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        child,
        SizedBox(height: bottomPadding),
      ],
    );
  }

  Widget _buildSectionLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _accent.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: AntarmargPlaceholder(compact: true),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white24),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

// ─── Sticky TabBar Delegate ─────────────────────────────────────
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;

  const _StickyTabBarDelegate({required this.tabBar, required this.color});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}
