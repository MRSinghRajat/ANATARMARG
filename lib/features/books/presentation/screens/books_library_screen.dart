import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/banyan_tree_painter.dart';
import '../../data/models/book_model.dart';
import '../providers/book_providers.dart';
import 'book_detail_screen.dart';

/// Library screen - Sacred Epics styling with all books, progress, subtitles.
class BooksLibraryScreen extends ConsumerStatefulWidget {
  const BooksLibraryScreen({super.key});

  @override
  ConsumerState<BooksLibraryScreen> createState() => _BooksLibraryScreenState();
}

class _BooksLibraryScreenState extends ConsumerState<BooksLibraryScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _booksKey = GlobalKey();
  List<BookModel> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final bookRepository = ref.read(bookRepositoryProvider);
    try {
      final books = await bookRepository.getAllBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _books = bookRepository.allBooks;
        _isLoading = false;
      });
    }
  }

  String _getBookSubtitle(BookModel book) {
    switch (book.id.toLowerCase()) {
      case 'ramayana':
      case 'ramayan':
        return 'THE PATH OF DHARMA';
      case 'mahabharata':
        return 'THE GREAT WAR OF VIRTUE';
      case 'bhagavad_gita':
        return 'THE SONG OF GOD';
      default:
        return book.description.toUpperCase().length > 25
            ? '${book.description.substring(0, 22).toUpperCase()}...'
            : book.description.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNavBar(context),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.warmOrange,
                      ),
                    )
                  : SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildFeaturedSection(context),
                          const SizedBox(height: 24),
                          _buildBooksList(context),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardBackground,
            border: Border.all(color: AppColors.warmOrange.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: CustomPaint(
              painter: BanyanTreePainter(),
              size: const Size(200, 200),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Scrollable.ensureVisible(
                _booksKey.currentContext ?? context,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warmOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: AppColors.warmOrange.withOpacity(0.3),
            ),
            child: const Text(
              'DHARMIC LIBRARY',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Knowledge is the supreme path to liberation.\n'
          'Choose your guide to the eternal truth.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBooksList(BuildContext context) {
    return Column(
      key: _booksKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _books.map((book) => _buildBookCard(context, book)).toList(),
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primaryText, size: 24),
            onPressed: () {},
          ),
          const Text(
            'SACRED EPICS',
            style: TextStyle(
              color: AppColors.warmOrange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.warmOrange.withOpacity(0.2),
            child: const Icon(Icons.person, color: AppColors.warmOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, BookModel book) {
    final progressPercent = (book.progress * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailScreen(book: book),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildBookThumbnail(book),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getBookSubtitle(book),
                        style: const TextStyle(
                          color: AppColors.tertiaryText,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: book.progress,
                          minHeight: 6,
                          backgroundColor: AppColors.borderColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.warmOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$progressPercent% Completed',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailScreen(book: book),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Continue Learning'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warmOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: AppColors.warmOrange.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookThumbnail(BookModel book) {
    if (book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: book.coverImageUrl!,
        width: 80,
        height: 100,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _defaultThumbnail(),
      );
    }
    return _defaultThumbnail();
  }

  Widget _defaultThumbnail() {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightGreen.withOpacity(0.4),
            AppColors.earthBrown.withOpacity(0.3),
          ],
        ),
      ),
      child: const Icon(
        Icons.menu_book,
        color: AppColors.warmOrange,
        size: 36,
      ),
    );
  }
}
