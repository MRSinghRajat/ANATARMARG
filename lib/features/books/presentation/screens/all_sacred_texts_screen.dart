import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/antarmarg_placeholder.dart';
import '../../data/models/granthalaya_models.dart';
import '../providers/book_providers.dart';
import 'sacred_text_reader_screen.dart';

/// Full-page view of all sacred texts with search, filter, and pagination.
class AllSacredTextsScreen extends ConsumerStatefulWidget {
  const AllSacredTextsScreen({super.key});

  @override
  ConsumerState<AllSacredTextsScreen> createState() =>
      _AllSacredTextsScreenState();
}

class _AllSacredTextsScreenState extends ConsumerState<AllSacredTextsScreen> {
  String _searchQuery = '';
  String? _selectedType;
  String? _selectedDeity;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Pagination
  static const int _pageSize = 10;
  int _currentPage = 0;

  // Deity gradient map
  static const _deityGradients = <String, List<Color>>{
    'shiva': [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    'krishna': [Color(0xFF0E7490), Color(0xFF0891B2)],
    'hanuman': [Color(0xFFEA580C), Color(0xFFF59E0B)],
    'ganesha': [Color(0xFFE11D48), Color(0xFFF43F5E)],
  };

  // Type gradient map
  static const _typeGradients = <String, List<Color>>{
    'chalisa': [Color(0xFFD97706), Color(0xFFF59E0B)],
    'stotra': [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
    'mantra': [Color(0xFF059669), Color(0xFF10B981)],
    'aarti': [Color(0xFFE11D48), Color(0xFFF43F5E)],
    'stuti': [Color(0xFF0284C7), Color(0xFF0EA5E9)],
    'suktam': [Color(0xFF9333EA), Color(0xFFA855F7)],
    'kavach': [Color(0xFF65A30D), Color(0xFF84CC16)],
    'sahasranama': [Color(0xFFB45309), Color(0xFFD97706)],
  };

  List<Color> _getDeityGradient(String? slug) {
    if (slug == null) return const [Color(0xFFC5A059), Color(0xFFA88B3D)];
    return _deityGradients[slug.toLowerCase()] ??
        const [Color(0xFFC5A059), Color(0xFFA88B3D)];
  }

  List<Color> _getTypeGradient(String type) {
    return _typeGradients[type.toLowerCase()] ??
        const [Color(0xFFC5A059), Color(0xFFA88B3D)];
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textsAsync = ref.watch(sacredTextsProvider(null));
    final allTexts = textsAsync.valueOrNull ?? [];

    // Extract unique types & deities for filter chips
    final types = allTexts.map((t) => t.type).toSet().toList()..sort();
    final deities = allTexts
        .map((t) => t.deitySlug)
        .where((d) => d != null && d.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();

    // Apply filters
    var filtered = allTexts.toList();
    if (_selectedType != null) {
      filtered = filtered.where((t) => t.type == _selectedType).toList();
    }
    if (_selectedDeity != null) {
      filtered = filtered
          .where((t) =>
              t.deitySlug?.toLowerCase() == _selectedDeity!.toLowerCase())
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              (t.titleHindi ?? '').contains(q) ||
              (t.deitySlug ?? '').toLowerCase().contains(q) ||
              t.typeLabel.toLowerCase().contains(q))
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
          ref.invalidate(sacredTextsProvider);
          ref.invalidate(featuredSacredTextsProvider);
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
          SliverToBoxAdapter(child: _buildFilterChips(types, deities)),
          if (textsAsync.isLoading)
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
                      'No texts match your filters',
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
                  (context, i) => _buildTextCard(paged[i]),
                  childCount: paged.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
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
          child: Icon(Icons.arrow_back, color: AppColors.matteGold, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sacred Texts',
            style: GoogleFonts.crimsonPro(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.matteGold,
            ),
          ),
          Text(
            'चालीसा, स्तोत्र एवं मंत्र',
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
            hintText: 'Search chalisas, mantras, aartis...',
            hintStyle:
                GoogleFonts.inter(color: AppColors.zinc500, fontSize: 13),
            prefixIcon: Icon(Icons.search,
                color: AppColors.matteGold.withOpacity(0.6), size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon:
                        Icon(Icons.close, color: AppColors.zinc500, size: 18),
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

  Widget _buildFilterChips(List<String> types, List<String> deities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chip('All', _selectedType == null, () {
                setState(() {
                  _selectedType = null;
                  _currentPage = 0;
                });
              }),
              const SizedBox(width: 8),
              ...types.map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child:
                        _typeChip(_capitalize(t), t, _selectedType == t),
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
            color:
                isActive ? Colors.black : AppColors.matteGold.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label, String type, bool isActive) {
    final colors = _getTypeGradient(type);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = _selectedType == type ? null : type;
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
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.white : colors[0].withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 6),
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

  // ── Card ──
  Widget _buildTextCard(SacredTextModel text) {
    final deityColors = _getDeityGradient(text.deitySlug);
    final typeColors = _getTypeGradient(text.type);
    final deityName = _capitalize(text.deitySlug ?? '');
    final coverUrl = text.coverImageUrl;
    final hasCoverImage = coverUrl != null && coverUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SacredTextReaderScreen(sacredText: text),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
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
                    fallback: _buildDeityGradientCover(deityName, deityColors),
                  )
                else
                  _buildDeityGradientCover(deityName, deityColors),
                // Bottom gradient for readability
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
                // Content at bottom
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
                          color: typeColors[0].withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: typeColors[0].withOpacity(0.2)),
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
                          fontSize: 15,
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
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.matteGold.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (text.verseCount != null) ...[
                            Icon(Icons.format_list_numbered,
                                size: 11,
                                color: AppColors.matteGold.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(
                              '${text.verseCount} verses',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.matteGold.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(Icons.signal_cellular_alt,
                              size: 10,
                              color: AppColors.matteGold.withOpacity(0.4)),
                          const SizedBox(width: 3),
                          Text(
                            _capitalize(text.difficulty),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.matteGold.withOpacity(0.5),
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
      ),
    );
  }

  /// Deity gradient background with Om watermark and deity name. Shows "Antar मार्ग" when empty.
  Widget _buildDeityGradientCover(String deityName, List<Color> colors) {
    final displayName = deityName.isEmpty ? 'Antar मार्ग' : deityName;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0].withOpacity(0.28),
            colors[1].withOpacity(0.14),
            AppColors.charcoalDark,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative book-style border
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
          // Om watermark
          Positioned(
            right: 12,
            top: 14,
            child: Text(
              'ॐ',
              style: TextStyle(
                fontSize: 28,
                color: colors[0].withOpacity(0.12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Deity name centered
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 42),
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
                    fontSize: 30,
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

  // ── Pagination ──
  Widget _buildPagination(int total, int totalPages) {
    if (totalPages <= 1) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Center(
          child: Text(
            '$total texts',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.zinc500),
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
            style:
                GoogleFonts.inter(fontSize: 11, color: AppColors.zinc500),
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
                            color:
                                isActive ? Colors.black : AppColors.zinc500,
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
            color: enabled
                ? AppColors.matteGold.withOpacity(0.3)
                : AppColors.charcoalBorder,
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
      _selectedType = null;
      _selectedDeity = null;
      _searchQuery = '';
      _searchController.clear();
      _currentPage = 0;
    });
  }
}
