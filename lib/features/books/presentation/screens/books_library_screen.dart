import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/book_model.dart';
import '../providers/book_providers.dart';
import '../widgets/granthalaya_audio_content.dart';
import '../widgets/granthalaya_audio_mini_player.dart';
import 'book_detail_screen.dart';

/// Granthalaya - Academic Dashboard. Sacred Texts on top, Foundation & Concepts, Study Resources.
class BooksLibraryScreen extends ConsumerStatefulWidget {
  const BooksLibraryScreen({super.key});

  @override
  ConsumerState<BooksLibraryScreen> createState() => _BooksLibraryScreenState();
}

class _BooksLibraryScreenState extends ConsumerState<BooksLibraryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<BookModel> _books = [];
  bool _isLoading = true;
  bool _readMode = true;
  // Audio (Listen mode) - mini player only visible in this tab
  bool _showMiniPlayer = false;
  String _nowPlayingTitle = '';
  String? _nowPlayingCoverUrl;
  double _nowPlayingProgress = 0.2;

  static const _coverUrls = {
    'bhagavad_gita': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
    'mahabharata': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    'ramayana': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
    'ramayan': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
    'vedas': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
    'upanishads': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
  };

  static const _foundationConceptCards = [
    ('DEFINITION', 'Sanatana Dharma', 'The eternal law and inherent nature of reality.'),
    ('HISTORY', 'Vedic Timeline', 'Evolution of thought from 1500 BCE to modern era.'),
  ];

  static const _conceptListCards = [
    ('Brahman', 'The Ultimate Reality, singular and infinite.',
        'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=200'),
    ('Deities', 'Manifestations of the Divine as Devas & Devis.',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200'),
    ('Avatars', 'Divine incarnations descending for Dharma.',
        'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=200'),
  ];

  static const _studyResources = [
    (Icons.menu_book, 'Hymn Vocabulary', '45 ESSENTIAL SANSKRIT TERMS'),
    (Icons.history_edu, 'Dharma Principles', '12 FOUNDATION GUIDELINES'),
  ];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(granthalayaReadModeProvider.notifier).state = _readMode;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final repo = ref.read(bookRepositoryProvider);
    try {
      final books = await repo.getAllBooks();
      if (mounted) setState(() => _books = books);
    } catch (_) {
      if (mounted) setState(() => _books = repo.allBooks);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _getBookSubtitle(BookModel book) {
    switch (book.id.toLowerCase()) {
      case 'ramayana':
      case 'ramayan':
        return 'The Journey';
      case 'mahabharata':
        return 'The Kurukshetra War Chronicle';
      case 'bhagavad_gita':
        return '18 Chapters • The Divine Song';
      case 'upanishads':
        return 'Philosophical Wisdom';
      default:
        return book.description.length > 35
            ? '${book.description.substring(0, 32)}...'
            : book.description;
    }
  }

  String _getBookTag(BookModel book) {
    switch (book.id.toLowerCase()) {
      case 'bhagavad_gita':
        return 'SMRITI';
      case 'mahabharata':
      case 'ramayana':
      case 'ramayan':
        return 'ITIHASA';
      default:
        return 'SHRUTI';
    }
  }

  String? _getCoverUrl(String bookId) {
    if (_coverUrls.containsKey(bookId.toLowerCase())) {
      return _coverUrls[bookId.toLowerCase()];
    }
    return _coverUrls['bhagavad_gita'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalDark,
      body: SafeArea(
        child: _readMode ? _buildReadContent() : _buildListenContent(),
      ),
    );
  }

  Widget _buildReadContent() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildModeToggleAndSearch()),
        SliverToBoxAdapter(child: _buildSacredTexts()),
        SliverToBoxAdapter(child: _buildFoundationConcepts()),
        SliverToBoxAdapter(child: _buildStudyResources()),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildListenContent() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildModeToggleAndSearch(),
            Expanded(
              child: GranthalayaAudioContent(
                onPlay: (info) {
                  setState(() {
                    _nowPlayingTitle = info.title;
                    _nowPlayingCoverUrl = info.coverUrl;
                    _nowPlayingProgress = 0.2;
                    _showMiniPlayer = true;
                  });
                },
              ),
            ),
            if (_showMiniPlayer)
              GranthalayaAudioMiniPlayer(
                title: _nowPlayingTitle,
                coverImageUrl: _nowPlayingCoverUrl,
                progress: _nowPlayingProgress,
                onClose: () => setState(() => _showMiniPlayer = false),
              )
            else
              const SizedBox(height: 0),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.charcoalDark.withOpacity(0.95),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: AppColors.matteGold),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
              Text(
                'Granthalaya',
                style: GoogleFonts.crimsonPro(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.matteGold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.notifications_outlined,
                  color: AppColors.matteGold.withOpacity(0.6), size: 22),
              const SizedBox(width: 16),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.matteGold.withOpacity(0.3)),
                  color: AppColors.charcoalCard,
                ),
                child: const Icon(Icons.person, color: AppColors.matteGold, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggleAndSearch() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.charcoalCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.charcoalBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_readMode ? Colors.white.withOpacity(0.05) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: !_readMode
                          ? Border.all(color: AppColors.matteGold.withOpacity(0.2))
                          : null,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _readMode = false);
                        ref.read(granthalayaReadModeProvider.notifier).state = false;
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.headphones,
                              size: 18, color: _readMode ? AppColors.zinc500 : AppColors.matteGold),
                          const SizedBox(width: 8),
                          Text(
                            'Listen',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: _readMode ? FontWeight.w500 : FontWeight.w600,
                              color: _readMode ? AppColors.zinc500 : AppColors.matteGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _readMode ? Colors.white.withOpacity(0.05) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: _readMode
                          ? Border.all(color: AppColors.matteGold.withOpacity(0.2))
                          : null,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _readMode = true);
                        ref.read(granthalayaReadModeProvider.notifier).state = true;
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_stories,
                              size: 18, color: _readMode ? AppColors.matteGold : AppColors.zinc500),
                          const SizedBox(width: 8),
                          Text(
                            'Read Mode',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _readMode ? AppColors.matteGold : AppColors.zinc500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.charcoalCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.charcoalBorder),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: _readMode
                    ? 'Search scriptures, terms, or deities...'
                    : 'Search audiobooks, chants, or discussions...',
                hintStyle: GoogleFonts.inter(color: AppColors.zinc500, fontSize: 14),
                prefixIcon: Icon(Icons.search,
                    color: AppColors.matteGold.withOpacity(0.6), size: 22),
                filled: true,
                fillColor: AppColors.charcoalCard,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSacredTexts() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.matteGold, width: 4)),
            ),
            child: Text(
              'Sacred Texts',
              style: GoogleFonts.crimsonPro(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 320,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.matteGold))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _books.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (_, i) => _buildSacredBookCard(_books[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSacredBookCard(BookModel book) {
    final coverUrl = book.coverImageUrl?.isNotEmpty == true
        ? book.coverImageUrl
        : _getCoverUrl(book.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
      ).then((_) => _loadBooks()),
      child: SizedBox(
        width: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: coverUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: coverUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _placeholderCover(),
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ],
                    )
                  : _placeholderCover(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.charcoalDark.withOpacity(0.3),
                    AppColors.charcoalDark,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: book.id.toLowerCase() == 'bhagavad_gita'
                          ? AppColors.matteGold.withOpacity(0.9)
                          : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getBookTag(book),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: book.id.toLowerCase() == 'bhagavad_gita'
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.name,
                    style: GoogleFonts.crimsonPro(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getBookSubtitle(book),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.zinc400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoundationConcepts() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 12),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: AppColors.matteGold, width: 4)),
                ),
                child: Text(
                  'Foundation & Concepts',
                  style: GoogleFonts.crimsonPro(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Show all',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.matteGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildFoundationCard(
                  _foundationConceptCards[0].$1,
                  _foundationConceptCards[0].$2,
                  _foundationConceptCards[0].$3,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFoundationCard(
                  _foundationConceptCards[1].$1,
                  _foundationConceptCards[1].$2,
                  _foundationConceptCards[1].$3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._conceptListCards.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildConceptListCard(e.$1, e.$2, e.$3),
              )),
        ],
      ),
    );
  }

  Widget _buildFoundationCard(String tag, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoalCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.matteGold.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: AppColors.matteGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.crimsonPro(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.zinc500,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildConceptListCard(String title, String desc, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.charcoalCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.matteGold.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: SizedBox(
              width: 56,
              height: 56,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: Colors.black,
                  child: const Icon(Icons.image, color: AppColors.matteGold, size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.crimsonPro(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.zinc500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.matteGold.withOpacity(0.3), size: 24),
        ],
      ),
    );
  }

  Widget _buildStudyResources() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.matteGold, width: 4)),
            ),
            child: Text(
              'Study Resources',
              style: GoogleFonts.crimsonPro(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ..._studyResources.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildStudyResourceCard(e.$1, e.$2, e.$3),
              )),
        ],
      ),
    );
  }

  Widget _buildStudyResourceCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoalCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.matteGold.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.matteGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.matteGold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.crimsonPro(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: AppColors.zinc500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppColors.matteGold.withOpacity(0.4), size: 16),
        ],
      ),
    );
  }

  Widget _placeholderCover() {
    return Container(
      color: Colors.black,
      child: const Icon(Icons.menu_book, size: 48, color: AppColors.matteGold),
    );
  }
}
