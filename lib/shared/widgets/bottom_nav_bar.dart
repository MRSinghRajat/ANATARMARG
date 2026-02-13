import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum NavItem {
  home,
  books,
  chat,
  ashram,
  profile,
}

class BottomNavBar extends StatelessWidget {
  final NavItem currentItem;
  final Function(NavItem) onTap;

  const BottomNavBar({
    super.key,
    required this.currentItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900, // Dark grey background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                NavItem.home,
                Icons.home,
                AppColors.earthBrown,
                'AANGAN',
              ),
              _buildNavItem(
                context,
                NavItem.chat,
                Icons.auto_awesome,
                AppColors.earthBrown,
                'AI GURU',
              ),
              _buildNavItem(
                context,
                NavItem.ashram,
                Icons.temple_buddhist,
                AppColors.ashramSaffron,
                'ASHRAM',
                isCenter: true,
              ),
              _buildNavItem(
                context,
                NavItem.books,
                Icons.menu_book,
                AppColors.earthBrown,
                'GRANTHALYA',
              ),
              _buildNavItem(
                context,
                NavItem.profile,
                Icons.person,
                AppColors.earthBrown,
                'PROFILE',
                hasNotification: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavItem item,
    IconData icon,
    Color color,
    String label, {
    bool isCenter = false,
    bool hasNotification = false,
  }) {
    final isActive = currentItem == item;

    if (isCenter && isActive) {
      return GestureDetector(
        onTap: () => onTap(item),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 72,
              height: 14,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => onTap(item),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isActive ? color : Colors.grey.shade400,
                size: 24,
              ),
              if (hasNotification && !isActive)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade900, width: 1),
                    ),
                    child: const Center(
                      child: Text(
                        '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 72,
            height: 14,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? color : Colors.grey.shade400,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
