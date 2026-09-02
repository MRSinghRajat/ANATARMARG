import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../data/models/chapter_model.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../data/services/verse_notes_service.dart';

/// Shows verse notes (shlok copy + user comment) for the book.
/// Notes are user-authored; there is no `title_hindi` on this surface (AM-62).
class BookNotesScreen extends ConsumerStatefulWidget {
  final BookModel book;

  const BookNotesScreen({
    super.key,
    required this.book,
  });

  @override
  ConsumerState<BookNotesScreen> createState() => _BookNotesScreenState();
}

class _BookNotesScreenState extends ConsumerState<BookNotesScreen> {
  final VerseNotesService _notesService = VerseNotesService();
  final ChapterRepository _chapterRepository = ChapterRepository();
  List<VerseNoteModel> _notes = [];
  Map<String, ChapterModel> _chapterById = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await _notesService.getNotesForBook(widget.book.id);
    final chapters = await _chapterRepository.getChaptersForBook(widget.book.id);
    final chapterMap = {for (final c in chapters) c.id: c};
    if (mounted) {
      setState(() {
        _notes = notes;
        _chapterById = chapterMap;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_outlined,
              size: 64,
              color: AppColors.tertiaryText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Long-press a shlok in a chapter and tap Notes to add a note',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _chapterById[note.chapterId] != null
                          ? '${_chapterById[note.chapterId]!.displayTitle} • Shloka ${note.shlokaNumber}'
                          : 'Shloka ${note.shlokaNumber}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warmOrange,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: AppColors.tertiaryText,
                      onPressed: () async {
                        await _notesService.removeNote(note.verseId, note.note);
                        if (mounted) await _loadNotes();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.verseText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.primaryText,
                      ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warmOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.comment,
                          size: 18, color: AppColors.warmOrange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          note.note,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primaryText,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
