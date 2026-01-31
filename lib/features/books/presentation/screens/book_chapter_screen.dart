import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/guide_animation_service.dart';
import '../../../../shared/services/avatar_growth_service.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/widgets/coin_earned_overlay.dart';
import '../../../../core/utils/coin_calculator.dart';
import '../../data/models/book_model.dart';
import '../../data/models/chapter_model.dart';
import '../../data/repositories/verse_repository.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../data/repositories/book_progress_repository.dart';
import '../../data/datasources/supabase_verse_datasource.dart'
    show VerseWithTranslations;
import '../../data/services/verse_notes_service.dart';
import '../../../content/data/datasources/gpt_api_service.dart';
import '../../../content/data/models/chapter_model.dart' show ChapterContent;
import '../widgets/books_chapters_modal.dart';
import 'book_chat_screen.dart';

class BookChapterScreen extends ConsumerStatefulWidget {
  final BookModel book;
  final ChapterModel? chapter;
  final int? chapterNumber;

  /// When navigating from prev chapter, start at this verse index (e.g. last verse)
  final int? initialVerseIndex;

  const BookChapterScreen({
    super.key,
    required this.book,
    this.chapter,
    this.chapterNumber,
    this.initialVerseIndex,
  });

  @override
  ConsumerState<BookChapterScreen> createState() => _BookChapterScreenState();
}

class _BookChapterScreenState extends ConsumerState<BookChapterScreen> {
  final GPTApiService _gptService = GPTApiService();
  final VerseRepository _verseRepository = VerseRepository();
  final ChapterRepository _chapterRepository = ChapterRepository();
  final VerseNotesService _notesService = VerseNotesService();
  final BookProgressRepository _progressRepository = BookProgressRepository();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _verseKeys = {};
  ChapterContent? _chapterContent;
  List<VerseWithTranslations> _verses = [];
  List<ChapterModel> _chapters = [];
  Set<String> _bookmarkedVerseIds = {};
  List<VerseNoteModel> _chapterNotes = [];
  String _selectedLanguage = 'en';
  int _currentVerseIndex = 0;
  int _selectedContentTab = 0; // 0: Chapter, 1: Notes
  bool _isLoading = true;
  bool _isLoadingVerses = false;
  bool _isCompleted = false;
  String? _loadError;
  final GlobalKey _completeButtonKey = GlobalKey();

  String get _chapterId =>
      widget.chapter?.id ?? 'bg_chapter_${widget.chapterNumber ?? 1}';
  int get _chapterNum =>
      widget.chapter?.chapterNumber ?? widget.chapterNumber ?? 1;
  String get _chapterDisplayName =>
      widget.chapter?.title ?? 'Chapter $_chapterNum';
  String get _translationLabel {
    switch (_selectedLanguage) {
      case 'en':
        return 'EN';
      case 'hi':
        return 'HI';
      case 'sa':
        return 'SA';
      default:
        return 'EN';
    }
  }

  String _getBookShortName() {
    switch (widget.book.id) {
      case 'bhagavad_gita':
      case 'geeta':
        return 'Gita';
      case 'mahabharata':
        return 'Mahabharat';
      case 'ramayan':
        return 'Ramayan';
      default:
        return widget.book.name;
    }
  }

  /// Remove redundant "Chapter X of Bhagavad Gita is titled..." from summary text
  String _stripChapterIntro(String text) {
    if (text.isEmpty) return text;
    final patterns = [
      RegExp(
        r'^Chapter\s+\d+\s+of\s+(?:the\s+)?(?:Bhagavad\s+)?Gita\s+is\s+titled\s+[\x27\x22][^\x27\x22]+[\x27\x22]\.?\s*',
        caseSensitive: false,
      ),
      RegExp(
        r'^Chapter\s+\d+\s+of\s+(?:the\s+)?(?:Bhagavad\s+)?Gita\s+\.\s*',
        caseSensitive: false,
      ),
      RegExp(
        r'^Chapter\s+\d+\s+of\s+(?:the\s+)?(?:Bhagavad\s+)?Gita\s+:\s*',
        caseSensitive: false,
      ),
    ];
    var result = text.trim();
    for (final p in patterns) {
      result = result.replaceFirst(p, '').trim();
    }
    return result.isEmpty ? text : result;
  }

  @override
  void initState() {
    super.initState();
    GuideAnimationService().setState(GuideState.speaking);
    _loadChapter();
    _loadBookmarksAndNotes();
  }

  Future<void> _loadChapters() async {
    try {
      final chapters =
          await _chapterRepository.getChaptersForBook(widget.book.id);
      if (mounted) setState(() => _chapters = chapters);
    } catch (_) {
      if (mounted) {
        setState(() => _chapters =
            _chapterRepository.getChaptersForBookSync(widget.book.id));
      }
    }
  }

  Future<void> _loadBookmarksAndNotes() async {
    var bookmarks = await _notesService.getBookmarkedVerseIds();
    final supabaseBookmarks = await _progressRepository.getBookmarkedVerseIds();
    if (supabaseBookmarks.isNotEmpty) {
      bookmarks = bookmarks.union(supabaseBookmarks);
    }
    final notes = await _notesService.getNotesForChapter(_chapterId);
    if (mounted) {
      setState(() {
        _bookmarkedVerseIds = bookmarks;
        _chapterNotes = notes;
      });
    }
  }

  @override
  void dispose() {
    if (_verses.isNotEmpty &&
        _currentVerseIndex >= 0 &&
        _currentVerseIndex < _verses.length) {
      _progressRepository.saveLastReadPosition(
        bookId: widget.book.id,
        chapterId: _chapterId,
        lastReadVerseId: _verses[_currentVerseIndex].verse.id,
      );
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChapter() async {
    setState(() => _isLoading = true);
    try {
      // Load chapters for prev/next navigation (in parallel with verses)
      if (_chapters.isEmpty) await _loadChapters();
      // Load verses FIRST (fast, from Supabase) - don't block on GPT
      await _loadVerses();
      setState(() => _isLoading = false);

      // Load chapter summary in background (DB or GPT) - for Notes/empty state
      _gptService
          .getChapterSummary(
        book: widget.book.name,
        chapterId: _chapterId,
      )
          .then((chapter) {
        if (mounted) {
          setState(() => _chapterContent = chapter);
        }
      }).catchError((e) {
        if (mounted) {
          setState(() => _chapterContent = ChapterContent(
                id: _chapterId,
                book: widget.book.name,
                chapterId: _chapterId,
                chapterNumber: _chapterNum.toString(),
                title: _chapterDisplayName,
                summary: '',
                estimatedReadingMinutes: 2,
                createdAt: DateTime.now(),
              ));
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chapter: $e')),
        );
      }
    }
  }

  Future<void> _loadVerses() async {
    setState(() {
      _isLoadingVerses = true;
      _loadError = null;
    });
    _verseKeys.clear();
    try {
      final verses =
          await _verseRepository.getVersesWithAllTranslations(_chapterId);
      var idx = widget.initialVerseIndex;
      if (idx == null || idx >= verses.length) {
        final lastReadVerseId =
            await _progressRepository.getLastReadVerseId(_chapterId);
        if (lastReadVerseId != null) {
          final found = verses.indexWhere((v) => v.verse.id == lastReadVerseId);
          if (found >= 0) idx = found;
        }
      }
      final int resolvedIdx = (idx != null && idx < verses.length) ? idx : 0;
      setState(() {
        _verses = verses;
        _isLoadingVerses = false;
        _loadError = null;
        _currentVerseIndex = resolvedIdx;
      });
      _loadBookmarksAndNotes();
      if (resolvedIdx > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToVerse(resolvedIdx);
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingVerses = false;
        _loadError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onLanguageChanged(String lang) {
    setState(() => _selectedLanguage = lang);
    // No need to refetch - we already have all translations, just update display
  }

  /// Get verse text for the selected language (default: English)
  String _getVerseTextForLanguage(VerseWithTranslations v) {
    switch (_selectedLanguage) {
      case 'hi':
        return v.hindiTranslation?.text ??
            v.englishTranslation?.text ??
            v.primaryTranslation?.text ??
            (v.translations.isNotEmpty ? v.translations.first.text : '');
      case 'sa':
        return v.primaryTranslation?.text ??
            v.getTranslation('sa')?.text ??
            v.hindiTranslation?.text ??
            v.englishTranslation?.text ??
            (v.translations.isNotEmpty ? v.translations.first.text : '');
      case 'en':
      default:
        return v.englishTranslation?.text ??
            v.primaryTranslation?.text ??
            (v.translations.isNotEmpty ? v.translations.first.text : '');
    }
  }

  Future<void> _toggleBookmark(String verseId) async {
    await _notesService.toggleBookmark(verseId);
    var bookmarks = await _notesService.getBookmarkedVerseIds();
    final isNowBookmarked = bookmarks.contains(verseId);
    await _progressRepository.setVerseBookmarked(verseId, isNowBookmarked);
    final supabaseBookmarks = await _progressRepository.getBookmarkedVerseIds();
    bookmarks = bookmarks.union(supabaseBookmarks);
    if (mounted) {
      setState(() => _bookmarkedVerseIds = bookmarks);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(isNowBookmarked ? 'Bookmarked' : 'Removed from bookmarks'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showVerseContextMenu(
    BuildContext context, {
    required String verseId,
    required String verseText,
    required int shlokaNum,
    required int totalShlokas,
    required VerseWithTranslations v,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Shloka $shlokaNum of $totalShlokas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warmOrange,
                  ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.note_add, color: AppColors.warmOrange),
              title: const Text('Notes'),
              subtitle: const Text('Add note to this shlok'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddNoteDialog(context, verseId, verseText, shlokaNum, v);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppColors.warmOrange),
              title: const Text('Copy'),
              subtitle: const Text('Copy shlok to clipboard'),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: verseText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppColors.warmOrange),
              title: const Text('Chat'),
              subtitle: const Text('Ask about this verse'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookChatScreen(
                      book: widget.book,
                      verseContext: verseText,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(
    BuildContext context,
    String verseId,
    String verseText,
    int shlokaNum,
    VerseWithTranslations v,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _AddNoteDialog(
        shlokaNum: shlokaNum,
        verseText: verseText,
        onSave: (note) async {
          await _notesService.addNote(VerseNoteModel(
            verseId: verseId,
            verseText: verseText,
            note: note,
            bookId: widget.book.id,
            chapterId: _chapterId,
            shlokaNumber: shlokaNum,
            createdAt: DateTime.now(),
          ));
          if (mounted) {
            await _loadBookmarksAndNotes();
            setState(() => _selectedContentTab = 1);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Note saved')),
            );
          }
        },
      ),
    );
  }

  ChapterModel? _getPrevChapter() {
    if (_chapters.isEmpty) return null;
    final idx = _chapters.indexWhere((c) => c.id == _chapterId);
    if (idx <= 0) return null;
    return _chapters[idx - 1];
  }

  ChapterModel? _getNextChapter() {
    if (_chapters.isEmpty) return null;
    final idx = _chapters.indexWhere((c) => c.id == _chapterId);
    if (idx < 0 || idx >= _chapters.length - 1) return null;
    return _chapters[idx + 1];
  }

  void _goToPrevChapter() async {
    final prev = _getPrevChapter();
    if (prev == null) return;
    final prevVerses =
        await _verseRepository.getVersesWithAllTranslations(prev.id);
    final lastIdx = prevVerses.isEmpty ? 0 : prevVerses.length - 1;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookChapterScreen(
          book: widget.book,
          chapter: prev,
          initialVerseIndex: lastIdx,
        ),
      ),
    );
  }

  void _goToNextChapter() async {
    final next = _getNextChapter();
    if (next == null) return;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BookChapterScreen(
          book: widget.book,
          chapter: next,
        ),
      ),
    );
  }

  void _scrollToVerse(int index) {
    if (_verses.isEmpty) return;
    if (!_scrollController.hasClients) return;
    // ListView.builder builds items lazily - item may not exist yet.
    // Use ScrollController with estimated card height (~220px avg).
    const double estimatedCardHeight = 220;
    final targetOffset = (index * estimatedCardHeight)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    // After scroll, try ensureVisible if the item is now built
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final verseId = _verses[index].verse.id;
      final key = _verseKeys[verseId];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );
      }
    });
  }

  Future<void> _completeChapter() async {
    if (_isCompleted) return;
    setState(() => _isCompleted = true);
    final verseIds = _verses.map((v) => v.verse.id).toList();
    await _progressRepository.completeChapter(
      bookId: widget.book.id,
      chapterId: _chapterId,
      verseIds: verseIds,
      completedChaptersCount: widget.book.completedChapters + 1,
      totalChapters: widget.book.totalChapters,
    );
    final coins = CoinCalculator.calculateReadingReward(true);
    await CoinService().addCoins(coins);
    await AvatarGrowthService().completeAction(
      wisdomGain: 1,
      karmaGain: 5,
      extendsStreak: true,
    );
    AvatarGrowthService().setAnimationState(GuideState.welcoming);
    if (mounted) {
      CoinEarnedOverlay.show(
        context,
        amount: coins,
        fromKey: _completeButtonKey,
      );
    }
    Future.delayed(const Duration(seconds: 2), () {
      GuideAnimationService().setState(GuideState.sitting);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF98D8C8),
              Color(0xFF90EE90),
            ],
            stops: [0.0, 0.4, 0.8],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMainContent(context),
              ),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  void _showBooksChaptersModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => BooksChaptersModal(
        currentBook: widget.book,
        currentChapter: widget.chapter,
        onChapterSelected: (book, chapter) {
          Navigator.pop(modalContext); // Close modal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BookChapterScreen(
                book: book,
                chapter: chapter,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bookShortName = _getBookShortName();
    final chapterButtonLabel = '$bookShortName Ch $_chapterNum';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Book/Chapter selector button (Gita Ch 2 / Mahabharat Ch X)
          Expanded(
            child: GestureDetector(
              onTap: _showBooksChaptersModal,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book,
                        color: AppColors.warmOrange, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chapterButtonLabel,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.tertiaryText),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Language selector (EN/HI/SA)
          GestureDetector(
            onTap: () => _showLanguageSelector(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _translationLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmOrange,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Settings gear
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings')),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.settings, color: AppColors.tertiaryText),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Translation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(context, 'en', 'English'),
            _buildLanguageOption(context, 'hi', 'Hindi'),
            _buildLanguageOption(context, 'sa', 'Sanskrit'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String code, String label) {
    final isSelected = _selectedLanguage == code;
    return ListTile(
      leading: Icon(
        Icons.translate,
        color: isSelected ? AppColors.warmOrange : AppColors.tertiaryText,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.warmOrange : AppColors.primaryText,
        ),
      ),
      onTap: () {
        _onLanguageChanged(code);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.lightYellow.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildContentTabs(context),
          Expanded(
            child: _selectedContentTab == 0
                ? _buildChapterTab(context)
                : _buildNotesTab(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTabs(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildContentTab(0, 'Chapter', Icons.menu_book),
          _buildContentTab(1, 'Notes', Icons.note),
        ],
      ),
    );
  }

  Widget _buildContentTab(int index, String label, IconData icon) {
    final isSelected = _selectedContentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          if (index == 1) await _loadBookmarksAndNotes();
          setState(() => _selectedContentTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.warmOrange.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color:
                    isSelected ? AppColors.warmOrange : AppColors.tertiaryText,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.warmOrange
                      : AppColors.tertiaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterTab(BuildContext context) {
    if (_isLoadingVerses) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_verses.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_loadError != null) ...[
              const Icon(Icons.cloud_off, size: 48, color: AppColors.tertiaryText),
              const SizedBox(height: 16),
              Text(
                _loadError!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Query: verses WHERE chapter_id=\'$_chapterId\' then verse_translations',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.tertiaryText,
                      fontFamily: 'monospace',
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isLoadingVerses ? null : _loadVerses,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              const SizedBox(height: 24),
            ],
            if (_chapterContent != null &&
                _chapterContent!.summary.isNotEmpty) ...[
              Text(
                _stripChapterIntro(_chapterContent!.summary),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
            ],
            Text(
              _loadError != null
                  ? 'Verses could not be loaded.'
                  : 'No verses in database for this chapter.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.tertiaryText,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Run SUPABASE_BOOKS_SCHEMA.sql, SUPABASE_GITA_DATA.sql and SUPABASE_GITA_TRANSLATIONS.sql in your Supabase SQL Editor.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.tertiaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Shloka dropdown - jump to any shloka
        if (_verses.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<int>(
              initialValue: _currentVerseIndex.clamp(0, _verses.length - 1),
              decoration: InputDecoration(
                labelText: 'Jump to Shloka',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: List.generate(_verses.length, (i) {
                final num = i + 1;
                return DropdownMenuItem(
                  value: i,
                  child: Text('Shloka $num'),
                );
              }),
              onChanged: (index) {
                if (index != null) {
                  setState(() => _currentVerseIndex = index);
                  _scrollToVerse(index);
                }
              },
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: _verses.length,
            itemBuilder: (context, index) {
              final v = _verses[index];
              final shlokaNum = index + 1;
              final totalShlokas = _verses.length;
              final verseId = v.verse.id;

              // Get text for selected language (default: English)
              final displayText = _getVerseTextForLanguage(v);
              final verseTextForCopy = displayText;

              // Use verse.id for unique keys (avoids duplicate GlobalKeys)
              _verseKeys[verseId] ??= GlobalKey();

              final isBookmarked = _bookmarkedVerseIds.contains(verseId);
              final verseNotes =
                  _chapterNotes.where((n) => n.verseId == verseId).toList();

              return GestureDetector(
                key: _verseKeys[verseId],
                onLongPress: () => _showVerseContextMenu(
                  context,
                  verseId: verseId,
                  verseText: verseTextForCopy,
                  shlokaNum: shlokaNum,
                  totalShlokas: totalShlokas,
                  v: v,
                ),
                child: Container(
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
                      // Shloka number + bookmark
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$shlokaNum',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warmOrange,
                                ),
                          ),
                          GestureDetector(
                            onTap: () => _toggleBookmark(verseId),
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isBookmarked
                                  ? AppColors.warmOrange
                                  : AppColors.tertiaryText,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Show verse in selected language (default: English)
                      Text(
                        displayText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.primaryText,
                              height: 1.5,
                              fontStyle: _selectedLanguage == 'en'
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              fontSize: _selectedLanguage == 'sa' ? 18 : 16,
                            ),
                      ),
                      // Note hint at bottom when this shlok has notes
                      if (verseNotes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.warmOrange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.warmOrange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.note,
                                size: 18,
                                color: AppColors.warmOrange,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  verseNotes.first.note,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.secondaryText,
                                        fontStyle: FontStyle.italic,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotesTab(BuildContext context) {
    if (_chapterNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_add, size: 64, color: AppColors.tertiaryText),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Long-press a shlok and tap Notes to add a note',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.tertiaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chapterNotes.length,
      itemBuilder: (context, index) {
        final note = _chapterNotes[index];
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
                    'Shloka ${note.shlokaNumber}',
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
                      if (mounted) await _loadBookmarksAndNotes();
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
                    const Icon(Icons.comment, size: 18, color: AppColors.warmOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.note,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Complete button
          GestureDetector(
            onTap: _isCompleted ? null : _completeChapter,
            child: Container(
              key: _completeButtonKey,
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _isCompleted
                    ? AppColors.successColor.withOpacity(0.5)
                    : AppColors.successColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.successColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isCompleted ? Icons.check : Icons.check,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          // Prev/Next arrows - move between chapters
          Row(
            children: [
              _buildNavButton(
                icon: Icons.arrow_back_ios_new,
                onTap: _goToPrevChapter,
              ),
              const SizedBox(width: 16),
              _buildNavButton(
                icon: Icons.arrow_forward_ios,
                onTap: _goToNextChapter,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.primaryText),
      ),
    );
  }
}

/// Dialog for adding a note - manages TextEditingController lifecycle properly
class _AddNoteDialog extends StatefulWidget {
  final int shlokaNum;
  final String verseText;
  final void Function(String note) onSave;

  const _AddNoteDialog({
    required this.shlokaNum,
    required this.verseText,
    required this.onSave,
  });

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Note - Shloka ${widget.shlokaNum}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.verseText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Add your note or comment...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final note = _controller.text.trim();
            if (note.isEmpty) return;
            Navigator.pop(context); // Close dialog first, then save
            widget.onSave(note);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

