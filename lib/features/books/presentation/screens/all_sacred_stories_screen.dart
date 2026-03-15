import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/antarmarg_placeholder.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import '../../data/models/granthalaya_models.dart';
import '../providers/book_providers.dart';
import 'sacred_story_reader_screen.dart';

/// Full-page view of all sacred stories with search, filter, and pagination.
class AllSacredStoriesScreen extends ConsumerStatefulWidget {
  const AllSacredStoriesScreen({super.key});

  @override
  ConsumerState<AllSacredStoriesScreen> createState() =>
      _AllSacredStoriesScreenState();
}

class _AllSacredStoriesScreenState
    extends ConsumerState<AllSacredStoriesScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedDeity;
  bool _isPremium = false;
  StreamSubscription<bool>? _premiumSubscription;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Pagination
  static const int _pageSize = 10;
  int _currentPage = 0;

  // Deity gradient map for cover cards
  static const _deityGradients = <String, List<Color>>{
    'shiva': [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    'krishna': [Color(0xFF0E7490), Color(0xFF0891B2)],
    'hanuman': [Color(0xFFEA580C), Color(0xFFF59E0B)],
    'ganesha': [Color(0xFFE11D48), Color(0xFFF43F5E)],
  };

  // Category gradient map
  static const _categoryGradients = <String, List<Color>>{
    'mythology': [Color(0xFFC5A059), Color(0xFFA88B3D)],
    'leela': [Color(0xFF10B981), Color(0xFF059669)],
    'moral': [Color(0xFF6366F1), Color(0xFF4F46E5)],
  };

  List<Color> _getDeityGradient(String? slug) {
    if (slug == null) return const [Color(0xFFC5A059), Color(0xFFA88B3D)];
    return _deityGradients[slug.toLowerCase()] ??
        const [Color(0xFFC5A059), Color(0xFFA88B3D)];
  }

  List<Color> _getCategoryGradient(String category) {
    return _categoryGradients[category.toLowerCase()] ??
        const [Color(0xFFC5A059), Color(0xFFA88B3D)];
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _getDeityDisplayName(String? slug) {
    if (slug == null || slug.isEmpty) return '';
    return _capitalize(slug);
  }

  @override
  void initState() {
    super.initState();
    PremiumService.instance.isPremium.then((v) {
      if (mounted) setState(() => _isPremium = v);
    });
    _premiumSubscription = PremiumService.instance.premiumStatusStream.listen((v) {
      if (mounted) setState(() => _isPremium = v);
    });
  }

  @override
  void dispose() {
    _premiumSubscription?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(sacredStoriesCollectionProvider(null));
    final categoriesAsync = ref.watch(sacredStoryCategoriesProvider);
    final allStories = storiesAsync.valueOrNull ?? [];
    final categories = categoriesAsync.valueOrNull ?? [];

    // Extract unique deities
    final deities = allStories
        .map((s) => s.deitySlug)
        .where((d) => d != null && d.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();

    // Apply filters
    var filtered = allStories.toList();
    if (_selectedCategory != null) {
      filtered =
          filtered.where((s) => s.category == _selectedCategory).toList();
    }
    if (_selectedDeity != null) {
      filtered = filtered
          .where((s) =>
              s.deitySlug?.toLowerCase() == _selectedDeity!.toLowerCase())
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((s) =>
              s.title.toLowerCase().contains(q) ||
              (s.titleHindi ?? '').contains(q) ||
              (s.deitySlug ?? '').toLowerCase().contains(q) ||
              (s.source ?? '').toLowerCase().contains(q) ||
              (s.keyTeaching ?? '').toLowerCase().contains(q))
          .toList();
    }

    // Pagination
    final totalPages = (filtered.length / _pageSize).ceil();
    if (_currentPage >= totalPages && totalPages > 0) {
      _currentPage = totalPages - 1;
    }
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, filtered.length);
    final paged = filtered.sublist(start, end);

    return Scaffold(
      backgroundColor: AppColors.charcoalDark,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sacredStoriesCollectionProvider);
          ref.invalidate(sacredStoryCategoriesProvider);
        },
        color: AppColors.matteGold,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(
              child: _buildFilterChips(categories, deities)),
          if (storiesAsync.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.matteGold),
              ),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: const AntarmargPlaceholder(compact: true),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No stories match your filters',
                      style: GoogleFonts.inter(
                          color: AppColors.zinc500, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text('Clear all filters',
                          style: GoogleFonts.inter(
                              color: AppColors.matteGold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final story = paged[i];
                    final isLocked =
                        !_isPremium && story.isPremium;
                    return _buildStoryCard(story, isLocked: isLocked);
                  },
                  childCount: paged.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildPagination(filtered.length, totalPages),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.charcoalDark,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: AppColors.matteGold.withOpacity(0.15)),
          ),
          child:
              Icon(Icons.arrow_back, color: AppColors.matteGold, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sacred Stories',
            style: GoogleFonts.crimsonPro(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.matteGold,
            ),
          ),
          Text(
            'पवित्र कथाएँ',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.matteGold.withOpacity(0.5),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _clearFilters,
          icon: Icon(Icons.filter_alt_off,
              color: AppColors.matteGold.withOpacity(0.5), size: 20),
          tooltip: 'Clear filters',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.charcoalCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.charcoalBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
              _currentPage = 0;
            });
          },
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search stories, deities, teachings...',
            hintStyle:
                GoogleFonts.inter(color: AppColors.zinc500, fontSize: 13),
            prefixIcon: Icon(Icons.search,
                color: AppColors.matteGold.withOpacity(0.6), size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close,
                        color: AppColors.zinc500, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _currentPage = 0;
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<String> categories, List<String> deities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chip('All', _selectedCategory == null, () {
                setState(() {
                  _selectedCategory = null;
                  _currentPage = 0;
                });
              }),
              const SizedBox(width: 8),
              ...categories.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _chip(_capitalize(c), _selectedCategory == c, () {
                      setState(() {
                        _selectedCategory =
                            _selectedCategory == c ? null : c;
                        _currentPage = 0;
                      });
                    }),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Deity chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _deityChip('All Deities', null, _selectedDeity == null),
              const SizedBox(width: 8),
              ...deities.map((d) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _deityChip(
                      _capitalize(d),
                      d,
                      _selectedDeity?.toLowerCase() == d.toLowerCase(),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _chip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : AppColors.matteGold.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _deityChip(String label, String? deity, bool isActive) {
    final colors = deity != null
        ? _getDeityGradient(deity)
        : [AppColors.matteGold, AppColors.matteGold];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeity = _selectedDeity == deity ? null : deity;
          _currentPage = 0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(colors: [colors[0], colors[1]])
              : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? colors[0] : colors[0].withOpacity(0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (deity != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.white : colors[0].withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : AppColors.matteGold.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(SacredStoryModel story, {bool isLocked = false}) {
    final deityName = _getDeityDisplayName(story.deitySlug);
    final deityColors = _getDeityGradient(story.deitySlug);
    final catColors = _getCategoryGradient(story.category);
    final coverUrl = story.coverImageUrl;
    final hasImage = coverUrl != null && coverUrl.isNotEmpty;
    final pageCount = story.pages.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked
            ? () => PaywallScreen.showAsBottomSheet(context)
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
                // Background: cover image or deity name gradient (cached for fast tab switching)
                if (hasImage)
                  AppNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    cacheFailure: true,
                    fallback: _buildDeityNameCover(deityName, deityColors),
                  )
                else
                  _buildDeityNameCover(deityName, deityColors),
                // Bottom gradient overlay
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
                // Content
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: catColors[0].withOpacity(0.3),
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

  /// Deity name as a book title page in gradient. Shows "Antar मार्ग" when empty.
  Widget _buildDeityNameCover(String deityName, List<Color> colors) {
    final displayName = deityName.isEmpty ? 'Antar मार्ग' : deityName;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0].withOpacity(0.25),
            colors[1].withOpacity(0.12),
            AppColors.charcoalDark,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative border lines (book-style)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors[0].withOpacity(0.15),
                  width: 1,
                ),
              ),
            ),
          ),
          // Om symbol watermark
          Positioned(
            right: 10,
            top: 12,
            child: Text(
              'ॐ',
              style: TextStyle(
                fontSize: 28,
                color: colors[0].withOpacity(0.12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Deity first name centered
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors[0],
                    colors[1],
                    Colors.white.withOpacity(0.8),
                  ],
                ).createShader(bounds),
                child: Text(
                  displayName,
                  style: GoogleFonts.crimsonPro(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(int total, int totalPages) {
    if (totalPages <= 1) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Center(
          child: Text(
            '$total stories',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.zinc500,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          Text(
            'Showing ${_currentPage * _pageSize + 1}–${(_currentPage * _pageSize + _pageSize).clamp(0, total)} of $total',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.zinc500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _paginationButton(
                icon: Icons.chevron_left,
                enabled: _currentPage > 0,
                onTap: () {
                  setState(() => _currentPage--);
                  _scrollToTop();
                },
              ),
              const SizedBox(width: 8),
              ...List.generate(totalPages, (i) {
                if (totalPages > 7 &&
                    i != 0 &&
                    i != totalPages - 1 &&
                    (i - _currentPage).abs() > 1) {
                  if (i == _currentPage - 2 || i == _currentPage + 2) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text('·',
                          style: GoogleFonts.inter(
                              color: AppColors.zinc500, fontSize: 16)),
                    );
                  }
                  return const SizedBox.shrink();
                }
                final isActive = i == _currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _currentPage = i);
                      _scrollToTop();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.matteGold
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? AppColors.matteGold
                              : AppColors.charcoalBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.black : AppColors.zinc500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              _paginationButton(
                icon: Icons.chevron_right,
                enabled: _currentPage < totalPages - 1,
                onTap: () {
                  setState(() => _currentPage++);
                  _scrollToTop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? AppColors.matteGold.withOpacity(0.3) : AppColors.charcoalBorder,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? AppColors.matteGold
              : AppColors.zinc500.withOpacity(0.3),
        ),
      ),
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDeity = null;
      _searchQuery = '';
      _searchController.clear();
      _currentPage = 0;
    });
  }
}
