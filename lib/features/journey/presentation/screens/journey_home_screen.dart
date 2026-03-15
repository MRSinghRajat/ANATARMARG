import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../data/journey_logic.dart';
import '../../data/models/journey_models.dart';
import '../providers/journey_providers.dart';
import '../widgets/journey_phase_chips.dart';

class JourneyHomeScreen extends ConsumerWidget {
  final String userJourneyId;

  const JourneyHomeScreen({super.key, required this.userJourneyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyAsync = ref.watch(userJourneyProvider(userJourneyId));
    return Scaffold(
      backgroundColor: AppColors.ashramBackgroundDark,
      body: journeyAsync.when(
        data: (userJourney) {
          if (userJourney == null) {
            return Center(
              child: Text(
                'Journey not found',
                style: GoogleFonts.inter(color: AppColors.zinc500),
              ),
            );
          }
          return _JourneyHomeBody(
            userJourneyId: userJourneyId,
            userJourney: userJourney,
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.matteGold),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading…',
                style: GoogleFonts.inter(color: AppColors.zinc500, fontSize: 14),
              ),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Something went wrong',
              style: GoogleFonts.inter(color: AppColors.zinc500),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyHomeBody extends ConsumerWidget {
  final String userJourneyId;
  final UserJourney userJourney;

  const _JourneyHomeBody({required this.userJourneyId, required this.userJourney});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(journeyTasksProvider(userJourney.journeyTypeId));
    final todaysAsync = ref.watch(todaysJourneyTasksProvider(userJourneyId));
    final typesAsync = ref.watch(journeyTypesProvider);
    final typeList = typesAsync.valueOrNull?.where((t) => t.id == userJourney.journeyTypeId).toList() ?? [];
    final journeyType = typeList.isNotEmpty ? typeList.first : null;
    final milestonesAsync = ref.watch(journeyMilestonesProvider(userJourney.journeyTypeId));

    final allTasks = tasksAsync.valueOrNull ?? [];
    final todaysTasks = todaysAsync.valueOrNull ?? [];
    final milestones = milestonesAsync.valueOrNull ?? [];

    JourneyPhase? phase;
    List<JourneyPhase> phases = [];
    if (allTasks.isNotEmpty) {
      phases = JourneyLogic.extractPhases(allTasks);
      try {
        phase = JourneyLogic.getCurrentPhase(userJourney, phases);
      } catch (_) {}
    }

    final completedMilestoneIdsAsync = ref.watch(
      FutureProvider.family<List<String>, String>((ref, ujId) async {
        final repo = ref.read(journeyRepositoryProvider);
        return repo.getCompletedMilestoneIds(userJourney.userId, ujId);
      })(userJourneyId),
    );
    final completedMilestoneIds = completedMilestoneIdsAsync.valueOrNull ?? [];
    final completedDatesAsync = ref.watch(completedMilestoneDatesProvider(userJourneyId));
    final completedDates = completedDatesAsync.valueOrNull ?? {};

    final completedTasksToday = todaysTasks.where((twc) => twc.isCompleted).length;
    final totalXP = _computeTotalXP(completedTasksToday, completedMilestoneIds.length, todaysTasks);
    final samskarasCount = completedMilestoneIds.length;

    final upcomingMilestones = milestones.where((m) => !completedMilestoneIds.contains(m.id)).toList();
    final completedMilestones = milestones.where((m) => completedMilestoneIds.contains(m.id)).toList();

    final subtitle = _buildSubtitle(userJourney);
    final journeyTitle = journeyType?.title ?? 'My Journey';

    return Column(
      children: [
        // ─── Static header: does not scroll ───
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.zinc100, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.matteGold.withValues(alpha: 0.2),
                          border: Border.all(color: AppColors.matteGold.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Icon(Icons.child_care_rounded, color: AppColors.matteGold, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                journeyTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.zinc100,
                                ),
                              ),
                              if (subtitle != null && subtitle.isNotEmpty)
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.zinc500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: AppColors.matteGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(999),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.search_rounded, color: AppColors.matteGold, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.matteGold,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(999),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.zinc100, size: 24),
                  color: const Color(0xFF2A2618),
                  onSelected: (value) => _onMenuSelected(context, ref, value),
                  itemBuilder: (ctx) {
                    const menuStyle = TextStyle(color: Colors.white, fontSize: 14);
                    return [
                      PopupMenuItem(value: 'switch', child: Text('Switch journey', style: menuStyle)),
                      if (userJourney.isPaused)
                        PopupMenuItem(value: 'resume', child: Text('Resume journey', style: menuStyle)),
                      PopupMenuItem(value: 'remove', child: Text('Remove journey', style: menuStyle)),
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
        // ─── Scrollable content ───
        Expanded(
          child: CustomScrollView(
            slivers: [
        // ─── Stats Overview (glass cards, centered like HTML) ───
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: _formatXP(totalXP),
                    label: 'Total XP',
                    primary: AppColors.matteGold,
                    textMuted: AppColors.zinc500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    value: samskarasCount.toString().padLeft(2, '0'),
                    label: 'Samskaras',
                    primary: AppColors.matteGold,
                    textMuted: AppColors.zinc500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Spiritual Daily Tasks (all tasks from backend) ───
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spiritual Daily Tasks',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.zinc100,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.matteGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (todaysTasks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                'No tasks for today. Check back tomorrow.',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.zinc500),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final twc = todaysTasks[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: _DailyTaskRow(
                    task: twc.task,
                    isCompleted: twc.isCompleted,
                    primary: AppColors.matteGold,
                    text: AppColors.zinc100,
                    textMuted: AppColors.zinc500,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRouter.journeyTask,
                      arguments: {'userJourneyId': userJourneyId, 'taskId': twc.task.id},
                    ),
                  ),
                );
              },
              childCount: todaysTasks.length,
            ),
          ),

        // ─── Samskaras & Milestones (all from backend) ───
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Samskaras & Milestones',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.zinc100,
                  ),
                ),
                Icon(Icons.info_outline_rounded, size: 22, color: AppColors.zinc500),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // All upcoming milestones from backend
                ...upcomingMilestones.map((m) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _MilestoneCard(
                    title: m.title,
                    subtitle: m.description ?? 'Coming up',
                    label: 'COMING UP',
                    progress: 0.65,
                    progressLabel: '65% Prepared',
                    daysLeft: '12 Days Left',
                    isCompleted: false,
                    primary: AppColors.matteGold,
                    text: AppColors.zinc100,
                    textMuted: AppColors.zinc500,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRouter.journeyMilestone,
                      arguments: {'userJourneyId': userJourneyId, 'milestoneId': m.id},
                    ),
                  ),
                )),
                // All completed milestones from backend
                ...completedMilestones.map((m) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _MilestoneCard(
                    title: m.title,
                    subtitle: m.description ?? 'Completed',
                    label: 'COMPLETED',
                    completedDate: _formatMilestoneDate(completedDates[m.id]),
                    coinReward: m.coinReward,
                    isCompleted: true,
                    primary: AppColors.matteGold,
                    text: AppColors.zinc100,
                    textMuted: AppColors.zinc500,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRouter.journeyMilestone,
                      arguments: {'userJourneyId': userJourneyId, 'milestoneId': m.id},
                    ),
                  ),
                )),
                if (upcomingMilestones.isEmpty && completedMilestones.isEmpty)
                  _EmptyMilestoneCard(textMuted: AppColors.zinc500),
              ],
            ),
          ),
        ),

        // ─── Daily Wisdom (primary bg + white text like HTML) ───
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.matteGold,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.matteGold.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_rounded, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Wisdom',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Repeating sacred chants around a child helps build a serene subconscious environment.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.45,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
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

        // ─── Your journey (phase chips) ───
        if (phases.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your journey',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.zinc100,
                    ),
                  ),
                  const SizedBox(height: 12),
                  JourneyPhaseChips(
                    phases: phases,
                    currentPhaseId: phase?.id,
                    completedPhaseIds: phases
                        .where((p) => (phase?.phaseOrder ?? 0) > p.phaseOrder)
                        .map((p) => p.id)
                        .toSet(),
                  ),
                ],
              ),
            ),
          ),

      ],
          ),
        ),
      ],
    );
  }

  int _computeTotalXP(int completedTasksToday, int completedMilestones, List<JourneyTaskWithCompletion> todaysTasks) {
    int xp = completedMilestones * 50;
    for (final twc in todaysTasks) {
      if (twc.isCompleted) xp += twc.task.coinReward;
    }
    return xp;
  }

  String _formatXP(int xp) {
    final s = xp.toString();
    return s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  void _onMenuSelected(BuildContext context, WidgetRef ref, String value) async {
    final repo = ref.read(journeyRepositoryProvider);
    if (value == 'resume') {
      await repo.resumeJourney(userJourneyId);
      ref.invalidate(activeJourneyProvider);
      ref.invalidate(allUserJourneysProvider);
      if (context.mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } else if (value == 'remove') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remove journey?'),
          content: const Text('This will delete your journey. You can start a new one anytime.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Remove')),
          ],
        ),
      );
      if (confirm == true) {
        await repo.deleteJourney(userJourneyId);
        ref.invalidate(activeJourneyProvider);
        ref.invalidate(allUserJourneysProvider);
        if (context.mounted) {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      }
    } else if (value == 'switch') {
      if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  String _formatMilestoneDate(DateTime? d) {
    if (d == null) return 'Completed';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
    final m = d.month >= 1 && d.month <= 12 ? months[d.month - 1] : '${d.month}';
    return '$m ${d.day}, ${d.year}';
  }

  String? _buildSubtitle(UserJourney uj) {
    final meta = uj.metadata;
    if (meta.containsKey('child_dob')) {
      final dob = DateTime.tryParse(meta['child_dob'] as String? ?? '');
      if (dob != null) {
        final days = DateTime.now().difference(dob).inDays;
        final m = (days / 30).floor();
        return 'Day $days • $m Months Old';
      }
    }
    if (uj.startDate != null) {
      final day = DateTime.now().difference(uj.startDate!).inDays;
      return 'Day $day';
    }
    return null;
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color primary;
  final Color textMuted;

  const _StatCard({
    required this.value,
    required this.label,
    required this.primary,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF52481F).withValues(alpha: 0.15),
            const Color(0xFF1E1C14).withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: primary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTaskRow extends StatelessWidget {
  final JourneyTask task;
  final bool isCompleted;
  final Color primary;
  final Color text;
  final Color textMuted;
  final VoidCallback? onTap;

  const _DailyTaskRow({
    required this.task,
    required this.isCompleted,
    required this.primary,
    required this.text,
    required this.textMuted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final duration = task.durationMinutes != null ? '${task.durationMinutes} mins' : '';
    final timeLabel = task.frequency == 'daily' ? 'Daily' : task.frequency;
    final subtitle = [duration, timeLabel].where((e) => e.isNotEmpty).join(' • ');
    final tag = task.phaseTitle ?? 'Practice';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: primary.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check_rounded, color: primary, size: 24)
                      : (task.icon != null && task.icon!.length <= 2
                          ? Text(task.icon!, style: const TextStyle(fontSize: 22))
                          : Icon(_taskIconFromSlug(task.slug), color: primary, size: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: text,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: textMuted,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(fontSize: 14, color: textMuted),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (task.coinReward > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '+${task.coinReward} XP',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: primary),
                            ),
                          ),
                        if (task.coinReward > 0) const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: textMuted.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.inter(fontSize: 10, color: textMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.transparent : primary,
                  borderRadius: BorderRadius.circular(999),
                  border: isCompleted ? Border.all(color: primary.withValues(alpha: 0.4)) : null,
                  boxShadow: isCompleted ? null : [BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 8)],
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
                  color: isCompleted ? primary : Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _taskIconFromSlug(String slug) {
    final s = slug.toLowerCase();
    if (s.contains('chant') || s.contains('om')) return Icons.graphic_eq_rounded;
    if (s.contains('lullaby') || s.contains('bed') || s.contains('night')) return Icons.nightlight_round;
    if (s.contains('morning') || s.contains('blessing') || s.contains('waking')) return Icons.wb_sunny_rounded;
    return Icons.self_improvement_rounded;
  }
}

class _MilestoneCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String label;
  final double? progress;
  final String? progressLabel;
  final String? daysLeft;
  final String? completedDate;
  final int? coinReward;
  final bool isCompleted;
  final Color primary;
  final Color text;
  final Color textMuted;
  final VoidCallback? onTap;

  const _MilestoneCard({
    required this.title,
    required this.subtitle,
    required this.label,
    this.progress,
    this.progressLabel,
    this.daysLeft,
    this.completedDate,
    this.coinReward,
    required this.isCompleted,
    required this.primary,
    required this.text,
    required this.textMuted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isCompleted
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF52481F).withValues(alpha: 0.15),
                      const Color(0xFF1E1C14).withValues(alpha: 0.4),
                    ],
                  ),
            color: isCompleted ? primary.withValues(alpha: 0.1) : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withValues(alpha: isCompleted ? 0.2 : 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: primary, letterSpacing: 1.5),
                  ),
                  if (!isCompleted)
                    Icon(Icons.history_edu_rounded, size: 22, color: primary.withValues(alpha: 0.5)),
                  if (isCompleted)
                    Icon(Icons.verified_rounded, size: 22, color: primary.withValues(alpha: 0.5)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isCompleted ? textMuted : text,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (progress != null && progressLabel != null && daysLeft != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: textMuted.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(progressLabel!, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: textMuted)),
                    Text(daysLeft!, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: text)),
                  ],
                ),
              ],
              if (isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (completedDate != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: primary),
                          const SizedBox(width: 4),
                          Text(completedDate!, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: primary)),
                        ],
                      ),
                    if (coinReward != null && coinReward! > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+$coinReward XP',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMilestoneCard extends StatelessWidget {
  final Color textMuted;

  const _EmptyMilestoneCard({required this.textMuted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF52481F).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF52481F).withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Text(
          'No milestones yet',
          style: GoogleFonts.inter(fontSize: 14, color: textMuted),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color primary;
  final Color textMuted;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.primary,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: isActive ? primary : textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isActive ? primary : textMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
