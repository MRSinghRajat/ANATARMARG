import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/sound_manager.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../shared/widgets/pro_gradient_badge.dart';
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
  final SpiritualProgressRepository _progressRepository = SpiritualProgressRepository();

  bool _isSoundEnabled = true;
  double _soundVolume = 0.5;

  UserSpiritualProgress? _progress;
  bool _isPremium = false;
  bool _isLoading = true;
  bool _isClearingCache = false;
  int _avatarCacheBuster = 0;

  StreamSubscription<bool>? _premiumSubscription;

  @override
  void initState() {
    super.initState();
    _loadSoundSettings();
    _loadUserData();
    _premiumSubscription = PremiumService.instance.premiumStatusStream.listen((v) {
      if (mounted) setState(() => _isPremium = v);
    });
  }

  @override
  void dispose() {
    _premiumSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSoundSettings() async {
    try {
      await _soundManager.initialize();
      if (mounted) {
        setState(() {
          _isSoundEnabled = !_soundManager.isMuted;
          _soundVolume = _soundManager.volume;
        });
      }
    } catch (_) {}
  }

  Future<void> _setBackgroundSoundEnabled(bool enabled) async {
    await _soundManager.setBackgroundSoundEnabled(enabled);
    if (mounted) {
      setState(() {
        _isSoundEnabled = !_soundManager.isMuted;
        _soundVolume = _soundManager.volume;
      });
    }
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

  Future<void> _updateVolume(double value) async {
    setState(() => _soundVolume = value);
    await _soundManager.setVolume(value);
  }

  Future<void> _openUserProfileDetails() async {
    if (SupabaseService().currentUserId == null) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );
    if (updated == true && mounted) {
      setState(() => _avatarCacheBuster = DateTime.now().millisecondsSinceEpoch);
      _loadUserData();
    }
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

                    // Pro / subscription (same gradient language as Granthalaya gates)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildPremiumSection(),
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
    final lang = ref.watch(languageProvider);
    final title = AppStrings.get('profile', lang);
    final loggedIn = SupabaseService().currentUserId != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (loggedIn)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openUserProfileDetails,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Text(
                    title,
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          else
            Text(
              title,
              style: GoogleFonts.cormorantGaramond(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          const Spacer(),
          if (kDebugMode)
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
    final loggedIn = SupabaseService().currentUserId != null;
    final card = Container(
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
              if (_isPremium)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryOrange, AppColors.deepPurple],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.backgroundDark, width: 2),
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
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
                      const ProGradientLabel(fontSize: 11),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (loggedIn)
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.35),
              size: 28,
            ),
        ],
      ),
    );

    if (!loggedIn) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openUserProfileDetails,
        borderRadius: BorderRadius.circular(20),
        child: card,
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

  Widget _buildPremiumSection() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          PaywallScreen.showRevenueCatPaywallOrCustom(context).then((result) {
            if (result == true) {
              _loadUserData();
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryOrange.withValues(alpha: 0.2),
                AppColors.deepPurple.withValues(alpha: 0.16),
              ],
            ),
            border: Border.all(
              width: 1.5,
              color: AppColors.primaryOrange.withValues(alpha: 0.38),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepPurple.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryOrange.withValues(alpha: 0.45),
                  ),
                ),
                child: const ProGradientPremiumIcon(size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const ProGradientLabel(fontSize: 17),
                        Text(
                          _isPremium ? ' · Active' : ' · Plans',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isPremium
                          ? 'Manage subscription, restore purchases, or redeem offers'
                          : 'Upgrade for Mandir, Granthalaya, journeys & more',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryOrange.withValues(alpha: 0.85),
                size: 24,
              ),
            ],
          ),
        ),
      ),
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
                  onChanged: _setBackgroundSoundEnabled,
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
                icon: Icons.article_outlined,
                title: 'Terms of Service',
                onTap: () => Navigator.pushNamed(context, AppRouter.termsOfService),
              ),
              const Divider(color: Colors.white12, height: 1),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => Navigator.pushNamed(context, AppRouter.privacyPolicy),
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
