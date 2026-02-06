import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/bookmarked_items_service.dart';
import '../../../books/presentation/screens/book_chapter_screen.dart';
import '../../../books/presentation/screens/book_detail_screen.dart';
import '../../../books/data/models/book_model.dart';

/// Bookmarked section for Profile - Granthalaya black theme, books + verses.
class BookmarkedSection extends StatefulWidget {
  const BookmarkedSection({super.key});

  @override
  State<BookmarkedSection> createState() => _BookmarkedSectionState();
}

class _BookmarkedSectionState extends State<BookmarkedSection> {
  final BookmarkedItemsService _service = BookmarkedItemsService();
  List<BookmarkedVerseItem> _items = [];
  Map<BookModel, int> _booksWithBookmarks = {};
  bool _isLoading = true;

  static const _coverUrls = {
    'bhagavad_gita': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
    'mahabharata': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    'ramayana': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
    'ramayan': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final items = await _service.getBookmarkedItems();
      final books = await _service.getBooksWithBookmarks();
      if (mounted) {
        setState(() {
          _items = items;
          _booksWithBookmarks = books;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _getCoverUrl(BookModel book) {
    if (book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty) {
      return book.coverImageUrl;
    }
    return _coverUrls[book.id.toLowerCase()];
  }

  String _bookSubtitle(BookModel book) {
    switch (book.id.toLowerCase()) {
      case 'ramayana':
      case 'ramayan':
        return 'The Journey';
      case 'mahabharata':
        return 'Epic Conflict';
      case 'bhagavad_gita':
        return 'Divine Song';
      default:
        return book.description.length > 30
            ? '${book.description.substring(0, 27)}...'
            : book.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.charcoalCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.charcoalBorder),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.warmOrange),
        ),
      );
    }

    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.charcoalCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.charcoalBorder),
        ),
        child: Column(
          children: [
            const Icon(Icons.bookmark_border, size: 48, color: AppColors.zinc500),
            const SizedBox(height: 12),
            Text(
              'No bookmarks yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bookmark verses while reading to see them here',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.zinc500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.charcoalDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.charcoalBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                const Icon(Icons.bookmark, color: AppColors.warmOrange, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Bookmarks',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (_booksWithBookmarks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'BOOKS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.zinc500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _booksWithBookmarks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, i) {
                  final entry = _booksWithBookmarks.entries.elementAt(i);
                  final book = entry.key;
                  final count = entry.value;
                  return _BookCard(
                    book: book,
                    bookmarkCount: count,
                    coverUrl: _getCoverUrl(book),
                    subtitle: _bookSubtitle(book),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailScreen(book: book),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'YOUR VERSES',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppColors.zinc500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: _items.take(10).map((item) => _VerseCard(item: item)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookModel book;
  final int bookmarkCount;
  final String? coverUrl;
  final String subtitle;
  final VoidCallback onTap;

  const _BookCard({
    required this.book,
    required this.bookmarkCount,
    required this.coverUrl,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: coverUrl != null
                        ? CachedNetworkImage(
                            imageUrl: coverUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warmOrange,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$bookmarkCount',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.name,
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.zinc500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.charcoalCard,
      child: const Icon(
        Icons.menu_book,
        size: 40,
        color: AppColors.warmOrange,
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  final BookmarkedVerseItem item;

  const _VerseCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookChapterScreen(
              book: item.book,
              chapter: item.chapter,
              initialVerseIndex: (item.verse.verseNumber - 1).clamp(0, 999),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.charcoalCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.charcoalBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.warmOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.format_quote,
                color: AppColors.warmOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.book.name} • Ch.${item.chapter.chapterNumber}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warmOrange,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Shloka ${item.verse.verseNumberDisplay}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.zinc500, size: 22),
          ],
        ),
      ),
    );
  }
}
