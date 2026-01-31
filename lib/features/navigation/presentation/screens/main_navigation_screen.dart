import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../books/presentation/screens/books_library_screen.dart';
import '../../../shop/presentation/screens/shop_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  NavItem _currentItem = NavItem.home;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(isYatraTab: false), // Aangan
    const ShopScreen(),
    const HomeScreen(isYatraTab: true), // Yatra - character walks
    const BooksLibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentItem: _currentItem,
        onTap: (item) {
          setState(() {
            _currentItem = item;
            _currentIndex = _getIndexForNavItem(item);
          });
        },
      ),
    );
  }

  int _getIndexForNavItem(NavItem item) {
    switch (item) {
      case NavItem.home:
        return 0;
      case NavItem.ashram:
        return 1;
      case NavItem.quests:
        return 2;
      case NavItem.books:
        return 3;
      case NavItem.profile:
        return 4;
    }
  }
}
