import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/bookmarked_items_service.dart';
import '../screens/bookmarked_notes_screen.dart';

/// Bookmarks & Notes section for Profile. Shows preview and "See all" to full screen.
class BookmarkedSection extends StatefulWidget {
  const BookmarkedSection({super.key});

  @override
  State<BookmarkedSection> createState() => _BookmarkedSectionState();
}

class _BookmarkedSectionState extends State<BookmarkedSection> {
  final BookmarkedItemsService _service = BookmarkedItemsService();
  List<BookmarkedVerseItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    try {
      final items = await _service.getBookmarkedItems();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoalCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.charcoalBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bookmark, color: AppColors.matteGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bookmarks & Notes',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookmarkedNotesScreen(),
                    ),
                  ).then((_) => _loadBookmarks());
                },
                child: Text(
                  'See All',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.matteGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.matteGold,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No bookmarks yet. Tap the bookmark icon while reading verses, sacred texts or stories to save them. Tap "See All" to view notes too.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.zinc500,
                  height: 1.4,
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _items.take(3).map<Widget>((bv) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.matteGold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bv.book.name,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Chapter ${bv.chapter.chapterNumber}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.zinc500,
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
        ],
      ),
    );
  }
}
