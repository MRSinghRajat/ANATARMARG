import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';

/// A compact "Upgrade to Pro" promotional banner.
///
/// Shows only for free users. Check [PremiumService.instance.isPremium] before
/// including this widget -- it does **not** check premium status itself so that
/// the parent can control visibility without async overhead.
class UpgradeProBanner extends StatelessWidget {
  final String message;

  const UpgradeProBanner({
    super.key,
    this.message = 'Unlock all features with Pro',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PaywallScreen.showAsBottomSheet(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFD4AF37).withOpacity(0.20),
              const Color(0xFFD4AF37).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFD4AF37).withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Pro',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD4AF37),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFD4AF37),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
