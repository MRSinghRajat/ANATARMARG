import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/aangan_notification_realtime_service.dart';
import '../../../../core/services/daily_streak_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../providers/main_navigation_intent_provider.dart';
import '../../../home/presentation/screens/aangan_screen.dart';
import '../../../books/presentation/screens/books_library_screen.dart';
import '../../../ashram/presentation/screens/ashram_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../chat/presentation/screens/spiritual_chat_screen.dart';
import '../../../sanctuary/data/services/sanctuary_customization_service.dart';
import '../../../streak/presentation/screens/day1_streak_screen.dart';
import '../../../streak/presentation/screens/missed_you_streak_screen.dart';
import '../../../streak/presentation/screens/commitment_streak_screen.dart';
import '../../../streak/presentation/widgets/streak_count_dialog.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../onboarding/presentation/widgets/first_run_coach_overlay.dart';
import '../../../profile/presentation/providers/language_provider.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  NavItem _currentItem = NavItem.home;
  int _currentIndex = 0;
  DateTime? _lastBackPress;
  ProviderSubscription<MainNavIntent?>? _mainNavIntentSubscription;
  final SanctuaryCustomizationService _customizationService =
      SanctuaryCustomizationService();

  /// Keys for each bottom tab (tour spotlight + layout).
  late final Map<NavItem, GlobalKey> _navTabItemKeys = {
    NavItem.home: GlobalKey(debugLabel: 'nav_tab_home'),
    NavItem.chat: GlobalKey(debugLabel: 'nav_tab_chat'),
    NavItem.ashram: GlobalKey(debugLabel: 'nav_tab_ashram'),
    NavItem.books: GlobalKey(debugLabel: 'nav_tab_books'),
    NavItem.profile: GlobalKey(debugLabel: 'nav_tab_profile'),
  };

  /// Tracks which tabs have been visited so we build them lazily.
  final Set<int> _initializedTabs = {0};

  /// Incremented each time user switches to AI Guru tab so animations replay.
  int _chatTabAnimationSeed = 0;

  @override
  void initState() {
    super.initState();
    _customizationService.initialize();
    _mainNavIntentSubscription =
        ref.listenManual<MainNavIntent?>(mainNavIntentProvider, (previous, intent) {
      if (intent == null) return;
      final nav = intent.nav;
      final aTab = intent.aanganTabIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(mainNavIntentProvider.notifier).state = null;
        _navigateTo(nav);
        if (nav == NavItem.home && aTab != null) {
          ref.read(aanganPendingTabProvider.notifier).state = aTab;
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyStreak();
      _scheduleBackgroundTabWarm();
      _startAanganNotificationRealtime();
    });
  }

  void _startAanganNotificationRealtime() {
    if (!SupabaseService().isInitialized) return;
    final code =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode;
    final region =
        (code != null && code.isNotEmpty) ? code : null;
    AanganNotificationRealtimeService.instance.stop();
    AanganNotificationRealtimeService.instance.start(userRegion: region);
  }

  /// Mount inactive tabs across subsequent frames so the first tap on each tab
  /// does not pay the full first-build cost in one interaction.
  void _scheduleBackgroundTabWarm() {
    const order = <int>[4, 3, 2, 1];
    var i = 0;
    void step() {
      if (!mounted || i >= order.length) return;
      final idx = order[i];
      i++;
      if (!_initializedTabs.contains(idx)) {
        setState(() => _initializedTabs.add(idx));
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => step());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => step());
  }

  @override
  void dispose() {
    AanganNotificationRealtimeService.instance.stop();
    _mainNavIntentSubscription?.close();
    super.dispose();
  }

  Future<void> _checkDailyStreak() async {
    if (!mounted) return;
    final userId = SupabaseService().currentUserId;
    await DailyStreakService.instance.init();
    DailyStreakService.instance.setUserId(userId);
    await CoinService().initialize();
    final result = await DailyStreakService.instance.recordVisitAndGetPrompt();

    if (!mounted) return;
    switch (result.prompt) {
      case DailyStreakPrompt.day1:
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (day1Context) => Day1StreakScreen(
              onLetsGo: () {
                final nav = Navigator.of(day1Context);
                if (nav.canPop()) nav.pop();
              },
              onSetGoal: result.showCommitmentAfter
                  ? () => _openCommitmentThenPop(day1Context)
                  : null,
            ),
          ),
        );
        break;
      case DailyStreakPrompt.missedYou:
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => MissedYouStreakScreen(
              previousStreak: result.previousStreak,
              onStartToday: () async {
                await DailyStreakService.instance.restartStreakToday();
              },
            ),
          ),
        );
        break;
      case DailyStreakPrompt.streakCount:
        if (result.showStreakCelebration && result.currentStreak > 1) {
          await StreakCountDialog.show(context, result.currentStreak);
        }
        break;
      case DailyStreakPrompt.none:
      case DailyStreakPrompt.commitment:
        break;
    }
    if (!mounted) return;
    await _maybeShowPostLoginTabTour();
  }

  /// First visit to main tabs (after login or skip-sign-in): full bottom-nav tour. Skippable.
  Future<void> _maybeShowPostLoginTabTour() async {
    if (!mounted) return;

    final hindi = ref.read(languageProvider) == 'hi';
    await FirstRunCoachOverlay.showIfNeeded(
      context: context,
      bottomNavKey: mainNavBottomBarLayerKey,
      onNavigate: _navigateTo,
      hindi: hindi,
    );
  }

  /// [day1Context] is the [BuildContext] of [Day1StreakScreen] so pushes/pops
  /// target the same navigator route as the celebration overlay.
  Future<void> _openCommitmentThenPop(BuildContext day1Context) async {
    await Navigator.of(day1Context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => CommitmentStreakScreen(
          onCommitted: () {
            if (!ctx.mounted) return;
            final nav = Navigator.of(ctx);
            if (nav.canPop()) nav.pop();
          },
        ),
      ),
    );
    if (day1Context.mounted) {
      final nav = Navigator.of(day1Context);
      if (nav.canPop()) nav.pop();
    }
  }

  void _navigateTo(NavItem item) {
    final newIndex = _getIndexForNavItem(item);
    if (newIndex == _currentIndex) return;

    setState(() {
      _currentItem = item;
      _currentIndex = newIndex;
      _initializedTabs.add(newIndex);
      if (newIndex == 1) _chatTabAnimationSeed++;
    });
  }

  Widget _buildTab(int index) {
    if (!_initializedTabs.contains(index)) {
      return const SizedBox.shrink();
    }
    Widget child;
    switch (index) {
      case 0:
        child = AanganScreen(
          key: const ValueKey('aangan'),
          isActive: _currentIndex == 0,
          onBeginTap: () => _navigateTo(NavItem.chat),
        );
        break;
      case 1:
        child = SpiritualChatScreen(
          key: const ValueKey('chat'),
          animationSeed: _chatTabAnimationSeed,
        );
        break;
      case 2:
        child = const AshramScreen(key: ValueKey('ashram'));
        break;
      case 3:
        child = const BooksLibraryScreen(key: ValueKey('books'));
        break;
      case 4:
        child = const ProfileScreen(key: ValueKey('profile'));
        break;
      default:
        child = const SizedBox.shrink();
    }
    // Pause all animation tickers on background tabs
    return TickerMode(
      enabled: _currentIndex == index,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final now = DateTime.now();
        final shouldExit = _lastBackPress != null &&
            now.difference(_lastBackPress!).inMilliseconds < 2000;
        if (shouldExit) {
          SystemNavigator.pop();
        } else {
          _lastBackPress = now;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Press back again to exit'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: _currentIndex == 2
            ? AppColors.ashramBackgroundDark
            : AppColors.primaryBackground,
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(5, _buildTab),
        ),
        bottomNavigationBar: BottomNavBar(
          layerKey: mainNavBottomBarLayerKey,
          itemKeys: _navTabItemKeys,
          currentItem: _currentItem,
          onTap: _navigateTo,
        ),
      ),
    );
  }

  int _getIndexForNavItem(NavItem item) {
    switch (item) {
      case NavItem.home:
        return 0;
      case NavItem.chat:
        return 1;
      case NavItem.ashram:
        return 2;
      case NavItem.books:
        return 3;
      case NavItem.profile:
        return 4;
    }
  }
}
