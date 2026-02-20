import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../home/presentation/screens/aangan_screen.dart';
import '../../../books/presentation/screens/books_library_screen.dart';
import '../../../ashram/presentation/screens/ashram_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../chat/presentation/screens/spiritual_chat_screen.dart';
import '../../../sanctuary/data/services/sanctuary_customization_service.dart';

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
  final SanctuaryCustomizationService _customizationService =
      SanctuaryCustomizationService();

  /// Tracks which tabs have been visited so we build them lazily.
  final Set<int> _initializedTabs = {0};

  @override
  void initState() {
    super.initState();
    _customizationService.initialize();
  }

  void _navigateTo(NavItem item) {
    final newIndex = _getIndexForNavItem(item);
    if (newIndex == _currentIndex) return;

    if (newIndex == 2 && _currentIndex != 2) {
      _customizationService.refresh();
    }

    setState(() {
      _currentItem = item;
      _currentIndex = newIndex;
      _initializedTabs.add(newIndex);
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
          onBeginTap: () => _navigateTo(NavItem.chat),
        );
        break;
      case 1:
        child = const SpiritualChatScreen(key: ValueKey('chat'));
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
