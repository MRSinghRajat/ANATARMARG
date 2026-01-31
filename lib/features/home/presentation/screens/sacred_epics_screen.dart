import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/banyan_tree_painter.dart';
import '../../../books/data/models/book_model.dart';
import '../../../books/data/repositories/book_repository.dart';
import '../../../books/presentation/screens/book_detail_screen.dart';

/// Sacred Epics screen - replicates the reference UI exactly:
/// Top nav (hamburger, SACRED EPICS, profile), featured banyan tree,
/// DHARMIC LIBRARY button, quote, and book cards with progress.
class SacredEpicsScreen extends ConsumerStatefulWidget {
  const SacredEpicsScreen({super.key});

  @override
  ConsumerState<SacredEpicsScreen> createState() => _SacredEpicsScreenState();
}

class _SacredEpicsScreenState extends ConsumerState<SacredEpicsScreen> {
  final BookRepository _bookRepository = BookRepository();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _booksKey = GlobalKey();
  List<BookModel> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final books = await _bookRepository.getAllBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _books = _bookRepository.allBooks;
        _isLoading = false;
      });
    }
  }

  /// Subtitle mapping for books (reference: Ramayana, Mahabharata)
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
      backgroundColor: const Color(0xFF1A1612),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNavBar(context),
            Expanded(
              child: SingleChildScrollView(
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

  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 24),
            onPressed: () {
              // TODO: Open drawer/side menu
            },
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
            backgroundColor: AppColors.warmOrange.withOpacity(0.3),
            child: const Icon(Icons.person, color: AppColors.warmOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context) {
    return Column(
      children: [
        // Circular banyan tree graphic
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.warmOrange, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.warmOrange.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 2,
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
        // DHARMIC LIBRARY button
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
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
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
        // Quote
        Text(
          'Knowledge is the supreme path to liberation.\n'
          'Choose your guide to the eternal truth.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBooksList(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.warmOrange),
        ),
      );
    }

    return Column(
      key: _booksKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _books.map((book) => _buildBookCard(context, book)).toList(),
    );
  }

  Widget _buildBookCard(BuildContext context, BookModel book) {
    final progressPercent = (book.progress * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2520),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warmOrange.withOpacity(0.3)),
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
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildBookThumbnail(book),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: const TextStyle(
                          color: AppColors.warmOrange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getBookSubtitle(book),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: book.progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade700,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.warmOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$progressPercent% Completed',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // CONTINUE LEARNING button
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
                          label: const Text('CONTINUE LEARNING'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warmOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
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
      return Image.network(
        book.coverImageUrl!,
        width: 80,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultThumbnail(),
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
            const Color(0xFF2D5016),
            AppColors.earthBrown.withOpacity(0.6),
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
