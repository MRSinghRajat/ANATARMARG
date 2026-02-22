import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/garbh_sanskar_models.dart';
import '../providers/garbh_sanskar_providers.dart';
import 'garbh_sanskar_content_list_screen.dart';
import 'garbh_sanskar_samskaras_screen.dart';
import 'garbh_sanskar_lullabies_screen.dart';
import 'baby_milestones_screen.dart';

/// Main Garbh Sanskar home screen — shows week tracker, daily content,
/// and navigation to all sub-sections
class GarbhSanskarHomeScreen extends ConsumerStatefulWidget {
  const GarbhSanskarHomeScreen({super.key});

  @override
  ConsumerState<GarbhSanskarHomeScreen> createState() =>
      _GarbhSanskarHomeScreenState();
}

class _GarbhSanskarHomeScreenState
    extends ConsumerState<GarbhSanskarHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journeyAsync = ref.watch(journeyNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A06),
      body: journeyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9933)),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.white)),
        ),
        data: (journey) {
          if (journey == null) {
            return const Center(
              child: Text('No journey found',
                  style: TextStyle(color: Colors.white)),
            );
          }
          return _buildHomeContent(journey);
        },
      ),
    );
  }

  Widget _buildHomeContent(UserPregnancyJourney journey) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(journey),
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (journey.isPrenatal) _buildWeekTracker(journey),
              if (journey.isPostnatal) _buildPostnatalHeader(journey),
              const SizedBox(height: 8),
              _buildDailySection(journey),
              const SizedBox(height: 8),
              _buildContentGrid(journey),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(UserPregnancyJourney journey) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0D0A06),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2A1000), Color(0xFF0D0A06)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'गर्भ संस्कार',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 28,
                            color: const Color(0xFFFF9933),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (journey.motherName != null)
                          Text(
                            'Namaste, ${journey.motherName}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1500),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF9933).withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪔', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          journey.isPrenatal
                              ? 'Week ${journey.computedCurrentWeek}'
                              : journey.babyAgeLabel,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFFFF9933),
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildWeekTracker(UserPregnancyJourney journey) {
    final week = journey.computedCurrentWeek;
    final info = WeekDevelopmentInfo.forWeek(week);
    final progress = week / 40.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1500), Color(0xFF1A0A00)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF9933).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week $week of 40',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        color: const Color(0xFFFF9933),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      journey.trimesterLabelHindi,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: Text(
                      info.babySizeEmoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF9933)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          // Baby size
          Row(
            children: [
              const Icon(Icons.child_care, color: Colors.white38, size: 16),
              const SizedBox(width: 6),
              Text(
                'Baby is the size of a ${info.babySize}',
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Development
          Text(
            info.babyDevelopment,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Mantra recommendation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('🕉️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    info.mantraRecommendation,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostnatalHeader(UserPregnancyJourney journey) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1A2A), Color(0xFF0D0A06)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) => Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.08),
              child: const Text('👶', style: TextStyle(fontSize: 52)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journey.babyName != null
                      ? '${journey.babyName} is here! 🎉'
                      : 'Your baby is here! 🎉',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  journey.babyAgeLabel,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: const Color(0xFF6366F1)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Continue your sacred journey',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySection(UserPregnancyJourney journey) {
    final phase = journey.isPrenatal ? 'prenatal' : 'postnatal';
    final contentAsync = journey.isPrenatal
        ? ref.watch(prenatalContentProvider)
        : ref.watch(postnatalContentProvider);

    return contentAsync.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
              color: Color(0xFFFF9933), strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (allContent) {
        // Pick today's mantra (rotate by day of year)
        final mantras =
            allContent.where((c) => c.contentType == 'mantra').toList();
        if (mantras.isEmpty) return const SizedBox.shrink();
        final todayIndex =
            DateTime.now().dayOfYear % mantras.length;
        final todayMantra = mantras[todayIndex];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'आज का मंत्र — Today\'s Mantra',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _DailyMantraCard(content: todayMantra, phase: phase),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentGrid(UserPregnancyJourney journey) {
    final phase = journey.isPrenatal ? 'prenatal' : 'postnatal';

    final sections = journey.isPrenatal
        ? [
            _ContentSection(
                emoji: '🕉️',
                title: 'Mantras',
                titleHindi: 'मंत्र',
                type: 'mantra',
                color: const Color(0xFFFF9933)),
            _ContentSection(
                emoji: '🧘',
                title: 'Meditations',
                titleHindi: 'ध्यान',
                type: 'meditation',
                color: const Color(0xFF7C3AED)),
            _ContentSection(
                emoji: '💨',
                title: 'Pranayama',
                titleHindi: 'प्राणायाम',
                type: 'pranayama',
                color: const Color(0xFF0EA5E9)),
            _ContentSection(
                emoji: '🌿',
                title: 'Yoga',
                titleHindi: 'योग',
                type: 'yoga',
                color: const Color(0xFF16A34A)),
            _ContentSection(
                emoji: '💛',
                title: 'Affirmations',
                titleHindi: 'पुष्टि',
                type: 'affirmation',
                color: const Color(0xFFF59E0B)),
            _ContentSection(
                emoji: '🥗',
                title: 'Diet Tips',
                titleHindi: 'आहार',
                type: 'diet_tip',
                color: const Color(0xFFEA580C)),
          ]
        : [
            _ContentSection(
                emoji: '🪔',
                title: 'Rituals',
                titleHindi: 'अनुष्ठान',
                type: 'ritual',
                color: const Color(0xFFD97706)),
            _ContentSection(
                emoji: '💛',
                title: 'Affirmations',
                titleHindi: 'पुष्टि',
                type: 'affirmation',
                color: const Color(0xFFF59E0B)),
            _ContentSection(
                emoji: '🥗',
                title: 'Diet Tips',
                titleHindi: 'आहार',
                type: 'diet_tip',
                color: const Color(0xFFEA580C)),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content type grid
          Text(
            'Explore',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: sections.length,
            itemBuilder: (context, i) {
              final section = sections[i];
              return _ContentTypeCard(
                section: section,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GarbhSanskarContentListScreen(
                      phase: phase,
                      contentType: section.type,
                      title: section.title,
                      titleHindi: section.titleHindi,
                      color: section.color,
                      emoji: section.emoji,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Samskaras section
          _SectionNavCard(
            emoji: '🪔',
            title: journey.isPrenatal
                ? 'Prenatal Samskaras'
                : 'Postnatal Samskaras',
            titleHindi: journey.isPrenatal ? 'गर्भ संस्कार' : 'जन्म संस्कार',
            subtitle: journey.isPrenatal
                ? 'Garbhadhana, Pumsavana, Simantonnayana'
                : 'Jatakarma, Namakarana, Nishkramana, Annaprashana',
            color: const Color(0xFFD97706),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GarbhSanskarSamskarasScreen(
                    isPrenatal: journey.isPrenatal),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Lullabies section
          _SectionNavCard(
            emoji: '🌙',
            title: 'Lullabies',
            titleHindi: 'लोरियाँ',
            subtitle: 'Krishna, Ram, Hanuman & more',
            color: const Color(0xFF6366F1),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GarbhSanskarLullabiesScreen(),
              ),
            ),
          ),

          if (journey.isPostnatal) ...[
            const SizedBox(height: 12),
            _SectionNavCard(
              emoji: '⭐',
              title: 'Baby Milestones',
              titleHindi: 'शिशु की उपलब्धियाँ',
              subtitle: 'Track Samskaras & developmental moments',
              color: const Color(0xFFEC4899),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BabyMilestonesScreen(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// HELPER WIDGETS
// ============================================================

class _ContentSection {
  final String emoji;
  final String title;
  final String titleHindi;
  final String type;
  final Color color;

  const _ContentSection({
    required this.emoji,
    required this.title,
    required this.titleHindi,
    required this.type,
    required this.color,
  });
}

class _DailyMantraCard extends StatelessWidget {
  final GarbhSanskarContent content;
  final String phase;

  const _DailyMantraCard({required this.content, required this.phase});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GarbhSanskarContentListScreen(
            phase: phase,
            contentType: 'mantra',
            title: 'Mantras',
            titleHindi: 'मंत्र',
            color: const Color(0xFFFF9933),
            emoji: '🕉️',
            initialContentId: content.id,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF9933).withOpacity(0.15),
              const Color(0xFF2A1000),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFFF9933).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🕉️', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    content.displayTitle,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      color: const Color(0xFFFF9933),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    content.formattedDuration,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.white54),
                  ),
                ),
              ],
            ),
            if (content.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                content.subtitle!,
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.white60),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (content.bodyText != null) ...[
              const SizedBox(height: 10),
              Text(
                content.bodyText!.split('\n').first,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 15,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.play_circle_outline,
                    color: Color(0xFFFF9933), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Tap to listen & read',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFFF9933),
                  ),
                ),
                const Spacer(),
                Text(
                  '+${content.coinsReward} 🪙',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentTypeCard extends StatelessWidget {
  final _ContentSection section;
  final VoidCallback onTap;

  const _ContentTypeCard({required this.section, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: section.color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(section.emoji,
                style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 6),
            Text(
              section.titleHindi,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: section.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              section.title,
              style: GoogleFonts.inter(
                  fontSize: 10, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionNavCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String titleHindi;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SectionNavCard({
    required this.emoji,
    required this.title,
    required this.titleHindi,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleHindi,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }
}
