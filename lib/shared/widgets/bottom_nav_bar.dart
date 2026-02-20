import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../features/profile/presentation/providers/language_provider.dart';

enum NavItem {
  home,
  books,
  chat,
  ashram,
  profile,
}

class BottomNavBar extends ConsumerWidget {
  final NavItem currentItem;
  final Function(NavItem) onTap;

  const BottomNavBar({
    super.key,
    required this.currentItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, NavItem.home, Icons.home, AppStrings.get('nav_aangan', lang)),
                _buildNavItem(context, NavItem.chat, Icons.auto_awesome, AppStrings.get('nav_ai_guru', lang)),
                _buildNavItem(context, NavItem.ashram, Icons.temple_buddhist, AppStrings.get('nav_ashram', lang)),
                _buildNavItem(context, NavItem.books, Icons.menu_book, AppStrings.get('nav_granthalya', lang)),
                _buildNavItem(context, NavItem.profile, Icons.person, AppStrings.get('nav_profile', lang)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavItem item,
    IconData icon,
    String label,
  ) {
    final isActive = currentItem == item;
    final color = AppColors.ashramSaffron;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(item),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(0, isActive ? -4 : 0, 0),
                    child: Icon(
                      icon,
                      color: isActive ? color : Colors.grey.shade400,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? color : Colors.grey.shade400,
                      fontSize: 9,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
