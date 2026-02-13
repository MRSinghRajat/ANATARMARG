import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/sound_manager.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../ashram/data/models/user_spiritual_progress_model.dart';
import '../../../ashram/data/repositories/spiritual_progress_repository.dart';
import '../../../ashram/data/repositories/achievement_repository.dart';
import '../../../ashram/data/models/achievement_model.dart';
import '../../../ashram/presentation/widgets/streak_stats_card.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import '../../../subscription/presentation/screens/customer_center_screen.dart';
import '../widgets/bookmarked_section.dart';
import 'language_settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final SoundManager _soundManager = SoundManager();
  final CoinService _coinService = CoinService();
  final SpiritualProgressRepository _progressRepository = SpiritualProgressRepository();
  final AchievementRepository _achievementRepository = AchievementRepository();
  
  bool _isSoundEnabled = true;
  double _soundVolume = 0.5;
  
  UserSpiritualProgress? _progress;
  List<UserAchievement> _recentAchievements = [];
  int _totalAchievements = 0;
  int _unlockedAchievements = 0;
  bool _isPremium = false;
  bool _isLoading = true;
  
  StreamSubscription<int>? _coinSubscription;

  @override
  void initState() {
    super.initState();
    _loadSoundSettings();
    _loadUserData();
    _coinSubscription = _coinService.coinStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _coinSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSoundSettings() async {
    try {
      if (mounted) {
        setState(() {
          _isSoundEnabled = !_soundManager.isMuted;
          _soundVolume = _soundManager.volume;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load spiritual progress
      final progress = await _progressRepository.getProgress();
      
      // Load achievements
      final allAchievements = await _achievementRepository.getAllAchievements();
      final userAchievements = await _achievementRepository.getUserAchievements();
      final recentUnlocks = await _achievementRepository.getRecentUnlocks();
      
      // Check premium status
      final isPremium = await PremiumService.instance.isPremium;
      
      if (mounted) {
        setState(() {
          _progress = progress;
          _totalAchievements = allAchievements.length;
          _unlockedAchievements = userAchievements.length;
          _recentAchievements = recentUnlocks.take(3).toList();
          _isPremium = isPremium;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleSound() async {
    await _soundManager.toggleMute();
    setState(() {
      _isSoundEnabled = !_soundManager.isMuted;
    });
  }

  Future<void> _updateVolume(double value) async {
    setState(() => _soundVolume = value);
    await _soundManager.setVolume(value);
  }

  String? get _userName {
    final user = SupabaseService().client?.auth.currentUser;
    return user?.userMetadata?['full_name'] ?? 
           user?.userMetadata?['name'] ?? 
           user?.email?.split('@').first;
  }

  String? get _userEmail {
    return SupabaseService().client?.auth.currentUser?.email;
  }

  String? get _userAvatar {
    return SupabaseService().client?.auth.currentUser?.userMetadata?['avatar_url'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryOrange),
              )
            : RefreshIndicator(
                onRefresh: _loadUserData,
                color: AppColors.primaryOrange,
                child: CustomScrollView(
                  slivers: [
                    // Custom App Bar
                    SliverToBoxAdapter(
                      child: _buildHeader(),
                    ),
                    
                    // Profile Card with Avatar and Info
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildProfileCard(),
                      ),
                    ),
                    
                    // Streak Stats Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: StreakStatsCard(progress: _progress),
                      ),
                    ),
                    
                    // Coins and Premium Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildCoinsAndPremiumSection(),
                      ),
                    ),
                    
                    // Achievements Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildAchievementsSection(),
                      ),
                    ),
                    
                    // Bookmarked Section
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: BookmarkedSection(),
                      ),
                    ),
                    
                    // Settings Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildSettingsSection(),
                      ),
                    ),
                    
                    // Sign Out Button
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildSignOutButton(),
                      ),
                    ),
                    
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Profile',
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Dev settings (only in debug)
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.subscriptionDevSettings);
            },
            icon: const Icon(Icons.developer_mode, color: Colors.white38, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryOrange.withOpacity(0.15),
            AppColors.deepPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryOrange,
                      AppColors.deepPurple,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _userAvatar != null
                    ? ClipOval(
                        child: Image.network(
                          _userAvatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                        ),
                      )
                    : _buildAvatarPlaceholder(),
              ),
              // Premium badge
              if (_isPremium)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.backgroundDark, width: 2),
                    ),
                    child: const Icon(Icons.star, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName ?? 'Spiritual Seeker',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_userEmail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _userEmail!,
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getLevelColor(_progress?.spiritualLevel ?? 1).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _progress?.spiritualTitle ?? 'Beginner',
                        style: GoogleFonts.poppins(
                          color: _getLevelColor(_progress?.spiritualLevel ?? 1),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PRO',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Edit button
          IconButton(
            onPressed: () {
              // TODO: Edit profile
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Center(
      child: Text(
        (_userName ?? 'U').substring(0, 1).toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCoinsAndPremiumSection() {
    return Row(
      children: [
        // Coins card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_coinService.currentBalance}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Coins',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Premium/Subscription card
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_isPremium) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerCenterScreen()),
                );
              } else {
                PaywallScreen.showAsBottomSheet(context).then((result) {
                  if (result == true) {
                    _loadUserData();
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: _isPremium
                    ? LinearGradient(
                        colors: [
                          Colors.amber.withOpacity(0.2),
                          Colors.orange.withOpacity(0.1),
                        ],
                      )
                    : null,
                color: _isPremium ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPremium
                      ? Colors.amber.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isPremium
                          ? Colors.amber.withOpacity(0.2)
                          : AppColors.primaryOrange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPremium ? Icons.star : Icons.workspace_premium,
                      color: _isPremium ? Colors.amber : AppColors.primaryOrange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPremium ? 'Pro' : 'Upgrade',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isPremium ? 'Manage' : 'Get Pro',
                          style: GoogleFonts.poppins(
                            color: _isPremium ? Colors.amber : AppColors.primaryOrange,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unlockedAchievements / $_totalAchievements',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _totalAchievements > 0 
                  ? _unlockedAchievements / _totalAchievements 
                  : 0,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
              minHeight: 6,
            ),
          ),
          
          // Recent achievements
          if (_recentAchievements.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Recent Unlocks',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentAchievements.map((ua) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(ua.achievement?.badgeColor).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getBadgeColor(ua.achievement?.badgeColor).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getAchievementIcon(ua.achievement?.iconName),
                        color: _getBadgeColor(ua.achievement?.badgeColor),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ua.achievement?.title ?? 'Achievement',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              // Sound settings
              _buildSettingsTile(
                icon: _isSoundEnabled ? Icons.music_note : Icons.music_off,
                title: 'Background Sound',
                trailing: Switch(
                  value: _isSoundEnabled,
                  onChanged: (_) => _toggleSound(),
                  activeTrackColor: AppColors.primaryOrange.withOpacity(0.5),
                  activeColor: AppColors.primaryOrange,
                ),
              ),
              
              if (_isSoundEnabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_mute, size: 16, color: Colors.white38),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primaryOrange,
                            inactiveTrackColor: Colors.white12,
                            thumbColor: AppColors.primaryOrange,
                            overlayColor: AppColors.primaryOrange.withOpacity(0.2),
                            trackHeight: 2,
                          ),
                          child: Slider(
                            value: _soundVolume,
                            onChanged: _updateVolume,
                          ),
                        ),
                      ),
                      const Icon(Icons.volume_up, size: 16, color: Colors.white38),
                    ],
                  ),
                ),
              
              const Divider(color: Colors.white12, height: 1),
              
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () => Navigator.pushNamed(context, AppRouter.notificationsSettings),
              ),
              
              const Divider(color: Colors.white12, height: 1),
              
              _buildSettingsTile(
                icon: Icons.language,
                title: 'Language',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguageSettingsScreen()),
                ),
              ),
              
              const Divider(color: Colors.white12, height: 1),
              
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  // TODO: Show about dialog
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return TextButton(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.cardDark,
            title: Text(
              'Sign Out',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to sign out?',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        
        if (confirmed == true) {
          await SupabaseService().client?.auth.signOut();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.login,
              (route) => false,
            );
          }
        }
      },
      child: Text(
        'Sign Out',
        style: GoogleFonts.poppins(
          color: Colors.red.withOpacity(0.8),
          fontSize: 14,
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level >= 50) return Colors.purpleAccent;
    if (level >= 25) return Colors.amber;
    if (level >= 10) return Colors.lightBlue;
    return Colors.green;
  }

  Color _getBadgeColor(BadgeColor? badgeColor) {
    switch (badgeColor) {
      case BadgeColor.bronze:
        return const Color(0xFFCD7F32);
      case BadgeColor.silver:
        return Colors.grey.shade400;
      case BadgeColor.gold:
        return Colors.amber;
      case BadgeColor.purple:
        return Colors.purpleAccent;
      case BadgeColor.diamond:
        return Colors.cyanAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getAchievementIcon(String? iconName) {
    switch (iconName) {
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'check_circle':
        return Icons.check_circle;
      case 'menu_book':
        return Icons.menu_book;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'star':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }
}
