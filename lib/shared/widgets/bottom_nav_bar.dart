import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../features/navigation/presentation/providers/main_navigation_intent_provider.dart';
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
  /// Optional key to measure the bar (e.g. first-run coach highlight).
  final GlobalKey? layerKey;
  /// Keys per tab for tour spotlight geometry (optional).
  final Map<NavItem, GlobalKey>? itemKeys;

  const BottomNavBar({
    super.key,
    required this.currentItem,
    required this.onTap,
    this.layerKey,
    this.itemKeys,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final tourHighlight = ref.watch(tabTourHighlightProvider);
    return Container(
      key: layerKey,
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
                _buildNavItem(context, NavItem.home, Icons.home, AppStrings.get('nav_aangan', lang), tourHighlight),
                _buildNavItem(context, NavItem.chat, Icons.auto_awesome, AppStrings.get('nav_ai_guru', lang), tourHighlight),
                _buildNavItem(context, NavItem.ashram, Icons.temple_buddhist, AppStrings.get('nav_ashram', lang), tourHighlight),
                _buildNavItem(context, NavItem.books, Icons.menu_book, AppStrings.get('nav_granthalya', lang), tourHighlight),
                _buildNavItem(context, NavItem.profile, Icons.person, AppStrings.get('nav_profile', lang), tourHighlight),
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
    NavItem? tourHighlight,
  ) {
    final isActive = currentItem == item;
    final isTourSpot = tourHighlight == item;
    final color = AppColors.ashramSaffron;
    final key = itemKeys?[item];

    Widget child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: isTourSpot ? const EdgeInsets.symmetric(horizontal: 2, vertical: 2) : EdgeInsets.zero,
        decoration: isTourSpot
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.95), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isTourSpot ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 420),
              curve: Curves.elasticOut,
              child: Icon(
                icon,
                color: isActive || isTourSpot ? color : Colors.grey.shade400,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive || isTourSpot ? color : Colors.grey.shade400,
                fontSize: 9,
                fontWeight: isActive || isTourSpot ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );

    child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(item),
        splashColor: color.withOpacity(0.15),
        highlightColor: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );

    return Expanded(
      key: key,
      child: child,
    );
  }
}
