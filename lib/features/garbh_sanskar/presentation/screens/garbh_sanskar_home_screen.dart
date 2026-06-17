import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/garbh_sanskar_models.dart';
import '../providers/garbh_sanskar_providers.dart';
import 'garbh_sanskar_content_list_screen.dart';
import 'garbh_sanskar_samskaras_screen.dart';
import 'baby_milestones_screen.dart';
import 'garbh_sanskar_setup_screen.dart';

class GarbhSanskarHomeScreen extends ConsumerWidget {
  const GarbhSanskarHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyAsync = ref.watch(journeyNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: journeyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.saffron),
        ),
        error: (e, _) => _buildErrorState(context, e),
        data: (journey) {
          if (journey == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const GarbhSanskarSetupScreen()),
                );
              }
            });
            return const Center(
              child: CircularProgressIndicator(color: AppColors.saffron),
            );
          }
          return _GarbhSanskarHomeBody(journey: journey);
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🪔', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Could not load your journey',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back', style: TextStyle(color: AppColors.saffron)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GarbhSanskarHomeBody extends ConsumerWidget {
  final UserPregnancyJourney journey;
  const _GarbhSanskarHomeBody({required this.journey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (journey.isPlanning) _buildPlanningHeader(),
              if (journey.isPrenatal) _buildWeekTracker(),
              if (journey.isPostnatal) _buildPostnatalHeader(),
              const SizedBox(height: 8),
              if (!journey.isPlanning) _buildGentleVoiceReminder(),
              const SizedBox(height: 8),
              _buildContentGrid(context),
              const SizedBox(height: 16),
              _buildWeeklyReadingGuidance(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    String badge;
    if (journey.isPlanning) {
      badge = 'Planning';
    } else if (journey.isPrenatal) {
      badge = 'Week ${journey.computedCurrentWeek}';
    } else {
      badge = journey.babyAgeLabel;
    }

    return SliverAppBar(
      expandedHeight: 110,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white54, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2A1000), AppColors.backgroundDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(56, 12, 16, 0),
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
                            fontSize: 26,
                            color: AppColors.saffron,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (journey.motherName != null)
                          Text(
                            'Namaste, ${journey.motherName}',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1500),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.saffron.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪔', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          badge,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.saffron,
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

  // ── Planning mode header ──────────────────────────────────

  Widget _buildPlanningHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1030), AppColors.backgroundDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.deepPurple.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌸', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'गर्भधारण योजना',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        color: AppColors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pre-Conception Wellness',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Prepare your body, mind and spirit for this sacred journey. '
              'Follow meditations, gentle practices and Ayurvedic diet tips to create '
              'the best environment for your future baby.',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white54, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Prenatal week tracker ─────────────────────────────────

  Widget _buildWeekTracker() {
    final week = journey.computedCurrentWeek;
    final info = WeekDevelopmentInfo.forWeek(week);
    final progress = week / 40.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1500), Color(0xFF1A0A00)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.saffron.withOpacity(0.3)),
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
                        fontSize: 20,
                        color: AppColors.saffron,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      journey.trimesterLabelHindi,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Text(info.babySizeEmoji, style: const TextStyle(fontSize: 40)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffron),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.child_care, color: Colors.white38, size: 14),
              const SizedBox(width: 5),
              Text(
                'Baby is the size of a ${info.babySize}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            info.babyDevelopment,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.46), height: 1.5),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'सुबह की कोमलता — Sing softly (calm & protection)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  info.gentleBondingTip,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFFFFD700),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Postnatal header ──────────────────────────────────────

  Widget _buildPostnatalHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1A2A), AppColors.backgroundDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('👶', style: TextStyle(fontSize: 44)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journey.babyName != null
                      ? '${journey.babyName} is here!'
                      : 'Your baby is here!',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  journey.babyAgeLabel,
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6366F1)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Continue your sacred journey',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.46)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Gentle voice (no in-app audio; encourages live lullaby / hum) ──

  Widget _buildGentleVoiceReminder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.saffron.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.saffron.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌙', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'आज की आवाज़ — Your voice today',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.46),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Take a few quiet minutes to hum or sing softly to your baby. '
                  'Your calm, live voice matters more than any recording.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Content grid ──────────────────────────────────────────

  Widget _buildContentGrid(BuildContext context) {
    final phase = journey.isPlanning
        ? 'all'
        : journey.isPrenatal
            ? 'prenatal'
            : 'postnatal';

    final sections = journey.isPlanning
        ? [
            _Section(emoji: '🕉️', title: 'Mantras', titleHindi: 'मंत्र', type: 'mantra', color: AppColors.saffron),
            _Section(emoji: '🧘', title: 'Meditations', titleHindi: 'ध्यान', type: 'meditation', color: AppColors.deepPurple),
            _Section(emoji: '🌿', title: 'Yoga', titleHindi: 'योग', type: 'yoga', color: const Color(0xFF16A34A)),
            _Section(emoji: '💛', title: 'Affirmations', titleHindi: 'पुष्टि', type: 'affirmation', color: const Color(0xFFF59E0B)),
            _Section(emoji: '🥗', title: 'Diet Tips', titleHindi: 'आहार', type: 'diet_tip', color: const Color(0xFFEA580C)),
            _Section(emoji: '💨', title: 'Pranayama', titleHindi: 'प्राणायाम', type: 'pranayama', color: const Color(0xFF0EA5E9)),
          ]
        : journey.isPrenatal
            ? [
                _Section(emoji: '🕉️', title: 'Mantras', titleHindi: 'मंत्र', type: 'mantra', color: AppColors.saffron),
                _Section(emoji: '🧘', title: 'Meditations', titleHindi: 'ध्यान', type: 'meditation', color: AppColors.deepPurple),
                _Section(emoji: '💨', title: 'Pranayama', titleHindi: 'प्राणायाम', type: 'pranayama', color: const Color(0xFF0EA5E9)),
                _Section(emoji: '🌿', title: 'Yoga', titleHindi: 'योग', type: 'yoga', color: const Color(0xFF16A34A)),
                _Section(emoji: '💛', title: 'Affirmations', titleHindi: 'पुष्टि', type: 'affirmation', color: const Color(0xFFF59E0B)),
                _Section(emoji: '🥗', title: 'Diet Tips', titleHindi: 'आहार', type: 'diet_tip', color: const Color(0xFFEA580C)),
              ]
            : [
                _Section(emoji: '🪔', title: 'Rituals', titleHindi: 'अनुष्ठान', type: 'ritual', color: const Color(0xFFD97706)),
                _Section(emoji: '💛', title: 'Affirmations', titleHindi: 'पुष्टि', type: 'affirmation', color: const Color(0xFFF59E0B)),
                _Section(emoji: '🥗', title: 'Diet Tips', titleHindi: 'आहार', type: 'diet_tip', color: const Color(0xFFEA580C)),
              ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.95,
            ),
            itemCount: sections.length,
            itemBuilder: (context, i) {
              final s = sections[i];
              return _ContentTypeCard(
                section: s,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GarbhSanskarContentListScreen(
                      phase: phase,
                      contentType: s.type,
                      title: s.title,
                      titleHindi: s.titleHindi,
                      color: s.color,
                      emoji: s.emoji,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Samskaras
          if (!journey.isPlanning)
            _NavCard(
              emoji: '🪔',
              title: journey.isPrenatal ? 'Prenatal Samskaras' : 'Postnatal Samskaras',
              titleHindi: journey.isPrenatal ? 'गर्भ संस्कार' : 'जन्म संस्कार',
              subtitle: journey.isPrenatal
                  ? 'Garbhadhana, Pumsavana, Simantonnayana'
                  : 'Jatakarma, Namakarana, Nishkramana, Annaprashana',
              color: const Color(0xFFD97706),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GarbhSanskarSamskarasScreen(isPrenatal: journey.isPrenatal),
                ),
              ),
            ),
          if (journey.isPlanning)
            _NavCard(
              emoji: '🪔',
              title: 'All Samskaras',
              titleHindi: 'संस्कार',
              subtitle: 'Learn about prenatal & postnatal sacred ceremonies',
              color: const Color(0xFFD97706),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GarbhSanskarSamskarasScreen(isPrenatal: true),
                ),
              ),
            ),
          const SizedBox(height: 10),

          if (journey.isPostnatal) ...[
            const SizedBox(height: 10),
            _NavCard(
              emoji: '⭐',
              title: 'Baby Milestones',
              titleHindi: 'शिशु की उपलब्धियाँ',
              subtitle: 'Track Samskaras & developmental moments',
              color: const Color(0xFFEC4899),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BabyMilestonesScreen()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Weekly reading: encourage reading without naming specific texts ──

  Widget _buildWeeklyReadingGuidance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'पठन — Reading',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.ashramCardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.saffron.withOpacity(0.15)),
            ),
            child: Text(
              'When you can, read aloud from any sacred or uplifting material you already have. '
              'We do not list specific books or paths here — use what is meaningful and available to you.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.72),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HELPER WIDGETS & DATA
// ============================================================

class _Section {
  final String emoji, title, titleHindi, type;
  final Color color;
  const _Section({
    required this.emoji,
    required this.title,
    required this.titleHindi,
    required this.type,
    required this.color,
  });
}

class _ContentTypeCard extends StatelessWidget {
  final _Section section;
  final VoidCallback onTap;
  const _ContentTypeCard({required this.section, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.ashramCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: section.color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(section.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(
              section.titleHindi,
              style: GoogleFonts.inter(fontSize: 12, color: section.color, fontWeight: FontWeight.w600),
            ),
            Text(
              section.title,
              style: GoogleFonts.inter(fontSize: 9, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String emoji, title, titleHindi, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.ashramCardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleHindi,
                    style: GoogleFonts.inter(fontSize: 14, color: color, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withOpacity(0.46)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
