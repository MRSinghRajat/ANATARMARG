import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_clock.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../ashram/data/models/achievement_model.dart';
import '../../../ashram/data/models/daily_task_model.dart';
import '../../../ashram/data/models/user_spiritual_progress_model.dart';
import '../../../ashram/data/repositories/achievement_repository.dart';
import '../../../ashram/data/repositories/daily_task_repository.dart';
import '../../../ashram/data/repositories/spiritual_progress_repository.dart';
import '../../../ashram/presentation/widgets/streak_stats_card.dart';
import '../../../journey/data/models/journey_models.dart';
import '../../../journey/presentation/providers/journey_providers.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// My Growth - level, streak, practice stats, journeys, monthly overview, insights, daily task timeline.
/// Opened from profile streak card or Ashram header (name / Karma level).
class MyGrowthScreen extends ConsumerStatefulWidget {
  const MyGrowthScreen({super.key});

  @override
  ConsumerState<MyGrowthScreen> createState() => _MyGrowthScreenState();
}

class _MyGrowthScreenState extends ConsumerState<MyGrowthScreen> {
  final SpiritualProgressRepository _progressRepo = SpiritualProgressRepository();
  final DailyTaskRepository _taskRepo = DailyTaskRepository();
  final AchievementRepository _achievementRepo = AchievementRepository();

  UserSpiritualProgress? _progress;
  Map<DateTime, int> _heatmap = {};
  Map<DateTime, List<UserDailyTask>> _timelineHistory = {};
  int _totalJapa = 0;
  int _gratitudeCount = 0;
  bool _isPremium = false;
  bool _loading = true;
  List<UserAchievement> _recentAchievements = [];
  int _totalAchievements = 0;
  int _unlockedAchievements = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final progress = await _progressRepo.getProgress();
    final start = progress?.journeyStartDate ?? AppClock.now();
    final days = AppClock.now().difference(DateTime(start.year, start.month, start.day)).inDays.clamp(1, 365);
    final heatmap = await _taskRepo.getActivityHeatmap(28);
    final history = await _taskRepo.getTaskHistory(days);
    final japa = await _taskRepo.getTotalJapaCompletions();
    final gratitude = await _taskRepo.getGratitudeCompletionsCount();
    final isPremium = await PremiumService.instance.isPremium;
    final allAchievements = await _achievementRepo.getAllAchievements();
    final userAchievements = await _achievementRepo.getUserAchievements();
    final recentUnlocks = await _achievementRepo.getRecentUnlocks();
    if (mounted) {
      setState(() {
        _progress = progress;
        _heatmap = heatmap;
        _timelineHistory = history;
        _totalJapa = japa;
        _gratitudeCount = gratitude;
        _isPremium = isPremium;
        _totalAchievements = allAchievements.length;
        _unlockedAchievements = userAchievements.length;
        _recentAchievements = recentUnlocks.take(3).toList();
        _loading = false;
      });
    }
  }

  /// Same theme as StreakStatsCard: orange–purple gradient, white border, radius 20.
  BoxDecoration get _streakCardDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryOrange.withValues(alpha: 0.2),
            AppColors.deepPurple.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      );

  @override
  Widget build(BuildContext context) {
    const theme = AppColors.primaryOrange;
    const bg = AppColors.ashramBackgroundDark;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Growth',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            color: Colors.white70,
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
          : RefreshIndicator(
              onRefresh: _load,
              color: theme,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1) Same Streak Card as Profile
                    StreakStatsCard(progress: _progress),
                    const SizedBox(height: 24),
                    // 2) Streak days (Discipline Streak + heatmap)
                    _buildDisciplineStreak(theme),
                    const SizedBox(height: 24),
                    // 3) Meditation highlight
                    _buildMeditationCard(theme),
                    const SizedBox(height: 16),
                    // 4) Gratitude highlight
                    _buildGratitudeCard(theme),
                    const SizedBox(height: 24),
                    // 5) Level & XP
                    _buildLevelCard(theme),
                    const SizedBox(height: 24),
                    _buildPracticeStats(theme),
                    const SizedBox(height: 24),
                    _buildJourneys(theme),
                    const SizedBox(height: 24),
                    _buildThisMonth(theme),
                    const SizedBox(height: 24),
                    _buildGrowthInsights(theme),
                    const SizedBox(height: 24),
                    _buildAchievementsSection(theme),
                    const SizedBox(height: 24),
                    _buildDailyTaskTimeline(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLevelCard(Color theme) {
    final p = _progress;
    final level = p?.spiritualLevel ?? 1;
    final title = p?.spiritualTitle ?? 'Beginner';
    final xp = p?.experiencePoints ?? 0;
    final xpNeeded = p?.xpForNextLevel ?? 150;
    final xpInLevel = xp % xpNeeded;
    final remaining = xpNeeded - xpInLevel;
    final progress = (xpInLevel / xpNeeded).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _streakCardDecoration,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -24,
            right: -24,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.deepPurple.withValues(alpha: 0.15),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade400,
                          Colors.amber.shade200,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.black87, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GOLD BADGE',
                          style: GoogleFonts.poppins(
                            color: theme,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lv. $level - $title',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress to Level ${level + 1}',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$remaining XP remaining',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(theme),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '"Consistency builds mastery."',
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationCard(Color theme) {
    final mins = _progress?.totalMeditationMinutes ?? 0;
    final hours = mins ~/ 60;
    final m = mins % 60;
    final timeStr = hours > 0 ? '${hours}h ${m}m' : '$mins min';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _streakCardDecoration,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(Icons.self_improvement_rounded, color: theme, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meditation',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total practice time',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGratitudeCard(Color theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _streakCardDecoration,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.deepPurple.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(Icons.volunteer_activism_rounded, color: theme, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gratitude & Reflections',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_gratitudeCount sessions',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Journal & reflection practices',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplineStreak(Color theme) {
    final p = _progress;
    final current = p?.currentStreak ?? 0;
    final longest = p?.longestStreak ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STREAK DAYS',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            if (_isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Text(
                  'PREMIUM',
                  style: GoogleFonts.poppins(
                    color: theme,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _streakCardDecoration,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: theme, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '$current Days',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LONGEST STREAK',
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$longest Days',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildHeatmap(theme),
              if (!_isPremium) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => PaywallScreen.showAsBottomSheet(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: theme.withValues(alpha: 0.8)),
                      const SizedBox(width: 6),
                      Text(
                        'Upgrade for full activity history',
                        style: GoogleFonts.poppins(
                          color: theme.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmap(Color theme) {
    final now = AppClock.now();
    final cells = <Widget>[];
    for (int i = 27; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = DateTime(d.year, d.month, d.day);
      final count = _heatmap[key] ?? 0;
      double intensity = 0;
      if (count > 0) {
        if (count >= 5) {
          intensity = 1.0;
        } else if (count >= 3) {
          intensity = 0.8;
        } else if (count >= 2) {
          intensity = 0.6;
        } else {
          intensity = 0.4;
        }
      }
      cells.add(
        Container(
          decoration: BoxDecoration(
            color: intensity > 0
                ? AppColors.primaryOrange.withValues(alpha: 0.3 + intensity * 0.6)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
      );
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 1,
      children: cells,
    );
  }

  Widget _buildPracticeStats(Color theme) {
    final p = _progress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRACTICE STATS',
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: [
            _statCard('Verses Read', '${p?.totalVersesRead ?? 0}', theme),
            _statCard('Meditation Min', '${p?.totalMeditationMinutes ?? 0}', theme),
            _statCard('Total Japa', '$_totalJapa', theme),
            _statCard('Acts of Seva', '${p?.totalSevaActs ?? 0}', theme),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _streakCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneys(Color theme) {
    final journeysAsync = ref.watch(allUserJourneysProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JOURNEYS',
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        journeysAsync.when(
          data: (journeys) {
            if (journeys.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: _streakCardDecoration,
                child: Center(
                  child: Text(
                    'No journeys yet',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
                  ),
                ),
              );
            }
            final typesAsync = ref.watch(journeyTypesProvider);
            return typesAsync.when(
              data: (types) {
                JourneyType? typeFor(UserJourney j) {
                  try {
                    return types.firstWhere((t) => t.id == j.journeyTypeId);
                  } catch (_) {
                    return null;
                  }
                }
                return Column(
                  children: journeys.take(5).map((j) {
                    final type = typeFor(j);
                    final isActive = j.isActive;
                    int day = 0;
                    int total = 90;
                    if (j.startDate != null && j.targetDate != null) {
                      final start = j.startDate!;
                      final end = j.targetDate!;
                      total = end.difference(start).inDays.clamp(1, 365);
                      day = AppClock.now().difference(start).inDays.clamp(0, total);
                    } else if (j.metadata.containsKey('due_date')) {
                      final due = DateTime.tryParse(j.metadata['due_date'] as String? ?? '');
                      if (due != null) {
                        final start = due.subtract(const Duration(days: 280));
                        day = DateTime.now().difference(start).inDays.clamp(0, 280);
                        total = 280;
                      }
                    }
                    final progress = total > 0 ? (day / total).clamp(0.0, 1.0) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: _streakCardDecoration,
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? theme.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Icon(
                                isActive ? Icons.psychology_rounded : Icons.child_care_rounded,
                                color: isActive ? theme : Colors.white38,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          type?.title ?? 'Journey',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (isActive)
                                        Text(
                                          '${(progress * 100).round()}%',
                                          style: GoogleFonts.poppins(
                                            color: theme,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      else
                                        const Icon(Icons.verified_rounded, color: Colors.amber, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isActive ? theme : Colors.white38,
                                      ),
                                      minHeight: 4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isActive ? 'Day $day of $total' : 'Completed Journey',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white38,
                                      fontSize: 10,
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
                  }).toList(),
                );
              },
              loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(color: AppColors.ashramSaffron))),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
          loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(color: AppColors.ashramSaffron))),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildThisMonth(Color theme) {
    final now = AppClock.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int daysActive = 0;
    int minsTotal = 0;
    final weekCounts = <int>[0, 0, 0, 0];
    for (final entry in _timelineHistory.entries) {
      if (entry.key.isBefore(startOfMonth)) continue;
      if (entry.key.isAfter(now)) continue;
      final completed = entry.value.where((t) => t.isCompleted).length;
      if (completed > 0) daysActive++;
      for (final t in entry.value.where((t) => t.isCompleted)) {
        minsTotal += t.estimatedMinutes;
      }
      final weekIndex = (entry.key.difference(startOfMonth).inDays / 7).floor().clamp(0, 3);
      weekCounts[weekIndex] = (weekCounts[weekIndex] + completed).clamp(0, 20);
    }
    final maxWeek = weekCounts.isEmpty ? 1 : weekCounts.reduce((a, b) => a > b ? a : b).clamp(1, 20);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THIS MONTH',
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: _streakCardDecoration,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$daysActive/$daysInMonth',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'DAYS ACTIVE',
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$minsTotal',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'MINS TOTAL',
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(4, (i) {
                    final h = maxWeek > 0 ? (weekCounts[i] / maxWeek).clamp(0.15, 1.0) : 0.15;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: weekCounts[i] > 0
                                ? AppColors.primaryOrange.withValues(alpha: 0.35 + h * 0.55)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          height: 80 * h,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['WK 1', 'WK 2', 'WK 3', 'WK 4']
                    .map((l) => Text(
                          l,
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthInsights(Color theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'GROWTH INSIGHTS',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'AI POWERED',
                style: GoogleFonts.poppins(
                  color: Colors.amber.shade200,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _streakCardDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.trending_up_rounded, color: theme, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meditation up 4x',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your focus window has significantly deepened compared to last week.',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _streakCardDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.schedule_rounded, color: theme, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Best practiced before 9 AM',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Data shows your streak stays consistent when you complete your Japa early.',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!_isPremium) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => PaywallScreen.showAsBottomSheet(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: _streakCardDecoration,
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: theme, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Unlock more AI-powered insights with Premium',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: theme),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAchievementsSection(Color theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACHIEVEMENTS',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                '$_unlockedAchievements / $_totalAchievements',
                style: GoogleFonts.poppins(
                  color: theme,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _streakCardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _totalAchievements > 0
                      ? (_unlockedAchievements / _totalAchievements).clamp(0.0, 1.0)
                      : 0,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(theme),
                  minHeight: 6,
                ),
              ),
              if (_recentAchievements.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Recent Unlocks',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentAchievements.map((ua) {
                    final badgeColor = _getBadgeColor(ua.achievement?.badgeColor);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getAchievementIcon(ua.achievement?.iconName),
                            color: badgeColor,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ua.achievement?.title ?? 'Achievement',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getBadgeColor(BadgeColor? badgeColor) {
    switch (badgeColor) {
      case BadgeColor.bronze:
        return const Color(0xFFCD7F32);
      case BadgeColor.silver:
        return Colors.grey.shade400;
      case BadgeColor.gold:
        return Colors.amber;
      case BadgeColor.purple:
        return Colors.purpleAccent;
      case BadgeColor.diamond:
        return Colors.cyanAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getAchievementIcon(String? iconName) {
    switch (iconName) {
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'check_circle':
        return Icons.check_circle;
      case 'menu_book':
        return Icons.menu_book;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'star':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }

  Widget _buildDailyTaskTimeline(Color theme) {
    if (_timelineHistory.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAILY TASK TIMELINE',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _streakCardDecoration,
            child: Center(
              child: Text(
                'No task history yet. Complete tasks to see your timeline.',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    final dates = _timelineHistory.keys.toList()..sort((a, b) => b.compareTo(a));
    final limit = _isPremium ? 14 : 7;
    final recentDates = dates.take(limit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DAILY TASK TIMELINE',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            if (!_isPremium && dates.length > 7)
              GestureDetector(
                onTap: () => PaywallScreen.showAsBottomSheet(context),
                child: Text(
                  'See full history',
                  style: GoogleFonts.poppins(
                    color: theme,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'What you chose and completed each day.',
          style: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        ...recentDates.map((date) {
          final tasks = _timelineHistory[date]!
              .where((t) => t.isCompleted)
              .toList();
          if (tasks.isEmpty) return const SizedBox.shrink();
          final now = AppClock.now();
          final today = DateTime(now.year, now.month, now.day);
          final dateOnly = DateTime(date.year, date.month, date.day);
          String dateLabel;
          if (dateOnly == today) {
            dateLabel = 'Today';
          } else if (dateOnly == today.subtract(const Duration(days: 1))) {
            dateLabel = 'Yesterday';
          } else {
            dateLabel = '${date.day}/${date.month}/${date.year}';
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: _streakCardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: theme, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        dateLabel,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...tasks.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: theme.withValues(alpha: 0.9),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t.title,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (t.coinsEarned > 0)
                              Text(
                                '+${t.coinsEarned}',
                                style: GoogleFonts.poppins(
                                  color: theme,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
