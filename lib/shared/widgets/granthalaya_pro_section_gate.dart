import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/profile_pro_upgrade_nav.dart' show openProfileTabForProUpgrade;
import 'pro_gradient_badge.dart';

/// Full-section Pro gate: Granthalaya Listen / Journey, and Aangan 3D Mandir (free tier).
/// Hero icon, title, subtitle, Pro gradient row, feature pills, bottom bar (secondary + Open Profile).
class GranthalayaProSectionGate extends StatelessWidget {
  const GranthalayaProSectionGate({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onSecondary,
    this.secondaryLabel = 'Read',
    this.featurePills,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  /// e.g. switch Granthalaya tab to Read, or Aangan tab to Aatma.
  final VoidCallback onSecondary;
  final String secondaryLabel;
  final List<String>? featurePills;

  static const List<String> defaultFeaturePills = [
    'Ad-free listening',
    'Full journeys',
    'Sacred audio library',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.ashramAccentGold.withValues(alpha: 0.35),
                        AppColors.deepPurple.withValues(alpha: 0.25),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ashramAccentGold.withValues(alpha: 0.15),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.ashramAccentGold.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 44,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF5F0E8),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.zinc500,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ProGradientPremiumIcon(size: 22),
                    const SizedBox(width: 8),
                    const ProGradientLabel(fontSize: 18),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: (featurePills ?? defaultFeaturePills)
                      .map(_pill)
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.ashramBackgroundDark.withValues(alpha: 0.92),
                AppColors.ashramBackgroundDark,
              ],
              stops: const [0.0, 0.35, 1.0],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      secondaryLabel,
                      style: GoogleFonts.tenorSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => openProfileTabForProUpgrade(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ashramAccentGold,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          size: 18,
                          color: Colors.black.withValues(alpha: 0.88),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Open Profile',
                          style: GoogleFonts.tenorSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.ashramAccentGold.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.72),
        ),
      ),
    );
  }
}
