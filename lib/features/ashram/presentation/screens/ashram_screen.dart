import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/utils/app_clock.dart';
import '../../../profile/presentation/providers/language_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/widgets/flying_coins_animation.dart';
import '../../data/models/daily_task_model.dart';
import '../../data/models/custom_habit_model.dart';
import '../../data/models/user_spiritual_progress_model.dart';
import '../../data/models/achievement_model.dart';
import '../../data/services/daily_task_service.dart';
import '../../data/services/custom_habit_service.dart';
import '../../data/repositories/ashram_daily_verse_repository.dart';
import '../widgets/add_habit_sheet.dart';
import '../widgets/achievement_unlock_dialog.dart';
import '../../../books/data/datasources/supabase_granthalaya_datasource.dart';
import '../../../books/data/models/daily_story_model.dart';
import '../../../books/presentation/screens/story_reader_screen.dart';
import 'ashram_verse_detail_screen.dart';
import 'gratitude_practice_screen.dart';
import 'seva_help_screen.dart';
import 'dana_practice_screen.dart';
import 'chant_player_screen.dart';
import 'evening_aarti_screen.dart';
import 'japa_counter_screen.dart';
import 'manifestation_practice_screen.dart';
import 'habit_detail_screen.dart';
import '../../data/panchang/panchang_engine.dart';
import '../panchang/widgets/panchang_detail_sheet.dart';
import '../panchang/widgets/panchang_month_sheet.dart';
import '../../../journey/data/journey_logic.dart';
import '../../../journey/data/models/journey_models.dart';
import '../../../journey/presentation/providers/journey_providers.dart';
import '../../../onboarding/presentation/screens/spiritual_onboarding_screen.dart';
import '../../../profile/data/repositories/app_profile_repository.dart';
import '../../../home/data/services/aangan_notification_service.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/services/app_notification_service.dart';
import '../../../../core/services/notification_preferences.dart';
import '../../../../core/utils/profile_pro_upgrade_nav.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../shared/widgets/pro_gradient_badge.dart';

/// Set to true to show the debug "Tap to change date" banner (e.g. for testing).
const bool kShowDebugDateBanner = true;

class AshramScreen extends ConsumerStatefulWidget {
  const AshramScreen({super.key});

  @override
  ConsumerState<AshramScreen> createState() => _AshramScreenState();
}

class _AshramScreenState extends ConsumerState<AshramScreen> with WidgetsBindingObserver {
  final CoinService _coinService = CoinService();
  final AshramDailyVerseRepository _verseRepository =
      AshramDailyVerseRepository();
  final DailyTaskService _taskService = DailyTaskService.instance;
  final CustomHabitService _habitService = CustomHabitService.instance;

  // State
  bool _isLoading = true;
  bool _isPremium = false;
  StreamSubscription<bool>? _premiumSubscription;
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
  bool _practiceToolsExpanded = false;
  bool _todayPathExpanded = false;
  bool _activeJourneyExpanded = false;
  bool _myHabitsExpanded = false;
  int _lastKnownLevel = 1;
  /// Cancels auto-close if the level-up overlay is dismissed early (avoids a stray [pop] breaking the route stack).
  Timer? _levelUpOverlayAutoClose;
  final AppProfileRepository _appProfileRepo = AppProfileRepository();
  late final Future<({String displayName, String? avatarUrl})> _profileFuture;

  Future<({String displayName, String? avatarUrl})> _loadProfileForHeader() async {
    final onb = await SpiritualOnboardingScreen.getStoredUserName();
    final name = await _appProfileRepo.getDisplayNameWithFallback(onboardingName: onb);
    final avatar = await _appProfileRepo.getAvatarUrlWithFallback();
    return (displayName: name ?? onb ?? 'Sadhak', avatarUrl: avatar);
  }

  BoxDecoration get _streakStyleDecoration => BoxDecoration(
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
  void initState() {
    super.initState();
    _profileFuture = _loadProfileForHeader();
    WidgetsBinding.instance.addObserver(this);
    _coinService.initialize();
    FlyingCoinsAnimation.coinCounterKey = _coinCounterKey;
    _initializeTaskSystem();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotification());
    PremiumService.instance.isPremium.then((v) {
      if (mounted) setState(() => _isPremium = v);
    });
    _premiumSubscription = PremiumService.instance.premiumStatusStream.listen((v) {
      if (mounted) {
        setState(() {
          _isPremium = v;
          if (!v) {
            _activeJourneyExpanded = false;
            _myHabitsExpanded = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _levelUpOverlayAutoClose?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _premiumSubscription?.cancel();
    _tasksSubscription?.cancel();
    _progressSubscription?.cancel();
    _achievementSubscription?.cancel();
    _habitsSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _taskService.refresh();
      _habitService.refresh();
    }
  }

  Future<void> _initializeTaskSystem() async {
    // Subscribe to streams
    _tasksSubscription = _taskService.tasksStream.listen((tasks) {
      if (mounted) setState(() => _tasks = tasks);
    });

    _progressSubscription = _taskService.progressStream.listen((progress) {
      if (mounted) {
        // Snapshot *before* setState — after setState, _progress is already the new value, so
        // `_progress != null` would be true on first load and wrongly fire level-up.
        final hadPriorProgress = _progress != null;
        final previousLevel = _progress?.spiritualLevel ?? _lastKnownLevel;
        setState(() => _progress = progress);
        if (progress != null && progress.spiritualLevel >= 1 && _coinService.currentBalance == 0) {
          _coinService.ensureMinimumKarmaForLevel(progress.spiritualLevel);
        }
        if (progress != null &&
            hadPriorProgress &&
            progress.spiritualLevel > previousLevel) {
          _lastKnownLevel = progress.spiritualLevel;
          WidgetsBinding.instance.addPostFrameCallback((_) => _showLevelUpAnimation(progress.spiritualLevel));
        } else if (progress != null) {
          _lastKnownLevel = progress.spiritualLevel;
        }
      }
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

    try {
      await Future.wait([
        _taskService.initialize(),
        _habitService.initialize(),
      ]).timeout(const Duration(seconds: 8));
    } catch (_) {
      // Offline / timeout — still show whatever local data the services have.
    }

    if (mounted) {
      setState(() {
        _tasks = _taskService.currentTasks;
        _progress = _taskService.currentProgress;
        _habits = _habitService.habits;
        _isLoading = false;
      });
    }
  }

  /// Pushes Ashram/Aangan notifications into the bell list so they appear on the Notifications page.
  Future<void> _loadNotification() async {
    try {
      final service = AanganNotificationService();
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
        service.userRegion = locale.countryCode;
      }
      final items = await service.getNotificationsForList();
      final appNotif = AppNotificationService.instance;
      if (!await NotificationPreferences.shouldDeliver(
        NotificationPreferences.keyUpdates,
      )) {
        return;
      }
      for (final item in items) {
        await appNotif.addNotification(
          title: item.emojiOrIcon != null ? '${item.emojiOrIcon} ${item.title}' : item.title,
          body: item.subtitle ?? '',
          type: 'aangan',
          customId: 'aangan_${item.id}',
        );
      }
    } catch (_) {
      // Optional: add a fallback notification for testing
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
    'evening_aarti',
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
              pageNumber: e.value.pageNumber,
              textEnglish: e.value.textEnglish,
              textHindi: e.value.textHindi,
              illustrationUrl: e.value.imageUrl,
              isFinal: e.value.isFinal(sacred.pages.length),
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
        screen = JapaCounterScreen(
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
        final isPremium = await PremiumService.instance.isPremium;
        if (!isPremium) {
          if (mounted) navigateToProfileForProUpgrade(context);
          return;
        }
        screen = ManifestationPracticeScreen(
          onComplete: () => _onTaskTap(task),
        );
        break;

      case 'evening_aarti':
        screen = const EveningAartiScreen();
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

  void _showLevelUpAnimation(int newLevel) {
    if (!mounted) return;
    _levelUpOverlayAutoClose?.cancel();
    final title = _progress?.spiritualTitle ?? 'Beginner';
    final navigator = Navigator.of(context);
    final closed = showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, animation, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: AppColors.ashramBackgroundDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Level Up!',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Lv. $newLevel',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    // If the user dismisses the overlay early, cancel this — otherwise a second [pop] peels the wrong route
    // and the next [pushNamed] can show "No route defined" or land on a broken stack.
    closed.whenComplete(() {
      _levelUpOverlayAutoClose?.cancel();
      _levelUpOverlayAutoClose = null;
    });
    _levelUpOverlayAutoClose = Timer(const Duration(milliseconds: 1800), () {
      _levelUpOverlayAutoClose = null;
      if (!mounted) return;
      navigator.pop();
    });
  }

  Future<void> _showAddHabitSheet() async {
    final canCreate = await _habitService.canCreateHabit();
    if (!canCreate && mounted) {
      navigateToProfileForProUpgrade(context);
      return;
    }
    if (!mounted) return;
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

  /// Non-premium users see only: daily verse, daily daan (donate), japa (meditation) tasks, japa counter.
  static const _nonPremiumTaskSlugs = {
    'daily_verse',
    'donate',
    'daily_meditation',
    'morning_meditation',
    'pranayama',
    'japa_108',
  };

  List<UserDailyTask> get _visibleTasks => _isPremium
      ? _tasks
      : _tasks.where((t) => _nonPremiumTaskSlugs.contains(t.slug)).toList();

  List<UserDailyTask> get _pendingTasks =>
      _visibleTasks.where((t) => t.isPending).toList();
  List<CustomHabit> get _todaysHabits =>
      _habits.where((h) => h.isScheduledForToday).toList();
  List<CustomHabit> get _completedHabits =>
      _todaysHabits.where((h) => _habitService.isCompletedToday(h.id)).toList();

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 100;

    return Scaffold(
      backgroundColor: AppColors.ashramBackgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: headerHeight,
              child: _buildAshramHeader(context),
            ),
            Expanded(
              child: _buildAshramBody(),
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

  Widget _buildAshramHeader(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final currencyName = AppStrings.get('ashram_currency', lang);
    final level = _progress?.spiritualLevel ?? 1;
    final levelProgress = _progress?.levelProgress ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.ashramBackgroundDark.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryOrange.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.myGrowth),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  FutureBuilder<({String displayName, String? avatarUrl})>(
                    future: _profileFuture,
                    builder: (context, snap) {
                      final avatarUrl = snap.data?.avatarUrl;
                      return _AshramProfileAvatar(level: level, avatarUrl: avatarUrl);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<({String displayName, String? avatarUrl})>(
                      future: _profileFuture,
                      builder: (context, snap) {
                        final displayName = snap.data?.displayName ?? 'Sadhak';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            StreamBuilder<int>(
                              stream: _coinService.coinStream,
                              initialData: _coinService.currentBalance,
                              builder: (context, coinSnap) {
                                final coins = coinSnap.data ?? 0;
                                return KeyedSubtree(
                                  key: _coinCounterKey,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.card_giftcard_rounded,
                                        size: 14,
                                        color: AppColors.primaryOrange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$coins $currencyName',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryOrange,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: levelProgress.clamp(0.0, 1.0),
                                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                                            minHeight: 4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          _NotificationBell(),
        ],
      ),
    );
  }

  Widget _buildAshramBody() {
    final now = AppClock.now();
    final dateStr = '${now.day} ${_monthName(now.month)}, ${now.year}';

    return CustomScrollView(
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 28)),
        if (kDebugMode && kShowDebugDateBanner)
          SliverToBoxAdapter(
            child: _buildDebugDateBanner(),
          ),
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
          // Panchang / calendar: Practice Tools → Panchang only (no top strip).

          // ─── Today's Path (collapsible) ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _todayPathExpanded = !_todayPathExpanded),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          _todayPathExpanded ? Icons.expand_more : Icons.chevron_right,
                          color: AppColors.primaryOrange,
                          size: 28,
                        ),
                        Icon(Icons.auto_awesome, color: AppColors.primaryOrange, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's Path",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                dateStr,
                                style: GoogleFonts.poppins(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_visibleTasks.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_visibleTasks.where((t) => t.isCompleted).length}/${_visibleTasks.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ),
                          if (_pendingTasks.isEmpty) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.greenAccent.withValues(alpha: 0.95),
                              size: 28,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_todayPathExpanded)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: _streakStyleDecoration,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_visibleTasks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'No tasks for today',
                              style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else ...[
                          ...List.generate(_visibleTasks.length, (index) {
                            final task = _visibleTasks[index];
                            final alt = index.isEven;
                            return KeyedSubtree(
                              key: _getTaskKey(task.id),
                              child: _TodayPathTaskRow(
                                task: task,
                                alternatingBg: alt,
                                onTap: () => _onTaskTap(task),
                                onCheckTap: () => _toggleTaskCompletion(task),
                                hasScreen: _hasScreen(task),
                                onNavigate: () => _navigateToTaskScreen(task),
                              ),
                            );
                          }),
                          if (_pendingTasks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                              child: Center(
                                child: Text(
                                  AppStrings.get(
                                    'all_tasks_complete_compact',
                                    ref.watch(languageProvider),
                                  ),
                                  style: GoogleFonts.poppins(
                                    color: Colors.greenAccent.withValues(alpha: 0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Active Journey (Pro): visible for everyone; full cards need Pro ───
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, _) {
                final allJourneys = ref.watch(allUserJourneysProvider).valueOrNull ?? [];
                final activeJourneys = allJourneys.where((j) => j.isActive).toList();
                final types = ref.watch(journeyTypesProvider).valueOrNull ?? [];
                if (activeJourneys.isEmpty && _isPremium) {
                  return const SizedBox.shrink();
                }
                var allActivePathComplete = false;
                if (activeJourneys.isNotEmpty) {
                  allActivePathComplete = true;
                  for (final j in activeJourneys) {
                    final t = ref.watch(todaysJourneyTasksProvider(j.id)).valueOrNull ?? [];
                    if (t.isEmpty || !t.every((twc) => twc.isCompleted)) {
                      allActivePathComplete = false;
                      break;
                    }
                  }
                }
                final subtitle = activeJourneys.isEmpty
                    ? (_isPremium ? '' : 'Pro — continue paths in Granthalaya')
                    : (activeJourneys.length == 1 ? '1 journey' : '${activeJourneys.length} journeys');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (!_isPremium) {
                            navigateToProfileForProUpgrade(
                              context,
                              message:
                                  'Active journeys and guided paths unlock with Pro. Continue in Granthalaya after upgrading.',
                            );
                            return;
                          }
                          setState(() => _activeJourneyExpanded = !_activeJourneyExpanded);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: Row(
                            children: [
                              Icon(
                                (_activeJourneyExpanded && _isPremium)
                                    ? Icons.expand_more
                                    : Icons.chevron_right,
                                color: AppColors.primaryOrange,
                                size: 28,
                              ),
                              Icon(Icons.spa_rounded, color: AppColors.primaryOrange, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Active Journey',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (AppConfig.showProMarkForPremiumFeature(
                                          _isPremium,
                                        )) ...[
                                          const SizedBox(width: 8),
                                          const ProGradientLabel(),
                                        ],
                                      ],
                                    ),
                                    if (subtitle.isNotEmpty)
                                      Text(
                                        subtitle,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (activeJourneys.isNotEmpty && allActivePathComplete && _isPremium)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.greenAccent.withValues(alpha: 0.95),
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_activeJourneyExpanded && _isPremium)
                      for (final active in activeJourneys)
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                          child: _JourneyCard(
                            userJourney: active,
                            types: types,
                            streakStyleDecoration: _streakStyleDecoration,
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── My habits (collapsible) ───
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final lang = ref.watch(languageProvider);
                final habitCount = _todaysHabits.isNotEmpty ? _todaysHabits.length : _habits.length;
                final allHabitsDone =
                    habitCount > 0 && _completedHabits.length == habitCount;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (!_isPremium) {
                            navigateToProfileForProUpgrade(
                              context,
                              message:
                                  'Custom habits and full tracking are part of Pro. Open Profile to upgrade.',
                            );
                            return;
                          }
                          setState(() => _myHabitsExpanded = !_myHabitsExpanded);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                          child: Row(
                            children: [
                              Icon(
                                (_myHabitsExpanded && _isPremium)
                                    ? Icons.expand_more
                                    : Icons.chevron_right,
                                color: AppColors.primaryOrange,
                                size: 28,
                              ),
                              Icon(Icons.repeat, color: AppColors.primaryOrange, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            AppStrings.get('my_habits', lang),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (AppConfig.showProMarkForPremiumFeature(
                                          _isPremium,
                                        )) ...[
                                          const SizedBox(width: 8),
                                          const ProGradientLabel(),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${_completedHabits.length}/$habitCount ${AppStrings.get('today', lang)}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (habitCount > 0) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryOrange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${_completedHabits.length}/$habitCount',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ),
                                ),
                                if (allHabitsDone) ...[
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.greenAccent.withValues(alpha: 0.95),
                                    size: 28,
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_myHabitsExpanded && _isPremium) ...[
                      if (_habits.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showAddHabitSheet,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: _streakStyleDecoration,
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 40,
                                        color: AppColors.primaryOrange.withValues(alpha: 0.8),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppStrings.get('add', lang) + ' personal practice',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: _streakStyleDecoration,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...List.generate(
                                    (_todaysHabits.isNotEmpty ? _todaysHabits : _habits).length,
                                    (index) {
                                      final list = _todaysHabits.isNotEmpty ? _todaysHabits : _habits;
                                      final habit = list[index];
                                      final isCompleted = _habitService.isCompletedToday(habit.id);
                                      final isLast = index == list.length - 1;
                                      return KeyedSubtree(
                                        key: _getHabitKey(habit.id),
                                        child: _FullWidthHabitRow(
                                          habit: habit,
                                          isCompleted: isCompleted,
                                          readOnly: !_isPremium,
                                          onTap: () => _onHabitTap(habit),
                                          onNavigate: () => _navigateToHabitDetail(habit),
                                          onLongPress:
                                              _isPremium ? () => _showHabitOptions(habit) : null,
                                          showDivider: !isLast,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Practice Tools ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: _streakStyleDecoration,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    InkWell(
                      onTap: () => setState(() => _practiceToolsExpanded = !_practiceToolsExpanded),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              color: AppColors.primaryOrange,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Practice Tools',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              _practiceToolsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: AppColors.primaryOrange,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_practiceToolsExpanded) ...[
                      Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.1,
                          children: [
                            _PracticeToolTile(
                              icon: Icons.touch_app_rounded,
                              label: 'Japa Counter',
                              locked: !_isPremium,
                              onTap: _isPremium
                                  ? () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const JapaCounterScreen(),
                                        ),
                                      )
                                  : () => navigateToProfileForProUpgrade(context),
                            ),
                            _PracticeToolTile(
                              icon: Icons.music_note_rounded,
                              label: 'Chants',
                              locked: !_isPremium,
                              onTap: _isPremium
                                  ? () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ChantPlayerScreen(),
                                        ),
                                      )
                                  : () => navigateToProfileForProUpgrade(context),
                            ),
                            _PracticeToolTile(
                              icon: Icons.calendar_month_rounded,
                              label: 'Panchang',
                              locked: !_isPremium,
                              onTap: _isPremium
                                  ? _openPanchangMonthSheet
                                  : () => navigateToProfileForProUpgrade(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ],
    );
  }

  String _monthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[(month - 1).clamp(0, 11)];
  }

  static IconData _journeyTaskIcon(String slug) {
    if (slug.contains('mantra') || slug.contains('chant') || slug.contains('listen')) return Icons.graphic_eq_rounded;
    if (slug.contains('story') || slug.contains('read')) return Icons.menu_book_rounded;
    if (slug.contains('affirmation') || slug.contains('heart')) return Icons.favorite_rounded;
    if (slug.contains('stretch') || slug.contains('yoga') || slug.contains('movement')) return Icons.self_improvement_rounded;
    return Icons.task_alt_rounded;
  }

  void _openPanchangMonthSheet() {
    if (!_isPremium) {
      navigateToProfileForProUpgrade(context);
      return;
    }
    final now = AppClock.now();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, _) => PanchangMonthSheet(
          initialDate: now,
          onDaySelected: (d) {
            Navigator.of(context).pop();
            _openPanchangDetailSheet(d);
          },
        ),
      ),
    );
  }

  void _openPanchangDetailSheet(DateTime d) {
    if (!_isPremium) {
      navigateToProfileForProUpgrade(context);
      return;
    }
    final day = PanchangEngine.getPanchangDay(d.year, d.month, d.day);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, _) => PanchangDetailSheet(
          day: day,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Future<void> _toggleTaskCompletion(UserDailyTask task) async {
    if (task.isCompleted) {
      await _taskService.uncompleteTask(task);
    } else {
      final result = await _taskService.completeTask(task);
      // Do not call refresh() here — it reloads from the server before persist finishes
      // and wipes the optimistic update (checkbox looked “one task behind”).
      if (mounted && result.success && result.coinsEarned > 0) {
        final taskKey = _taskKeys[task.id];
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

/// One card per journey: title = journey name only, no "Active Journey" label.
class _JourneyCard extends ConsumerWidget {
  const _JourneyCard({
    required this.userJourney,
    required this.types,
    required this.streakStyleDecoration,
  });

  final UserJourney userJourney;
  final List<JourneyType> types;
  final BoxDecoration streakStyleDecoration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeyType = types.where((t) => t.id == userJourney.journeyTypeId).firstOrNull;
    final todaysAsync = ref.watch(todaysJourneyTasksProvider(userJourney.id));
    final todaysTasks = todaysAsync.valueOrNull ?? [];
    final tasks = todaysTasks;
    final allTasksAsync = ref.watch(journeyTasksProvider(userJourney.journeyTypeId));
    final allTasks = allTasksAsync.valueOrNull ?? [];
    JourneyPhase? phase;
    if (allTasks.isNotEmpty) {
      final phases = JourneyLogic.extractPhases(allTasks);
      try {
        phase = JourneyLogic.getCurrentPhase(userJourney, phases);
      } catch (_) {}
    }
    final rpcCompleted =
        ref.watch(journeyCompletedTaskIdsTodayProvider(userJourney.id)).valueOrNull ?? {};
    final completedTaskIdsToday = <String>{
      ...rpcCompleted,
      ...tasks.where((t) => t.isCompleted).map((t) => t.task.id),
    };
    final dayProg = JourneyLogic.journeyDayProgress(userJourney);
    final currentDay = dayProg.currentDay;
    final title = journeyType?.title ?? 'Journey';
    final allTodayDone =
        tasks.isNotEmpty && tasks.every((twc) => completedTaskIdsToday.contains(twc.task.id));

    return Container(
      decoration: streakStyleDecoration,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.spa_rounded, color: AppColors.primaryOrange, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Day $currentDay · Today’s tasks',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            if (allTodayDone)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.greenAccent.withValues(alpha: 0.9), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Today's path complete",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (todaysAsync.isLoading && tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange),
                  ),
                ),
              )
            else if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No tasks for this journey yet.',
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < tasks.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                    _AshramJourneyTodayTaskRow(
                      key: ValueKey<String>('ashram_journey_task_${tasks[i].task.id}'),
                      userJourney: userJourney,
                      twc: tasks[i],
                      phase: phase,
                      allTasks: allTasks,
                      completedTaskIdsToday: completedTaskIdsToday,
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AshramJourneyTodayTaskRow extends ConsumerWidget {
  const _AshramJourneyTodayTaskRow({
    super.key,
    required this.userJourney,
    required this.twc,
    required this.phase,
    required this.allTasks,
    required this.completedTaskIdsToday,
  });

  final UserJourney userJourney;
  final JourneyTaskWithCompletion twc;
  final JourneyPhase? phase;
  final List<JourneyTask> allTasks;
  final Set<String> completedTaskIdsToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = completedTaskIdsToday.contains(twc.task.id);
    final blocked = JourneyLogic.taskCompletionBlockedReason(
      userJourney: userJourney,
      task: twc.task,
      calendarPhase: phase,
      allTasks: allTasks,
      completedTaskIdsToday: completedTaskIdsToday,
    );
    final canCheck = userJourney.isActive &&
        !userJourney.isCompleted &&
        !isDone &&
        blocked == null;
    final canUncheck = userJourney.isActive && !userJourney.isCompleted && isDone;
    final checkboxEnabled = canCheck || canUncheck;

    final task = twc.task;
    final duration = task.durationMinutes != null ? '${task.durationMinutes} mins' : '';
    final timeLabel = task.frequency == 'daily' ? 'Daily' : task.frequency;
    final subtitle = [duration, timeLabel].where((e) => e.isNotEmpty).join(' • ');

    void openDetail() {
      Navigator.of(context).pushNamed(
        AppRouter.journeyTask,
        arguments: {'userJourneyId': userJourney.id, 'taskId': task.id},
      );
    }

    Future<void> onCheckbox(bool? v) async {
      if (v == null) return;
      final uid = ref.read(currentUserIdProvider);
      if (uid == null) return;
      final ujId = userJourney.id;
      final repo = ref.read(journeyRepositoryProvider);
      try {
        if (v) {
          await repo.completeTask(
            userId: uid,
            userJourneyId: ujId,
            taskId: task.id,
            coinReward: task.coinReward,
          );
        } else {
          await repo.uncompleteTaskToday(
            userId: uid,
            userJourneyId: ujId,
            taskId: task.id,
          );
        }
        ref.invalidate(todaysJourneyTasksProvider(ujId));
        ref.invalidate(displayedJourneyTasksProvider(ujId));
        ref.invalidate(journeyCompletedTaskIdsTodayProvider(ujId));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Checkbox(
              value: isDone,
              onChanged: checkboxEnabled ? onCheckbox : null,
              shape: const CircleBorder(),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return Colors.white.withValues(alpha: 0.12);
                }
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primaryOrange;
                }
                return Colors.transparent;
              }),
              checkColor: Colors.black87,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: openDetail,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.white54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: Colors.white54,
            onPressed: openDetail,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

/// Profile avatar with level ring around it (Ashram header).
class _AshramProfileAvatar extends StatelessWidget {
  const _AshramProfileAvatar({required this.level, this.avatarUrl});

  final int level;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Level ring around avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryOrange,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0B1623),
                ),
                clipBehavior: Clip.antiAlias,
                child: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? Image.network(
                        avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderIcon(),
                      )
                    : _placeholderIcon(),
              ),
            ),
          ),
          // Level badge on the ring (bottom-right)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                '$level',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderIcon() {
    return const Icon(Icons.person_rounded, color: Colors.white38, size: 26);
  }
}

/// Notification bell in Ashram header: opens notifications list; shows dot when unread.
class _NotificationBell extends StatefulWidget {
  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNotificationService.instance.getUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = AppNotificationService.instance;
    return ValueListenableBuilder<int>(
      valueListenable: service.unreadCountNotifier,
      builder: (context, unreadCount, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.primaryOrange,
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.notificationsList);
              },
            ),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ashramBackgroundDark, width: 1.5),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Today's Path compact task row ───
class _TodayPathTaskRow extends StatelessWidget {
  final UserDailyTask task;
  final bool alternatingBg;
  final VoidCallback onTap;
  final VoidCallback onCheckTap;
  final bool hasScreen;
  final VoidCallback? onNavigate;

  const _TodayPathTaskRow({
    required this.task,
    required this.alternatingBg,
    required this.onTap,
    required this.onCheckTap,
    required this.hasScreen,
    this.onNavigate,
  });

  static String _subtitleForTask(UserDailyTask task) {
    if (task.estimatedMinutes > 0) return '${task.estimatedMinutes} mins';
    if (task.description != null && task.description!.isNotEmpty) {
      final d = task.description!;
      return d.length > 40 ? '${d.substring(0, 40)}...' : d;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    void openRow() {
      if (hasScreen && onNavigate != null) {
        onNavigate!();
      } else {
        onTap();
      }
    }

    final subtitle = _subtitleForTask(task);
    return Material(
      color: alternatingBg ? Colors.white.withValues(alpha: 0.04) : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Checkbox(
                value: task.isCompleted,
                onChanged: (v) {
                  if (v == null) return;
                  if (v != task.isCompleted) onCheckTap();
                },
                shape: const CircleBorder(),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primaryOrange;
                  }
                  return Colors.transparent;
                }),
                checkColor: Colors.black87,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: openRow,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.white54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              color: Colors.white54,
              onPressed: openRow,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Full-width habit row (like Today's task rows) ───
class _FullWidthHabitRow extends StatelessWidget {
  const _FullWidthHabitRow({
    required this.habit,
    required this.isCompleted,
    required this.readOnly,
    required this.onTap,
    required this.onNavigate,
    this.onLongPress,
    this.showDivider = true,
  });

  final CustomHabit habit;
  final bool isCompleted;
  /// When true, row tap opens detail only; no toggle / long-press edits.
  final bool readOnly;
  final VoidCallback onTap;
  final VoidCallback onNavigate;
  final VoidCallback? onLongPress;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Checkbox(
                    value: isCompleted,
                    onChanged: readOnly
                        ? null
                        : (v) {
                            if (v == null) return;
                            if (v != isCompleted) onTap();
                          },
                    shape: const CircleBorder(),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.white.withValues(alpha: 0.12);
                      }
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primaryOrange;
                      }
                      return Colors.transparent;
                    }),
                    checkColor: Colors.black87,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onNavigate,
                    onLongPress: readOnly ? null : onLongPress,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            habit.title,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            habit.frequency.displayName,
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: Colors.white54,
                  onPressed: onNavigate,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.08), indent: 52, endIndent: 16),
      ],
    );
  }
}

// ─── Compact habit card for 2-column grid ───
class _CompactHabitCard extends StatelessWidget {
  final CustomHabit habit;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onNavigate;
  final VoidCallback? onLongPress;
  final BoxDecoration? cardDecoration;

  const _CompactHabitCard({
    required this.habit,
    required this.isCompleted,
    required this.onTap,
    required this.onNavigate,
    this.onLongPress,
    this.cardDecoration,
  });

  static IconData _iconFromName(String name) {
    switch (name) {
      case 'self_improvement':
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'menu_book':
      case 'book':
        return Icons.menu_book_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'eco':
        return Icons.eco_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final decoration = cardDecoration ?? BoxDecoration(
      color: AppColors.cardDark,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    );
    return Container(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      _iconFromName(habit.iconName),
                      size: 24,
                      color: isCompleted ? Colors.green : AppColors.primaryOrange,
                    ),
                    const Spacer(),
                    if (isCompleted)
                      const Icon(Icons.check_circle, size: 18, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  habit.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  habit.frequency.displayName,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Practice Tools tile ───
class _PracticeToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool locked;

  const _PracticeToolTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: locked
                        ? Colors.white38
                        : AppColors.primaryOrange,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: locked ? Colors.white38 : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (locked)
              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: Colors.white54,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
