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
  final SanctuaryCustomizationService _customizationService = SanctuaryCustomizationService();

  @override
  void initState() {
    super.initState();
    // Initialize customization service early
    _customizationService.initialize();
  }

  void _navigateTo(NavItem item) {
    final newIndex = _getIndexForNavItem(item);
    
    // If navigating TO Ashram, refresh customization from Supabase
    if (newIndex == 2 && _currentIndex != 2) {
      _customizationService.refresh();
    }
    
    setState(() {
      _currentItem = item;
      _currentIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use IndexedStack for ALL screens to preserve state
    final screens = [
      AanganScreen(
        key: const ValueKey('aangan'),
        onBeginTap: () => _navigateTo(NavItem.chat),
      ),
      const SpiritualChatScreen(key: ValueKey('chat')),
      const AshramScreen(key: ValueKey('ashram')),
      const BooksLibraryScreen(key: ValueKey('books')),
      const ProfileScreen(key: ValueKey('profile')),
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
        backgroundColor: _currentIndex == 2
            ? AppColors.ashramBackgroundDark
            : AppColors.primaryBackground,
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
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
        return 2; // Ashram
      case NavItem.books:
        return 3;
      case NavItem.profile:
        return 4;
    }
  }
}
