import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../theme/journey_ashram_theme.dart';
import '../../../../core/utils/app_router.dart';
import '../../data/journey_logic.dart';
import '../../data/models/journey_models.dart';
import '../providers/journey_providers.dart';
import '../widgets/journey_phase_chips.dart';
import '../../../navigation/presentation/providers/main_navigation_intent_provider.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';

// Task-type badge colours (generic — driven by task.taskType from DB)
Color _taskTypeColor(String? type) {
  switch (type) {
    case 'mantra':   return const Color(0xFFF59E0B);
    case 'meditation': return const Color(0xFF818CF8);
    case 'yoga':     return const Color(0xFF34D399);
    case 'ritual':   return const Color(0xFFF472B6);
    case 'audio':    return const Color(0xFF38BDF8);
    case 'read':     return const Color(0xFFA78BFA);
    case 'lullaby':  return const Color(0xFFFB923C);
    default:         return AppColors.zinc500;
  }
}

String _taskTypeLabel(String? type) {
  switch (type) {
    case 'mantra':    return '📿 Mantra';
    case 'meditation': return '🧘 Meditation';
    case 'yoga':      return '🌿 Yoga';
    case 'ritual':    return '🪔 Ritual';
    case 'audio':     return '🎵 Audio';
    case 'read':      return '📖 Read';
    case 'lullaby':   return '🌙 Sing (your song)';
    default:          return '✦ Practice';
  }
}

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
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange),
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

class _JourneyHomeBody extends ConsumerStatefulWidget {
  final String userJourneyId;
  final UserJourney userJourney;

  const _JourneyHomeBody({required this.userJourneyId, required this.userJourney});

  @override
  ConsumerState<_JourneyHomeBody> createState() => _JourneyHomeBodyState();
}

class _JourneyHomeBodyState extends ConsumerState<_JourneyHomeBody> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final id = widget.userJourneyId;
      ref.invalidate(todaysJourneyTasksProvider(id));
      ref.invalidate(displayedJourneyTasksProvider(id));
      ref.invalidate(journeyCompletedTaskIdsTodayProvider(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userJourneyId = widget.userJourneyId;
    final userJourney = widget.userJourney;
    final tasksAsync = ref.watch(journeyTasksProvider(userJourney.journeyTypeId));
    final todaysAsync = ref.watch(todaysJourneyTasksProvider(userJourneyId));
    final displayedAsync = ref.watch(displayedJourneyTasksProvider(userJourneyId));
    final browsePhaseId = ref.watch(journeyBrowsePhaseIdProvider(userJourneyId));
    final typesAsync = ref.watch(journeyTypesProvider);
    final typeList = typesAsync.valueOrNull?.where((t) => t.id == userJourney.journeyTypeId).toList() ?? [];
    final journeyType = typeList.isNotEmpty ? typeList.first : null;
    final milestonesAsync = ref.watch(journeyMilestonesProvider(userJourney.journeyTypeId));

    final allTasks = tasksAsync.valueOrNull ?? [];
    final todaysTasks = todaysAsync.valueOrNull ?? [];
    final displayedTasks = displayedAsync.valueOrNull ?? [];
    final milestones = milestonesAsync.valueOrNull ?? [];

    JourneyPhase? phase;
    List<JourneyPhase> phases = [];
    if (allTasks.isNotEmpty) {
      phases = JourneyLogic.extractPhases(allTasks);
      try {
        phase = JourneyLogic.getCurrentPhase(userJourney, phases);
      } catch (_) {}
    }

    final completedMilestoneIdsAsync =
        ref.watch(journeyCompletedMilestoneIdsProvider(userJourneyId));
    final completedMilestoneIds = completedMilestoneIdsAsync.valueOrNull ?? [];
    final completedDatesAsync = ref.watch(completedMilestoneDatesProvider(userJourneyId));
    final completedDates = completedDatesAsync.valueOrNull ?? {};
    // Union RPC + displayed rows so checkboxes stay correct while provider reloads.
    final rpcCompletedToday =
        ref.watch(journeyCompletedTaskIdsTodayProvider(userJourneyId)).valueOrNull ?? {};
    final completedTaskIdsToday = <String>{
      ...rpcCompletedToday,
      ...displayedTasks.where((t) => t.isCompleted).map((t) => t.task.id),
    };

    final sortedMilestones = List<JourneyMilestone>.from(milestones)
      ..sort((a, b) {
        if (a.isRequired != b.isRequired) return a.isRequired ? -1 : 1;
        return a.milestoneOrder.compareTo(b.milestoneOrder);
      });

    final upcomingMilestones =
        sortedMilestones.where((m) => !completedMilestoneIds.contains(m.id)).toList();
    final completedMilestones =
        sortedMilestones.where((m) => completedMilestoneIds.contains(m.id)).toList();

    final requiredMilestones = milestones.where((m) => m.isRequired).toList();
    final dailyPathComplete = todaysTasks.isNotEmpty &&
        todaysTasks.every((twc) => completedTaskIdsToday.contains(twc.task.id));
    final milestonesComplete = requiredMilestones.isNotEmpty &&
        requiredMilestones.every((m) => completedMilestoneIds.contains(m.id));
    // Only collapse when there are actually milestones AND they are all done.
    // Previously collapsed when milestones was empty (hiding the placeholder).
    final collapseMilestoneCarousel = milestones.isNotEmpty &&
        (dailyPathComplete || milestonesComplete);

    final subtitle = _buildSubtitle(userJourney);
    final journeyTitle = journeyType?.title ?? 'My Journey';

    final selectedChipPhaseId = browsePhaseId ?? phase?.id;
    final isPreviewingOtherPhase =
        browsePhaseId != null && phase != null && browsePhaseId != phase.id;
    String? previewPhaseTitle;
    if (isPreviewingOtherPhase) {
      for (final p in phases) {
        if (p.id == browsePhaseId) {
          previewPhaseTitle = p.title;
          break;
        }
      }
    }

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
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.zinc100, size: 24),
                  color: AppColors.ashramCardDark,
                  onSelected: (value) => _onMenuSelected(context, value),
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
        // ─── Progress Banner ───────────────────────────────────────────────
        if (phases.isNotEmpty)
          SliverToBoxAdapter(
            child: _JourneyProgressBanner(
              userJourney: userJourney,
              phases: phases,
              currentPhase: phase,
              todaysDoneCount: completedTaskIdsToday
                  .where((id) => todaysTasks.any((t) => t.task.id == id))
                  .length,
              todaysTotalCount: todaysTasks.length,
            ),
          ),

        // ─── Phase chips ───────────────────────────────────────────────────
        if (phases.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JourneyPhaseChips(
                    phases: phases,
                    calendarPhaseId: phase?.id,
                    selectedPhaseId: selectedChipPhaseId,
                    completedPhaseIds: phases
                        .where((p) => (phase?.phaseOrder ?? 0) > p.phaseOrder)
                        .map((p) => p.id)
                        .toSet(),
                    onPhaseTap: (id) {
                      if (id == phase?.id) {
                        ref.read(journeyBrowsePhaseIdProvider(userJourneyId).notifier).state = null;
                      } else {
                        ref.read(journeyBrowsePhaseIdProvider(userJourneyId).notifier).state = id;
                      }
                    },
                  ),
                  if (isPreviewingOtherPhase && previewPhaseTitle != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Preview: $previewPhaseTitle — tasks unlock when you reach this stage.',
                        style: GoogleFonts.inter(fontSize: 13, height: 1.35, color: AppColors.zinc500),
                      ),
                    ),
                  ],
                  if (userJourney.isCompleted) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'This journey is complete. You can open tasks to read them, but you cannot mark them again.',
                        style: GoogleFonts.inter(fontSize: 13, height: 1.35, color: AppColors.zinc500),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

        // ─── Spiritual Daily Tasks (all tasks from backend) ───
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Spiritual Daily Tasks',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.zinc100,
                    ),
                  ),
                ),
                if (displayedTasks.isNotEmpty) ...[
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: Checkbox(
                      value: dailyPathComplete,
                      onChanged: null,
                      shape: const CircleBorder(),
                      side: BorderSide(color: AppColors.zinc500.withValues(alpha: 0.8)),
                      fillColor: WidgetStateProperty.resolveWith(
                        (s) => s.contains(WidgetState.selected)
                            ? Colors.greenAccent.withValues(alpha: 0.85)
                            : null,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        if (displayedTasks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                phase == null
                    ? 'No tasks for this stage yet.'
                    : 'No tasks for this view. Check back when your journey reaches the next stage.',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.zinc500),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final twc = displayedTasks[index];
                final isDoneToday = completedTaskIdsToday.contains(twc.task.id);
                final blocked = JourneyLogic.taskCompletionBlockedReason(
                  userJourney: userJourney,
                  task: twc.task,
                  calendarPhase: phase,
                  allTasks: allTasks,
                  completedTaskIdsToday: completedTaskIdsToday,
                );
                final canCheck = userJourney.isActive &&
                    !userJourney.isCompleted &&
                    !isDoneToday &&
                    blocked == null;
                final canUncheck =
                    userJourney.isActive && !userJourney.isCompleted && isDoneToday;
                final checkboxEnabled = canCheck || canUncheck;

                return Padding(
                  key: ValueKey<String>('journey_daily_${twc.task.id}'),
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: _DailyTaskRow(
                    task: twc.task,
                    isCompleted: isDoneToday,
                    checkboxEnabled: checkboxEnabled,
                    primary: AppColors.primaryOrange,
                    text: AppColors.zinc100,
                    textMuted: AppColors.zinc500,
                    onOpenDetail: () => Navigator.of(context).pushNamed(
                      AppRouter.journeyTask,
                      arguments: {'userJourneyId': userJourneyId, 'taskId': twc.task.id},
                    ),
                    onCheckboxChanged: checkboxEnabled
                        ? (v) => _onJourneyTaskCheckbox(context, twc, v)
                        : null,
                  ),
                );
              },
              childCount: displayedTasks.length,
            ),
          ),

        // ─── Samskaras & Milestones (all from backend) ───
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Samskaras & Milestones',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.zinc100,
                    ),
                  ),
                ),
                if (requiredMilestones.isNotEmpty) ...[
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: Checkbox(
                      value: milestonesComplete,
                      onChanged: null,
                      shape: const CircleBorder(),
                      side: BorderSide(color: AppColors.zinc500.withValues(alpha: 0.8)),
                      fillColor: WidgetStateProperty.resolveWith(
                        (s) => s.contains(WidgetState.selected)
                            ? Colors.greenAccent.withValues(alpha: 0.85)
                            : null,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        if (collapseMilestoneCarousel)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 24,
                    color: Colors.greenAccent.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      milestones.isEmpty
                          ? 'Samskaras will appear as your journey progresses.'
                          : "You're caught up. Open any milestone from this journey when you're ready.",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.45,
                        color: AppColors.zinc500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...upcomingMilestones.map((m) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _MilestoneCard(
                          title: m.title,
                          subtitle: m.isRequired
                              ? (m.description ?? 'Required samskara')
                              : (m.description ?? 'Optional milestone'),
                          label: m.isRequired ? 'REQUIRED' : 'OPTIONAL',
                          isRequired: m.isRequired,
                          isCompleted: false,
                          primary: AppColors.primaryOrange,
                          text: AppColors.zinc100,
                          textMuted: AppColors.zinc500,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRouter.journeyMilestone,
                            arguments: {'userJourneyId': userJourneyId, 'milestoneId': m.id},
                          ),
                        ),
                      )),
                  ...completedMilestones.map((m) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _MilestoneCard(
                          title: m.title,
                          subtitle: m.description ?? 'Completed',
                          label: 'COMPLETED',
                          completedDate: _formatMilestoneDate(completedDates[m.id]),
                          isRequired: m.isRequired,
                          isCompleted: true,
                          primary: AppColors.primaryOrange,
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

        // ─── Daily Wisdom — dynamic, rotates by journey day ───────────────
        SliverToBoxAdapter(
          child: _DynamicWisdomCard(userJourneyId: userJourneyId),
        ),

      ],
          ),
        ),
      ],
    );
  }

  Future<void> _onJourneyTaskCheckbox(
    BuildContext context,
    JourneyTaskWithCompletion twc,
    bool? newValue,
  ) async {
    if (newValue == null) return;
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    final ujId = widget.userJourneyId;
    final repo = ref.read(journeyRepositoryProvider);
    try {
      if (newValue) {
        await repo.completeTask(
          userId: uid,
          userJourneyId: ujId,
          taskId: twc.task.id,
          coinReward: twc.task.coinReward,
        );
      } else {
        await repo.uncompleteTaskToday(
          userId: uid,
          userJourneyId: ujId,
          taskId: twc.task.id,
        );
      }
      ref.invalidate(todaysJourneyTasksProvider(ujId));
      ref.invalidate(displayedJourneyTasksProvider(ujId));
      ref.invalidate(journeyCompletedTaskIdsTodayProvider(ujId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  /// Resets the root stack to [MainNavigationScreen] (same pattern as auth in [AntarMargApp]).
  void _popToMainShell(
    BuildContext context, {
    bool openBooksTab = false,
    void Function(ProviderContainer container)? afterNavigation,
  }) {
    if (!context.mounted) return;
    final container = ProviderScope.containerOf(context);
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      AppRouter.home,
      (route) => false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      afterNavigation?.call(container);
      if (openBooksTab) {
        container.read(mainNavIntentProvider.notifier).state =
            const MainNavIntent(NavItem.books);
      }
    });
  }

  void _onMenuSelected(BuildContext context, String value) async {
    final userJourneyId = widget.userJourneyId;
    final repo = ref.read(journeyRepositoryProvider);
    if (value == 'resume') {
      await repo.resumeJourney(userJourneyId);
      ref.invalidate(activeJourneyProvider);
      ref.invalidate(activeJourneysProvider);
      ref.invalidate(allUserJourneysProvider);
      if (!context.mounted) return;
      _popToMainShell(context);
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
        if (!context.mounted) return;
        _popToMainShell(
          context,
          openBooksTab: true,
          afterNavigation: (c) =>
              invalidateCachesForDeletedUserJourney(c, userJourneyId),
        );
      }
    } else if (value == 'switch') {
      _popToMainShell(context);
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

class _DailyTaskRow extends StatelessWidget {
  final JourneyTask task;
  final bool isCompleted;
  final bool checkboxEnabled;
  final Color primary;
  final Color text;
  final Color textMuted;
  final VoidCallback onOpenDetail;
  final ValueChanged<bool?>? onCheckboxChanged;

  const _DailyTaskRow({
    required this.task,
    required this.isCompleted,
    required this.checkboxEnabled,
    required this.primary,
    required this.text,
    required this.textMuted,
    required this.onOpenDetail,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final duration = task.durationMinutes != null ? '${task.durationMinutes} min' : '';
    final timeLabel = task.frequency == 'daily' ? 'Daily' : (task.frequency);
    final meta = [duration, if (timeLabel != null) timeLabel].where((e) => e.isNotEmpty).join(' • ');
    final typeColor = _taskTypeColor(task.taskType);
    final typeLabel = _taskTypeLabel(task.taskType);

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Checkbox(
              value: isCompleted,
              onChanged: onCheckboxChanged,
              shape: const CircleBorder(),
              side: BorderSide(color: textMuted.withValues(alpha: 0.85)),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return textMuted.withValues(alpha: 0.15);
                }
                if (states.contains(WidgetState.selected)) return primary;
                return Colors.transparent;
              }),
              checkColor: Colors.black87,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onOpenDetail,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Type badge + meta row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            typeLabel,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (meta.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            meta,
                            style: GoogleFonts.inter(fontSize: 11, color: textMuted),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Title
                    Text(
                      task.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: text,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: textMuted,
                      ),
                    ),
                    // Description preview
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: textMuted, size: 28),
            onPressed: onOpenDetail,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String label;
  final String? completedDate;
  final bool isRequired;
  final bool isCompleted;
  final Color primary;
  final Color text;
  final Color textMuted;
  final VoidCallback? onTap;

  const _MilestoneCard({
    required this.title,
    required this.subtitle,
    required this.label,
    this.completedDate,
    this.isRequired = false,
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
          decoration: isCompleted
              ? BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isRequired ? primary.withValues(alpha: 0.55) : primary.withValues(alpha: 0.2),
                    width: isRequired ? 1.5 : 1,
                  ),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.ashramCardDark.withValues(alpha: 0.65),
                  border: Border.all(
                    color: isRequired
                        ? primary.withValues(alpha: 0.75)
                        : primary.withValues(alpha: 0.12),
                    width: isRequired ? 2 : 1,
                  ),
                  boxShadow: isRequired
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
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
              if (isCompleted) ...[
                const SizedBox(height: 12),
                if (completedDate != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12, color: primary),
                      const SizedBox(width: 4),
                      Text(completedDate!, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: primary)),
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
      decoration: JourneyAshramTheme.softStreakDecoration(),
      child: Center(
        child: Text(
          'No milestones yet',
          style: GoogleFonts.inter(fontSize: 14, color: textMuted),
        ),
      ),
    );
  }
}

// ─── Progress Banner ──────────────────────────────────────────────────────────

class _JourneyProgressBanner extends StatelessWidget {
  final UserJourney userJourney;
  final List<JourneyPhase> phases;
  final JourneyPhase? currentPhase;
  final int todaysDoneCount;
  final int todaysTotalCount;

  const _JourneyProgressBanner({
    required this.userJourney,
    required this.phases,
    required this.currentPhase,
    required this.todaysDoneCount,
    required this.todaysTotalCount,
  });

  @override
  Widget build(BuildContext context) {
    final pregnancyWeek = JourneyLogic.getCurrentPregnancyWeek(userJourney);
    final progress = JourneyLogic.journeyDayProgress(userJourney);

    // Context pill text — pregnancy-specific if week available, else generic day
    final String contextLabel;
    if (pregnancyWeek != null) {
      contextLabel = 'Week $pregnancyWeek';
    } else if (currentPhase?.durationLabel != null) {
      contextLabel = currentPhase!.durationLabel!;
    } else {
      contextLabel = 'Day ${progress.currentDay}';
    }

    final hasPhaseColor = currentPhase?.colorHex != null;
    Color phaseAccent = AppColors.primaryOrange;
    if (hasPhaseColor) {
      try {
        final hex = currentPhase!.colorHex!.replaceAll('#', '');
        phaseAccent = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    final allDone = todaysTotalCount > 0 && todaysDoneCount >= todaysTotalCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.ashramCardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: phaseAccent.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase name + context pill
            Row(
              children: [
                if (currentPhase?.icon != null) ...[
                  Text(currentPhase!.icon!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentPhase?.title ?? 'Your Journey',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.zinc100,
                        ),
                      ),
                      if (currentPhase?.titleHindi != null)
                        Text(
                          currentPhase!.titleHindi!,
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.zinc500),
                        ),
                    ],
                  ),
                ),
                // Context pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: phaseAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: phaseAccent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    contextLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: phaseAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Phase dot row
            _PhaseDotRow(
              phases: phases,
              currentPhase: currentPhase,
              phaseAccent: phaseAccent,
            ),
            const SizedBox(height: 14),
            // Today's completion ratio
            Row(
              children: [
                Icon(
                  allDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 16,
                  color: allDone ? Colors.greenAccent : AppColors.zinc500,
                ),
                const SizedBox(width: 6),
                Text(
                  todaysTotalCount == 0
                      ? 'No tasks today'
                      : allDone
                          ? 'All done today ✓'
                          : '$todaysDoneCount / $todaysTotalCount done today',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: allDone ? Colors.greenAccent : AppColors.zinc500,
                    fontWeight: allDone ? FontWeight.w600 : FontWeight.w400,
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

class _PhaseDotRow extends StatelessWidget {
  final List<JourneyPhase> phases;
  final JourneyPhase? currentPhase;
  final Color phaseAccent;

  const _PhaseDotRow({
    required this.phases,
    required this.currentPhase,
    required this.phaseAccent,
  });

  @override
  Widget build(BuildContext context) {
    if (phases.isEmpty) return const SizedBox.shrink();
    final currentOrder = currentPhase?.phaseOrder ?? 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: phases.asMap().entries.map((entry) {
          final phase = entry.value;
          final isCurrent = phase.id == currentPhase?.id;
          final isPast = phase.phaseOrder < currentOrder;

          Color dotColor;
          if (isPast) {
            dotColor = phaseAccent.withValues(alpha: 0.7);
          } else if (isCurrent) {
            dotColor = phaseAccent;
          } else {
            dotColor = AppColors.zinc500.withValues(alpha: 0.3);
          }

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Tooltip(
              message: phase.title,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Dynamic Wisdom Card ──────────────────────────────────────────────────────

class _DynamicWisdomCard extends ConsumerWidget {
  final String userJourneyId;

  const _DynamicWisdomCard({required this.userJourneyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wisdomAsync = ref.watch(wisdomForJourneyProvider(userJourneyId));

    return wisdomAsync.when(
      data: (row) {
        final title = row?['title'] as String? ?? 'Daily Wisdom';
        final content = row?['content'] as String?;
        if (content == null || content.isEmpty) return const SizedBox.shrink();
        return _WisdomCard(title: title, content: content);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _WisdomCard extends StatelessWidget {
  final String title;
  final String content;

  const _WisdomCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryOrange,
              AppColors.primaryOrange.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
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
    );
  }
}
