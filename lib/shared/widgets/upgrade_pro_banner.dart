import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/profile_pro_upgrade_nav.dart' show navigateToProfileForProUpgrade;
import 'pro_gradient_badge.dart';

/// Compact Pro hint for free users. Upgrade happens from Profile only.
///
/// Check [PremiumService.instance.isPremium] before including this widget.
class UpgradeProBanner extends StatelessWidget {
  final String message;

  const UpgradeProBanner({
    super.key,
    this.message = 'Unlock all features with Pro',
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => navigateToProfileForProUpgrade(
              context,
              message: 'Reading, stories, and full library access grow with Pro. Open Profile to view plans.',
            ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryOrange.withValues(alpha: 0.18),
                AppColors.deepPurple.withValues(alpha: 0.14),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryOrange.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryOrange.withValues(alpha: 0.35),
                  ),
                ),
                child: const ProGradientPremiumIcon(size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const ProGradientLabel(fontSize: 15),
                        Text(
                          ' · Profile',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primaryOrange.withValues(alpha: 0.9),
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
