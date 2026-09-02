import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/guide_animation_service.dart';
import '../../../../shared/services/avatar_growth_service.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../core/utils/profile_pro_upgrade_nav.dart';
import '../../../../shared/widgets/coin_earned_overlay.dart';
import '../../../../shared/widgets/pro_gradient_badge.dart';
import '../../../../core/utils/coin_calculator.dart';
import '../../data/models/book_model.dart';
import '../../data/models/chapter_model.dart';
import '../../data/repositories/verse_repository.dart';
import '../../data/repositories/chapter_repository.dart';
import '../../data/repositories/book_progress_repository.dart';
import '../../data/datasources/supabase_verse_datasource.dart'
    show VerseWithTranslations;
import '../../data/services/verse_notes_service.dart';
import '../../data/services/reader_preferences_service.dart';
import '../../../content/data/models/chapter_model.dart' show ChapterContent;
import '../widgets/books_chapters_modal.dart';
import '../widgets/reader_settings_modal.dart';

/// Shlok Reader dark theme colors (from HTML design)
class _ShlokReaderColors {
  static const Color primary = Color(0xFFF59E0B); // Saffron Amber
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF161616);
  static const Color obsidianGreen = Color(0xFF0D1F1A);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
}

/// Gita / scripture chapter reader.
/// Verse body shows Hindi and English together on purpose (AM-58) — there is no
/// `_showHindi` toggle here. See `docs/LOCALIZATION.md`.
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

class _BookChapterScreenState extends ConsumerState<BookChapterScreen>
    with SingleTickerProviderStateMixin {
  final VerseRepository _verseRepository = VerseRepository();
  final ChapterRepository _chapterRepository = ChapterRepository();
  final VerseNotesService _notesService = VerseNotesService();
  final ReaderPreferencesService _prefsService = ReaderPreferencesService();
  final BookProgressRepository _progressRepository = BookProgressRepository();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  ChapterContent? _chapterContent;
  List<VerseWithTranslations> _verses = [];
  List<ChapterModel> _chapters = [];
  Set<String> _readVerseIds = {};
  List<VerseNoteModel> _chapterNotes = [];

  int _currentVerseIndex = 0;
  
  // Reader Settings State
  double _fontSize = 18.0;
  ReaderTheme _readerTheme = ReaderTheme.paper;
  ReaderFont _readerFont = ReaderFont.serif;
  ReaderLayout _readerLayout = ReaderLayout.card;
  Set<String> _bookmarkedVerseIds = {};
  bool _isLoading = true;
  bool _isLoadingVerses = false;
  bool _isCompleted = false;
  String? _loadError;
  final GlobalKey _completeButtonKey = GlobalKey();
  late AnimationController _glowController;
  bool _isPremium = false;
  StreamSubscription<bool>? _premiumSubscription;

  String get _chapterId =>
      widget.chapter?.id ?? 'bg_chapter_${widget.chapterNumber ?? 1}';
  int get _chapterNum =>
      widget.chapter?.chapterNumber ?? widget.chapterNumber ?? 1;
  String get _chapterDisplayName =>
      widget.chapter?.title ?? 'Chapter $_chapterNum';
  // AM-58: verse body always shows Hindi + English. Not a catalog switch. See docs/LOCALIZATION.md.

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
    _itemPositionsListener.itemPositions.addListener(_onItemPositionsChanged);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    GuideAnimationService().setState(GuideState.speaking);
    PremiumService.instance.isPremium.then((v) {
      if (mounted) setState(() => _isPremium = v);
    });
    _premiumSubscription = PremiumService.instance.premiumStatusStream.listen((v) {
      if (mounted) setState(() => _isPremium = v);
    });
    _loadPreferences();
    _loadChapter();
    _loadBookmarksAndNotes();
  }

  /// Track which verse is most visible using [ScrollablePositionedList] geometry.
  void _onItemPositionsChanged() {
    if (_verses.isEmpty || !mounted) return;
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    // Prefer verse whose vertical center is nearest upper third of viewport (readable).
    const targetMid = 0.28;
    int? best;
    double bestDist = double.infinity;
    for (final p in positions) {
      if (p.index <= 0) continue;
      final verseIdx = p.index - 1;
      if (verseIdx < 0 || verseIdx >= _verses.length) continue;
      final mid = (p.itemLeadingEdge + p.itemTrailingEdge) / 2;
      final d = (mid - targetMid).abs();
      if (d < bestDist) {
        bestDist = d;
        best = verseIdx;
      }
    }
    if (best != null && best != _currentVerseIndex) {
      setState(() => _currentVerseIndex = best!);
    }
  }

  Future<void> _loadPreferences() async {
    final fontSize = await _prefsService.loadFontSize();
    final theme = await _prefsService.loadTheme();
    final font = await _prefsService.loadFont();
    final layout = await _prefsService.loadLayout();
    if (mounted) {
      setState(() {
        _fontSize = fontSize;
        _readerTheme = theme;
        _readerFont = font;
        _readerLayout = layout;
      });
    }
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
    final notes = await _notesService.getNotesForChapter(_chapterId);
    final readVerses = await _progressRepository.getReadVerseIds(_chapterId);
    final bookmarks = await _notesService.getBookmarkedVerseIds();
    if (mounted) {
      setState(() {
        _readVerseIds = readVerses;
        _chapterNotes = notes;
        _bookmarkedVerseIds = bookmarks;
      });
    }
  }

  @override
  void dispose() {
    _premiumSubscription?.cancel();
    _itemPositionsListener.itemPositions.removeListener(_onItemPositionsChanged);
    _glowController.dispose();
    if (_verses.isNotEmpty &&
        _currentVerseIndex >= 0 &&
        _currentVerseIndex < _verses.length) {
      _progressRepository.saveLastReadPosition(
        bookId: widget.book.id,
        chapterId: _chapterId,
        lastReadVerseId: _verses[_currentVerseIndex].verse.id,
        bookNameForReminder: widget.book.name,
      );
    }
    super.dispose();
  }

  Future<void> _loadChapter() async {
    setState(() => _isLoading = true);
    try {
      // Load chapters for prev/next navigation (in parallel with verses)
      if (_chapters.isEmpty) await _loadChapters();
      // Load verses from Supabase only (no API calls)
      await _loadVerses();
      setState(() => _isLoading = false);
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
    try {
      final verses =
          await _verseRepository.getVersesWithAllTranslations(_chapterId);
      final readIds = await _progressRepository.getReadVerseIds(_chapterId);
      var idx = widget.initialVerseIndex;
      if (idx == null || idx >= verses.length) {
        final lastReadVerseId =
            await _progressRepository.getLastReadVerseId(_chapterId);
        if (lastReadVerseId != null) {
          final found = verses.indexWhere((v) => v.verse.id == lastReadVerseId);
          if (found >= 0) idx = found;
        }
      }
      int resolvedIdx = (idx != null && idx < verses.length) ? idx : 0;
      setState(() {
        _verses = verses;
        _readVerseIds = readIds;
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

  Future<void> _toggleReadStatus(String verseId) async {
    final isRead = !_readVerseIds.contains(verseId);
    setState(() {
      if (isRead) {
        _readVerseIds.add(verseId);
      } else {
        _readVerseIds.remove(verseId);
      }
    });

    try {
      if (isRead) {
        await _progressRepository.markVerseRead(
          verseId: verseId,
          chapterId: _chapterId,
          bookId: widget.book.id,
          completedVersesCount: _readVerseIds.length,
          totalVerses: _verses.length,
        );
      } else {
        // TODO: Implement unmark as read in repository if needed
        // For now we only support marking as read as per requirements
        // But local state update allows toggling for current session
      }
      
      // Auto-complete chapter if all verses read
      if (isRead && _readVerseIds.length == _verses.length && !_isCompleted) {
         _completeChapter();
      }
    } catch (e) {
      // Revert optimization on error
      if (mounted) {
        setState(() {
          if (isRead) {
             _readVerseIds.remove(verseId);
          } else {
             _readVerseIds.add(verseId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating progress: $e')),
        );
      }
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
    final isBookmarked = _bookmarkedVerseIds.contains(verseId);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: _goldAccent.withValues(alpha: 0.2)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Verse $shlokaNum of $totalShlokas',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _goldAccent,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            // Action grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildContextAction(
                  icon: Icons.note_add_rounded,
                  label: 'Note',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddNoteDialog(context, verseId, verseText, shlokaNum, v);
                  },
                ),
                _buildContextAction(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  label: isBookmarked ? 'Saved' : 'Save',
                  isActive: isBookmarked,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _notesService.toggleBookmark(verseId);
                    await _loadBookmarksAndNotes();
                  },
                ),
                _buildContextAction(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: () {
                    Navigator.pop(ctx);
                    final shareText = '${widget.book.name} - $_chapterDisplayName, Verse $shlokaNum\n\n$verseText\n\n— via Antar मार्ग';
                    Share.share(shareText);
                  },
                ),
                _buildContextAction(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onTap: () {
                    Navigator.pop(ctx);
                    Clipboard.setData(ClipboardData(text: verseText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Copied to clipboard'),
                        backgroundColor: const Color(0xFF1A1A1A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? _goldAccent.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? _goldAccent.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? _goldAccent : Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isActive ? _goldAccent : Colors.white.withValues(alpha: 0.5),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Note saved'),
                backgroundColor: const Color(0xFF1A1A1A),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
    if (_verses.isEmpty || index < 0 || index >= _verses.length) return;
    final listIndex = index + 1;

    void scroll() {
      if (!_itemScrollController.isAttached) return;
      _itemScrollController.scrollTo(
        index: listIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
        alignment: 0.1,
      );
      if (mounted) setState(() => _currentVerseIndex = index);
    }

    if (_itemScrollController.isAttached) {
      scroll();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_itemScrollController.isAttached) {
          scroll();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) scroll();
          });
        }
      });
    }
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
      backgroundColor: _ShlokReaderColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _ShlokReaderColors.primary,
                      ),
                    )
                  : _buildMainContent(context),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
      floatingActionButton: _verses.isNotEmpty && !_isLoading
          ? _buildFab(context)
          : null,
    );
  }

  bool get _isGitaBook =>
      widget.book.id == 'bhagavad_gita' || widget.book.id == 'geeta';

  void _showBooksChaptersModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => BooksChaptersModal(
        currentBook: widget.book,
        currentChapter: widget.chapter,
        isPremium: _isPremium,
        restrictToCurrentBook: _isGitaBook,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _ShlokReaderColors.zinc900.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Back',
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _ShlokReaderColors.zinc800,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Icon(Icons.arrow_back, color: Colors.grey.shade300, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Chapter selector pill
          Expanded(
            child: Semantics(
              button: true,
              label: 'Select Chapter',
              child: GestureDetector(
                onTap: _showBooksChaptersModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        color: _ShlokReaderColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chapterButtonLabel,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Verse grid picker (when verses loaded)
          if (_verses.isNotEmpty)
            Semantics(
              button: true,
              label: 'Select verse',
              child: GestureDetector(
                onTap: () => _showVerseGridPicker(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _ShlokReaderColors.zinc800,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Icon(Icons.grid_view, color: Colors.grey.shade300, size: 22),
                ),
              ),
            ),
          if (_verses.isNotEmpty) const SizedBox(width: 8),
          // Settings
          Semantics(
            button: true,
            label: 'Settings',
            child: GestureDetector(
              onTap: () => _showSettingsModal(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _ShlokReaderColors.zinc800,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Icon(Icons.settings, color: Colors.grey.shade300, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVerseGridPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _ShlokReaderColors.surfaceDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Verse',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: Icon(Icons.close, color: Colors.grey.shade300),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$_chapterDisplayName • ${_verses.length} verses',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _verses.length,
                itemBuilder: (context, index) {
                  final verseNum = index + 1;
                  final isCurrent = index == _currentVerseIndex;
                  final isRead = _readVerseIds.contains(_verses[index].verse.id);
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _scrollToVerse(index);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? _ShlokReaderColors.primary.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent
                              ? _ShlokReaderColors.primary
                              : Colors.white.withValues(alpha: 0.1),
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$verseNum',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isCurrent
                                  ? _ShlokReaderColors.primary
                                  : Colors.white,
                            ),
                          ),
                          if (isRead)
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: AppColors.successColor.withValues(alpha: 0.8),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseProgressBar(BuildContext context) {
    if (_verses.isEmpty) return const SizedBox.shrink();
    final progress = (_currentVerseIndex + 1) / _verses.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  _ShlokReaderColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Verse ${_currentVerseIndex + 1} of ${_verses.length}',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _ShlokReaderColors.primary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ReaderSettingsModal(
        currentFontSize: _fontSize,
        currentTheme: _readerTheme,
        currentFont: _readerFont,
        currentLayout: _readerLayout,
        onFontSizeChanged: (val) {
          setState(() => _fontSize = val);
          _prefsService.saveFontSize(val);
        },
        onThemeChanged: (val) {
          setState(() => _readerTheme = val);
          _prefsService.saveTheme(val);
        },
        onFontChanged: (val) {
          setState(() => _readerFont = val);
          _prefsService.saveFont(val);
        },
        onLayoutChanged: (val) {
          setState(() => _readerLayout = val);
          _prefsService.saveLayout(val);
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return _buildChapterTab(context);
  }

  // Ancient scroll design colors
  static const _goldAccent = Color(0xFFC5A059);
  static const _verseTextColor = Color(0xFFE8E0D4);
  static const _translationColor = Color(0xFF9E9689);

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
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildVerseProgressBar(context),
        Expanded(
          child: InteractiveViewer(
            minScale: 0.6,
            maxScale: 3.5,
            child: _readerLayout == ReaderLayout.card
                ? _buildCardLayout()
                : _buildScrollLayout(),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollLayout() {
    return ScrollablePositionedList.builder(
      key: ValueKey<String>('scroll_${widget.book.id}_$_chapterId'),
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: _verses.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildChapterHeader();
        return _buildVerseSection(context, index - 1);
      },
    );
  }

  Widget _buildCardLayout() {
    return ScrollablePositionedList.builder(
      key: ValueKey<String>('card_${widget.book.id}_$_chapterId'),
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _verses.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildChapterHeader();
        return _buildVerseCard(context, index - 1);
      },
    );
  }

  /// Decorative chapter header at the top of the scroll
  Widget _buildChapterHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Book title
          Text(
            widget.book.name,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _goldAccent.withValues(alpha: 0.6),
              letterSpacing: 3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Chapter title
          Text(
            _chapterDisplayName.toUpperCase(),
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _verseTextColor,
              letterSpacing: 4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Ornamental divider
          _buildOrnamentalDivider(),
          const SizedBox(height: 12),
          // Chapter summary if available
          if (_chapterContent != null &&
              _chapterContent!.summary.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '"${_stripChapterIntro(_chapterContent!.summary)}"',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: _translationColor.withValues(alpha: 0.8),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  /// Ornamental gold divider with center diamond
  Widget _buildOrnamentalDivider({bool compact = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 8 : 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _goldAccent.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Transform.rotate(
              angle: 0.785398, // 45 degrees
              child: Container(
                width: compact ? 5 : 7,
                height: compact ? 5 : 7,
                decoration: BoxDecoration(
                  color: _goldAccent.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _goldAccent.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get Hindi text for the verse (primary display)
  String _getHindiText(VerseWithTranslations v) {
    return v.hindiTranslation?.text ??
        v.primaryTranslation?.text ??
        '';
  }

  /// Get English translation/meaning text
  String _getEnglishText(VerseWithTranslations v) {
    return v.englishTranslation?.text ??
        v.primaryTranslation?.text ??
        '';
  }

  /// Get Hindi AI commentary text (language_code: hi-commentary)
  String _getHindiCommentary(VerseWithTranslations v) {
    return v.hindiCommentary?.text ?? '';
  }

  /// Get English AI commentary text (language_code: en-commentary)
  String _getEnglishCommentary(VerseWithTranslations v) {
    return v.englishCommentary?.text ?? '';
  }

  /// Build commentary section with AI symbol; shows Hindi and/or English commentary if present.
  /// Free users see a teaser prompt; premium users see full commentary.
  Widget _buildCommentarySection(VerseWithTranslations v) {
    final hindiCommentary = _getHindiCommentary(v);
    final englishCommentary = _getEnglishCommentary(v);
    if (hindiCommentary.isEmpty && englishCommentary.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrnamentalDivider(compact: true),
          const SizedBox(height: 12),
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: !_isPremium
                    ? () => navigateToProfileForProUpgrade(
                          context,
                          message: 'Full AI commentary is included with Pro.',
                        )
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (AppConfig.showProMarkForPremiumFeature(_isPremium)) ...[
                        const ProGradientLabel(fontSize: 11),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: _goldAccent.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'AI Commentary',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _goldAccent.withValues(alpha: 0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (_isPremium) ...[
            if (hindiCommentary.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  hindiCommentary,
                  style: TextStyle(
                    fontFamily: ReaderSettingsModal.getFontFamily(_readerFont) ?? GoogleFonts.crimsonPro().fontFamily,
                    fontSize: _fontSize - 2,
                    height: 1.65,
                    color: _verseTextColor.withValues(alpha: 0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (englishCommentary.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  englishCommentary,
                  style: TextStyle(
                    fontFamily: ReaderSettingsModal.getFontFamily(_readerFont) ?? GoogleFonts.crimsonPro().fontFamily,
                    fontSize: _fontSize - 4,
                    height: 1.65,
                    color: _translationColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Build a single verse section with ancient scroll styling (Scroll layout)
  Widget _buildVerseSection(BuildContext context, int index) {
    final v = _verses[index];
    final shlokaNum = index + 1;
    final totalShlokas = _verses.length;
    final verseId = v.verse.id;
    final isRead = _readVerseIds.contains(verseId);
    final verseNotes =
        _chapterNotes.where((n) => n.verseId == verseId).toList();

    final hindiText = _getHindiText(v);
    final englishText = _getEnglishText(v);

    return GestureDetector(
      key: ValueKey<String>(verseId),
      onLongPress: () => _showVerseContextMenu(
        context,
        verseId: verseId,
        verseText: '$hindiText\n\n$englishText',
        shlokaNum: shlokaNum,
        totalShlokas: totalShlokas,
        v: v,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verse number label
            Center(
              child: Column(
                children: [
                  Text(
                    'VERSE $shlokaNum',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _goldAccent.withValues(alpha: 0.5),
                      letterSpacing: 4,
                    ),
                  ),
                  if (v.verse.verseNumberDisplay.isNotEmpty &&
                      v.verse.verseNumberDisplay != '$shlokaNum')
                    Text(
                      v.verse.verseNumberDisplay,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 11,
                        color: _goldAccent.withValues(alpha: 0.3),
                        letterSpacing: 2,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hindi verse + English translation: scripture-body exception (AM-58).
            // Do not collapse this to a single-language switch. See docs/LOCALIZATION.md.
            if (hindiText.isNotEmpty)
              _buildVerseBodyWithDropCap(hindiText),

            // Thin separator
            if (englishText.isNotEmpty) ...[
              _buildOrnamentalDivider(compact: true),
              // English translation / meaning
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  englishText,
                  style: TextStyle(
                    fontFamily: ReaderSettingsModal.getFontFamily(_readerFont) ?? GoogleFonts.crimsonPro().fontFamily,
                    fontSize: _fontSize - 3,
                    height: 1.7,
                    color: _translationColor,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            // AI Commentary (Hindi + English if present in verse_translations)
            _buildCommentarySection(v),

            // Read indicator
            if (isRead)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        size: 14,
                        color: AppColors.successColor.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      'Read',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.successColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Notes preview
            if (verseNotes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _goldAccent.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _goldAccent.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote,
                          size: 14,
                          color: _goldAccent.withValues(alpha: 0.4)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          verseNotes.first.note,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Ornamental divider between verses (with larger gap)
            if (index < _verses.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildOrnamentalDivider(),
              ),
          ],
        ),
      ),
    );
  }

  /// Build a single verse as a card with gradient animated border (Card layout)
  Widget _buildVerseCard(BuildContext context, int index) {
    final v = _verses[index];
    final shlokaNum = index + 1;
    final totalShlokas = _verses.length;
    final verseId = v.verse.id;
    final isRead = _readVerseIds.contains(verseId);

    final hindiText = _getHindiText(v);
    final englishText = _getEnglishText(v);

    return Padding(
      key: ValueKey<String>(verseId),
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onLongPress: () => _showVerseContextMenu(
          context,
          verseId: verseId,
          verseText: '$hindiText\n\n$englishText',
          shlokaNum: shlokaNum,
          totalShlokas: totalShlokas,
          v: v,
        ),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final angle = _glowController.value * 2 * math.pi;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: SweepGradient(
                  center: Alignment.center,
                  startAngle: angle,
                  endAngle: angle + math.pi * 2,
                  colors: [
                    _goldAccent.withValues(alpha: 0.4),
                    Colors.transparent,
                    _goldAccent.withValues(alpha: 0.15),
                    Colors.transparent,
                    _goldAccent.withValues(alpha: 0.4),
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(1.5),
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Verse number + read badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VERSE $shlokaNum',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _goldAccent.withValues(alpha: 0.6),
                        letterSpacing: 4,
                      ),
                    ),
                    if (isRead) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle,
                          size: 14,
                          color: AppColors.successColor.withValues(alpha: 0.7)),
                    ],
                  ],
                ),
                const SizedBox(height: 20),

                // Hindi text
                if (hindiText.isNotEmpty)
                  _buildVerseBodyWithDropCap(hindiText),

                if (englishText.isNotEmpty) ...[
                  _buildOrnamentalDivider(compact: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      englishText,
                      style: TextStyle(
                        fontFamily: ReaderSettingsModal.getFontFamily(_readerFont) ?? GoogleFonts.crimsonPro().fontFamily,
                        fontSize: _fontSize - 3,
                        height: 1.7,
                        color: _translationColor,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                // AI Commentary (Hindi + English if present)
                _buildCommentarySection(v),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Verse body text with decorative drop cap for first character
  Widget _buildVerseBodyWithDropCap(String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    final firstChar = text.substring(0, 1);
    final restText = text.substring(1);
    final dropCapSize = _fontSize + 18;
    final verseFontFamily = ReaderSettingsModal.getFontFamily(_readerFont);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: firstChar,
              style: TextStyle(
                fontFamily: verseFontFamily ?? GoogleFonts.cormorantGaramond().fontFamily,
                fontSize: dropCapSize,
                fontWeight: FontWeight.bold,
                color: _goldAccent.withValues(alpha: 0.8),
                height: 1.0,
              ),
            ),
            TextSpan(
              text: restText,
              style: TextStyle(
                fontFamily: verseFontFamily ?? GoogleFonts.crimsonPro().fontFamily,
                fontSize: _fontSize + 2,
                height: 1.85,
                color: _verseTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FAB to open bookmarks & notes sheet
  Widget _buildFab(BuildContext context) {
    final hasContent = _chapterNotes.isNotEmpty || _bookmarkedVerseIds.isNotEmpty;
    return FloatingActionButton(
      mini: true,
      backgroundColor: hasContent
          ? _goldAccent.withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onPressed: () => _showBookmarksNotesSheet(context),
      child: Icon(
        Icons.collections_bookmark_rounded,
        size: 20,
        color: hasContent ? Colors.black : Colors.white.withValues(alpha: 0.6),
      ),
    );
  }

  /// Full-screen bottom sheet with Bookmarks + Notes tabs
  void _showBookmarksNotesSheet(BuildContext context) async {
    await _loadBookmarksAndNotes();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => _BookmarksNotesSheet(
          chapterNotes: _chapterNotes,
          bookmarkedVerseIds: _bookmarkedVerseIds,
          verses: _verses,
          bookName: widget.book.name,
          chapterName: _chapterDisplayName,
          notesService: _notesService,
          onNoteDeleted: (verseId, note) async {
            await _notesService.removeNote(verseId, note);
            if (mounted) await _loadBookmarksAndNotes();
          },
          onBookmarkRemoved: (verseId) async {
            await _notesService.toggleBookmark(verseId);
            if (mounted) await _loadBookmarksAndNotes();
          },
          onVerseSelected: (verseId) {
            Navigator.pop(ctx);
            final idx = _verses.indexWhere((v) => v.verse.id == verseId);
            if (idx >= 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _scrollToVerse(idx);
              });
            }
          },
          scrollController: scrollController,
        ),
      ),
    );
  }

  Future<void> _toggleCenterVerseRead() async {
    if (_verses.isEmpty || _currentVerseIndex >= _verses.length) return;
    final verseId = _verses[_currentVerseIndex].verse.id;
    await _toggleReadStatus(verseId);
    if (mounted && _readVerseIds.length == _verses.length && !_isCompleted) {
      _completeChapter();
    }
  }

  bool get _isCenterVerseRead {
    if (_verses.isEmpty || _currentVerseIndex >= _verses.length) return false;
    return _readVerseIds.contains(_verses[_currentVerseIndex].verse.id);
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: _ShlokReaderColors.obsidianGreen.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShlokNavButton(
            icon: Icons.chevron_left,
            onTap: _goToPrevChapter,
            label: 'Previous Chapter',
            enabled: true,
          ),
          const SizedBox(width: 16),
          Semantics(
            button: true,
            label: _isCenterVerseRead ? 'Mark verse as unread' : 'Mark verse as read',
            child: GestureDetector(
              onTap: _toggleCenterVerseRead,
              child: Container(
                key: _completeButtonKey,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isCenterVerseRead
                      ? AppColors.successColor
                      : _ShlokReaderColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (_isCenterVerseRead
                              ? AppColors.successColor
                              : _ShlokReaderColors.primary)
                          .withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(
                  _isCenterVerseRead ? Icons.check_circle : Icons.check,
                  color: _isCenterVerseRead ? Colors.white : Colors.black,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildShlokNavButton(
            icon: Icons.chevron_right,
            onTap: _goToNextChapter,
            label: 'Next Chapter',
            enabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildShlokNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      label: label,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(
              icon,
              size: 18,
              color: enabled ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for adding a note - dark theme
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
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Note - Verse ${widget.shlokaNum}',
        style: GoogleFonts.cormorantGaramond(
          color: const Color(0xFFC5A059),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(
                widget.verseText,
                style: GoogleFonts.crimsonPro(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade400,
                  fontSize: 13,
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Write your thoughts...',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFC5A059)),
                ),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey.shade500)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFC5A059),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            final note = _controller.text.trim();
            if (note.isEmpty) return;
            Navigator.pop(context);
            widget.onSave(note);
          },
          child: Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

/// Bookmarks + Notes bottom sheet
class _BookmarksNotesSheet extends StatefulWidget {
  final List<VerseNoteModel> chapterNotes;
  final Set<String> bookmarkedVerseIds;
  final List<VerseWithTranslations> verses;
  final String bookName;
  final String chapterName;
  final VerseNotesService notesService;
  final void Function(String verseId, String note) onNoteDeleted;
  final void Function(String verseId) onBookmarkRemoved;
  final void Function(String verseId) onVerseSelected;
  final ScrollController scrollController;

  const _BookmarksNotesSheet({
    required this.chapterNotes,
    required this.bookmarkedVerseIds,
    required this.verses,
    required this.bookName,
    required this.chapterName,
    required this.notesService,
    required this.onNoteDeleted,
    required this.onBookmarkRemoved,
    required this.onVerseSelected,
    required this.scrollController,
  });

  @override
  State<_BookmarksNotesSheet> createState() => _BookmarksNotesSheetState();
}

class _BookmarksNotesSheetState extends State<_BookmarksNotesSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _goldAccent = Color(0xFFC5A059);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'My Collection',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _goldAccent,
                letterSpacing: 1,
              ),
            ),
          ),
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: _goldAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: _goldAccent,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bookmark_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text('Bookmarks (${widget.bookmarkedVerseIds.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.description_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text('Notes (${widget.chapterNotes.length})'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookmarksTab(),
                _buildNotesListTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksTab() {
    // Filter bookmarks that are in this chapter's verses
    final chapterBookmarks = widget.verses
        .where((v) => widget.bookmarkedVerseIds.contains(v.verse.id))
        .toList();

    if (chapterBookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border_rounded,
                size: 48, color: Colors.grey.shade700),
            const SizedBox(height: 12),
            Text(
              'No bookmarks yet',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 6),
            Text(
              'Long-press a verse to bookmark it',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: chapterBookmarks.length,
      itemBuilder: (context, index) {
        final v = chapterBookmarks[index];
        final verseIdx = widget.verses.indexOf(v);
        final hindiText = v.hindiTranslation?.text ?? v.primaryTranslation?.text ?? '';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => widget.onVerseSelected(v.verse.id),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _goldAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${verseIdx + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _goldAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        hindiText,
                        style: GoogleFonts.crimsonPro(
                          fontSize: 14,
                          color: const Color(0xFFE8E0D4),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => widget.onBookmarkRemoved(v.verse.id),
                      child: Icon(Icons.bookmark,
                          size: 20, color: _goldAccent.withValues(alpha: 0.7)),
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

  Widget _buildNotesListTab() {
    if (widget.chapterNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_add_rounded,
                size: 48, color: Colors.grey.shade700),
            const SizedBox(height: 12),
            Text(
              'No notes yet',
              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 6),
            Text(
              'Long-press a verse and tap Note to add one',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: widget.chapterNotes.length,
      itemBuilder: (context, index) {
        final note = widget.chapterNotes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => widget.onVerseSelected(note.verseId),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Verse ${note.shlokaNumber}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: _goldAccent,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => widget.onNoteDeleted(note.verseId, note.note),
                          child: Icon(Icons.delete_outline,
                              size: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.verseText,
                      style: GoogleFonts.crimsonPro(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade400,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _goldAccent.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.comment_rounded,
                              size: 14, color: _goldAccent.withValues(alpha: 0.5)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note.note,
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade300,
                                fontSize: 13,
                                height: 1.4,
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
      },
    );
  }
}
