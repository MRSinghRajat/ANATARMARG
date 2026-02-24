import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/utils/app_clock.dart';
import '../../../profile/presentation/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/widgets/flying_coins_animation.dart';
import '../../../gamification/data/repositories/avatar_repository.dart';
import '../../../sanctuary/data/models/sanctuary_customization_model.dart';
import '../../../sanctuary/data/services/sanctuary_customization_service.dart';
import '../../../sanctuary/presentation/widgets/customizable_om_sanctuary.dart';
import '../../data/models/daily_task_model.dart';
import '../../data/models/custom_habit_model.dart';
import '../../data/models/user_spiritual_progress_model.dart';
import '../../data/models/achievement_model.dart';
import '../../data/services/daily_task_service.dart';
import '../../data/services/custom_habit_service.dart';
import '../../data/repositories/ashram_daily_verse_repository.dart';
import '../widgets/daily_task_card.dart';
import '../widgets/custom_habit_card.dart';
import '../widgets/add_habit_sheet.dart';
import '../widgets/achievement_unlock_dialog.dart';
import '../../../books/data/datasources/supabase_granthalaya_datasource.dart';
import '../../../books/data/models/daily_story_model.dart';
import '../../../books/presentation/screens/story_reader_screen.dart';
import 'ashram_verse_detail_screen.dart';
import 'meditation_guide_screen.dart';
import 'gratitude_practice_screen.dart';
import 'seva_help_screen.dart';
import 'dana_practice_screen.dart';
import 'chant_player_screen.dart';
import 'japa_counter_screen.dart';
import 'manifestation_practice_screen.dart';
import 'habit_detail_screen.dart';
import '../../../garbh_sanskar/presentation/widgets/garbh_sanskar_entry_card.dart';

class AshramScreen extends ConsumerStatefulWidget {
  const AshramScreen({super.key});

  @override
  ConsumerState<AshramScreen> createState() => _AshramScreenState();
}

class _AshramScreenState extends ConsumerState<AshramScreen>
    with WidgetsBindingObserver {
  final CoinService _coinService = CoinService();
  final AvatarRepository _avatarRepository = AvatarRepository();
  final SanctuaryCustomizationService _customizationService =
      SanctuaryCustomizationService();
  final AshramDailyVerseRepository _verseRepository =
      AshramDailyVerseRepository();
  final DailyTaskService _taskService = DailyTaskService.instance;
  final CustomHabitService _habitService = CustomHabitService.instance;

  // State
  bool _isLoading = true;
  SanctuaryCustomization? _currentCustomization;
  StreamSubscription<SanctuaryCustomization>? _customizationSubscription;
  bool _customizationLoaded = false;
  // Task system state
  List<UserDailyTask> _tasks = [];
  List<CustomHabit> _habits = [];
  UserSpiritualProgress? _progress;
  StreamSubscription<List<UserDailyTask>>? _tasksSubscription;
  StreamSubscription<UserSpiritualProgress?>? _progressSubscription;
  StreamSubscription<Achievement>? _achievementSubscription;
  StreamSubscription<List<CustomHabit>>? _habitsSubscription;

  // GlobalKeys for animations
  final GlobalKey _coinCounterKey = GlobalKey();
  final Map<String, GlobalKey> _taskKeys = {};
  final Map<String, GlobalKey> _habitKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _coinService.initialize();
    _initializeCustomization();
    _initializeTaskSystem();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _customizationSubscription?.cancel();
    _tasksSubscription?.cancel();
    _progressSubscription?.cancel();
    _achievementSubscription?.cancel();
    _habitsSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCustomization();
      _taskService.refresh();
      _habitService.refresh();
    }
  }

  Future<void> _initializeCustomization() async {
    await _customizationSubscription?.cancel();

    _customizationSubscription =
        _customizationService.customizationStream.listen((customization) {
      if (mounted) {
        setState(() {
          _currentCustomization = customization;
          _customizationLoaded = true;
        });
      }
    });

    await _customizationService.ensureInitialized();

    if (mounted) {
      setState(() {
        _currentCustomization = _customizationService.currentCustomization;
        _customizationLoaded = true;
      });
    }
  }

  Future<void> _initializeTaskSystem() async {
    // Subscribe to streams
    _tasksSubscription = _taskService.tasksStream.listen((tasks) {
      if (mounted) setState(() => _tasks = tasks);
    });

    _progressSubscription = _taskService.progressStream.listen((progress) {
      if (mounted) setState(() => _progress = progress);
    });

    _achievementSubscription =
        _taskService.achievementUnlockedStream.listen((achievement) {
      if (mounted) {
        AchievementUnlockDialog.show(context, achievement);
      }
    });

    _habitsSubscription = _habitService.habitsStream.listen((habits) {
      if (mounted) setState(() => _habits = habits);
    });

    // Initialize services
    await Future.wait([
      _taskService.initialize(),
      _habitService.initialize(),
    ]);

    // Update state with current data
    if (mounted) {
      setState(() {
        _tasks = _taskService.currentTasks;
        _progress = _taskService.currentProgress;
        _habits = _habitService.habits;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshCustomization() async {
    await _customizationService.refresh();
    if (mounted) {
      setState(() {
        _currentCustomization = _customizationService.currentCustomization;
      });
    }
  }

  Future<void> _onTaskTap(UserDailyTask task) async {
    final wasCompleted = task.isCompleted;
    final taskKey = _taskKeys[task.id];

    final result = await _taskService.toggleTask(task);

    // Fire-and-forget: don't await the coin animation
    if (mounted && result.success && result.coinsEarned > 0 && !wasCompleted) {
      if (taskKey != null) {
        FlyingCoinsAnimation.show(
          context,
          amount: result.coinsEarned,
          fromKey: taskKey,
          toKey: _coinCounterKey,
        );
      }
    }
  }

  /// Slugs that have a dedicated screen to navigate to
  static const _navigableSlugs = {
    'daily_verse',
    'daily_story',
    'daily_meditation',
    'morning_meditation',
    'pranayama',
    'gratitude_journal',
    'gratitude_practice',
    'help_someone',
    'donate',
    'listen_chant',
    'japa_108',
    'manifestation',
  };

  bool _hasScreen(UserDailyTask task) =>
      _navigableSlugs.contains(task.slug);

  Future<void> _navigateToTaskScreen(UserDailyTask task) async {
    Widget? screen;
    final slug = task.slug;

    switch (slug) {
      case 'daily_verse':
        final verse = await _verseRepository.getTodaysVerseForDisplay();
        if (verse == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.get('no_verse_available', ref.read(languageProvider)))),
          );
          return;
        }
        screen = AshramVerseDetailScreen(verse: verse!);
        break;

      case 'daily_story':
        try {
          final ds = SupabaseGranthalayaDataSource();
          final stories = await ds.getSacredStories();
          if (stories.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.get('no_stories_available', ref.read(languageProvider)))),
              );
            }
            return;
          }
          final dayOfYear = AppClock.now().difference(DateTime(AppClock.now().year)).inDays + 1;
          final sacred = stories[dayOfYear % stories.length];
          final story = DailyStoryModel(
            id: sacred.id,
            dayOfYear: dayOfYear,
            storyTitle: sacred.title,
            source: sacred.source,
            category: sacred.category,
            estimatedMinutes: sacred.estimatedMinutes,
            totalPages: sacred.pages.length,
            pages: sacred.pages.asMap().entries.map((e) => StoryPage(
              pageNumber: e.key,
              textEnglish: e.value.textEnglish,
              textHindi: e.value.textHindi,
              illustrationUrl: e.value.illustrationUrl,
              isFinal: e.value.isFinal,
            )).toList(),
            keyTeaching: sacred.keyTeaching,
            reflectionPrompt: sacred.reflectionPrompt,
            coverImageUrl: sacred.coverImageUrl,
          );
          screen = StoryReaderScreen(story: story);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load story: $e')),
            );
          }
          return;
        }
        break;

      case 'daily_meditation':
      case 'morning_meditation':
      case 'pranayama':
        screen = MeditationGuideScreen(
          slug: slug,
          onComplete: () => _onTaskTap(task),
        );
        break;

      case 'gratitude_journal':
      case 'gratitude_practice':
        screen = GratitudePracticeScreen(
          onComplete: () => _onTaskTap(task),
        );
        break;

      case 'help_someone':
        screen = SevaHelpScreen(
          onComplete: () => _onTaskTap(task),
        );
        break;

      case 'donate':
        screen = DanaPracticeScreen(
          onComplete: () => _onTaskTap(task),
        );
        break;

      case 'listen_chant':
        screen = ChantPlayerScreen(
          onComplete: () => _onTaskTap(task),
        );
        break;

      case 'japa_108':
        screen = JapaCounterScreen(
          onComplete: () => _onTaskTap(task),
        );
        break;

      case 'manifestation':
        screen = ManifestationPracticeScreen(
          onComplete: () => _onTaskTap(task),
        );
        break;

      default:
        // No dedicated screen - just toggle
        _onTaskTap(task);
        return;
    }

    if (mounted) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => screen!),
      );
      // If screen returned true (completed), and task isn't already complete,
      // auto-complete it
      if (result == true && !task.isCompleted) {
        await _onTaskTap(task);
      }
    }
  }

  Future<void> _onHabitTap(CustomHabit habit) async {
    // Only animate if habit is being completed (not uncompleted)
    final wasCompleted = habit.isCompletedToday;
    final habitKey = _habitKeys[habit.id];

    final result = await _habitService.toggleHabit(habit);

    if (mounted && result.success && result.coinsEarned > 0 && !wasCompleted) {
      // Show flying coins animation
      if (habitKey != null) {
        await FlyingCoinsAnimation.show(
          context,
          amount: result.coinsEarned,
          fromKey: habitKey,
          toKey: _coinCounterKey,
        );
      }
    }
  }

  /// Get or create a GlobalKey for a task
  GlobalKey _getTaskKey(String taskId) {
    return _taskKeys.putIfAbsent(taskId, () => GlobalKey());
  }

  /// Get or create a GlobalKey for a habit
  GlobalKey _getHabitKey(String habitId) {
    return _habitKeys.putIfAbsent(habitId, () => GlobalKey());
  }

  void _showAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitSheet(
        onHabitAdded: () {
          _habitService.refresh();
        },
      ),
    );
  }

  // Getters for task organization
  List<UserDailyTask> get _pendingTasks =>
      _tasks.where((t) => t.isPending).toList();
  List<UserDailyTask> get _completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();
  List<CustomHabit> get _todaysHabits =>
      _habits.where((h) => h.isScheduledForToday).toList();
  List<CustomHabit> get _pendingHabits => _todaysHabits
      .where((h) => !_habitService.isCompletedToday(h.id))
      .toList();
  List<CustomHabit> get _completedHabits =>
      _todaysHabits.where((h) => _habitService.isCompletedToday(h.id)).toList();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topHeight = screenHeight * 0.50; // Reduced to 50% for more task space

    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          fit: StackFit.expand,
          children: [
            // Geometry overlay
            const Positioned.fill(child: _GeometryOverlay()),

            // Layer 1: OM section (top 50%)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ClipRect(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildPremiumHeader(context),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Center(
                              child: _customizationLoaded &&
                                      _currentCustomization != null
                                  ? CustomizableOmSanctuary(
                                      size: 260,
                                      customization: _currentCustomization!,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Layer 2: Draggable task sheet
            Positioned.fill(
              child: DraggableScrollableSheet(
                initialChildSize: 0.40,
                minChildSize: 0.35,
                maxChildSize: 0.95,
                snap: true,
                snapSizes: const [0.35, 0.50, 0.70, 0.95],
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.ashramBackgroundDark,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildTaskContent(scrollController),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitSheet,
        backgroundColor: AppColors.primaryOrange,
        elevation: 8,
        highlightElevation: 12,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTaskContent(ScrollController scrollController) {
    return CustomScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // Handle bar
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Debug date picker (only in debug builds)
        if (kDebugMode)
          SliverToBoxAdapter(
            child: _buildDebugDateBanner(),
          ),

        // Loading indicator
        if (_isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            ),
          )
        else ...[
          // Garbh Sanskar entry card
          const SliverToBoxAdapter(
            child: GarbhSanskarEntryCard(),
          ),

          // Section: Today's Tasks
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Builder(builder: (context) {
                final lang = ref.watch(languageProvider);
                return _buildSectionHeader(
                  title: AppStrings.get('todays_tasks', lang),
                  subtitle:
                      '${_completedTasks.length}/${_tasks.length} ${AppStrings.get('completed', lang)}',
                  icon: Icons.check_circle_outline,
                );
              }),
            ),
          ),

          // Pending Tasks
          if (_pendingTasks.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = _pendingTasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DailyTaskCard(
                        task: task,
                        onTap: () => _onTaskTap(task),
                        onNavigate: _hasScreen(task)
                            ? () => _navigateToTaskScreen(task)
                            : null,
                        rewardsKey: _getTaskKey(task.id),
                      ),
                    );
                  },
                  childCount: _pendingTasks.length,
                ),
              ),
            ),

          // No pending tasks message
          if (_pendingTasks.isEmpty && _tasks.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.15),
                        Colors.green.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration,
                          color: Colors.green, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(builder: (context) {
                              final lang = ref.watch(languageProvider);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.get('all_tasks_complete', lang),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.get('all_tasks_complete_sub', lang),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Section: Custom Habits
          if (_todaysHabits.isNotEmpty || _habits.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Builder(builder: (context) {
                  final lang = ref.watch(languageProvider);
                  return _buildSectionHeader(
                    title: AppStrings.get('my_habits', lang),
                    subtitle:
                        '${_completedHabits.length}/${_todaysHabits.length} ${AppStrings.get('today', lang)}',
                    icon: Icons.repeat,
                    action: TextButton(
                      onPressed: _showAddHabitSheet,
                      child: Text(
                        AppStrings.get('add', lang),
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Pending Habits
          if (_pendingHabits.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = _pendingHabits[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CustomHabitCard(
                        habit: habit,
                        isCompleted: _habitService.isCompletedToday(habit.id),
                        onTap: () => _onHabitTap(habit),
                        onNavigate: () => _navigateToHabitDetail(habit),
                        onLongPress: () => _showHabitOptions(habit),
                        animationKey: _getHabitKey(habit.id),
                      ),
                    );
                  },
                  childCount: _pendingHabits.length,
                ),
              ),
            ),

          // Section: Completed Today
          if (_completedTasks.isNotEmpty || _completedHabits.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Builder(builder: (context) {
                  final lang = ref.watch(languageProvider);
                  return _buildSectionHeader(
                    title: AppStrings.get('completed_today', lang),
                    subtitle:
                        '${_completedTasks.length + _completedHabits.length} ${AppStrings.get('items', lang)}',
                    icon: Icons.done_all,
                  );
                }),
              ),
            ),

          // Completed Tasks
          if (_completedTasks.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = _completedTasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CompletedTaskTile(
                        task: task,
                        onTap: () => _onTaskTap(task),
                      ),
                    );
                  },
                  childCount: _completedTasks.length,
                ),
              ),
            ),

          // Completed Habits
          if (_completedHabits.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = _completedHabits[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CompletedHabitTile(
                        habit: habit,
                        onTap: () => _navigateToHabitDetail(habit),
                      ),
                    );
                  },
                  childCount: _completedHabits.length,
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? action,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryOrange, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  // ─── Debug Date Picker (kDebugMode only) ───

  Widget _buildDebugDateBanner() {
    final isOverridden = AppClock.isOverridden;
    final displayDate = AppClock.now();
    final dateLabel =
        '${displayDate.year}-${displayDate.month.toString().padLeft(2, '0')}-${displayDate.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: GestureDetector(
        onTap: () => _showDebugDatePicker(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isOverridden
                ? Colors.orange.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverridden
                  ? Colors.orange.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bug_report_rounded,
                size: 18,
                color: isOverridden ? Colors.orange : Colors.grey.shade500,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOverridden ? 'DEBUG: Date Override Active' : 'DEBUG: Tap to change date',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isOverridden ? Colors.orange : Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      'Current: $dateLabel${isOverridden ? "  (simulated)" : "  (real)"}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOverridden)
                GestureDetector(
                  onTap: () => _onDebugDateChanged(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Reset',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade300,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDebugDatePicker() async {
    final now = AppClock.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      helpText: 'Pick a date to simulate',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1A1A2E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _onDebugDateChanged(picked);
    }
  }

  void _onDebugDateChanged(DateTime? date) {
    AppClock.setDebugDate(date);
    // Re-initialize everything for the new "day"
    setState(() {
      _isLoading = true;
      _tasks = [];
    });
    _taskService.refresh();
    _habitService.refresh();
    // Small delay to let streams update
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return FutureBuilder(
      future: _avatarRepository.getAvatar(),
      builder: (context, avatarSnapshot) {
        return StreamBuilder<int>(
          stream: _coinService.coinStream,
          initialData: _coinService.currentBalance,
          builder: (context, coinSnapshot) {
            final coins = coinSnapshot.data ?? 0;
            final level = _progress?.spiritualLevel ?? 1;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile Avatar with level
                Row(
                  children: [
                    const _PremiumProfileAvatar(),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level $level',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _progress?.spiritualTitle ?? 'Beginner',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryOrange,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Stats Row (coins only; streak is shown on Self/Profile tab)
                KeyedSubtree(
                  key: _coinCounterKey,
                  child: _buildPremiumStatBubble(
                      '$coins', Icons.monetization_on, Colors.amber),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPremiumStatBubble(String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2837).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToHabitDetail(CustomHabit habit) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HabitDetailScreen(habit: habit),
      ),
    );
    // Refresh if habit was deleted or edited
    if (result == true) {
      _habitService.refresh();
    }
  }

  void _showHabitOptions(CustomHabit habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              habit.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white70),
              title: Text(
                'Edit Habit',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddHabitSheet(
                    editingHabit: habit,
                    onHabitAdded: () => _habitService.refresh(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Habit',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.cardDark,
                    title: Text(
                      'Delete Habit?',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    content: Text(
                      'This will remove "${habit.title}" from your habits.',
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _habitService.deleteHabit(habit.id);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Geometry overlay with diagonal lines
class _GeometryOverlay extends StatelessWidget {
  const _GeometryOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GeometryPainter(opacity: 0.03),
    );
  }
}

class _GeometryPainter extends CustomPainter {
  final double opacity;

  _GeometryPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(opacity)
      ..strokeWidth = 1;

    const spacing = 80.0;
    for (var i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
    for (var i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i.toDouble(), size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GeometryPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

/// Premium profile avatar with shimmer effect
class _PremiumProfileAvatar extends StatefulWidget {
  const _PremiumProfileAvatar();

  @override
  State<_PremiumProfileAvatar> createState() => _PremiumProfileAvatarState();
}

class _PremiumProfileAvatarState extends State<_PremiumProfileAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, _) {
            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD4AF37), Color(0xFFF4E4B6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Transform.rotate(
                      angle: _shimmerController.value * 2 * math.pi,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: [
                              0.0,
                              _shimmerController.value % 1.0,
                              (_shimmerController.value % 1.0) + 0.2,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0B1623),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
