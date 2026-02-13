import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../data/models/chapter_model.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../data/repositories/book_progress_repository.dart';

/// Books & Chapters bottom sheet - like the reference UI
/// Shows all books, expandable to chapters. Tap chapter to open.
/// Chapters are locked until previous is completed; premium users can open any.
class BooksChaptersModal extends StatefulWidget {
  final BookModel currentBook;
  final ChapterModel? currentChapter;
  final Function(BookModel book, ChapterModel chapter) onChapterSelected;
  /// If true, all chapters are tappable. If false, only completed + next are tappable.
  final bool isPremium;

  const BooksChaptersModal({
    super.key,
    required this.currentBook,
    this.currentChapter,
    required this.onChapterSelected,
    this.isPremium = false,
  });

  @override
  State<BooksChaptersModal> createState() => _BooksChaptersModalState();
}

class _BooksChaptersModalState extends State<BooksChaptersModal> {
  final BookRepository _bookRepo = BookRepository();
  final ChapterRepository _chapterRepo = ChapterRepository();
  final BookProgressRepository _progressRepo = BookProgressRepository();
  List<BookModel> _books = [];
  final Map<String, List<ChapterModel>> _chaptersByBook = {};
  final Map<String, int> _completedChaptersByBook = {};
  String _searchQuery = '';
  String? _expandedBookId;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await _bookRepo.getAllBooks();
    setState(() => _books = books);
  }

  Future<void> _loadChaptersForBook(String bookId) async {
    if (_chaptersByBook.containsKey(bookId)) return;
    final chapters = await _chapterRepo.getChaptersForBook(bookId);
    final progress = await _progressRepo.getBookProgress(bookId);
    final completed = (progress?['completed_chapters'] as int?) ?? 0;
    if (mounted) {
      setState(() {
        _chaptersByBook[bookId] = chapters;
        _completedChaptersByBook[bookId] = completed;
      });
    }
  }

  String _getBookShortName(BookModel book) {
    switch (book.id) {
      case 'bhagavad_gita':
      case 'geeta':
        return 'Gita';
      case 'mahabharata':
        return 'Mahabharat';
      case 'ramayan':
        return 'Ramayan';
      default:
        return book.name;
    }
  }

  List<BookModel> get _filteredBooks {
    if (_searchQuery.isEmpty) return _books;
    return _books
        .where((b) =>
            b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            _getBookShortName(b)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F0E6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.sort_by_alpha,
                    color: AppColors.warmOrange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Books & Chapters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: AppColors.warmOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.tertiaryText),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Book & Chapter list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: _filteredBooks.length,
              itemBuilder: (context, index) {
                final book = _filteredBooks[index];
                final isExpanded = _expandedBookId == book.id;
                final chapters = _chaptersByBook[book.id] ?? [];
                return _BookChapterTile(
                  book: book,
                  index: index + 1,
                  shortName: _getBookShortName(book),
                  isExpanded: isExpanded,
                  chapters: chapters,
                  completedChapters: _completedChaptersByBook[book.id] ?? 0,
                  isPremium: widget.isPremium,
                  currentBook: widget.currentBook,
                  currentChapter: widget.currentChapter,
                  onTap: () async {
                    if (isExpanded) {
                      setState(() => _expandedBookId = null);
                    } else {
                      await _loadChaptersForBook(book.id);
                      setState(() => _expandedBookId = book.id);
                    }
                  },
                  onChapterTap: (chapter) {
                    widget.onChapterSelected(book, chapter);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookChapterTile extends StatelessWidget {
  final BookModel book;
  final int index;
  final String shortName;
  final bool isExpanded;
  final List<ChapterModel> chapters;
  final int completedChapters;
  final bool isPremium;
  final BookModel currentBook;
  final ChapterModel? currentChapter;
  final VoidCallback onTap;
  final Function(ChapterModel) onChapterTap;

  const _BookChapterTile({
    required this.book,
    required this.index,
    required this.shortName,
    required this.isExpanded,
    required this.chapters,
    required this.completedChapters,
    required this.isPremium,
    required this.currentBook,
    this.currentChapter,
    required this.onTap,
    required this.onChapterTap,
  });

  /// Chapter at index i is unlocked if premium or i <= completedChapters (ch 0 always unlocked).
  bool _isChapterUnlocked(int chapterIndex) {
    if (isPremium) return true;
    return chapterIndex <= completedChapters;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Text(
            '$index.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.tertiaryText,
                ),
          ),
          title: Text(
            book.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: AppColors.tertiaryText,
          ),
          onTap: onTap,
        ),
        if (isExpanded && chapters.isNotEmpty)
          ...chapters.asMap().entries.map((entry) {
            final chapterIndex = entry.key;
            final chapter = entry.value;
            final isSelected =
                currentBook.id == book.id && currentChapter?.id == chapter.id;
            final unlocked = _isChapterUnlocked(chapterIndex);
            return Padding(
              padding: const EdgeInsets.only(left: 24, right: 16, bottom: 4),
              child: ListTile(
                leading: Icon(
                  unlocked ? Icons.menu_book : Icons.lock_outline,
                  size: 20,
                  color: isSelected
                      ? AppColors.warmOrange
                      : (unlocked
                          ? AppColors.tertiaryText
                          : AppColors.tertiaryText.withOpacity(0.6)),
                ),
                title: Text(
                  chapter.displayTitle,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppColors.warmOrange
                        : (unlocked
                            ? AppColors.primaryText
                            : AppColors.primaryText.withOpacity(0.6)),
                  ),
                ),
                trailing: unlocked
                    ? const Icon(Icons.chevron_right, size: 20)
                    : Icon(
                        Icons.lock,
                        size: 18,
                        color: Colors.grey.shade500,
                      ),
                onTap: () {
                  if (unlocked) {
                    onChapterTap(chapter);
                  } else {
                    // Optional: show snackbar
                  }
                },
              ),
            );
          }),
        const Divider(height: 1),
      ],
    );
  }
}
