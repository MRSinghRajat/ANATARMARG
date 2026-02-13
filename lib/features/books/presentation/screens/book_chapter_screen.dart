import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/guide_animation_service.dart';
import '../../../../shared/services/avatar_growth_service.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/services/premium_service.dart';
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
import '../../data/services/reader_preferences_service.dart';
import '../../../content/data/datasources/gpt_api_service.dart';
import '../../../content/data/models/chapter_model.dart' show ChapterContent;
import '../widgets/books_chapters_modal.dart';
import 'book_chat_screen.dart';
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
  final GPTApiService _gptService = GPTApiService();
  final VerseRepository _verseRepository = VerseRepository();
  final ChapterRepository _chapterRepository = ChapterRepository();
  final VerseNotesService _notesService = VerseNotesService();
  final ReaderPreferencesService _prefsService = ReaderPreferencesService();
  final BookProgressRepository _progressRepository = BookProgressRepository();
  late final PageController _pageController;
  final Map<String, GlobalKey> _verseKeys = {};
  ChapterContent? _chapterContent;
  List<VerseWithTranslations> _verses = [];
  List<ChapterModel> _chapters = [];
  Set<String> _readVerseIds = {};
  List<VerseNoteModel> _chapterNotes = [];

  String _selectedLanguage = 'en';
  int _currentVerseIndex = 0;
  int _selectedContentTab = 0; // 0: Chapter, 1: Notes
  double _pageScrollOffset = 0; // For zoom/opacity animation during scroll
  
  // Reader Settings State
  double _fontSize = 18.0;
  ReaderTheme _readerTheme = ReaderTheme.paper;
  ReaderFont _readerFont = ReaderFont.serif;
  bool _isLoading = true;
  bool _isLoadingVerses = false;
  bool _isCompleted = false;
  String? _loadError;
  final GlobalKey _completeButtonKey = GlobalKey();
  late AnimationController _glowController;
  bool _isPremium = false;

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
    _pageController = PageController(initialPage: 0, viewportFraction: 0.52);
    _pageController.addListener(_onPageScroll);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    GuideAnimationService().setState(GuideState.speaking);
    PremiumService.instance.isPremium.then((v) {
      if (mounted) setState(() => _isPremium = v);
    });
    _loadPreferences();
    _loadChapter();
    _loadBookmarksAndNotes();
  }

  /// First verse index that is not read (in order). Max allowed verse index = this value.
  int get _firstUnreadVerseIndex {
    for (var i = 0; i < _verses.length; i++) {
      if (!_readVerseIds.contains(_verses[i].verse.id)) return i;
    }
    return _verses.length; // all read
  }

  bool _canNavigateToVerseIndex(int index) {
    if (_isPremium) return true;
    return index <= _firstUnreadVerseIndex;
  }

  void _onPageScroll() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page ?? 0;
    if ((page - _pageScrollOffset).abs() > 0.001) {
      setState(() => _pageScrollOffset = page);
    }
  }

  Future<void> _loadPreferences() async {
    final fontSize = await _prefsService.loadFontSize();
    final theme = await _prefsService.loadTheme();
    final font = await _prefsService.loadFont();
    if (mounted) {
      setState(() {
        _fontSize = fontSize;
        _readerTheme = theme;
        _readerFont = font;
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
    if (mounted) {
      setState(() {
        _readVerseIds = readVerses;
        _chapterNotes = notes;
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _glowController.dispose();
    if (_verses.isNotEmpty &&
        _currentVerseIndex >= 0 &&
        _currentVerseIndex < _verses.length) {
      _progressRepository.saveLastReadPosition(
        bookId: widget.book.id,
        chapterId: _chapterId,
        lastReadVerseId: _verses[_currentVerseIndex].verse.id,
      );
    }
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
      final readIds = await _progressRepository.getReadVerseIds(_chapterId);
      final isPremium = await PremiumService.instance.isPremium;
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
      if (!isPremium) {
        int firstUnread = verses.length;
        for (var i = 0; i < verses.length; i++) {
          if (!readIds.contains(verses[i].verse.id)) {
            firstUnread = i;
            break;
          }
        }
        resolvedIdx = resolvedIdx.clamp(0, firstUnread);
      }
      setState(() {
        _verses = verses;
        _readVerseIds = readIds;
        _isLoadingVerses = false;
        _loadError = null;
        _currentVerseIndex = resolvedIdx;
        _pageScrollOffset = resolvedIdx.toDouble();
      });
      if (resolvedIdx > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pageController.hasClients) {
            _pageController.jumpToPage(resolvedIdx);
          }
        });
      }
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
    if (!_isPremium && !_isCompleted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Complete this chapter to unlock the next, or upgrade to Premium for full access.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
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
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      index.clamp(0, _verses.length - 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
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
        isPremium: _isPremium,
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
          // Language selector (EN/HI/SA)
          Semantics(
            button: true,
            label: 'Select Language',
            child: GestureDetector(
              onTap: () => _showLanguageSelector(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: _ShlokReaderColors.zinc800,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _translationLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _ShlokReaderColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
      color: _ShlokReaderColors.backgroundDark,
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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _ShlokReaderColors.zinc900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _ShlokReaderColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          _buildContentTab(0, 'Chapter', Icons.auto_stories),
          _buildContentTab(1, 'Notes', Icons.description),
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
                ? _ShlokReaderColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? _ShlokReaderColors.primary
                    : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? _ShlokReaderColors.primary
                      : Colors.grey.shade400,
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
        _buildVerseProgressBar(context),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportHeight = constraints.maxHeight;
              return Stack(
                children: [
                  // Gradient line connecting verse numbers (fixed, full height)
                  Positioned(
                    left: 21,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _ShlokReaderColors.primary,
                              _ShlokReaderColors.primary.withValues(alpha: 0.6),
                              _ShlokReaderColors.primary.withValues(alpha: 0.2),
                              _ShlokReaderColors.primary.withValues(alpha: 0.05),
                            ],
                            stops: const [0.0, 0.2, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    physics: const PageScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: _verses.length,
          onPageChanged: (index) {
            if (!_canNavigateToVerseIndex(index)) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Complete the current verse to unlock the next. Premium unlocks all.',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _pageController.hasClients) {
                  final allowed = _firstUnreadVerseIndex.clamp(0, _verses.length - 1);
                  _pageController.animateToPage(
                    allowed,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                  setState(() => _currentVerseIndex = allowed);
                }
              });
              return;
            }
            setState(() {
              _currentVerseIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final page = _pageController.hasClients
                ? (_pageController.page ?? index.toDouble())
                : index.toDouble();
            final distance = (index - page).abs();
            final scale = (1.0 - (distance * 0.06)).clamp(0.9, 1.0);
            final opacity = (1.0 - (distance * 0.35)).clamp(0.45, 1.0);
            final isActive = distance < 0.5;

            return SizedBox(
              height: viewportHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Verse count on far left (aligned with gradient line)
                  SizedBox(
                    width: 48,
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? _ShlokReaderColors.primary
                              : _ShlokReaderColors.primary.withValues(alpha: 0.4),
                          border: Border.all(
                            color: _ShlokReaderColors.backgroundDark,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.black
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: isActive
                              ? _buildVersePageCard(context, index)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                      sigmaX: 2,
                                      sigmaY: 2,
                                    ),
                                    child: _buildVersePageCard(context, index),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVersePageCard(BuildContext context, int index) {
    final v = _verses[index];
    final shlokaNum = index + 1;
    final totalShlokas = _verses.length;
    final verseId = v.verse.id;
    final displayText = _getVerseTextForLanguage(v);
    _verseKeys[verseId] ??= GlobalKey();
    final isRead = _readVerseIds.contains(verseId);
    final page = _pageController.hasClients ? (_pageController.page ?? index.toDouble()) : index.toDouble();
    final isActive = (index - page).abs() < 0.5; // Centered card during scroll
    final verseNotes =
        _chapterNotes.where((n) => n.verseId == verseId).toList();
    final snippet = displayText.length > 100
        ? '${displayText.substring(0, 100)}...'
        : displayText;

    return Padding(
      key: _verseKeys[verseId],
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: () => _showVerseContextMenu(
            context,
            verseId: verseId,
            verseText: displayText,
            shlokaNum: shlokaNum,
            totalShlokas: totalShlokas,
            v: v,
          ),
          borderRadius: BorderRadius.circular(32),
          splashColor: _ShlokReaderColors.primary.withValues(alpha: 0.1),
          highlightColor: _ShlokReaderColors.primary.withValues(alpha: 0.05),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final glowValue = 0.15 + (_glowController.value * 0.15);
                return Container(
                  constraints: const BoxConstraints(maxWidth: 540, minHeight: 180),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isRead
                          ? [
                              AppColors.successColor.withValues(alpha: 0.25),
                              AppColors.successColor.withValues(alpha: 0.12),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.06),
                              Colors.white.withValues(alpha: 0.02),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isActive
                          ? _ShlokReaderColors.primary
                              .withValues(alpha: 0.2 + glowValue)
                          : Colors.white.withValues(alpha: 0.06),
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: _ShlokReaderColors.primary
                                  .withValues(alpha: glowValue),
                              blurRadius: 20,
                            ),
                          ]
                        : null,
                  ),
                  child: child,
                );
              },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (isActive) _buildFloatingParticles(),
                    Container(
                      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.28,
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          isActive ? displayText : snippet,
                          style: GoogleFonts.cinzel(
                            fontSize: isActive ? _fontSize : 16,
                            height: 1.8,
                            fontStyle: isActive ? FontStyle.normal : FontStyle.italic,
                            color: isActive ? Colors.grey.shade100 : Colors.grey.shade500,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: isActive ? null : 4,
                          overflow: isActive ? null : TextOverflow.ellipsis,
                        ),
                      ),
                          ),
                          if (verseNotes.isNotEmpty && isActive) ...[
                            const SizedBox(height: 12),
                            Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _ShlokReaderColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                              Icons.note,
                              size: 18,
                              color: _ShlokReaderColors.primary,
                            ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      verseNotes.first.note,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey.shade400,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, _) {
            return CustomPaint(
              painter: _ParticlePainter(progress: _glowController.value),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotesTab(BuildContext context) {
    if (_chapterNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_add, size: 64, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Long-press a shlok and tap Notes to add a note',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade400,
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
            color: _ShlokReaderColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shloka ${note.shlokaNumber}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: _ShlokReaderColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: Colors.grey.shade500),
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
                style: GoogleFonts.inter(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade300,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _ShlokReaderColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.comment, size: 18, color: _ShlokReaderColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.note,
                        style: GoogleFonts.inter(color: Colors.grey.shade300),
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
            enabled: _isPremium || _isCompleted,
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

/// Painter for floating particle effect (incense smoke style)
class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const particles = [
      Offset(0.2, 0.8),
      Offset(0.5, 0.7),
      Offset(0.8, 0.75),
      Offset(0.35, 0.9),
      Offset(0.65, 0.85),
    ];
    for (var i = 0; i < particles.length; i++) {
      final p = particles[i];
      final yOffset = (progress * 2 + i * 0.2) % 1.0;
      final x = p.dx * size.width + (i.isOdd ? 10 : -10) * progress;
      final y = size.height - (p.dy * size.height * 0.6) - (yOffset * size.height * 0.4);
      final radius = 2.0 + (i % 3);
      final opacity = (0.03 + (1 - yOffset) * 0.04).clamp(0.0, 0.08);
      final paint = Paint()
        ..color = _ShlokReaderColors.primary.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
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
