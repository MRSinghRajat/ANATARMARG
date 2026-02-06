import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../home/presentation/screens/aangan_screen.dart';
import '../../../books/presentation/providers/book_providers.dart';
import '../../../books/presentation/screens/books_library_screen.dart';
import '../../../books/presentation/widgets/granthalaya_resume_bar.dart';
import '../../../shop/presentation/screens/shop_screen.dart';
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
    final screens = [
      AanganScreen(
        onBeginTap: () => _navigateTo(NavItem.quests), // Prayer tab
      ),
      const PrayerDashboardScreen(),
      const ShopScreen(), // Ashram
      const BooksLibraryScreen(),
      const ProfileScreen(),
    ];

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
        backgroundColor: AppColors.primaryBackground,
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentItem == NavItem.books &&
                ref.watch(granthalayaReadModeProvider))
              const GranthalayaResumeBar(),
            BottomNavBar(
              currentItem: _currentItem,
              onTap: _navigateTo,
            ),
          ],
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
