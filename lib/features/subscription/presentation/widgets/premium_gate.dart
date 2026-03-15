import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/premium_service.dart';
import '../screens/paywall_screen.dart';

/// A widget that gates content behind premium subscription.
/// 
/// Shows [child] if user is premium, otherwise shows a premium prompt.
class PremiumGate extends StatelessWidget {
  /// The content to show if user is premium
  final Widget child;
  
  /// Custom locked content (optional)
  final Widget? lockedContent;
  
  /// Feature name to display in the upgrade prompt
  final String? featureName;
  
  /// If true, shows a subtle lock indicator instead of full overlay
  final bool subtleMode;
  
  /// Callback when upgrade is tapped
  final VoidCallback? onUpgradeTap;

  const PremiumGate({
    super.key,
    required this.child,
    this.lockedContent,
    this.featureName,
    this.subtleMode = false,
    this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: PremiumService.instance.premiumStatusStream,
      initialData: PremiumService.instance.isPremiumSync,
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;
        
        if (isPremium) {
          return child;
        }
        
        if (lockedContent != null) {
          return lockedContent!;
        }
        
        if (subtleMode) {
          return _buildSubtleLock(context);
        }
        
        return _buildFullLock(context);
      },
    );
  }

  Widget _buildSubtleLock(BuildContext context) {
    return Stack(
      children: [
        // Blurred/dimmed child
        Opacity(
          opacity: 0.5,
          child: IgnorePointer(child: child),
        ),
        
        // Lock badge
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _showPaywall(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'PRO',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFullLock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryOrange.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              color: AppColors.primaryOrange,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            featureName ?? 'Premium Feature',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Upgrade to Antar मार्ग Pro to unlock this feature',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (onUpgradeTap != null) {
                onUpgradeTap!();
              } else {
                _showPaywall(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Upgrade Now',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    PaywallScreen.showAsBottomSheet(context);
  }
}

/// A button that shows paywall when tapped if user is not premium
class PremiumButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String? featureName;

  const PremiumButton({
    super.key,
    required this.child,
    required this.onTap,
    this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: child,
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    final isPremium = await PremiumService.instance.isPremium;
    
    if (isPremium) {
      onTap();
    } else {
      final result = await PaywallScreen.showAsBottomSheet(context);
      if (result == true) {
        onTap();
      }
    }
  }
}

/// Mixin for premium-aware stateful widgets
mixin PremiumAwareMixin<T extends StatefulWidget> on State<T> {
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  @override
  void initState() {
    super.initState();
    _checkPremium();
    PremiumService.instance.premiumStatusStream.listen((status) {
      if (mounted) {
        setState(() => _isPremium = status);
      }
    });
  }

  Future<void> _checkPremium() async {
    final status = await PremiumService.instance.isPremium;
    if (mounted) {
      setState(() => _isPremium = status);
    }
  }

  Future<bool> requirePremium({
    String? featureName,
  }) async {
    if (_isPremium) return true;
    
    final result = await PaywallScreen.showAsBottomSheet(context);
    return result == true;
  }
}
