import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../books/presentation/screens/books_library_screen.dart';

/// Prayer tab: Spiritual Guide, Journey entry, Recommended Practices, Progress.
class PrayerDashboardScreen extends StatelessWidget {
  const PrayerDashboardScreen({super.key});

  static const _practices = [
    (Icons.graphic_eq, '15 MINS', 'Chant Session', 'Vocalizing sacred Om.', true),
    (Icons.self_improvement, '20 MINS', 'Yoga Flow', 'Morning Surya Namaskar.', false),
    (Icons.spa, '10 MINS', 'Pranayama', 'Rhythmic breath control.', false),
  ];

  static const _achievements = [
    ('Gita Chapter 1 Completed', '2 days ago', true),
    ('7-Day Mindfulness Badge', '5 days ago', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.prayerBackgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(child: _buildHeroCard()),
                SliverToBoxAdapter(child: _buildJourneyAwaits()),
                SliverToBoxAdapter(child: _buildScriptureJourneyCard(context)),
                SliverToBoxAdapter(child: _buildRecommendedPractices()),
                SliverToBoxAdapter(child: _buildSpiritualProgress()),
                SliverToBoxAdapter(child: _buildRecentAchievements()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.prayerBackgroundDark.withOpacity(0.85),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
          Text(
            'Prayer',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.prayerSurfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
                  fit: BoxFit.cover,
                  color: Colors.white.withOpacity(0.4),
                  colorBlendMode: BlendMode.overlay,
                  errorWidget: (_, __, ___) => Container(color: AppColors.prayerSurfaceDark),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: RadialGradient(
                    center: Alignment.bottomCenter,
                    radius: 1.2,
                    colors: [
                      AppColors.prayerGold.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Center(
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=280',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) => Icon(
                    Icons.self_improvement,
                    size: 120,
                    color: AppColors.prayerGold.withOpacity(0.6),
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'SPIRITUAL GUIDE',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
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

  Widget _buildJourneyAwaits() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        children: [
          Text(
            'Your journey awaits',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'The morning prayers are ready for you. Take a moment to connect with the divine.',
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: AppColors.prayerMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.prayerTeal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ACTIVE SANCTUARY',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.prayerTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScriptureJourneyCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.prayerGold, Color(0xFFB88A00)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.prayerGold.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.prayerSurfaceDark.withOpacity(0.95),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.article, color: AppColors.prayerGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'PREMIUM JOURNEY',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: AppColors.prayerGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Begin a Scripture Journey',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Deepen your understanding through ancient sacred scrolls.',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.prayerMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BooksLibraryScreen(),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.prayerGold, Color(0xFFB88A00)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Start Now',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.prayerBackgroundDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18, color: AppColors.prayerBackgroundDark),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.prayerGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.prayerGold.withOpacity(0.2)),
                ),
                child: const Icon(Icons.menu_book, size: 36, color: AppColors.prayerGold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedPractices() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended Practices',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Text(
                  'NEXT STEPS',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: AppColors.prayerGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _practices.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) {
                final (icon, duration, title, subtitle, isTeal) = _practices[i];
                return Container(
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.prayerSurfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isTeal
                              ? AppColors.prayerTeal.withOpacity(0.1)
                              : (i == 1 ? AppColors.prayerGold.withOpacity(0.1) : Colors.white.withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: isTeal ? AppColors.prayerTeal : (i == 1 ? AppColors.prayerGold : Colors.white.withOpacity(0.6)),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        duration,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: isTeal ? AppColors.prayerTeal : (i == 1 ? AppColors.prayerGold : Colors.white.withOpacity(0.4)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppColors.prayerMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpiritualProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spiritual Progress',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.prayerSurfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.workspace_premium, color: AppColors.prayerGold, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        '12',
                        style: GoogleFonts.manrope(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'DAY STREAK',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppColors.prayerMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.prayerSurfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.auto_stories, color: AppColors.prayerTeal, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        '04',
                        style: GoogleFonts.manrope(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JOURNEYS',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppColors.prayerMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.prayerSurfaceDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Achievements',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Icon(Icons.open_in_new, size: 18, color: Colors.white.withOpacity(0.3)),
                  ],
                ),
                const SizedBox(height: 12),
                ..._achievements.asMap().entries.map((e) {
                  final (title, ago, isGold) = e.value;
                  return Padding(
                    padding: EdgeInsets.only(top: e.key > 0 ? 12 : 0),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isGold ? AppColors.prayerGold : AppColors.prayerTeal,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isGold ? AppColors.prayerGold : AppColors.prayerTeal).withOpacity(0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                ago.toUpperCase(),
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
