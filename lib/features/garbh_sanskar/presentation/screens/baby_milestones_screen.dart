import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/garbh_sanskar_models.dart';
import '../../data/repositories/garbh_sanskar_repository.dart';
import '../providers/garbh_sanskar_providers.dart';

/// Baby milestones tracker — Samskaras + developmental milestones
class BabyMilestonesScreen extends ConsumerStatefulWidget {
  const BabyMilestonesScreen({super.key});

  @override
  ConsumerState<BabyMilestonesScreen> createState() =>
      _BabyMilestonesScreenState();
}

class _BabyMilestonesScreenState
    extends ConsumerState<BabyMilestonesScreen> {
  final GarbhSanskarRepository _repo = GarbhSanskarRepository();

  // All possible milestones to track
  static const _allMilestoneTypes = [
    ('jatakarma', '🪔', 'Jatakarma', 'Birth ceremony'),
    ('namakarana', '📿', 'Namakarana', 'Naming ceremony'),
    ('nishkramana', '☀️', 'Nishkramana', 'First outing'),
    ('annaprashana', '🍚', 'Annaprashana', 'First solid food'),
    ('chudakarana', '✂️', 'Chudakarana', 'First haircut'),
    ('karnavedha', '💎', 'Karnavedha', 'Ear piercing'),
    ('vidyarambha', '📚', 'Vidyarambha', 'Start of learning'),
    ('first_smile', '😊', 'First Smile', 'Developmental'),
    ('first_laugh', '😂', 'First Laugh', 'Developmental'),
    ('head_control', '💪', 'Head Control', 'Developmental'),
    ('sitting', '🧸', 'Sitting Up', 'Developmental'),
    ('crawling', '🐾', 'Crawling', 'Developmental'),
    ('first_word', '🗣️', 'First Word', 'Developmental'),
    ('first_step', '👣', 'First Step', 'Developmental'),
  ];

  @override
  Widget build(BuildContext context) {
    final milestonesAsync = ref.watch(babyMilestonesProvider);
    final journeyAsync = ref.watch(journeyNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A06),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0A06),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'शिशु की उपलब्धियाँ',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                color: const Color(0xFFEC4899),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Baby Milestones',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: Color(0xFFEC4899)),
            onPressed: () => _showAddMilestoneSheet(context),
          ),
        ],
      ),
      body: milestonesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFEC4899)),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.white)),
        ),
        data: (completedMilestones) {
          final completedTypes =
              completedMilestones.map((m) => m.milestoneType).toSet();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Journey stats
              journeyAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (journey) {
                  if (journey == null) return const SizedBox.shrink();
                  return _buildStatsCard(
                      journey, completedMilestones.length);
                },
              ),
              const SizedBox(height: 16),

              // Milestone grid
              Text(
                'Samskaras & Milestones',
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
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                ),
                itemCount: _allMilestoneTypes.length,
                itemBuilder: (context, i) {
                  final (type, emoji, name, category) =
                      _allMilestoneTypes[i];
                  final isCompleted = completedTypes.contains(type);
                  final milestone = completedMilestones
                      .where((m) => m.milestoneType == type)
                      .firstOrNull;

                  return _MilestoneCard(
                    emoji: emoji,
                    name: name,
                    category: category,
                    isCompleted: isCompleted,
                    milestone: milestone,
                    onTap: isCompleted
                        ? null
                        : () => _logMilestone(context, type, name),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Timeline of completed milestones
              if (completedMilestones.isNotEmpty) ...[
                Text(
                  'Timeline',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...completedMilestones.map(
                  (m) => _TimelineTile(milestone: m),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(
      UserPregnancyJourney journey, int completedCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A0A1A), Color(0xFF0D0A06)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFEC4899).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('👶', style: TextStyle(fontSize: 44)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (journey.babyName != null)
                  Text(
                    journey.babyName!,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  journey.babyAgeLabel,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFFEC4899)),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount / ${_allMilestoneTypes.length} milestones',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white54),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: completedCount / _allMilestoneTypes.length,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFEC4899)),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logMilestone(
      BuildContext context, String type, String name) async {
    final journey =
        ref.read(journeyNotifierProvider).valueOrNull;
    final babyAgeDays = journey?.babyAgeInDays;

    final success = await _repo.addMilestone(
      milestoneType: type,
      milestoneDate: DateTime.now(),
      babyAgeDays: babyAgeDays,
    );

    if (success && mounted) {
      ref.invalidate(babyMilestonesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2A0A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                '$name logged! +10 🪙',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showAddMilestoneSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D23),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log a Milestone',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                color: const Color(0xFFEC4899),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap any milestone card to log it for today.',
              style: GoogleFonts.inter(
                  fontSize: 14, color: Colors.white60),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String category;
  final bool isCompleted;
  final BabyMilestone? milestone;
  final VoidCallback? onTap;

  const _MilestoneCard({
    required this.emoji,
    required this.name,
    required this.category,
    required this.isCompleted,
    this.milestone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF2A0A1A)
              : const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFFEC4899).withOpacity(0.5)
                : Colors.white12,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji,
                    style: const TextStyle(fontSize: 24)),
                if (isCompleted)
                  const Icon(Icons.check_circle,
                      color: Color(0xFFEC4899), size: 18)
                else
                  const Icon(Icons.add_circle_outline,
                      color: Colors.white24, size: 18),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isCompleted
                        ? const Color(0xFFEC4899)
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isCompleted && milestone != null
                      ? _formatDate(milestone!.milestoneDate)
                      : category,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TimelineTile extends StatelessWidget {
  final BabyMilestone milestone;

  const _TimelineTile({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Text(
            milestone.milestoneEmoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.milestoneLabel,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (milestone.babyAgeDays != null)
                  Text(
                    'At ${_formatAge(milestone.babyAgeDays!)}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white54),
                  ),
              ],
            ),
          ),
          Text(
            '${milestone.milestoneDate.day}/${milestone.milestoneDate.month}/${milestone.milestoneDate.year}',
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  String _formatAge(int days) {
    if (days < 7) return '$days days';
    if (days < 30) return '${days ~/ 7} weeks';
    return '${days ~/ 30} months';
  }
}
