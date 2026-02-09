import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../home/presentation/screens/aangan_screen.dart';
import '../../../books/presentation/screens/books_library_screen.dart';
import '../../../ashram/presentation/screens/ashram_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../prayer/presentation/screens/prayer_dashboard_screen.dart';

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

  void _navigateTo(NavItem item) {
    setState(() {
      _currentItem = item;
      _currentIndex = _getIndexForNavItem(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ashramIndex = 2;
    final otherScreens = [
      AanganScreen(
        onBeginTap: () => _navigateTo(NavItem.quests), // Prayer tab
      ),
      const PrayerDashboardScreen(),
      const BooksLibraryScreen(),
      const ProfileScreen(),
    ];
    final otherIndex = _currentIndex > ashramIndex ? _currentIndex - 1 : _currentIndex;

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
        backgroundColor: _currentIndex == ashramIndex
            ? AppColors.ashramBackgroundDark
            : AppColors.primaryBackground,
        body: _currentIndex == ashramIndex
            ? const AshramScreen()
            : IndexedStack(
                index: otherIndex,
                children: otherScreens,
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
      case NavItem.quests:
        return 1; // Prayer
      case NavItem.ashram:
        return 2; // Ashram
      case NavItem.books:
        return 3;
      case NavItem.profile:
        return 4;
    }
  }
}
