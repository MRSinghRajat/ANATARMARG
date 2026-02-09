import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/book_model.dart';
import '../providers/book_providers.dart';
import '../providers/now_playing_provider.dart';
import '../../data/models/granthalaya_models.dart';
import '../widgets/granthalaya_audio_content.dart';
import '../widgets/granthalaya_audio_progress_sync.dart';
import '../widgets/granthalaya_audio_mini_player.dart';
import 'book_detail_screen.dart';
import 'full_audio_player_screen.dart';

/// Granthalaya - Academic Dashboard. Sacred Texts on top, Foundation & Concepts, Study Resources.
class BooksLibraryScreen extends ConsumerStatefulWidget {
  const BooksLibraryScreen({super.key});

  @override
  ConsumerState<BooksLibraryScreen> createState() => _BooksLibraryScreenState();
}

class _BooksLibraryScreenState extends ConsumerState<BooksLibraryScreen> {
  final ScrollController _scrollController = ScrollController();
  List<BookModel> _books = [];
  bool _isLoading = true;
  bool _readMode = true;
  int _sacredLibraryCategoryIndex = 0;
  // Audio (Listen mode) - mini player driven by nowPlayingProvider

  static const _coverUrls = {
    'bhagavad_gita':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCeFNfyF3TMbtQ7up4KjskhDXsUja_ezF57r7yXtsw7qht7MWETTO5t-dTRJ5yKLGjVidywqNDN_tYKaEhCT-GW6PgKdHyCJivzZEk3MFKeenhqQE9lW9dmulcDAGEtzqlDKk9-V_1vAxfrsXu5ER-bNWtcVzRI4zSyvvmNDPJ58EPRheqIFknQUzuOF0zLsTHepqZozzC058V3Vhz4FC7I0MqtbnhK3mRrEBauKk-OBOllQvmPoUhxzI3oicigPXbW4HNzglsA3JZD',
    'mahabharata':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1',
    'ramayana':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1',
    'ramayan':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1',
    'vedas':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1',
    'upanishads':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCJl1L6fIrykeLWmdy0V5EC5-Eh4nRFTBiIJmZvfBncpvgMivobf5NbOHIFWkBndaaRvC4YCHyOTgYrn17GM4YRUqu02UjdT4uoTbH-Qgy1FmIfhhsA0Q21QwyKikc1JvvZApGs7fH_6m_pQ48kHemmVpGJUfO0f-idW3Am5Dmyv8mGgIQlPOWu75jym4UITWgp7x6KSH22NMoTXUhrWu_mF-XQ-pykoUCH1RnyCP6zvd3oYGw_0Gh7KrpdRZrmDrJCq4lPaP81wgPO',
    'shiva purana':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCJl1L6fIrykeLWmdy0V5EC5-Eh4nRFTBiIJmZvfBncpvgMivobf5NbOHIFWkBndaaRvC4YCHyOTgYrn17GM4YRUqu02UjdT4uoTbH-Qgy1FmIfhhsA0Q21QwyKikc1JvvZApGs7fH_6m_pQ48kHemmVpGJUfO0f-idW3Am5Dmyv8mGgIQlPOWu75jym4UITWgp7x6KSH22NMoTXUhrWu_mF-XQ-pykoUCH1RnyCP6zvd3oYGw_0Gh7KrpdRZrmDrJCq4lPaP81wgPO',
    'rig veda':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1',
  };

  static const _deitiesFallback = [
    (
      'Shiva',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv'
    ),
    (
      'Vishnu',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv'
    ),
    (
      'Devi',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCd_4JNasICaIaHij84HkpIMICry2qj9vQbv4E418yGFsZvKbS4Wk5J2i4pPOqk6gM2mWCKAS7JczuUgHfnRi0fUli5hU8gZovvHqoWo1GI22rS613kTYAxJVowoCXRgFDR7-97bUilllW6Z6rM_MEB4Hk9fe8yAcF-871rkAWzHsFNmpVDH0R7w0OW0g-tlL9Ncib0jHHxIuN-3O-lrpEiRaVouZoSikGTJQqEE0fD1rbpaJNRwDvfadeu6GWnWi2-30rmN0BAjiQr'
    ),
    (
      'Ganesha',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDT51ZKt0o37zUWn7OBW7NHAv_eqYJDBi4yZSbeFZsG98EbbMrXTd47UBFo-C-q6a_D5Wg7QkmTldlWo2U-Y6HXTvI8ZMGCeKCqeeY_SH_QML9bOxOaQmW3MahYkvWdvzedC3MC4eh1a__pyn4fjae8N3Nv0t3kjNR4AXPY0PcHYhJw7RD9oPYAhii6KgHEnis4nYoIPGi8mnmpm2BwyGDZVYSjZGHeofoTpepPJCe6VnrqAtyO98VkNkBPEHHvZZP7xXJcLm8pe54P'
    ),
  ];

  IconData _iconFromName(String name) {
    switch (name) {
      case 'record_voice_over':
        return Icons.record_voice_over;
      default:
        return Icons.menu_book;
    }
  }

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

  String _getBookTag(BookModel book) {
    switch (book.id.toLowerCase()) {
      case 'bhagavad_gita':
      case 'geeta':
        return 'Wisdom';
      case 'mahabharata':
      case 'ramayana':
      case 'ramayan':
        return 'Epic';
      default:
        return 'Sacred';
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
      backgroundColor: AppColors.deepAsh,
      body: SafeArea(
        child: _readMode ? _buildReadContent() : _buildListenContent(),
      ),
    );
  }

  List<BookModel> get _currentlyReadingBooks {
    final started = _books.where((b) => b.progress > 0).toList();
    started.sort((a, b) =>
        (b.lastReadAt ?? DateTime(0)).compareTo(a.lastReadAt ?? DateTime(0)));
    return started;
  }

  Widget _buildReadContent() {
    return RefreshIndicator(
      onRefresh: _loadBooks,
      color: AppColors.matteGold,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: _buildReadHeader()),
          SliverToBoxAdapter(child: _buildModeToggle()),
          SliverToBoxAdapter(child: _buildInProgressSection()),
          SliverToBoxAdapter(child: _buildSacredLibrarySection()),
          SliverToBoxAdapter(child: _buildChantsSection()),
          SliverToBoxAdapter(child: _buildExploreDeitiesSection()),
          SliverToBoxAdapter(child: _buildResourceLibrarySection()),
          SliverToBoxAdapter(child: _buildDeepDiveSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildReadHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.deepAsh.withOpacity(0.85),
        border: Border(
            bottom: BorderSide(color: AppColors.matteGold.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu_open,
                    color: AppColors.matteGold, size: 24),
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              Text(
                'Granthalaya',
                style: GoogleFonts.crimsonPro(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: AppColors.matteGold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.search,
                  color: AppColors.matteGold.withOpacity(0.6), size: 22),
              const SizedBox(width: 20),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.matteGold.withOpacity(0.2)),
                  color: AppColors.manuscriptDark,
                ),
                child:
                    const Icon(Icons.spa, color: AppColors.matteGold, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.manuscriptDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.matteGold.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _readMode = false);
                  ref.read(granthalayaReadModeProvider.notifier).state = false;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _readMode
                        ? Colors.transparent
                        : AppColors.matteGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: !_readMode
                        ? Border.all(
                            color: AppColors.matteGold.withOpacity(0.2))
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.headphones,
                          size: 18,
                          color: _readMode
                              ? AppColors.zinc500
                              : AppColors.matteGold),
                      const SizedBox(width: 8),
                      Text(
                        'Listen',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              _readMode ? FontWeight.w500 : FontWeight.bold,
                          color: _readMode
                              ? AppColors.zinc500
                              : AppColors.matteGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _readMode = true);
                  ref.read(granthalayaReadModeProvider.notifier).state = true;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _readMode
                        ? AppColors.matteGold.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: _readMode
                        ? Border.all(
                            color: AppColors.matteGold.withOpacity(0.2))
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_stories,
                          size: 18,
                          color: _readMode
                              ? AppColors.matteGold
                              : AppColors.zinc500),
                      const SizedBox(width: 8),
                      Text(
                        'Read Mode',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              _readMode ? FontWeight.bold : FontWeight.w500,
                          color: _readMode
                              ? AppColors.matteGold
                              : AppColors.zinc500,
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
    );
  }

  Widget _buildInProgressSection() {
    final books = _currentlyReadingBooks;
    if (books.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'In Progress',
                  style: GoogleFonts.crimsonPro(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matteGold.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Resuming Your Path',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matteGold.withOpacity(0.4),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 320,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) => _buildInProgressCard(books[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressCard(BookModel book) {
    final coverUrl = book.coverImageUrl?.isNotEmpty == true
        ? book.coverImageUrl
        : _getCoverUrl(book.id);
    final progress = book.progress.clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final tag = _getBookTag(book);
    final subtitle = _getInProgressSubtitle(book);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
        ).then((_) => _loadBooks()),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 260,
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.matteGold.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (coverUrl != null && coverUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholderCover(),
                  )
                else
                  _placeholderCover(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.matteGold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.name,
                          style: GoogleFonts.crimsonPro(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.matteGold.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _getProgressLabel(book),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              '$percent% Complete',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.matteGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildProgressBar(progress),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInProgressSubtitle(BookModel book) {
    final nextChapter = (book.completedChapters) + 1;
    final total = book.totalChapters;
    switch (book.id.toLowerCase()) {
      case 'bhagavad_gita':
      case 'geeta':
        return 'Chapter $nextChapter of $total';
      case 'ramayana':
      case 'ramayan':
        return nextChapter <= 7 ? 'Kanda $nextChapter' : 'Chapter $nextChapter';
      case 'mahabharata':
        return 'Parva $nextChapter';
      default:
        return 'Chapter $nextChapter of $total';
    }
  }

  String _getProgressLabel(BookModel book) {
    switch (book.id.toLowerCase()) {
      case 'bhagavad_gita':
      case 'geeta':
        return 'Shlok ${(book.completedChapters * 10).clamp(1, 700)} / ${book.totalChapters * 40}';
      case 'ramayana':
      case 'ramayan':
        return 'Sarga ${(book.completedChapters * 17).clamp(1, 119)} of 119';
      default:
        return 'Chapter ${book.completedChapters + 1} / ${book.totalChapters}';
    }
  }

  Widget _buildProgressBar(double progress) {
    final p = progress.clamp(0.0, 1.0);
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (p > 0)
                SizedBox(
                  width: constraints.maxWidth * p,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFC5A059),
                          Color(0xFFE2C999),
                          Color(0xFFC5A059)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.matteGold.withOpacity(0.4),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListenContent() {
    return Stack(
      children: [
        GranthalayaAudioProgressSync(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildListenHeader(),
              _buildListenModeToggle(),
              Expanded(
                child: GranthalayaAudioContent(
                  onPlay: (info) async {
                    await ref.read(nowPlayingProvider.notifier).setTrackAndPlay(
                          title: info.title,
                          subtitle: info.subtitle,
                          coverUrl: info.coverUrl,
                          audioUrl: info.audioUrl,
                        );
                    await ref.read(granthalayaDataSourceProvider).upsertUserAudioProgress(
                          title: info.title,
                          tag: info.subtitle ?? '',
                          subtitle: info.subtitle,
                          imageUrl: info.coverUrl,
                          audioUrl: info.audioUrl,
                          currentTimeSeconds: 0,
                          totalTimeSeconds: 0,
                        );
                    ref.invalidate(userAudioProgressProvider);
                  },
                ),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(nowPlayingProvider);
                  if (state == null) return const SizedBox.shrink();
                  return GranthalayaAudioMiniPlayer(
                    onClose: () => ref.read(nowPlayingProvider.notifier).clear(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListenHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.deepAsh.withOpacity(0.8),
        border:
            Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.menu,
                  color: AppColors.matteGold.withOpacity(0.8), size: 24),
              const SizedBox(width: 16),
              Text(
                'GRANTHALAYA',
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.matteGold,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.search,
                  color: AppColors.matteGold.withOpacity(0.6), size: 20),
              const SizedBox(width: 20),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.matteGold.withOpacity(0.2)),
                ),
                child: Icon(Icons.face,
                    color: AppColors.matteGold.withOpacity(0.6), size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListenModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _readMode = false);
                  ref.read(granthalayaReadModeProvider.notifier).state = false;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !_readMode
                        ? AppColors.matteGold.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: !_readMode
                        ? Border.all(
                            color: AppColors.matteGold.withOpacity(0.2))
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.headphones,
                          size: 18,
                          color: !_readMode
                              ? AppColors.matteGold
                              : AppColors.zinc500),
                      const SizedBox(width: 8),
                      Text(
                        'Listen',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              !_readMode ? FontWeight.w600 : FontWeight.w500,
                          color: !_readMode
                              ? AppColors.matteGold
                              : AppColors.zinc500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _readMode = true);
                  ref.read(granthalayaReadModeProvider.notifier).state = true;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _readMode ? Colors.transparent : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_stories,
                          size: 18,
                          color: _readMode
                              ? AppColors.zinc500
                              : AppColors.matteGold),
                      const SizedBox(width: 8),
                      Text(
                        'Read Mode',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              _readMode ? FontWeight.w500 : FontWeight.w600,
                          color: _readMode
                              ? AppColors.zinc500
                              : AppColors.matteGold,
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
    );
  }

  static const _sacredCategories = [
    'All Texts',
    'Puranas',
    'Vedas',
    'Upanishads'
  ];

  List<BookModel> get _filteredBooks {
    if (_sacredLibraryCategoryIndex == 0) return _books;
    final cat = _sacredCategories[_sacredLibraryCategoryIndex].toLowerCase();
    return _books
        .where((b) =>
            b.category.toLowerCase().contains(cat) ||
            b.name.toLowerCase().contains(cat) ||
            (cat == 'puranas' &&
                (b.id.toLowerCase().contains('purana') ||
                    b.name.toLowerCase().contains('purana'))) ||
            (cat == 'vedas' &&
                (b.id.toLowerCase().contains('veda') ||
                    b.name.toLowerCase().contains('veda'))) ||
            (cat == 'upanishads' &&
                (b.id.toLowerCase().contains('upanishad') ||
                    b.name.toLowerCase().contains('upanishad'))))
        .toList();
  }

  Widget _buildSacredLibrarySection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sacred Library',
                  style: GoogleFonts.crimsonPro(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matteGold.withOpacity(0.9),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.matteGold.withOpacity(0.2)),
                      ),
                      child: Icon(Icons.tune,
                          size: 16,
                          color: AppColors.matteGold.withOpacity(0.6)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: _sacredCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final isActive = i == _sacredLibraryCategoryIndex;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        setState(() => _sacredLibraryCategoryIndex = i),
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isActive ? AppColors.matteGold : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isActive
                              ? AppColors.matteGold
                              : AppColors.matteGold.withOpacity(0.2),
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                    color: AppColors.matteGold.withOpacity(0.2),
                                    blurRadius: 8)
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          _sacredCategories[i],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.black
                                : AppColors.matteGold.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 175,
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.matteGold))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _filteredBooks.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (_, i) =>
                        _buildSacredLibraryCard(_filteredBooks[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChantsSection() {
    return Consumer(
      builder: (context, ref, _) {
        final chantsAsync = ref.watch(chantsProvider);
        final chants = chantsAsync.valueOrNull ?? [];
        if (chants.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Chants',
                  style: GoogleFonts.crimsonPro(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matteGold.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: chants.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, i) => _buildChantCard(chants[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChantCard(ChantModel chant) {
    final imageUrl = chant.imageUrl ??
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (chant.effectiveAudioUrl.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullAudioPlayerScreen(
                  title: chant.title,
                  subtitle: chant.subtitle,
                  coverImageUrl: imageUrl,
                  audioUrl: chant.effectiveAudioUrl,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.charcoalCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.charcoalBorder),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.manuscriptDark,
                      child: Icon(
                        Icons.music_note,
                        color: AppColors.matteGold,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chant.title,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chant.subtitle ?? chant.durationFormatted,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.zinc500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          color: AppColors.matteGold,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Play',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.matteGold,
                          ),
                        ),
                      ],
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

  Widget _buildSacredLibraryCard(BookModel book) {
    final coverUrl = book.coverImageUrl?.isNotEmpty == true
        ? book.coverImageUrl
        : _getCoverUrl(book.id);
    final subtitle = _getSacredLibrarySubtitle(book);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
        ).then((_) => _loadBooks()),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 200,
          height: 175,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (coverUrl != null && coverUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: coverUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _placeholderCover(),
                        )
                      else
                        _placeholderCover(),
                      Container(color: Colors.black.withOpacity(0.2)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF1F5F9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.matteGold.withOpacity(0.5),
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  String _getSacredLibrarySubtitle(BookModel book) {
    switch (book.id.toLowerCase()) {
      case 'bhagavad_gita':
      case 'geeta':
        return '18 Chapters • The Divine Song';
      case 'ramayana':
      case 'ramayan':
        return '7 Kandas • The Journey';
      case 'mahabharata':
        return '18 Parvas • Epic Chronicle';
      case 'shiva purana':
        return '12 Cantos • Eternal Wisdom';
      case 'rig veda':
      case 'vedas':
        return 'Mandala I-X • Ancient Hymns';
      default:
        return book.description.length > 40
            ? '${book.description.substring(0, 37)}...'
            : book.description;
    }
  }

  Widget _buildExploreDeitiesSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explore Deities',
                  style: GoogleFonts.crimsonPro(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matteGold.withOpacity(0.9),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'See All',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.matteGold.withOpacity(0.6),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Consumer(
            builder: (context, ref, _) {
              final deitiesAsync = ref.watch(deitiesProvider);
              final deities = deitiesAsync.valueOrNull ?? [];
              final items = deities.isNotEmpty
                  ? deities.map((d) => (d.name, d.imageUrl ?? '')).toList()
                  : _deitiesFallback;
              return SizedBox(
                height: 130,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 32),
                  itemBuilder: (_, i) {
                    final (name, url) = items[i];
                    return _buildDeityCircle(name, url);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeityCircle(String name, String imageUrl) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.matteGold.withOpacity(0.8),
                    AppColors.matteGold.withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.matteGold.withOpacity(0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.manuscriptDark,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Icon(Icons.person,
                        color: AppColors.matteGold, size: 32),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.matteGold.withOpacity(0.8),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceLibrarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 2,
                color: AppColors.matteGold.withOpacity(0.3),
              ),
              const SizedBox(width: 12),
              Text(
                'Resource Library',
                style: GoogleFonts.crimsonPro(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.matteGold.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Consumer(
            builder: (context, ref, _) {
              final cardsAsync = ref.watch(resourceCardsProvider);
              final cards = cardsAsync.valueOrNull ?? [];
              final fallback = [
                ResourceCardModel(
                    id: '1',
                    title: 'Terminology',
                    subtitle: 'Sanskrit Glossary',
                    iconName: 'menu_book'),
                ResourceCardModel(
                    id: '2',
                    title: 'Pronunciation',
                    subtitle: 'Chanting Rules',
                    iconName: 'record_voice_over'),
              ];
              final items = cards.isNotEmpty ? cards : fallback;
              return Row(
                children: [
                  if (items.isNotEmpty)
                    Expanded(
                      child: _buildResourceCard(
                        icon: _iconFromName(items[0].iconName),
                        title: items[0].title,
                        subtitle: items[0].subtitle,
                      ),
                    ),
                  if (items.length > 1) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildResourceCard(
                        icon: _iconFromName(items[1].iconName),
                        title: items[1].title,
                        subtitle: items[1].subtitle,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A1A1A).withOpacity(0.6),
                const Color(0xFF0F0F0F).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.matteGold.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.matteGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.matteGold, size: 22),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.matteGold.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeepDiveSection() {
    return Consumer(
      builder: (context, ref, _) {
        final deepDiveAsync = ref.watch(deepDiveProvider);
        final articles = deepDiveAsync.valueOrNull ?? [];
        final article = articles.isNotEmpty
            ? articles.first
            : DeepDiveModel(
                id: '1',
                title: "The Nature of 'Atman'",
                quote:
                    '"The Self is not born, nor does it ever die... Unborn, eternal, ever-existing, and primeval."',
                durationLabel: '4 min read',
              );
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 48),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(32),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1A1A1A).withOpacity(0.6),
                      const Color(0xFF0F0F0F).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border(
                    top: BorderSide(
                        color: AppColors.matteGold.withOpacity(0.3), width: 2),
                    left:
                        BorderSide(color: AppColors.matteGold.withOpacity(0.1)),
                    right:
                        BorderSide(color: AppColors.matteGold.withOpacity(0.1)),
                    bottom:
                        BorderSide(color: AppColors.matteGold.withOpacity(0.1)),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(Icons.psychology,
                            size: 64, color: AppColors.matteGold),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.matteGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color:
                                        AppColors.matteGold.withOpacity(0.2)),
                              ),
                              child: Text(
                                'Deep Dive',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.matteGold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            Icon(Icons.share,
                                color: AppColors.matteGold.withOpacity(0.5),
                                size: 20),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          article.title,
                          style: GoogleFonts.crimsonPro(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.only(left: 16),
                          decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    color: AppColors.matteGold.withOpacity(0.2),
                                    width: 2)),
                          ),
                          child: Text(
                            article.quote,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF94A3B8),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.schedule,
                                    size: 16,
                                    color:
                                        AppColors.matteGold.withOpacity(0.4)),
                                const SizedBox(width: 8),
                                Text(
                                  article.durationLabel ?? '4 min read',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.matteGold.withOpacity(0.6),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.matteGold,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.matteGold.withOpacity(0.2),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Read Article',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _placeholderCover() {
    return Container(
      color: Colors.black,
      child: const Icon(Icons.menu_book, size: 48, color: AppColors.matteGold),
    );
  }
}
