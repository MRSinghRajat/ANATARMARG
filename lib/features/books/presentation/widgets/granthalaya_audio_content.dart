import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/book_providers.dart';

/// Single audio item info for "now playing" and play actions.
class AudioItemInfo {
  final String title;
  final String? subtitle;
  final String? coverUrl;
  final String duration;

  const AudioItemInfo({
    required this.title,
    this.subtitle,
    this.coverUrl,
    this.duration = '0:00',
  });
}

/// Listen Mode UI: In Progress, Sacred Library, Divine Presence, Today's Reflection
class GranthalayaAudioContent extends ConsumerStatefulWidget {
  final ValueChanged<AudioItemInfo> onPlay;

  const GranthalayaAudioContent({super.key, required this.onPlay});

  @override
  ConsumerState<GranthalayaAudioContent> createState() => _GranthalayaAudioContentState();
}

class _GranthalayaAudioContentState extends ConsumerState<GranthalayaAudioContent> {
  int _sacredLibraryCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 140),
      children: [
        _buildInProgressSection(),
        const SizedBox(height: 48),
        _buildSacredLibrarySection(),
        const SizedBox(height: 48),
        _buildDivinePresenceSection(),
        const SizedBox(height: 48),
        _buildTodaysReflectionSection(),
      ],
    );
  }

  Widget _buildInProgressSection() {
    final inProgressAsync = ref.watch(audioInProgressProvider);
    final items = inProgressAsync.valueOrNull ?? [];
    final fallback = [
      (tag: 'Itihasa • Chapter 4', title: 'Bhagavad Gita', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCeFNfyF3TMbtQ7up4KjskhDXsUja_ezF57r7yXtsw7qht7MWETTO5t-dTRJ5yKLGjVidywqNDN_tYKaEhCT-GW6PgKdHyCJivzZEk3MFKeenhqQE9lW9dmulcDAGEtzqlDKk9-V_1vAxfrsXu5ER-bNWtcVzRI4zSyvvmNDPJ58EPRheqIFknQUzuOF0zLsTHepqZozzC058V3Vhz4FC7I0MqtbnhK3mRrEBauKk-OBOllQvmPoUhxzI3oicigPXbW4HNzglsA3JZD', current: '12:45', total: '28:30', progress: 0.45, isActive: true),
      (tag: 'Shruti • Isha', title: 'Mukhya Upanishads', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCJl1L6fIrykeLWmdy0V5EC5-Eh4nRFTBiIJmZvfBncpvgMivobf5NbOHIFWkBndaaRvC4YCHyOTgYrn17GM4YRUqu02UjdT4uoTbH-Qgy1FmIfhhsA0Q21QwyKikc1JvvZApGs7fH_6m_pQ48kHemmVpGJUfO0f-idW3Am5Dmyv8mGgIQlPOWu75jym4UITWgp7x6KSH22NMoTXUhrWu_mF-XQ-pykoUCH1RnyCP6zvd3oYGw_0Gh7KrpdRZrmDrJCq4lPaP81wgPO', current: '02:15', total: '15:00', progress: 0.15, isActive: false),
    ];

    final displayItems = items.isNotEmpty
        ? items.map((m) => (tag: m.tag, title: m.title, imageUrl: m.imageUrl, current: m.currentFormatted, total: m.totalFormatted, progress: m.progress, isActive: m.isActiveItem)).toList()
        : fallback;

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
                      color: AppColors.matteGold.withOpacity(0.5),
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
                  Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 448,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: displayItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 24),
            itemBuilder: (_, i) {
              final item = displayItems[i];
              return _buildInProgressCard(
                tag: item.tag,
                title: item.title,
                imageUrl: item.imageUrl,
                current: item.current,
                total: item.total,
                progress: item.progress,
                isActive: item.isActive,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressCard({
    required String tag,
    required String title,
    required String imageUrl,
    required String current,
    required String total,
    required double progress,
    required bool isActive,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onPlay(AudioItemInfo(title: title, coverUrl: imageUrl, duration: total)),
        borderRadius: BorderRadius.circular(24),
        child: Opacity(
          opacity: isActive ? 1 : 0.7,
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 10 / 14,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.6), Colors.black],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tag,
                              style: GoogleFonts.cinzel(
                                fontSize: 10,
                                color: AppColors.matteGold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: GoogleFonts.crimsonPro(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildProgressBar(progress, isActive),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(current, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withOpacity(0.6))),
                                Text(total, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.matteGold)),
                              ],
                            ),
                            if (isActive) ...[
                              const SizedBox(height: 16),
                              Center(
                                child: Material(
                                  color: AppColors.matteGold.withOpacity(0.9),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    onTap: () => widget.onPlay(AudioItemInfo(title: title, coverUrl: imageUrl, duration: total)),
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

  Widget _buildProgressBar(double progress, bool showThumb) {
    final p = progress.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 6,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
              ),
              if (p > 0)
                SizedBox(
                  width: constraints.maxWidth * p,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC5A059), Color(0xFFE5C17B), Color(0xFFC5A059)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              if (showThumb && progress > 0)
                Positioned(
                  left: (constraints.maxWidth * p).clamp(0.0, constraints.maxWidth - 16),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.matteGold, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSacredLibrarySection() {
    final categoriesAsync = ref.watch(audioCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? [];
    final categoryNames = categories.isNotEmpty
        ? categories.map((c) => c.name).toList()
        : ['Audio Books', 'Chants', 'Guided', 'Nature'];
    final selectedSlug = categories.isNotEmpty && _sacredLibraryCategoryIndex < categories.length
        ? categories[_sacredLibraryCategoryIndex].slug
        : 'audio_books';
    final wisdomAsync = ref.watch(audioWisdomCardsProvider(selectedSlug));
    final wisdomCards = wisdomAsync.valueOrNull ?? [];
    final fallbackCards = [
      (title: 'Shiva Purana', subtitle: '42 Tracks • 12 Cantos', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCJl1L6fIrykeLWmdy0V5EC5-Eh4nRFTBiIJmZvfBncpvgMivobf5NbOHIFWkBndaaRvC4YCHyOTgYrn17GM4YRUqu02UjdT4uoTbH-Qgy1FmIfhhsA0Q21QwyKikc1JvvZApGs7fH_6m_pQ48kHemmVpGJUfO0f-idW3Am5Dmyv8mGgIQlPOWu75jym4UITWgp7x6KSH22NMoTXUhrWu_mF-XQ-pykoUCH1RnyCP6zvd3oYGw_0Gh7KrpdRZrmDrJCq4lPaP81wgPO'),
      (title: 'Rig Veda', subtitle: '108 Mandalas • Shruti', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDW-hLl9t9nlfz4_XrCHE2L8fj4DjztQltqRcePuXQI84cP7mH2T5Vk6fnWShHxhB2nEVs-H-DVPm9NgTCLgC5CG13Uh5YaT6mLZYrkRyoUqeX2fq4xqsN1DrfDR3xPIxZwvrjKBBCOTIwQ8u9ZnsBd4-WqJstOmf1IuOTfreoIsIIkfW4rSrIeyb8cG2zqsUB4WN4pTh0c3zMaM7hl4fkFV7GLUtOQkDKflakau3LOs140pz6a7PfD6-v3lv1K3NzfgVXUe8geeLv1'),
      (title: 'Sama Veda', subtitle: '1875 Melodies', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCeFNfyF3TMbtQ7up4KjskhDXsUja_ezF57r7yXtsw7qht7MWETTO5t-dTRJ5yKLGjVidywqNDN_tYKaEhCT-GW6PgKdHyCJivzZEk3MFKeenhqQE9lW9dmulcDAGEtzqlDKk9-V_1vAxfrsXu5ER-bNWtcVzRI4zSyvvmNDPJ58EPRheqIFknQUzuOF0zLsTHepqZozzC058V3Vhz4FC7I0MqtbnhK3mRrEBauKk-OBOllQvmPoUhxzI3oicigPXbW4HNzglsA3JZD'),
    ];
    final displayCards = wisdomCards.isNotEmpty
        ? wisdomCards.map((c) => (title: c.title, subtitle: c.subtitle, imageUrl: c.imageUrl)).toList()
        : fallbackCards;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sacred Library',
                style: GoogleFonts.crimsonPro(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.filter_list, color: AppColors.matteGold.withOpacity(0.4), size: 24),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: categoryNames.length,
              separatorBuilder: (_, __) => const SizedBox(width: 24),
              itemBuilder: (_, i) {
                final isActive = i == _sacredLibraryCategoryIndex;
                return GestureDetector(
                  onTap: () => setState(() => _sacredLibraryCategoryIndex = i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        categoryNames[i],
                        style: GoogleFonts.cinzel(
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? AppColors.matteGold : Colors.white.withOpacity(0.4),
                          letterSpacing: 2,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 8),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.matteGold)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
          ),
          const SizedBox(height: 24),
          ...displayCards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildWisdomCard(card.title, card.subtitle, card.imageUrl),
              )),
        ],
      ),
    );
  }

  Widget _buildWisdomCard(String title, String subtitle, String imageUrl) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onPlay(AudioItemInfo(title: title, subtitle: subtitle, coverUrl: imageUrl)),
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF141414).withOpacity(0.8),
                const Color(0xFF0A0A0A),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.matteGold.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF1F5F9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.cinzel(
                        fontSize: 10,
                        color: AppColors.matteGold.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => widget.onPlay(AudioItemInfo(title: title, subtitle: subtitle, coverUrl: imageUrl)),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shuffle, color: AppColors.matteGold, size: 14),
                              const SizedBox(width: 8),
                              Text(
                                'Shuffle Play',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.matteGold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildDivinePresenceSection() {
    final deitiesAsync = ref.watch(deitiesProvider);
    final deities = deitiesAsync.valueOrNull ?? [];
    final fallback = [
      (name: 'Shiva', description: 'The cosmic dancer who performs the Ananda Tandava, creating and destroying the universe.', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv'),
      (name: 'Vishnu', description: 'The sustainer of the universe, reclining on the serpent Shesha in the causal ocean.', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBxEcRo7ik8Jy87-HtauEuHdKTHi8GdIKmqcGT7A5tLs9Hd-Wq91i1xIZpcgTgMFEyViD600BqtPNRVbEyrpPj7PkicrXavkLAdieCs-HG7T-CmNq5Vn8RU9C9G_OcPnb9-KFF_c-E5hYmG2dRuaRslH5YuWAypzoerq_3o2MelRx0QBg-6De5K0GHxsWNTnKgpBjNkH0lRv2pe0ovaqx7zwlv1MiE_idLjwiWDvZHbG-Fz9GDBrle5Za0lmTsTVd--0et2rE3iJwOv'),
      (name: 'Devi', description: 'The supreme feminine energy, embodying power, knowledge, and compassion.', imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCd_4JNasICaIaHij84HkpIMICry2qj9vQbv4E418yGFsZvKbS4Wk5J2i4pPOqk6gM2mWCKAS7JczuUgHfnRi0fUli5hU8gZovvHqoWo1GI22rS613kTYAxJVowoCXRgFDR7-97bUilllW6Z6rM_MEB4Hk9fe8yAcF-871rkAWzHsFNmpVDH0R7w0OW0g-tlL9Ncib0jHHxIuN-3O-lrpEiRaVouZoSikGTJQqEE0fD1rbpaJNRwDvfadeu6GWnWi2-30rmN0BAjiQr'),
    ];
    final displayItems = deities.isNotEmpty
        ? deities.map((d) => (name: d.name, description: d.description ?? '', imageUrl: d.imageUrl ?? '')).toList()
        : fallback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Divine Presence',
                style: GoogleFonts.crimsonPro(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.cinzel(
                    fontSize: 10,
                    color: AppColors.matteGold,
                    letterSpacing: 2,
                  ),
                ),
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
              return _buildDivineCard(item.name, item.description, item.imageUrl);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDivineCard(String name, String description, String imageUrl) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onPlay(AudioItemInfo(title: name, subtitle: description, coverUrl: imageUrl)),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder(),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.4), Colors.black],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.crimsonPro(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.matteGold,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.volume_up, color: Colors.black, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Listen to Story',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    letterSpacing: 2,
                                  ),
                                ),
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
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF141414).withOpacity(0.8),
                  const Color(0xFF0A0A0A),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.matteGold.withOpacity(0.1)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24)],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.share, color: Colors.white.withOpacity(0.2), size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Reflection",
                      style: GoogleFonts.cinzel(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.matteGold,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      article?.quote ?? '"The Self is not born, nor does it ever die... Unborn, eternal, ever-existing, and primeval."',
                      style: GoogleFonts.crimsonPro(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 48,
                      height: 2,
                      color: AppColors.matteGold.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          article?.durationLabel ?? 'Atman • 4 min listen',
                          style: GoogleFonts.cinzel(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 2,
                          ),
                        ),
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
                                  Icon(Icons.play_circle, color: Colors.black, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Play Now',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      letterSpacing: 2,
                                    ),
                                  ),
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
    return Container(
      color: AppColors.manuscriptDark,
      child: const Icon(Icons.image, color: AppColors.matteGold, size: 48),
    );
  }
}
