import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/sound_manager.dart';
import '../../../../shared/services/coin_service.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../ashram/data/models/user_spiritual_progress_model.dart';
import '../../../ashram/data/repositories/spiritual_progress_repository.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import '../providers/language_provider.dart';
import '../widgets/bookmarked_section.dart';
import 'language_settings_screen.dart';
import 'edit_profile_screen.dart';
import '../../../../core/services/compressed_image_cache.dart';
import '../../../sanctuary/data/services/sanctuary_customization_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final SoundManager _soundManager = SoundManager();
  final CoinService _coinService = CoinService();
  final SpiritualProgressRepository _progressRepository = SpiritualProgressRepository();

  bool _isSoundEnabled = true;
  double _soundVolume = 0.5;

  UserSpiritualProgress? _progress;
  bool _isPremium = false;
  bool _isLoading = true;
  bool _isClearingCache = false;
  int _avatarCacheBuster = 0;

  StreamSubscription<int>? _coinSubscription;
  StreamSubscription<bool>? _premiumSubscription;

  @override
  void initState() {
    super.initState();
    _loadSoundSettings();
    _loadUserData();
    _coinSubscription = _coinService.coinStream.listen((_) {
      if (mounted) setState(() {});
    });
    _premiumSubscription = PremiumService.instance.premiumStatusStream.listen((v) {
      if (mounted) setState(() => _isPremium = v);
    });
  }

  @override
  void dispose() {
    _premiumSubscription?.cancel();
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

  Future<void> _clearImageCache() async {
    if (_isClearingCache) return;
    setState(() => _isClearingCache = true);
    try {
      await CompressedImageCache.instance.clearCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image cache cleared. Storage freed.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            backgroundColor: AppColors.cardDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear cache: $e', style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isClearingCache = false);
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Load spiritual progress
      final progress = await _progressRepository.getProgress();

      // Check premium status
      final isPremium = await PremiumService.instance.isPremium;

      if (mounted) {
        setState(() {
          _progress = progress;
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
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
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

                    SliverToBoxAdapter(child: const SizedBox(height: 20)),

                    // Coins and Premium Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildCoinsAndPremiumSection(),
                      ),
                    ),

                    SliverToBoxAdapter(child: const SizedBox(height: 16)),

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
                      child: SizedBox(height: 24),
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
            AppStrings.get('profile', ref.watch(languageProvider)),
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
                  gradient: const LinearGradient(
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
                          '$_userAvatar${_avatarCacheBuster > 0 ? '?v=$_avatarCacheBuster' : ''}',
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
                          gradient: const LinearGradient(
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
          
          // Edit button (only when logged in)
          if (SupabaseService().currentUserId != null)
            IconButton(
              onPressed: () async {
                final updated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
                if (updated == true) {
                  setState(() => _avatarCacheBuster = DateTime.now().millisecondsSinceEpoch);
                  _loadUserData();
                }
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
              // Paywall is enabled for both free and premium users (premium can manage, restore, or redeem coupon)
              PaywallScreen.showAsBottomSheet(context).then((result) {
                if (result == true) {
                  _loadUserData();
                }
              });
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
                  const Icon(
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

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('settings', ref.watch(languageProvider)),
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
                  activeThumbColor: AppColors.primaryOrange,
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
                title: AppStrings.get('notifications', ref.watch(languageProvider)),
                onTap: () => Navigator.pushNamed(context, AppRouter.notificationsSettings),
              ),
              
              const Divider(color: Colors.white12, height: 1),
              
              _buildSettingsTile(
                icon: Icons.language,
                title: AppStrings.get('language', ref.watch(languageProvider)),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguageSettingsScreen()),
                ),
              ),
              
              const Divider(color: Colors.white12, height: 1),
              _buildSettingsTile(
                icon: Icons.cleaning_services_outlined,
                title: 'Clear image cache',
                subtitle: 'Compressed cache (~1024px per image)',
                trailing: _isClearingCache
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                      )
                    : const Icon(Icons.chevron_right, color: Colors.white38),
                onTap: _isClearingCache ? null : _clearImageCache,
              ),
              const Divider(color: Colors.white12, height: 1),
              _buildSettingsTile(
                icon: Icons.refresh_rounded,
                title: 'Reset Aangan to Default',
                subtitle: 'Restore Aangan customization to default',
                onTap: () async {
                  await SanctuaryCustomizationService().resetToDefault();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aangan reset to default'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const Divider(color: Colors.white12, height: 1),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  // TODO: Show about dialog
                },
              ),

              const Divider(color: Colors.white12, height: 1),

              // DEV: Test onboarding
              _buildSettingsTile(
                icon: Icons.play_circle_outline,
                title: 'Test Onboarding',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.spiritualOnboarding);
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
    String? subtitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
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
        AppStrings.get('sign_out', ref.watch(languageProvider)),
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

}
