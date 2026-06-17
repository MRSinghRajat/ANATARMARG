import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/antarmarg_placeholder.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../shared/services/feature_gate_config.dart';
import '../../../../core/utils/profile_pro_upgrade_nav.dart';
import '../providers/book_providers.dart';
import '../providers/now_playing_provider.dart';
import '../../data/models/granthalaya_models.dart';
import '../../data/models/book_model.dart';

class AudioItemInfo {
  final String title;
  final String? subtitle;
  final String? coverUrl;
  final String duration;
  final String? audioUrl;

  const AudioItemInfo({
    required this.title,
    this.subtitle,
    this.coverUrl,
    this.duration = '0:00',
    this.audioUrl,
  });
}

class GranthalayaAudioContent extends ConsumerStatefulWidget {
  final ValueChanged<AudioItemInfo> onPlay;

  const GranthalayaAudioContent({super.key, required this.onPlay});

  @override
  ConsumerState<GranthalayaAudioContent> createState() => _GranthalayaAudioContentState();
}

class _GranthalayaAudioContentState extends ConsumerState<GranthalayaAudioContent> {
  bool _isPremium = false;
  StreamSubscription<bool>? _premiumSubscription;

  static const _deityGradients = <String, List<Color>>{
    'shiva': [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    'krishna': [Color(0xFF0E7490), Color(0xFF0891B2)],
    'hanuman': [Color(0xFFEA580C), Color(0xFFF59E0B)],
    'ganesha': [Color(0xFFE11D48), Color(0xFFF43F5E)],
    'vishnu': [Color(0xFF0284C7), Color(0xFF0EA5E9)],
    'devi': [Color(0xFFDB2777), Color(0xFFF472B6)],
    'rama': [Color(0xFF059669), Color(0xFF34D399)],
    'lakshmi': [Color(0xFFD97706), Color(0xFFFBBF24)],
  };

  static const _defaultGoldGradient = [Color(0xFFC5A059), Color(0xFFA88B3D)];

  static const _defaultImageUrl = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv';

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
    super.dispose();
  }

  List<Color> _getDeityGradient(String? slug) {
    if (slug == null || slug.isEmpty) return _defaultGoldGradient;
    return _deityGradients[slug.toLowerCase()] ?? _defaultGoldGradient;
  }

  void _showPaywall() {
    navigateToProfileForProUpgrade(context);
  }

  @override
  Widget build(BuildContext context) {
    final userProgressAsync = ref.watch(userAudioProgressProvider);
    final nowPlaying = ref.watch(nowPlayingProvider);
    final userItems = userProgressAsync.valueOrNull ?? [];
    final hasInProgress = nowPlaying != null || userItems.isNotEmpty;

    return ListView(
      physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(top: 8, bottom: 140),
      children: [
        if (hasInProgress) ...[
          _buildInProgressSection(),
          const SizedBox(height: 48),
        ],
        _buildSacredTextsAudioSection(),
        const SizedBox(height: 48),
        _buildAudiobooksSection(),
        const SizedBox(height: 48),
        _buildSacredStoriesAudioSection(),
        const SizedBox(height: 48),
        _buildChantsSection(),
        const SizedBox(height: 48),
        _buildDivinePresenceSection(),
        const SizedBox(height: 48),
        _buildTodaysReflectionSection(),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  // IN PROGRESS (compact for imageless items)
  // ──────────────────────────────────────────────────────────

  bool _hasRealImage(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url == _defaultImageUrl) return false;
    return true;
  }

  Widget _buildInProgressSection() {
    final userProgressAsync = ref.watch(userAudioProgressProvider);
    final nowPlaying = ref.watch(nowPlayingProvider);
    final userItems = userProgressAsync.valueOrNull ?? [];

    List<({String tag, String title, String imageUrl, String current, String total, double progress, bool isActive, String? audioUrl})> displayItems = [];

    if (nowPlaying != null) {
      displayItems.add((
        tag: nowPlaying.subtitle ?? 'Now Playing',
        title: nowPlaying.title,
        imageUrl: nowPlaying.coverUrl ?? _defaultImageUrl,
        current: nowPlaying.positionFormatted,
        total: nowPlaying.duration.inMilliseconds > 0 ? nowPlaying.durationFormatted : '--:--',
        progress: nowPlaying.progress,
        isActive: true,
        audioUrl: nowPlaying.audioUrl,
      ));
    }

    for (final m in userItems) {
      if (nowPlaying != null && m.title == nowPlaying.title) continue;
      displayItems.add((
        tag: m.tag,
        title: m.title,
        imageUrl: m.imageUrl ?? _defaultImageUrl,
        current: m.currentFormatted,
        total: m.totalFormatted,
        progress: m.progress,
        isActive: false,
        audioUrl: m.audioUrl,
      ));
    }

    final hasLargeCards = displayItems.any((i) => _hasRealImage(i.imageUrl));
    final sectionHeight = hasLargeCards ? 448.0 : (displayItems.isEmpty ? 100.0 : 130.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keep Listening',
                    style: GoogleFonts.cinzel(
                      fontSize: 10,
                      color: AppColors.matteGold.withValues(alpha: 0.5),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'In Progress',
                    style: GoogleFonts.crimsonPro(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.matteGold)),
                  const SizedBox(width: 4),
                  Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: sectionHeight,
          child: displayItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Play a chant or audio to see it here',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.5)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  itemCount: displayItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 24),
                  itemBuilder: (_, i) {
                    final item = displayItems[i];
                    final hasImage = _hasRealImage(item.imageUrl);
                    if (hasImage) {
                      return _buildInProgressCardLarge(
                        tag: item.tag, title: item.title, imageUrl: item.imageUrl,
                        current: item.current, total: item.total, progress: item.progress,
                        isActive: item.isActive, audioUrl: item.audioUrl,
                      );
                    }
                    return _buildInProgressCardCompact(
                      tag: item.tag, title: item.title,
                      current: item.current, total: item.total, progress: item.progress,
                      isActive: item.isActive, audioUrl: item.audioUrl,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInProgressCardLarge({
    required String tag, required String title, required String imageUrl,
    required String current, required String total, required double progress,
    required bool isActive, String? audioUrl,
  }) {
    final info = AudioItemInfo(title: title, coverUrl: imageUrl, duration: total, audioUrl: audioUrl);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onPlay(info),
        borderRadius: BorderRadius.circular(24),
        child: Opacity(
          opacity: isActive ? 1 : 0.7,
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 10 / 14,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6), Colors.black],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0, right: 0, bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tag, style: GoogleFonts.cinzel(fontSize: 10, color: AppColors.matteGold, letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Text(title, style: GoogleFonts.crimsonPro(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 24),
                            _buildProgressBar(progress, isActive),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(current, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
                                Text(total, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.matteGold)),
                              ],
                            ),
                            if (isActive) ...[
                              const SizedBox(height: 16),
                              Center(
                                child: Material(
                                  color: AppColors.matteGold.withValues(alpha: 0.9),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    onTap: () => widget.onPlay(info),
                                    customBorder: const CircleBorder(),
                                    child: const SizedBox(width: 48, height: 48, child: Icon(Icons.play_arrow, color: Colors.black, size: 32)),
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildInProgressCardCompact({
    required String tag, required String title,
    required String current, required String total, required double progress,
    required bool isActive, String? audioUrl,
  }) {
    final info = AudioItemInfo(title: title, duration: total, audioUrl: audioUrl);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onPlay(info),
        borderRadius: BorderRadius.circular(20),
        child: Opacity(
          opacity: isActive ? 1 : 0.7,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [const Color(0xFF141414).withValues(alpha: 0.8), const Color(0xFF0A0A0A)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.matteGold.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.matteGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isActive ? Icons.graphic_eq : Icons.headphones,
                    color: AppColors.matteGold,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(tag, style: GoogleFonts.cinzel(fontSize: 8, color: AppColors.matteGold.withValues(alpha: 0.7), letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(title, style: GoogleFonts.crimsonPro(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      _buildProgressBar(progress, false),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(current, style: GoogleFonts.inter(fontSize: 9, color: Colors.white.withValues(alpha: 0.5))),
                          Text(total, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.matteGold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.matteGold.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => widget.onPlay(info),
                    customBorder: const CircleBorder(),
                    child: const SizedBox(width: 36, height: 36, child: Icon(Icons.play_arrow, color: Colors.black, size: 20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, bool showThumb) {
    final p = progress.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 6,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(height: 6, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4))),
              if (p > 0)
                SizedBox(
                  width: constraints.maxWidth * p,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(colors: [Color(0xFFC5A059), Color(0xFFE5C17B), Color(0xFFC5A059)]),
                    ),
                  ),
                ),
              if (showThumb && progress > 0)
                Positioned(
                  left: (constraints.maxWidth * p).clamp(0.0, constraints.maxWidth - 16),
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      border: Border.all(color: AppColors.matteGold, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────
  // DEITY GRADIENT TEXT WIDGET
  // ──────────────────────────────────────────────────────────

  Widget _buildDeityGradientText(String name, String? deitySlug, {double fontSize = 10}) {
    final gradient = _getDeityGradient(deitySlug);
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(colors: gradient).createShader(bounds),
      child: Text(
        name.toUpperCase(),
        style: GoogleFonts.cinzel(fontSize: fontSize, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // SACRED TEXTS AUDIO SECTION
  // ──────────────────────────────────────────────────────────

  Widget _buildSacredTextsAudioSection() {
    return Consumer(
      builder: (context, ref, _) {
        final textsAsync = ref.watch(sacredTextsWithAudioProvider);
        final allTexts = textsAsync.valueOrNull ?? [];
        final texts = allTexts.take(5).toList();

        return _buildAudioSection(
          title: 'Sacred Texts',
          subtitle: '${allTexts.length} texts with audio',
          showViewAll: allTexts.length > 5,
          onViewAll: () => Navigator.pushNamed(context, '/listen/all-texts'),
          isLoading: textsAsync.isLoading,
          isEmpty: texts.isEmpty,
          cardHeight: 200,
          itemCount: texts.length,
          itemBuilder: (i) => _buildSacredTextAudioCard(texts[i]),
        );
      },
    );
  }

  Widget _buildSacredTextAudioCard(SacredTextModel text) {
    final deityName = text.deitySlug?.replaceAll('_', ' ') ?? '';
    final durationStr = text.durationSeconds != null
        ? '${(text.durationSeconds! ~/ 60)}m'
        : '';
    return _buildAudioCardTile(
      title: text.title,
      subtitle: '${text.typeLabel}${durationStr.isNotEmpty ? ' · $durationStr' : ''}',
      imageUrl: text.coverImageUrl,
      deitySlug: text.deitySlug,
      deityName: deityName,
      onTap: () => Navigator.pushNamed(context, '/listen/sacred-text', arguments: text),
      audioUrl: text.audioUrl,
    );
  }

  // ──────────────────────────────────────────────────────────
  // AUDIOBOOKS SECTION
  // ──────────────────────────────────────────────────────────

  Widget _buildAudiobooksSection() {
    return Consumer(
      builder: (context, ref, _) {
        final booksAsync = ref.watch(booksWithAudioProvider);
        final allBooks = booksAsync.valueOrNull ?? [];
        final books = allBooks.take(5).toList();

        return _buildAudioSection(
          title: 'Audiobooks',
          subtitle: '${allBooks.length} books with audio',
          showViewAll: allBooks.length > 5,
          onViewAll: () => Navigator.pushNamed(context, '/listen/all-books'),
          isLoading: booksAsync.isLoading,
          isEmpty: books.isEmpty,
          cardHeight: 200,
          itemCount: books.length,
          itemBuilder: (i) => _buildAudiobookCard(books[i]),
        );
      },
    );
  }

  Widget _buildAudiobookCard(BookModel book) {
    return _buildAudioCardTile(
      title: book.name,
      subtitle: '${book.totalChapters} chapters',
      imageUrl: book.coverImageUrl,
      deitySlug: null,
      deityName: '',
      onTap: () => Navigator.pushNamed(context, '/listen/book', arguments: book),
      audioUrl: book.audioUrl,
    );
  }

  // ──────────────────────────────────────────────────────────
  // SACRED STORIES AUDIO SECTION
  // ──────────────────────────────────────────────────────────

  Widget _buildSacredStoriesAudioSection() {
    return Consumer(
      builder: (context, ref, _) {
        final storiesAsync = ref.watch(storiesWithAudioProvider);
        final allStories = storiesAsync.valueOrNull ?? [];
        final stories = allStories.take(5).toList();

        return _buildAudioSection(
          title: 'Sacred Stories',
          subtitle: '${allStories.length} stories with audio',
          showViewAll: allStories.length > 5,
          onViewAll: () => Navigator.pushNamed(context, '/listen/all-stories'),
          isLoading: storiesAsync.isLoading,
          isEmpty: stories.isEmpty,
          cardHeight: 200,
          itemCount: stories.length,
          itemBuilder: (i) => _buildSacredStoryAudioCard(stories[i]),
        );
      },
    );
  }

  Widget _buildSacredStoryAudioCard(SacredStoryModel story) {
    final deityName = story.deitySlug?.replaceAll('_', ' ') ?? '';
    return _buildAudioCardTile(
      title: story.title,
      subtitle: '${story.estimatedMinutes}m',
      imageUrl: story.coverImageUrl,
      deitySlug: story.deitySlug,
      deityName: deityName,
      onTap: () => Navigator.pushNamed(context, '/listen/story', arguments: story),
      audioUrl: story.audioUrl,
    );
  }

  // ──────────────────────────────────────────────────────────
  // CHANTS SECTION
  // ──────────────────────────────────────────────────────────

  Widget _buildChantsSection() {
    return Consumer(
      builder: (context, ref, _) {
        final chantsAsync = ref.watch(chantsProvider);
        final allChants = chantsAsync.valueOrNull ?? [];
        final chants = allChants.take(5).toList();

        return _buildAudioSection(
          title: 'Chants',
          subtitle: '${allChants.length} chants',
          showViewAll: allChants.length > 5,
          onViewAll: () => Navigator.pushNamed(context, '/listen/all-chants'),
          isLoading: chantsAsync.isLoading,
          isEmpty: chants.isEmpty,
          cardHeight: 200,
          itemCount: chants.length,
          itemBuilder: (i) => _buildChantAudioCard(chants[i]),
        );
      },
    );
  }

  Widget _buildChantAudioCard(ChantModel chant) {
    final deityName = chant.deitySlug?.replaceAll('_', ' ') ?? '';
    final isLocked = !_isPremium && chant.orderIndex >= FeatureGateConfig.freeAudioPerBook;
    if (isLocked) {
      return _buildLockedAudioTile(title: chant.title, subtitle: chant.subtitle ?? chant.durationFormatted);
    }
    return _buildAudioCardTile(
      title: chant.title,
      subtitle: chant.subtitle ?? chant.durationFormatted,
      imageUrl: chant.imageUrl,
      deitySlug: chant.deitySlug,
      deityName: deityName,
      onTap: () => widget.onPlay(AudioItemInfo(
        title: chant.title, subtitle: chant.subtitle,
        coverUrl: chant.imageUrl, duration: chant.durationFormatted,
        audioUrl: chant.effectiveAudioUrl.isNotEmpty ? chant.effectiveAudioUrl : null,
      )),
      audioUrl: chant.effectiveAudioUrl.isNotEmpty ? chant.effectiveAudioUrl : null,
    );
  }

  // ──────────────────────────────────────────────────────────
  // SHARED SECTION BUILDER
  // ──────────────────────────────────────────────────────────

  Widget _buildAudioSection({
    required String title,
    required String subtitle,
    required bool showViewAll,
    required VoidCallback onViewAll,
    required bool isLoading,
    required bool isEmpty,
    required double cardHeight,
    required int itemCount,
    required Widget Function(int) itemBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.crimsonPro(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.matteGold.withValues(alpha: 0.9))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.zinc500)),
                  ],
                ),
                if (showViewAll)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.matteGold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View All', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.matteGold)),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14, color: AppColors.matteGold),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            SizedBox(
              height: cardHeight,
              child: const Center(child: CircularProgressIndicator(color: AppColors.matteGold)),
            )
          else if (isEmpty)
            SizedBox(
              height: cardHeight,
              child: Center(child: SizedBox(width: 160, height: 180, child: const AntarmargPlaceholder(compact: true))),
            )
          else
            SizedBox(
              height: cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const ClampingScrollPhysics(),
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) => itemBuilder(i),
              ),
            ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // AUDIO CARD TILE (shared by all sections)
  // ──────────────────────────────────────────────────────────

  Widget _buildAudioCardTile({
    required String title,
    required String subtitle,
    required String? imageUrl,
    required String? deitySlug,
    required String deityName,
    required VoidCallback onTap,
    String? audioUrl,
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final gradient = _getDeityGradient(deitySlug);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: deitySlug != null ? gradient.first.withValues(alpha: 0.3) : AppColors.matteGold.withValues(alpha: 0.15),
            ),
            color: const Color(0xFF0F0F0F),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: hasImage
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            AppNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder()),
                            Positioned(
                              right: 8, bottom: 8,
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow, color: AppColors.matteGold, size: 18),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                              colors: [gradient.first.withValues(alpha: 0.2), gradient.last.withValues(alpha: 0.1)],
                            ),
                          ),
                          child: Center(
                            child: Icon(Icons.headphones, color: gradient.first.withValues(alpha: 0.5), size: 40),
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (deityName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: _buildDeityGradientText(deityName, deitySlug, fontSize: 8),
                        ),
                      Text(
                        title,
                        style: GoogleFonts.crimsonPro(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(fontSize: 9, color: Colors.white.withValues(alpha: 0.5)),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedAudioTile({required String title, required String subtitle}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showPaywall,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: 0.5,
          child: Container(
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.matteGold.withValues(alpha: 0.1)),
              color: const Color(0xFF0F0F0F),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.05),
                      child: const Center(child: Icon(Icons.lock, color: Color(0xFFD4AF37), size: 32)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: GoogleFonts.crimsonPro(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(subtitle, style: GoogleFonts.inter(fontSize: 9, color: Colors.white.withValues(alpha: 0.5)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                          ),
                          child: Text('PRO', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1)),
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

  // ──────────────────────────────────────────────────────────
  // DIVINE PRESENCE SECTION (kept, with deity gradient names)
  // ──────────────────────────────────────────────────────────

  Widget _buildDivinePresenceSection() {
    final deitiesAsync = ref.watch(deitiesProvider);
    final deities = deitiesAsync.valueOrNull ?? [];
    const fallback = [
      (name: 'Shiva', slug: 'shiva', description: 'The cosmic dancer who performs the Ananda Tandava.', imageUrl: ''),
      (name: 'Vishnu', slug: 'vishnu', description: 'The sustainer of the universe.', imageUrl: ''),
      (name: 'Devi', slug: 'devi', description: 'The supreme feminine energy.', imageUrl: ''),
    ];
    final displayItems = deities.isNotEmpty
        ? deities.map((d) => (name: d.name, slug: d.slug, description: d.description ?? '', imageUrl: d.imageUrl ?? '')).toList()
        : fallback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Divine Presence', style: GoogleFonts.crimsonPro(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              GestureDetector(
                onTap: () {},
                child: Text('View All', style: GoogleFonts.cinzel(fontSize: 10, color: AppColors.matteGold, letterSpacing: 2)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 360,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: displayItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (_, i) {
              final item = displayItems[i];
              return _buildDivineCard(item.name, item.slug, item.description, item.imageUrl);
            },
          ),
        ),
      ],
    );
  }

  void _showDeityChantsSheet(String deityName, String deitySlug, String imageUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F0F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final chantsAsync = ref.watch(chantsByDeityProvider(deitySlug));
            final chants = chantsAsync.valueOrNull ?? [];
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.85,
              expand: false,
              builder: (_, controller) => _DeityChantsSheetContent(
                sheetController: controller,
                deityName: deityName,
                chants: chants,
                buildChantCard: _buildChantCardRow,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChantCardRow(ChantModel chant) {
    final imageUrl = chant.imageUrl ?? '';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onPlay(AudioItemInfo(
          title: chant.title, subtitle: chant.subtitle,
          coverUrl: imageUrl.isNotEmpty ? imageUrl : null,
          duration: chant.durationFormatted,
          audioUrl: chant.effectiveAudioUrl.isNotEmpty ? chant.effectiveAudioUrl : null,
        )),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 48, height: 48,
                  child: imageUrl.isNotEmpty
                      ? AppNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
                      : Container(color: AppColors.matteGold.withValues(alpha: 0.1), child: const Icon(Icons.music_note, color: AppColors.matteGold, size: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chant.deitySlug != null && chant.deitySlug!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: _buildDeityGradientText(chant.deitySlug!.replaceAll('_', ' '), chant.deitySlug, fontSize: 8),
                      ),
                    Text(chant.title, style: GoogleFonts.crimsonPro(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(chant.subtitle ?? chant.durationFormatted, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill, color: AppColors.matteGold, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivineCard(String name, String slug, String description, String imageUrl) {
    final gradient = _getDeityGradient(slug);
    final hasImage = imageUrl.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDeityChantsSheet(name, slug, imageUrl),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    AppNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [gradient.first.withValues(alpha: 0.3), gradient.last.withValues(alpha: 0.15)],
                        ),
                      ),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4), Colors.black],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDeityGradientText(name, slug, fontSize: 16),
                          const SizedBox(height: 4),
                          Text(description, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(color: AppColors.matteGold, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.volume_up, color: Colors.black, size: 18),
                                const SizedBox(width: 8),
                                Text('Listen to Chants', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 2)),
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
    );
  }

  // ──────────────────────────────────────────────────────────
  // TODAY'S REFLECTION (kept)
  // ──────────────────────────────────────────────────────────

  Widget _buildTodaysReflectionSection() {
    final deepDiveAsync = ref.watch(deepDiveProvider);
    final articles = deepDiveAsync.valueOrNull ?? [];
    final article = articles.isNotEmpty ? articles.first : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onPlay(AudioItemInfo(title: article?.title ?? "The Nature of Atman", duration: '4:00')),
          borderRadius: BorderRadius.circular(40),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [const Color(0xFF141414).withValues(alpha: 0.8), const Color(0xFF0A0A0A)],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.matteGold.withValues(alpha: 0.1)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24)],
            ),
            child: Stack(
              children: [
                Positioned(top: 0, right: 0, child: Icon(Icons.share, color: Colors.white.withValues(alpha: 0.2), size: 24)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Reflection", style: GoogleFonts.cinzel(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.matteGold, letterSpacing: 3)),
                    const SizedBox(height: 16),
                    Text(
                      article?.quote ?? '"The Self is not born, nor does it ever die... Unborn, eternal, ever-existing, and primeval."',
                      style: GoogleFonts.crimsonPro(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.white, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Container(width: 48, height: 2, color: AppColors.matteGold.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(article?.durationLabel ?? 'Atman · 4 min listen', style: GoogleFonts.cinzel(fontSize: 10, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 2)),
                        Material(
                          color: AppColors.matteGold,
                          borderRadius: BorderRadius.circular(999),
                          child: InkWell(
                            onTap: () => widget.onPlay(AudioItemInfo(title: article?.title ?? "The Nature of Atman", duration: '4:00')),
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.play_circle, color: Colors.black, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Play Now', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 2)),
                                ],
                              ),
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
  }

  Widget _placeholder() {
    return const AntarmargPlaceholder();
  }
}

class _DeityChantsSheetContent extends StatefulWidget {
  final ScrollController sheetController;
  final String deityName;
  final List<ChantModel> chants;
  final Widget Function(ChantModel) buildChantCard;

  const _DeityChantsSheetContent({
    required this.sheetController,
    required this.deityName,
    required this.chants,
    required this.buildChantCard,
  });

  @override
  State<_DeityChantsSheetContent> createState() => _DeityChantsSheetContentState();
}

class _DeityChantsSheetContentState extends State<_DeityChantsSheetContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (d) {
            final ext = widget.sheetController.hasClients ? widget.sheetController.position.pixels : 0.0;
            widget.sheetController.jumpTo(ext - d.delta.dy);
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text(widget.deityName, style: GoogleFonts.crimsonPro(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.matteGold)),
                const SizedBox(height: 4),
                Text('${widget.chants.length} chants', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
        ),
        Expanded(
          child: widget.chants.isEmpty
              ? Center(child: Text('No chants available', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.4))))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: widget.chants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => widget.buildChantCard(widget.chants[i]),
                ),
        ),
      ],
    );
  }
}
