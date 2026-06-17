import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/antarmarg_placeholder.dart';
import '../../data/models/book_model.dart';
import '../providers/book_providers.dart';
import '../providers/now_playing_provider.dart';
import '../../data/models/granthalaya_models.dart';
import '../widgets/granthalaya_audio_content.dart';
import '../widgets/granthalaya_audio_progress_sync.dart';
import '../widgets/granthalaya_audio_mini_player.dart';
import 'book_detail_screen.dart';
import 'full_audio_player_screen.dart';
import 'deity_detail_screen.dart';
import 'sacred_text_reader_screen.dart';
import 'sacred_story_reader_screen.dart';
import 'all_sacred_stories_screen.dart';
import 'all_sacred_texts_screen.dart';
import '../../data/services/granthalaya_recent_service.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../core/utils/profile_pro_upgrade_nav.dart';
import '../../../../shared/widgets/upgrade_pro_banner.dart';
import '../../../../core/utils/app_router.dart';
import '../../../journey/data/models/journey_models.dart';
import '../../../journey/presentation/providers/journey_providers.dart';

/// Granthalaya - Academic Dashboard. Sacred Texts on top, Foundation & Concepts, Study Resources.
class BooksLibraryScreen extends ConsumerStatefulWidget {
  const BooksLibraryScreen({super.key});

  @override
  ConsumerState<BooksLibraryScreen> createState() => _BooksLibraryScreenState();
}

class _BooksLibraryScreenState extends ConsumerState<BooksLibraryScreen> {
  final ScrollController _scrollController = ScrollController();
  /// Journey tab: horizontal carousel for multiple in-progress journeys.
  final PageController _journeyPageController = PageController(viewportFraction: 0.86);
  int _journeyCarouselIndex = 0;
  List<BookModel> _books = [];
  bool _isLoading = true;
  bool _isPremium = false;
  StreamSubscription<bool>? _premiumSubscription;
  /// 0 = Read, 1 = Listen, 2 = Journey
  int _granthalayaTabIndex = 0;
  int _sacredLibraryCategoryIndex = 0;
  // Audio (Listen mode) - mini player driven by nowPlayingProvider

  static const _coverUrls = {
    'bhagavad_gita':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCeFNfyF3TMbtQ7up4KjskhDXsUja_ezF57r7yXtsw7qht7MWETTO5t-dTRJ5yKLGjVidywqNDN_tYKaEhCT-GW6PgKdHyCJivzZEk3MFKeenhqQE9lW9dmulcDAGEtzqlDKk9-V_1vAxfrsXu5ER-bNWtcVzRI4zSyvvmNDPJ58EPRheqIFknQUzuOF0zLsTHepqZozzC058V3Vhz4FC7I0MqtbnhK3mRrEBauKk-OBOllQvmPoUhxzI3oicigPXbW4HNzglsA3JZD',
    'mahabharata':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1',
    'ramayana':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1',
    'ramayan':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1',
    'vedas':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1',
    'upanishads':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCJl1L6fIrykeLWmdy0V5EC5-Eh4nRFTBiIJmZvfBncpvgMivobf5NbOHIFWkBndaaRvC4YCHyOTgYrn17GM4YRUqu02UjdT4uoTbH-Qgy1FmIfhhsA0Q21QwyKikc1JvvZApGs7fH_6m_pQ48kHemmVpGJUfO0f-idW3Am5Dmyv8mGgIQlPOWu75jym4UITWgp7x6KSH22NMoTXUhrWu_mF-XQ-pykoUCH1RnyCP6zvd3oYGw_0Gh7KrpdRZrmDrJCq4lPaP81wgPO',
    'shiva purana':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCJl1L6fIrykeLWmdy0V5EC5-Eh4nRFTBiIJmZvfBncpvgMivobf5NbOHIFWkBndaaRvC4YCHyOTgYrn17GM4YRUqu02UjdT4uoTbH-Qgy1FmIfhhsA0Q21QwyKikc1JvvZApGs7fH_6m_pQ48kHemmVpGJUfO0f-idW3Am5Dmyv8mGgIQlPOWu75jym4UITWgp7x6KSH22NMoTXUhrWu_mF-XQ-pykoUCH1RnyCP6zvd3oYGw_0Gh7KrpdRZrmDrJCq4lPaP81wgPO',
    'rig veda':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1',
  };

  static const _deitiesFallback = [
    (
      'Shiva',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv'
    ),
    (
      'Vishnu',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv'
    ),
    (
      'Devi',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCd_4JNasICaIaHij84HkpIMICry2qj9vQbv4E418yGFsZvKbS4Wk5J2i4pPOqk6gM2mWCKAS7JczuUgHfnRi0fUli5hU8gZovvHqoWo1GI22rS613kTYAxJVowoCXRgFDR7-97bUilllW6Z6rM_MEB4Hk9fe8yAcF-871rkAWzHsFNmpVDH0R7w0OW0g-tlL9Ncib0jHHxIuN-3O-lrpEiRaVouZoSikGTJQqEE0fD1rbpaJNRwDvfadeu6GWnWi2-30rmN0BAjiQr'
    ),
    (
      'Ganesha',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDT51ZKt0o37zUWn7OBW7NHAv_eqYJDBi4yZSbeFZsG98EbbMrXTd47UBFo-C-q6a_D5Wg7QkmTldlWo2U-Y6HXTvI8ZMGCeKCqeeY_SH_QML9bOxOaQmW3MahYkvWdvzedC3MC4eh1a__pyn4fjae8N3Nv0t3kjNR4AXPY0PcHYhJw7RD9oPYAhii6KgHEnis4nYoIPGi8mnmpm2BwyGDZVYSjZGHeofoTpepPJCe6VnrqAtyO98VkNkBPEHHvZZP7xXJcLm8pe54P'
    ),
  ];

  IconData _iconFromName(String name) {
    switch (name) {
      case 'record_voice_over':
        return Icons.record_voice_over;
      default:
        return Icons.menu_book;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBooks();
    PremiumService.instance.isPremium.then((v) {
      if (mounted) setState(() => _isPremium = v);
    });
    _premiumSubscription = PremiumService.instance.premiumStatusStream.listen((v) {
      if (!mounted) return;
      setState(() {
        _isPremium = v;
        if (!v && _granthalayaTabIndex != 0) {
          _granthalayaTabIndex = 0;
          ref.read(granthalayaReadModeProvider.notifier).state = true;
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(granthalayaReadModeProvider.notifier).state =
          _granthalayaTabIndex == 0;
    });
  }

  @override
  void dispose() {
    _premiumSubscription?.cancel();
    _scrollController.dispose();
    _journeyPageController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final repo = ref.read(bookRepositoryProvider);
    try {
      final books = await repo.getAllBooks();
      if (mounted) setState(() => _books = books);
    } catch (_) {
      if (mounted) setState(() => _books = repo.allBooks);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _tryOpenJourneySetup(JourneyType t) async {
    if (t.isPremium && !_isPremium) {
      navigateToProfileForProUpgrade(context);
      return;
    }
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in')),
        );
      }
      return;
    }
    final existing = await ref.read(journeyRepositoryProvider).getActiveOrPausedJourneyForType(
          userId: uid,
          journeyTypeId: t.id,
        );
    if (!mounted) return;
    if (existing != null) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('This journey type is already in progress'),
          content: const Text(
            'You already have an active or paused path for this journey. Open it from Your journeys below or from Ashram. You can still start other journey types anytime.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRouter.journeySetup, arguments: {'slug': t.slug});
  }

  /// Pull-to-refresh: reload books and invalidate all Granthalaya providers so every section refetches.

  void _selectGranthalayaTab(int index) {
    if (!_isPremium && (index == 1 || index == 2)) {
      final msg = index == 1
          ? 'Listen mode and the full audio library are part of Pro. Open Profile to upgrade.'
          : 'Spiritual journeys unlock with Pro. Open Profile to upgrade.';
      navigateToProfileForProUpgrade(context, message: msg);
      return;
    }
    setState(() => _granthalayaTabIndex = index);
    ref.read(granthalayaReadModeProvider.notifier).state = index == 0;
  }

  Future<void> _onGranthalayaRefresh() async {
    await _loadBooks();
    if (!mounted) return;
    ref.invalidate(sacredTextsProvider);
    ref.invalidate(featuredSacredTextsProvider);
    ref.invalidate(sacredStoriesCollectionProvider);
    ref.invalidate(sacredStoryCategoriesProvider);
    ref.invalidate(deitiesProvider);
    ref.invalidate(chantsProvider);
    ref.invalidate(resourceCardsProvider);
    ref.invalidate(deepDiveProvider);
    ref.invalidate(audioCategoriesProvider);
    ref.invalidate(audioInProgressProvider);
    ref.invalidate(userAudioProgressProvider);
    ref.invalidate(audioWisdomCardsProvider);
  }

  String _getBookTag(BookModel book) {
    switch (book.id.toLowerCase()) {
      case 'bhagavad_gita':
      case 'geeta':
        return 'Wisdom';
      case 'mahabharata':
      case 'ramayana':
      case 'ramayan':
        return 'Epic';
      default:
        return 'Sacred';
    }
  }

  String? _getCoverUrl(String bookId) {
    if (_coverUrls.containsKey(bookId.toLowerCase())) {
      return _coverUrls[bookId.toLowerCase()];
    }
    return _coverUrls['bhagavad_gita'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepAsh,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeToggle(),
            Expanded(
              child: _granthalayaTabIndex == 0
                  ? _buildReadContent()
                  : _granthalayaTabIndex == 1
                      ? _buildListenContent()
                      : _buildJourneyContent(),
            ),
          ],
        ),
      ),
    );
  }

  List<BookModel> get _currentlyReadingBooks {
    final started = _books.where((b) => b.progress > 0).toList();
    started.sort((a, b) =>
        (b.lastReadAt ?? DateTime(0)).compareTo(a.lastReadAt ?? DateTime(0)));
    return started;
  }

  Widget _buildReadContent() {
    return RefreshIndicator(
      onRefresh: _onGranthalayaRefresh,
      color: AppColors.matteGold,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          if (!_isPremium)
            const SliverToBoxAdapter(
              child: UpgradeProBanner(
                message: 'Read all chapters, stories & audio',
              ),
            ),
          SliverToBoxAdapter(child: _buildLastViewedSection()),
          SliverToBoxAdapter(child: _buildSacredTextsSection()),
          SliverToBoxAdapter(child: _buildSacredLibrarySection()),
          SliverToBoxAdapter(child: _buildSacredStoriesSection()),
          SliverToBoxAdapter(child: _buildExploreDeitiesSection()),
          SliverToBoxAdapter(child: _buildResourceLibrarySection()),
          SliverToBoxAdapter(child: _buildDeepDiveSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.manuscriptDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.matteGold.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectGranthalayaTab(0),
                child: _buildModeToggleSegment(
                  index: 0,
                  icon: Icons.auto_stories,
                  label: 'Read',
                  locked: false,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectGranthalayaTab(1),
                child: _buildModeToggleSegment(
                  index: 1,
                  icon: Icons.headphones,
                  label: 'Listen',
                  locked: !_isPremium,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectGranthalayaTab(2),
                child: _buildModeToggleSegment(
                  index: 2,
                  icon: Icons.route,
                  label: 'Journey',
                  locked: !_isPremium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggleSegment({
    required int index,
    required IconData icon,
    required String label,
    required bool locked,
  }) {
    final selected = _granthalayaTabIndex == index;
    final baseColor = locked && !selected ? AppColors.zinc500.withOpacity(0.65) : null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppColors.matteGold.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: AppColors.matteGold.withOpacity(0.2))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: baseColor ?? (selected ? AppColors.matteGold : AppColors.zinc500),
          ),
          if (locked) ...[
            const SizedBox(width: 4),
            Icon(Icons.lock_outline_rounded, size: 14, color: baseColor ?? AppColors.zinc500),
          ],
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: baseColor ?? (selected ? AppColors.matteGold : AppColors.zinc500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyContent() {
    if (!_isPremium) {
      return const SizedBox.shrink();
    }
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(activeJourneyProvider);
        ref.invalidate(activeJourneysProvider);
        ref.invalidate(allUserJourneysProvider);
        ref.invalidate(journeyTypesProvider);
        ref.invalidate(journeyTypeMemberCountsProvider);
      },
      color: AppColors.journeyGold,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Spiritual Circle',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 28,
                      color: const Color(0xFFF5F0E8),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sacred journeys for every stage of life — run several paths at once.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.zinc500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          Consumer(
            builder: (context, ref, _) {
              final allJourneysAsync = ref.watch(allUserJourneysProvider);
              final typesAsync = ref.watch(journeyTypesProvider);
              final countsAsync = ref.watch(journeyTypeMemberCountsProvider);
              if (typesAsync.isLoading && allJourneysAsync.isLoading) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.journeyGold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading your journeys…',
                          style: GoogleFonts.inter(color: AppColors.zinc500, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (typesAsync.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.zinc500.withValues(alpha: 0.8)),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load journeys',
                          style: GoogleFonts.inter(color: AppColors.zinc400, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            ref.invalidate(journeyTypesProvider);
                            ref.invalidate(allUserJourneysProvider);
                            ref.invalidate(journeyTypeMemberCountsProvider);
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Retry'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.journeyGold),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final allJourneys = ref.watch(allUserJourneysProvider).valueOrNull ?? [];
              final activeJourneys = allJourneys.where((j) => j.isActive).toList();
              final types = typesAsync.valueOrNull ?? [];
              final memberCounts = countsAsync.valueOrNull ?? {};
              final pausedJourneys = allJourneys.where((j) => j.isPaused).toList();
              final startTypes = types.where((t) => !t.isComingSoon).toList();
              final comingSoonTypes = types.where((t) => t.isComingSoon).toList();
              final allUserJourneysForProgress = [...activeJourneys, ...pausedJourneys];
              final jp = allUserJourneysForProgress.length;
              if (jp > 1 && _journeyCarouselIndex >= jp) {
                final last = jp - 1;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() => _journeyCarouselIndex = last);
                  if (_journeyPageController.hasClients) {
                    _journeyPageController.jumpToPage(last);
                  }
                });
              }
              return SliverList(
                delegate: SliverChildListDelegate([
                  if (allUserJourneysForProgress.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'YOUR JOURNEYS',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.zinc500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Global Progress',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.journeyPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Several journeys can run together — each path stays separate.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.zinc500.withValues(alpha: 0.95),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (allUserJourneysForProgress.length == 1)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: allUserJourneysForProgress.first.isActive
                            ? _buildJourneyContinuingCard(
                                ref,
                                allUserJourneysForProgress.first,
                                types,
                                memberCounts,
                                listMode: true,
                              )
                            : _buildJourneyPausedCard(
                                ref,
                                allUserJourneysForProgress.first,
                                types,
                                listMode: true,
                              ),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(allUserJourneysForProgress.length, (i) {
                            final active = i == _journeyCarouselIndex;
                            return Semantics(
                              label: 'Show journey ${i + 1} of ${allUserJourneysForProgress.length}',
                              button: true,
                              selected: active,
                              child: GestureDetector(
                                onTap: () {
                                  _journeyPageController.animateToPage(
                                    i,
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeOutCubic,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: active ? 20 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: active
                                        ? AppColors.journeyGold
                                        : AppColors.zinc600.withValues(alpha: 0.65),
                                    boxShadow: active
                                        ? [
                                            BoxShadow(
                                              color: AppColors.journeyGold.withValues(alpha: 0.35),
                                              blurRadius: 6,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: PageView.builder(
                          controller: _journeyPageController,
                          onPageChanged: (i) {
                            setState(() => _journeyCarouselIndex = i);
                          },
                          itemCount: allUserJourneysForProgress.length,
                          padEnds: false,
                          itemBuilder: (context, index) {
                            final uj = allUserJourneysForProgress[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: uj.isActive
                                  ? _buildJourneyContinuingCard(
                                      ref,
                                      uj,
                                      types,
                                      memberCounts,
                                      compact: true,
                                    )
                                  : _buildJourneyPausedCard(
                                      ref,
                                      uj,
                                      types,
                                      compact: true,
                                    ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 16),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'POPULAR IN YOUR CIRCLE',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.zinc400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...startTypes.asMap().entries.map((e) => _buildJourneyPopularCard(ref, e.value, memberCounts, isTrending: e.key == 0, showPill: e.key == 1)),
                  ...comingSoonTypes.map((t) => _buildJourneyPopularCard(ref, t, memberCounts, isComingSoon: true)),
                  if (types.isEmpty && !typesAsync.isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
                      child: Center(
                        child: Text(
                          'No journeys available yet',
                          style: GoogleFonts.inter(color: AppColors.zinc500, fontSize: 14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 120),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Big "Continuing Together" card: active journey with Joined by X, progress, Continue CTA.
  /// [compact] when true uses tighter padding for horizontal list to avoid overflow.
  /// [listMode] full-width vertical list (Granthalaya Journey tab).
  Widget _buildJourneyContinuingCard(
    WidgetRef ref,
    UserJourney active,
    List<JourneyType> types,
    Map<String, int> memberCounts, {
    bool compact = false,
    bool listMode = false,
  }) {
    final typeList = types.where((t) => t.id == active.journeyTypeId).toList();
    final journeyType = typeList.isNotEmpty ? typeList.first : (types.isNotEmpty ? types.first : null);
    final phaseAsync = ref.watch(currentPhaseProvider(active.id));
    final tasksAsync = ref.watch(todaysJourneyTasksProvider(active.id));
    final tasks = tasksAsync.valueOrNull ?? [];
    final done = tasks.where((t) => t.isCompleted).length;
    final total = tasks.length > 0 ? tasks.length : 1;
    final label = _journeyContextLabel(active, phaseAsync.valueOrNull);
    final memberCount = memberCounts[active.journeyTypeId] ?? 0;
    final joinedText = memberCount >= 1000
        ? 'Joined by ${(memberCount / 1000).toStringAsFixed(1)}k+'
        : memberCount > 0
            ? 'Joined by $memberCount'
            : null;
    // Black–gold gradient theme for Journey progress cards
    final outerPadding = listMode
        ? EdgeInsets.zero
        : (compact ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 20));
    final innerPadding = listMode
        ? const EdgeInsets.all(16)
        : (compact ? const EdgeInsets.all(12) : const EdgeInsets.all(20));
    return Padding(
      padding: outerPadding,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(AppRouter.journeyHome, arguments: {'userJourneyId': active.id}),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  AppColors.journeyBlack,
                  Color(0xFF1A1510),
                  AppColors.journeyGold,
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.journeyGold.withValues(alpha: 0.35), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: innerPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.journeyGold.withValues(alpha: 0.4), width: 2),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                          ),
                          child: _journeyCardImageOrPlaceholder(
                            imageUrl: journeyType?.cardImageUrl,
                            placeholder: _journeyPlaceholderCircleSmall(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                journeyType?.title ?? 'Journey',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              if (joinedText != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  joinedText,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.journeyGold.withValues(alpha: 0.95),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Community Milestone: ${(total > 0 ? (done / total * 100).round() : 0)}% Complete',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (label != null) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    label.split(' · ').first,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.journeyGold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.journeyGold.withValues(alpha: 0.5),
                                    blurRadius: 12,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: LinearProgressIndicator(
                                value: total > 0 ? (done / total) : 0,
                                minHeight: 8,
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.journeyGold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildAvatarStack(const ['JD', 'MK', 'AS'], overflow: 42),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  memberCount > 0
                                      ? '${(memberCount / 1000).toStringAsFixed(1)}k+ people active now'
                                      : '$done of $total done today',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.journeyGold,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.journeyGold.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue Journey',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.journeyBlack,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.journeyBlack),
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

  /// Map journey type icon name to Material icon for parity with design (child_care, face, book, etc.).
  static final Map<String, IconData> _journeyIconMap = {
    'child_care': Icons.child_care,
    'face': Icons.face,
    'face_2': Icons.face_2,
    'menu_book': Icons.menu_book,
    'book': Icons.menu_book,
    'auto_stories': Icons.auto_stories,
    'self_improvement': Icons.self_improvement,
    'psychology': Icons.psychology,
    'eco': Icons.eco,
    'spa': Icons.spa,
  };

  Widget _journeyIconWidget(JourneyType t, {double size = 24, Color? color}) {
    final name = (t.icon ?? '').toString().trim().toLowerCase();
    final iconData = name.isNotEmpty ? _journeyIconMap[name] : null;
    if (iconData != null) {
      return Icon(iconData, size: size, color: color ?? AppColors.journeyPrimary);
    }
    return Text(t.icon ?? '🛤️', style: TextStyle(fontSize: size));
  }

  /// Avatar stack like HTML: overlapping circles with initials, optional +N overflow.
  /// Uses Stack + Positioned to overlap (SizedBox with negative width is invalid in Flutter).
  Widget _buildAvatarStack(List<String> initials, {int? overflow}) {
    const size = 20.0;
    const overlap = 6.0;
    const step = size - overlap;
    const colors = [
      Color(0xFF60A5FA),
      Color(0xFFF472B6),
      Color(0xFF34D399),
      Color(0xFFFF9933),
    ];
    final count = initials.length + (overflow != null ? 1 : 0);
    final totalWidth = size + (count - 1) * step;
    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < initials.length; i++)
            Positioned(
              left: i * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[i % colors.length],
                  border: Border.all(color: AppColors.journeyBackgroundDark, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials[i],
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (overflow != null)
            Positioned(
              left: initials.length * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.journeyPrimary,
                  border: Border.all(color: AppColors.journeyBackgroundDark, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$overflow',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _journeyPlaceholderCircleSmall() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.journeyGold.withValues(alpha: 0.2),
        border: Border.all(color: AppColors.journeyGold.withValues(alpha: 0.4)),
      ),
      child: Icon(Icons.eco_rounded, size: 28, color: AppColors.journeyGold.withValues(alpha: 0.8)),
    );
  }

  /// Null-safe: show network image only when [imageUrl] is non-null and non-empty.
  Widget _journeyCardImageOrPlaceholder({String? imageUrl, required Widget placeholder}) {
    if (imageUrl == null || imageUrl.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }

  Widget _journeyPlaceholderCircle() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.journeyGold.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.journeyGold.withValues(alpha: 0.25)),
      ),
      child: Icon(
        Icons.eco_rounded,
        size: 36,
        color: AppColors.journeyGold.withValues(alpha: 0.7),
      ),
    );
  }

  /// [compact] when true uses tighter padding and min height for horizontal list to avoid overflow.
  /// [listMode] full-width card for vertical list layout.
  Widget _buildJourneyPausedCard(
    WidgetRef ref,
    UserJourney uj,
    List<JourneyType> types, {
    bool compact = false,
    bool listMode = false,
  }) {
    final typeList = types.where((t) => t.id == uj.journeyTypeId).toList();
    final journeyType = typeList.isNotEmpty ? typeList.first : null;
    final repo = ref.read(journeyRepositoryProvider);
    final cardPadding = listMode
        ? EdgeInsets.zero
        : (compact ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 20, vertical: 6));
    return Padding(
      padding: cardPadding,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              await repo.resumeJourney(uj.id);
              ref.invalidate(activeJourneyProvider);
              ref.invalidate(activeJourneysProvider);
              ref.invalidate(allUserJourneysProvider);
              ref.invalidate(todaysJourneyTasksProvider(uj.id));
              ref.invalidate(allJourneyTasksWithTodayCompletionProvider(uj.id));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${journeyType?.title ?? 'Journey'} resumed — tasks are back in Ashram'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.journeyGold.withValues(alpha: 0.9),
                  ),
                );
                Navigator.of(context).pushNamed(AppRouter.journeyHome, arguments: {'userJourneyId': uj.id});
              }
            } catch (_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not resume. Try again.'), behavior: SnackBarBehavior.floating),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: compact ? 100 : 88),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.journeyBlack,
                      const Color(0xFF1A1510),
                      AppColors.journeyGold.withValues(alpha: 0.15),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.journeyGold.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.journeyGold.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildJourneyCardLeftImageStrip(
                    imageUrl: journeyType?.cardImageUrl ?? journeyType?.bannerUrl,
                    mergeGradientEnd: AppColors.journeyBlack,
                    placeholder: Container(
                      color: AppColors.journeyBlack,
                      child: Center(
                        child: journeyType != null
                            ? _journeyIconWidget(journeyType!, size: 32, color: AppColors.journeyGold)
                            : Icon(Icons.pause_rounded, size: 32, color: AppColors.journeyGold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 12 : 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  journeyType?.title ?? 'Journey',
                                  style: GoogleFonts.inter(
                                    fontSize: compact ? 15 : 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Paused — tap to resume',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.journeyGold.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 6 : 8),
                            decoration: BoxDecoration(
                              color: AppColors.journeyGold.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.journeyGold.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Resume',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.journeyGold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.play_arrow_rounded, size: 22, color: AppColors.journeyGold),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  String? _journeyContextLabel(UserJourney uj, JourneyPhase? phase) {
    final meta = uj.metadata;
    if (meta.containsKey('due_date')) {
      final due = DateTime.tryParse(meta['due_date'] as String? ?? '');
      if (due != null) {
        final week = (40 - due.difference(DateTime.now()).inDays / 7).ceil().clamp(1, 42);
        return 'Week $week${phase != null ? ' · ${phase.title}' : ''}';
      }
    }
    if (meta.containsKey('child_dob')) {
      final dob = DateTime.tryParse(meta['child_dob'] as String? ?? '');
      final name = meta['child_name'] as String? ?? 'Baby';
      if (dob != null) {
        final days = DateTime.now().difference(dob).inDays;
        final y = days ~/ 365;
        final m = (days % 365) ~/ 30;
        final ageStr = y > 0 ? '${y}y ${m}m' : '${m}m';
        return '$name · $ageStr${phase != null ? ' · ${phase.title}' : ''}';
      }
    }
    if (uj.startDate != null) {
      final day = DateTime.now().difference(uj.startDate!).inDays;
      return 'Day $day${phase != null ? ' · ${phase.title}' : ''}';
    }
    return phase?.title;
  }

  Color? _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length == 6 || h.length == 8) {
      final v = int.tryParse('FF$h', radix: 16);
      if (v != null) return Color(v);
    }
    return null;
  }

  /// Left-side image strip for Paused/Popular cards: rectangular, ~90% of image visible, 10% clipped behind card edge, gradient merged into card.
  static const double _journeyCardImageStripWidth = 96.0;

  Widget _buildJourneyCardLeftImageStrip({
    required String? imageUrl,
    required Color mergeGradientEnd,
    Widget? placeholder,
  }) {
    return SizedBox(
      width: _journeyCardImageStripWidth,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              Positioned(
                left: -_journeyCardImageStripWidth * 0.1,
                top: 0,
                bottom: 0,
                width: _journeyCardImageStripWidth * 1.1,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => placeholder ?? _journeyCardImagePlaceholder(mergeGradientEnd),
                ),
              )
            else
              placeholder ?? _journeyCardImagePlaceholder(mergeGradientEnd),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, mergeGradientEnd],
                    stops: const [0.5, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _journeyCardImagePlaceholder(Color mergeGradientEnd) {
    return Container(
      color: mergeGradientEnd,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Image.asset(
            AppConfig.appLogoPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.auto_stories_rounded, size: 36, color: AppColors.journeyGold.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  /// Single row card in "Popular in your Circle": icon, title, subtitle, Joined by X, lock/chevron. Matches HTML layout.
  Widget _buildJourneyPopularCard(WidgetRef ref, JourneyType t, Map<String, int> memberCounts, {bool isTrending = false, bool isComingSoon = false, bool showPill = false}) {
    final allJourneys = ref.watch(allUserJourneysProvider).valueOrNull ?? [];
    final journeyInProgress = allJourneys.any(
      (j) => j.journeyTypeId == t.id && (j.isActive || j.isPaused),
    );
    final memberCount = memberCounts[t.id] ?? 0;
    final startedText = memberCount >= 1000
        ? '${(memberCount / 1000).toStringAsFixed(1)}k people started this week'
        : memberCount > 0
            ? '$memberCount people started this week'
            : null;
    final isPremiumLocked = t.isPremium && !_isPremium;

    // Coming-soon with image background: use separate layout
    final hasImage = (t.cardImageUrl ?? '').isNotEmpty || (t.bannerUrl ?? '').isNotEmpty;
    if (isComingSoon && hasImage) {
      return _buildJourneyComingSoonImageCard(t, memberCount);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isComingSoon) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
              return;
            }
            if (isPremiumLocked) {
              navigateToProfileForProUpgrade(context);
              return;
            }
            _tryOpenJourneySetup(t);
          },
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 116,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF252528),
                      const Color(0xFF1E1D21),
                      const Color(0xFF282520),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.journeyPrimary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (journeyInProgress && !isComingSoon)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade700,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            'IN PROGRESS',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    if (isTrending)
                      Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.journeyPrimary,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          'TRENDING',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildJourneyCardLeftImageStrip(
                          imageUrl: t.cardImageUrl ?? t.bannerUrl,
                          mergeGradientEnd: const Color(0xFF252528),
                          placeholder: Container(
                            color: const Color(0xFF252528),
                            child: Center(
                              child: _journeyIconWidget(t, size: 32, color: AppColors.journeyPrimary),
                            ),
                          ),
                        ),
                        Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      if (isTrending && (t.subtitle ?? '').isNotEmpty)
                                        Text(
                                          t.subtitle ?? '',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.zinc400,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      if (isTrending && (t.subtitle ?? '').isNotEmpty) const SizedBox(height: 4),
                                      if (startedText != null) ...[
                                        Row(
                                          children: [
                                            Icon(Icons.group_outlined, size: 12, color: AppColors.journeyPrimary.withValues(alpha: 0.9)),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                startedText,
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.zinc400,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else if (showPill && memberCount > 0) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _buildAvatarStack(const ['P', 'R'], overflow: null),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                memberCount >= 1000
                                                    ? '${(memberCount / 1000).toStringAsFixed(1)}k people are here'
                                                    : '$memberCount people are here',
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.journeyPrimary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else if (isComingSoon)
                                        Text(
                                          t.subtitle ?? 'Coming soon',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.zinc400,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      else if ((t.subtitle ?? '').isNotEmpty)
                                        Text(
                                          t.subtitle ?? '',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.zinc400,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isComingSoon)
                                Icon(Icons.lock_outline_rounded, size: 22, color: AppColors.zinc500)
                              else if (!isPremiumLocked)
                                Icon(Icons.chevron_right_rounded, size: 24, color: AppColors.journeyPrimary)
                              else
                                Icon(Icons.lock_outline_rounded, size: 22, color: AppColors.zinc500),
                            ],
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
      ),
    ),
    );
  }

  /// Coming-soon card with full-bleed background image (matches HTML 21-Day Gita / 40-Day Hanuman).
  Widget _buildJourneyComingSoonImageCard(JourneyType t, int memberCount) {
    final imageUrl = t.cardImageUrl ?? t.bannerUrl ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon'))),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.journeyPrimary.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                onError: (_, __) {},
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.9),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.journeyPrimary.withValues(alpha: 0.25),
                            border: Border.all(color: AppColors.journeyPrimary.withValues(alpha: 0.3)),
                          ),
                          child: Center(
                            child: _journeyIconWidget(t, size: 28, color: AppColors.journeyPrimary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      t.title,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.journeyPrimary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'COMING SOON',
                                      style: GoogleFonts.inter(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.subtitle ?? 'Unlock wisdom with others',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.zinc400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (memberCount > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      height: 16,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            left: 0,
                                            child: Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withValues(alpha: 0.2),
                                                border: Border.all(color: Colors.black.withValues(alpha: 0.5)),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 12,
                                            child: Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withValues(alpha: 0.3),
                                                border: Border.all(color: Colors.black.withValues(alpha: 0.5)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      memberCount >= 1000
                                          ? '${(memberCount / 1000).toStringAsFixed(1)}k people on the waitlist'
                                          : '$memberCount people on the waitlist',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.zinc400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(Icons.lock_outline_rounded, size: 22, color: AppColors.journeyPrimary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyTypeGrid(WidgetRef ref, List<JourneyType> list, {required bool isComingSoon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.88,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final t = list[index];
          final isPremiumLocked = t.isPremium && !_isPremium;
          final color = _parseColor(t.colorPrimary ?? '') ?? AppColors.journeyGold;
          if (isComingSoon) {
            return _buildComingSoonCard(t);
          }
          return _buildStartJourneyCard(ref, t, isPremiumLocked, color);
        },
      ),
    );
  }

  Widget _buildStartJourneyCard(WidgetRef ref, JourneyType t, bool isPremiumLocked, Color color) {
    final allJourneys = ref.watch(allUserJourneysProvider).valueOrNull ?? [];
    final journeyInProgress = allJourneys.any(
      (j) => j.journeyTypeId == t.id && (j.isActive || j.isPaused),
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isPremiumLocked) {
            navigateToProfileForProUpgrade(context);
            return;
          }
          _tryOpenJourneySetup(t);
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF252028).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: color.withValues(alpha: 0.15),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        t.icon ?? '🛤️',
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    t.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF5F0E8),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.subtitle ?? 'Begin your path',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.zinc500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (journeyInProgress)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'IN PROGRESS',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              if (isPremiumLocked)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(Icons.lock_rounded, size: 18, color: AppColors.zinc500),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonCard(JourneyType t) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B22).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.journeyGold.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 32,
                color: AppColors.journeyGold.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                t.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB8B2A8),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Coming soon',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.zinc600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastViewedSection() {
    return Consumer(
      builder: (context, ref, _) {
        final textsAsync = ref.watch(sacredTextsProvider(null));
        final storiesAsync = ref.watch(sacredStoriesCollectionProvider(null));
        final deitiesAsync = ref.watch(deitiesProvider);
        final allTexts = textsAsync.valueOrNull ?? [];
        final allStories = storiesAsync.valueOrNull ?? [];
        final allDeities = deitiesAsync.valueOrNull ?? [];

        return FutureBuilder<_LastViewedData>(
          future: _loadLastViewedData(allTexts, allStories, allDeities),
          builder: (context, snapshot) {
            final data = snapshot.data;
            final recentBooks = data?.books ?? [];
            final recentTexts = data?.texts ?? [];
            final recentStories = data?.stories ?? [];
            final recentDeities = data?.deities ?? [];
            return _buildLastViewedSectionContent(
              recentBooks: recentBooks,
              recentTexts: recentTexts,
              recentStories: recentStories,
              recentDeities: recentDeities,
            );
          },
        );
      },
    );
  }

  Future<_LastViewedData> _loadLastViewedData(
    List<SacredTextModel> allTexts,
    List<SacredStoryModel> allStories,
    List<DeityModel> allDeities,
  ) async {
    final recent = GranthalayaRecentService();
    final bookIds = await recent.getRecentBookIds();
    final textIds = await recent.getRecentSacredTextIds();
    final storyIds = await recent.getRecentSacredStoryIds();
    final deitySlugs = await recent.getRecentDeitySlugs();
    final books = <BookModel>[];
    for (final id in bookIds) {
      final b = _books.where((b) => b.id == id).toList();
      if (b.isNotEmpty) books.add(b.first);
    }
    final texts = <SacredTextModel>[];
    for (final id in textIds) {
      final t = allTexts.where((t) => t.id == id).toList();
      if (t.isNotEmpty) texts.add(t.first);
    }
    final stories = <SacredStoryModel>[];
    for (final id in storyIds) {
      final s = allStories.where((s) => s.id == id).toList();
      if (s.isNotEmpty) stories.add(s.first);
    }
    final deities = <DeityModel>[];
    for (final slug in deitySlugs) {
      final d = allDeities.where((d) => d.slug == slug).toList();
      if (d.isNotEmpty) deities.add(d.first);
    }
    return _LastViewedData(
      books: books,
      texts: texts,
      stories: stories,
      deities: deities,
    );
  }

  Widget _buildLastViewedSectionContent({
    required List<BookModel> recentBooks,
    required List<SacredTextModel> recentTexts,
    required List<SacredStoryModel> recentStories,
    required List<DeityModel> recentDeities,
  }) {
    final hasAny = recentBooks.isNotEmpty ||
        recentTexts.isNotEmpty ||
        recentStories.isNotEmpty ||
        recentDeities.isNotEmpty;

    if (!hasAny) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'Last Viewed',
                  style: GoogleFonts.crimsonPro(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matteGold.withOpacity(0.9),
                  ),
                ),
                Text(
                  'Books, texts, stories & more',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matteGold.withOpacity(0.4),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 320,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              children: [
                ...recentBooks.map((b) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildInProgressCard(b),
                    )),
                ...recentTexts.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildInProgressSacredTextCard(t),
                    )),
                ...recentStories.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildInProgressStoryCard(s),
                    )),
                ...recentDeities.map((d) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildInProgressDeityCard(d),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressSacredTextCard(SacredTextModel text) {
    final deityColors = _getTextDeityGradient(text.deitySlug);
    final godName = _capitalize(text.deitySlug ?? '');
    final coverUrl = text.coverImageUrl;
    final hasCoverImage = coverUrl != null && coverUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SacredTextReaderScreen(sacredText: text),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: deityColors[0].withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasCoverImage)
                  AppNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    cacheFailure: true,
                    fallback: AntarmargPlaceholder(
                        compact: true, godName: godName.isEmpty ? null : godName),
                  )
                else
                  AntarmargPlaceholder(
                      compact: true, godName: godName.isEmpty ? null : godName),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          text.typeLabel,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.matteGold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          text.title,
                          style: GoogleFonts.crimsonPro(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInProgressStoryCard(SacredStoryModel story) {
    final gradientColors = _getStoryGradient(story.category);
    final godName = _capitalize(story.deitySlug ?? '');
    final coverUrl = story.coverImageUrl;
    final hasImage = coverUrl != null && coverUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SacredStoryReaderScreen(story: story),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: gradientColors[0].withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  AppNetworkImage(
                    imageUrl: coverUrl!,
                    fit: BoxFit.cover,
                    cacheFailure: true,
                    fallback: AntarmargPlaceholder(
                        compact: true, godName: godName.isEmpty ? null : godName),
                  )
                else
                  AntarmargPlaceholder(
                      compact: true, godName: godName.isEmpty ? null : godName),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          story.category.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.matteGold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          story.title,
                          style: GoogleFonts.crimsonPro(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInProgressDeityCard(DeityModel deity) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeityDetailScreen(deity: deity),
          ),
        ),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 120,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getDeityGradient(deity.slug)[0].withOpacity(0.8),
                      _getDeityGradient(deity.slug)[1].withOpacity(0.3),
                    ],
                  ),
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.manuscriptDark,
                  ),
                  child: ClipOval(
                    child: deity.imageUrl != null && deity.imageUrl!.isNotEmpty
                        ? AppNetworkImage(
                            imageUrl: deity.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                color: AppColors.matteGold,
                                size: 32,
                              ),
                          )
                        : Icon(
                            Icons.person,
                            color: AppColors.matteGold,
                            size: 32,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                deity.name,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.matteGold.withOpacity(0.9),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInProgressCard(BookModel book) {
    final coverUrl = book.coverImageUrl?.isNotEmpty == true
        ? book.coverImageUrl
        : _getCoverUrl(book.id);
    final progress = book.progress.clamp(0.0, 1.0);
    final percent = (progress * 100).round();
    final tag = _getBookTag(book);
    final subtitle = _getInProgressSubtitle(book);
    final isLocked = book.isPremium && !_isPremium;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked
            ? () => navigateToProfileForProUpgrade(context)
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => BookDetailScreen(book: book)),
                ).then((_) => _loadBooks()),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 260,
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.matteGold.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (coverUrl != null && coverUrl.isNotEmpty)
                  AppNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    cacheFailure: true,
                    fallback: const AntarmargPlaceholder(),
                  )
                else
                  const AntarmargPlaceholder(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.matteGold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.name,
                          style: GoogleFonts.crimsonPro(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.matteGold.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _getProgressLabel(book),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              '$percent% Complete',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.matteGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildProgressBar(progress),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInProgressSubtitle(BookModel book) {
    final nextChapter = (book.completedChapters) + 1;
    final total = book.totalChapters;
    switch (book.id.toLowerCase()) {
      case 'bhagavad_gita':
      case 'geeta':
        return 'Chapter $nextChapter of $total';
      case 'ramayana':
      case 'ramayan':
        return nextChapter <= 7 ? 'Kanda $nextChapter' : 'Chapter $nextChapter';
      case 'mahabharata':
        return 'Parva $nextChapter';
      default:
        return 'Chapter $nextChapter of $total';
    }
  }

  String _getProgressLabel(BookModel book) {
    switch (book.id.toLowerCase()) {
      case 'bhagavad_gita':
      case 'geeta':
        return 'Shlok ${(book.completedChapters * 10).clamp(1, 700)} / ${book.totalChapters * 40}';
      case 'ramayana':
      case 'ramayan':
        return 'Sarga ${(book.completedChapters * 17).clamp(1, 119)} of 119';
      default:
        return 'Chapter ${book.completedChapters + 1} / ${book.totalChapters}';
    }
  }

  Widget _buildProgressBar(double progress) {
    final p = progress.clamp(0.0, 1.0);
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (p > 0)
                SizedBox(
                  width: constraints.maxWidth * p,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFC5A059),
                          Color(0xFFE2C999),
                          Color(0xFFC5A059)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.matteGold.withOpacity(0.4),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListenContent() {
    if (!_isPremium) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        GranthalayaAudioProgressSync(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: GranthalayaAudioContent(
                  onPlay: (info) async {
                    await ref.read(nowPlayingProvider.notifier).setTrackAndPlay(
                          title: info.title,
                          subtitle: info.subtitle,
                          coverUrl: info.coverUrl,
                          audioUrl: info.audioUrl,
                        );
                    await ref.read(granthalayaDataSourceProvider).upsertUserAudioProgress(
                          title: info.title,
                          tag: info.subtitle ?? '',
                          subtitle: info.subtitle,
                          imageUrl: info.coverUrl,
                          audioUrl: info.audioUrl,
                          currentTimeSeconds: 0,
                          totalTimeSeconds: 0,
                        );
                    ref.invalidate(userAudioProgressProvider);
                  },
                ),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(nowPlayingProvider);
                  if (state == null) return const SizedBox.shrink();
                  return GranthalayaAudioMiniPlayer(
                    onClose: () => ref.read(nowPlayingProvider.notifier).clear(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const _sacredCategories = [
    'All Texts',
    'Puranas',
    'Vedas',
    'Upanishads'
  ];

  List<BookModel> get _filteredBooks {
    if (_sacredLibraryCategoryIndex == 0) return _books;
    final cat = _sacredCategories[_sacredLibraryCategoryIndex].toLowerCase();
    return _books
        .where((b) =>
            b.category.toLowerCase().contains(cat) ||
            b.name.toLowerCase().contains(cat) ||
            (cat == 'puranas' &&
                (b.id.toLowerCase().contains('purana') ||
                    b.name.toLowerCase().contains('purana'))) ||
            (cat == 'vedas' &&
                (b.id.toLowerCase().contains('veda') ||
                    b.name.toLowerCase().contains('veda'))) ||
            (cat == 'upanishads' &&
                (b.id.toLowerCase().contains('upanishad') ||
                    b.name.toLowerCase().contains('upanishad'))))
        .toList();
  }

  Widget _buildSacredLibraryBooksRow() {
    if (_isLoading) {
      return const SizedBox(
        height: 175,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.matteGold),
        ),
      );
    }
    if (_sacredLibraryCategoryIndex > 0 && _filteredBooks.isEmpty) {
      final categoryName = _sacredCategories[_sacredLibraryCategoryIndex];
      return SizedBox(
        height: 175,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Coming soon',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.matteGold.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$categoryName texts will appear here when available.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.zinc500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 175,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: _filteredBooks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) => _buildSacredLibraryCard(_filteredBooks[i]),
      ),
    );
  }

  Widget _buildSacredLibrarySection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sacred Library',
                  style: GoogleFonts.crimsonPro(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matteGold.withOpacity(0.9),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.matteGold.withOpacity(0.2)),
                      ),
                      child: Icon(Icons.tune,
                          size: 16,
                          color: AppColors.matteGold.withOpacity(0.6)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: _sacredCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final isActive = i == _sacredLibraryCategoryIndex;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        setState(() => _sacredLibraryCategoryIndex = i),
                    borderRadius: BorderRadius.circular(999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isActive ? AppColors.matteGold : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isActive
                              ? AppColors.matteGold
                              : AppColors.matteGold.withOpacity(0.2),
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                    color: AppColors.matteGold.withOpacity(0.2),
                                    blurRadius: 8)
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          _sacredCategories[i],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.black
                                : AppColors.matteGold.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSacredLibraryBooksRow(),
        ],
      ),
    );
  }

  // ── Deity gradient colors for book title covers ──
  static const _deityGradients = <String, List<Color>>{
    'shiva': [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    'krishna': [Color(0xFF0E7490), Color(0xFF0891B2)],
    'hanuman': [Color(0xFFEA580C), Color(0xFFF59E0B)],
    'ganesha': [Color(0xFFE11D48), Color(0xFFF43F5E)],
  };

  List<Color> _getDeityGradient(String? slug) {
    if (slug == null) return const [Color(0xFFC5A059), Color(0xFFA88B3D)];
    return _deityGradients[slug.toLowerCase()] ??
        const [Color(0xFFC5A059), Color(0xFFA88B3D)];
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  // ── Story category icon mapping ──
  static const _storyCategoryIcons = <String, IconData>{
    'wisdom': Icons.psychology,
    'devotion': Icons.favorite,
    'faith': Icons.volunteer_activism,
    'values': Icons.balance,
    'service': Icons.handshake,
    'karma': Icons.loop,
    'compassion': Icons.spa,
    'sacrifice': Icons.local_fire_department,
    'patience': Icons.hourglass_bottom,
    'humility': Icons.self_improvement,
    'focus': Icons.center_focus_strong,
    'discipline': Icons.fitness_center,
    'courage': Icons.shield,
    'determination': Icons.flag,
  };

  static const _storyCategoryGradients = <String, List<Color>>{
    'wisdom': [Color(0xFF6366F1), Color(0xFF4F46E5)],
    'devotion': [Color(0xFFEC4899), Color(0xFFDB2777)],
    'faith': [Color(0xFFF59E0B), Color(0xFFD97706)],
    'values': [Color(0xFF10B981), Color(0xFF059669)],
    'service': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    'karma': [Color(0xFFF97316), Color(0xFFEA580C)],
  };

  List<Color> _getStoryGradient(String category) {
    return _storyCategoryGradients[category.toLowerCase()] ??
        const [Color(0xFFC5A059), Color(0xFFA88B3D)];
  }

  Widget _buildSacredStoriesSection() {
    return Consumer(
      builder: (context, ref, _) {
        final storiesAsync = ref.watch(sacredStoriesCollectionProvider(null));
        final allStories = storiesAsync.valueOrNull ?? [];
        // Show only top 5 featured/ordered stories
        final stories = allStories.take(5).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sacred Stories',
                          style: GoogleFonts.crimsonPro(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.matteGold.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${allStories.length} stories',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.zinc500,
                          ),
                        ),
                      ],
                    ),
                    if (allStories.length > 5)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllSacredStoriesScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.matteGold.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View All',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.matteGold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward,
                                  size: 14, color: AppColors.matteGold),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (storiesAsync.isLoading)
                const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.matteGold),
                  ),
                )
              else if (stories.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalCard,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'No stories available yet.',
                        style: GoogleFonts.inter(
                          color: AppColors.zinc500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: stories.length,
                    itemBuilder: (_, i) => _buildSacredStoryCard(stories[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoryCategoryChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.matteGold : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive
                  ? AppColors.matteGold
                  : AppColors.matteGold.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? Colors.black
                    : AppColors.matteGold.withOpacity(0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSacredStoryCard(SacredStoryModel story) {
    final gradientColors = _getStoryGradient(story.category);
    final deityColors = _getDeityGradient(story.deitySlug);
    final deityName = _capitalize(story.deitySlug ?? '');
    final coverUrl = story.coverImageUrl;
    final hasImage = coverUrl != null && coverUrl.isNotEmpty;
    final pageCount = story.pages.length;
    final isLocked = story.isPremium && !_isPremium;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked
            ? () => navigateToProfileForProUpgrade(context)
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SacredStoryReaderScreen(story: story),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(20),
        child: Opacity(
          opacity: isLocked ? 0.6 : 1.0,
          child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.matteGold.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background: cover image or deity name book-cover
                if (hasImage)
                  AppNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    cacheFailure: true,
                    fallback: _buildDeityNameCover(deityName, deityColors),
                  )
                else
                  _buildDeityNameCover(deityName, deityColors),
                // Bottom gradient overlay for readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.88),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                // Bottom content
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: gradientColors[0].withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _capitalize(story.category),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        story.title,
                        style: GoogleFonts.crimsonPro(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (story.titleHindi != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          story.titleHindi!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.matteGold.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 11,
                              color: AppColors.matteGold.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(
                            '${story.estimatedMinutes} min • $pageCount pages',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.matteGold.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isLocked)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock,
                              color: Colors.white, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            'PRO',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  /// Book-cover style: Antar मार्ग title in gradient golden/black + God name below.
  Widget _buildDeityNameCover(String deityName, List<Color> colors) {
    return AntarmargPlaceholder(
      compact: false,
      godName: deityName.isEmpty ? null : deityName,
    );
  }

  Widget _buildChantsSection() {
    return Consumer(
      builder: (context, ref, _) {
        final chantsAsync = ref.watch(chantsProvider);
        final chants = chantsAsync.valueOrNull ?? [];
        if (chants.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Chants',
                  style: GoogleFonts.crimsonPro(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matteGold.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: chants.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, i) => _buildChantCard(chants[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChantCard(ChantModel chant) {
    final imageUrl = chant.imageUrl ??
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (chant.effectiveAudioUrl.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullAudioPlayerScreen(
                  title: chant.title,
                  subtitle: chant.subtitle,
                  coverImageUrl: imageUrl,
                  audioUrl: chant.effectiveAudioUrl,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.charcoalCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.charcoalBorder),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: AppNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.manuscriptDark,
                      child: const Icon(
                        Icons.music_note,
                        color: AppColors.matteGold,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chant.title,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chant.subtitle ?? chant.durationFormatted,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.zinc500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.play_circle_fill,
                          color: AppColors.matteGold,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Play',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.matteGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSacredLibraryCard(BookModel book) {
    final coverUrl = book.coverImageUrl?.isNotEmpty == true
        ? book.coverImageUrl
        : _getCoverUrl(book.id);
    final subtitle = _getSacredLibrarySubtitle(book);
    final isLocked = book.isPremium && !_isPremium;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked
            ? () => navigateToProfileForProUpgrade(context)
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => BookDetailScreen(book: book)),
                ).then((_) => _loadBooks()),
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isLocked ? 0.6 : 1.0,
          child: SizedBox(
            width: 200,
            height: 175,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (coverUrl != null && coverUrl.isNotEmpty)
                          AppNetworkImage(
                            imageUrl: coverUrl,
                            fit: BoxFit.cover,
                            cacheFailure: true,
                            fallback: const AntarmargPlaceholder(),
                          )
                        else
                          const AntarmargPlaceholder(),
                        Container(color: Colors.black.withOpacity(0.2)),
                        if (isLocked)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37)
                                    .withOpacity(0.85),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.lock,
                                      color: Colors.white, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PRO',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: GoogleFonts.crimsonPro(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF1F5F9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.matteGold.withOpacity(0.5),
                          letterSpacing: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  String _getSacredLibrarySubtitle(BookModel book) {
    switch (book.id.toLowerCase()) {
      case 'bhagavad_gita':
      case 'geeta':
        return '18 Chapters • The Divine Song';
      case 'ramayana':
      case 'ramayan':
        return '7 Kandas • The Journey';
      case 'mahabharata':
        return '18 Parvas • Epic Chronicle';
      case 'shiva purana':
        return '12 Cantos • Eternal Wisdom';
      case 'rig veda':
      case 'vedas':
        return 'Mandala I-X • Ancient Hymns';
      default:
        return book.description.length > 40
            ? '${book.description.substring(0, 37)}...'
            : book.description;
    }
  }

  Widget _buildExploreDeitiesSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explore Deities',
                  style: GoogleFonts.crimsonPro(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.matteGold.withOpacity(0.9),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'See All',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.matteGold.withOpacity(0.6),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Consumer(
            builder: (context, ref, _) {
              final deitiesAsync = ref.watch(deitiesProvider);
              final deities = deitiesAsync.valueOrNull ?? [];
              if (deities.isEmpty) {
                final items = _deitiesFallback;
                return SizedBox(
                  height: 130,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 32),
                    itemBuilder: (_, i) {
                      final (name, url) = items[i];
                      return _buildDeityCircle(name, url, onTap: () {});
                    },
                  ),
                );
              }
              return SizedBox(
                height: 130,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: deities.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 32),
                  itemBuilder: (_, i) {
                    final d = deities[i];
                    return _buildDeityCircle(
                      d.name,
                      d.imageUrl ?? '',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeityDetailScreen(deity: d),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeityCircle(String name, String imageUrl, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.matteGold.withOpacity(0.8),
                    AppColors.matteGold.withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.matteGold.withOpacity(0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.manuscriptDark,
                ),
                child: ClipOval(
                  child: AppNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person,
                        color: AppColors.matteGold, size: 32),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.matteGold.withOpacity(0.8),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Deity gradient map for sacred text tiles
  static const _textDeityGradients = <String, List<Color>>{
    'shiva': [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    'krishna': [Color(0xFF0E7490), Color(0xFF0891B2)],
    'hanuman': [Color(0xFFEA580C), Color(0xFFF59E0B)],
    'ganesha': [Color(0xFFE11D48), Color(0xFFF43F5E)],
  };


  List<Color> _getTextDeityGradient(String? slug) {
    if (slug == null) return const [Color(0xFFC5A059), Color(0xFFA88B3D)];
    return _textDeityGradients[slug.toLowerCase()] ??
        const [Color(0xFFC5A059), Color(0xFFA88B3D)];
  }

  Widget _buildSacredTextsSection() {
    return Consumer(
      builder: (context, ref, _) {
        final textsAsync = ref.watch(sacredTextsProvider(null));
        final allTexts = textsAsync.valueOrNull ?? [];
        // Show only top 5
        final texts = allTexts.take(5).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sacred Texts',
                          style: GoogleFonts.crimsonPro(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.matteGold.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${allTexts.length} texts · Chalisas, Stotras & Mantras',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.zinc500,
                          ),
                        ),
                      ],
                    ),
                    if (allTexts.length > 5)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllSacredTextsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.matteGold.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View All',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.matteGold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward,
                                  size: 14, color: AppColors.matteGold),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (textsAsync.isLoading)
                const SizedBox(
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.matteGold),
                  ),
                )
              else if (texts.isEmpty)
                SizedBox(
                  height: 200,
                  child: Center(
                    child: SizedBox(
                      width: 160,
                      height: 180,
                      child: const AntarmargPlaceholder(compact: true),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const ClampingScrollPhysics(),
                    itemCount: texts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, i) => _buildSacredTextTile(texts[i]),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSacredTextTile(SacredTextModel text) {
    final deityColors = _getTextDeityGradient(text.deitySlug);
    final deityName = _capitalize(text.deitySlug ?? '');
    final coverUrl = text.coverImageUrl;
    final hasCoverImage = coverUrl != null && coverUrl.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SacredTextReaderScreen(sacredText: text),
        ),
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: deityColors[0].withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cover image or deity gradient background (cached for fast tab switching)
              if (hasCoverImage)
                AppNetworkImage(
                  imageUrl: coverUrl,
                  fit: BoxFit.cover,
                  cacheFailure: true,
                  fallback: _buildSacredTextGradientBg(deityColors, deityName),
                )
              else
                _buildSacredTextGradientBg(deityColors, deityName),
              // Bottom gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.92),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
              // Bottom content
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: deityColors[0].withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        text.typeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text.title,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (text.titleHindi != null) ...[                   
                      const SizedBox(height: 2),
                      Text(
                        text.titleHindi!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.matteGold.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (text.verseCount != null) ...[                       
                          Icon(Icons.format_list_numbered,
                              size: 11,
                              color: AppColors.matteGold.withOpacity(0.5)),
                          const SizedBox(width: 3),
                          Text(
                            '${text.verseCount} verses',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.matteGold.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSacredTextGradientBg(List<Color> deityColors, String deityName) {
    return AntarmargPlaceholder(
      compact: true,
      godName: deityName.isEmpty ? null : deityName,
    );
  }

  Widget _buildResourceLibrarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 2,
                color: AppColors.matteGold.withOpacity(0.3),
              ),
              const SizedBox(width: 12),
              Text(
                'Resource Library',
                style: GoogleFonts.crimsonPro(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.matteGold.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Consumer(
            builder: (context, ref, _) {
              final cardsAsync = ref.watch(resourceCardsProvider);
              final cards = cardsAsync.valueOrNull ?? [];
              final fallback = [
                ResourceCardModel(
                    id: '1',
                    title: 'Terminology',
                    subtitle: 'Sanskrit Glossary',
                    iconName: 'menu_book'),
                ResourceCardModel(
                    id: '2',
                    title: 'Pronunciation',
                    subtitle: 'Chanting Rules',
                    iconName: 'record_voice_over'),
              ];
              final items = cards.isNotEmpty ? cards : fallback;
              return Row(
                children: [
                  if (items.isNotEmpty)
                    Expanded(
                      child: _buildResourceCard(
                        icon: _iconFromName(items[0].iconName),
                        title: items[0].title,
                        subtitle: items[0].subtitle,
                      ),
                    ),
                  if (items.length > 1) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildResourceCard(
                        icon: _iconFromName(items[1].iconName),
                        title: items[1].title,
                        subtitle: items[1].subtitle,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A1A1A).withOpacity(0.6),
                const Color(0xFF0F0F0F).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.matteGold.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.matteGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.matteGold, size: 22),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.matteGold.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeepDiveSection() {
    return Consumer(
      builder: (context, ref, _) {
        final deepDiveAsync = ref.watch(deepDiveProvider);
        final articles = deepDiveAsync.valueOrNull ?? [];
        final article = articles.isNotEmpty
            ? articles.first
            : DeepDiveModel(
                id: '1',
                title: "The Nature of 'Atman'",
                quote:
                    '"The Self is not born, nor does it ever die... Unborn, eternal, ever-existing, and primeval."',
                durationLabel: '4 min read',
              );
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 48),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(32),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1A1A1A).withOpacity(0.6),
                      const Color(0xFF0F0F0F).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppColors.matteGold.withOpacity(0.18),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(Icons.psychology,
                            size: 64, color: AppColors.matteGold),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.matteGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color:
                                        AppColors.matteGold.withOpacity(0.2)),
                              ),
                              child: Text(
                                'Deep Dive',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.matteGold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            Icon(Icons.share,
                                color: AppColors.matteGold.withOpacity(0.5),
                                size: 20),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          article.title,
                          style: GoogleFonts.crimsonPro(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.only(left: 16),
                          decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    color: AppColors.matteGold.withOpacity(0.2),
                                    width: 2)),
                          ),
                          child: Text(
                            article.quote,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF94A3B8),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.schedule,
                                    size: 16,
                                    color:
                                        AppColors.matteGold.withOpacity(0.4)),
                                const SizedBox(width: 8),
                                Text(
                                  article.durationLabel ?? '4 min read',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.matteGold.withOpacity(0.6),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.matteGold,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.matteGold.withOpacity(0.2),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Read Article',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

class _LastViewedData {
  final List<BookModel> books;
  final List<SacredTextModel> texts;
  final List<SacredStoryModel> stories;
  final List<DeityModel> deities;

  _LastViewedData({
    required this.books,
    required this.texts,
    required this.stories,
    required this.deities,
  });
}
