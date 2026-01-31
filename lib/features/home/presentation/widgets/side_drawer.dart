import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2A2520), // Matches book card background
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1612), // Matches screen background
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.warmOrange.withOpacity(0.3),
                  child: const Icon(Icons.person, size: 36, color: AppColors.warmOrange),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sacred Epics',
                  style: TextStyle(
                    color: AppColors.warmOrange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.home,
            title: 'Home',
            onTap: () {
              // Navigation logic would go here
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.menu_book,
            title: 'Sacred Epics',
            isSelected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(color: Colors.grey),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.warmOrange : Colors.grey.shade400,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.warmOrange : Colors.white.withOpacity(0.9),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.warmOrange.withOpacity(0.1),
      onTap: onTap,
    );
  }
}
