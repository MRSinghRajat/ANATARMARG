import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/book_model.dart';
import '../providers/book_providers.dart';
import '../screens/book_detail_screen.dart';

/// Resume bar attached to bottom nav when Granthalaya tab is active.
class GranthalayaResumeBar extends ConsumerStatefulWidget {
  const GranthalayaResumeBar({super.key});

  @override
  ConsumerState<GranthalayaResumeBar> createState() =>
      _GranthalayaResumeBarState();
}

class _GranthalayaResumeBarState extends ConsumerState<GranthalayaResumeBar> {
  BookModel? _lastReadBook;

  static const _coverUrls = {
    'bhagavad_gita': 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
    'mahabharata': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    'ramayana': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
    'ramayan': 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
  };

  @override
  void initState() {
    super.initState();
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    final repo = ref.read(bookRepositoryProvider);
    try {
      final books = await repo.getAllBooks();
      if (mounted && books.isNotEmpty) {
        final sorted = List<BookModel>.from(books)
          ..sort((a, b) =>
              (b.lastReadAt ?? DateTime(0)).compareTo(a.lastReadAt ?? DateTime(0)));
        setState(() => _lastReadBook = sorted.first);
      } else if (mounted) {
        setState(() => _lastReadBook = null);
      }
    } catch (_) {
      if (mounted) {
        setState(() =>
            _lastReadBook = repo.allBooks.isNotEmpty ? repo.allBooks.first : null);
      }
    }
  }

  String? _getCoverUrl(BookModel book) {
    if (book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty) {
      return book.coverImageUrl;
    }
    return _coverUrls[book.id.toLowerCase()];
  }

  @override
  Widget build(BuildContext context) {
    final book = _lastReadBook;
    final coverUrl = book != null ? _getCoverUrl(book) : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoalCard.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.matteGold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 44,
                child: coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: coverUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                  book?.name ?? 'Hanuman Chalisa',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book != null)
                    Text(
                      '${(book.progress * 100).round()}% COMPLETED',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.matteGold,
                      ),
                    ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: book?.progress ?? 0.0,
                      minHeight: 4,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.matteGold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                if (book != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookDetailScreen(book: book)),
                  );
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.matteGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.black, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.charcoalDark,
      child: const Icon(Icons.menu_book, color: AppColors.warmOrange, size: 22),
    );
  }
}
